#Adding a device to the tenant by using the Device Registry Management API of Eclipse Hono
curl -i -X POST http://$REGISTRY_IP:28080/v1/devices/$MY_TENANT/$MY_TENANT:$MY_DEVICE -H  "content-type: application/json" --data-binary '{"authorities":["auto-provisioning-enabled"]}'
 
#Creating the twin by using the HTTP API of Eclipse Ditto
curl -X PUT -u ditto:ditto -H 'Content-Type: application/json' --data '{
  "policyId": "'$MY_TENANT':'$MY_POLICY'",
  "attributes": {
    "location": "Germany"
  },
  "features": {
    "temperature": {
      "properties": {
        "value": null
      }
    },
    "humidity": {
      "properties": {
        "value": null
      }
    }
  }
}' http://${DITTO_API_IP}:${DITTO_API_PORT_HTTP}/api/2/things/$MY_TENANT:$MY_DEVICE:edge:containers
