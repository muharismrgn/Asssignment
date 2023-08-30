# ## ************************Question #3************************

# Write a python program to get a single string from two given strings, separated by a space and swap the first three characters of each string.

# # Input
# Enter the sample string: 'purwa, dhika'

# # Output
# expected result: 'dhiwa purka'

# input text
string = input("Enter the sample string (2 words): ")
splitText = string.split(", ")

# kondisi ketika string tidak 2 kata
if len(splitText) != 2:
    print("Enter 2 Words")
# kondisi ketika string sudah memenuhi syarat
else :
    string1 = splitText[0]
    string2 = splitText[1]
    result = string2[0:3] + string1[3:] + " " + string1[0:3]+string2[3:]
    print("expected result: ", result)