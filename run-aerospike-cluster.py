from typing import List, Dict

import argparse
import docker
from box import Box
from docker.client import DockerClient


def parse_cli():
    parser = argparse.ArgumentParser(description="run aerospike cluster")
    parser.add_argument('--aerospike_version', type=str, help="version of aerospike")
    parser.add_argument('--aerospike_conf', type=str, help="aerospike configuration location on host machine")
    parser.add_argument('--features_file', type=str, help="base64 encoded features file")
    parser.add_argument('--repo_path', type=str, help="repo path")
    cli = parser.parse_args()
    assert cli.repo_path is not None
    assert cli.aerospike_version is not None
    assert cli.aerospike_conf is not None
    assert cli.features_file is not None

    return Box({"aerospike_version": cli.aerospike_version,
                "aerospike_conf": cli.aerospike_conf,
                "features_file": cli.features_file,
                "repo_path": cli.repo_path,
                "aerospike_image": f"aerospike:{cli.aerospike_version}"})


def get_mounts(config) -> List[Dict]:
    return [{
        "Target": "/opt/aerospike/etc",
        "Mode": "",
        "Propagation": "rprivate",
        "RW": True,
        "Source": f"{config.repo_path}/.github/aerospike",
        "Type": "bind"
    }]


def start_aerospike_node(config: Box, docker_client: DockerClient):
    mounts = get_mounts(config)

    it = docker_client.containers.run(config.aerospike_image,
                                      command=" --config-file /opt/aerospike/etc/aerospike.conf",
                                      detach=True,
                                      mounts=mounts)
    return it.id


def run_asinfo_cmd(cmd: str, ctr_id: str, docker_client: DockerClient):
    container = docker_client.containers.get(ctr_id)
    exit, output = container.exec_run(cmd)
    assert exit == 0
    return exit, output


def run_asinfo_tip(ctr_id: str, peer_ip: str, docker_client: DockerClient):
    return run_asinfo_cmd(f"asinfo -v tip:host={peer_ip};port=3002", ctr_id, docker_client)


def get_ctr_ip(ctr_id: str, docker_client: DockerClient) -> str:
    container = docker_client.containers.get(ctr_id)
    x = container.attrs['NetworkSettings']['IPAddress']
    return x


def healthcheck(ctr_id: str, docker_client: DockerClient) -> bool:
    cmd = "cluster-stable:size=3;ignore-migrations=true;namespace=test"
    exit, output = run_asinfo_cmd(cmd, ctr_id, docker_client)
    return exit == 0


def shutdown(ctr_id: str, docker_client: DockerClient):
    container = docker_client.containers.get(ctr_id)
    container.stop()


def start_aerospike_cluster(config, docker_client):
    ctr_id_1: str = start_aerospike_node(config, docker_client)
    ctr_id_2: str = start_aerospike_node(config, docker_client)
    ctr_id_3: str = start_aerospike_node(config, docker_client)

    # tip container 2 to peer with container 1
    run_asinfo_tip(ctr_id_2, get_ctr_ip(ctr_id_1, docker_client), docker_client)
    # tip container 3 to peer with container 1
    run_asinfo_tip(ctr_id_3, get_ctr_ip(ctr_id_1, docker_client), docker_client)

    return [ctr_id_1, ctr_id_2, ctr_id_3]


if __name__ == '__main__':
    docker_client: DockerClient = docker.from_env()
    config = parse_cli()
    nodes: List = start_aerospike_cluster(config, docker_client)
