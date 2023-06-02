# coatldev/six

Docker image with Python 2 and 3 pre-installed with [`pyenv`] using Ubuntu 22.04 (Jammy Jellyfish).

## Supported tags

- `3.10.11b1` - Comes with Python 3.10.11 and 2.7.18.

## How to use this image

The examples below will demonstrate how to use this image in [Azure pipelines], and [GitHub workflows].

### Azure Pipelines

```yml
jobs:
  - job: tox

    pool:
      vmImage: ubuntu-latest

    container:
      image: coatldev/six:3.10.11b1

    steps:
      - script: |
          echo '##vso[task.prependpath]/home/vsts_azpcontainer/.local/bin'
        displayName: Modify PATH

      - script: |
          sudo chown -R vsts_azpcontainer:azure_pipelines_sudo /opt/pyenv
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
    container:
      image: coatldev/six:3.10.11b1

    steps:
      - name: Checkout repo
        uses: actions/checkout@v3

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip tox

      - name: Run tests
        run: |
          tox
```

## Source of inspiration

Based on [vicamo/docker-pyenv/jammy/slim].

[`pyenv`]: https://github.com/pyenv/pyenv
[Azure pipelines]: https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/jobs-job-container?view=azure-pipelines
[GitHub workflows]: https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container
[vicamo/docker-pyenv/jammy/slim]: https://github.com/vicamo/docker-pyenv/blob/259cc288f846c07dee6d8ed7790cf86be4aaa3d1/jammy/slim/Dockerfile
