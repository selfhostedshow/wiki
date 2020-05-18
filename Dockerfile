FROM squidfunk/mkdocs-material:latest

COPY requirements.txt /docs/requirements.txt

RUN pip install -U -r /docs/requirements.txt

# Work around for https://github.com/squidfunk/mkdocs-material/pull/1712
CMD ["serve", "--dev-addr=0.0.0.0:8000"]
