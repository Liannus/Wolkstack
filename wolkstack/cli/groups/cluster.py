import click
from wolkstack.utils.helpers import getProjectDirectory, searchParentDirectoriesForFile, callCommand
from wolkstack.utils import constants
import logging

# Command Group
@click.group(name='cluster')
def cluster():
    """Manage the deployed kubernetes cluster."""
    pass


@cluster.command(name='pods', help='get the pods in the Wolkstack cluster')
def pods_cmd():
    directory = searchParentDirectoriesForFile("wolkstack.json")
    if directory:
        try:
            print(directory+"/wolkstack.json")
            open(directory + "/wolkstack.json",)
        except:
            logging.debug("Corrupt wolkstack.json file")
    callCommand(["kubectl", "get", "pods", "-A"], cwd=directory +
                "/" + constants.TERRAFORM_PATH)


@cluster.command(name='services', help='get the services in the Wolkstack cluster')
def servies_cmd():
    directory = searchParentDirectoriesForFile("wolkstack.json")
    if directory:
        try:
            print(directory+"/wolkstack.json")
            open(directory + "/wolkstack.json",)
        except:
            logging.debug("Corrupt wolkstack.json file")
    callCommand(["kubectl", "get", "pods", "-A"], cwd=directory +
                "/" + constants.TERRAFORM_PATH)


@cluster.command(name='ingress', help='get the ingress in the Wolkstack cluster')
def ingress_cmd():
    directory = searchParentDirectoriesForFile("wolkstack.json")
    if directory:
        try:
            print(directory+"/wolkstack.json")
            open(directory + "/wolkstack.json",)
        except:
            logging.debug("Corrupt wolkstack.json file")
    callCommand(["kubectl", "get", "ingress"], cwd=directory +
                "/" + constants.TERRAFORM_PATH)


@cluster.command(name='cert', help='get the certificates in the Wolkstack cluster')
def cert_cmd():
    directory = searchParentDirectoriesForFile("wolkstack.json")
    if directory:
        try:
            print(directory+"/wolkstack.json")
            open(directory + "/wolkstack.json",)
        except:
            logging.debug("Corrupt wolkstack.json file")
    callCommand(["kubectl", "get", "certificate", "-A"], cwd=directory +
                "/" + constants.TERRAFORM_PATH)


@cluster.command(name='cert-manager', help='get the status of cert manager')
def cert_manager_cmd():
    directory = searchParentDirectoriesForFile("wolkstack.json")
    if directory:
        try:
            print(directory+"/wolkstack.json")
            open(directory + "/wolkstack.json",)
        except:
            logging.debug("Corrupt wolkstack.json file")
    callCommand(["kubectl", "describe", "certificate", "wolkstack-deployment-secret"], cwd=directory +
                "/" + constants.TERRAFORM_PATH)


if __name__ == '__main__':
    cluster()
