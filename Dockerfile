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
ENV PYTHON3_VERSION 3.10.12

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
        git \
        libpython2.7 \
        libpython3.10 \
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
        gcc \
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

FROM builder AS python27

WORKDIR /tmp

RUN set -eux; \
    \
    wget -q "https://www.python.org/ftp/python/${PYTHON2_VERSION%%[a-z]*}/Python-$PYTHON2_VERSION.tgz"; \
    tar xzf "Python-$PYTHON2_VERSION.tgz"

WORKDIR "/tmp/Python-$PYTHON2_VERSION"

RUN set -eux; \
    \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure \
        --build="$gnuArch" \
        --prefix="${PYTHON_ROOT}/2.7/" \
        --enable-optimizations \
        --enable-option-checking=fatal \
        --enable-shared \
        --enable-unicode=ucs4 \
    ; \
    make -j "$(nproc)" \
# setting PROFILE_TASK makes "--enable-optimizations" reasonable: https://bugs.python.org/issue36044 / https://github.com/docker-library/python/issues/160#issuecomment-509426916
        PROFILE_TASK='-m test.regrtest --pgo \
            test_array \
            test_base64 \
            test_binascii \
            test_binhex \
            test_binop \
            test_bytes \
            test_c_locale_coercion \
            test_class \
            test_cmath \
            test_codecs \
            test_compile \
            test_complex \
            test_csv \
            test_decimal \
            test_dict \
            test_float \
            test_fstring \
            test_hashlib \
            test_io \
            test_iter \
            test_json \
            test_long \
            test_math \
            test_memoryview \
            test_pickle \
            test_re \
            test_set \
            test_slice \
            test_struct \
            test_threading \
            test_time \
            test_traceback \
            test_unicode \
        ' \
    ; \
    make altinstall; \
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
    "${PYTHON_ROOT}/2.7/bin/python2.7" -m ensurepip --default-pip; \
    "${PYTHON_ROOT}/2.7/bin/python2.7" -m pip install --upgrade pip setuptools wheel

# add some soft links for comfortable usage
WORKDIR "${PYTHON_ROOT}/2.7/bin"
RUN set -eux; \
    \
    ln -s idle idle2; \
    ln -s python2.7 python2; \
    ln -s python2 python; \
    ln -s python2.7-config python-config

# > =============================================================== <

FROM builder AS python310

WORKDIR /tmp

RUN set -eux; \
    \
    wget -q "https://www.python.org/ftp/python/${PYTHON3_VERSION%%[a-z]*}/Python-$PYTHON3_VERSION.tgz"; \
    tar xzf "Python-$PYTHON3_VERSION.tgz"

WORKDIR "/tmp/Python-$PYTHON3_VERSION"

RUN set -eux; \
    \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure \
        --build="$gnuArch" \
        --prefix="${PYTHON_ROOT}/3.10/" \
        --enable-loadable-sqlite-extensions \
        --enable-optimizations \
        --enable-option-checking=fatal \
        --enable-shared \
        --with-lto \
        --with-system-expat \
    ; \
    nproc="$(nproc)"; \
    EXTRA_CFLAGS="$(dpkg-buildflags --get CFLAGS)"; \
    LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"; \
    LDFLAGS="${LDFLAGS:--Wl},--strip-all"; \
    make -j "$nproc" \
        "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
        "LDFLAGS=${LDFLAGS:-}" \
        "PROFILE_TASK=${PROFILE_TASK:-}" \
    ; \
# https://github.com/docker-library/python/issues/784
# prevent accidental usage of a system installed libpython of the same version
    rm python; \
    make -j "$nproc" \
        "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
        "LDFLAGS=${LDFLAGS:--Wl},-rpath='\$\$ORIGIN/../lib'" \
        "PROFILE_TASK=${PROFILE_TASK:-}" \
        python \
    ; \
    make altinstall; \
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
    "${PYTHON_ROOT}/3.10/bin/python3.10" -m pip install --upgrade pip setuptools wheel

# add some soft links for comfortable usage
WORKDIR "${PYTHON_ROOT}/3.10/bin"
RUN set -eux; \
    \
    ln -s idle3.10 idle3; \
    ln -s idle3 idle; \
    ln -s pydoc3.10 pydoc; \
    ln -s python3.10 python3; \
    ln -s python3 python; \
    ln -s python3.10-config python-config

# > =============================================================== <

FROM base AS final

COPY --from=python27 ${PYTHON_ROOT}/2.7/ ${PYTHON_ROOT}/2.7/
COPY --from=python310 ${PYTHON_ROOT}/3.10/ ${PYTHON_ROOT}/3.10/

# ensure local python is preferred over distribution python
ENV PATH ${PYTHON_ROOT}/3.10/bin:${PYTHON_ROOT}/2.7/bin:$PATH

# git config "hack"
RUN set -eux; \
    \
    git config --system --add safe.directory '*'
