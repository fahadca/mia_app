from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
import cv2
import firebase_admin
from firebase_admin import credentials, firestore
from facenet_pytorch import MTCNN, InceptionResnetV1
import torch
import time
# import yolov5
from ultralytics import YOLO
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
# from sendgrid import SendGridAPIClient
# from sendgrid.helpers.mail import Mail
import os
from dotenv import load_dotenv

app = Flask(__name__)
cred = credentials.Certificate("miaapp-d291d-firebase-adminsdk-fbsvc-0553353d59.json")
firebase_admin.initialize_app(cred)
db = firestore.client()


load_dotenv()


SMTP_EMAIL = os.getenv("SMTP_EMAIL")
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD")
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
mtcnn = MTCNN(image_size=160, margin=0)
facenet = InceptionResnetV1(pretrained='vggface2').eval()
# yolo_model = yolov5.load('yolov5s.pt')  # Load YOLOv5 model
yolo_model = YOLO("yolov8s.pt")  # Load YOLOv8 small model

def get_embedding(image):
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    face = mtcnn(image)
    if face is None:
        return None
    return facenet(face.unsqueeze(0)).detach().numpy()

@app.route('/register_face', methods=['POST'])
def register_face():
    name = request.form.get('name')
    image_data = request.files.get('image')
    
    if not name or not image_data:
        return jsonify({"error": "Missing name or image"}), 400
    
    image = cv2.imdecode(np.frombuffer(image_data.read(), np.uint8), cv2.IMREAD_COLOR)
    embedding = get_embedding(image)
    
    if embedding is None:
        return jsonify({"error": "No face detected"}), 400
    
    db.collection('faces').document(name).set({'embedding': embedding.flatten().tolist()})
    return jsonify({"message": "Face registered successfully"}), 200

@app.route('/recognize_face', methods=['POST'])
def recognize_face():
    image = cv2.imdecode(np.frombuffer(request.files['image'].read(), np.uint8), cv2.IMREAD_COLOR)
    embedding = get_embedding(image)
    
    if embedding is None:
        return jsonify({"name": "No Face Detected"})
    
    faces = db.collection('faces').stream()
    min_distance = float('inf')
    recognized_person = "Unknown"
    
    for face in faces:
        stored_embedding = np.array(face.to_dict()['embedding'])
        distance = np.linalg.norm(stored_embedding - embedding)
        if distance < 1.0 and distance < min_distance:
            min_distance = distance
            recognized_person = face.id
    
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    db.collection('logs').add({
        "name": recognized_person,
        "timestamp": timestamp
    })
    
    return jsonify({"name": recognized_person})

@app.route('/detect_objects', methods=['POST'])
def detect_objects():
    image = cv2.imdecode(np.frombuffer(request.files['image'].read(), np.uint8), cv2.IMREAD_COLOR)
    results = yolo_model(image)
    detected_objects = set()
    
    for result in results:
        for box in result.boxes:
            cls = int(box.cls[0])
            detected_objects.add(yolo_model.names[cls])

    return jsonify({"objects": list(detected_objects)})

@app.route('/fall_detect', methods=['POST'])
def fall_detect():
    data = request.get_json()
    
    latitude = data.get("latitude")
    longitude = data.get("longitude")
    location_link = f"https://www.google.com/maps?q={latitude},{longitude}"

    # latitude = data.get("latitude")
    # longitude = data.get("longitude")

    # if latitude is None or longitude is None:
    #   return jsonify({"error": "Missing location data"}), 400

    # location_link = f"https://www.google.com/maps?q={latitude},{longitude}" 

    emails_ref = db.collection("emails").stream()
    email_list = [doc.to_dict().get("email") for doc in emails_ref if "email" in doc.to_dict()]

    if not email_list:
        return jsonify({"message": "No emails found"}), 400

    message = f"Fall detected! Location: {location_link}"
    email_sent = send_email_alert(email_list, message)
    
    if email_sent:
        return jsonify({"message": "Fall alert sent successfully."}), 200
    else:
        return jsonify({"message": "Failed to send fall alert."}), 500


# def send_email_alert(recipient_emails, message):
#     subject = "🚨 Fall Alert!"
    
#     msg = MIMEMultipart()
#     msg["From"] = SMTP_EMAIL
#     msg["To"] = ", ".join(recipient_emails)
#     msg["Subject"] = subject
#     msg.attach(MIMEText(message, "plain"))
    
#     try:
#         with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
#             server.starttls()
#             server.login(SMTP_EMAIL, SMTP_PASSWORD)
#             server.sendmail(SMTP_EMAIL, recipient_emails, msg.as_string())
#         return True
#     except Exception as e:
#         print(f"Error sending email: {e}")
#         return False

def send_email_alert(recipient_emails, message):
    subject = "🚨 Fall Alert!"
    
    msg = MIMEMultipart()
    msg["From"] = SMTP_EMAIL
    msg["To"] = ", ".join(recipient_emails)
    msg["Subject"] = subject
    msg.attach(MIMEText(message, "plain"))
    
    try:
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(SMTP_EMAIL, SMTP_PASSWORD)
            server.sendmail(SMTP_EMAIL, recipient_emails, msg.as_string())
        print("✅ Email sent successfully!")
        return True
    except smtplib.SMTPAuthenticationError:
        print("❌ Authentication failed! Check your email/password.")
    except smtplib.SMTPException as e:
        print(f"❌ SMTP error: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
    
    return False  # Return False if email sending fails




if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)
