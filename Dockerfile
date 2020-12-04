FROM python:3.8-slim-buster
LABEL org.opencontainers.image.source https://github.com/ihaveamac/panopticon
ENV IS_DOCKER=1
ENV PYTHONUNBUFFERED=1
ENV HOME /home/panopticon
RUN useradd -m -d $HOME -s /bin/sh -u 2641 panopticon
WORKDIR $HOME
COPY ./requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
USER panopticon
COPY --chown=2641:2641 . .
CMD ["python3", "run.py"]
