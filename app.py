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

app = Flask(__name__)
cred = credentials.Certificate("miaapp-d291d-firebase-adminsdk-fbsvc-e0b6a0c874.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

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


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)
