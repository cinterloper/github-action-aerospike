#!/usr/bin/env bash
set -x
set -e
export AEROSPIKE_PORT="$1"
export AEROSPIKE_VERSION="$2"
export AEROSPIKE_CONF="$3"
export AEROSPIKE_FETURES_B64="$4"
export FIREFLY_PATH="$5"

echo $AEROSPIKE_FETURES_B64 | base64 -d >$FIREFLY_PATH/.github/aerospike/features.conf

virtualenv -p "$(which python3)" /tmp/venv
source /tmp/venv/bin/activate
pip3 install -r $FIREFLY_PATH/.github/aerospike/requirements.txt

python3 $FIREFLY_PATH/.github/aerospike/start_cluster.py \
  --repo_path="$FIREFLY_PATH" \
  --aerospike_version="$AEROSPIKE_VERSION" \
  --features_file="$FIREFLY_PATH/.github/aerospike/features.conf"
