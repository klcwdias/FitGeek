import os

import cv2
import numpy as np
from flask import Flask, jsonify, request
from keras import backend as K
from keras import models
from keras.backend import clear_session
from keras.losses import Huber
from keras.losses import Huber as KerasHuber
from keras.losses import Loss
from keras.optimizers import SGD
from tensorflow import keras
from werkzeug.utils import secure_filename

app = Flask(__name__)


def huber_loss(y_true, y_pred, delta=1.0):
    error = y_true - y_pred
    is_small_error = K.abs(error) < delta
    squared_loss = 0.5 * K.square(error)
    linear_loss = delta * (K.abs(error) - 0.5 * delta)
    loss = K.mean(K.switch(is_small_error, squared_loss, linear_loss))
    return loss


    
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

def preprocess_image(image_path, input_shape=(224, 224,3)):
    raw_input_image = cv2.imread(image_path)
    raw_input_image = cv2.cvtColor(raw_input_image, cv2.COLOR_BGR2RGB)
    raw_input_image = cv2.resize(raw_input_image, input_shape)

    # Preprocessing steps
    preprocessed_input_image = cv2.resize(raw_input_image, input_shape)
    preprocessed_input_image = preprocessed_input_image / 255.0 

    return preprocessed_input_image

dependencies = {
    'coeff_determination': coeff_determination,
  
}

def predict_bmi(image_path):
    clear_session() 
    model = models.load_model('lib/assets/last_model0.h5', custom_objects=None)

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
