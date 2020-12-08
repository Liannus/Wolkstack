#!/bin/bash
terraform init
terraform apply -auto-approve

mv -f kubeconfig_wolkstack* kubeconfig_wolkstack 
cp -f kubeconfig_wolkstack .kubeconfig

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.3/cert-manager.crds.yaml