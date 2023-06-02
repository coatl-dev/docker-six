FROM --platform=linux/amd64 ubuntu:jammy AS base

# set environment variables
ENV PYENV_ROOT="/opt/pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV PIP_ROOT_USER_ACTION="ignore"

# base dependencies
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update --quiet; \
    apt-get install  --yes --no-install-recommends \
        gnupg \
        software-properties-common \
    ; \
    add-apt-repository ppa:git-core/ppa -y; \
    apt-get update --quiet; \
    apt-get install --yes --no-install-recommends \
        bzip2 \
        ca-certificates \
        curl \
        git \
        libexpat1 \
        $(apt-cache search --names-only 'libffi[0-9]+$' 2>/dev/null | awk '{print $1}') \
        $(apt-cache search --names-only 'libmpdec[0-9]+$' 2>/dev/null | awk '{print $1}') \
        libncursesw5 \
        $(apt-cache show libncursesw6 >/dev/null 2>&1 && echo libncursesw6 || true) \
        $(apt-cache search --names-only 'libreadline[0-9]+$' 2>/dev/null | awk '{print $1}') \
        libsqlite3-0 \
        $(apt-cache search --names-only 'libssl[0-9]' 2>/dev/null | awk '{print $1}') \
        lzma \
        sudo \
        zlib1g \
    ; \
    rm -rf /var/lib/apt/lists/*

# install pyenv
RUN set -eux; \
    curl -sL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash; \
    pyenv update

# > =============================================================== <

FROM base AS builder

# runtime dependencies
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update --quiet; \
    apt-get install --yes --no-install-recommends \
        build-essential \
        gdb \
        lcov \
        libbz2-dev \
        libffi-dev \
        libgdbm-compat-dev \
        libgdbm-dev \
        libmpdec-dev \
        liblzma-dev \
        libncursesw5-dev \
        $(apt-cache show libncurses-dev >/dev/null 2>&1 && echo libncurses-dev || true) \
        libreadline6-dev \
        libsqlite3-dev \
        libssl-dev \
        lzma \
        lzma-dev \
        pkg-config \
        tk-dev \
        uuid-dev \
        zlib1g-dev \
    ; \
    rm -rf /var/lib/apt/lists/*

# > =============================================================== <

FROM builder AS build-all

ARG PYTHON_VERSIONS="2.7.18 3.10.11"
ARG ALLOW_FAILURES=

# install python versions
RUN set -eux; \
    for version in ${PYTHON_VERSIONS}; do \
        env PYTHON_CONFIGURE_OPTS=" \
            --enable-shared \
            --enable-loadable-sqlite-extensions \
            --with-lto \
            --with-system-expat \
            --with-system-ffi \
            --with-system-mpdec \
            " \
            pyenv install ${version} || test -n "${ALLOW_FAILURES}"; \
    done; \
    \
    find ${PYENV_ROOT}/versions -depth \
        \( \
            \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
            -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
            -o \( -type f -a -name 'wininst-*.exe' \) \
        \) -exec rm -rf '{}' +

# > =============================================================== <

FROM base

COPY --from=build-all ${PYENV_ROOT}/versions/ ${PYENV_ROOT}/versions/
COPY ./pyenv-plugins/rehash.bash "${PYENV_ROOT}/plugins/pyenv-rehash/etc/pyenv.d/exec/"

# set global pyenv versions
RUN set -eux; \
    pyenv rehash; \
    pyenv global $(pyenv versions --bare | tac)

# update python3 packages
RUN set -eux; \
    python3 -m pip install --no-cache-dir --upgrade pip setuptools; \
    pyenv rehash

# update python2 packages
RUN set -eux; \
    python2 -m pip install --no-cache-dir --upgrade pip setuptools; \
    pyenv rehash

# git config "hack"
RUN set -eux; \
    git config --system --add safe.directory '*'
