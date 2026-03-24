FROM python:3.11-slim

WORKDIR /app

# this will come from builder image (OpenShift injects it)
COPY /deps /usr/local

COPY app /app

CMD ["python", "main.py"]
