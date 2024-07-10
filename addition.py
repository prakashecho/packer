# addition.py

def add_numbers(a, b):
    """
    This function takes two numbers as arguments and returns their sum.
    """
    return a + b

if __name__ == "__main__":
    # Example usage
    num1 = float(input("Enter the first number: "))
    num2 = float(input("Enter the second number: "))
    
    result = add_numbers(num1, num2)
    print(f"The sum of {num1} and {num2} is {result}")
