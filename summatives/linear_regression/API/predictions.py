from fastapi import FastAPI
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware
import joblib
import pandas as pd
import uvicorn

app = FastAPI()

#cost as in the descriptions
origins = [
    "http://localhost",
    "http://localhost:3000",
    "http://localhost:8080",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# For loading the models
model = joblib.load("best_crop_yield_model.pkl")
scaler = joblib.load("scaler.pkl")
FEATURE_COLUMNS = joblib.load("feature_columns.pkl")


class PredictionInput(BaseModel):
    rainfall: float = Field(..., ge=0, le=5000)
    temperature: float = Field(..., ge=-10, le=60)
    fertilizer_used: int = Field(..., ge=0, le=1)
    irrigation_used: int = Field(..., ge=0, le=1)
    days_to_harvest: int = Field(..., ge=30, le=365)

    region: str
    soil_type: str
    crop: str
    weather_condition: str


@app.get("/")
def home():
    return {"message": "Crop Yield API is running 🚀"}


# THe POST request
@app.post("/predict")
def predict(data: PredictionInput):

    input_data = {
        "Rainfall_mm": data.rainfall,
        "Temperature_Celsius": data.temperature,
        "Fertilizer_Used": data.fertilizer_used,
        "Irrigation_Used": data.irrigation_used,
        "Days_to_Harvest": data.days_to_harvest
    }

    df_input = pd.DataFrame([input_data])

    # Encoding
    df_input = pd.get_dummies(df_input)

    df_input[f"Region_{data.region}"] = 1
    df_input[f"Soil_Type_{data.soil_type}"] = 1
    df_input[f"Crop_{data.crop}"] = 1
    df_input[f"Weather_Condition_{data.weather_condition}"] = 1

    df_input = df_input.reindex(columns=FEATURE_COLUMNS, fill_value=0)

    input_scaled = scaler.transform(df_input)
    prediction = model.predict(input_scaled)

    return {
        "predicted_yield": float(prediction[0])
    }


# trrying out the bonus marks for retaining the end point
@app.post("/retrain")
def retrain():
    # Simple version (manual trigger)
    return {"message": "Retraining triggered (implement training script here)"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
