import logging
import subprocess
import os
import os.path
import pathlib
import yaml
from wolkstack.utils import constants


def getCurrentDirectory():
    return os.getcwd()


def getProjectDirectory():
    return str(pathlib.Path(__file__).parents[1].absolute())


def createSubDirectory(subDirectory):
    return getProjectDirectory + subDirectory


def createCommandString(commandList):
    return " ".join(commandList)


def searchParentDirectoriesForFile(filename):
    file_name = filename  # file to be searched
    cur_dir = os.getcwd()  # Dir from where search starts can be replaced with any path

    while True:
        file_list = os.listdir(cur_dir)
        parent_dir = os.path.dirname(cur_dir)
        if file_name in file_list:
            return cur_dir
        else:
            if cur_dir == parent_dir:  # if dir is root dir
                logging.error(
                    """Can't find a suitable configuration file are you in the right directory?""")
                quit()
                break
            else:
                cur_dir = parent_dir


def handleExternalDNS(parentDir, outputYaml):
    result = callCommand(["terraform", "output", "external-dns-role-arn"],
                         cwd=parentDir + "/" + constants.TERRAFORM_PATH, stdout=True)
    logging.debug(f'Command result: ${str(result.stdout, "utf-8")}')
    file = open(outputYaml, 'r')
    data = yaml.safe_load(file)

    data["external-dns"]["serviceAccount"]["annotations"][
        "eks.amazonaws.com/role-arn"] = str(result.stdout, "utf-8").strip('\n')

    with open(outputYaml, 'w') as yaml_file:
        yaml.dump(data, yaml_file)


def callCommand(command, shell=False, cwd=None, stdout=False):
    logging.info(f'Running command: {command}')
    if shell:
        commandList = createCommandString(command)
    else:
        commandList = command
    result = subprocess.run(args=commandList, shell=shell,
                            cwd=cwd, stdout=subprocess.PIPE if stdout else None)
    logging.debug(f'Command result: {result}')
    return result
