import os
import librosa
import numpy as np
import tensorflow as tf
import cv2 # You might need: pip install opencv-python

# 1. Configuration
DATA_PATH = "data"
CATEGORIES = ["casual", "distress", "hungry"]
IMG_SIZE = (128, 128) 

def extract_features(folder_path):
    features = []
    labels = []
    
    for category in CATEGORIES:
        path = os.path.join(folder_path, category)
        label = CATEGORIES.index(category)
        
        for audio_file in os.listdir(path):
            if not audio_file.endswith('.wav'): continue # Skip hidden files
            try:
                # Load audio
                y, sr = librosa.load(os.path.join(path, audio_file), duration=3)
                
                # Create Mel-Spectrogram
                ps = librosa.feature.melspectrogram(y=y, sr=sr)
                ps_db = librosa.power_to_db(ps, ref=np.max)
                
                # FIX 1: Resize to exactly 128x128
                fixed_size = cv2.resize(ps_db, dsize=IMG_SIZE, interpolation=cv2.INTER_CUBIC)
                
                features.append(fixed_size)
                labels.append(label)
                
            except Exception as e:
                print(f"Error skipping file {audio_file}: {e}")
                
    # FIX 2: Reshape for CNN (Samples, Width, Height, Channels)
    X = np.array(features)
    X = X.reshape(X.shape[0], IMG_SIZE[0], IMG_SIZE[1], 1)
    return X, np.array(labels)

def build_model(input_shape):
    model = tf.keras.Sequential([
        tf.keras.layers.Conv2D(32, (3, 3), activation='relu', input_shape=input_shape),
        tf.keras.layers.MaxPooling2D((2, 2)),
        tf.keras.layers.Conv2D(64, (3, 3), activation='relu'),
        tf.keras.layers.MaxPooling2D((2, 2)),
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.Dense(3, activation='softmax')
    ])
    model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
    return model

# --- EXECUTION BLOCK ---
print("Extracting features...")
X, y = extract_features(DATA_PATH)

if len(X) > 0:
    print(f"Data Loaded! Found {len(X)} clips.")
    my_model = build_model((128, 128, 1))
    
    # FIX 3: Actually train the model
    print("Starting training...")
    my_model.fit(X, y, epochs=10, batch_size=4)
    
    # Save your hard work!
    my_model.save("bark_model.h5")
    print("Model saved as bark_model.h5")
else:
    print("No data found. Check your 'data' folders!")