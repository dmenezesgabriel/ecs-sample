import os
import time

import requests
from fastapi import FastAPI

app = FastAPI(root_path="/app2")

APP1_URL = os.getenv("APP1_URL")


@app.get("/")
def read_root():
    return {"message": "Hello from App2"}


@app.get("/cpu-intensive")
def cpu_intensive():
    start_time = time.time()
    while time.time() - start_time < 5:
        _ = [i**2 for i in range(10000)]
    return {"message": "CPU intensive task completed"}


@app.get("/health")
def health_check():
    return {"status": "healthy"}


@app.get("/call-app1")
def call_app1():
    try:
        response = requests.get(f"{APP1_URL}/")
        response.raise_for_status()
        return {"message": f"App2 received: {response.json()['message']}"}
    except requests.RequestException as e:
        return {"error": f"Failed to call App1: {str(e)}"}
