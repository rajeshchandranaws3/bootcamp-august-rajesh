# EKS Cluster Setup
- Create an EKS Cluster with name "rajesh-cluster"
- Create node group with 2 nodes
- Assign IAM Roles required for Cluster as well as Nodes
- Inside the cluster, create IAM Access Entries for the admin user "cli-user"
- Associate the policy "AmazonEKSClusterAdminPolicy" for "cli-user"

# Kube Config File Setup
- aws configure with access key and secret access key of "cli-user"
- aws sts get-caller-identity
- aws eks update-kubeconfig --region us-east-1 --name rajesh-cluster
- k get nodes

# Deploy Student-potal Application
- First deploy the student-portal application into the eks clsuter.
- Expose the service for that deployment
- Verify if it is working or not through port forwarding.
- Cluster IAM role and Node IAM roles are already assigned for EKS and they are enough for this deployment to work.

# Port-forward
- k port-forward svc/student-portal 8080:8080 -n student-portal
