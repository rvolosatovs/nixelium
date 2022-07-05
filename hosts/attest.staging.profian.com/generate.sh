#!/usr/bin/env bash
set -e

openssl ecparam -genkey -name prime256v1 | openssl pkcs8 -topk8 -nocrypt -out ca.key
chmod 0600 ca.key
openssl pkey -noout -text -in ca.key
openssl req -new -x509 -config ca.conf -key ca.key -out ca.crt
openssl x509 -noout -text -in ca.crt
