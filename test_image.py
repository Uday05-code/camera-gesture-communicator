import tensorflow as tf
import numpy as np
from PIL import Image

# Load TFLite model and allocate tensors
interpreter = tf.lite.Interpreter(model_path="model.tflite")
interpreter.allocate_tensors()

# Get input and output tensor details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Load labels
with open("labels.txt", "r") as f:
    labels = [line.strip() for line in f.readlines()]

# === CHANGE THIS TO YOUR TEST IMAGE PATH ===
test_image_path = "C:/Users/UDAY SHARMA/Desktop/SignModelTraining/SIBI_datasets_LEMLITBANG_SIBI_R_90.10_RAW/test/A_4.jpg"


# Load and preprocess image
img = Image.open(test_image_path).convert("RGB").resize((224, 224))
img_array = np.expand_dims(np.array(img, dtype=np.float32) / 255.0, axis=0)

# Set tensor and run inference
interpreter.set_tensor(input_details[0]['index'], img_array)
interpreter.invoke()

# Get output and prediction
output_data = interpreter.get_tensor(output_details[0]['index'])
pred_index = np.argmax(output_data)
confidence = np.max(output_data)

print("✅ Prediction:", labels[pred_index])
print("📊 Confidence:", round(float(confidence) * 100, 2), "%")