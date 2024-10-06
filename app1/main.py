import os

import requests
from fastapi import FastAPI

app = FastAPI(root_path="/app1")

APP2_URL = os.getenv("APP2_URL")


@app.get("/")
def read_root():
    return {"message": "Hello from App1"}


@app.get("/health")
def health_check():
    return {"status": "healthy"}


@app.get("/call-app2")
def call_app2():
    try:
        response = requests.get(f"{APP2_URL}/")
        response.raise_for_status()
        return {"message": f"App1 received: {response.json()['message']}"}
    except requests.RequestException as e:
        return {"error": f"Failed to call App2: {str(e)}"}
