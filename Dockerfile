# -------- STAGE 1: BUILDER --------
FROM python:3.12-slim AS builder

WORKDIR /app

# Install build dependencies (only here)
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements first (for caching)
COPY requirements.txt .

# Install dependencies into a separate folder
RUN pip install --prefix=/install -r requirements.txt


# -------- STAGE 2: RUNTIME --------
FROM python:3.12-slim

# Metadata
LABEL maintainer="jamestchalim12@gmail.com"
LABEL version="1.0"
LABEL description="FastAPI fault-tolerant service"

# Build args
ARG APP_ENV=production

# Environment
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV APP_ENV=${APP_ENV}

# Create non-root user
RUN useradd -m appuser

WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /install /usr/local

# Copy app code
COPY . .

# Permissions
RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

ENTRYPOINT ["uvicorn"]
CMD ["main:app", "--host", "0.0.0.0", "--port", "8000"]