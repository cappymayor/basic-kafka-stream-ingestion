FROM python:3.8.19-slim-bullseye

WORKDIR /stream_processing

COPY ./kafka /stream_processing/