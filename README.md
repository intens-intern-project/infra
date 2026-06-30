Running the project:

**1) Docker Compose:**

The `backend` and `frontend` projects are deployed locally,
and musr be stored in sibling directories to this one:

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

TODO