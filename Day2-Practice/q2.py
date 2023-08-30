# ## ************************Question #2************************

# Write a script that prompts the user to enter the coordinates of point (x, y). Find the slope and Euclidean distance between point (x1, y1) and point (x2, y2).

# # Input
# Enter the coordinate of point A: 2, 5
# Enter the coordinate of point B: 3, 7

# # Output
# slope: 2
# distance: 2.236

import math 

# input text
fPoint = input("Enter the coordinate of point A: ")
sPoint = input("Enter the coordinate of point B: ")

fSplit = fPoint.split(",")
sSplit = sPoint.split(",")

x1 = int(fSplit[0])
y1 = int(fSplit[1])

x2 = int(sSplit[0])
y2 = int(sSplit[1])

distance = math.sqrt((x1-x2)**2 + (y1-y2)**2)
slope = (y2-y1)/(x2-x1)

print("slope : ", int(slope))
print("distance : ", round(distance, 3))