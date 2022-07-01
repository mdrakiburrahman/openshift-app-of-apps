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

> We performed the BYOK injection in the onboarder repo

### `kube-arc-data-services-installer-job` Secret - one time generation

> This file is already encrypted and git committed, we only need to redo this unless the Azure Secrets changes for example.

* Grab the Azure Service Principal ID from our env variables
* Encrypt it with the sealed secret public key
* Annotate it for the Secret Controller
* Place in Kustomize overlay path

```bash
export PUBKEY='/workspaces/openshift-app-of-apps/.devcontainer/.keys/seal.crt'
export OVERLAY_PATH='/workspaces/openshift-app-of-apps/kube-arc-data-services-installer-job/kustomize/overlays/arcci/configs'

kubectl create secret \
        generic secret-envs \
        -n azure-arc-kubernetes-bootstrap \
        --from-literal=CLIENT_ID=$spnClientId \
        --from-literal=CLIENT_SECRET=$spnClientSecret \
        --from-literal=SUBSCRIPTION_ID=$subscriptionId \
        --from-literal=TENANT_ID=$spnTenantId \
        --from-literal=AZDATA_USERNAME="boor" \
        --from-literal=AZDATA_PASSWORD="acntorPRESTO!" \
        --dry-run=client \
        --output json \
        | kubectl annotate -f- \
        --local 'sealedsecrets.bitnami.com/managed=true' \
        --dry-run=client \
        --output json \
        | kubeseal --cert $PUBKEY \
        --scope namespace-wide \
        --format=yaml \
        | tee "${OVERLAY_PATH}/azure-spn-secret.yaml"
```

## Kustomize sanity checks

Generate the YAML Argo would end up applying:
```bash
mkdir .temp

# Argo Application
kubectl kustomize /workspaces/openshift-app-of-apps/app-of-apps/kustomize/overlays/arcci > .temp/argo.yaml

# Components
kubectl kustomize /workspaces/openshift-app-of-apps/arc-healthcheck/kustomize/overlays/arcci > .temp/arc-healthcheck.yaml
kubectl kustomize /workspaces/openshift-app-of-apps/machineset/kustomize/overlays/arcci > .temp/machineset.yaml
kubectl kustomize /workspaces/openshift-app-of-apps/metallb/kustomize/overlays/arcci > .temp/metallb.yaml
kubectl kustomize /workspaces/openshift-app-of-apps/sealed-secrets/kustomize/overlays/arcci > .temp/sealed-secrets.yaml
kubectl kustomize /workspaces/openshift-app-of-apps/arc-data-services-onboard/kustomize/overlays/arcci > .temp/arc-data-services-onboard.yaml
kubectl kustomize /workspaces/openshift-app-of-apps/sql-gp-ad-1/kustomize/overlays/arcci > .temp/sql-gp-ad-1.yaml
```

Dry run:
```bash
kubectl apply -f .temp --dry-run=client
# application.argoproj.io/machineset created (dry run)
# machineset.machine.openshift.io/worker-big created (dry run)
# ...
```