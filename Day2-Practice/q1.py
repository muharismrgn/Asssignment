
# ************************Question #1************************

# Write a program that will give you the result of adding and reversing four-digit numbers.

# Input
# Enter the four digit number: 4567

# Output
# total: 22
# reverse: 7654

#input 4 digit
num = input("Enter the four digit number: ")

# kondisi ketika input tidak samadengan 4 ataupun yang diinputkan bukan merupakan digit
if len(num) != 4 or not num.isdigit():
    print("Please enter a valid four digit number.")

# kondisi ketika input sudah sesuai
else:
    #menjumlahkan digit
    total = sum(int(digit) for digit in num)
    #reverse string
    reverse_num = num[::-1]

    print("total:", total)
    print("reverse:", reverse_num)