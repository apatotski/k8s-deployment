#!/bin/bash

#########################
# Install Kubernetes Base Components #
#########################
sudo swapoff -a
sudo sed -i '/^\/swap/s/^/#/' /etc/fstab

sudo apt-get update && sudo apt-get -y upgrade 
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo apt install -y ntp net-tools 


sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
#apt list -a kubeadm
#sudo apt-get install -y kubelet=1.26.1-00 kubeadm=1.26.1-00  kubectl=1.26.1-00
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

#containerd --version
sudo curl -L https://github.com/containerd/containerd/releases/download/v1.6.18/containerd-1.6.18-linux-amd64.tar.gz -o containerd-1.6.18-linux-amd64.tar.gz

sudo tar Cxzvf /usr/local containerd-1.6.18-linux-amd64.tar.gz
sudo rm containerd-1.6.18-linux-amd64.tar.gz

sudo mkdir /etc/containerd
sudo sh -c "containerd config default > /etc/containerd/config.toml"

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /usr/lib/systemd/system/containerd.service

sudo systemctl daemon-reload
sudo systemctl enable --now containerd

#runc --version 
sudo curl -L https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.amd64 -o runc.amd64

sudo install -m 755 runc.amd64 /usr/local/sbin/runc
sudo rm runc.amd64

sudo curl -L https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz -o cni-plugins-linux-amd64-v1.2.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.2.0.tgz
sudo rm cni-plugins-linux-amd64-v1.2.0.tgz


echo "
Kubernetes base instalation is finished succesfuly
"
