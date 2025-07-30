from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from starlette.responses import JSONResponse
import shutil, os

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = "backend/uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.post("/kyc_check")
async def kyc_check(passport: UploadFile = File(...), selfie: UploadFile = File(...)):
    passport_path = os.path.join(UPLOAD_DIR, passport.filename)
    selfie_path = os.path.join(UPLOAD_DIR, selfie.filename)

    with open(passport_path, "wb") as buffer:
        shutil.copyfileobj(passport.file, buffer)

    with open(selfie_path, "wb") as buffer:
        shutil.copyfileobj(selfie.file, buffer)

    # Simulated approval logic – you could plug in face match/ocr here
    if "fail" in passport.filename.lower():
        return JSONResponse({"status": "rejected"})
    return JSONResponse({"status": "approved"})

@app.get("/ipfs_metadata")
async def get_ipfs_metadata():
    # Simulated IPFS fetch
    metadata = {
        "asset_type": "Scotch Whiskey Cask",
        "vault": "Zug, CH",
        "token_id": "MST-2022-ISLAY-001"
    }
    return metadata
