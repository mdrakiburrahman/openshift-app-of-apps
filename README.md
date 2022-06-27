# Openshift-app-of-apps

Learning how to bootstrap OpenShift on vSphere with ArgoCD App of Apps:
* https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping
* https://github.com/argoproj/argocd-example-apps
* https://medium.com/dzerolabs/turbocharge-argocd-with-app-of-apps-pattern-and-kustomized-helm-ea4993190e7c
* https://github.com/bitnami-labs/sealed-secrets
* https://codefresh.io/blog/applied-gitops-with-kustomize
* https://github.com/hseligson1/kustomize-gitops-example
* https://github.com/openshift/openshift-gitops-examples/blob/master/argocd/README.md#Machine-Sets

> This repo is the source of truth for OpenShift after the bare minimal infra is setup with OpenShift IPI and Terraform.

## Bitnami Sealed Secret pre-req

To avoid having multiple sealed secrets per Cluster to pull out, we generate our own, and can put it in AKV someday:
```bash
export PRIVATEKEY="seal.key"
export PUBLICKEY="seal.crt"
export NAMESPACE="sealed-secrets"
export SECRETNAME="seal-cert"

# Go into secret path that is NOT to be committed to git
cd /workspaces/openshift-app-of-apps/.devcontainer/.keys

kubectl create namespace "$NAMESPACE"
# namespace/sealed-secrets created
openssl req -x509 -nodes -newkey rsa:4096 -keyout "$PRIVATEKEY" -out "$PUBLICKEY" -subj "/CN=sealed-secret/O=sealed-secret"
# Generating a RSA private key
# .......................................................................................................................................++++
# ................................................++++
# writing new private key to 'seal.key'
# -----
kubectl -n "$NAMESPACE" create secret tls "$SECRETNAME" --cert="$PUBLICKEY" --key="$PRIVATEKEY"
# secret/seal-cert created

# Label it for BYOK: https://github.com/bitnami-labs/sealed-secrets/blob/main/docs/bring-your-own-certificates.md#create-a-tls-k8s-secret-using-your-recently-created-rsa-key-pair
kubectl -n "$NAMESPACE" label secret "$SECRETNAME" sealedsecrets.bitnami.com/sealed-secrets-key=active
# secret/seal-cert labeled
```

## Kustomize sanity checks

Generate the YAML Argo would end up applying:
```bash
mkdir .temp

# Argo Application
kubectl kustomize /workspaces/openshift-app-of-apps/app-of-apps/kustomize/overlays/arcci > .temp/argo.yaml

# Components
kubectl kustomize /workspaces/openshift-app-of-apps/sealed-secrets/kustomize/overlays/arcci > .temp/sealed-secrets.yaml
kubectl kustomize /workspaces/openshift-app-of-apps/machineset/kustomize/overlays/arcci > .temp/machineset.yaml
kubectl kustomize /workspaces/openshift-app-of-apps/metallb/kustomize/overlays/arcci > .temp/metallb.yaml
```

Dry run:
```bash
kubectl apply -f .temp --dry-run=client
# application.argoproj.io/machineset created (dry run)
# machineset.machine.openshift.io/worker-big created (dry run)
# ...
```