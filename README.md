# coatldev/six

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/coatl-dev/docker-six/coatl.svg "pre-commit.ci status")](https://results.pre-commit.ci/latest/github/coatl-dev/docker-six/coatl)
[![Docker Repository on Docker Hub](https://img.shields.io/badge/hub.docker.com-white?logo=docker "Docker Repository on Docker Hub")](https://hub.docker.com/r/coatldev/six)
[![Docker Repository on Quay](https://img.shields.io/badge/quay.io-red?logo=red-hat "Docker Repository on Quay")](https://quay.io/repository/coatldev/six)

Docker image based on Ubuntu 24.04 (Noble Numbat) with Python 3.12.11 and 2.7.18
pre-installed, plus [`uv`].

## Supported tags

- [`3.12`, `3.12.11`, `latest`]

For the full list of supported tags, see:

- [Docker Hub tags]
- [Quay.io tags]

## Supported platforms

|Container image registry|amd64|arm64|
|------------------------|-----|-----|
|[Docker Hub]            | ✅ | ✅ |
|[Quay.io]               | ✅ | ✅ |

## How to use this image

The examples below will demonstrate how to use this image in [Azure Pipelines],
and [GitHub Workflows].

> [!NOTE]
> `pip` caching is disabled by default.
> See: <https://github.com/actions/runner/issues/652>

### Azure Pipelines

```yml
jobs:
  - job: tox

    pool:
      vmImage: ubuntu-latest

    container: coatldev/six:latest # or quay.io/coatldev/six:latest

    steps:
      - script: |
          sudo chown -R $(whoami):$(id -ng) "${PYTHON_ROOT}"
        displayName: Change owner

      - script: |
          uv python install 3.14
        displayName: Install Python with uv

      - script: |
          uvx tox
        displayName: Run tests
```

### GitHub Actions workflow

```yml
jobs:
  tox:

    runs-on: ubuntu-latest

    container: coatldev/six:latest # or quay.io/coatldev/six:latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Install Python with uv
        run: |
          uv python install 3.14

      - name: Run tests
        run: |
          uvx tox
```

<!-- External links -->
[`3.12`, `3.12.11`, `latest`]: https://github.com/coatl-dev/docker-six/blob/coatl/Dockerfile
[Azure Pipelines]: https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/jobs-job-container?view=azure-pipelines
[GitHub Workflows]: https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container
[Docker Hub]: https://hub.docker.com/r/coatldev/six
[Docker Hub tags]: https://hub.docker.com/r/coatldev/six/tags
[Quay.io]: https://quay.io/repository/coatldev/six
[Quay.io tags]: https://quay.io/repository/coatldev/six?tab=tags
[`uv`]: https://docs.astral.sh/uv/
