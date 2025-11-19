import boto3
import json


ec2 = boto3.client('ec2')
lmda = boto3.client('lambda')
s3 = boto3.client('s3')


aws_region = "us-east-1"
# retunr as string
# def ec2_data():
#     return_data = []
#     # print()
#     # print(f" printing at start {return_data}")
#     response = ec2.describe_instances()
#     instances = response.get('Reservations')
#     for instance in instances:
#         instance_id = instance['Instances'][0].get('InstanceId')
#         machine_type = instance['Instances'][0].get('InstanceType')
#         state = instance['Instances'][0].get('State')['Name']
#         # print(instance_id, machine_type, state)
#         return_data.append((instance_id, machine_type, state))
#         # print(f" printing inside the loop {return_data}")
#     return return_data


def ec2_data():
    return [(instance['Instances'][0].get('InstanceId'),
            instance['Instances'][0].get('InstanceType'), 
            instance['Instances'][0].get('State')['Name'] )
            for instance in ec2.describe_instances().get('Reservations')
            ]



def lamda_data():
    return [
       (function['FunctionName'], function['Runtime'])
       for function in lmda.list_functions()['Functions']
    ]


data = {
    "EC2_DATA" : ec2_data(),
    "LAMBDA_DATA": lamda_data()
}


with open('report.txt', 'w') as f:
    f.write(json.dumps(data, indent= 4))



