# ## ************************Question #4************************

# Create a new string made of the first, middle, and last characters of each input string.

# # Input
# Enter the first text: 'joGjaKARTa'
# Enter the second text: 'PurWAdhiKA'

# # Output
# expected result: 'jPKdaA'

# input text
fText = input("Enter the first text: ")
sText = input("Enter the second text: ")

# mencari index tengah
midfText = int(len(fText)/2)
midsText = int(len(sText)/2)

# hasil dari penggabungan
result = fText[0] + sText[0] + fText[midfText] + sText[midsText] + fText[-1] + sText[-1]

print("expected result: ", result)