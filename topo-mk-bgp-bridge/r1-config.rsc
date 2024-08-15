/ip pool
add name=dhcp_pool0 ranges=10.241.10.1-10.241.10.253
add name=dhcp_pool1 ranges=10.241.20.1-10.241.20.253
/ip dhcp-server
add address-pool=dhcp_pool0 interface=ether2 name=dhcp1
add address-pool=dhcp_pool1 interface=ether3 name=dhcp2
/ip address
add address=10.241.10.254/24 interface=ether2 network=10.241.10.0
add address=10.241.20.254/24 interface=ether3 network=10.241.20.0
/ip dhcp-server network
add address=10.241.10.0/24 dns-server=8.8.8.8 gateway=10.241.10.254
add address=10.241.20.0/24 dns-server=8.8.8.8 gateway=10.241.20.254
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1
/ip route
add dst-address=0.0.0.0/0 gateway=172.31.255.29
/user ssh-keys
add user=admin key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJXI5cFnmL8MrvsJlbPr1oEpNWO2uKithOkEuNKIQQI0vZdP4RELEs1RciQLfwwpYgQzu4S2+W2P9W8TUCjB/bKvEuzC+Y1/PYJuAoGY6rAum6PjA4GG6eTp50/fl9uI5Xvhtd7o2zGK21u8rJlzq/v4YTMEKYKZ0w+zbGkXXjnzPfZBmIk/sYGl5UPm369LdmIx2ymFamkX6p6sJnNYZXrKDFEXaEUlH8tl9llj5ToSIq1al3S8eIc1dRt/D91sPWzYmJT6SlC9pJQIoxeaz8h6jWCYg+0NzWwRHhrq1O5akK76QI/7/NH52/yZvtsdCmN+MQu1t9Sy1VrX3ym/7pzBU/Cqg8hNa2JEkbMYhhwoUT5Lbh7sizTOZesag+2POHLtZa00Oo94U6w3l7Qnazpl7+A1+wDqjtJr5QxJvBh1PWhl2FDAryMd0VeWodDXAr7yk68wCVRFe7fFXrJXaoc889h7jtw3Wb6hJ3UJKueBQxgcLhS23s55nhK+CywDc="

/ip firewall address-list
add address=10.241.20.0/24 list=r1-bgp-networks

/interface list
add name=WAN

/interface list member
add interface=ether1 list=WAN

/ip firewall nat
add action=masquerade chain=srcnat ipsec-policy=out,none out-interface-list=WAN

/ip route
add dst-address=0.0.0.0/0 gateway=172.31.255.29

/routing bgp connection
add disabled=no listen=yes local.role=ebgp name=toR2 output.default-originate=always \
    .network=r1-bgp-networks remote.address=10.241.10.253 templates=default

/ip firewall filter
add action=accept chain=input comment="defconf: accept established,related,untracked" \
    connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment="defconf: accept to local loopback (for CAPsMAN)" \
    dst-address=127.0.0.1
add action=accept chain=input protocol=ipsec-esp
add action=accept chain=input protocol=ipsec-ah
add action=accept chain=input dst-port=500,4500 protocol=udp
add action=accept chain=input dst-port=22 protocol=tcp
add action=accept chain=forward comment="defconf: accept in ipsec policy" ipsec-policy=\
    in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" ipsec-policy=\
    out,ipsec log-prefix=filter-forward-out-accept-ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-mark=\
    no-mark connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="defconf: accept established,related, untracked" \
    connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid

