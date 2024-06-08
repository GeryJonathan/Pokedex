import cv2
import numpy as np
import tensorflow as tf

# Load the TFLite model
interpreter = tf.lite.Interpreter(model_path='pokemon-classifier.tflite')
interpreter.allocate_tensors()

# Get input and output details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Load the input image and preprocess
image = cv2.imread('eevee.png')
img = cv2.resize(image, (150, 150))
img = img.astype(np.float32)
img = img / 255.0
img = np.expand_dims(img, axis=0)

# Set the input tensor and invoke the interpreter
interpreter.set_tensor(input_details[0]['index'], img)
interpreter.invoke()

# Get the output tensor and process the result
output_data = interpreter.get_tensor(output_details[0]['index'])
label_index = np.argmax(output_data, axis=1)[0]

# Print the predicted label
with open('labels.txt', 'r') as f:
    labels = f.read().splitlines()
    print('Predicted label index:', label_index)
    print('Predicted label:', labels[label_index])
    print('Input tensor:', interpreter.get_tensor(input_details[0]['index']))