# dotnet-ecs-demo

Sample ASP.NET / .NET Framework 4.7.2 IIS application for an AWS ECS Fargate demonstration.

## Important

This is a **Windows container** application. Docker Desktop must be switched to Windows containers for local image building.

The sample IIS container listens on **port 80**.

### Build

From the repository root:

```powershell
docker build -t dotnet-ecs-demo:initial .
```

### Run locally

```powershell
docker run -d --name dotnet-ecs-demo -p 8080:80 dotnet-ecs-demo:initial
```

Open:

http://localhost:8080/

### ECR example

Authenticate Docker to ECR, then tag and push:

```powershell
docker tag dotnet-ecs-demo:initial 435059220002.dkr.ecr.us-east-1.amazonaws.com/dotnet-ecs-demo:initial
docker push 435059220002.dkr.ecr.us-east-1.amazonaws.com/dotnet-ecs-demo:initial
```

Replace the AWS account ID if different.

## ECS port configuration for this sample

Because IIS listens on port 80 inside the container:

- Container port: 80
- Target group port: 80
- ALB listener: 80

Target type should be IP for Fargate.

If your existing target group is already configured for port 8080, either recreate/update the target group to use 80, or use an explicit container/IIS binding on 8080. Do not mix 80 and 8080 accidentally.

## GitHub Actions

After this image works manually, the GitHub Actions workflow can build the same Dockerfile, tag the image with the Git commit SHA, push it to ECR, render the ECS task definition, and deploy the new revision.
