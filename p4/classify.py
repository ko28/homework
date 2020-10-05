# Name: Daniel Ko
# Project 2, CS 540
# Email: ko28@wisc.edu
# Some comments were taken from the homework directly
import os 
import math 
import pickle 

def create_bow(vocab, filepath):
    """ Create a single dictionary for the data
        Note: label may be None
    """
    bow = {}
    with open(filepath, "r") as f:
        textfile = f.read().split('\n')
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
                textfile = f.read().split('\n')
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
    vocab.append(None)
    for word in vocab:
        count[word] = 0
    for data in training_data:
        if data["label"] == label:
            #print(data["bow"])
            num_label += sum(data["bow"].values())
            for word in vocab:     
                if word in data["bow"]:
                    count[word] += data["bow"][word]
    # |v|
    v = len(vocab)

    #print("num lab:", num_label, "   v:", v, "   demon:", num_label + v)
    for word in vocab:
        #prob = (count[word] + smooth) / (num_label + len(training_data))
        #word_prob[word] = math.log(prob)
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
    # TODO: add your code here

    #retval["log p(w|y=2016)"] = p_word_given_label(model["vocab"], training_data, "2016")

    #retval["log p(w|y=2020)"] = p_word_given_label(model["vocab"], training_data, "2020")
    #vocab = model["vocab"]
    #training_data = load_training_data(vocab, filepath)
    #p = prior(training_data, ['2020', '2016'])

    pi_2016 = 0 
    pi_2020 = 0 
    #print(model["log p(w|y=2016)"])
    #exit()
    with open(filepath, "r") as f:
        textfile = f.read().split('\n')
        for word in textfile:
            if word in model["log p(w|y=2016)"]:
                pi_2016 += model["log p(w|y=2016)"][word]
            if word in model["log p(w|y=2020)"]:
                pi_2020 += model["log p(w|y=2020)"][word]

    print("pi2016:", pi_2016, "  model 2016:s", model["log prior"]["2016"])
    retval["log p(w|y=2016)"] = model["log prior"]["2016"] + pi_2016
    retval["log p(w|y=2020)"] = model["log prior"]["2020"] + pi_2020
    #print(retval["log p(w|y=2016)"])
    retval["predicted y"] = "2016" if retval["log p(w|y=2016)"] > retval["log p(w|y=2020)"] else "2020"
    print(retval["predicted y"])
    return retval


if __name__ == "__main__":
    
    with open(r"someobject.pickle", "rb") as input_file:
        e = pickle.load(input_file)
        print(classify(e, './corpus/test/2016/0.txt') )
    
    """
    model = train('./corpus/training/', 2)
    #print(model)
    print(classify(model, './corpus/test/2016/0.txt') )
    """


