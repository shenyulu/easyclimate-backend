# Build an Image
# ------------------------------------------------
docker build -t my-image .

# Run container
docker run -d --name my_container my-image tail -f /dev/null

# Build env
# ------------------------------------------------
repository_path=/root/easyclimate-backend
repository_python_build_requirement=/root/easyclimate-backend/scripts/build_requirement_manylinux.txt

# copy repo
docker cp . my_container:${repository_path}
# PyPI mirror
docker exec my_container /root/venv_py313/bin/python -m pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

# Install Packages for Python Environment
docker exec my_container /root/venv_py313/bin/python -m pip install -r ${repository_python_build_requirement}
docker exec my_container bash -c "source /root/venv_py313/bin/activate && cd ${repository_path} && source /opt/intel/oneapi/setvars.sh --force && bash ./scripts/build_wheel_manylinux.sh && cd /root"

docker exec my_container /root/venv_py312/bin/python -m pip install -r ${repository_python_build_requirement}
docker exec my_container bash -c "source /root/venv_py312/bin/activate && cd ${repository_path} && source /opt/intel/oneapi/setvars.sh --force && bash ./scripts/build_wheel_manylinux.sh && cd /root"

docker exec my_container /root/venv_py311/bin/python -m pip install -r ${repository_python_build_requirement}
docker exec my_container bash -c "source /root/venv_py311/bin/activate && cd ${repository_path} && source /opt/intel/oneapi/setvars.sh --force && bash ./scripts/build_wheel_manylinux.sh && cd /root"

docker exec my_container /root/venv_py310/bin/python -m pip install -r ${repository_python_build_requirement}
docker exec my_container bash -c "source /root/venv_py310/bin/activate && cd ${repository_path} && source /opt/intel/oneapi/setvars.sh --force && bash ./scripts/build_wheel_manylinux.sh && cd /root"

# Copy file from the container to the host
# ------------------------------------------------
docker cp my_container:/root/easyclimate-backend/wheelhouse ./wheelhouse
# docker cp my-container:/root/easyclimate-backend/dist ./dist

# Delete the container and image
# ------------------------------------------------
docker rm -f my_container
# docker rmi my-image
cp ./wheelhouse/*.whl ./dist
rm -r ./wheelhouse
