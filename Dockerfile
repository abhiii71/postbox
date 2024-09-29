# Use the official Python image from the Docker Hub
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone the Flask repository
RUN git clone https://github.com/pallets/flask.git

# Change directory to the examples/tutorial
WORKDIR /app/flask/examples/tutorial

# Checkout the latest tagged version (replace `latest-tag` with the desired tag)
RUN git fetch --tags && \
    git checkout $(git describe --tags `git rev-list --tags --max-count=1`)

# Create a virtual environment
RUN python3 -m venv .venv

# Activate the virtual environment and install Flaskr
RUN . .venv/bin/activate && \
    pip install -e . && \
    pip install '.[test]'

# Expose port 5000
EXPOSE 5000

# Command to initialize the database and run the application
CMD ["/bin/bash", "-c", ". .venv/bin/activate && flask --app flaskr init-db && flask --app flaskr run --debug --host=0.0.0.0"]

