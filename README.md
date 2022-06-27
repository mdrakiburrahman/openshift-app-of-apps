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


## Kustomize sanity checks

Generate the YAML Argo would end up applying:
```bash
mkdir .temp

# Argo Application
kubectl kustomize /workspaces/openshift-app-of-apps/app-of-apps/kustomize/overlays/arcci > .temp/argo.yaml

# Components
kubectl kustomize /workspaces/openshift-app-of-apps/machineset/kustomize/overlays/arcci > .temp/machineset.yaml
kubectl kustomize /workspaces/openshift-app-of-apps/metallb/kustomize/overlays/arcci > .temp/metallb.yaml
```

Dry run:
```bash
kubectl apply -f .temp --dry-run=client
# application.argoproj.io/machineset created (dry run)
# machineset.machine.openshift.io/worker-big created (dry run)
```