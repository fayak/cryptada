Key from ASN1 :

```
openssl asn1parse -genconf <asn1> -out key.der
openssl rsa -in key.der -inform der -text -check
openssl rsa -in key.der -inform der -out key.pem
```
