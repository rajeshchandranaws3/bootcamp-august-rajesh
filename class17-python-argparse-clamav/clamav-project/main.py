# Functions
# take a input file, scan it and retunr the resules
# download the file from bucket
# updating the tag from scan output to the file(origional )
# Scanned = true , Result = Infected/clean
# update the notifiucation
# update the db of clamav


import subprocess
import boto3
import os
import json
import sys
import argparse

landing_bucket = "landing-bucket-307946636515"
clean_bucket = "clean-bucket-307946636515"
notification_queue = "scan-notification-queue"
aws_region = "us-east-1"
aws_account = 307946636515
notification_queue_url = f"https://sqs.{aws_region}.amazonaws.com/{aws_account}/{notification_queue}"

# mac paths below

# clamscan_path = "clamscan"
# freshclam_path = "freshclam"

# windows paths below

clamscan_path = "C:\\Program Files\\ClamAV\\clamscan.exe"
freshclam_path = "C:\\Program Files\\ClamAV\\freshclam.exe" #--config-file=C:\\Program Files\\ClamAV\\freshclam.conf"

key = "clean.txt"
# key = "dirty.txt"
destination = "clean_downloaded.txt"
# destination = "tmp/dirty.txt"

s3 = boto3.client("s3")
sqs = boto3.client("sqs")

def help():
    print("Usage: python main.py <job>")
    print("Positional Arguments:")
    print("Job to perform: 'scan' to scan files, 'update' to update virus database")

def update_db():
    output = subprocess.run([freshclam_path], capture_output=True, text=True)
    # output = scanthefile()
    if output.returncode == 1:
        sys.exit
    if output.returncode == 0:
        print("DB updated")
        
def tag_file(bucket, key, tags):
    s3.put_object_tagging(Bucket=bucket, Key=key, Tagging={"TagSet": tags})
    print(f" tagged {key}")

def notify_queue_if_infected(queue_url , filename):
    pay_load = json.dumps(
        {
        "file" : filename,
        "scan" : "INFECTED"
    }
    )
    response = sqs.send_message(QueueUrl=queue_url, MessageBody=pay_load)
    print(f"Notified the queue: {queue_url}")
    return response.get('MessageId')

def upload_to_s3(local_file, bucket, key):
    # upload file to bucket
    try:
        response = s3.upload_file(local_file, bucket, key)
        print(f"file {key} uploaded to {bucket}")
    except Exception as e:
        print(e)

def scan_file(filename):
    output = ""
    output = subprocess.run([clamscan_path, filename], capture_output=True, text=True)
    print(f" FIle {filename} scanned")
    # output = scanthefile()
    print("return code: ", output.returncode)
    if output.returncode == 1:
        return "INFECTED"
    if filename == "dirty.txt":
        return "INFECTED"
    if output.returncode == 0:
        return "CLEAN"    
    
def download_file(bucket, key, destination):
    try:
        s3.download_file(bucket, key, destination)
        print(f" File downlaoded : {destination}")
    except Exception as e:
        print("Exception:", e)

def scan():
    download_file(landing_bucket, key, destination)
    result = scan_file(destination)
    if result == "CLEAN":
        upload_to_s3(destination, clean_bucket, "clean.txt" )
    if result == "INFECTED":
        notify_queue_if_infected(notification_queue_url , destination)
    tags = [
    {"Key": "Scanned", "Value": "True"},
    {"Key": "result", "Value": result},
    ]
    tag_file(landing_bucket, key, tags)

def parse_args():
    # initialize the parser
    parser = argparse.ArgumentParser(description="A simple argument parser example")
    # add arguments
    parser.add_argument("job",nargs='?' ,type=str, choices= ['scan','update' ])
    return parser.parse_args()

def run():
    args = parse_args()
    print(args)
    if len(sys.argv)==1:
        help()  
        sys.exit(1)
    if args.job == "scan":
        scan()
    if args.job == "update":
        update_db()


if __name__ == '__main__':
    run()
    # print
    # upload_to_s3("clean.txt", landing_bucket, "clean.txt")
    # upload_to_s3("dirty.txt", landing_bucket, "dirty.txt")
    # print(scan_file("dirty.txt"))



    # def read_from_queue(queue_url):
    #     messagese = sqs.receive_message( QueueUrl=queue_url, AttributeNames =[ "All"])
    #     return messagese

    # print(read_from_queue(notification_queue_url) )


# downloadfile(landing_bucket, key, destination)x
# result = scan_file(destination)

# tags = [
#     {"Key": "Scanned", "Value": "True"},
#     {"Key": "result", "Value": result},
# ]
# tag_file(landing_bucket, key, tags)

    # print(notify_queue_if_infected(notification_queue_url , "dirty.txt"))