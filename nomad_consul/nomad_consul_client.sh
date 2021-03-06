#!/usr/bin/env bash
mkdir -p ./jalgoarena-data
mkdir -p ./logs
echo "jalgoarena-data & logs dir created"

nohup consul agent -ui -data-dir=./jalgoarena-data/consul -retry-join "192.168.63.21"> logs/consul.out 2> logs/consul.err < /dev/null &
echo "Consul client started, check http://$(hostname):8500"
consul version

nohup nomad agent -client -data-dir=$(pwd)/jalgoarena-data/nomad -client -servers="192.168.63.21" -config=$(pwd)/nomad-client.hcl > logs/nomad.out 2> logs/nomad.err < /dev/null &
echo "Nomad Started, check http://$(hostname):4646"
nomad version
