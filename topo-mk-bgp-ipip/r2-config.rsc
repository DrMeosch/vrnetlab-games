/ip pool
add name=dhcp_pool0 ranges=192.168.97.1-192.168.97.253

/ip dhcp-server
add address-pool=dhcp_pool0 interface=ether3 name=dhcp1

/routing bgp template
set default as=65531

/routing table
add fib name=rtable-special

/interface list
add name=WAN

/interface list member
add interface=ether1 list=WAN

/ip address
add address=192.168.97.254/24 interface=ether3 network=192.168.97.0

/ip dhcp-client
add add-default-route=no interface=ether2

/ip dhcp-server network
add address=192.168.97.0/24 dns-server=8.8.8.8 gateway=192.168.97.254

/ip firewall address-list
add address=192.168.97.0/24 list=r2-bgp-networks

/user ssh-keys
add user=admin key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJXI5cFnmL8MrvsJlbPr1oEpNWO2uKithOkEuNKIQQI0vZdP4RELEs1RciQLfwwpYgQzu4S2+W2P9W8TUCjB/bKvEuzC+Y1/PYJuAoGY6rAum6PjA4GG6eTp50/fl9uI5Xvhtd7o2zGK21u8rJlzq/v4YTMEKYKZ0w+zbGkXXjnzPfZBmIk/sYGl5UPm369LdmIx2ymFamkX6p6sJnNYZXrKDFEXaEUlH8tl9llj5ToSIq1al3S8eIc1dRt/D91sPWzYmJT6SlC9pJQIoxeaz8h6jWCYg+0NzWwRHhrq1O5akK76QI/7/NH52/yZvtsdCmN+MQu1t9Sy1VrX3ym/7pzBU/Cqg8hNa2JEkbMYhhwoUT5Lbh7sizTOZesag+2POHLtZa00Oo94U6w3l7Qnazpl7+A1+wDqjtJr5QxJvBh1PWhl2FDAryMd0VeWodDXAr7yk68wCVRFe7fFXrJXaoc889h7jtw3Wb6hJ3UJKueBQxgcLhS23s55nhK+CywDc="

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
add chain=input action=drop in-interface-list=WAN
add action=accept chain=forward comment="defconf: accept in ipsec policy" ipsec-policy=\
    in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" ipsec-policy=\
    out,ipsec log-prefix=filter-forward-out-accept-ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-mark=\
    no-mark connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="defconf: accept established,related, untracked" \
    connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid

/ip firewall nat
add action=masquerade chain=srcnat ipsec-policy=out,none out-interface-list=WAN

/ip route
add dst-address=0.0.0.0/0 gateway=172.31.255.29
add distance=20 dst-address=192.168.97.0/24 gateway=ether3 routing-table=rtable-special

/interface ipip
add allow-fast-path=no \
    ipsec-secret="Aeph6see biToh0oo Quai5shu eesh5Ay2 aRa8Zaem OF2eicei Cho1daip Sa5Eith3" \
    local-address=10.241.10.253 name=ipip-tunnel1 remote-address=10.241.10.254

/ip route
add dst-address=192.168.100.0/24 gateway=ipip-tunnel1

/interface bridge
add name=bridge-lo0

/ip address
add address=192.168.200.254/24 interface=bridge-lo0 network=192.168.200.0

/routing bgp connection
add disabled=no listen=yes local.role=ebgp name=toR1 output.network=r2-bgp-networks \
    remote.address=192.168.100.254 local.address=192.168.200.254 routing-table=rtable-special \
    templates=default multihop=yes

/routing rule
add action=lookup-only-in-table table=rtable-special src-address=192.168.97.253/32