FROM python:3.11-slim

WORKDIR /build
COPY requirements.txt .

RUN pip install --prefix=/deps -r requirements.txt
