#!/bin/sh
# Creation date: 24/05/2020
# Description: builds docker images and deploys them onto a kubernetes cluster for the ft_service project of school 42

# Colors
LIGHT_BLUE="\033[1;34m"
NC="\033[0m"

# OS detection
MACHINE_OS=$(uname -s)

# Checks the presence of docker and minikube on the system
if ! which docker 1> /dev/null || ! which minikube 1> /dev/null; then
	echo "Please install docker and minikube before lauching this script"
	exit 1
fi

# cleanup function for restart, stop and stop_all options
cleanup () {
	kubectl delete -k srcs
	rm srcs/ftps/Dockerfile
}

# Option management
VERBOSE="false"
if [ "$1" = "-v" ]; then
	VERBOSE="true"
	shift
fi

# Mode management
case "$1" in
	start) echo "Ok let's go!" ;;
	restart)
		cleanup
		echo "Ok let's go!" ;;
	stop)
		cleanup
		exit 0;;
	stop_all)
		cleanup
		minikube stop
		exit 0;;
	extra)
		brew install figlet lolcat
		exit 0;;
	*) 
		echo "Usage: ./ft_service [OPTION] [MODE]"
		echo ""
		echo "Options:"
		echo "    -v         verbose"
		echo ""
		echo "Modes:"
		echo "    start      starts the project"
		echo "    restart    deletes the running kustomization and reapplies it"
		echo "    stop       deletes the running kustomization"
		echo "    stop_all   deletes the running kustomization and stops minikube"
		echo "    extra      installs figlet and lolcat to make the results go 'yes'"
		exit 1;;
esac

# Lanches minikube if not already started
if ! minikube status 1> /dev/null 2> /dev/null; then
	echo "Starting Minikube..."
	if [ "$VERBOSE" = "true" ]; then
		minikube start --driver=virtualbox
	else
		minikube start --driver=virtualbox 1> /dev/null
	fi
	echo "Minikube started!"
fi

# Enables addons
echo "enabling addons: ingress and metrics-server"
if [ "$VERBOSE" = "true" ]; then
	minikube addons enable ingress
	minikube addons enable metrics-server
else
	minikube addons enable ingress 1> /dev/null
	minikube addons enable metrics-server 1> /dev/null
fi

# Prepares Dockerfiles
mk_ip=$(minikube ip)
sed "s|#MINIKUBE_IP#|$mk_ip|g" < srcs/ftps/Dockerfile-template > srcs/ftps/Dockerfile


# Builds Dockerfiles
echo "Building Docker images"
eval "$(minikube docker-env)"
if [ "$VERBOSE" = "true" ]; then
	docker build -t custom-nginx:latest srcs/nginx/
	docker build -t custom-ftps:latest srcs/ftps/
else
	docker build -t custom-nginx:latest srcs/nginx/ 1> /dev/null
	docker build -t custom-ftps:latest srcs/ftps/ 1> /dev/null
fi

# Applies kustomization
echo "Applying kustomization"
if [ "$VERBOSE" = "true" ]; then
	kubectl apply -k srcs/
else
	kubectl apply -k srcs/ 1> /dev/null
fi

# The result
echo ""
if ! which figlet 1> /dev/null 2> /dev/null || ! which lolcat 1> /dev/null 2> /dev/null; then
	echo "The results:"
else
	figlet "The  results :" | lolcat -F 0.4 -a
fi

# Get K8s pods
kubectl get pods

# Get urls
echo ""
echo "$LIGHT_BLUE""Nginx urls:""$NC"
minikube service nginx --url | tr "\n" "#" | sed -E 's|^(.*#)http(.*#)http://(.*)#|\1https\2ssh://bonjour@\3|' | tr "#" "\n"
echo "$LIGHT_BLUE""ftps urls:""$NC"
minikube service ftps --url | head -1 | sed 's|http://|ftp |;s|:| |'
