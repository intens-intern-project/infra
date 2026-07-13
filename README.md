# Infrastructure as Code

**Repo structure**

The services are deployed on Kubernetes using Helm charts
in `/helmcharts`. Deployment is automated using Terraform
whose configuration is in `/terraform`.

Changes pushed
to [`frontend:main`](https://github.com/intens-intern-project/frontend)
or [`backend:main`](https://github.com/intens-intern-project/backend) 
trigger a CI/CD pipeline which builds and pushes a new Docker image
and rollouts a restart of the Deployment in Kubernetes.

For testing purposes, a Minikube cluster is locally deployed. To
make modifications on this local cluster, the pipelines use a self-hosted
ARC runner for the necessary steps.

The database initialization scripts are 
in [`./helmcharts/db/files`](./helmcharts/db/files/)
because Helm doesn't support reading from files 
outside the chart's root directory.

---

**Running the project**

**1) Docker Compose:**

The `backend` and `frontend` projects are deployed locally,
and must be stored in sibling directories to this one:

```
/
    /infra/
        docker-compose.yaml
    /backend/
        Dockerfile
    /frontend/
        Dockerfile
```

Build and run the services using Docker Compose:

```sh
docker compose build
docker compose up
```

Visit [http://localhost](http://localhost).

**2) Minikube:**

Initialize Minikube:

```sh
minikube start
```

Create the necessary namespaces:

```sh
kubectl create namespace iip-dev
kubectl create namespace iip-prod
```

Deploy:

```sh
# Using Terraform (recommended)
cd terraform
terraform init
terraform apply

# or using a script
./helmcharts/upgrade.sh
```

Open ports for backend and frontend services:

```sh
kubectl port-forward service/backend 8080:8080 -n iip-[dev/prod]
kubectl port-forward service/frontend 5173:80 -n iip-[dev/prod]
```

Visit [http://localhost:5173](http://localhost:5173).
