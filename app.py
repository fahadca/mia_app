# from flask import Flask, request, jsonify
# import tensorflow as tf
# import numpy as np
# import cv2
# import firebase_admin
# from firebase_admin import credentials, firestore
# from facenet_pytorch import MTCNN, InceptionResnetV1
# import torch

# app = Flask(__name__)
# cred = credentials.Certificate("C:/FHD/miaapp/miaapp-d291d-firebase-adminsdk-fbsvc-4e36038e7e.json")  # Use actual path

# firebase_admin.initialize_app(cred)
# db = firestore.client()

# device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
# mtcnn = MTCNN(image_size=160, margin=0)
# facenet = InceptionResnetV1(pretrained='vggface2').eval()

# def get_embedding(image):
#     image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)  # Convert BGR to RGB
#     face = mtcnn(image)
#     if face is None:
#         return None
#     return facenet(face.unsqueeze(0)).detach().numpy()

# @app.route('/register_face', methods=['POST'])
# def register_face():
#     name = request.form['name']
#     image = cv2.imdecode(np.frombuffer(request.files['image'].read(), np.uint8), cv2.IMREAD_COLOR)
#     embedding = get_embedding(image)
#     if embedding is not None:
#         # db.collection('faces').document(name).set({'embedding': embedding.tolist()})
#         db.collection('faces').document(name).set({'embedding': embedding.flatten().tolist()})

#         return "Face registered", 200
#     return "No face detected", 400

# @app.route('/recognize_face', methods=['POST'])
# def recognize_face():
#     image = cv2.imdecode(np.frombuffer(request.files['image'].read(), np.uint8), cv2.IMREAD_COLOR)
#     embedding = get_embedding(image)
#     faces = db.collection('faces').stream()
#     for face in faces:
#         stored_embedding = np.array(face.to_dict()['embedding'])
#         if np.linalg.norm(stored_embedding - embedding) < 1.0:
#             return face.id, 200
#     return "Unknown", 200

# if __name__ == '__main__':
#     app.run(host="0.0.0.0", port=5000)



from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
import cv2
import firebase_admin
from firebase_admin import credentials, firestore
from facenet_pytorch import MTCNN, InceptionResnetV1
import torch
import multiprocessing  # ✅ For background processing

app = Flask(__name__)
cred = credentials.Certificate("C:/FHD/miaapp/miaapp-d291d-firebase-adminsdk-fbsvc-4e36038e7e.json")  
firebase_admin.initialize_app(cred)
db = firestore.client()

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
mtcnn = MTCNN(image_size=160, margin=0)
facenet = InceptionResnetV1(pretrained='vggface2').eval()

# ✅ Use multiprocessing to handle embedding extraction
def get_embedding(image):
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)  # Convert BGR to RGB
    face = mtcnn(image)
    if face is None:
        return None
    return facenet(face.unsqueeze(0)).detach().numpy()

# ✅ Runs embedding extraction in a separate process
def process_embedding(image_data):
    image = cv2.imdecode(np.frombuffer(image_data, np.uint8), cv2.IMREAD_COLOR)
    return get_embedding(image)

@app.route('/register_face', methods=['POST'])
def register_face():
    name = request.form['name']
    image_data = request.files['image'].read()

    with multiprocessing.Pool(1) as pool:  # ✅ Run in background
        embedding = pool.apply(process_embedding, (image_data,))

    if embedding is not None:
        db.collection('faces').document(name).set({'embedding': embedding.flatten().tolist()})
        return "Face registered", 200
    return "No face detected", 400

@app.route('/recognize_face', methods=['POST'])
def recognize_face():
    image_data = request.files['image'].read()

    with multiprocessing.Pool(1) as pool:  # ✅ Run in background
        embedding = pool.apply(process_embedding, (image_data,))

    if embedding is None:
        return "Unknown", 200

    faces = db.collection('faces').stream()
    for face in faces:
        stored_embedding = np.array(face.to_dict()['embedding'])
        if np.linalg.norm(stored_embedding - embedding) < 1.0:
            return face.id, 200
    return "Unknown", 200

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)
