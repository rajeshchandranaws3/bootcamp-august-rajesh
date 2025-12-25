# EKS Deployment steps with OIDC and IRSA Setup for K8S to create the Load Balancer in AWS

- First deploy the student-portal application into the eks clsuter.
- Expose the service for that deployment
- Verify if it is working or not through port forwarding.
- Cluster IAM role and Node IAM roles are enough for this deployment to work.


We need OIDC and IRSA Setup for the LB Ingress Controller (in EKS) to deploy the Load Balancer (in AWS)

- OIDC Setup in AWS:
	- Create IAM identity provider for EKS cluster (Use OIDC URL). I have created it manually.
    - Ex for provider url: https://oidc.eks.us-east-1.amazonaws.com/id/584682AA01BDA504CBA2D22C8E94E4BE
    - audience: sts.amazonaws.com
	- Create IAM role with permission policy as well as trust policy (ex: "AWSLoadBalancerControllerRole")
	- Provide the OIDC ARN inside the trust policy as Principal->Federated
- IRSA Setup in EKS:
	- Install the LB Ingress Controller using HELM.
	- Create the Service Account in EKS (ex: "aws-load-balancer-controller")
	- Provide the role-arn for IAM Role: "AWSLoadBalancerControllerRole" as annotation inside the Service Account
	- Create the Ingress Resource with ingressClassName: alb



## Steps with aws-cli codes

307946636515

- create the iam identity provider for you cluster (oidc)

- export cluster_name=rajesh-cluster

- oidc_id=$(aws eks describe-cluster --name $cluster_name \
--query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

- echo $oidc_id

- copy the arn for oidc id provider (arn:aws:iam::307946636515:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/xxxxxx)

- use the above oidc arn while creting the iam role 

## Check if IAM OIDC provider with your cluster’s issuer ID 
- aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4


- download the iam policy
  curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json


## create service account
- Use kubectl command for creating SA
- Use iam role arn as annotation inside SA.

## cretae iam policy with the jsn config file

```
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

## cretae iam role with trust policy

```
aws iam create-role --role-name AWSLoadBalancerControllerRole \
    --assume-role-policy-document file://iam_trust_policy.json
```


## attach the policy to role

```
aws iam attach-role-policy \
    --role-name AWSLoadBalancerControllerRole \
    --policy-arn arn:aws:iam::307946636515:policy/AWSLoadBalancerControllerIAMPolicy

```

## load balancer controller install

## helm install
- install helm (In your respective OS)

## helm repo add

- helm repo add eks https://aws.github.io/eks-charts

## helm update

- helm repo update

<!-- ## create a custom resource 

kubectl apply -k  \
"github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master" -->

## instal aws load balancer controller 
```
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=rajesh-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set vpcId=vpc-04225d76b207fbd2d  \
  --set region=us-east-1
```




  public subnet need tag

  Key=kubernetes.io/role/elb,Value=1


  aws ec2 describe-subnets --filters "Name=vpc-id,Values=	
vpc-0b9dbc4b7574faa5e" "Name=map-public-ip-on-launch,Values=true" \
--query "Subnets[*].{SubnetId:SubnetId,AvailabilityZone:AvailabilityZone,PublicIp:MapPublicIpOnLaunch}"

- AvailabilityZone: ap-south-1b
  PublicIp: true
  SubnetId: subnet-0bff6e900da51e8d9
- AvailabilityZone: ap-south-1a
  PublicIp: true
  SubnetId: subnet-0fe851cbd12dc1edb
- AvailabilityZone: ap-south-1c
  PublicIp: true
  SubnetId: subnet-0243c0bd813e40632
(END)


aws ec2 create-tags --resources subnet-0bff6e900da51e8d9 subnet-0fe851cbd12dc1edb \
subnet-0243c0bd813e40632 --tags Key=kubernetes.io/role/elb,Value=1

aws ec2 describe-subnets --subnet-ids subnet-0bff6e900da51e8d9 subnet-0fe851cbd12dc1edb \
subnet-0243c0bd813e40632 --query "Subnets[*].{SubnetId:SubnetId,Tags:Tags}"