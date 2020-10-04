# Name: Daniel Ko
# Project 2, CS 540
# Email: ko28@wisc.edu
# Some comments were taken from the homework directly
import os 
import math 

def create_bow(vocab, filepath):
    """ Create a single dictionary for the data
        Note: label may be None
    """
    bow = {}
    textfile = open(filepath, "r").read().split('\n')
    for word in textfile:
        if word in vocab:
            if word not in bow:
                bow[word] = 1
            else:
                bow[word] += 1
        else:
            if None not in bow:
                bow[None] = 1
            else:
                bow[None] += 1
     

    return bow

def load_training_data(vocab, directory):
    """ Create the list of dictionaries """
    dataset = []
    for dir in os.listdir(directory):
        for file in os.listdir(os.path.join(directory,dir)):
            vocab = {}
            textfile = open(os.path.join(directory, dir, file), "r").read().split('\n')
            for text in textfile:
                if text not in vocab:
                    vocab[text] = 1
                else:
                    vocab[text] = vocab[text] + 1
            dataset.append({"label": dir, "bow": vocab})


    return dataset

def create_vocabulary(directory, cutoff):
    """ Create a vocabulary from the training directory
        return a sorted vocabulary list
    """
    vocab = {}
    for root, dirs, files in os.walk(directory):
        for f in files:
            textfile = open(os.path.join(root, f), "r").read().split('\n')
            for text in textfile:
                if text not in vocab:
                    vocab[text] = 1
                else:
                    vocab[text] = vocab[text] + 1
    
    list_vocab = []
    for key in vocab.keys():
        if vocab[key] >= cutoff:
            list_vocab.append(key)
    
    return sorted(list_vocab)

def prior(training_data, label_list):
    """ return the prior probability of the label in the training set
        => frequency of DOCUMENTS
    """

    smooth = 1 # smoothing factor
    logprob = {}
    # TODO: add your code here
    count = {}
    for label in label_list:
        count[label] = 0
    for data in training_data:
        for label in label_list:
            if data["label"] == label:
                count[label] += 1

    for label in label_list:
        prob = (count[label] + smooth) / (len(training_data) + len(label_list))
        logprob[label] = math.log(prob)
                
    return logprob

def p_word_given_label(vocab, training_data, label):
    """ return the class conditional probability of label over all words, with smoothing """
    

    smooth = 1 # smoothing factor
    word_prob = {}
    # TODO: add your code here
    count = {}
    # number data["label"] == label in training data
    num_label = 0
    for word in vocab:
        count[word] = 0
        for data in training_data:
            if data["label"] == label and word in data["bow"]:
                    count[word] += data["bow"][word]
    print(len(vocab) )
    #print("len vocab ", len_vocab, "    len(vocab) ", len(vocab))
    for word in vocab:
        #prob = (count[word] + smooth) / (num_label)
        #word_prob[word] = math.log(prob)
        word_prob[word] = count[word]

    return word_prob

    
##################################################################################
def train(training_directory, cutoff):
    """ return a dictionary formatted as follows:
            {
             'vocabulary': <the training set vocabulary>,
             'log prior': <the output of prior()>,
             'log p(w|y=2016)': <the output of p_word_given_label() for 2016>,
             'log p(w|y=2020)': <the output of p_word_given_label() for 2020>
            }
    """
    retval = {}
    # TODO: add your code here


    return retval


def classify(model, filepath):
    """ return a dictionary formatted as follows:
            {
             'predicted y': <'2016' or '2020'>, 
             'log p(y=2016|x)': <log probability of 2016 label for the document>, 
             'log p(y=2020|x)': <log probability of 2020 label for the document>
            }
    """
    retval = {}
    # TODO: add your code here


    return retval


if __name__ == "__main__":
    #vocab = create_vocabulary('./corpus/training/', 2)
    #training_data = load_training_data(vocab,'./corpus/training/')
    #vocab = create_vocabulary('./EasyFiles/', 2)
    #training_data = load_training_data(vocab,'./EasyFiles/')
    #print("training data", training_data)
    #g = prior(training_data, ['2020', '2016'])
    #print(g)

    vocab = create_vocabulary('./EasyFiles/', 1)
    training_data = load_training_data(vocab, './EasyFiles/')
    print(training_data)
    #print(p_word_given_label(vocab, training_data, '2020'))
    print("len vocab ", len(vocab))
    print(p_word_given_label(vocab, training_data, '2016'))