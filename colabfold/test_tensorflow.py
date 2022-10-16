# Script to benchmark/test TF installation
# Based on blog post by Purnendu Shukla, 2021
# https://www.analyticsvidhya.com/blog/2021/11/benchmarking-cpu-and-gpu-performance-with-tensorflow/
# Including test data during fit process suggested
# by blog post by Jason Brownlee, 2022:
# https://machinelearningmastery.com/evaluate-performance-deep-learning-models-keras/
import tensorflow as tf
from tensorflow import keras
import numpy as np

# Initial tests
tf.config.experimental.list_physical_devices()
tf.test.is_built_with_cuda()

# Download/preprocess data
(X_train, y_train), (X_test, y_test) = keras.datasets.cifar10.load_data()
X_train_scaled = X_train/255
X_test_scaled = X_test/255
y_train_encoded = keras.utils.to_categorical(y_train, num_classes = 10, dtype = 'float32')
y_test_encoded = keras.utils.to_categorical(y_test, num_classes = 10, dtype = 'float32')

# Define the model
def get_model():
    model = keras.Sequential([
        keras.layers.Flatten(input_shape=(32,32,3)),
        keras.layers.Dense(3000, activation='relu'),
        keras.layers.Dense(1000, activation='relu'),
        keras.layers.Dense(10, activation='sigmoid')
    ])
    model.compile(optimizer='SGD',
                  loss='categorical_crossentropy',
                  metrics=['accuracy'])
    return model

# Train model on CPU - slow ~ 10 mins
#with tf.device('/CPU:0'):
#    model_cpu = get_model()
#    model_cpu.fit(X_train_scaled, y_train_encoded, epochs = 10)
    #validation_data=(X_test_scaled, y_train_encoded), epochs = 10)

# Train model on GPU - fast ~ 1 min
with tf.device('/GPU:0'):
    model_gpu = get_model()
    model_gpu.fit(X_train_scaled, y_train_encoded, epochs = 10)
    #validation_data=(X_test_scaled, y_train_encoded), epochs = 10)