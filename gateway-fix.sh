#!/usr/bin/env bash

echo "Check and fix multiple gateways..."

while [ true ]; do

  PPP_IFACE=$(ip route show | grep default | grep ppp* | awk '{ print $5 }')
  EXISTING_DEF_REMOTE_GW=$(ip route show | grep default | grep "$PPP_IFACE" | awk '{ print $3 }')

  if [ -z "$PPP_IFACE"  ]
  then
      # the gateway is OK, there is no default gateway on ppp0 interface
      sleep 5
  else
      # there is a default gateway on ppp interface
      echo "Fixing default gateway"
      route del -net 0.0.0.0 gw "$EXISTING_DEF_REMOTE_GW" netmask 0.0.0.0 dev "$PPP_IFACE"
      route add "$VPNRDPIP" gw "$EXISTING_DEF_REMOTE_GW" dev "$PPP_IFACE"
      echo "Default gateway fixed"
      sleep 1
  fi

done