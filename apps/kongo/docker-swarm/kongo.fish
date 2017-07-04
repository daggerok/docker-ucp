#!/usr/local/bin/fish

# for i in 0 1 2; docker-machine create "node$i"; end

# docker-machine ssh node0
# docker@node0:~$ export ip=$(ifconfig eth1 | grep 'inet ' | awk '{print $2}' | awk -F ':' '{print $2}') # 192.168.99.100
# docker@node0:~$ docker swarm init --advertise-addr $ip --force-new-cluster
# 
# Swarm initialized: current node (m51j68z5ki5vauxm4qlbfmnf9) is now a manager.
# 
# To add a worker to this swarm, run the following command:
# 
#     docker swarm join --token SWMTKN-1-2l6kut578l5brcla5kym4j5sjcppkz810e9ht4boj2g0qns6lj-enzjqdxq3wy33ko1h5btfpxzc 192.168.99.100:2377
# 
# To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
# docker@node0:~$ exit

# docker-machine ssh node1
# docker@node1:~$ docker swarm join --token SWMTKN-1-2l6kut578l5brcla5kym4j5sjcppkz810e9ht4boj2g0qns6lj-enzjqdxq3wy33ko1h5btfpxzc 192.168.99.100:2377
# This node joined a swarm as a worker.
# docker@node1:~$ exit

# docker-machine ssh node2
# docker@node2:~$ docker swarm join --token SWMTKN-1-2l6kut578l5brcla5kym4j5sjcppkz810e9ht4boj2g0qns6lj-enzjqdxq3wy33ko1h5btfpxzc 192.168.99.100:2377
# This node joined a swarm as a worker.
# docker@node2:~$ exit

# eval (docker-machine env node0)

# docker network create -d overlay kongonet

## form
# docker run -d --name kong-db \
#   -p 5432:5432 \
#   -e POSTGRES_USER=kong \
#   -e POSTGRES_DB=kong \
#   healthcheck/postgres:alpine
## to
docker service create -d --name kong-db \
  --replicas 1 \
  --network kongonet \
  --mount type=volume,source=db-data,destination=/var/lib/postgresql \
  -p 5432:5432 \
  -e POSTGRES_USER=kong \
  -e POSTGRES_DB=kong \
  healthcheck/postgres:alpine

## from
# docker run -d --name kong \
#   --link kong-db:kong-db \
#   -p 8000:8000 -p 8443:8443 -p 8001:8001 -p 7946 \
#   -e "KONG_DATABASE=postgres" -e "KONG_PG_HOST=kong-db" \
#   kong
## to
docker service create -d --name kong \
  --replicas 1 \
  --network kongonet \
  -p 8000:8000 -p 8443:8443 -p 8001:8001 -p 7946 \
  -e "KONG_DATABASE=postgres" -e "KONG_PG_HOST=kong-db" \
  kong

## from
# docker run -d --name kong-dashboard \
#   -p 8080:8080 \
#   pgbi/kong-dashboard
## to
docker service create -d --name kong-dashboard \
  --replicas 1 \
  --network kongonet \
  -p 8080:8080 \
  pgbi/kong-dashboard

# open http://192.168.99.100:8080/
# config Kong node URL: http://192.168.99.100:8001
# docker service scale kong=3
# docker service scale kong-dashboard=2

# docker service ls                                                                                               03:21:32
# ID                  NAME                MODE                REPLICAS            IMAGE                         PORTS
# 3lb50hfchb89        kong-db             replicated          1/1                 healthcheck/postgres:alpine   *:5432->5432/tcp
# ac6kbu326kr6        kong-dashboard      replicated          1/2                 pgbi/kong-dashboard:latest    *:8080->8080/tcpkqz82v6blyf9        kong                replicated          3/3                 kong:latest                   *:8000->8000/tcp,*:8443->8443/tcp,*:8001->8001/tcp,*:0->7946/tcp

# for i in 0 1 2; docker-machine rm -f "node$i"; end
