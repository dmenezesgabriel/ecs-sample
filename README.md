docker build -t dmenezesgabriel/fastapi-app1:v1 ./app1
docker build -t dmenezesgabriel/fastapi-app2:v1 ./app2

docker push dmenezesgabriel/fastapi-app1:v1
docker push dmenezesgabriel/fastapi-app2:v1