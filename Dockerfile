# Stage 1: builder
FROM python:3.11-slim-bookworm AS builder
WORKDIR /app
COPY requirements.txt .
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir --upgrade pip wheel && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# Stage 2: runtime (final image)
FROM python:3.11-slim-bookworm AS runtime
WORKDIR /app
# Apply all available OS security patches
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*
# Copy venv from builder — nothing else
COPY --from=builder /opt/venv /opt/venv
COPY app.py .
# Non-root user
RUN adduser --disabled-password --gecos "" appuser && \
    chown -R appuser /app
USER appuser
ENV PATH=/opt/venv/bin:$PATH
EXPOSE 5000
CMD ["python", "app.py"]