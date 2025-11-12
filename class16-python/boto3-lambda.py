import boto3

lambda_client = boto3.client('lambda')

lambda_arn = 'arn:aws:lambda:ap-south-1:879381241087:function:iam-key-rotation'
tag_key = 'team'


##### Function to print all lambda functions (name, runtime, and arn) #####

def print_lambda_functions():
    response = lambda_client.list_functions()
    for function in response.get('Functions', []):
        function_name = function.get('FunctionName')
        runtime = function.get('Runtime')
        arn = function.get('FunctionArn')
        print(f"Lambda Function Name: {function_name}")
        print(f"Python Version: {runtime}")
        print(f"ARN: {arn}")
        print("----")

print("---- Listing Lambda Function Details ----")
print_lambda_functions()


##### Function to print all lambda functions along with their tags (name, version, tags) #####

def print_lambda_functions_and_tags():
    lambda_info = []
    paginator = lambda_client.get_paginator('list_functions')
    for page in paginator.paginate():
        for fn in page.get('Functions', []):
            name = fn.get('FunctionName')
            runtime = fn.get('Runtime')
            arn = fn.get('FunctionArn')
            try:
                tags_resp = lambda_client.list_tags(Resource=arn)
                tags = tags_resp.get('Tags', {}) or {}
            except Exception:
                tags = {}
            print(f"Lambda Name: {name}")
            print(f"Python Version: {runtime}")
            if tags:
                print("Tags:")
                for k, v in tags.items():
                    print(f"  {k}: {v}")
            else:
                print("Tags: None")
            print("----")
            lambda_info.append({"name": name, "runtime": runtime, "arn": arn, "tags": tags})


# print("---- Listing Lambda Functions & Tags ----")
# print_lambda_functions_and_tags()


##### Function to get specific tag value for a given lambda function #####

def get_lambda_tag_value(lambda_arn, tag_key):
    response = lambda_client.list_tags(Resource=lambda_arn)
    try:
      output = response.get('Tags')[tag_key]
    except KeyError:
    #   print(f"Tag key '{tag_key}' not found.")
      output = None

    return output

# print("---- Getting Specific Tag Value ----")
# print(get_lambda_tag_value(lambda_arn, tag_key))


##### Function to return all lambda details as list of tuples #####

def get_all_lambda_function_details():
    response = lambda_client.list_functions()
    temp_lambda = []
    for function in response['Functions']:
        function_name = function['FunctionName']
        runtime = function['Runtime']
        lambda_arn = function['FunctionArn']
        temp_lambda.append((function_name, runtime, lambda_arn))
    return temp_lambda

# print("---- Getting All Lambda Function Details ----")
# print(get_all_lambda_function_details())


##### Generate report of lambda name, python version and team tag value #####

def generate_lambda_report():
    lambda_list = get_all_lambda_function_details()
    # print(lambda_list)
    for items in lambda_list:
        # print(items)
        name, version, arn = items
        # print(name, version, arn)
        team = get_lambda_tag_value(arn, 'team')
        print(f"Lambda Name: {name}, Python Version: {version}, Team: {team}")

# print("---- Generating Lambda Report ----")
# generate_lambda_report()








# list = []
# list.append(("name", "version", "arn"))
# list.append(("name", "version", "arn"))
# print(list)