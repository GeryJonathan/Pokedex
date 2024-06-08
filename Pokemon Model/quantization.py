import tensorflow as tf

# Load the SavedModel
converter = tf.lite.TFLiteConverter.from_saved_model('model_pokemon')

# Enable dynamic range quantization
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# Convert the model
tflite_quant_model = converter.convert()

# Save the quantized model to a file
with open('model_quant.tflite', 'wb') as f:
    f.write(tflite_quant_model)
