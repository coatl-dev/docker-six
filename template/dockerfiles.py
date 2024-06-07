"""Dockerfile generator."""

import os
from jinja2 import Environment, FileSystemLoader

JYTHON_VERSION = "2.7.3"
PYTHON3_VERSIONS = ["3.8.19", "3.9.19", "3.10.14", "3.11.9", "3.12.4", "3.13.0b2"]

ENVIRONMENT = Environment(
    trim_blocks=True, lstrip_blocks=True, loader=FileSystemLoader("template/")
)
TEMPLATE = ENVIRONMENT.get_template("docker.jinja")


def create_dockerfile(template, version, path, is_jython=False):
    """
    Create a Dockerfile using the provided template, version, and path.

    Args:
        template: The Jinja2 template used to generate the Dockerfile
            content.
        version: The version to be included in the Dockerfile.
        path: The path where the Dockerfile will be created.
        is_jython: A boolean indicating whether Jython is being used.
            Optional. Default is False.
    """

    os.makedirs(path, exist_ok=True)
    filename = f"{path}/Dockerfile"
    content = template.render(
        version=version, is_jython=is_jython, jython_version=JYTHON_VERSION
    )
    with open(filename, mode="w", encoding="utf-8") as dockerfile:
        dockerfile.write(content)
        print(f"... wrote {filename}")


def create_dockerfiles():
    """
    Create Dockerfiles for Python and Jython versions based on
    predefined templates.
    """

    for python3_version in PYTHON3_VERSIONS:
        major_minor = python3_version.split(".")[:2]
        root_dir = ".".join(major_minor)
        # Create Python
        create_dockerfile(TEMPLATE, python3_version, f"{root_dir}/python")
        # Create Jython
        create_dockerfile(TEMPLATE, python3_version, f"{root_dir}/jython", True)


if __name__ == "__main__":
    create_dockerfiles()
