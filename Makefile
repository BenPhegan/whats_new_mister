
.venv: requirements.txt
	virtualenv .venv
	source .venv/bin/activate && pip install -r requirements.txt

format: | .venv
	source .venv/bin/activate && yapf --style facebook -i whats_new.sh
.PHONY: format