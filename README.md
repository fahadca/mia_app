# Multifunctional Intelligent Assistant for Visually Impaired People

This project is a **Flutter-based mobile application** designed to assist visually impaired individuals by integrating multiple AI-powered features such as:

✅ **Face Recognition** (via Flask + FaceNet)
✅ **Real-Time Object Detection** (via YOLOv8)
✅ **Voice Feedback** (Text-to-Speech for accessibility)
✅ **Shortcut Navigation** (Triple-tap for object detection, long-press for face recognition)

---

## 📌 **Installation & Setup**

### **1️⃣ Install Required Dependencies**
Before running the app, install the necessary Python packages:
```bash
pip install flask tensorflow numpy opencv-python firebase-admin facenet-pytorch torch ultralytics
```

### **2️⃣ Setting Up Firebase**
This project uses **Firebase** for cloud storage and Firestore database. If you are using your own Firebase project, follow these steps:

#### **🔹 Setup Firebase for Flutter**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one.
3. In **Project Settings**, go to the **General** tab and download the `google-services.json` file.
4. Place `google-services.json` inside your **Flutter project's `android/app/` directory**.
5. Add Firebase SDK dependencies in `pubspec.yaml` if not already included:
   ```yaml
   dependencies:
     firebase_core: latest_version
     cloud_firestore: latest_version
   ```
6. Run:
   ```bash
   flutter pub get
   ```

#### **🔹 Setup Firebase for Flask (`app.py`)**
1. In the Firebase Console, go to **Project Settings > Service Accounts**.
2. Click **Generate New Private Key** and download the `serviceAccountKey.json` file.
3. Place `serviceAccountKey.json` in the same directory as `app.py`.
4. Ensure that `app.py` initializes Firebase using this credential:
   ```python
   import firebase_admin
   from firebase_admin import credentials, firestore

   cred = credentials.Certificate("serviceAccountKey.json")
   firebase_admin.initialize_app(cred)
   db = firestore.client()
   ```

---

## 📲 **Running the Application**

### **1️⃣ Start the Flask Server**
Run the backend:
```bash
python app.py
```

📌 **Make sure your phone and laptop are connected to the same Wi-Fi network**.

### **2️⃣ Connect Your Phone to the Laptop**
Find your laptop's **local IP address**:
```bash
ipconfig  # (Windows)
ifconfig  # (Mac/Linux)
```
Update the `baseUrl` in `api_service.dart` with your laptop's IP.

### **3️⃣ Run the Flutter App**
```bash
flutter run
```

### **4️⃣ Navigate Through the App**
✅ **Long-press on the home screen** → Opens **Face Recognition**
✅ **Triple-tap anywhere** → Opens **Object Detection**
✅ **Triple-tap in Object Detection screen** → Returns to **Home**
✅ **Long-press in Face Recognition screen** → Returns to **Home**

---

## ⚡ **Switching Between YOLOv5 and YOLOv8**

This project now uses **YOLOv8 for improved accuracy**.
If you want to **ensure YOLOv8 is correctly set up**, run:
```bash
pip install ultralytics
```
Then download the YOLOv8 model:
```bash
yolo task=detect mode=predict model=yolov8s.pt source='test.jpg'
```

---

### **✅ Everything is Now Set Up!** 🎯
You can now run the application and test its functionalities. 
