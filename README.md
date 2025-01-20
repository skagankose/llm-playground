# llm_playground
<code>
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
</code>

<code>
- message input field not focused when new chat button is clicked
- limit input fields for admin(?)
- maybe reverse date sort message history
- make renew button work Turkish work
- make a load test, add timer for waiting for response(?)
- long names tooltip addition
- when it took too long to take response it bugged(?)
- allow access form same local network
- check for "sisme" when message etc. too much
- optional feedback lagy when too much message(?)
- good suggestion when new chat
- launching ideas moves bottom message(?)
- when new chat comes, does not scroll down(?)
- add regenerated_date or flag
- categorize former sessions with tags(?)
- give him a voice(?)
- adjust mobile use(?)
- add right panel for anything really(?)
- add check mechanisms like unit tests(?)
- production: remove not required (e.g. openwebui)
- only limited conversation history issue(?)
- if refreshed on user page, stay there(?)
- if there is too many message the user detail opening might be lagy(?s)
- test overall system(?)
- check if stop generation stops ollama
- make streaming(?)
- if only single world malicious input, the history brokes visually
- add ability to remove messages or session to admin for all users(?)
</code>

<code>
- add flowise: https://www.youtube.com/watch?v=9R5zo3IVkqU
- add ci/cd for airs(?)
- database büşra < arda
- active directory hüseyin yay
- cursor ai alim dokumani yaz
</code>
