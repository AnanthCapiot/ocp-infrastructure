#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 ENV"
    exit 1
fi

ENV=$1

echo "Input environment is:${ENV}"

oc project ${ENV}-mongodb && \

oc create -f ../templates/${ENV}-mongodb-configmap.yml  

oc new-app --name=${ENV}-mongodb -e MONGODB_USER=mongodb -e MONGODB_PASSWORD=mongodb -e MONGODB_DATABASE=${ENV}-mongodb -e MONGODB_ADMIN_PASSWORD=mongodb registry.access.redhat.com/rhscl/mongodb-26-rhel7 && \

oc rollout pause dc/${ENV}-mongodb && \

oc env dc/${ENV}-mongodb --from=configmap/${ENV}-mongodb-config-map && \

oc create -f ../templates/${ENV}-mongodb-pvc.yml && \

oc set volume dc/${ENV}-mongodb --add --type=persistentVolumeClaim --name=${ENV}-mongodb-pv --claim-name=${ENV}-mongodb-pvc --mount-path=/data --containers=* && \

oc rollout resume dc/${ENV}-mongodb  
