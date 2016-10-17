Generate client certificates for a docker daemon running with TLS verification. It can be used after provisioning an instance with docker machine. Prerequisites: The CA and CA key that the server certificates were generated with.

Usage:
~~~
./generate-client-certs.sh PATH-TO-CA.pem PATH-TO-CA-KEY.pem
~~~

If you used docker machine, you can find these in ~/.docker/machine/certs/ where you created the remote docker host. In that case:
~~~
./generate-client-certs.sh ~/.docker/machine/certs/ca.pem ~/.docker/machine/certs/ca-key.pem
~~~
