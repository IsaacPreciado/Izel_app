"""
Valores por defecto (medianas del set de entrenamiento) para features del
modelo de SOP que la app iOS no recolecta (labs clínicos, ecografías, etc.).

Generados con: df.median() sobre python/data/SOP_clean.csv

El orden y nombres de las columnas deben coincidir EXACTAMENTE con
feature_names_in_ del pipeline guardado en modelo_sop_rf.joblib.
"""

SOP_DEFAULTS: dict[str, float] = {
    # Demográficos / antropometría  → la app los envía, pero si faltan usamos mediana
    "Age (yrs)": 31.0,
    "Weight (Kg)": 59.0,
    "Height(Cm) ": 156.0,       # ojo: espacio final como en el CSV
    "BMI": 24.24,

    # Grupo sanguíneo (codificado) — no lo tenemos, mediana
    "Blood Group": 14.0,

    # Signos vitales
    "Pulse rate(bpm) ": 72.0,   # ojo: espacio final
    "RR (breaths/min)": 18.0,

    # Sangre / labs
    "Hb(g/dl)": 11.0,

    # Ciclo menstrual
    "Cycle(R/I)": 2.0,          # 2 = regular, 4 = irregular (según dataset original)
    "Cycle length(days)": 5.0,

    # Historia reproductiva
    "Marraige Status (Yrs)": 7.0,
    "Pregnant(Y/N)": 0.0,
    "No. of aborptions": 0.0,

    # Hormonas
    "  I   beta-HCG(mIU/mL)": 20.0,
    "II    beta-HCG(mIU/mL)": 1.99,
    "FSH(mIU/mL)": 4.85,
    "LH(mIU/mL)": 2.30,
    "FSH/LH": 2.17,

    # Antropometría adicional
    "Hip(inch)": 38.0,
    "Waist(inch)": 34.0,
    "Waist:Hip Ratio": 0.8947,

    # Endocrinos
    "TSH (mIU/L)": 2.26,
    "AMH(ng/mL)": 3.70,
    "PRL(ng/mL)": 21.92,
    "Vit D3 (ng/mL)": 25.9,
    "PRG(ng/mL)": 0.32,
    "RBS(mg/dl)": 100.0,

    # Síntomas (Y/N) — la app SÍ puede derivarlos de SymptomEntry
    "Weight gain(Y/N)": 0.0,
    "hair growth(Y/N)": 0.0,
    "Skin darkening (Y/N)": 0.0,
    "Hair loss(Y/N)": 0.0,
    "Pimples(Y/N)": 0.0,

    # Estilo de vida
    "Fast food (Y/N)": 1.0,
    "Reg.Exercise(Y/N)": 0.0,

    # Presión arterial
    "BP _Systolic (mmHg)": 110.0,
    "BP _Diastolic (mmHg)": 80.0,

    # Ecografía — no las tenemos, mediana
    "Follicle No. (L)": 5.0,
    "Follicle No. (R)": 6.0,
    "Avg. F size (L) (mm)": 15.0,
    "Avg. F size (R) (mm)": 16.0,
    "Endometrium (mm)": 8.5,
}


ENDO_DEFAULTS: dict[str, float] = {
    "Age": 30.0,
    "Menstrual_Irregularity": 0.0,
    "Chronic_Pain_Level": 0.0,
    "Hormone_Level_Abnormality": 0.0,
    "Infertility": 0.0,
    "BMI": 24.0,
}
