import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras import layers, models
import os

# === PATHS ===
base_dir = "SIBI_datasets_LEMLITBANG_SIBI_R_90.10_RAW"
train_dir = os.path.join(base_dir, "training")
val_dir = os.path.join(base_dir, "validation")

# === SETTINGS ===
img_size = (224, 224)
batch_size = 32
epochs = 100  # can increase later for better accuracy

# === DATA AUGMENTATION ===
train_datagen = ImageDataGenerator(
    rescale=1./255,
    rotation_range=15,
    width_shift_range=0.1,
    height_shift_range=0.1,
    shear_range=0.1,
    zoom_range=0.1,
    horizontal_flip=True
)
val_datagen = ImageDataGenerator(rescale=1./255)

train_gen = train_datagen.flow_from_directory(
    train_dir,
    target_size=img_size,
    batch_size=batch_size,
    class_mode='categorical'
)
val_gen = val_datagen.flow_from_directory(
    val_dir,
    target_size=img_size,
    batch_size=batch_size,
    class_mode='categorical'
)

# === CNN MODEL ===
model = models.Sequential([
    layers.Conv2D(32, (3,3), activation='relu', input_shape=(224,224,3)),
    layers.MaxPooling2D(2,2),
    layers.Conv2D(64, (3,3), activation='relu'),
    layers.MaxPooling2D(2,2),
    layers.Conv2D(128, (3,3), activation='relu'),
    layers.MaxPooling2D(2,2),
    layers.Flatten(),
    layers.Dense(128, activation='relu'),
    layers.Dropout(0.5),
    layers.Dense(train_gen.num_classes, activation='softmax')
])

model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
model.summary()

# === TRAIN ===
history = model.fit(
    train_gen,
    validation_data=val_gen,
    epochs=epochs
)

# === SAVE MODEL ===
model.save("sign_model.h5")

# === CONVERT TO TFLITE ===
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()
with open("model.tflite", "wb") as f:
    f.write(tflite_model)

# === SAVE LABELS ===
labels = list(train_gen.class_indices.keys())
with open("labels.txt", "w") as f:
    f.write("\n".join(labels))

print("\n✅ Training complete!")
print("Model saved as model.tflite and labels.txt")
