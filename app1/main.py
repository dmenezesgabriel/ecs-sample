from fastapi import FastAPI

app = FastAPI(root_path="/app1")


@app.get("/")
async def root():
    return {"message": "Hello from App1!"}


@app.get("/health")
async def health():
    return {"status": "healthy"}
