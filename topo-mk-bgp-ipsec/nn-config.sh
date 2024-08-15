ip route del default
ip link set eth1 up

dhclient eth1

# waiting for the network to be ready
while ! ping -c 1 8.8.8.8; do
  sleep 1
done

ssh-keygen -A -v
mkdir -p /root/.ssh
chmod 600 /root/.ssh
cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
chmod 644 /root/.ssh/authorized_keys
/usr/sbin/sshd -D -o ListenAddress=0.0.0.0 -o PermitRootLogin=yes -o PubkeyAuthentication=yes