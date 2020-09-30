#!/bin/bash

# Colors
_BLACK='\033[30m'
_RED='\033[31m'
_GREEN='\033[32m'
_YELLOW='\033[33m'
_BLUE='\033[34m'
_PURPLE='\033[35m'
_CYAN='\033[36m'
_WHITE='\033[37m'
_NOCOLOR='\033[0m'

man_msg () {
	echo -e "${_GREEN}Usage: $0 [OPTION] [MODE]$_NOCOLOR"
	echo ""
	echo "Options:"
	echo "    -v        Verbose"
	echo "    -h        Displays this help"
	echo ""
	echo "Modes:"
	echo "    start     Starts the project"
	echo "    stop      Deletes the current kustomization"
	echo "    help      Displays this help"
	echo "    test      Displays help to test the project"
}

if [ "$#" -gt 2 ]; then
	echo "Too many arguments!"
	exit 1
elif [ "$1" = "-h" ] || [ "$#" = "0" ]; then
	man_msg
	exit 2
fi

verbose="false"
if [ "$1" = "-v" ]; then
	verbose="true"
	shift
elif [ "$2" = "-v" ]; then
	verbose="true"
fi

test_msg () {
	if ! minikube status > /dev/null ; then
		echo -e "${_RED}Minikube not started,$_YELLOW run '$0 start'$_NOCOLOR"
		exit 1
	fi
	echo -e "'kubectl get pods' for pod status\n"
	echo -e "'kubectl get services' for list of ips\n"
	echo -e "'minikube dashboard' for a dashboard with lots of info"
	# Test SSH
	echo "To test ssh:"
	echo "ssh admin@172.17.0.4"
	echo "password: password"
	# Test FTPS
	echo "To test ftps:"
	echo "lftp admin@172.17.0.2"
	echo "password: password"
	echo "write 'set ssl:verify-certificate no' to disable certificate verification"
	echo "'put' to send a file, 'ls' to list files, 'get' to fetch a file"
}

# Read arguments
case "$1" in
	start | launch | go)
		echo "Starting ft_services!";;
	stop | delete | del)
		minikube delete
		exit 0;;
	test)
		test_msg
		exit 2;;
	help)
		man_msg
		exit 2;;
	*)
		echo -e "${_RED}Wrong argument $_NOCOLOR"
		man_msg
		exit 1;;
esac

# List of services to be deployed
SERVICE_LIST="nginx mysql wordpress phpmyadmin ftps influxdb telegraf grafana"

[ -z "${USER}" ] && export USER=`whoami`

# Check programs installation
# check_install (program_name, description, is_required)
check_install () {
	if ! which "$1" 1> /dev/null 2> /dev/null; then
		printf "$1 ($2) is not installed on your system, install it? (y/n)"
		read -r install
		if [ "$install" = "y" ] || [ "$install" = "yes" ]; then
			sudo apt install "$1" -y 1> /dev/null
		elif [ "$3" = "yes" ]; then
			exit 1
		fi
	fi
}

check_install minikube "required" "yes"
check_install lftp "A ftp client to test ftps" "no"
check_install "lolcat" "A program for funky cli writing" "no"
check_install "figlet" "Another program for funky cli writing" "no"

# Give sudo permission to docker
sudo usermod -aG docker $(whoami)

# Check if minikube is launched
if ! minikube status 1> /dev/null; then
	echo -ne "Minikube is not started,$_GREEN starting now $_NOCOLOR"
	if [ "$verbose" = "true" ]; then
		echo ""
		minikube start --vm-driver=docker
	else
		minikube start --vm-driver=docker 1> /dev/null 2> /dev/null
	fi
fi

if [[ $? == 0 ]]
then
	eval $(minikube docker-env)
	echo -ne "$_GREEN➜$_YELLOW Minikube started\n$_NOCOLOR"
else
	sudo minikube delete
	echo -ne "$_RED➜$_YELLOW Error occured\n$_NOCOLOR"
	exit
fi

# Preparing files
MINIKUBE_IP="$(kubectl get node -o=custom-columns='DATA:status.addresses[0].address' | sed -n 2p)"
#sed 's/MINIKUBE_IP/'"$MINIKUBE_IP"'/g' < srcs/ftps-template.yml > srcs/ftps.yml
#sed 's/MINIKUBE_IP/'"$MINIKUBE_IP"'/g' < srcs/ftps/setup-template.sh > srcs/ftps/setup.sh
#sed 's/MINIKUBE_IP/'"$MINIKUBE_IP"'/g' < srcs/telegraf/telegraf-template.conf > srcs/telegraf/telegraf.conf

# Install metallb
metallb_install () {
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
	kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
	kubectl apply -f srcs/metallb.yml
}
if [ "$verbose" = "true" ]; then
	metallb_install
else
	echo -e "$_GREEN➜$_YELLOW Installing metallb..."
	metallb_install 1> /dev/null
	echo -e "$_GREEN✓$_YELLOW Done!$_NOCOLOR"
fi

# Build Docker images and Deploy services
echo -ne "$_GREEN✓$_YELLOW Building Docker images and Deploying services...\n"
echo -ne "$_NOCOLOR"

# Function to apply a chosen service
build_docker () {
	echo -ne "$_GREEN➜$_YELLOW	Deploying $1...\n"
	echo -ne "$_NOCOLOR"
	if [ "$verbose" = "true" ]; then
		docker build -t custom-$1:1 srcs/$1
	else
		docker build -t custom-$1:1 srcs/$1 1> /dev/null
	fi
	echo -ne "$_GREEN✓$_YELLOW	$1 deployed!\n"
}

for service in $SERVICE_LIST
do
	build_docker $service
done

echo -e "\n$_GREEN➜$_YELLOW Applying kustomization...$_NOCOLOR"
if [ "$verbose" = "true" ]; then
	kubectl apply -k srcs/
else
	kubectl apply -k srcs/ 1> /dev/null
fi
echo -e "$_GREEN✓$_YELLOW Done!$_NOCOLOR"

echo -e "\n$_GREEN✓$_YELLOW	ft_services deployment complete !$_NOCOLOR"

sleep 4

if ! which figlet > /dev/null || ! which lolcat > /dev/null ; then
	echo "The results:"
else
	figlet "The results  :" | lolcat -F 0.4 -a
fi

kubectl get pods
echo ""
kubectl get services

echo -e "\nWrite$_YELLOW '$0 test'$_NOCOLOR for help message to test project"
