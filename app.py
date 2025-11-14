from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
from PIL import Image
import io
import os

app = Flask(__name__)

# ---------------------------
# 🔹 Model & Label Loading
# ---------------------------
MODEL_PATH = "model.tflite"
LABELS_PATH = "labels.txt"

try:
    interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    print("✅ Model loaded successfully.")
except Exception as e:
    print(f"⚠ Error loading model: {e}")
    interpreter = None
    input_details, output_details = None, None

try:
    with open(LABELS_PATH, "r") as f:
        labels = [line.strip() for line in f.readlines()]
    print(f"✅ Labels loaded successfully: {len(labels)} classes")
except Exception as e:
    print(f"⚠ Error loading labels: {e}")
    labels = []

# ---------------------------
# 🔹 Helper Function
# ---------------------------
def preprocess_image(image_file):
    """Convert image to model input tensor."""
    image = Image.open(image_file.stream).convert("RGB").resize((224, 224))
    img_array = np.array(image, dtype=np.float32) / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    return img_array


# ---------------------------
# 🔹 Routes
# ---------------------------
@app.route("/")
def home():
    """Simple route to test backend status."""
    return jsonify({"message": "✅ Sign Language Detection Backend is running!"})


@app.route("/predict", methods=["POST"])
def predict():
    """Handle image upload and prediction."""
    if interpreter is None:
        return jsonify({"error": "Model not loaded"}), 500

    if "file" not in request.files:
        return jsonify({"error": "No file part in request"}), 400

    file = request.files["file"]
    if file.filename == "":
        return jsonify({"error": "No file selected"}), 400

    try:
        # Preprocess and predict
        input_data = preprocess_image(file)
        interpreter.set_tensor(input_details[0]["index"], input_data)
        interpreter.invoke()

        output_data = interpreter.get_tensor(output_details[0]["index"])
        predicted_index = int(np.argmax(output_data))
        confidence = float(np.max(output_data))
        predicted_label = labels[predicted_index] if labels else str(predicted_index)

        # Log prediction
        print(f"🖼 File: {file.filename} | 🔤 Predicted: {predicted_label} ({confidence:.2f})")

        # Return JSON
        return jsonify({
            "predicted_label": predicted_label,
            "confidence": confidence
        })

    except Exception as e:
        print(f"⚠ Prediction error: {e}")
        return jsonify({"error": str(e)}), 500


# ---------------------------
# 🔹 Main Entry
# ---------------------------
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    print(f"🚀 Server running on http://0.0.0.0:{port}")
    app.run(host="0.0.0.0", port=port)