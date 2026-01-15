Generate client certificates for a Docker daemon running with TLS verification. This script signs a client certificate with the same CA used to create the daemon's server certificate. It is handy for air-gapped or legacy Docker API deployments, and for machines that still use TLS client auth.

Prerequisites:
- The CA certificate and CA private key used for the daemon's TLS setup.
- `openssl` on your PATH.

Quick start:
```
./generate-client-certs.sh PATH-TO-CA.pem PATH-TO-CA-KEY.pem
```

Outputs:
- `client-key.pem` (private key)
- `client-cert.pem` (client certificate)

These files are created in the current directory by default. Use `-o` to write to a different location.

If you used docker-machine, you can find the CA files in `~/.docker/machine/certs/`:
```
./generate-client-certs.sh ~/.docker/machine/certs/ca.pem ~/.docker/machine/certs/ca-key.pem
```

More options:
```
./generate-client-certs.sh -c ca.pem -k ca-key.pem -o ./out -d 365 -s "/CN=docker-client"
```

Options:
- `-c` Path to CA certificate (ca.pem)
- `-k` Path to CA private key (ca-key.pem)
- `-o` Output directory (default: current directory)
- `-d` Certificate validity in days (default: 365)
- `-s` Subject for the client certificate (default: /CN=docker-client)

Notes:
- The script generates a 4096-bit RSA key by default and sets `extendedKeyUsage = clientAuth`.
- The CA serial is created in a temporary directory and removed automatically.
- The private key is written with restrictive permissions using `umask 077`.

To use the generated cert with Docker:
```
export DOCKER_HOST=tcp://your-docker-host:2376
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=/path/to/output
docker info
```
