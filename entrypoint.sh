#!/usr/bin/env bash
set -x
set -e
export AEROSPIKE_VERSION="$1"
export AEROSPIKE_FETURES_B64="$2"
export AEROSPIKE_CONF_TEMPLATE_B64="$3"


echo $AEROSPIKE_FETURES_B64 | base64 -d >$FIREFLY_PATH/.github/aerospike/features.conf

virtualenv -p "$(which python3)" /tmp/venv
source /tmp/venv/bin/activate
pip3 install -r $FIREFLY_PATH/.github/aerospike/requirements.txt

if [[ ! -z "$AEROSPIKE_CONF_TEMPLATE_B64" ]]
then
  echo $AEROSPIKE_CONF_TEMPLATE_B64 | base64 -d > $FIREFLY_PATH/.github/aerospike/custom_template.conf
  CONF_PARAM="--config_template=custom_template.conf"
fi

python3 $FIREFLY_PATH/.github/aerospike/start_cluster.py \
  --repo_path="$FIREFLY_PATH" \
  --aerospike_version="$AEROSPIKE_VERSION" \
  --features_file="$FIREFLY_PATH/.github/aerospike/features.conf" ${CONF_PARAM:-""}
  
