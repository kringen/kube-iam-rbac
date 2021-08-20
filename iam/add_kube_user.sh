#!/bin/bash

USER_NAME=$1
CERT_FOLDER=$2
CLUSTER_NAME=$3

kubectl config set-credentials $USER_NAME \
	--client-key=$CERT_FOLDER/$USER_NAME.key \
	--client-certificate=$CERT_FOLDER/$USER_NAME.crt \
	--embed-certs=true

kubectl config set-context $USER_NAME@$CLUSTER_NAME --cluster=$CLUSTER_NAME --user=$USER_NAME
