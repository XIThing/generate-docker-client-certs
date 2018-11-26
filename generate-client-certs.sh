#!/bin/bash
# Generate client certificates for a docker host.
# Command line params:
# - $1 - Path to ca.pem
# - $2 - Path to ca-key.pem

if [ "$1" = "" ] || [ "$2" = "" ]; then
    echo "Please provide paths to the ca.pem and ca-key.pem files."
    exit 2
fi

echo 01 > ca.srl
cp "$1" ca.pem
cp "$2" ca-key.pem

openssl genrsa -out client-key.pem
openssl req -new -key client-key.pem -out client.csr

echo 'extendedKeyUsage = clientAuth' > extfile.cnf

openssl x509 -req -days 365 \
    -in client.csr \
    -out client-cert.pem \
    -CA ca.pem \
    -CAkey ca-key.pem \
    -extfile extfile.cnf

# Cleanup
rm ca.srl ca.pem ca-key.pem client.csr extfile.cnf

