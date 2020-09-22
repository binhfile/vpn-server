## Install packages
```bash
apt install openvpn easy-rsa
```
## Make server configurations
```bash
./easyrsa init-pki
./easyrsa build-ca
./easyrsa gen-dh
./easyrsa gen-crl
./easyrsa gen-req vpn-server nopass
./easyrsa sign-req server vpn-server
openssl verify -CAfile pki/ca.crt pki/issued/vpn-server.crt

cp pki/ca.crt /etc/openvpn/server/
cp pki/issued/vpn-server.crt /etc/openvpn/server/
cp pki/private/vpn-server.key /etc/openvpn/server/
cp pki/dh.pem /etc/openvpn/server/
cp -rf pki/crl.pem /etc/openvpn/server/

cat << EOF > /etc/openvpn/server/server.conf
port 8668
proto udp
dev tun
ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/vpn-server.crt
key /etc/openvpn/server/vpn-server.key
dh /etc/openvpn/server/dh.pem
# crl-verify /etc/openvpn/server/crl.pem

server 10.10.0.0 255.255.255.0
ifconfig-pool-persist /etc/openvpn/server/ipp.txt
cipher AES-256-CBC
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA256
auth SHA512
auth-nocache

keepalive 20 60
persist-key
persist-tun
daemon
user root
group root

client-to-client
client-config-dir /etc/openvpn/server/ccd
explicit-exit-notify 1

log-append /var/log/openvpn.log
status /var/log/openvpn-status.log
verb 3
EOF

mkdir -p /etc/openvpn/server/ccd
systemctl start openvpn-server@server
systemctl enable openvpn-server@server
```

## Make client configurations
```bash
./build_client.sh ${client-name}
```
### Configure static ip for client
```bash
echo "ifconfig-push 10.10.0.50 255.255.255.0" > /etc/openvpn/ccd/${client-name}
```

## Create project from scratch

```bash
make-cadir ~/vpn-server
cd ~/vpn-server
cat << EOF >> vars
set_var EASYRSA_REQ_COUNTRY  "VI"
set_var EASYRSA_REQ_PROVINCE  "HN"
set_var EASYRSA_REQ_CITY  "HN"
set_var EASYRSA_REQ_ORG  "TEST"
set_var EASYRSA_REQ_EMAIL  "admin@test.net"
set_var EASYRSA_REQ_OU  "TEST"
set_var EASYRSA_CA_EXPIRE  36500
set_var EASYRSA_CERT_EXPIRE  36500
set_var EASYRSA_REQ_CN  "TEST"
EOF
```
