"""
Wrapper sobre los modelos RandomForest entrenados.
Carga perezosa en la primera inferencia.
"""
from __future__ import annotations

from pathlib import Path
from typing import Any

import joblib
import pandas as pd

from defaults import ENDO_DEFAULTS, SOP_DEFAULTS

MODELS_DIR = Path(__file__).resolve().parent.parent / "models"
ENDO_PATH = MODELS_DIR / "endometriosis_rf_model.joblib"
SOP_PATH = MODELS_DIR / "modelo_sop_rf.joblib"


class ModelNotLoaded(RuntimeError):
    pass


class Predictor:
    def __init__(self) -> None:
        self._endo: Any | None = None
        self._sop: Any | None = None

    # ── Lazy loading ──────────────────────────────────────────────────────
    @property
    def endo(self) -> Any:
        if self._endo is None:
            if not ENDO_PATH.exists():
                raise ModelNotLoaded(f"Modelo no encontrado: {ENDO_PATH}")
            self._endo = joblib.load(ENDO_PATH)
        return self._endo

    @property
    def sop(self) -> Any:
        if self._sop is None:
            if not SOP_PATH.exists():
                raise ModelNotLoaded(f"Modelo no encontrado: {SOP_PATH}")
            self._sop = joblib.load(SOP_PATH)
        return self._sop

    # ── Resolución de columnas esperadas por el pipeline ─────────────────
    @staticmethod
    def _feature_names(pipeline: Any) -> list[str]:
        if hasattr(pipeline, "feature_names_in_"):
            return list(pipeline.feature_names_in_)
        if hasattr(pipeline, "named_steps"):
            for step in pipeline.named_steps.values():
                if hasattr(step, "feature_names_in_"):
                    return list(step.feature_names_in_)
        raise ModelNotLoaded("El pipeline no expone feature_names_in_")

    # ── Predicción ───────────────────────────────────────────────────────
    def _predict(
        self,
        pipeline: Any,
        overrides: dict[str, float],
        defaults: dict[str, float],
    ) -> tuple[int, float]:
        feature_names = self._feature_names(pipeline)
        row: dict[str, float] = {}
        for name in feature_names:
            if name in overrides:
                row[name] = float(overrides[name])
            elif name in defaults:
                row[name] = float(defaults[name])
            else:
                # Tolera pequeñas variaciones de nombre (strip)
                match = next((k for k in defaults if k.strip() == name.strip()), None)
                if match is None:
                    raise ModelNotLoaded(
                        f"No hay default para la feature esperada: {name!r}"
                    )
                row[name] = float(defaults[match])

        X = pd.DataFrame([row], columns=feature_names)
        prob = float(pipeline.predict_proba(X)[0, 1])
        label = int(pipeline.predict(X)[0])
        return label, prob

    def predict_endometriosis(self, overrides: dict[str, float]) -> tuple[int, float]:
        return self._predict(self.endo, overrides, ENDO_DEFAULTS)

    def predict_sop(self, overrides: dict[str, float]) -> tuple[int, float]:
        return self._predict(self.sop, overrides, SOP_DEFAULTS)


predictor = Predictor()
