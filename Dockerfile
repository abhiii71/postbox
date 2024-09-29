# Stage 1: Build Stage
FROM python:3.11-slim AS builder

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies for building
RUN apt-get update && apt-get install -y \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone the Flask repository
RUN git clone https://github.com/pallets/flask.git

# Change directory to the examples/tutorial
WORKDIR /app/flask/examples/tutorial

# Checkout the latest tagged version
RUN git fetch --tags && \
    git checkout $(git describe --tags `git rev-list --tags --max-count=1`)

# Create a virtual environment
RUN python3 -m venv .venv

# Upgrade pip and install Flaskr and test dependencies
RUN . .venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -e . && \
    pip install '.[test]'

# Stage 2: Runtime Stage
FROM python:3.11-slim AS runtime

# Set the working directory in the runtime container
WORKDIR /app

# Copy the virtual environment and Flask application from the builder stage
COPY --from=builder /app/flask/examples/tutorial/.venv .venv
COPY --from=builder /app/flask/examples/tutorial/flaskr ./flaskr

# Expose port 5000
EXPOSE 5000

# Command to run the Flask application
CMD ["/bin/bash", "-c", ". .venv/bin/activate && flask --app flaskr run --debug --host=0.0.0.0"]

