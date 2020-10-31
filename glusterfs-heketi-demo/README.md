## Setup Gluster cluster and Heketi RESTful layer playground
Follow this documentation to set up and play with GlusterFS through Heketi interface

#### Vagrant Environment
When you do **vagrant up** inside vagrant-infra directory of this repo, you will end up with below environment.
|Role|FQDN|IP|OS|RAM|CPU|
|----|----|----|----|----|----|
|Heketi Node|heketi.example.com|172.16.16.200|Ubuntu 20.04|1G|1|
|Gluster Node 1|gluster-1.example.com|172.16.16.201|Ubuntu 20.04|1G|1|
|Gluster Node 2|gluster-2.example.com|172.16.16.202|Ubuntu 20.04|1G|1|

> Root password for all the VMs is **admin**

> Run all commands as root user unles otherwise specified

## Gluster Nodes Setup (on gluster-1 and gluster-2)
#### Attach another hard disk to VirtualBox virtual machines
Whatever hypervisor you are using, just make sure to have a space disk attached to both gluster-1 and gluster-2.

#### Install glusterfs
```
{
  apt install -y glusterfs-server
  systemctl enable --now glusterd
}
```

## Heketi Setup (on heketi node)
#### Download Heketi binaries
```
{
  cd /tmp
  wget https://github.com/heketi/heketi/releases/download/v10.1.0/heketi-v10.1.0.linux.amd64.tar.gz
  tar zxf heketi*
  mv heketi/{heketi,heketi-cli} /usr/local/bin/
}
```

#### Set up user account for heketi
```
{
  groupadd -r heketi
  useradd -r -s /sbin/nologin -g heketi heketi
  mkdir {/var/lib,/etc,/var/log}/heketi
}
```

#### Create ssh passwordless access to Gluster nodes
```
{
  ssh-keygen -f /etc/heketi/heketi_key -t rsa -N ''
  for node in gluster-1 gluster-2; do
    ssh-copy-id -i /etc/heketi/heketi_key.pub root@$node
  done
}
```

#### Configure heketi
```
cp /tmp/heketi/heketi.json /etc/heketi/
```
Edit **/etc/heketi/heketi.json**, change executor to ssh and update sshexec options as shown below
```
	"executor": "ssh", 

	"_sshexec_comment": "SSH username and private key file information",
	"sshexec": {
  	  "keyfile": "/etc/heketi/heketi_key", 
  	  "user": "root", 
  	  "port": "22", 
  	  "fstab": "/etc/fstab" 
	},
```
> Refer the below YouTube video for correct configuration. Otherwise heketi service will fail

#### Update permissions on heketi directories
```
chown -R heketi:heketi {/var/lib,/etc,/var/log}/heketi
```

#### Create systemd unit file for heketi
```
cat <<EOF >/etc/systemd/system/heketi.service
[Unit]
Description=Heketi Server

[Service]
Type=simple
WorkingDirectory=/var/lib/heketi
EnvironmentFile=-/etc/heketi/heketi.env
User=heketi
ExecStart=/usr/local/bin/heketi --config=/etc/heketi/heketi.json
Restart=on-failure
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target
EOF
```

#### Enable and start heketi service
```
{
  systemctl daemon-reload
  systemctl enable --now heketi
}
```
#### Quick verification that heketi is running
```
curl localhost:8080/hello; echo
```
#### Export environment variables for heketi-cli
```
export HEKETI_CLI_USER=admin
export HEKETI_CLI_KEY=secretpassword
```

#### Play with heketi-cli
Use help commands to start playing with heketi to use GlusterFS. Or watch my YouTube video
