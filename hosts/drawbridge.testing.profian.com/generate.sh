#!/usr/bin/env bash
set -e

openssl ecparam -genkey -name prime256v1 | openssl pkcs8 -topk8 -nocrypt -out server.key
chmod 0600 server.key
openssl pkey -noout -text -in server.key
openssl req -new -config server.conf -key server.key -out server.csr
openssl req -text -in server.csr
openssl x509 -req -days 9999 -CAcreateserial -CA ../steward.testing.profian.com/ca.crt -CAkey ../steward.testing.profian.com/ca.key -in server.csr -out server.crt -extfile server.conf -extensions server_crt
openssl x509 -noout -text -in server.crt
