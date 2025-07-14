ARG MANYLINUX_VERSION=manylinux_2_34_x86_64
FROM quay.io/pypa/${MANYLINUX_VERSION}

LABEL version="2025.8.0" maintainer="shenyulu"

WORKDIR /root

# AlmaLinux mirror
RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' -e 's|^# baseurl=https://repo.almalinux.org|baseurl=https://mirrors.aliyun.com|g' -i.bak /etc/yum.repos.d/almalinux*.repo

# Install AlmaLinux packages
COPY /config /etc/yum.repos.d
RUN yum install -y wget
RUN yum install -y intel-oneapi-hpc-toolkit
RUN yum clean all

# Build Python Environment
RUN /opt/python/cp313-cp313/bin/python -m venv venv_py313
RUN /opt/python/cp312-cp312/bin/python -m venv venv_py312
RUN /opt/python/cp311-cp311/bin/python -m venv venv_py311
RUN /opt/python/cp310-cp310/bin/python -m venv venv_py310
RUN /opt/python/cp314-cp314/bin/python -m venv venv_py314