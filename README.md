# Hello World

Hello World is a Web app powered by Mongo that lives in Kuberenetes.


## export your kube config context for EKS
aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)


## add the nginx ingress
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
    --version 4.2.3 \
    --namespace kube-system \
    --set controller.service.type=ClusterIP

kubectl -n kube-system rollout status deployment ingress-nginx-controller

kubectl get deployment -n kube-system ingress-nginx-controller

helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
    --namespace kube-system \
    --set controller.service.type=LoadBalancer

## with your nginx ingress controller installed deploy the load balancer controller

eksctl create iamserviceaccount \
    --cluster=arn:aws:eks:us-west-2:807078899029:cluster/ideal-turtle \
    --name=aws-load-balancer-controller \
    --namespace=kube-system \
    --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT}:policy/AWSLoadBalancerControllerIAMPolicy \
    --approve

## Add custom helm repo
helm repo add markchristopherwest https://markchristopherwest.github.io/hello-world-chart

helm pull markchristopherwest/hello-world-chart

helm install frontend markchristopherwest/hello-world-chart

kubectl get pods