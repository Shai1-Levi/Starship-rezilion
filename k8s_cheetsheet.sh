kubectl expose deployment nginx3 --type=LoadBalancer --port=5000 --name=nginx3
kubectl patch svc web -p '{"spec":{"externalIPs":["34.67.32.39"]}}'


# local shell
# gcloud auth login
# gcloud config set container/use_client_certificate False
# gcloud config set container/use_client_certificate True
# export CLOUDSDK_CONTAINER_USE_CLIENT_CERTIFICATE=True