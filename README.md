# OpenVPN client tunneler for Docker

Creates a tunnel to a resource (`REMOTEHOST`:`REMOTEPORT`) in virtual private network in a docker container.

User can access the specified resource using `dockerhost`:`publish_port`, e. g. to Remote Desktop providing `REMOTEPORT=3389`, `-p 53389:3380` with RDP client and remote address `localhost:53389`.

## Usage

```bash
docker run \
  -d \
  --name ovpn-client-tunnel \
  --label container-type=vpnclient \
  --label vpn-type=openvpn \
  --label customer=customer-XYZ \
  --privileged \
  -v {path_to_vpn_configuration}:/vpn \
  -p {publish_port}:3380 \
  -e "REMOTEHOST={remote_host}" \
  -e "REMOTEPORT={remote_port}" \
  -e "CERTAUTH=[password_to_private_key]" \ #Optional
  -e "VPNAUTH=[username;password]" \ #Optional
  tiomny/ovpn-client-tunnel
```
### Parameters

| Switch | Description |
| --- | ----------- |
| -d | detached mode (you can use -it to run it interactively) |
| --name | specify a name of the container |
| --label | labels are not necessary but can help to identify and filter the containers |
| --privileged | this is vital to run VPN containers in a privileged mode (or use caps) |
| -p {publish_port}:3380 | port used for accessing resource |
| -v {path_to_vpn_configuration}:/vpn | Folder containing ovpn or conf file |
| | | 
| -e "REMOTEHOST=remote_host" | specify target host |
| -e "REMOTEPORT=remote_port" | specify target port |
| -e "CERTAUTH=[password_to_private_key]" | _Optional_: specify password to private key file |
| -e "VPNAUTH=[username;password]" | _Optional_: specify `username;password` pair to VPN server |
