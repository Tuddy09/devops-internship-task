FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install flask  # Flask is a dependency but not explicitly listed

COPY calculator.py .

ENV FLASK_ENV=production
ENV PORT=8080

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "calculator:app"]