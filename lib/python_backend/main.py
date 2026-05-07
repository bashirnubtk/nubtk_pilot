from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
# তোমার check_models.py ফাইলটা python_backend ফোল্ডারে রাখো
from check_models import analyze_image  

app = FastAPI(title="NUBTK AI Analysis API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def health_check():
    return {"status": "NUBTK AI Server Running"}

@app.post("/analyze")
async def analyze_endpoint(
    file: UploadFile = File(...), 
    user_id: str = Form(...)
):
    try:
        image_bytes = await file.read()
        result = analyze_image(image_bytes)  # তোমার existing ফাংশন
        
        return {
            "success": True,
            "user_id": user_id,
            "data": result,
            "model_version": "1.0"
        }
    except Exception as e:
        return {"success": False, "error": str(e)}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)