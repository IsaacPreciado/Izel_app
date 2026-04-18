"""
Izel-Data prediction server.

Ejecutar (desde python/server/):
    uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""
from __future__ import annotations

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from predictor import ModelNotLoaded, predictor

app = FastAPI(title="Izel-Data Prediction API", version="1.0.0")

# El simulador iOS y dispositivos físicos pegarán directo: abrimos CORS.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Request schemas ───────────────────────────────────────────────────────
class EndoRequest(BaseModel):
    age: float = Field(..., ge=0, le=120)
    menstrual_irregularity: int = Field(..., ge=0, le=1)
    chronic_pain_level: int = Field(..., ge=0, le=5)
    hormone_level_abnormality: int = Field(0, ge=0, le=1)
    infertility: int = Field(0, ge=0, le=1)
    bmi: float = Field(..., ge=0, le=80)


class SopRequest(BaseModel):
    age: float = Field(..., ge=0, le=120)
    weight_kg: float = Field(..., ge=0, le=300)
    height_cm: float = Field(..., ge=0, le=250)
    bmi: float = Field(..., ge=0, le=80)
    cycle_irregular: int = Field(..., ge=0, le=1, description="0=regular, 1=irregular")
    cycle_length_days: int = Field(28, ge=10, le=90)
    pregnant: int = Field(0, ge=0, le=1)
    abortions: int = Field(0, ge=0, le=20)
    weight_gain: int = Field(0, ge=0, le=1)
    hair_growth: int = Field(0, ge=0, le=1)
    skin_darkening: int = Field(0, ge=0, le=1)
    hair_loss: int = Field(0, ge=0, le=1)
    pimples: int = Field(0, ge=0, le=1)


class PredictionResponse(BaseModel):
    label: int
    probability: float
    risk_level: str
    condition: str


def _risk_level(prob: float) -> str:
    if prob >= 0.60:
        return "high"
    if prob >= 0.35:
        return "moderate"
    return "low"


# ── Endpoints ─────────────────────────────────────────────────────────────
@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "izel-data-predictor"}


@app.post("/predict/endometriosis", response_model=PredictionResponse)
def predict_endometriosis(req: EndoRequest) -> PredictionResponse:
    overrides = {
        "Age": req.age,
        "Menstrual_Irregularity": req.menstrual_irregularity,
        "Chronic_Pain_Level": req.chronic_pain_level,
        "Hormone_Level_Abnormality": req.hormone_level_abnormality,
        "Infertility": req.infertility,
        "BMI": req.bmi,
    }
    try:
        print(overrides)
        label, prob = predictor.predict_endometriosis(overrides)
    except ModelNotLoaded as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
    return PredictionResponse(
        label=label,
        probability=prob,
        risk_level=_risk_level(prob),
        condition="endometriosis",
    )


@app.post("/predict/sop", response_model=PredictionResponse)
def predict_sop(req: SopRequest) -> PredictionResponse:
    # Ciclo: el dataset usa 2=regular, 4=irregular
    cycle_code = 4.0 if req.cycle_irregular else 2.0
    overrides = {
        "Age (yrs)": req.age,
        "Weight (Kg)": req.weight_kg,
        "Height(Cm) ": req.height_cm,
        "BMI": req.bmi,
        "Cycle(R/I)": cycle_code,
        "Cycle length(days)": req.cycle_length_days,
        "Pregnant(Y/N)": req.pregnant,
        "No. of aborptions": req.abortions,
        "Weight gain(Y/N)": req.weight_gain,
        "hair growth(Y/N)": req.hair_growth,
        "Skin darkening (Y/N)": req.skin_darkening,
        "Hair loss(Y/N)": req.hair_loss,
        "Pimples(Y/N)": req.pimples,
    }
    try:
        print(overrides)
        label, prob = predictor.predict_sop(overrides)
    except ModelNotLoaded as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
    return PredictionResponse(
        label=label,
        probability=prob,
        risk_level=_risk_level(prob),
        condition="sop",
    )
