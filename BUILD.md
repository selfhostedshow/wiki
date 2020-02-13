## Build locally

- Clone the repository and `cd` into the directory:

```bash
git clone https://github.com/selfhostedshow/wiki ~/wiki &&\
	cd ~/wiki
```

- Make changes as necessary.

- Start development server on http://localhost:8000:

```bash
docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material
```
