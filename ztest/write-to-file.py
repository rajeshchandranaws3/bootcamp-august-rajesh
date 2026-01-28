file_name = "output.txt"
with open(file_name, "w") as file:
    file.write("This is a test file from Rajesh.\n")
    file.write("Writing some sample text to the file.\n")
    file.write("End of the file.\n")    
print(f"Data has been written to {file_name}")
