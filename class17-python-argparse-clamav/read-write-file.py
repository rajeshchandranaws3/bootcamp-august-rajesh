import json
import os

#read the contents of sample.txt file
with open('sample.txt', 'r') as f:
    content = f.read()
print("Content of sample.txt:")
print(content)
print("Type of content:", type(content))
print("Length of content:", len(content))
print("-----")

#read the contents line by line
with open('sample.txt', 'r') as f:
    lines = f.readlines()   

print("Lines in sample.txt:")
print(lines)

# for i, line in enumerate(lines):
#     # print(f"{i+1}): {line.strip()}")
#     print(line.strip('\n'))

# add these lines to another file
with open('sample_copy.txt', 'w') as f:
    f.writelines(lines)
print("Lines written to sample_copy.txt")

# add these lines to another file using loop
with open('sample_copy_loop.txt', 'w') as f:
    for line in lines:
        f.write("-- "+ line.strip() + "--" + "\n")   
print("Lines written to sample_copy_loop.txt")



for line in lines:
    print(line.strip('\n'))

print("Type of lines:", type(lines))
print("Length of lines:", len(lines))
print("-----")

