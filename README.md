# Hello World

Hello World is a Web app powered by Mongo that lives in Kuberenetes.


aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)


