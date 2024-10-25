docker build -t react-nginx-app .

docker run --name react-nginx-app -p 8080:80 -d react-nginx-app
