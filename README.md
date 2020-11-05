# Build local version of test code and add to MicroK8s
```bash
# Build test container
sudo docker build -t reqwest-test:latest -f ./Dockerfile .
# Create cached version of container
sudo docker save reqwest-test > reqwest-test.tar
# Load cached container into MicroK8s
microk8s ctr image import reqwest-test.tar
```

# Start service and test
```bash
# Start a service (that doesn't do anthing)
microk8s kubectl apply -f my-service.yaml
# Start reqwest-test
microk8s kubectl apply -f reqwest-test.yaml 
```

# Query logs to see if DNS succeeds
```bash
microk8s kubectl logs $(microk8s kubectl get pods | grep reqwest | grep -v Terminat | awk '{print $1}')

reqwest-test url: "http://my-service:80"
Failed to establish connection to http://my-service:80
Error: error sending request for url (http://my-service/): error trying to connect: tcp connect error: Connection refused (os error 111)
reqwest-test url: "http://my-service:80"
Failed to establish connection to http://my-service:80
Error: error sending request for url (http://my-service/): error trying to connect: tcp connect error: Connection refused (os error 111)
```
