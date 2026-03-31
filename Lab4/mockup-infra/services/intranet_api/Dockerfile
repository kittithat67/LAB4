FROM python:3.11-slim

WORKDIR /app

# Install Flask dependency
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY api.py .
COPY requirements.txt .

EXPOSE 5000

CMD ["python", "api.py"]
