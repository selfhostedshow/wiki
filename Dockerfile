FROM squidfunk/mkdocs-material:latest

COPY requirements.txt /docs/requirements.txt

RUN pip install -U -r /docs/requirements.txt
