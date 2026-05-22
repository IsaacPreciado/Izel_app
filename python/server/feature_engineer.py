"""
Custom Feature Engineering Transformer for Endometriosis Model.

This module defines the EndometriosisFeatureEngineer transformer that is
used inside the sklearn Pipeline. It must be importable by any code that
loads the saved .joblib model (tests, server, etc.).
"""
from __future__ import annotations

import numpy as np
from sklearn.base import BaseEstimator, TransformerMixin

FEATURE_NAMES = [
    "Age",
    "Menstrual_Irregularity",
    "Chronic_Pain_Level",
    "Hormone_Level_Abnormality",
    "Infertility",
    "BMI",
]


class EndometriosisFeatureEngineer(BaseEstimator, TransformerMixin):
    """
    Custom sklearn transformer that adds engineered interaction features.

    Input: numpy array of shape (n, 6) after StandardScaler
    Output: numpy array of shape (n, 12) with 6 original + 6 engineered features

    Engineered features:
    - Pain_x_Irregularity: Chronic_Pain_Level * Menstrual_Irregularity
    - Hormone_x_Infertility: Hormone_Level_Abnormality * Infertility
    - Age_BMI_interaction: Age * BMI (already scaled by StandardScaler)
    - Risk_Score: sum of binary risk factors (Menstrual_Irregularity +
                  Hormone_Level_Abnormality + Infertility)
    - BMI_Category: categorical encoding of BMI ranges (uses scaled values,
                    approximated via thresholds on standardized data)
    - Pain_Squared: Chronic_Pain_Level^2
    """

    # Column indices in the 6-feature input
    IDX_AGE = 0
    IDX_MENSTRUAL = 1
    IDX_PAIN = 2
    IDX_HORMONE = 3
    IDX_INFERTILITY = 4
    IDX_BMI = 5

    def fit(self, X, y=None):
        return self

    def transform(self, X):
        X = np.asarray(X, dtype=np.float64)

        # Original features (already scaled)
        age = X[:, self.IDX_AGE]
        menstrual = X[:, self.IDX_MENSTRUAL]
        pain = X[:, self.IDX_PAIN]
        hormone = X[:, self.IDX_HORMONE]
        infertility = X[:, self.IDX_INFERTILITY]
        bmi = X[:, self.IDX_BMI]

        # Engineered features
        pain_x_irregularity = pain * menstrual
        hormone_x_infertility = hormone * infertility
        age_bmi_interaction = age * bmi  # both already normalized by scaler
        risk_score = menstrual + hormone + infertility
        bmi_category = np.digitize(bmi, bins=[-1.0, -0.5, 0.5, 1.0])
        pain_squared = pain ** 2

        # Stack all features
        engineered = np.column_stack([
            X,
            pain_x_irregularity,
            hormone_x_infertility,
            age_bmi_interaction,
            risk_score,
            bmi_category,
            pain_squared,
        ])

        return engineered

    def get_feature_names_out(self, input_features=None):
        base = list(input_features) if input_features is not None else FEATURE_NAMES
        return base + [
            "Pain_x_Irregularity",
            "Hormone_x_Infertility",
            "Age_BMI_interaction",
            "Risk_Score",
            "BMI_Category",
            "Pain_Squared",
        ]
