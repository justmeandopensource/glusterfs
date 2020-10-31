#!/bin/bash

echo "[TASK 1] Enable ssh password authentication"
{
  sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
  systemctl reload sshd
} >/dev/null 2>&1

echo "[TASK 2] Set root password"
echo -e "admin\nadmin" | passwd root >/dev/null 2>&1

echo "[TASK 3] Update /etc/hosts file"
cat <<EOF >>/etc/hosts
172.16.16.200   heketi.example.com      heketi
172.16.16.201   gluster-1.example.com   gluster-1
172.16.16.202   gluster-2.example.com   gluster-2
EOF

echo "[TASK 4] Update Apt cache"
apt update >/dev/null 2>&1