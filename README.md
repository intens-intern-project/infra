Running the project:

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

Deploy:

```sh
# Using Terraform (recommended)
terraform init
terraform apply

# or using a script
./helmcharts/upgrade.sh
```

Open ports for backend and frontend services:

```sh
kubectl port-forward service/backend 8080:8080 
kubectl port-forward service/frontend 5173:80
```

Visit [http://localhost:5173](http://localhost:5173).

---

Note: the database initialization scripts are in `/helmcharts/db/files` 
because Helm doesn't support reading from files outside the chart's root
directory.