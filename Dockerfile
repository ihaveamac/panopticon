FROM python:3.9-slim

ENV IS_DOCKER 1
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

ENV HOME /home/panopticon
RUN useradd -m -d $HOME -s /bin/sh -u 2641 panopticon

WORKDIR $HOME
COPY ./requirements.txt .
RUN pip install --no-compile --no-cache-dir -r requirements.txt

USER panopticon
COPY --chown=2641:2641 . .

ARG COMMIT="unknown"

LABEL org.opencontainers.image.title discord-mod-mail
LABEL org.opencontainers.image.description Simple mod-mail system for Discord
LABEL org.opencontainers.image.source https://github.com/ihaveamac/panopticon
LABEL org.opencontainers.image.url https://github.com/ihaveamac/panopticon
LABEL org.opencontainers.image.documentation https://github.com/ihaveamac/panopticon
LABEL org.opencontainers.image.licenses BSD-3-Clause
LABEL org.opencontainers.image.revision $COMMIT

CMD ["python3", "run.py"]
