from fastapi import FastAPI #make sure to install this btw : pip install fastapi uvicorn
import joblib
import pandas as pd
import uvicorn

app = FastAPI()

# Load model, scaler, and feature columns
model = joblib.load("best_crop_yield_model.pkl")
scaler = joblib.load("scaler.pkl")
FEATURE_COLUMNS = joblib.load("feature_columns.pkl") #pplease make sure you run the multivariate file first and the prediction file mus tbe in the same directory 

@app.get("/")
def home():
    return {"message": "Yesss Crop Yield Prediction API is running "}

@app.post("/predict")
def predict(
    rainfall: float,
    temperature: float,
    fertilizer_used: int,
    irrigation_used: int,
    days_to_harvest: int,
    region: str,
    soil_type: str,
    crop: str,
    weather_condition: str
):
    # Create base input
    input_data = {
        "Rainfall_mm": rainfall,
        "Temperature_Celsius": temperature,
        "Fertilizer_Used": fertilizer_used,
        "Irrigation_Used": irrigation_used,
        "Days_to_Harvest": days_to_harvest
    }

    df_input = pd.DataFrame([input_data])

    # Apply get_dummies (same as training)
    df_input = pd.get_dummies(df_input)

    # Manually add categorical columns
    # Example: Region_West = 1
    df_input[f"Region_{region}"] = 1
    df_input[f"Soil_Type_{soil_type}"] = 1
    df_input[f"Crop_{crop}"] = 1
    df_input[f"Weather_Condition_{weather_condition}"] = 1

    # Ensure all columns match training
    df_input = df_input.reindex(columns=FEATURE_COLUMNS, fill_value=0)

    # Scale
    input_scaled = scaler.transform(df_input)

    # Predict
    prediction = model.predict(input_scaled)

    return {
        "Predicted Crop Yield (tons per hectare)": float(prediction[0])
    }

# Run API
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
