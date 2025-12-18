### ecr
307946636515.dkr.ecr.us-east-1.amazonaws.com/v2/student-portal

### db_link
postgresql://myadmin:mypassword@student-portal.cizic4iqc955.us-east-1.rds.amazonaws.com:5432/postgres

### Debug Pod
kubectl run debug-pod --rm -it --image=postgres:16 -- bash

#### Running psqlcoomand
PGPASSWORD=mypassword psql -h \
student-portal.cizic4iqc955.us-east-1.rds.amazonaws.com -U myadmin -d postgres

### Port-Forward
❯ kubectl port-forward -n student-portal service/student-portal 8080:8080


## Steps for deploying student-portal app with postgresql
1. Create Dockerfile for the student-portal app.
2. Build the image using Dockerfile.
3. Create the ECR repo to store the image.
4. Tag the image based on the ECR repo name.
5. Authenticate the system to AWS using aws cli "aws configure"
6. Authenticate the system to ECR using aws cli "aws ecr get-login-password & docker login".
7. Push the image to ECR repo
8. Create kubernetes secret of type docker-registry, with ecr login password (using kubectl).
9. Create postgres db in RDS.
10. Create the db_link in aws secret manager.
11. Create deployment YAML file with the below details: 
	11.1. Create init container to fetch secrets from AWS Secrets Manager. Use image: amazon/aws-cli
    11.2. Create an IAM user in aws with custom policy attached for reading the aws secret manager.
	11.3. Create kubernetes secret  of type Opaque, with access key and secret access key of that user.
	11.4. Provide that access key and secret access key as ENV variable to the init container, for authentication.
	11.5. Inside init container, execute aws cli "aws secretsmanager get-secret-value" to fetch the db_link
	11.6. Extract the db_link value, and store it in a file inside the volume mount (Common volume for init conatiner and main container).
	11.7. Create the main container by using ECR image and provide "imagePullSecret" for docker-registry secret.
	11.8. Inside the main container, read the db_link file from volume mount and set it as ENV variable for the container and override the CMD.
12. Create service YAML file for the above deployment, with type ClusterIP.
13. Use "kubectl apply" to create all the resources in the required namespace.
14. Use kubectl port-forward to access the minikube's cluster ip service from the local machine itself.
15. Inorder to test the db connectivity separately, create a debug pod using image:postgres, and use the psql command inside the pod.


### Create ECR Registry Secret

    ```bash
    kubectl -n student-portal create secret docker-registry ecr-registry-secret \
      --docker-server=307946636515.dkr.ecr.us-east-1.amazonaws.com \
      --docker-username=AWS \
      --docker-password=$(aws ecr get-login-password --region us-east-1) \
      --docker-email=livingdevops@gmail.com
    ```

    Verify the secret was created:
    ```bash
    kubectl -n student-portal get secret ecr-registry-secret
    kubectl -n student-portal describe secret ecr-registry-secret
    ```
