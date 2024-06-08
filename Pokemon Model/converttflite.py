import tensorflow as tf

# Convert the model with SignatureDef
converter = tf.lite.TFLiteConverter.from_saved_model('model_pokemon', signature_keys=['serving_default'])
tflite_model = converter.convert()

# Save the model
with open('pokemonClasify.tflite', 'wb') as f:
    f.write(tflite_model)
