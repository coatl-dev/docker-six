# coatldev/six

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/coatl-dev/docker-six/coatl.svg)](https://results.pre-commit.ci/latest/github/coatl-dev/docker-six/coatl)
![Docker Pulls](https://img.shields.io/docker/pulls/coatldev/six)

Docker image based on Ubuntu 24.04 (Noble Numbat) with Python 2.7.18, Python 3
and [Jython](#jython) pre-installed.

## Supported tags

### Python

- [`3.12`, `3.12.3`, `latest`] - Comes with Python 3.12.3 and 2.7.18.
- [`3.11`, `3.11.9`] - Comes with Python 3.11.9 and 2.7.18.
- [`3.10`, `3.10.14`] - Comes with Python 3.10.14 and 2.7.18.
- [`3.9`, `3.9.19`] - Comes with Python 3.9.19 and 2.7.18.
- [`3.8`, `3.8.19`] - Comes with Python 3.8.19 and 2.7.18.

#### Python Alpha, Beta and Release Candidates

- [`3.13.0b1`] - Comes with Python 3.13.0b1 and 2.7.18.

### Jython

- [`jython-3.8`, `jython-3.8.19`] - Comes with Python 3.8.19 and 2.7.18.

#### Jython Alpha, Beta and Release Candidates

- [`jython-3.13.0b1`] - Comes with Python 3.13.0b1, 2.7.18 and Jython 2.7.3.

For more tags, [click here].

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

    container: coatldev/six:latest

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

    container: coatldev/six:latest

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

Based on the [Docker "Official Image"] for [`python`] using the following
`Dockerfile`s:

- [`2.7/buster/slim`]
- [`3.13-rc/slim-bullseye`]
- [`3.12/slim-bullseye`]
- [`3.11/slim-bullseye`]
- [`3.10/slim-bullseye`]
- [`3.9/slim-bullseye`]
- [`3.8/slim-bullseye`]

<!-- Dockerfiles -->
[`3.13.0b1`]: https://github.com/coatl-dev/docker-six/blob/HEAD/3.13/python/Dockerfile
[`3.12`, `3.12.3`, `latest`]: https://github.com/coatl-dev/docker-six/blob/HEAD/3.12/python/Dockerfile
[`3.11`, `3.11.9`]: https://github.com/coatl-dev/docker-six/blob/HEAD/3.11/python/Dockerfile
[`3.10`, `3.10.14`]: https://github.com/coatl-dev/docker-six/blob/HEAD/3.10/python/Dockerfile
[`3.9`, `3.9.19`]: https://github.com/coatl-dev/docker-six/blob/HEAD/3.9/python/Dockerfile
[`3.8`, `3.8.19`]: https://github.com/coatl-dev/docker-six/blob/HEAD/3.8/python/Dockerfile
[`jython-3.8`, `jython-3.8.19`]: https://github.com/coatl-dev/docker-six/blob/HEAD/3.8/jython/Dockerfile
[`jython-3.13.0b1`]: https://github.com/coatl-dev/docker-six/blob/HEAD/3.13/jython/Dockerfile
<!-- External links -->
[Azure Pipelines]: https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/jobs-job-container?view=azure-pipelines
[click here]: https://hub.docker.com/repository/docker/coatldev/six/tags
[GitHub Workflows]: https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container
[Docker "Official Image"]: https://github.com/docker-library/official-images#what-are-official-images
[`python`]: https://hub.docker.com/_/python/
<!-- Inspiration -->
[`2.7/buster/slim`]: https://github.com/docker-library/python/blob/f1e613f48eb4fc88748b36787f5ed74c14914636/2.7/buster/slim/Dockerfile
[`3.13-rc/slim-bullseye`]: https://github.com/docker-library/python/blob/HEAD/3.13-rc/slim-bullseye/Dockerfile
[`3.12/slim-bullseye`]: https://github.com/docker-library/python/blob/HEAD/3.12/slim-bullseye/Dockerfile
[`3.11/slim-bullseye`]: https://github.com/docker-library/python/blob/HEAD/3.11/slim-bullseye/Dockerfile
[`3.10/slim-bullseye`]: https://github.com/docker-library/python/blob/HEAD/3.10/slim-bullseye/Dockerfile
[`3.9/slim-bullseye`]: https://github.com/docker-library/python/blob/HEAD/3.9/slim-bullseye/Dockerfile
[`3.8/slim-bullseye`]: https://github.com/docker-library/python/blob/HEAD/3.8/slim-bullseye/Dockerfile
