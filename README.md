# llm_playground

docker run --name kk_container -p 8888:8888 -v /home/db21051/Desktop/docker_workspace:/workspace/ -it --gpus all e087 bash

jupyter lab --ip 0.0.0.0 --port 8888 --no-browser --allow-root

code --no-sandbox --user-data-dir /home/db21051/Desktop/vscode_user_data

watch -n0.1 nvidia-smi

docker run --name python_container -v /home/db21051/Desktop/python_workspace:/workspace/ -it fad0 bash

docker run -itd --name ollama_1.0 -v /home/db21051/Desktop/docker_workspace:/root/workspace/ -p 11434:11434 -p 8888:8888 --gpus all 3257

docker run -itd --name ollama_1.0 -v /home/db21051/Desktop/docker_workspace:/root/workspace/ -p 11434:11434 -p 8888:8888 --device nvidia.com/gpu=all 356

flatpak run io.podman_desktop.PodmanDesktop

# os.environ["LANGCHAIN_API_KEY"]="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"
# os.environ["TAVILY_API_KEY"] = "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"