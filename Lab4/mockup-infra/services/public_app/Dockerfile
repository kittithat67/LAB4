FROM python:3.11-slim

WORKDIR /app

# No external dependencies needed for http.server
COPY app.py .
COPY requirements.txt .

EXPOSE 80

CMD ["python", "app.py"]
