FROM quay.io/pypa/manylinux_2_34_x86_64

LABEL version="2025.3.0" maintainer="shenyulu"

# Variables
ARG repository_path=/root/easyclimate-backend
ARG repository_python_build_requirement=/root/easyclimate-backend/build_requirement_manylinux.txt

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

# Git Clone Repository
COPY . ${repository_path}

# Pypi mirror
RUN /root/venv_py313/bin/python -m pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

# Install Packages for Python Environment
RUN /root/venv_py313/bin/python -m pip install -r ${repository_python_build_requirement}
RUN source /root/venv_py313/bin/activate && cd ${repository_path} && source /opt/intel/oneapi/setvars.sh --force && bash ./build_wheel_manylinux.sh && cd /root

RUN /root/venv_py312/bin/python -m pip install -r ${repository_python_build_requirement}
RUN source /root/venv_py312/bin/activate && cd ${repository_path} && source /opt/intel/oneapi/setvars.sh --force && bash ./build_wheel_manylinux.sh && cd /root

RUN /root/venv_py311/bin/python -m pip install -r ${repository_python_build_requirement}
RUN source /root/venv_py311/bin/activate && cd ${repository_path} && source /opt/intel/oneapi/setvars.sh --force && bash ./build_wheel_manylinux.sh && cd /root

RUN /root/venv_py310/bin/python -m pip install -r ${repository_python_build_requirement}
RUN source /root/venv_py310/bin/activate && cd ${repository_path} && source /opt/intel/oneapi/setvars.sh --force && bash ./build_wheel_manylinux.sh && cd /root
