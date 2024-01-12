FROM python:3.12

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=utf-8

WORKDIR /app

RUN apt-get update --fix-missing && \
    apt-get upgrade -y && \
    apt-get -y install tzdata gettext netcat-traditional --fix-missing && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata
RUN apt-get -y install wget git gnupg2 jq postgresql-client --fix-missing

COPY pyproject.toml pdm.lock ./

RUN mkdir __pypackages__ && \
    pip install pdm && \
    pdm sync --production --fail-fast --no-editable


RUN cp -r /app/__pypackages__/3.12/lib /usr/local/lib/python3.12 && \
    cp /app/__pypackages__/3.12/bin/* /usr/local/bin/ && \
    rm -r __pypackages__

COPY src ./

ENV PYTHONPATH=/usr/local/lib/python3.12/lib

ENTRYPOINT ["gunicorn", "backend.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "4"]
