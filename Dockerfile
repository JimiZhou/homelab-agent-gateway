FROM python:3.11-alpine

ENV PYTHONUNBUFFERED=1
WORKDIR /app
EXPOSE 8088
RUN mkdir -p /data

COPY gateway.py /app/gateway.py

HEALTHCHECK --interval=15s --timeout=3s --retries=8 --start-period=10s \
  CMD python3 -c "import json, os, urllib.request; port=os.environ.get('GATEWAY_PORT','8088'); json.load(urllib.request.urlopen('http://127.0.0.1:%s/health' % port, timeout=2))['status'] == 'ok' or exit(1)"

CMD ["python3", "/app/gateway.py", "--host", "0.0.0.0", "--port", "8088"]
