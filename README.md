# wasmcloud-docker-image

A simple Dokcer image that hosts the following binaries:
1. nats-server
2. wadm
3. wasmcloud

It exposes the following ports:
1. 4222 - NATS server
2. 4001 - websocket
3. 8080 - web application


## Usage

```bash
 docker run -p 4222:4222 -p 8080:8080 -p 4001:4001 @eden/wasmcloud

wash app put petclinic.wadm.yam
```
