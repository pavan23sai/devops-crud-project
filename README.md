# Advanced Task Manager — DevOps & IT Security Project

## 1. Project Overview

This project implements a containerized Task Manager application using Ruby on Rails and MySQL. The application is deployed using Docker Compose and Kubernetes (Minikube).

The project demonstrates containerization, database persistence, Kubernetes orchestration, health monitoring, horizontal scaling, fault tolerance and performance testing.

## 2. Technology Stack

| Component | Technology |
|---|---|
| Backend | Ruby on Rails 8.1 |
| Programming Language | Ruby 3.3 |
| Web Server | Puma |
| Database | MySQL 8.4 |
| Containerization | Docker |
| Multi-container Management | Docker Compose |
| Orchestration | Kubernetes |
| Local Kubernetes Cluster | Minikube |
| Load Testing | k6 |
| Operating System | Windows 11 |

## 3. Application Features

The application supports:

- Create tasks.
- Retrieve all tasks.
- Update task titles and completion status.
- Delete tasks.
- Search and filter tasks through the frontend.
- Health checking through `/up`.

### API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/tasks` | Retrieve all tasks |
| POST | `/tasks` | Create a task |
| PUT | `/tasks/:id` | Update a task |
| DELETE | `/tasks/:id` | Delete a task |
| GET | `/up` | Application health check |

## 4. Project Structure

```text
devops-crud-project/
├── app/
│   ├── controllers/
│   ├── models/
│   └── views/
├── config/
├── db/
│   └── migrate/
├── k8s/
│   ├── app.yaml
│   ├── hpa.yaml
│   └── loadtest.js
├── Dockerfile
├── docker-compose.yaml
├── .dockerignore
├── .gitignore
├── Gemfile
├── Gemfile.lock
└── README.md
```

## 5. Docker Implementation

The Dockerfile uses a multi-stage build:

- Builder stage: `ruby:3.3`
- Runtime stage: `ruby:3.3-slim`
- Puma runs the Rails application on port 3000.
- The application runs using a non-root user.

Docker Compose includes:

- Rails application service.
- MySQL 8.4 database service.
- Named volumes for persistent database and application data.
- A named bridge network.
- Health checks and database dependency management.

### Start the application

```bash
docker compose up --build -d
```

### Check containers

```bash
docker compose ps
```

### Stop containers

```bash
docker compose down
```

## 6. Kubernetes Deployment

The Kubernetes configuration includes:

- Rails Deployment.
- MySQL Deployment.
- Kubernetes Secret for database credentials.
- MySQL PersistentVolumeClaim (2 GiB).
- MySQL ClusterIP Service.
- Rails NodePort Service (30080).
- Readiness and liveness probes.
- CPU and memory requests and limits.

### Deploy

```bash
kubectl apply -f k8s/app.yaml
```

### Check pods

```bash
kubectl get pods
```

### Check services

```bash
kubectl get services
```

### Check application logs

```bash
kubectl logs deployment/taskmanager
```

## 7. Horizontal Pod Autoscaling

The project includes a HorizontalPodAutoscaler configured with:

- Minimum replicas: 1
- Maximum replicas: 3
- Target average CPU utilization: 70%

Apply the HPA:

```bash
kubectl apply -f k8s/hpa.yaml
```

Check its status:

```bash
kubectl get hpa
```

## 8. Performance Testing

Performance testing was performed using k6.

Test configuration:

- Virtual users: 500
- Duration: 60 seconds
- Endpoint: `GET /tasks`

The first test through the Minikube service tunnel produced:

- Total HTTP requests: 12,961
- HTTP failure rate: 87.97%
- Average latency: 1.31 seconds
- P95 latency: 7.65 seconds

A second test using port-forwarding also experienced connection failures:

- Total HTTP requests: 5,023
- HTTP failure rate: 65.06%
- Average latency: 4.99 seconds
- P95 latency: 14.68 seconds

These results indicate that the test environment did not reliably handle the 500-user workload. They are reported as observed results, not as successful performance targets.

## 9. Observability and Fault Tolerance

Kubernetes resource monitoring was performed using:

```bash
kubectl top pods
```

A sample observation after switching Puma to single mode:

| Component | CPU | Memory |
|---|---:|---:|
| Rails | 18m | 97 MiB |
| MySQL | 20m | 483 MiB |

Fault tolerance was tested by terminating the Rails container's main process.

Observed results:

- Restart count increased from 0 to 1.
- Kubernetes automatically restarted the container.
- The Rails pod returned to `1/1 Running`.
- Previously stored task data remained available.

## 10. Assumptions and Limitations

- Minikube is used as a local Kubernetes environment.
- The project uses demonstration database credentials; they are not suitable for production.
- Kubernetes Secrets in this local demonstration are not a replacement for production-grade secret management.
- The load test was executed on a resource-limited local environment.
- The 500-user test produced substantial request failures and requires further performance tuning.
- MySQL memory usage approached its configured 512 MiB limit during monitoring.
- HPA was configured with a CPU utilization target of 70%.

## 11. Conclusion

This project demonstrates the complete deployment workflow of a Ruby on Rails application using Docker, Docker Compose, MySQL and Kubernetes.

It also demonstrates Kubernetes health monitoring, resource monitoring, automatic container recovery, horizontal pod autoscaling and load testing.

The performance testing results identify areas for future optimization, particularly application stability, database resource usage and concurrent request handling.
