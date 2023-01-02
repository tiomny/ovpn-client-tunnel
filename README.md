# OpenVPN client tunneler for Docker

## Usage

You can access a predetermined target PC inside the VPN directly from any machine in your LAN.

```bash
# Start the privileged docker container

# -d => detached mode (you can use -it to run it interactively)
# --name => specify a name of the container
# --label => labels are not necessary but can help to identify and filter the containers
# --privileged => this is vital to run VPN containers in a privileged mode (or use caps)
# -p => # use mapped ports to allow access to anyone in your network (using a port on the left side)

# -e "REMOTEHOST=remote_host" => specify target host
# -e "REMOTEPORT=remote_port" => specify target port
# -e "CERTAUTH=[password_to_private_key]" => Optional: specify password to private key file
#  -e "VPNAUTH=[username;password]" => Optional: specify `username;password` pair to VPN

docker run \
  -d \
  --name vpn-test1 \
  --label container-type=vpnclient \
  --label vpn-type=forticlient \
  --label customer=customer-XYZ \
  --privileged \
  -p 51234:3380 \
  -e "REMOTEHOST=remote_host" \
  -e "REMOTEPORT=remote_port" \
  -e "CERTAUTH=[password_to_private_key]" \ #Optional
  -e "VPNAUTH=[username;password]" \ #Optional
  tiomny/ovpn-client-tunnel
```