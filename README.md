# Hello World

Hello World is a Web app powered by Mongo that lives in Kuberenetes.


## Prerequisites

1. Obtain Access to an AWS Account

You will need an AWS account and ability to communicate with it from your terminal, using AWS Command Line Interface (AWS CLI) and similar tools.

In the following code examples, we encounter several tokens that can’t be given synthetic values (e.g.,, those referring to AWS account ID or Region). These should be replaced with values that match your environment.

2. Create the Cluster

We will use terraform to provision an Amazon EKS cluster, which in addition to creating the cluster itself also provisions and configures the necessary network resources (a Virtual Private Cloud — VPC, subnets, and security groups).

The following terraform command  defines the Amazon EKS cluster and its settings:

```
terraform apply -auto-approve
```

## after terraform apply export your kube config context for EKS

```
aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)

# verity you can connect to the k8s cluster
kubectl get nodes
kubectl get pods -A
```

## install ingress-nginx controller

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
    --version 4.2.3 \
    --namespace kube-system \
    --set controller.service.type=ClusterIP

kubectl -n kube-system rollout status deployment ingress-nginx-controller

kubectl get deployment -n kube-system ingress-nginx-controller
```

## Deploy the Testing Services

### 1. Create the Services Namespace
```
kubectl create namespace apps

# this is for the hashicorp/echo service:
SERVICE_NAME=first NS=apps envsubst < k8s-service-echo.yml | kubectl apply -f -

# this is for the markchristopherwest/hello-world service:
SERVICE_NAME=webserver NS=apps  DB_PASS=changeme DB_HOST=$(terraform output -raw ec2_hostname) DB_NAME=hello_world envsubst < k8s-service-example.yml | kubectl apply -f -
```

# deploy the ingress

```
NS=apps envsubst < k8s-ingress.yml | kubectl apply -f -

kubectl port-forward -n kube-system svc/ingress-nginx-controller 8080:80

curl -sS localhost:8080/first
curl -sS localhost:8080/hello-world

```

# deploy NLB

```
# for classic NLB:
helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
    --namespace kube-system \
    --set controller.service.type=LoadBalancer

# for modern ALB:
helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
    --namespace kube-system \
    --set controller.service.type=LoadBalancer \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="nlb" 


## with your nginx ingress controller installed deploy the load balancer controller


# https://aws.amazon.com/blogs/containers/exposing-kubernetes-applications-part-3-nginx-ingress-controller/


curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json  


aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json

eksctl create iamserviceaccount   \
    --cluster=$(terraform output -raw cluster_name) \
    --name=aws-load-balancer-controller \
    --namespace=kube-system \
    --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT}:policy/AWSLoadBalancerControllerIAMPolicy \
    --approve

kubectl apply -k \
    "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"

helm repo add eks https://aws.github.io/eks-charts

helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$(terraform output -raw cluster_name)\
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller

kubectl -n kube-system rollout status deployment aws-load-balancer-controller

kubectl get deployment -n kube-system aws-load-balancer-controller


# Redeploy the controller:
helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
    --version 4.2.3 \
    --namespace kube-system \
    --values values.yml
    
kubectl -n kube-system rollout status deployment ingress-nginx-controller

kubectl get deployment -n kube-system ingress-nginx-controller

export NLB_URL=$(kubectl get -n kube-system service/ingress-nginx-controller \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')


# curl your exposed service

curl $NLB_URL/hello-world


## Add custom helm repo
helm repo add markchristopherwest https://markchristopherwest.github.io/hello-world-chart

helm pull markchristopherwest/hello-world-chart

helm install --set DB_HOST=$(terraform output -raw ec2_hostname) webserver markchristopherwest/hello-world-chart

helm install webserver markchristopherwest/hello-world-chart

kubectl get pods


NS=apps DB_HOST=$(terraform output -raw ec2_hostname) envsubst < k8s-service-example.yml | kubectl apply -f - 

SERVICE_NAME=webserver NS=apps  DB_PASS=changeme DB_HOST=$(terraform output -raw ec2_hostname) DB_NAME=hello_world envsubst < k8s-service-example.yml | kubectl apply -f -


### Grant admin access to the container

kubectl exec -n apps <pod-name> -c <container-name> -- --privileged
```


## Don't Forget to:

- toggle authentication in mongo
- confirm backups are in s3
- confirm s3 is open wide
- confirm context of container is elevated


# https://kubernetes.io/docs/reference/access-authn-authz/rbac/#permissive-rbac-permissions
kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts