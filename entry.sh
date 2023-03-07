#!/usr/bin/env bash

set -e

### cert_auth: setup auth passwd for accessing certificate
# Arguments:
#   passwd) Password to access the cert
# Return: openvpn argument to support certificate authentication
cert_auth() { local passwd="$1"
    grep -q "^${passwd}\$" $cert_auth || {
        echo "$passwd" >$cert_auth
    }
    chmod 0600 $cert_auth
}

### vpn_auth: configure authentication username and password
# Arguments:
#   user) user name on VPN
#   pass) password on VPN
# Return: configured auth file
vpn_auth() { local user="$1" pass="$2"
    echo "$user" >$auth
    echo "$pass" >>$auth
    chmod 0600 $auth
}

cleanup() {
    if [[ $openvpn_child ]]; then
        kill SIGTERM "$openvpn_child"
    fi

    sleep 0.5
    rm -f "$modified_config_file"
    echo "info: exiting"
    exit 0
}

for ARGUMENT in "$@"
do
    KEY=$(echo ${ARGUMENT^^} | cut -f1 -d=)
 
    KEY_LENGTH=${#KEY}
    VALUE="${ARGUMENT:$KEY_LENGTH+1}"
    export "$KEY"=$VALUE
done

if [ -z "$REMOTEHOST" -o -z "$REMOTEPORT" ]; then
  echo "Variables REMOTEHOST, REMOTEPORT must be set."; exit;
fi

export VPNTIMEOUT=${VPNTIMEOUT:-5}
export RETRYDELAY=${RETRYDELAY:-10}
export RETRYCOUNT=${RETRYCOUNT:-3}

SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
SCRIPT_PATH="$(cd -- "$SCRIPT_PATH" && pwd)"

origdir="$SCRIPT_PATH/vpn"
dir="$SCRIPT_PATH/ovpn"
auth="$dir/vpn.auth"
cert_auth="$dir/vpn.cert_auth"

iptables -t nat -A PREROUTING -p tcp --dport 3380 -j DNAT --to-destination ${REMOTEHOST}:${REMOTEPORT}
iptables -t nat -A POSTROUTING -j MASQUERADE

# Setup masquerade, to allow using the container as a gateway
for iface in $(ip a | grep eth | grep inet | awk '{print $2}'); do
  iptables -t nat -A POSTROUTING -s "$iface" -j MASQUERADE
done

config_file=$(find $origdir -name '*.conf' -o -name '*.ovpn' 2> /dev/null | sort | shuf -n 1)

if [[ -z $config_file ]]; then
    >&2 echo 'erro: no vpn configuration file found'
    exit 1
fi

echo "info: configuration file: $config_file"

[[ ! -d "$dir" ]] && cp -r "$origdir" "$dir"
	
[[ -e $auth ]] && rm -f "$auth"
[[ -e $cert_auth ]] && rm -f "$cert_auth"

config_file="${config_file/"$origdir"/"$dir"}"

# Remove carriage returns (\r) from the config file
sed -i 's/\r$//g' "$config_file"

[[ "${CERTAUTH:-}" ]] && cert_auth "$CERTAUTH"

[[ "${VPNAUTH:-}" ]] &&
    eval vpn_auth $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $VPNAUTH)

openvpn_args=(
    "--config" "$config_file"
    "--auth-nocache"
    "--cd" "$dir"
    "--pull-filter" "ignore" "ifconfig-ipv6 "
    "--pull-filter" "ignore" "route-ipv6 "
    "--script-security" "2"
    "--up-restart"
    "--verb" "$VPN_LOG_LEVEL"
)

[[ -e $auth ]] && openvpn_args+=("--auth-user-pass" "$auth")
[[ -e $cert_auth ]] && openvpn_args+=("--askpass" "$cert_auth")

echo "info: openvpn_args: ${openvpn_args[@]}"

/usr/bin/gateway-fix.sh &
(
    openvpn "${openvpn_args[@]}" &
    openvpn_child=$!

    wait $openvpn_child
)

# for i in `seq 1 $RETRYCOUNT`
# do
  # echo "------------ VPN Starts ------------"
  # /usr/bin/forticlient
  # echo "------------ VPN exited ------------"
  # sleep $RETRYDELAY
# done