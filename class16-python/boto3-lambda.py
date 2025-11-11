# generate a report of lambd -> lambda_name python_version -> version owner -> owner_name
# create virtual env
# install boto3 -> pip install boto3
# have aws cli installed on laptop -> auth with it --> aws configure -

import boto3

lambda_client = boto3.client('lambda')

# response = lambda_client.list_functions()

# print(response)

# print(response['Functions']) # print(response.get('Functions'))

# for function in response['Functions']:
#     function_name = function['FunctionName']
#     runtime = function['Runtime']
#     print(f"Lambda Name: {function_name}, Python Version: {runtime}, Owner: {owner}")



lambda_arn = 'arn:aws:lambda:ap-south-1:879381241087:function:iam-key-rotation'
tag_key = 'owner'   
# response = lambda_client.list_tags(
#     Resource=lambda_arn
# )
# print(response.get('Tags')['owner'])

def get_lambda_tag_value(lambda_arn, tag_key):
    response = lambda_client.list_tags(
        Resource=lambda_arn
    )
    try:
      output = response.get('Tags')[tag_key]
    except KeyError:
    #   print(f"Tag key '{tag_key}' not found.")
      output = None

    return output

def get_all_lambda():
    response = lambda_client.list_functions()
    temp_lambda = []
    for function in response['Functions']:
        function_name = function['FunctionName']
        runtime = function['Runtime']
        lambda_arn = function['FunctionArn']
        temp_lambda.append((function_name, runtime, lambda_arn))
    return temp_lambda

# print(get_lambda_tag_value(lambda_arn, tag_key))

# name, version, arn = get_all_lambda()
# print(f"Lambda Name: {name}, Python Version: {version}, ARN : {arn}")

def generate_lambda_report():
    lambda_list = get_all_lambda()
    # print(lambda_list)
    for items in lambda_list:
        # print(items)
        name, version, arn = items
        # print(name, version, arn)
        owner = get_lambda_tag_value(arn, 'owner')
        print(f"Lambda Name: {name}, Python Version: {version}, Owner: {owner}")

    # for lambda_info in lambda_list:
    #     name, version, arn = lambda_info
    #     owner = get_lambda_tag_value(arn, 'owner')
    #     print(f"Lambda Name: {name}, Python Version: {version}, Owner: {owner}")


generate_lambda_report()








# list = []
# list.append(("name", "version", "arn"))
# list.append(("name", "version", "arn"))
# print(list)