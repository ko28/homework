'''
HW4 is to be written in a file called classify.py with the following interface:
create_vocabulary(training_directory: str, cutoff: int)
create_bow(vocab: dict, filepath: str)
load_training_data(vocab: list, directory: str)
prior(training_data: list, label_list: list)
p_word_given_label(vocab: list, training_data: list, label: str)
train(training_directory: str, cutoff: int)
classify(model: dict, filepath: str)
'''
__author__ = 'cs540-testers'
__credits__ = ['Saurabh Kulkarni', 'Alex Moon', 'Stephen Jasina',
               'Harrison Clark']
version = 'V1.1.1'

from classify import train, create_bow, load_training_data, prior, \
    p_word_given_label, classify, create_vocabulary
import unittest

class TestClassify(unittest.TestCase):
    def compare_dicts(self, a, b):
        '''Compares two dicts that map strings to other (non-container) data'''

        # Check that all elements of a are in b
        for k in a:
            self.assertIn(k, b)
            if type(a[k]) is float:
                self.assertAlmostEqual(a[k], b[k])
            elif type(a[k]) is dict:
                self.compare_dicts(a[k], b[k])
            else:
                self.assertEqual(a[k], b[k])

        # Check if b has unexpected extra entries
        for k in b:
            self.assertIn(k, a)

    # create_vocabulary(training_directory: str, cutoff: int)
    # returns a list
    def test_create_vocabulary(self):
        vocab = create_vocabulary('./EasyFiles/', 1)
        expected_vocab = [',', '.', '19', '2020', 'a', 'cat', 'chases', 'dog',
                'february', 'hello', 'is', 'it', 'world']
        self.assertEqual(vocab, expected_vocab)

        vocab = create_vocabulary('./EasyFiles/', 2)
        expected_vocab = ['.', 'a']
        self.assertEqual(vocab, expected_vocab)

    # create_bow(vocab: dict, filepath: str)
    # returns a dict
    def test_create_bow(self):
        vocab = create_vocabulary('./EasyFiles/', 1)

        bow = create_bow(vocab, './EasyFiles/2016/1.txt')
        expected_bow = {'a': 2, 'dog': 1, 'chases': 1, 'cat': 1, '.': 1}
        self.assertEqual(bow, expected_bow)

        bow = create_bow(vocab, './EasyFiles/2020/2.txt')
        expected_bow = {'it': 1, 'is': 1, 'february': 1, '19': 1, ',': 1,
                '2020': 1, '.': 1}
        self.assertEqual(bow, expected_bow)

        vocab = create_vocabulary('./EasyFiles/', 2)

        bow = create_bow(vocab, './EasyFiles/2016/1.txt')
        expected_bow = {'a': 2, None: 3, '.': 1}
        self.assertEqual(bow, expected_bow)

    # load_training_data(vocab: list, directory: str)
    # returns a list of dicts
    def test_load_training_data(self):
        vocab = create_vocabulary('./EasyFiles/', 1)
        training_data = load_training_data(vocab, './EasyFiles/')
        expected_training_data = [
            {
                'label': '2020',
                'bow': {'it': 1, 'is': 1, 'february': 1, '19': 1, ',': 1,
                        '2020': 1, '.': 1}
            },
            {
                'label': '2016',
                'bow': {'hello': 1, 'world': 1}
            },
            {
                'label': '2016',
                'bow': {'a': 2, 'dog': 1, 'chases': 1, 'cat': 1, '.': 1}
            }
        ]
        self.assertCountEqual(training_data, expected_training_data)

    # prior(training_data: list, label_list: list)
    # returns a dict mapping labels to floats
    # assertAlmostEqual(a, b) can be handy here
    def test_prior(self):
        vocab = create_vocabulary('./corpus/training/', 2)
        training_data = load_training_data(vocab, './corpus/training/')
        log_probabilities = prior(training_data, ['2020', '2016'])
        expected_log_probabilities = {'2020': -0.32171182103809226,
                '2016': -1.2906462863976689}
        self.compare_dicts(log_probabilities, expected_log_probabilities)


    # p_word_given_label(vocab: list, training_data: list, label: str)
    # returns a dict mapping words to floats
    # assertAlmostEqual(a, b) can be handy here
    def test_p_word_given_label_2020(self):
        vocab = create_vocabulary('./EasyFiles/', 1)
        training_data = load_training_data(vocab, './EasyFiles/')

        log_probabilities = p_word_given_label(vocab, training_data, '2020')
        expected_log_probabilities = {',': -2.3513752571634776,
                '.': -2.3513752571634776, '19': -2.3513752571634776,
                '2020': -2.3513752571634776, 'a': -3.044522437723423,
                'cat': -3.044522437723423, 'chases': -3.044522437723423,
                'dog': -3.044522437723423, 'february': -2.3513752571634776,
                'hello': -3.044522437723423, 'is': -2.3513752571634776,
                'it': -2.3513752571634776, 'world': -3.044522437723423,
                None: -3.044522437723423}
        self.compare_dicts(log_probabilities, expected_log_probabilities)

        vocab = create_vocabulary('./EasyFiles/', 2)
        training_data = load_training_data(vocab, './EasyFiles/')

        log_probabilities = p_word_given_label(vocab, training_data, '2020')
        expected_log_probabilities = {'.': -1.6094379124341005,
                'a': -2.302585092994046, None: -0.35667494393873267}
        self.compare_dicts(log_probabilities, expected_log_probabilities)

    def test_p_word_given_label_2016(self):
        vocab = create_vocabulary('./EasyFiles/', 1)
        training_data = load_training_data(vocab, './EasyFiles/')

        log_probabilities = p_word_given_label(vocab, training_data, '2016')
        expected_log_probabilities = {',': -3.091042453358316,
                '.': -2.3978952727983707, '19': -3.091042453358316,
                '2020': -3.091042453358316, 'a': -1.9924301646902063,
                'cat': -2.3978952727983707, 'chases': -2.3978952727983707,
                'dog': -2.3978952727983707, 'february': -3.091042453358316,
                'hello': -2.3978952727983707, 'is': -3.091042453358316,
                'it': -3.091042453358316, 'world': -2.3978952727983707,
                None: -3.091042453358316}
        self.compare_dicts(log_probabilities, expected_log_probabilities)

        vocab = create_vocabulary('./EasyFiles/', 2)
        training_data = load_training_data(vocab, './EasyFiles/')

        log_probabilities = p_word_given_label(vocab, training_data, '2016')
        expected_log_probabilities = {'.': -1.7047480922384253,
                'a': -1.2992829841302609, None: -0.6061358035703157}
        self.compare_dicts(log_probabilities, expected_log_probabilities)

    # train(training_directory: str, cutoff: int)
    # returns a dict
    def test_train(self):
        model = train('./EasyFiles/', 2)
        expected_model = {
            'vocabulary': ['.', 'a'],
            'log prior': {
                '2020': -0.916290731874155,
                '2016': -0.5108256237659905
            },
            'log p(w|y=2020)': {
                '.': -1.6094379124341005,
                'a': -2.302585092994046,
                None: -0.35667494393873267
            },
            'log p(w|y=2016)': {
                '.': -1.7047480922384253,
                'a': -1.2992829841302609,
                None: -0.6061358035703157
            }
        }
        self.compare_dicts(model, expected_model)

    # classify(model: dict, filepath: str)
    # returns a dict
    def test_classify_2020(self):
        model = train('./corpus/training/', 2)
        classification = classify(model, './corpus/test/2016/0.txt')
        expected_classification = {
            'log p(y=2020|x)': -3906.351945884105,
            'log p(y=2016|x)': -3916.458747858926,
            'predicted y': '2020'
        }
        self.compare_dicts(classification, expected_classification)

    def test_classify_2016(self):
        model = train('./corpus/training/', 2)
        classification = classify(model, './corpus/test/2016/19.txt')
        expected_classification = {
            'log p(y=2016|x)': -3800.4027665365134,
            'log p(y=2020|x)': -3805.776535552692,
            'predicted y': '2016'
        }
        self.compare_dicts(classification, expected_classification)



if __name__ == '__main__':
    print('Tester %s' % version)
    unittest.main()