#!/bin/sh
set -x
set -e

mount=""
if [ -n "$3" ] || [ -n "$4" ]; then
  config_dir="/github/workspace/$(dirname $3)"
  mount="-v $config_dir:/opt/aerospike/etc"
  echo "list config dir" ls $config_dir
fi

if [ -n "$4" ]; then
  feature_key_file=$(basename $4)
  image="-e \"FEATURE_KEY_FILE=/opt/aerospike/etc/$feature_key_file\" aerospike/aerospike-server-enterprise:$2"
else
  image="aerospike/aerospike-server:$2"
fi

if [ -n "$3" ]; then
  config_file=$(basename $3)
  docker_cmd="docker run -d --name gha_aerospike -e MEM_GB=2 -p $1:3000 -p 3001:3001 -p 3002:3002 -p 3003:3003 -p4333:4333 \
  $mount $image --config-file /opt/aerospike/etc/$config_file "
else
  docker_cmd="docker run -d --name gha_aerospike -p $1:3000 -e MEM_GB=2 -p 3001:3001 -p 3002:3002 -p 3003:3003 -p4333:4333 $image"
fi

echo $docker_cmd

ctr_id=$($docker_cmd)
echo will sleep 10 seconds and check $ctr_id
sleep 10
docker logs $ctr_id
