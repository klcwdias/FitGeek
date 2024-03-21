import numpy as np
import tensorflow as tf
from flask import Flask, jsonify, request
from flask_cors import CORS
from PIL import Image

app = Flask(__name__)
CORS(app)

# Load the TFLite model
interpreter = tf.lite.Interpreter(model_path="lib/assets/converted_model.tflite")
interpreter.allocate_tensors()

# Define the input and output details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

@app.route('/process_image', methods=['POST'])
def process_image():
    try:
        # Get the uploaded image from the request
        image_file = request.files['image']
        image = Image.open(image_file).convert('RGB')

        # Preprocess the image for inference
        input_data = preprocess_image(image)

        # Set the input tensor
        interpreter.set_tensor(input_details[0]['index'], input_data)

        # Run inference
        interpreter.invoke()

        # Get the output tensor
        output_data = interpreter.get_tensor(output_details[0]['index'])

        # Post-process the output to get the BMI result
        bmi_result = postprocess_output(output_data)

        return jsonify({'bmi': bmi_result})

    except Exception as e:
        return jsonify({'error': str(e)})

def preprocess_image(image):
    # Resize and normalize the image for inference
    image = image.resize((224, 224))
    image = np.asarray(image) / 255.0
    image = (image - 0.5) / 0.5  # Normalize to the range [-1, 1]
    image = np.expand_dims(image, axis=0)  # Add batch dimension
    return image.astype(np.float32)

def postprocess_output(output_data):
    # Post-process the output to get the BMI result
    bmi_result = output_data[0][0]
    return bmi_result

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
