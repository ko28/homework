import tensorflow as tf
from tensorflow import keras


def get_dataset(training=True):
    mnist = keras.datasets.mnist
    (train_images, train_labels), (test_images, test_labels) = mnist.load_data()
    if training:
        return train_images, train_labels
    return test_images, test_labels


def print_stats(train_images, train_labels):
    class_names = ['Zero', 'One', 'Two', 'Three',
                   'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine']
    print(len(train_images))
    shape = train_images[0].shape
    print('%dx%d' % (shape[0], shape[1]))
    d = dict.fromkeys(class_names, 0)
    for num in train_labels:
        d[class_names[num]] += 1
    for i, name in enumerate(class_names):
        print('%d. %s - %d' % (i, name, d[name]))


def build_model():
    model = keras.models.Sequential([
        keras.layers.Flatten(input_shape=(28, 28)),
        keras.layers.Dense(128, activation='relu'),
        keras.layers.Dense(64, activation='relu'),
        keras.layers.Dense(10)
    ])
    model.compile(
        loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        optimizer=keras.optimizers.SGD(learning_rate=0.001),
        metrics=['accuracy'],
    )
    return model


def train_model(model, train_images, train_labels, T):
    model.fit(
        x=train_images,
        y=train_labels,
        epochs=T,
    )


def evaluate_model(model, test_images, test_labels, show_loss=True):
    test_loss, test_accuracy = model.evaluate(
        test_images, test_labels, verbose=0)
    if show_loss:
        print("Loss:", "%.4f" % round(test_loss, 4))
    print("Accuracy:", '{:.2%}'.format(test_accuracy))


def predict_label(model, test_images, index):
    class_names = ['Zero', 'One', 'Two', 'Three',
                   'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine']
    prob = model.predict(test_images[index].reshape(1, 28, 28))[0]
    largest_idxs = prob.argsort()[-3:][::-1]
    for i in largest_idxs:
        print("%s:" % class_names[i], '{:.2%}'.format(prob[i]))
