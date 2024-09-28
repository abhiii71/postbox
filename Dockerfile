### Stage 1
FROM python:3.11-slim AS build

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/abhiii71/postbox.git

WORKDIR /app/postbox/flask/examples/tutorial

RUN python3 -m venv .venv

RUN . .venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -e . && \
    pip install '.[test]'

### Stage 2
FROM python:3.11-alpine  AS runtime

WORKDIR /app

COPY --from=build /app/postbox/flask/examples/tutorial/.venv .venv
COPY --from=build /app/postbox/flask/examples/tutorial/flaskr ./flaskr

EXPOSE 5000

CMD ["/bin/bash", "-c", " . .venv/bin/activate && flask --app flaskr run --debug --host=0.0.0.0"]
