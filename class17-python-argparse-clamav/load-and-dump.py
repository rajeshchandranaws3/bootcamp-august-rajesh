import json

# Sample Python object
data_dict = {"name": "Rajesh", "age": 43, "city": "Kottayam"}
print("Original data:", data_dict)
print("Type of Original Data:", type(data_dict))
print("Length of Origianl Data", len(data_dict))
print("-----")

# 1. dumps() -> Python object to JSON string
json_string = json.dumps(data_dict)
print("dumps into json_string:", json_string)
print("Type of json_string", type(json_string))
print("Length of json_string:", len(json_string))
print("-----")

# 2. loads() -> JSON string to Python object
py_obj = json.loads(json_string)
print("loads from json_string into py_obj:", py_obj)
print("Type of py_obj:", type(py_obj))
print("Length of py_obj:", len(py_obj)) 
print("-----")


# 3. dump() -> write JSON to a file
with open("data.json", "w") as f:
    json.dump(data_dict, f)

with open("temp.txt", "w") as f:
    json.dump(data_dict, f)    

# 4. load() -> read JSON from file
with open("data.json", "r") as f:
    file_data_json = json.load(f)
print("load from json file into file_data_json:", file_data_json)
print("Type of file_data_json:", type(file_data_json))
print("Length of file_data_json:", len(file_data_json))
print("-----")

with open("temp.txt", "r") as f:
    file_data_txt = json.load(f)
print("load from txt file into file_data_txt:", file_data_txt)
print("Type of file_data_txt:", type(file_data_txt))
print("Length of file_data_txt:", len(file_data_txt))
print("-----")

# Clean up created files
# import os   
# os.remove("data.json")
# os.remove("temp.txt")