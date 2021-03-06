#!/usr/bin/env bash

# init kubernetes 
kubeadm init --token 123456.1234567890123456 --token-ttl 0 --pod-network-cidr=172.16.0.0/16 --apiserver-advertise-address=192.168.20.10

# config for master node only 
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# calico install
# kubectl apply -f https://raw.githubusercontent.com/gasida/NDKS/main/5/calico-vxlan.yaml
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# calicoctl install v3.21.2
# curl -o calicoctl -O -L  "https://github.com/projectcalico/calicoctl/releases/download/v3.20.2/calicoctl"
curl -o calicoctl -O -L  "https://github.com/projectcalico/calicoctl/releases/download/v3.21.2/calicoctl"
chmod +x calicoctl && mv calicoctl /usr/bin

# etcdctl install
apt install etcd-client -y

# source bash-completion for kubectl kubeadm
source <(kubectl completion bash)
source <(kubeadm completion bash)

## Source the completion script in your ~/.bashrc file
echo 'source <(kubectl completion bash)' >> /etc/profile
echo 'source <(kubeadm completion bash)' >> /etc/profile

## alias kubectl to k 
echo 'alias k=kubectl' >> /etc/profile
echo 'complete -F __start_kubectl k' >> /etc/profile

## kubectx kubens install
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx

## kube-ps1 install
git clone https://github.com/jonmosco/kube-ps1.git /root/kube-ps1
cat <<"EOT" >> ~/.bash_profile
source /root/kube-ps1/kube-ps1.sh
KUBE_PS1_SYMBOL_ENABLE=false
function get_cluster_short() {
  echo "$1" | cut -d . -f1
}
KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
KUBE_PS1_SUFFIX=') '
PS1='$(kube_ps1)'$PS1
EOT
kubectl config rename-context "kubernetes-admin@kubernetes" "istio-k8s"

## kube-tail install
curl -O https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail
chmod 744 kubetail && mv kubetail /usr/bin
curl -o /root/kubetail.bash https://raw.githubusercontent.com/johanhaleby/kubetail/master/completion/kubetail.bash
cat <<EOT >> ~/.bash_profile
source /root/kubetail.bash
EOT

# Install Helm v3
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# bash
source <(helm completion bash)
echo 'source <(helm completion bash)' >> /etc/profile
