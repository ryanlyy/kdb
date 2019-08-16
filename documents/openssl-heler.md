# Generate RSA Key and Crt
```
openssl genrsa 2048 > host.key
chmod 400 host.key
openssl req -new -x509 -nodes -sha256 -days 365 -key host.key -out host.cert
```
# Disable DH Cipher Support in Server Hello Handshake Message
https://www.joji.me/en-us/blog/walkthrough-decrypt-ssl-tls-traffic-https-and-http2-in-wireshark/
```
  ssl_ctx = create_ssl_ctx(key_file, cert_file);
  //RYAN: AES256-SHA256; using RSA instead of DH in order to decode it in Wirshark
  SSL_CTX_set_cipher_list(ssl_ctx, "AES256-SHA256");
```
https://stackoverflow.com/questions/18449332/limit-openssl-server-cipher-options

