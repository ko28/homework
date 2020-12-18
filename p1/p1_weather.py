# Name: Daniel Ko
# Project 1, CS 540
# Email: ko28@wisc.edu
# Some comments were taken from the homework directly

import datetime 

# Distance between points in three-dimensional space, 
# where those dimensions are the precipitation amount (PRCP), 
# maximum temperature (TMAX), and minimum temperature for the day (TMIN)
def manhattan_distance(data_point1, data_point2):
    return (abs(data_point1['TMAX'] - data_point2['TMAX']) + 
            abs(data_point1['PRCP'] - data_point2['PRCP']) +
            abs(data_point1['TMIN'] - data_point2['TMIN'])) 

# Return a list of data point dictionaries read from the specified file.
def read_dataset(filename):
    d = [] 
    with open(filename) as f:
        for line in f:
            words = line.split()
            # Generate dictionary from each line and add to list
            d.append({'DATE': words[0], 
                      'TMAX': float(words[1]), 
                      'PRCP': float(words[2]), 
                      'TMIN': float(words[3]), 
                      'RAIN': words[4]})
    return d

# Return a prediction of whether it is raining or not based on a majority vote of the list of neighbors.
def majority_vote(nearest_neighbors):
    numTrue = 0
    numFalse = 0
    for n in nearest_neighbors:
        if n['RAIN'] == 'TRUE':
            numTrue+=1
        elif n['RAIN'] == 'FALSE':
            numFalse +=1
    
    #If a tie occurs, default to 'TRUE' as your answer.  
    return "TRUE" if numTrue >= numFalse else "FALSE"


def k_nearest_neighbors(filename, test_point, k, year_interval):
    data = read_dataset(filename)
    # adding all values within year interval from data into this list
    within_year = []
    test_point_date = getdate(test_point)
    years = year_interval * datetime.timedelta(days = 365) 
    # use date time library to do some simple subtraction on dates to determine if data point
    # is in range
    for d in data:
        time_diff = test_point_date - getdate(d)
        if years >= abs(time_diff):
            within_year.append(d)   
   
    # list of tuples with manhattan_distance as first element, data point as second
    man_dis = []
    for d in within_year:
        man_dis.append((manhattan_distance(test_point,d), d))

    # sort this list by manhattan_distance, asending
    # source: https://www.geeksforgeeks.org/python-program-to-sort-a-list-of-tuples-alphabetically/
    man_dis = sorted(man_dis, key = lambda x : x[0])
    
    # majority_vote of closest k valid neighbors 
    return majority_vote([x[1] for x in man_dis[:k]])

# Returns datetime object given a dictionary entry of data point 
def getdate(point):
    datestr = point["DATE"]
    return datetime.datetime(year = int(datestr[:4]), 
        month = int(datestr[5:7]), day = int(datestr[8:10]))
 

