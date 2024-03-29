#!/bin/sh


# Start 3 instances of NATS Server with different ports and configuration if necessary
export WASMCLOUD_LOG_LEVEL=DEBUG
printenv

nats-server -c ./nats.conf &
sleep 1

wadm &

sleep 1

wasmcloud

wait
