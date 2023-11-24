FROM ubuntu:jammy AS base

LABEL \
    maintainer="César Román <cesar@coatl.dev>" \
    repository="https://github.com/coatl-dev/docker-six" \
    vendor="coatl.dev"

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8
# https://github.com/docker-library/python/issues/147
ENV PYTHONIOENCODING UTF-8

# pip
ENV PIP_NO_CACHE_DIR 1
ENV PIP_NO_PYTHON_VERSION_WARNING 1
ENV PIP_ROOT_USER_ACTION ignore

# python
ENV PYTHON_ROOT /opt/python
ENV PYTHON2_VERSION 2.7.18
ENV PYTHON3_VERSION 3.13.0a2

# base dependencies
RUN set -eux; \
    \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update --quiet; \
    apt-get install --yes --no-install-recommends \
        gnupg \
        software-properties-common \
    ; \
    add-apt-repository ppa:git-core/ppa -y; \
    apt-get install --yes --no-install-recommends \
        bzip2 \
        ca-certificates \
        gcc \
        git \
        netbase \
        sudo \
        tzdata \
    ; \
    rm -rf /var/lib/apt/lists/*

# > =============================================================== <

FROM base as builder

RUN set -eux; \
    \
    apt-get update --quiet; \
    apt-get install --yes --no-install-recommends \
        build-essential \
        dirmngr \
        dpkg-dev \
        gnupg \
        libbluetooth-dev \
        libbz2-dev \
        libc6-dev \
        libdb-dev \
        libexpat1-dev \
        libffi-dev \
        libgdbm-dev \
        liblzma-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        llvm \
        make \
        tk-dev \
        uuid-dev \
        wget \
        xz-utils \
        zlib1g-dev \
    ; \
    rm -rf /var/lib/apt/lists/*

# > =============================================================== <

FROM builder AS python2

WORKDIR /tmp

RUN set -eux; \
    \
    wget -q "https://www.python.org/ftp/python/${PYTHON2_VERSION%%[a-z]*}/Python-$PYTHON2_VERSION.tgz"; \
    tar xzf "Python-$PYTHON2_VERSION.tgz"

WORKDIR "/tmp/Python-$PYTHON2_VERSION"

RUN set -eux; \
    \
    ./configure \
        --prefix="${PYTHON_ROOT}/2/" \
        --enable-optimizations \
        --enable-shared \
        --enable-unicode=ucs4 \
    ; \
    make -j "$(nproc)"; \
    \
    make altinstall; \
    \
    ARCH="$(arch)"; \
    ln -s "${PYTHON_ROOT}/2/lib/libpython${PYTHON2_VERSION%.*}.so.1.0" "/usr/lib/${ARCH}-linux-gnu/libpython${PYTHON2_VERSION%.*}.so.1.0"; \
    ln -s "/usr/lib/${ARCH}-linux-gnu/libpython${PYTHON2_VERSION%.*}.so.1.0" "/usr/lib/${ARCH}-linux-gnu/libpython${PYTHON2_VERSION%.*}.so.1"; \
    \
    find "${PYTHON_ROOT}" -depth \
        \( \
            \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf '{}' + \
    ; \
    rm "/tmp/Python-$PYTHON2_VERSION.tgz"

# update Pip, Setuptools and Wheel packages
RUN set -eux; \
    \
    "${PYTHON_ROOT}/2/bin/python${PYTHON2_VERSION%.*}" -m ensurepip --default-pip; \
    "${PYTHON_ROOT}/2/bin/python${PYTHON2_VERSION%.*}" -m pip install --upgrade pip setuptools wheel

# add some soft links for comfortable usage
WORKDIR "${PYTHON_ROOT}/2/bin"
RUN set -eux; \
    \
    ln -s idle idle2; \
    ln -s "python${PYTHON2_VERSION%.*}" python2; \
    ln -s "python${PYTHON2_VERSION%.*}" python; \
    ln -s "python${PYTHON2_VERSION%.*}-config" python-config

# > =============================================================== <

FROM builder AS python3

WORKDIR /tmp

RUN set -eux; \
    \
    wget -q "https://www.python.org/ftp/python/${PYTHON3_VERSION%%[a-z]*}/Python-$PYTHON3_VERSION.tgz"; \
    tar xzf "Python-$PYTHON3_VERSION.tgz"

WORKDIR "/tmp/Python-$PYTHON3_VERSION"

RUN set -eux; \
    \
    ./configure \
        --prefix="${PYTHON_ROOT}/3/" \
        --enable-loadable-sqlite-extensions \
        --enable-optimizations \
        --enable-shared \
        --with-lto \
        --with-system-expat \
    ; \
    \
    make -j "$(nproc)"; \
    \
    make altinstall; \
    \
    ARCH="$(arch)"; \
    ln -s "${PYTHON_ROOT}/3/lib/libpython${PYTHON3_VERSION%.*}.so.1.0" "/usr/lib/${ARCH}-linux-gnu/libpython${PYTHON3_VERSION%.*}.so.1.0"; \
    ln -s "/usr/lib/${ARCH}-linux-gnu/libpython${PYTHON3_VERSION%.*}.so.1.0" "/usr/lib/${ARCH}-linux-gnu/libpython3.so.1"; \
    \
     find "${PYTHON_ROOT}" -depth \
        \( \
            \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
            -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \
        \) -exec rm -rf '{}' + \
    ; \
    rm "/tmp/Python-$PYTHON3_VERSION.tgz"

# update Pip, Setuptools and Wheel packages
RUN set -eux; \
    \
    "${PYTHON_ROOT}/3/bin/python${PYTHON3_VERSION%.*}" -m pip install --upgrade pip setuptools wheel

# add some soft links for comfortable usage
WORKDIR "${PYTHON_ROOT}/3/bin"
RUN set -eux; \
    \
    ln -s "idle${PYTHON3_VERSION%.*}" idle; \
    ln -s "idle${PYTHON3_VERSION%.*}" idle3; \
    ln -s "pydoc${PYTHON3_VERSION%.*}" pydoc; \
    ln -s "python${PYTHON3_VERSION%.*}" python3; \
    ln -s "python${PYTHON3_VERSION%.*}" python; \
    ln -s "python${PYTHON3_VERSION%.*}-config" python-config

# > =============================================================== <

FROM base AS final

COPY --from=python2 ${PYTHON_ROOT}/2/ ${PYTHON_ROOT}/2/
COPY --from=python3 ${PYTHON_ROOT}/3/ ${PYTHON_ROOT}/3/

# ensure local python is preferred over distribution python
ENV PATH ${PYTHON_ROOT}/3/bin:${PYTHON_ROOT}/2/bin:$PATH

# link Python libraries
RUN set -eux; \
    \
    ARCH="$(arch)"; \
    ln -s "${PYTHON_ROOT}/2/lib/libpython${PYTHON2_VERSION%.*}.so.1.0" "/usr/lib/${ARCH}-linux-gnu/libpython${PYTHON2_VERSION%.*}.so.1.0"; \
    ln -s "/usr/lib/${ARCH}-linux-gnu/libpython${PYTHON2_VERSION%.*}.so.1.0" "/usr/lib/${ARCH}-linux-gnu/libpython${PYTHON2_VERSION%.*}.so.1"; \
    ln -s "${PYTHON_ROOT}/3/lib/libpython${PYTHON3_VERSION%.*}.so.1.0" "/usr/lib/${ARCH}-linux-gnu/libpython${PYTHON3_VERSION%.*}.so.1.0"; \
    ln -s "/usr/lib/${ARCH}-linux-gnu/libpython${PYTHON3_VERSION%.*}.so.1.0" "/usr/lib/${ARCH}-linux-gnu/libpython3.so.1"

# git config "hack"
RUN set -eux; \
    \
    git config --system --add safe.directory '*'
