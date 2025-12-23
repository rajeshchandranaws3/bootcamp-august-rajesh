# things to do

- Build a ci for app build
- deploy app on eks and do rolling upgrade for new version u[date]
- build cd for automated rolling upgrade(legacy but important to understand why we need gitops)
- HPA




EKS cluster build step
- build eks cluster from console
- use clauster iam role 
- vpc cni, kube proxy and core dns plugins and create cluster
- register clusetr on local - auth and all
- kubectl context management 
- managed nodes confif 


aws eks update-kubeconfig --region ap-south-1 --name demo-akhilesh


kubectl port-forward -n student-portal service/student-portal 8111:8080 


new image: 307946636515.dkr.ecr.us-east-1.amazonaws.com/student-portal:2.0

kubectl set image deployment/student-portal -n student-portal flask=307946636515.dkr.ecr.us-east-1.amazonaws.com/student-portal:2.0

kubectl set image deployment/student-portal -n student-portal flask=nginx:latest

kubectl set image deployment/student-portal -n student-portal flask=307946636515.dkr.ecr.us-east-1.amazonaws.com/student-portal:3.0

kubectl rollout restart deployment/student-portal -n student-portal 

# Build multi-platform image

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t 307946636515.dkr.ecr.us-east-1.amazonaws.com/student-portal:2.0 --push .
```

For local testing without push:
```bash
docker buildx build --platform linux/amd64 -t student-portal:2.0 .
```