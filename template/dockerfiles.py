import os
from jinja2 import Environment, FileSystemLoader

versions = ["3.8.19", "3.9.19", "3.10.14", "3.11.9", "3.12.3", "3.13.0b1"]

environment = Environment(
    trim_blocks=True, lstrip_blocks=True, loader=FileSystemLoader("template/")
)
template = environment.get_template("docker.jinja")


def create_dockerfile(template, version, path, is_jython=False):
    os.makedirs(path, exist_ok=True)
    filename = f"{path}/Dockerfile"
    content = template.render(
        version=version, is_jython=is_jython, jython_version="2.7.3"
    )
    with open(filename, mode="w", encoding="utf-8") as dockerfile:
        dockerfile.write(content)
        print(f"... wrote {filename}")


for version in versions:
    major_minor = version.split(".")[:2]
    root_dir = ".".join(major_minor)
    # Create Python
    create_dockerfile(template, version, f"{root_dir}/python")
    # Create Jython
    create_dockerfile(template, version, f"{root_dir}/jython", True)
