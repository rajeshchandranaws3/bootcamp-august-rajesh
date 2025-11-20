# Import the Boto3 library, which is the Amazon Web Services (AWS) SDK for Python.
import boto3


# Define the Lambda handler function that will be executed when the Lambda function is invoked.
def lambda_handler(event, context):
    # Extract the owner's username from the event data.
    try:
        # If logged in as AWS IAM user
        owner = event["detail"]["userIdentity"]["userName"]
    except Exception as e:
        # if logged in as AWS root user
        owner = event["detail"]["userIdentity"]["arn"].split(":")[-1]

    # Extract the ID of the EC2 instance from the event data.
    InstanceId = event["detail"]["responseElements"]["instancesSet"]["items"][0][
        "instanceId"
    ]

    # Create an EC2 client using the boto3 library.
    ec2 = boto3.client("ec2")

    # Create tags for the EC2 instance. Tags provide metadata for the instance.
    ec2.create_tags(
        # Specify the resources (in this case, the EC2 instance) to which the tags will be applied.
        Resources=[
            InstanceId,  # ID of the EC2 instance
        ],
        # Specify the tags to be applied to the resources.
        Tags=[
            {
                "Key": "OWNER",  # Tag key
                "Value": owner,  # Tag value (the owner's username)
            },
        ],
    )
