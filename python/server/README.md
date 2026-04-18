# Izel-Data Prediction Server

Servidor FastAPI que carga los modelos RandomForest entrenados (`../models/*.joblib`) y expone endpoints de predicción para la app iOS.

## Setup

```bash
cd python/server
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Run

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

- Swagger UI:  http://localhost:8000/docs
- Health:      http://localhost:8000/health

## Endpoints

### `POST /predict/endometriosis`
```json
{
  "age": 29,
  "menstrual_irregularity": 1,
  "chronic_pain_level": 3,
  "hormone_level_abnormality": 0,
  "infertility": 0,
  "bmi": 23.4
}
```

### `POST /predict/sop`
```json
{
  "age": 29,
  "weight_kg": 62,
  "height_cm": 163,
  "bmi": 23.3,
  "cycle_irregular": 1,
  "cycle_length_days": 32,
  "pregnant": 0,
  "abortions": 0,
  "weight_gain": 1,
  "hair_growth": 1,
  "skin_darkening": 0,
  "hair_loss": 1,
  "pimples": 1
}
```

### Respuesta (ambos)
```json
{ "label": 1, "probability": 0.71, "risk_level": "high", "condition": "sop" }
```

`risk_level`: `low` (<0.35), `moderate` (0.35–0.60), `high` (≥0.60).

## Nota sobre features del SOP

El modelo original entrena con 41 features clínicas (FSH, LH, AMH, ecografía, etc.) que la app no recolecta. El servidor rellena esas features con **medianas del set de entrenamiento** (ver `defaults.py`). Sólo se envían desde la app las que sí puede derivar de `UserProfile` + `SymptomEntry`.

## Conexión desde iOS

- Simulador → `http://localhost:8000`
- Dispositivo físico en misma red → `http://<IP-LAN-del-Mac>:8000` (p.ej. `192.168.1.x`)
- Info.plist: `NSAppTransportSecurity > NSAllowsLocalNetworking = true` si usas HTTP local
