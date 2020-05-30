#!/bin/sh
# Creation date: 24/05/2020
# Description: builds docker images and deploys them onto a kubernetes cluster for the ft_service project of school 42

LIGHT_BLUE="\033[1;34m"
NC="\033[0m"

# Checks the presence of docker and minikube on the system
if ! which docker 1> /dev/null || ! which minikube 1> /dev/null; then
	echo "Please install docker and minikube before lauching this script"
	exit 1
fi

# Lanches minikube if not already started
if ! minikube status 1> /dev/null 2> /dev/null; then
	minikube start
fi

# Enables addons
minikube addons enable ingress
minikube addons enable metrics-server

# Builds Dockerfiles
docker build -t custom-nginx:latest srcs/nginx/

# Applies kustomization
kubectl apply -k srcs/

# The result
figlet "the result" | lolcat -F 0.4 -a

# Get urls
echo "$LIGHT_BLUE""Nginx urls:""$NC"
minikube service nginx --url | tr "\n" "#"  | sed -E 's|^(.*#)http(.*#)http://(.*)#|\1https\2ssh://bonjour@\3|' | tr "#" "\n"

