# Name: Daniel Ko
# Project 4, CS 540
# Email: ko28@wisc.edu
# Some comments were taken from the homework directly
import os 
import math 
import pickle 

def process_textfile(f):
    """
        Helper function to convert file into list of words/characters
    """
    textfile = f.read().split('\n')
    # empty lines are removed
    if "" in textfile:
            textfile.remove("") 
    return textfile

def create_bow(vocab, filepath):
    """ Create a single dictionary for the data
        Note: label may be None
    """
    bow = {}
    with open(filepath, "r") as f:
        textfile = process_textfile(f)
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
            dataset.append({"label": dir, "bow": create_bow(vocab, os.path.join(directory, dir, file))})

    return dataset

def create_vocabulary(directory, cutoff):
    """ Create a vocabulary from the training directory
        return a sorted vocabulary list
    """
    vocab = {}
    for root, dirs, files in os.walk(directory):
        for f in files:
            with open(os.path.join(root, f), "r") as f:
                textfile = process_textfile(f)
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
    count = {}

    for label in label_list:
        count[label] = 0
    for data in training_data:
        for label in label_list:
            if data["label"] == label:
                count[label] += 1

    for label in label_list:
        logprob[label] = math.log(count[label] + smooth) - math.log(len(training_data) + len(label_list))
                
    return logprob

def p_word_given_label(vocab, training_data, label):
    """ return the class conditional probability of label over all words, with smoothing """
    
    smooth = 1 # smoothing factor
    word_prob = {}
    count = {}
    num_label = 0
    vocab.append(None)

    for word in vocab:
        count[word] = 0
    for data in training_data:
        if data["label"] == label:
            num_label += sum(data["bow"].values())
            for word in vocab:     
                if word in data["bow"]:
                    count[word] += data["bow"][word]
    # |v|
    v = len(vocab)
    for word in vocab:
        word_prob[word] = math.log(count[word] + smooth) - math.log(num_label + v)
    
    vocab.remove(None)
    
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
    
    vocab = create_vocabulary(training_directory, cutoff)
    training_data = load_training_data(vocab, training_directory)

    retval = {}
    retval["vocabulary"] = vocab
    retval["log prior"] = prior(training_data, ['2020', '2016'])
    retval["log p(w|y=2016)"] = p_word_given_label(vocab, training_data, "2016")
    retval["log p(w|y=2020)"] = p_word_given_label(vocab, training_data, "2020")

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

    pi_2016 = 0 
    pi_2020 = 0 

    with open(filepath, "r") as f:
        textfile = process_textfile(f)
       
        for word in textfile:

            if word in model["log p(w|y=2016)"]:
                pi_2016 += model["log p(w|y=2016)"][word]
            else:
                pi_2016 += model["log p(w|y=2016)"][None]

            if word in model["log p(w|y=2020)"]:
                pi_2020 += model["log p(w|y=2020)"][word]
            else:
                pi_2020 += model["log p(w|y=2020)"][None]


    retval["log p(y=2016|x)"] = model["log prior"]["2016"] + pi_2016
    retval["log p(y=2020|x)"] = model["log prior"]["2020"] + pi_2020
    retval["predicted y"] = "2016" if retval["log p(y=2016|x)"] > retval["log p(y=2020|x)"] else "2020"
    return retval