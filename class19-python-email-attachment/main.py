import boto3
import json

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders

ec2 = boto3.client('ec2')
lmda = boto3.client('lambda')
s3 = boto3.client('ec2')
ses = boto3.client('ses')


aws_region = "ap-south-1"
# retunr as string
def ec2_data():
    return_data = []
    # print()
    # print(f" printing at start {return_data}")
    response = ec2.describe_instances()
    instances = response.get('Reservations')
    for instance in instances:
        instance_id = instance['Instances'][0].get('InstanceId')
        machine_type = instance['Instances'][0].get('InstanceType')
        state = instance['Instances'][0].get('State')['Name']
        # print(instance_id, machine_type, state)
        return_data.append((instance_id, machine_type, state))
        # print(f" printing inside the loop {return_data}")
    return return_data

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

# writing a report to reports.txt
with open('report.txt', 'w') as f:
    f.write(json.dumps(data, indent= 4))


business_team = "businkpmgsol@mkpg.com"

from_email = 'aditiyamishranit@gmail.com'
to_email = ['livingdevops@gmail.com', 'adetayo.eyelade2@gmail.com']
subject = "Daily Automated cloud report"
body = f"""
         HI All,
         Please find today cloud roport.
         Reach out to busineess team for any queries on below email \n
         {business_team}

         Regards
         Cloud team
        """
text_body = MIMEText(body, 'plain')


msg = MIMEMultipart()
msg["To"] = ', '.join(to_email)
msg["From"] = from_email
msg["Subject"] = subject
msg.attach(text_body)


filename = 'report.txt'
with open(filename, 'rb') as attachment:
    part = MIMEBase('application', 'octet-stream')
    part.set_payload(attachment.read())

encoders.encode_base64(part)
part.add_header('Content-Disposition', f'attachment; filename={filename}')
msg.attach(part)


# sending email
response = ses.send_raw_email(
    Source=from_email,
    Destinations=to_email,
    RawMessage={
        'Data': msg.as_string()
    },

)

# print(dir(msg))
print(response)