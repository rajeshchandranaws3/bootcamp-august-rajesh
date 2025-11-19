# get the lambda function details and store them in a file
import json
import os
import boto3

lambda_client = boto3.client('lambda')
function_name = 'lambda_1'  # replace with your lambda function name
response = lambda_client.get_function(FunctionName=function_name)
print("response: ", response)
print("response type: ", type(response))
print(len(response))
print(response.keys())


lambda_details = {
    'FunctionName': response['Configuration']['FunctionName'],
    'Runtime': response['Configuration']['Runtime'],
    'Handler': response['Configuration']['Handler'],
    'Role': response['Configuration']['Role'],
    'CodeSize': response['Configuration']['CodeSize'],
    'Description': response['Configuration']['Description'],
    'Timeout': response['Configuration']['Timeout'],
    'MemorySize': response['Configuration']['MemorySize'],
    'LastModified': response['Configuration']['LastModified'],
    'CodeSha256': response['Configuration']['CodeSha256'],
    'Version': response['Configuration']['Version'],
}

#write response details to a json file  
with open('lambda_response.json', 'w') as f:
    json.dump(response, f, indent=4)


#write the lambda details to a json file

with open('lambda_details.json', 'w') as f:
    json.dump(lambda_details, f, indent=4)

# read the lambda details from the json file and print them
with open('lambda_details.json', 'r') as f:
    loaded_details = json.load(f)
print("load_details:", loaded_details)
print(type(loaded_details))
print(len(loaded_details))


# write some data to a file
data = {
    "name": "Alice",    
    "age": 30,
    "city": "New York"
}

# write the dictionary data to a json file
with open("output.json", "w") as f:
    json.dump(data, f)  

# read the data back from the file
with open("output.json", "r") as f:
    loaded_data = json.load(f)  

#print the loaded data
print("loaded data: ", loaded_data)  

# {'name': 'Alice', 'age': 30, 'city': 'New York'}
print(type(loaded_data))
# <class 'dict'>    
print(len(loaded_data))
# 3
# Clean up created file
#os.remove("output.json")
