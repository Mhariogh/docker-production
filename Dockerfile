# Stage 1: Builder
FROM python:3.11-alpine AS builder

# Set working directory
WORKDIR /app

# Install build dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt -t /app/deps

# Copy application code
COPY . .

# Stage 2: Final image
FROM python:3.11-alpine 
# FROM python:3.11-slim

WORKDIR /app

# Copy only installed dependencies from builder
COPY --from=builder /app/deps /usr/local/lib/python3.11/site-packages

# Copy only the app source code
COPY --from=builder /app /app

# Expose port and run the app
EXPOSE 5000
CMD ["python", "app.py"]
