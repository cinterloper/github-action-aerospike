#!/usr/bin/env bash
set -x
set -e
export AEROSPIKE_VERSION="$1"
export AEROSPIKE_FETURES_B64="$2"
export AEROSPIKE_CONF_TEMPLATE_B64="$3"
export REPOSITORY_ROOT="$4"
export LAUNCHER_ARGS="$5"

ls -laht $REPOSITORY_ROOT

echo $AEROSPIKE_FETURES_B64 | base64 -d >$REPOSITORY_ROOT/.github/aerospike/features.conf

virtualenv -p "$(which python3)" /tmp/venv
source /tmp/venv/bin/activate
pip3 install -r $REPOSITORY_ROOT/.github/aerospike/requirements.txt

if [[ ! -z "$AEROSPIKE_CONF_TEMPLATE_B64" ]]
then
  echo $AEROSPIKE_CONF_TEMPLATE_B64 | base64 -d > $REPOSITORY_ROOT/.github/aerospike/custom_template.conf
  CONF_PARAM="--config_template=custom_template.conf"
fi

python3 $REPOSITORY_ROOT/.github/aerospike/start_cluster.py \
  --repo_path="$REPOSITORY_ROOT" \
  --aerospike_version="$AEROSPIKE_VERSION" \
  --features_file="$REPOSITORY_ROOT/.github/aerospike/features.conf" ${CONF_PARAM:-""} ${LAUNCHER_ARGS:-""}
  
