# list comprehension


# normal way

# l = []

# for i in range(1, 25, 5):
#     new_i = i*2
#     l.append(new_i)

# print(l)

# better way 

# print([ i*2 for i in range(1, 25, 5)])
import boto3

ses = boto3.client('ses')
response = ses.send_email(
    Source='rajeshchandranaws3@gmail.com',
    Destination={
        'ToAddresses': [
            'rajeshchandran007@gmail.com',
        ]
    },
    Message={
        'Subject': {
            'Data': 'this is the subject',
        },
        'Body': {
        #     'Text': {
        #         'Data': 'this is the body',
        #     },
            'Html': {
                'Data': '<h1>  this is heading </h1>',
            }
        }}
)


print(response)