FROM python:3.10 AS builder

RUN pip install --user pipenv

ENV RUN_HOST="0.0.0.0"
ENV RUN_PORT=80

# Tell pipenv to create venv in the current directory
ENV PIPENV_VENV_IN_PROJECT=1

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# only copy in lockfile - install from locked deps
COPY Pipfile.lock /app/Pipfile.lock

WORKDIR /app

RUN /root/.local/bin/pipenv sync

FROM python:3.10-slim AS runtime

WORKDIR /app

# copy venv into runtime
COPY --from=builder /app/.venv/ /app/.venv/

# add venv to path
ENV PATH="/app/.venv/bin:$PATH"

# copy in everything
COPY . /app

CMD ["./.venv/bin/gunicorn", "--chdir", "/app", "main:app",  "-w", "4", "-b", "$RUN_HOST:$RUN_PORT"]