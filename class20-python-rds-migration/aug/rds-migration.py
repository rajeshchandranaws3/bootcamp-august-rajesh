import boto3
import json
import logging
import time
import subprocess
import psycopg2


rds_client = boto3.client("rds")
sm = boto3.client("secretsmanager")

# db_identifier = "dev-app-db"
# password = "admin1234"
# db_link = 'postgresql://postgres:admin1234@dev-app-db.cvik8accw2tk.ap-south-1.rds.amazonaws.com:5432/mydb'

# pull the data about the existing RDS instance


def get_db_credentials_from_secret(db_link):
    response = sm.get_secret_value(SecretId=db_link)
    # value = response.get('SecretString')
    # credentials = json.loads(value)
    # print(credentials.get('db_link'))

    return json.loads(response.get("SecretString")).get("db_link")


def parse_db_link(db_link_secret):
    # db_link = 'postgresql://postgres:admin1234@dev-app-db.cvik8accw2tk.ap-south-1.rds.amazonaws.com:5432/mydb'
    user = db_link_secret.split("//")[-1].split(":")[0]
    password = db_link_secret.split("//")[-1].split(":")[1].split("@")[0]
    host = db_link_secret.split("//")[-1].split(":")[1].split("@")[-1]
    db_identifier = (
        db_link_secret.split("//")[-1].split(":")[1].split("@")[-1].split(".")[0]
    )
    dbname = db_link_secret.split(":")[-1].split("/")[-1]

    return user, password, host, db_identifier, dbname

def check_rds_availability(host, port, dbname, user, password):
    timeout = 600  # 10 minutes
    start_time = time.time()
    
    while time.time() - start_time < timeout:
        try:
            conn = psycopg2.connect(
                host=host, 
                port=port, 
                dbname=dbname, 
                user=user, 
                password=password
            )
            conn.close()
            logging.info(f"Connection established successfully with {host}.")
            time.sleep(90)
            return True
            
        except:
            logging.error(f"Error connecting to RDS database {host}: Not ready yet.")
            logging.info("Retrying in 90 seconds...")
            time.sleep(90)
    
    logging.error("Connection timeout after 10 minutes.")
    return False

def get_rds_instance_info(dbname):
    response = rds_client.describe_db_instances(DBInstanceIdentifier=dbname)
    return response["DBInstances"][0]


def create_new_rds_instance(db_link, new_storage):
    _ , password, _ , db_identifier, _ = parse_db_link(get_db_credentials_from_secret(db_link))

    rds_info = get_rds_instance_info(db_identifier)
    # print(rds_info["VpcSecurityGroups"])
    # for i in rds_info["VpcSecurityGroups"]:
    #     print(i["VpcSecurityGroupId"])
    # print([sg["VpcSecurityGroupId"] for sg in rds_info["VpcSecurityGroups"]])



    # print(rds_info.get("DBInstanceClass"))
    # print(rds_info.get("DBSubnetGroup")["DBSubnetGroupName"])

    response = rds_client.create_db_instance(
        DBInstanceIdentifier=f"{db_identifier}-new",
        AllocatedStorage=new_storage,
        DBInstanceClass=rds_info["DBInstanceClass"],
        Engine=rds_info["Engine"],
        MasterUsername=rds_info["MasterUsername"],
        # get this from secrets manager or as input from outside
        MasterUserPassword=password,
        VpcSecurityGroupIds=[
            sg["VpcSecurityGroupId"] for sg in rds_info["VpcSecurityGroups"]
        ],
        DBSubnetGroupName=rds_info["DBSubnetGroup"]["DBSubnetGroupName"],
        MultiAZ=rds_info["MultiAZ"],
        PubliclyAccessible=rds_info["PubliclyAccessible"],
        StorageType=rds_info["StorageType"],
        Tags=rds_info.get("TagList", []),
    )
    return response


def sync_dbs(old_db, new_db):
    # Create pgsync configuration with source and destination db details
    with open(".pgsync.yml", "w") as f:
        f.write(f"from: {old_db}\n")
        f.write(f"to: {new_db}\n")
        f.write("to_safe: true\n")
    # pgsync
    try:
        process = subprocess.Popen(
            [
                "pgsync",
            ],
            stdout=subprocess.PIPE,
        )
        output = process.communicate()[0]
        if int(process.returncode) != 0:
            logging.error(f"Command failed. Return code : {process.returncode}")

        return output
    except Exception as e:
        logging.error(f"Issue with db sync")
        exit(1)


def rename_dbs(old_db_identifier, new_db_identifier):
    # rename old db
    rds_client.modify_db_instance(
        DBInstanceIdentifier=old_db_identifier,
        NewDBInstanceIdentifier=new_db_identifier,
        ApplyImmediately=True,
    )


# when we created duplicate rds -> dev-app-db -> dev-app-db-new
# swap
# dev-app-db -> dev-app-db-old
# dev-app-db-new -> dev-app-db

def swap_dbs(db_identifier):
    # rename new db to old db name
    logging.info("Swapping DBs - dev-app-db -> dev-app-db-old")
    rename_dbs(db_identifier, f"{db_identifier}-old")
    time.sleep(300)
    
    logging.info("Swapping DBs - dev-app-db-new -> dev-app-db")
    rename_dbs(f"{db_identifier}-new",db_identifier)
    time.sleep(300)

def stop_rds_instance(db_identifier):
    response = rds_client.stop_db_instance(
        DBInstanceIdentifier=db_identifier
    )
    return response



def run():
    db_link = "db/dev-app-db/db_link"
    new_storage = 20  # in GB
    user, password, old_host, db_identifier, dbname = parse_db_link(get_db_credentials_from_secret(db_link))
    new_host= old_host.split(".")[0] + "-new" + "."+ ".".join(old_host.split(".")[1:])
    create_new_rds_instance(db_link, new_storage)

    check_rds_availability(old_host, 5432, dbname, user, password)
    sync_dbs(old_host, new_host)
    swap_dbs(db_identifier)
    stop_rds_instance(f"{db_identifier}-old")

