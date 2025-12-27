
# Dockerfile for voice-agent/backend/python
FROM python:3.13-slim

WORKDIR /app

# Install uv
RUN pip install uv

# Copy backend files
COPY voice-agent/backend/python /app/backend/python
COPY voice-agent/frontend/web/dist /app/web/dist

# Set working directory to backend/python for dependency installation
WORKDIR /app/backend/python

# Install dependencies
RUN uv sync --no-dev

# Expose port
EXPOSE 8000

# Run server from the backend/python directory
CMD ["uv", "run", "src/main.py"]
