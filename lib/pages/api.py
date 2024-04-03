import os

import cv2
import numpy as np
from flask import Flask, jsonify, request
from keras import backend as K
from keras import models
from tensorflow import keras
from werkzeug.utils import secure_filename

app = Flask(__name__)

UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def coeff_determination(y_true, y_pred):
    SS_res = K.sum(K.square(y_true - y_pred))
    SS_tot = K.sum(K.square(y_true - K.mean(y_true)))
    return 1 - SS_res / (SS_tot + K.epsilon())

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def preprocess_image(image_path, input_shape=(224, 224, 3)):
    raw_input_image = cv2.imread(image_path)
    raw_input_image = cv2.cvtColor(raw_input_image, cv2.COLOR_BGR2RGB)
    raw_input_image = cv2.resize(raw_input_image, (input_shape[0], input_shape[1]))

    # Preprocessing steps
    preprocessed_input_image = cv2.resize(raw_input_image, (224, 224))
    preprocessed_input_image = preprocessed_input_image / 255.0

    return preprocessed_input_image

dependencies = {
    'coeff_determination': coeff_determination
}

def predict_bmi(image_path):
    model = models.load_model('lib/assets/3.935_model.h5', custom_objects=dependencies)

    preprocessed_input_image = preprocess_image(image_path)
    features_batch = model.predict(np.expand_dims(preprocessed_input_image, axis=0))
    bmi_pred = features_batch[0][0]
    return bmi_pred

@app.route('/predict_bmi', methods=['POST'])
def predict_bmi_route():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'})

    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': 'No selected file'})

    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        bmi_pred = predict_bmi(filepath)

        return jsonify({'bmi': bmi_pred})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
