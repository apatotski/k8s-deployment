#!/bin/bash
#Install Calico

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/tigera-operator.yaml

curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/custom-resources.yaml -O

sed -i -e '/cidr:/s/\([0-9]\+.\)\{3\}[0-9]\+\/[0-9]\+/10.244.0.0\/16/' custom-resources.yaml

sleep 30
echo "Please wait 30 sec for tigera-operator starts up"

kubectl create -f custom-resources.yaml

cd /usr/local/bin/
sudo curl -L https://github.com/projectcalico/calico/releases/download/v3.24.1/calicoctl-linux-amd64 -o calicoctl

sudo chmod +x calicoctl
cd ~/
