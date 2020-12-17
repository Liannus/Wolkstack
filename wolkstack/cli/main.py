import sys
import os
import click
import time
import json
from .groups import groups
from cookiecutter.main import cookiecutter
from wolkstack.utils.helpers import handleExternalDNS, getProjectDirectory, searchParentDirectoriesForFile, callCommand
from wolkstack.utils import constants
import logging

logging.basicConfig(filename='logfile.log',
                    level=logging.DEBUG)
root = logging.getLogger()
root.setLevel(logging.DEBUG)

handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)
formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
root.addHandler(handler)


# Main CLI Group
@click.group()
@click.version_option("1.1.1")
def main():
    """A framework for blazing fast cloud infrastructure management and deployment."""
    pass


@main.command(name='generate', help='Generate a project boilerplate for deployment.')
@click.option('-p', '--project-name', prompt=True)
@click.option('-e', '--email', prompt=True)
@click.option('-d', '--domain-name', prompt=True)
@click.option('-r', '--route-53-hosted-zone-id', prompt=True)
@click.option('-do', '--docker-hub-username', prompt=True)
@click.option('-gu', '--github-username', prompt=True)
@click.option('-gr', '--github-repository-name', prompt=True)
def generate_project(project_name, email, domain_name, route_53_hosted_zone_id,
                     docker_hub_username, github_username, github_repository_name):
    cookiecutter(getProjectDirectory() + "/templates/base",
                 no_input=True, extra_context=locals())


@main.command(name='update-containers', help='Manually update containers in case of CICD errors.')
def update_containers():
    directory = searchParentDirectoriesForFile("wolkstack.json")
    if directory:
        try:
            print(directory+"/wolkstack.json")
            open(directory + "/wolkstack.json",)
        except:
            logging.debug("Corrupt wolkstack.json file")
    callCommand(["bash", "predeploy.sh"], cwd=directory +
                "/" + constants.TERRAFORM_PATH)


@main.command(name='up', help='Create infrastructure and boot application.')
def deploy_project():
    directory = searchParentDirectoriesForFile("wolkstack.json")
    if directory:
        try:
            print(directory+"/wolkstack.json")
            open(directory + "/wolkstack.json",)
        except:
            logging.debug("Corrupt wolkstack.json file")

    callCommand(["bash", "deploy.sh"], cwd=directory +
                "/" + constants.TERRAFORM_PATH)
    handleExternalDNS(directory, (directory + "/" +
                                  constants.HELM_TOOLS_PATH + "/values.yaml"))
    callCommand(["helm", "install", "deploy-tools", "../helm/toolChart"], cwd=directory +
                "/" + constants.TERRAFORM_PATH)
    time.sleep(30)
    callCommand(["helm", "install", "wolkstack-apps", "../helm/appChart"], cwd=directory +
                "/" + constants.TERRAFORM_PATH)


@main.command(name='down', help='Delete infrastructure and tear down application.')
def teardown_project():
    directory = searchParentDirectoriesForFile("wolkstack.json")
    if directory:
        try:
            print(directory+"/wolkstack.json")
            open(directory + "/wolkstack.json",)
        except:
            logging.debug("Corrupt wolkstack.json file")

    callCommand(["helm", "uninstall", "deploy-tools"], cwd=directory +
                "/" + constants.TERRAFORM_PATH)
    callCommand(["helm", "uninstall", "wolkstack-apps"], cwd=directory +
                "/" + constants.TERRAFORM_PATH)
    callCommand(["bash", "destroy.sh"], cwd=directory +
                "/" + constants.TERRAFORM_PATH)


# Add groups
for group in groups:
    main.add_command(group)

# Initialize CLI
if __name__ == '__main__':
    args = sys.argv
    if "--help" in args or len(args) == 1:
        print("CVE")
    main()
