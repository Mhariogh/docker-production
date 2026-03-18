#Stage 1: builder
#Install all dependencies into a virtual environment. This stage will NOT be in the final image.
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN python -m venv /opt/venv && \
/opt/venv/bin/pip install --no-cache-dir -r requirements.txt


#Stage 2: runtime (final image)
#Copy only the virtual environment from the builder stage — no pip, no build tools.
FROM python:3.11-slim AS runtime
WORKDIR /app
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
