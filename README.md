# Hello World

Hello World is a Web app powered by Mongo that lives in Kuberenetes.

## after terraform apply export your kube config context for EKS

```
aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)
```




## 1 . Create the Ingress Manifest file and Deploy the Ingress setup nginx ingress via helm

```
# add the helm repo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# update helm
helm repo update

# install the ingress
helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
    --version 4.2.3 \
    --namespace kube-system \
    --set controller.service.type=ClusterIP

# after this: Release "ingress-nginx" does not exist. Installing it now.

kubectl -n kube-system rollout status deployment ingress-nginx-controller

kubectl get deployment -n kube-system ingress-nginx-controller
```

## Deploy the Testing Services

### 1. Create the Services Namespace
```
kubectl create namespace apps

# this is for the hashicorp/echo service:

SERVICE_NAME=first NS=apps envsubst < k8s-service-echo.yml | kubectl apply -f -

# the hello-world app requires secrets

SERVICE_NAME=frontend NS=apps envsubst < k8s-secrets.yml | kubectl apply -f -

# this is for the markchristopherwest/hello-world service:

SERVICE_NAME=frontend NS=apps envsubst < k8s-service-example.yml | kubectl apply -f -

```

# deploy the ingress

```
NS=apps envsubst < k8s-ingress.yml | kubectl apply -f -

kubectl port-forward -n kube-system svc/ingress-nginx-controller 8080:80
```

# deploy NLB

helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
    --namespace kube-system \
    --set controller.service.type=LoadBalancer

# 

## with your nginx ingress controller installed deploy the load balancer controller


# https://aws.amazon.com/blogs/containers/exposing-kubernetes-applications-part-3-nginx-ingress-controller/


curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json  


aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json


eksctl create iamserviceaccount \
    --cluster=$(terraform output -raw cluster_name) \
    --name=aws-load-balancer-controller \
    --namespace=kube-system \
    --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT}:policy/AWSLoadBalancerControllerIAMPolicy \
    --approve




kubectl apply -k \
    "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

helm repo add eks https://aws.github.io/eks-charts


helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$(terraform output -raw cluster_name)\
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller


kubectl -n kube-system rollout status deployment aws-load-balancer-controller

kubectl get deployment -n kube-system aws-load-balancer-controller

export NLB_URL=$(kubectl get -n kube-system service/ingress-nginx-controller \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

## Add custom helm repo
helm repo add markchristopherwest https://markchristopherwest.github.io/hello-world-chart

helm pull markchristopherwest/hello-world-chart

helm install --set DB_HOST=$(terraform output -raw ec2_hostname) frontend markchristopherwest/hello-world-chart

helm install frontend markchristopherwest/hello-world-chart

kubectl get pods


NS=apps DB_HOST=$(terraform output -raw ec2_hostname) envsubst < k8s-service-example.yml | kubectl apply -f - 

