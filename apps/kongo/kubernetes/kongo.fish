#!/usr/local/bin/fish

minikube start

kubectl create \
  -f kongo-db.replication-controller.yml \
  -f kongo-db.service.yml \
  -f kongo.deployment.yml \
  -f kongo.service.yml \
  -f kongo-dashboard.deployment.yml \
  -f kongo-dashboard.service.yml

kubectl get services
# NAME          CLUSTER-IP   EXTERNAL-IP   PORT(S)                         AGE
# kongo-admin   10.0.0.200   <nodes>       8001:30814/TCP,8443:30524/TCP   57m
# kongo-proxy   10.0.0.220   <nodes>       8000:30299/TCP,8443:31322/TCP   57m
# kongo-ui      10.0.0.11    <pending>     80:31486/TCP                    57m
# kubernetes    10.0.0.1     <none>        443/TCP                         2h
# postgres      10.0.0.184   <none>        5432/TCP                        57m

open (minikube service kongo-ui --url)
# TODO: figure out how to get right host and port for Kong node URL

minikube stop
minikube delete
