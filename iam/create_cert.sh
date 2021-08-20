#!/bin/bash

CERT_NAME=$1
GROUP_NAME=$2

$(mkdir -p $CERT_NAME)

echo "Creating Cert for $CERT_NAME"

$(openssl genrsa -out $CERT_NAME/$CERT_NAME.key 2048)

CONFIG=$(cat << EOF
[ req ]
prompt = no
distinguished_name = dn

[ dn ]
CN = $CERT_NAME
O = $GROUP_NAME

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
EOF
)

$(openssl req -config <(echo "$CONFIG") -new -days 365 -key $CERT_NAME/$CERT_NAME.key -nodes -out $CERT_NAME/$CERT_NAME.csr)

BASE64_CSR=$(cat $CERT_NAME/$CERT_NAME.csr | base64 | tr -d "\n")

SIGN_REQ_YAML=$(cat <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $CERT_NAME
spec:
  request: $BASE64_CSR
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400  # one day
  usages:
  - client auth
EOF
)

echo "$SIGN_REQ_YAML"

OUTPUT=$(echo "$SIGN_REQ_YAML" | kubectl apply -f -)

echo $OUTPUT

OUTPUT=$(kubectl certificate approve $CERT_NAME)

echo $OUTPUT

OUTPUT=$(kubectl get csr $CERT_NAME -o jsonpath='{.status.certificate}'| base64 -d > $CERT_NAME/$CERT_NAME.crt)

echo $OUTPUT

