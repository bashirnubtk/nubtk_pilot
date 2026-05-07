from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import os
from check_models import analyze_image # তোমার existing ফাংশন

app = FastAPI()

# CORS - Flutter থেকে কল করার জন্য
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"status": "NUBTK AI Backend Running"}

@app.post("/analyze")
async def analyze(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        # তোমার check_models.py এর ফাংশন কল করো
        result = analyze_image(contents)
        return {"success": True, "data": result}
    except Exception as e:
        return {"success": False, "error": str(e)}

# Railway এর জন্য পোর্ট সেট
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)