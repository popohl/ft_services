#!/bin/sh
# Creation date: 24/05/2020
# Description: builds docker images and deploys them onto a kubernetes cluster for the ft_service project of school 42

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


