#!/bin/sh
set -x
set -e
AEROSPIKE_PORT="$1"
AEROSPIKE_VERSION="$2"
AEROSPIKE_CONF="$3"
AEROSPIKE_FETURES_B64="$4"
FIREFLY_PATH="$5"

env
pwd
ls


ls /

ls /home/

ls /opt


mount="-v $FIREFLY_PATH/.github/aerospike:/opt/aerospike/etc"

docker run -v "$FIREFLY_PATH":"$FIREFLY_PATH" -e FIREFLY_PATH -e AEROSPIKE_FETURES_B64 ubuntu:22.04 bash -x -c 'echo $AEROSPIKE_FETURES_B64 | base64 -d > $FIREFLY_PATH/.github/aerospike/features.conf'

echo "$feature_key_string" | base64 -d > /github/workspace/.github/aerospike/features.conf


echo $docker_cmd
echo "will list /opt/aerospike/ with same mounts"
docker run -v $FIREFLY_PATH/.github/aerospike:/opt/aerospike/etc ubuntu:22.04 bash -x -c 'ls /opt; find /opt/aerospike/'
docker run -d --name gha_aerospike --rm \
  -e MEM_GB=2 \
  -e FEATURE_KEY_FILE=/opt/aerospike/etc/features.conf
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
