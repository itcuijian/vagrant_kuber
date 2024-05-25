# kubeadm join
kubeadm join 10.0.0.30:6443 --node-name node1 --token 22jc7y.1fb43gey9nrcn7gm \
        --discovery-token-ca-cert-hash sha256:dfeb6172ebcc612d68ed9fa84ddb4d323c8f6f0d7f7ec63d7c54fb042d6dadd6

kubeadm join 10.0.0.30:6443 --node-name node2 --token 22jc7y.1fb43gey9nrcn7gm \
        --discovery-token-ca-cert-hash sha256:dfeb6172ebcc612d68ed9fa84ddb4d323c8f6f0d7f7ec63d7c54fb042d6dadd6
