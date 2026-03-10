#!/bin/bash
# Log all output to a file for easy debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting system update and K3s installation..."

apt-get update -y
apt-get upgrade -y

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo "Retrieved Public IP: $PUBLIC_IP"

# We disable traefik and explicitly add the Public IP to the TLS Certificate SAN list
# This prevents the x509 certificate error when connecting via kubectl remotely
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --tls-san $PUBLIC_IP" sh -

mkdir -p /home/ubuntu/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# Export KUBECONFIG to bashrc
echo 'export KUBECONFIG=/home/ubuntu/.kube/config' >> /home/ubuntu/.bashrc

echo "K3s Installation Completed Successfully!"