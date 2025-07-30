from fastapi import FastAPI

app = FastAPI()

@app.get("/price")
def get_price():
    return {"asset": "SPIRITS", "price_usd": 183.25}
