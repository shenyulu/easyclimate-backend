docker run -d --name="test2" my-image tail -f /dev/null
exit
docker exec test2 /root/venv_py313/bin/python -m pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

