cd /grafana-6.7.1/bin/ && ./grafana-server web &
while true; do
	if ! pgrep grafana-server > /dev/null; then
		./grafana-server web &
	fi
	sleep 10
done
