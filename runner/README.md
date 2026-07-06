# This readme file mostly contains notes regarding the infrastrucutre

[Backend/Frontend CI/CD] Workflow

- `deploy.yaml` workflow starts
- **Job #1** -> build, on cloud runner
- Checkout repo
- Login to ghcr
- Build and push
- **Job #2** -> deploy, on arc runner
- Install Kubectl
- Kubectl will use ~/.kube/config provided to the arc-runners chart through a k8s secret
- `kubectl rollout restart deployment/{name}`

[Infra CI] Validate Workflow
- `validate.yaml` workflow starts
- uses github hosted runner
- checkout repo, fetch terraform and helm
- validate terraform
- lint helm

[Infra CD] Deploy Workflow

- `deploy.yaml` workflow starts
- a RunnerSet resource is created, with a Runner pod which talks to the GitHub actions API
- [1] Checkout Repo - download git branch to pod's filesystem
- [2] Setup Node - downloads Node, needed by Terraform
- [3] Setup Terraform - downloads Terraform
- sets up Terraform
- Terraform needs Kubernetes provider
- uses ~/.kube/config provided to the chart through a k8s secret
- the secret's certificates are b64 hardcoded and the server url is `https://<minikube-ip>:8443`
- Terraform needs Helm provider
- no need for any authorization for Helm
- Needs to authorize for Terraform Cloud => github secret token generated from app.terraform.io
- [4] Terraform Init, uses a remote backend (`providers.tf - backend "remote"`)
- [5] Terraform Apply on the remote
- charts can't be local anymore, so I upload them on ghcr.io (*)
- `chart   = "oci://ghcr.io/intens-intern-project/backend"`
- `version = "0.1.4"`
- all charts must have this
- terraform apply updates the state

[Pushing new helm charts] (*)

- `helm registry login ghcr.io -u magley -p <PAT>`
- PAT is a classic GitHub token with read/write packages permissions 
- `helm package ./helmcharts/backend`
- `helm push ./backend-{VERSION}.tgz oci://ghcr.io/intens-intern-project`

[Creating the ARC]

- install an ARC controller which talks to GitHub API and creates runners
- ARC runners needs a classic GitHub token to manage org and repo
- Create a K8s secret for the token         -> safe access to the token
- Create a Runner Group in the GitHub org   -> so we have one runner scaler for entire org
- Create a Service Account for the runners  -> default SA for runners can't do anything (kubectl)
- Create a Secret for Kube config           -> so kubectl knows which cluster to talk to
    - base64 for all certificates, hardcode them instead of providing a non-portable path
    - server is https://<minikube-ip>:8443
- install ARC runner scale set              -> with the provided secrets, refs and service accounts

# Notes on setting up a self hosted k8s runner (ARC) for this organization 

1. Install an ARC controller _(per cluster)_

```sh
NAMESPACE="arc-systems"
INSTALLATION_NAME="arc"
helm install ${INSTALLATION_NAME} \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller
```

_The ARC controller manages ARC runners in a cluster._ 

2. Create a Classic Token _(per cluster)_

- Go to user settings
- Click create a token (classic)
- Set `org:admin` and `repo` permissions
- Copy the token

_This token is used to authenticate ARC runners against GitHub._

3. Create a Kubernetes secret for the token _(per cluster)_

```sh
NAMESPACE="arc-runners"
GITHUB_PAT="<token goes here>"
SECRET_NAME="github-auth"
kubectl create secret generic ${SECRET_NAME} \
  --namespace ${NAMESPACE} \
  --from-literal=github_token=${GITHUB_PAT}
```

_ARC runners will use this secret to access the token._

4. Create a Runner Group in the Github Organization _(per org)_

- Go to organization settings
- Go to Actions -> Runner groups
- Create a group named `self-hosted-runner-group`
- Grant permission to all repositories and workflows

_This is used to group multiple GitHub runners together._
_The ARC runners will "bind" to this group._

5. Create a Service Account with the required roles _(per org)_

Because by default the helm chart puts the runners in a Service Account with no permissions.

```sh
kubectl apply -f ./rbac.yaml
```

_When installing an ARC controller, it creates a service account with no permissions._
_We need permissions to be able to read/write/etc. the different Kuberenetes resources_
_from inside those runners._

6. Create a secret for kube config

The certificates will be hardcoded as base64 because otherwise it'll fail to resolve
a relative path under a different home path.

```sh
base64 -w0 ~/.minikube/ca.crt
base64 -w0 ~/.minikube/profiles/minikube/client.crt
base64 -w0 ~/.minikube/profiles/minikube/client.key
```

```yaml
# ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    #certificate-authority: <remove this>
    certificate-authority-data: <paste contents of ca.crt base64>
    ...
    server: https://<minikube ip>:8443 # This is also different
...
users:
- name: minikube
  user:
    #client-certificate: <remove this>
    client-certificate-data: <paste contents of client.crt base64>
    #client-key: <remove this>
    client-key-data: <paste contents of client.key>
```

```sh
NAMESPACE="arc-runners"
SECRET_NAME="kubeconfig"
kubectl create secret generic ${SECRET_NAME} \
    --from-file=config=$HOME/.kube/config \
    --namespace ${NAMESPACE}
```

_Terraform needs `.kube/config`, to be accessible from an ARC runner_
_so we put it in a secret and mount it inside the pod._

7. Create a runner scale set _(per org)_

```sh
NAMESPACE="arc-runners"
VALUES_FILE="./values.yaml"
INSTALLATION_NAME="iip-org-runner"
helm install ${INSTALLATION_NAME} \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set \
    --namespace ${NAMESPACE} \
    -f ${VALUES_FILE}
```

_This is what manages ARC runners while a workflow is running._
_Its configuration is in ./values.yaml, used to give it the key for Github,_
_the Service Account for the Kubernetes cluster, and also tell it which GitHub_
_organization to manage._

8. Use the runner in workflows _(per workflow)_

```yml
name: Test workflow
on:
  workflow_dispatch:

jobs:
  first-and-only-job:
    runs-on: iip-org-runner # This is `runnerScaleSetName` from values.yaml
    steps:
    - run: echo "Hello from local runner"
```

9. Changes

- If you change `values.yaml`:

```sh
NAMESPACE="arc-runners"
VALUES_FILE="./values.yaml"
INSTALLATION_NAME="iip-org-runner"
helm upgrade ${INSTALLATION_NAME} \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set \
    --namespace ${NAMESPACE} \
    -f ${VALUES_FILE}
```

Same command as in step 7, but it's `helm upgrade` instead of `helm install` because the
ARC runner scale set chart already exists by now.

- If you change `~/.kube/config`:

```sh
NAMESPACE="arc-runners"
SECRET_NAME="kubeconfig"
kubectl delete secret ${SECRET_NAME} --namespace ${NAMESPACE}
```

```sh
NAMESPACE="arc-runners"
SECRET_NAME="kubeconfig"
kubectl create secret generic ${SECRET_NAME} \
    --from-file=config=$HOME/.kube/config \
    --namespace ${NAMESPACE}
```