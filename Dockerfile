FROM ubuntu:noble AS base

LABEL \
    maintainer="César Román <cesar@coatl.dev>" \
    repository="https://github.com/coatl-dev/docker-six" \
    vendor="coatl.dev"

ENV DEBIAN_FRONTEND=noninteractive

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG=C.UTF-8

ENV PYTHON_ROOT=/opt/python

# https://github.com/docker-library/python/issues/147
ENV PYTHONIOENCODING=UTF-8

ENV PIP_NO_CACHE_DIR=1
ENV PIP_NO_PYTHON_VERSION_WARNING=1
ENV PIP_ROOT_USER_ACTION=ignore

# install base dependencies
RUN set -eux; \
    \
    apt-get update --quiet; \
    apt-get upgrade --yes; \
    apt-get install --yes --no-install-recommends \
        apt-utils \
        build-essential \
        ca-certificates \
        curl \
        git-man \
        libcurl3t64-gnutls \
        liberror-perl \
        libexpat1 \
        libsqlite3-0 \
        netbase \
        sudo \
        tzdata \
        wget \
    ; \
    rm -rf /var/lib/apt/lists/*

# >============================================================================<

FROM base AS builder

RUN set -eux; \
    \
    apt-get update --quiet; \
    apt-get install --yes --no-install-recommends \
        libbluetooth-dev \
        libbz2-dev \
        libc6-dev \
        libcurl4-gnutls-dev \
        libdb-dev \
        libexpat1-dev \
        libffi-dev \
        libgdbm-dev \
        liblzma-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libvips-dev \
        packaging-dev \
        tk-dev \
        uuid-dev \
        xz-utils \
        zlib1g-dev \
    ; \
    rm -rf /var/lib/apt/lists/*

# >============================================================================<

FROM builder AS git-builder

ENV GIT_VERSION=2.47.0

WORKDIR /tmp

RUN set -eux; \
    \
    wget -q "https://github.com/git/git/archive/refs/tags/v${GIT_VERSION}.tar.gz"; \
    tar -zxf "v${GIT_VERSION}.tar.gz"

WORKDIR "/tmp/git-${GIT_VERSION}"

RUN set -eux; \
    \
    make configure; \
    ./configure --prefix=/usr/local; \
    make all; \
    make install

# >============================================================================<

FROM builder AS python27-builder

ENV PYTHON217_VERSION=2.7.18

WORKDIR /tmp

RUN set -eux; \
    \
    wget -q "https://www.python.org/ftp/python/${PYTHON217_VERSION%%[a-z]*}/Python-${PYTHON217_VERSION}.tgz"; \
    tar -zxf "Python-${PYTHON217_VERSION}.tgz"

WORKDIR "/tmp/Python-${PYTHON217_VERSION}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
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
    make --jobs="$(nproc)" \
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
    \
    make altinstall; \
    \
    echo "${PYTHON_ROOT}/2.7/lib" | tee /etc/ld.so.conf.d/python2.7.conf; \
    ldconfig; \
    \
    find "${PYTHON_ROOT}" -depth \
        \( \
            \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf '{}' + \
    ;

# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL=https://raw.githubusercontent.com/pypa/get-pip/HEAD/public/2.7/get-pip.py

RUN set -eux; \
    \
    wget -q "$PYTHON_GET_PIP_URL"; \
	\
	"${PYTHON_ROOT}/2.7/bin/python${PYTHON217_VERSION%.*}" get-pip.py \
		--disable-pip-version-check

# add some soft links for comfortable usage
WORKDIR "${PYTHON_ROOT}/2.7/bin"
RUN set -eux; \
    \
    ln -svT idle idle2; \
    ln -svT "python${PYTHON217_VERSION%.*}" python2; \
    ln -svT "python${PYTHON217_VERSION%.*}" python; \
    ln -svT "python${PYTHON217_VERSION%.*}-config" python-config

# >============================================================================<

FROM builder AS python312-builder

ENV PYTHON312_VERSION=3.12.7

WORKDIR /tmp

RUN set -eux; \
    \
    wget -q "https://www.python.org/ftp/python/${PYTHON312_VERSION%%[a-z]*}/Python-${PYTHON312_VERSION}.tgz"; \
    tar -zxf "Python-${PYTHON312_VERSION}.tgz"

WORKDIR "/tmp/Python-${PYTHON312_VERSION}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN set -eux; \
    \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure \
        --build="$gnuArch" \
        --prefix="${PYTHON_ROOT}/3.12/" \
        --enable-loadable-sqlite-extensions \
        --enable-optimizations \
        --enable-option-checking=fatal \
        --enable-shared \
        --with-lto \
        --with-system-expat \
        --without-ensurepip \
    ; \
	nproc="$(nproc)"; \
	EXTRA_CFLAGS="$(dpkg-buildflags --get CFLAGS)"; \
	LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"; \
	LDFLAGS="${LDFLAGS:--Wl},--strip-all"; \
	make --jobs="$nproc" \
		"EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
		"LDFLAGS=${LDFLAGS:-}" \
		"PROFILE_TASK=${PROFILE_TASK:-}" \
	; \
    \
    # https://github.com/docker-library/python/issues/784
    # prevent accidental usage of a system installed libpython of the same version
    rm python; \
    make --jobs="$nproc" \
        "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
        "LDFLAGS=${LDFLAGS:--Wl},-rpath='\$\$ORIGIN/../lib'" \
        "PROFILE_TASK=${PROFILE_TASK:-}" \
        python \
    ; \
    make altinstall; \
    \
    echo "${PYTHON_ROOT}/3.12/lib" | tee /etc/ld.so.conf.d/python3.12.conf; \
    ldconfig; \
    \
    find "${PYTHON_ROOT}" -depth \
        \( \
            \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
            -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \
        \) -exec rm -rf '{}' + \
    ;

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON312_PIP_VERSION=24.2
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL=https://raw.githubusercontent.com/pypa/get-pip/HEAD/public/get-pip.py

RUN set -eux; \
    \
    wget -q "$PYTHON_GET_PIP_URL"; \
    \
	export PYTHONDONTWRITEBYTECODE=1; \
    \
    "${PYTHON_ROOT}/3.12/bin/python${PYTHON312_VERSION%.*}" get-pip.py \
        --disable-pip-version-check \
        --no-cache-dir \
        --no-compile \
        "pip==$PYTHON312_PIP_VERSION"

# add some soft links for comfortable usage
WORKDIR "${PYTHON_ROOT}/3.12/bin"
RUN set -eux; \
    \
    ln -svT "2to3-${PYTHON312_VERSION%.*}" 2to3; \
    ln -svT "idle${PYTHON312_VERSION%.*}" idle3; \
    ln -svT "idle${PYTHON312_VERSION%.*}" idle; \
    ln -svT "pydoc${PYTHON312_VERSION%.*}" pydoc; \
    ln -svT "python${PYTHON312_VERSION%.*}" python3; \
    ln -svT "python${PYTHON312_VERSION%.*}" python; \
    ln -svT "python${PYTHON312_VERSION%.*}-config" python-config

# >============================================================================<

FROM builder AS python313-builder

ENV PYTHON313_VERSION=3.13.0

WORKDIR /tmp

RUN set -eux; \
    \
    wget -q "https://www.python.org/ftp/python/${PYTHON313_VERSION%%[a-z]*}/Python-${PYTHON313_VERSION}.tgz"; \
    tar -zxf "Python-${PYTHON313_VERSION}.tgz"

WORKDIR "/tmp/Python-${PYTHON313_VERSION}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN set -eux; \
    \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure \
        --build="$gnuArch" \
        --prefix="${PYTHON_ROOT}/3.13/" \
        --enable-loadable-sqlite-extensions \
        --enable-optimizations \
        --enable-option-checking=fatal \
        --enable-shared \
        --with-lto \
        --with-system-expat \
        --without-ensurepip \
    ; \
    nproc="$(nproc)"; \
    EXTRA_CFLAGS="$(dpkg-buildflags --get CFLAGS)"; \
    LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"; \
    LDFLAGS="${LDFLAGS:--Wl},--strip-all"; \
    make --jobs="$nproc" \
        "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
        "LDFLAGS=${LDFLAGS:-}" \
        "PROFILE_TASK=${PROFILE_TASK:-}" \
    ; \
    \
    # https://github.com/docker-library/python/issues/784
    # prevent accidental usage of a system installed libpython of the same version
    rm python; \
    make --jobs="$nproc" \
        "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
        "LDFLAGS=${LDFLAGS:--Wl},-rpath='\$\$ORIGIN/../lib'" \
        "PROFILE_TASK=${PROFILE_TASK:-}" \
        python \
    ; \
    make altinstall; \
    \
    echo "${PYTHON_ROOT}/3.13/lib" | tee /etc/ld.so.conf.d/python3.13.conf; \
    ldconfig; \
    \
    find "${PYTHON_ROOT}" -depth \
        \( \
            \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
            -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \
        \) -exec rm -rf '{}' + \
    ;

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON313_PIP_VERSION=24.2
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL=https://raw.githubusercontent.com/pypa/get-pip/HEAD/public/get-pip.py

RUN set -eux; \
    \
    wget -q "$PYTHON_GET_PIP_URL"; \
    \
    export PYTHONDONTWRITEBYTECODE=1; \
    \
    "${PYTHON_ROOT}/3.13/bin/python${PYTHON313_VERSION%.*}" get-pip.py \
        --disable-pip-version-check \
        --no-cache-dir \
        --no-compile \
        "pip==$PYTHON313_PIP_VERSION"

# add some soft links for comfortable usage
WORKDIR "${PYTHON_ROOT}/3.13/bin"
RUN set -eux; \
    \
    ln -svT "idle${PYTHON313_VERSION%.*}" idle3; \
    ln -svT "idle${PYTHON313_VERSION%.*}" idle; \
    ln -svT "pydoc${PYTHON313_VERSION%.*}" pydoc; \
    ln -svT "python${PYTHON313_VERSION%.*}" python3; \
    ln -svT "python${PYTHON313_VERSION%.*}" python; \
    ln -svT "python${PYTHON313_VERSION%.*}-config" python-config

# >============================================================================<

FROM base AS final

COPY --from=git-builder /usr/local /usr/local
COPY --from=python27-builder ${PYTHON_ROOT}/2.7/ ${PYTHON_ROOT}/2.7/
COPY --from=python27-builder /etc/ld.so.conf.d/python2.7.conf /etc/ld.so.conf.d/python2.7.conf
COPY --from=python312-builder ${PYTHON_ROOT}/3.12/ ${PYTHON_ROOT}/3.12/
COPY --from=python312-builder /etc/ld.so.conf.d/python3.12.conf /etc/ld.so.conf.d/python3.12.conf
COPY --from=python313-builder ${PYTHON_ROOT}/3.13/ ${PYTHON_ROOT}/3.13/
COPY --from=python313-builder /etc/ld.so.conf.d/python3.13.conf /etc/ld.so.conf.d/python3.13.conf

# ensure local python is preferred over distribution python
ENV PATH="${PYTHON_ROOT}/3.13/bin:${PYTHON_ROOT}/3.12/bin:${PYTHON_ROOT}/2.7/bin:$PATH"

# link Python libraries
RUN set -eux; \
    \
    ldconfig

# git config "hack"
RUN set -eux; \
    \
    git config --system --add safe.directory '*'

CMD ["/bin/bash"]
