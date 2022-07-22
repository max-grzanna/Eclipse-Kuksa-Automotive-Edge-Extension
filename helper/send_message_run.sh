#Sending a Eclipse Ditto message to it's HTTP API (run)
curl -i -X POST -u ditto:ditto -H 'Content-Type: application/json' -w '\n' --data '{
  "imageRef": "docker.io/library/influxdb:1.8.4",
  "start": true
}' http://$LOADBALANCER_IP:8081/api/2/things/$MY_TENANT:$MY_DEVICE:edge:containers/features/ContainerFactory/inbox/messages/create?timeout=60
