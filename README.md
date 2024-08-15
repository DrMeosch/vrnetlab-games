# vrnetlab-games

## Installation

You need docker and containerlab already installed.

Then install vrnetlab routeros images.

```
git clone https://github.com/hellt/vrnetlab
cd vrnetlab/routeros
wget https://download.mikrotik.com/routeros/7.15.3/chr-7.15.3.vmdk.zip && unzip chr-7.15.3.vmdk.zip
make all
```

## Basic usage

Use a topology of your choice:

```
cd topo-mk-bgp-ipsec
sudo ip link add name br-clab type bridge
sudo containerlab -t topo.yaml deploy
ssh root@clab-bgp-ipsec-n2
ssh admin@clab-bgp-ipsec-R1
```

Inspect traffic on the bridge on the host machine:

```
sudo tcpdump -i br-clab -vvvn
```