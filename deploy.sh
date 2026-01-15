#!/bin/bash

echo "Starting MBank deployment to Fly.io..."

#Build the application
echo "Building application..."
./mvnw clean package -DskipTests

# Check if fly.toml exists, if not create it
if [ ! -f "fly.toml" ]; then
    echo "Creating fly.toml configuration..."
    cat > fly.toml << EOF
app = "m-bank-spring"
primary_region = "iad"

[build]
  dockerfile = "Dockerfile"

[env]
  JAVA_OPTS = "-Xmx512m"
  SPRING_PROFILES_ACTIVE = "flyio"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true

[[http_service.checks]]
  interval = "10s"
  grace_period = "5s"
  method = "get"
  path = "/ping"
  timeout = "2s"
EOF
fi

# Deploy to Fly.io
echo "Deploying to Fly.io..."
fly deploy

# Check status
echo "Checking deployment status..."
fly status

echo "Deployment complete! Your app is live at: https://m-bank-spring.fly.dev"