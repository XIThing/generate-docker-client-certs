#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage:
  ./generate-client-certs.sh <ca.pem> <ca-key.pem>
  ./generate-client-certs.sh -c <ca.pem> -k <ca-key.pem> [-o <outdir>] [-d <days>] [-s <subject>]

Options:
  -c  Path to CA certificate (ca.pem)
  -k  Path to CA private key (ca-key.pem)
  -o  Output directory (default: current directory)
  -d  Certificate validity in days (default: 365)
  -s  Subject for the client certificate (default: /CN=docker-client)
  -h  Show this help
EOF
}

if ! command -v openssl >/dev/null 2>&1; then
    echo "openssl not found on PATH."
    exit 127
fi

ca_cert=""
ca_key=""
out_dir="."
days="365"
subject="/CN=docker-client"

if [ "$#" -ge 1 ] && [[ "$1" == -* ]]; then
    while getopts ":c:k:o:d:s:h" opt; do
        case "$opt" in
            c) ca_cert="$OPTARG" ;;
            k) ca_key="$OPTARG" ;;
            o) out_dir="$OPTARG" ;;
            d) days="$OPTARG" ;;
            s) subject="$OPTARG" ;;
            h) usage; exit 0 ;;
            *) usage; exit 2 ;;
        esac
    done
else
    if [ "$#" -lt 2 ]; then
        usage
        exit 2
    fi
    ca_cert="$1"
    ca_key="$2"
fi

if [ -z "$ca_cert" ] || [ -z "$ca_key" ]; then
    usage
    exit 2
fi

if [ ! -r "$ca_cert" ] || [ ! -r "$ca_key" ]; then
    echo "CA certificate or key not readable."
    exit 2
fi

mkdir -p "$out_dir"

tmp_dir="$(mktemp -d)"
cleanup() {
    rm -rf "$tmp_dir"
}
trap cleanup EXIT

umask 077

key_path="$out_dir/client-key.pem"
cert_path="$out_dir/client-cert.pem"
csr_path="$tmp_dir/client.csr"
extfile_path="$tmp_dir/extfile.cnf"
serial_path="$tmp_dir/ca.srl"

openssl genrsa -out "$key_path" 4096
openssl req -new -key "$key_path" -out "$csr_path" -subj "$subject"

printf '%s\n' 'extendedKeyUsage = clientAuth' > "$extfile_path"

openssl x509 -req -days "$days" \
    -in "$csr_path" \
    -out "$cert_path" \
    -CA "$ca_cert" \
    -CAkey "$ca_key" \
    -extfile "$extfile_path" \
    -CAcreateserial \
    -CAserial "$serial_path"
