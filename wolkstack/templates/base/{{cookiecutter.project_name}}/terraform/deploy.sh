#!/bin/bash
terraform init
terraform apply -auto-approve

mv -f wolkstack_kubeconfig* wolkstack_kubeconfig
cp -f wolkstack_kubeconfig .kubeconfig

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.3/cert-manager.crds.yaml