#!/bin/sh
set -x
set -e
export AEROSPIKE_PORT="$1"
export AEROSPIKE_VERSION="$2"
export AEROSPIKE_CONF="$3"
export AEROSPIKE_FETURES_B64="$4"
export FIREFLY_PATH="$5"

env
pwd
ls

docker run -v "$FIREFLY_PATH":"$FIREFLY_PATH" -e FIREFLY_PATH -e AEROSPIKE_FETURES_B64 ubuntu:22.04 bash -x -c 'echo $AEROSPIKE_FETURES_B64 | base64 -d > $FIREFLY_PATH/.github/aerospike/features.conf'

echo "will list /opt/aerospike/ with same mounts"
docker run -v $FIREFLY_PATH/.github/aerospike:/opt/aerospike/etc ubuntu:22.04 bash -x -c 'ls /opt; find /opt/aerospike/'

docker run -d --name gha_aerospike --rm \
  -e MEM_GB=2 \
  -e FEATURE_KEY_FILE=/opt/aerospike/etc/features.conf \
  -p $AEROSPIKE_PORT:3000 \
  -p 3001:3001 \
  -p 3002:3002 \
  -p 3003:3003 \
  -p 4333:4333 \
  -v $FIREFLY_PATH/.github/aerospike:/opt/aerospike/etc \
   aerospike/aerospike-server-enterprise:$AEROSPIKE_VERSION --config-file /opt/aerospike/etc/aerospike.conf


echo will sleep 10 seconds and check gha_aerospike container
sleep 10
docker logs gha_aerospike
