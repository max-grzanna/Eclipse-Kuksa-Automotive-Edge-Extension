#Retrieving the properties of the installed containers by using the HTTP API of Eclipse Ditto (retrieve)
curl -u ditto:ditto -w '\n' http://$LOADBALANCER_IP:8081/api/2/things/$MY_TENANT:$MY_DEVICE:edge:containers
