# coatldev/six

[![Lint Dockerfiles](https://github.com/coatl-dev/docker-six/actions/workflows/main.yml/badge.svg)](https://github.com/coatl-dev/docker-six/actions/workflows/main.yml)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/coatl-dev/docker-six/coatl.svg)](https://results.pre-commit.ci/latest/github/coatl-dev/docker-six/coatl)
![Docker Pulls](https://img.shields.io/docker/pulls/coatldev/six)

Docker image based on Ubuntu 22.04 (Jammy Jellyfish) with Python 2.7 and Python 3 pre-installed.

## Supported tags

- [`3.12`, `3.12.2`, `latest`] - Comes with Python 3.12.2 and 2.7.18.
- [`3.11`, `3.11.8`] - Comes with Python 3.11.8 and 2.7.18.
- [`3.10`, `3.10.13`] - Comes with Python 3.10.13 and 2.7.18.

### Alpha, Beta and Release Candidates

- [`3.13.0a4`] - Comes with Python 3.13.0a4 and 2.7.18.

For more tags, [click here].

## How to use this image

The examples below will demonstrate how to use this image in [Azure Pipelines], and [GitHub Workflows].

**NOTE:** `pip` caching is disabled by default. See: <https://github.com/actions/runner/issues/652>

### Azure Pipelines

```yml
jobs:
  - job: tox

    pool:
      vmImage: ubuntu-latest

    container: coatldev/six:3.11

    steps:
      - script: |
          sudo chown -R $(whoami):$(id -ng) "${PYTHON_ROOT}"
        displayName: Change owner

      - script: |
          python -m pip install --upgrade pip tox
        displayName: Install dependencies

      - script: |
          tox
        displayName: Run tests
```

### GitHub Workflows

```yml
jobs:
  tox:

    runs-on: ubuntu-latest

    container: coatldev/six:3.11

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip tox

      - name: Run tests
        run: |
          tox
```

## Source of inspiration

Based on the [Docker "Official Image"] for [`python`] using the following `Dockerfile`s:

- [`2.7/buster/slim`]
- [`3.10/slim-bullseye`]
- [`3.11/slim-bullseye`]
- [`3.12/slim-bullseye`]

<!-- Dockerfiles -->
[`3.12`, `3.12.2`, `latest`]: https://github.com/coatl-dev/docker-six/blob/HEAD/3.12/Dockerfile
[`3.11`, `3.11.8`]: https://github.com/coatl-dev/docker-six/blob/HEAD/3.11/Dockerfile
[`3.10`, `3.10.13`]: https://github.com/coatl-dev/docker-six/blob/HEAD/3.10/Dockerfile
[`3.13.0a4`]: https://github.com/coatl-dev/docker-six/blob/HEAD/3.13/Dockerfile
<!-- External links -->
[Azure Pipelines]: https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/jobs-job-container?view=azure-pipelines
[click here]: https://hub.docker.com/repository/docker/coatldev/six/tags
[GitHub Workflows]: https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container
[Docker "Official Image"]: https://github.com/docker-library/official-images#what-are-official-images
[`python`]: https://hub.docker.com/_/python/
<!-- Inspiration -->
[`2.7/buster/slim`]: https://github.com/docker-library/python/blob/f1e613f48eb4fc88748b36787f5ed74c14914636/2.7/buster/slim/Dockerfile
[`3.10/slim-bullseye`]: https://github.com/docker-library/python/blob/HEAD/3.10/slim-bullseye/Dockerfile
[`3.11/slim-bullseye`]: https://github.com/docker-library/python/blob/HEAD/3.11/slim-bullseye/Dockerfile
[`3.12/slim-bullseye`]: https://github.com/docker-library/python/blob/HEAD/3.12/slim-bullseye/Dockerfile
