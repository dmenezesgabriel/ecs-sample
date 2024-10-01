from fastapi import FastAPI

app = FastAPI(root_path="/app2")


@app.get("/")
async def root():
    return {"message": "Hello from App2!"}


@app.get("/health")
async def health():
    return {"status": "healthy"}
