# Testing locally
# Run PostgreSQL container
docker run -d \
 --name attendance-db \
 -e POSTGRES_PASSWORD=password \
 -e POSTGRES_DB=mydb \
 -p 5432:5432 \
 postgres:15

# Export database connection string
export DB_LINK="postgresql://postgres:password@localhost:5432/mydb"

# Virtual env

python3 -m venv venv

source venv/bin/activate

pip install -r requirements.txt

python run.py 

# with Docker compose



# ECS

create an ecr repo, either with console, cli

repo name 
studentportal - url will look like 307946636515.dkr.ecr.us-east-1.amazonaws.com/ecs-studentportal

# login to ecr 
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 307946636515.dkr.ecr.us-east-1.amazonaws.com


#  docker build and push 

docker build -t student-portal .

docker tag student-portal 307946636515.dkr.ecr.us-east-1.amazonaws.com/ecs-studentportal:1.0

docker push 307946636515.dkr.ecr.us-east-1.amazonaws.com/ecs-studentportal:1.0

# now you can use this on ecs to run app