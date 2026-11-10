# Advanced Task Manager — DevOps & IT Security Project

## 1. Project Overview

This project implements a Task Manager application using Ruby on Rails and MySQL. The application is containerized with Docker, managed using Docker Compose, and deployed to Kubernetes using Minikube.

The project demonstrates:

- Application containerization using a multi-stage Dockerfile.
- Database integration and persistent storage.
- Kubernetes Deployments, Services and health probes.
- CPU and memory monitoring.
- Horizontal Pod Autoscaling (HPA).
- Application recovery and fault-tolerance testing.
- Performance testing using Grafana k6.

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
| Load Testing | Grafana k6 |
| Operating System | Windows 11 |

## 3. Application Features

The application provides a web-based Task Manager dashboard.

Features include:

- Create tasks.
- Retrieve all tasks.
- Update task titles and completion status.
- Delete tasks.
- Search and filter tasks.
- View total, completed and pending task statistics.
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
│   ├── views/
│   ├── assets/
│   └── javascript/
├── config/
├── db/
│   └── migrate/
├── k8s/
│   ├── app.yaml
│   ├── hpa.yaml
│   ├── loadtest.js
│   ├── k6-job.yaml
│   └── k6-results-final.txt
├── Dockerfile
├── docker-compose.yaml
├── .dockerignore
├── .gitignore
├── Gemfile
├── Gemfile.lock
└── README.md
```

## 5. Docker Implementation

The Dockerfile uses a multi-stage build to separate application dependencies and build operations from the runtime image.

- Builder stage: `ruby:3.3`
- Runtime stage: `ruby:3.3-slim`
- Puma runs the Rails application on port 3000.
- The application runs using a non-root Linux user.
- The Docker build excludes local secrets such as `config/master.key`.

Docker Compose includes:

- Rails application service.
- MySQL 8.4 database service.
- Named volumes for persistent database and application data.
- A named bridge network.
- MySQL health checks and application health checks.
- Database dependency management.

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

The application is deployed on a local Minikube Kubernetes cluster.

The Kubernetes configuration includes:

- Rails Deployment.
- MySQL Deployment.
- Kubernetes Secret for database credentials.
- MySQL PersistentVolumeClaim (2 GiB).
- MySQL ClusterIP Service.
- Rails NodePort Service (30080).
- Readiness and liveness probes using `/up`.
- CPU and memory requests and limits.

The Rails Deployment starts with one replica. The HPA manages the number of replicas between one and three.

### Deploy the application

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

### Access the application

```text
http://<minikube-ip>:30080
```

The NodePort Service provides access to the application from outside the Kubernetes cluster in the local Minikube environment.

## 7. Horizontal Pod Autoscaling

The project uses a HorizontalPodAutoscaler with the following final configuration:

| Setting | Value |
|---|---:|
| Minimum replicas | 1 |
| Maximum replicas | 3 |
| CPU utilization target | 70% |

The CPU utilization target is calculated relative to the CPU request configured for the Rails container.

### Apply HPA

```bash
kubectl apply -f k8s/hpa.yaml
```

### Check HPA

```bash
kubectl get hpa taskmanager-hpa
```

### HPA scaling demonstration

A controlled scaling demonstration was performed by temporarily lowering the CPU utilization target from 70% to 40%.

During the load test:

- HPA reported CPU utilization of 431% against the temporary 40% target.
- The desired replica count increased from one to three.
- Kubernetes created two additional Rails pods.
- All three Rails pods reached `1/1 Running`.

After the demonstration, the original 70% target was restored and verified.

The application returned to one replica when the workload subsided.

The temporary 40% target was used only for demonstration. The committed HPA configuration retains the required 70% target.

## 8. Performance Testing