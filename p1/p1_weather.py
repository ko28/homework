def manhattan_distance(data_point1, data_point2):
    return abs(data_point1['TMAX'] - data_point2['TMAX']) + abs(data_point1['PRCP'] - data_point2['PRCP']) + abs(data_point1['TMIN'] - data_point2['TMIN']) 

def read_dataset(filename):
    d = {}
    with open(filename) as f:
        for index, line in enumerate(f):
            words = line.split()
            d[index] = {'DATE' : words[0], 'TMAX' : float(words[1]), 'PRCP': float(words[2]), 'TMIN': float(words[3]), 'RAIN': words[4]}
    return d

#dataset = read_dataset("rain.txt")
#print(dataset[0])
#print(len(dataset))
print(manhattan_distance({'DATE': '1951-05-19', 'TMAX': 66.0, 'PRCP': 0.0, 'TMIN': 43.0, 'RAIN': 'FALSE'},{'DATE': '1951-01-27', 'TMAX': 33.0, 'PRCP': 0.0, 'TMIN': 19.0, 'RAIN': 'FALSE'})) 

print(manhattan_distance({'DATE': '2015-08-12', 'TMAX': 83.0, 'PRCP': 0.3, 'TMIN': 62.0, 'RAIN': 'TRUE'}, {'DATE': '2014-05-19', 'TMAX': 70.0, 'PRCP': 0.0, 'TMIN': 50.0, 'RAIN': 'FALSE'}))
