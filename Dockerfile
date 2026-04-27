ARG MANYLINUX_VERSION=manylinux_2_34_x86_64
FROM quay.io/pypa/${MANYLINUX_VERSION}

LABEL version="2025.8.0" maintainer="shenyulu"
ARG ONEAPI_VERSION=2025.3.1

WORKDIR /root

# AlmaLinux mirror
# RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' -e 's|^# baseurl=https://repo.almalinux.org|baseurl=https://mirrors.aliyun.com|g' -i.bak /etc/yum.repos.d/almalinux*.repo

# Install AlmaLinux packages
COPY /config /etc/yum.repos.d

# print available versions
RUN yum --showduplicates list Intel-fortran-essentials || true
RUN yum --showduplicates list intel-oneapi-compiler-fortran || true
RUN yum --showduplicates list intel-oneapi-mkl-devel || true
RUN yum --showduplicates list intel-oneapi-mpi-devel || true


RUN yum install -y wget
RUN yum -y install \
    intel-oneapi-mkl-devel-${ONEAPI_VERSION}* \
    intel-oneapi-mpi-devel-${ONEAPI_VERSION}* \
    intel-oneapi-compiler-fortran-${ONEAPI_VERSION}* \
    && yum clean all

# Build Python Environment
RUN /opt/python/cp313-cp313/bin/python -m venv venv_py313
RUN /opt/python/cp312-cp312/bin/python -m venv venv_py312
RUN /opt/python/cp311-cp311/bin/python -m venv venv_py311
RUN /opt/python/cp310-cp310/bin/python -m venv venv_py310
RUN /opt/python/cp314-cp314/bin/python -m venv venv_py314