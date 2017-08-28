# Create self-signed certificate and custom CA

This is the steps I did to create the certificates needed.

Use 1234 for all the passwords

## Private key

    mkdir ca

    openssl genrsa -aes256 -out ca/ca.key 4096

    chmod 400 ca/ca.key

## The root CA certificate

    openssl req -new -x509 -sha256 -days 730 -key ca/ca.key -out ca/ca.crt

        country 2 letter code: NO
        State or Province Name: Oslo
        Locality Name: Oslo
        Organization Name: Fuse
        Organization Unit Name: Testing
        Common Name: ca.fusetools.com
        Email Address: testing@fusetools.com

    chmod 444 ca/ca.crt

Check results

    openssl x509 -noout -text -in ca/ca.crt


## The receiver node certificate

    mkdir server

    openssl genrsa -out server/receiver.key 2048

    chmod 400 server/receiver.key

    openssl req -new -key server/receiver.key -sha256 -out server/receiver.csr

        country 2 letter code: NO
        State or Province Name: Oslo
        Locality Name: Oslo
        Organization Name: Fuse
        Organization Unit Name: Testing
        Common Name: receiver.fusetools.com
        Email Address: testing@fusetools.com
        challenge password: .
        opt company name: .

    openssl x509 -req -days 365 -sha256 -in server/receiver.csr -CA ca/ca.crt -CAkey ca/ca.key -set_serial 1 -out server/receiver.crt

    chmod 444 server/receiver.crt

    openssl x509 -outform DER -in receiver.crt -out receiverDER.crt

    openssl verify -CAfile ca/ca.crt server/receiver.crt

    openssl pkcs12 -export -in server/receiver.crt -inkey server/receiver.key -out server/receiver.pfx -CAfile ca/ca.crt -chain


## The sender node certificate

    mkdir client

    openssl genrsa -out client/sender.key 2048

    chmod 400 client/sender.key

    openssl req -new -key client/sender.key -out client/sender.csr

        country 2 letter code: NO
        State or Province Name: Oslo
        Locality Name: Oslo
        Organization Name: Fuse
        Organization Unit Name: Testing
        Common Name: sender.fusetools.com
        Email Address: testing@fusetools.com
        challenge password: .
        opt company name: .

    openssl x509 -req -days 365 -sha256 -in client/sender.csr -CA ca/ca.crt -CAkey ca/ca.key -set_serial 2 -out client/sender.crt

    chmod 444 client/sender.crt

    openssl x509 -outform DER -in sender.crt -out senderDER.crt

    openssl verify -CAfile ca/ca.crt client/sender.crt

    openssl pkcs12 -export -in client/sender.crt -inkey client/sender.key -out client/sender.pfx -CAfile ca/ca.crt -chain
