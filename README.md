# ECS Terraform

- Public subnets
- Application load balancer in front of
- Multiple applications

## Usage

Push images (replace the name with your docker hub user)

```sh
docker build -t dmenezesgabriel/fastapi-app1:v3 ./app1
docker build -t dmenezesgabriel/fastapi-app2:v3 ./app2
docker build -t dmenezesgabriel/nextjs-app3:v3 ./app3
docker build -t dmenezesgabriel/nextjs-app4:v3 ./app4
docker build -t dmenezesgabriel/nextjs-app5:v6 ./app5

docker push dmenezesgabriel/fastapi-app1:v3
docker push dmenezesgabriel/fastapi-app2:v3
docker push dmenezesgabriel/nextjs-app3:v3
docker push dmenezesgabriel/nextjs-app4:v3
docker push dmenezesgabriel/nextjs-app5:v6
```

Then `cd` into infra

```sh
terraform init
terraform validate
terraform apply --auto-approve
```

Check the ALB dns url in the terminal output then http://dns_url/app1 or http://dns_url/app2
