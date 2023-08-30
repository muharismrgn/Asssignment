# ## ************************Question #5************************

# Given two strings. Write a program to create a new string by appending the second string in the middle of first string.

# # Input
# Enter the first text: 'JCDS'
# Enter the second text: '0210'

# # Output
# expected result: 'JC0210DS'

# input text
fText = input("Enter the first text: ")
sText = input("Enter the second text: ")

# mencari index tengah
midfText = int(len(fText)/2)
print(midfText)

# hasil dari penggabungan
result = fText[0:midfText] + sText + fText[midfText:]

print("expected result: ", result)