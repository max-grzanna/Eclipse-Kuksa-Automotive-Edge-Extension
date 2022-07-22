#Sending a Eclipse Ditto message to it's HTTP API (remove)
curl -i -X POST -u ditto:ditto -H 'Content-Type: application/json' -w '\n' --data 'true' http://$LOADBALANCER_IP:8081/api/2/things/$MY_TENANT:$MY_DEVICE:edge:containers/features/Container:$CONTAINER_ID/inbox/messages/remove?timeout=60
