# 1. Lightweight Python base image
FROM python:3.11-slim

# 2. Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# 3. Set working directory
WORKDIR /app

# 4. Copy dependency files first for Docker layer caching
COPY pyproject.toml uv.lock ./

# 5. Create virtual environment and install locked dependencies
RUN uv sync --frozen --no-dev

# 6. Copy the entire project
COPY . .

# 7. Explicitly copy model
COPY src/serving/model /app/src/serving/model

# 8. Copy MLflow model artifacts
COPY src/serving/model/3b1a41221fc44548aed629fa42b762e0/artifacts/model /app/model
COPY src/serving/model/3b1a41221fc44548aed629fa42b762e0/artifacts/feature_columns.txt /app/model/feature_columns.txt
COPY src/serving/model/3b1a41221fc44548aed629fa42b762e0/artifacts/preprocessing.pkl /app/model/preprocessing.pkl

# 9. Environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/src \
    PATH="/app/.venv/bin:$PATH"

# 10. FastAPI port
EXPOSE 8000

# 11. Start FastAPI
CMD ["uvicorn", "src.app.main:app", "--host", "0.0.0.0", "--port", "8000"]