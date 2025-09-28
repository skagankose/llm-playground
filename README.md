This repo is my sandbox for LLMs and generative AI—an experimental playground where I try ideas fast and break things even faster. You’ll find small scripts and notebooks, quick proofs-of-concept, and code snippets ranging from “works great” to “left here as a reminder of what not to do.” Expect rough edges, missing tests, and occasional breaking changes as I iterate. Use anything at your own risk, pin dependencies where possible, and read the comments for context and references.

## References (for myself)
<code>
docker run --name kk_container -p 8888:8888 -v /home/db21051/Desktop/docker_workspace:/workspace/ -it --gpus all e087 bash
jupyter lab --ip 0.0.0.0 --port 8888 --no-browser --allow-root
code --no-sandbox --user-data-dir /home/db21051/Desktop/other/vscode_user_data
watch -n0.1 nvidia-smi
docker run --name python_container -v /home/db21051/Desktop/python_workspace:/workspace/ -it fad0 bash
docker run -itd --name ollama_1.0 -v /home/db21051/Desktop/docker_workspace:/root/workspace/ -p 11434:11434 -p 8888:8888 --gpus all 3257
docker run -itd --name ollama_1.0 -v /home/db21051/Desktop/docker_workspace:/root/workspace/ -p 11434:11434 -p 8888:8888 --device nvidia.com/gpu=all 356
docker run -it -d -p 8888:8888 --name generic_python -v /home/db21051/Desktop/repositories/llm_playground/sandbox/:/home/sandbox/ --gpus all cbcc
podman run -it -d -p 8888:8888 --name generic_python -v /home/db21051/Desktop/repositories/llm_playground/sandbox/:/home/sandbox/ --device nvidia.com/gpu=all cbcc
flatpak run io.podman_desktop.PodmanDesktop
# os.environ["LANGCHAIN_API_KEY"]=""
# os.environ["TAVILY_API_KEY"] = ""
sudo ntfsfix -d -b /dev/sda1
docker compose --profile gpu-nvidia up  
</code>

<code>
docker compose exec backend alembic revision --autogenerate -m "add_new_column"
docker compose exec backend alembic upgrade head
docker compose down -v
docker compose up --build

cd backend
pip install python-jose[cryptography] passlib[bcrypt] python-multipart

cd ../frontend
npm install @chakra-ui/react @emotion/react @emotion/styled framer-motion

DROP TABLE messages, users CASCADE;

docker rm -vf $(docker ps -aq)

docker rmi -f $(docker images -aq)
</code>

<code>
- add flowise: https://www.youtube.com/watch?v=9R5zo3IVkqU
- add ci/cd for airs(?)
- database büşra < arda
- active directory hüseyin yay
- cursor ai alim dokumani yaz
</code>
