#!/bin/bash
CLIENT=$1
./easyrsa gen-req ${CLIENT} nopass
./easyrsa sign-req client ${CLIENT}
openssl verify -CAfile pki/ca.crt pki/issued/${CLIENT}.crt

cat << EOF > ${CLIENT}.ovpn
client
dev tun
proto udp
remote binhfile.ddns.net 8668
resolv-retry infinite
nobind
persist-key
remote-cert-tls server
cipher AES-256-CBC
verb 3
key-direction 1

EOF

echo '<ca>' >> ${CLIENT}.ovpn 
cat pki/ca.crt >> ${CLIENT}.ovpn 
echo '</ca>' >> ${CLIENT}.ovpn 
echo '<cert>' >> ${CLIENT}.ovpn 
cat pki/issued/${CLIENT}.crt >> ${CLIENT}.ovpn 
echo '</cert>' >> ${CLIENT}.ovpn 
echo '<key>' >> ${CLIENT}.ovpn 
cat pki/private/${CLIENT}.key >> ${CLIENT}.ovpn 
echo '</key>' >> ${CLIENT}.ovpn
