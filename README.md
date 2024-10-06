# ECS Terraform

- Public subnets
- Application load balancer in front of
- Multiple applications

## Usage

Push images (replace the name with your docker hub user)

```sh
docker build -t dmenezesgabriel/fastapi-app1:v2 ./app1
docker build -t dmenezesgabriel/fastapi-app2:v2 ./app2

docker push dmenezesgabriel/fastapi-app1:v2
docker push dmenezesgabriel/fastapi-app2:v2
```

Then `cd` into infra

```sh
terraform init
terraform validate
terraform apply --auto-approve
```

Check the ALB dns url in the terminal output then http://dns_url/app1 or http://dns_url/app2
