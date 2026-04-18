# Izel-Data — Contexto Completo del Proyecto

> **Documento maestro.** Cualquier IA que continúe este proyecto debe leer este archivo entero antes de tocar nada.
> Última actualización: **2026-04-18**.

---

## 1. Qué es

**Izel-Data** es un producto con dos piezas que se hablan entre sí:

1. **App iOS** (SwiftUI + SwiftData) para seguimiento clínico de salud hormonal femenina.
2. **Servidor Python** (FastAPI) que sirve predicciones ML de riesgo para **Endometriosis** y **SOP/PCOS** usando modelos RandomForest pre-entrenados.

La app es autosuficiente (indicadores placeholder en Análisis), pero cuando el servidor está corriendo, el botón **"Analizar con IA"** en la pestaña Análisis envía los datos y muestra probabilidades reales del modelo.

---

## 2. Rutas absolutas y estructura del repo

Raíz del proyecto: `/Users/mpreciad/Desktop/Isaac/Especialidad/Dirección de proyectos/izel/`

```
izel/
├── CONTEXT.md                              ← ESTE ARCHIVO
│
├── Izel-Data/                              ← Proyecto Xcode (app iOS)
│   ├── Izel-Data.xcodeproj/               ← NO editar a mano
│   └── Izel-Data/                          ← Código fuente del target
│       ├── Izel_DataApp.swift              ← @main, inyecta ModelContainer
│       ├── Assets.xcassets/
│       ├── Preview Content/
│       ├── DesignSystem/
│       │   ├── Theme.swift                 ← Colores, fonts, radios, spacing, shadows
│       │   └── Components/
│       │       ├── CardContainer.swift
│       │       ├── ChipButton.swift
│       │       ├── IconBadge.swift
│       │       ├── LabeledField.swift
│       │       ├── PrimaryButton.swift
│       │       ├── SectionHeader.swift
│       │       └── StepperField.swift
│       ├── Models/
│       │   ├── CycleEntry.swift            ← @Model
│       │   ├── CyclePhase.swift            ← enum menstrual/folicular/ovulatoria/lutea
│       │   ├── CycleRegularity.swift       ← enum regular/irregular/variable
│       │   ├── RiskIndicator.swift         ← struct + RiskLevel enum (low/moderate/high)
│       │   ├── Symptom.swift               ← struct + catálogo de 10 síntomas
│       │   ├── SymptomEntry.swift          ← @Model (date, symptomIDs:[String], intensity:Int, note:String)
│       │   └── UserProfile.swift           ← @Model (birthDate, weightKg, heightCm, cycleRegularityRaw, cycleDurationDays, pregnancies, abortions, bmi computed)
│       ├── Services/
│       │   ├── CycleCalculatorService.swift
│       │   ├── PersistenceService.swift    ← factory ModelContainer + makeContainer(inMemory:)
│       │   └── PredictionService.swift     ← HTTP client + ServerConfig + feature engineering
│       ├── Navigation/
│       │   ├── RootView.swift              ← Gate: OnboardingView ↔ MainTabView (transición opacity)
│       │   └── MainTabView.swift           ← 5 tabs: home/history/symptoms/analysis/profile
│       └── Features/
│           ├── Onboarding/
│           │   ├── OnboardingView.swift    ← DatePicker es_ES + Slider 21–45 días
│           │   └── OnboardingViewModel.swift
│           ├── Dashboard/
│           │   ├── DashboardView.swift     ← recibe @Binding<AppTab>
│           │   ├── DashboardViewModel.swift
│           │   └── Components/
│           │       ├── CyclePhaseHero.swift
│           │       ├── CycleProgressRing.swift
│           │       ├── IMCCard.swift
│           │       └── PatternAlertCard.swift
│           ├── SymptomLog/
│           │   ├── SymptomLogView.swift    ← Slider intensidad + TextField notas + Alert
│           │   ├── SymptomLogViewModel.swift
│           │   └── Components/
│           │       └── SymptomGridCard.swift
│           ├── History/
│           │   ├── HistoryView.swift
│           │   ├── HistoryViewModel.swift
│           │   └── Components/
│           │       ├── FrequentSymptomsList.swift
│           │       ├── PredictionCard.swift
│           │       └── SymptomIntensityChart.swift
│           ├── Analysis/
│           │   ├── AnalysisView.swift      ← badge estado servidor + botón "Analizar con IA"
│           │   ├── AnalysisViewModel.swift ← runServerPrediction + refreshLocal (fallback)
│           │   └── Components/
│           │       └── RiskIndicatorCard.swift
│           └── Profile/
│               └── ProfileEditView.swift   ← editar UserProfile + config IP/puerto servidor
│
├── python/
│   ├── Modelo_endometriosis.ipynb
│   ├── modelo_SOP.ipynb
│   ├── data/
│   │   ├── endometriosis_clean.csv         ← 9988 filas, 7 cols
│   │   └── SOP_clean.csv                   ← 541 filas, 42 cols
│   ├── models/
│   │   ├── endometriosis_rf_model.joblib   ← Pipeline(StandardScaler + RF, 6 features)
│   │   └── modelo_sop_rf.joblib            ← Pipeline(StandardScaler + RF, 41 features)
│   └── server/
│       ├── .venv/                          ← Python 3.12.13 (NO COMMIT)
│       ├── main.py                         ← FastAPI app
│       ├── predictor.py                    ← carga joblib + inferencia
│       ├── defaults.py                     ← medianas del training set para features SOP faltantes
│       ├── requirements.txt
│       └── README.md
│
├── stitch_screens/                         ← Mocks de Stitch (HTML + PNG)
│   ├── analisis_predictivo/
│   ├── dashboard_principal/
│   ├── fecha_nacimiento/
│   ├── historico_tendencias/
│   ├── prd_izel_data/
│   └── registro_sintomas/
│
└── Izel-server/                            ← ⚠️ OBSOLETO. server.py vacío. Se puede borrar.
```

---

## 3. Stack técnico

### iOS
- **iOS 17+**, Xcode 16
- SwiftUI + SwiftData (`@Model`, `@Query`, `@Environment(\.modelContext)`)
- `@Observable` macro para ViewModels — **NO usar `@StateObject`**
- Charts framework (Apple) en `SymptomIntensityChart`
- `PBXFileSystemSynchronizedRootGroup`: cualquier `.swift` dentro de `Izel-Data/Izel-Data/` se incluye automáticamente. **No tocar `project.pbxproj`.**

### Python / ML
- **Python 3.12.13** — **NO usar 3.14** (rompe `pydantic-core` vía PyO3)
- FastAPI 0.115.0 + uvicorn 0.32.0
- scikit-learn **1.6.1** (debe coincidir con versión de entrenamiento)
- pandas 2.2.3, numpy 2.1.2, joblib 1.4.2

---

## 4. Tabs de la app (MainTabView)

```swift
enum AppTab: Hashable {
    case home, history, symptoms, analysis, profile
}
```

| Tab | View | Ícono SF Symbol |
|-----|------|----------------|
| Home | `DashboardView` | `house.fill` |
| Historial | `HistoryView` | `calendar` |
| Síntomas | `SymptomLogView` | `heart.text.square` |
| Análisis | `AnalysisView` | `chart.xyaxis.line` |
| **Perfil** | `ProfileEditView` | `person.crop.circle` |

---

## 5. Flujo de datos iOS

```
Izel_DataApp
  └─ .modelContainer(PersistenceService.makeContainer())
       └─ RootView                       ← @Query UserProfile, decide gate
             ├─ OnboardingView           ← inserta UserProfile vía modelContext
             └─ MainTabView (5 tabs)
                   ├─ DashboardView      ← @Query UserProfile + SymptomEntry; @Binding<AppTab>
                   ├─ HistoryView        ← @Query SymptomEntry
                   ├─ SymptomLogView     ← inserta SymptomEntry vía modelContext
                   ├─ AnalysisView       ← @Query UserProfile + SymptomEntry
                   │    └─ AnalysisViewModel.runServerPrediction()
                   │         └─ PredictionService → HTTP POST → FastAPI
                   └─ ProfileEditView    ← @Query UserProfile, edita en lugar
                                           también configura IP/puerto servidor
```

---

## 6. PredictionService — diseño clave

`Services/PredictionService.swift` contiene:

### `ServerConfig`
Lee/escribe `UserDefaults` con claves `"server_host"` (default `"localhost"`) y `"server_port"` (default `"8000"`). La URL se construye en tiempo de ejecución para que cambios en `ProfileEditView` surtan efecto de inmediato sin reiniciar la app.

```swift
ServerConfig.host     // leer host actual
ServerConfig.port     // leer puerto actual
ServerConfig.baseURL  // URL computada: http://<host>:<port>
ServerConfig.save(host:port:)  // no se usa directamente — ProfileEditView usa @AppStorage
```

### `PredictionService.ping()`
`GET /health` con timeout 5s. Retorna `Bool`. Usado por:
- `AnalysisView.onAppear` — actualiza badge de estado
- `ProfileEditView` — botón "Probar conexión"

### Estado servidor en `AnalysisView`
Badge siempre visible con tres estados: `.unknown` (gris), `.online` (verde), `.offline` (rojo). Se actualiza en `onAppear` y tras cada predicción.

---

## 7. ProfileEditView — secciones

1. **01 Datos Biométricos** — DatePicker fecha nacimiento, peso, estatura
2. **02 Historial de Salud** — regularidad ciclo (ChipButton), duración (Slider 21–45), embarazos/abortos (StepperField)
3. **03 Servidor ML** — campos IP (`@AppStorage("server_host")`) y puerto (`@AppStorage("server_port")`), botón "Probar" que hace ping, badge resultado (verde/rojo)
4. Botón **"Guardar cambios"** — muta el `UserProfile` existente en SwiftData

Los cambios al campo host/port se guardan automáticamente vía `@AppStorage` — no requieren presionar "Guardar".

---

## 8. Servidor Python — contrato completo

### Arrancar
```bash
cd "/Users/mpreciad/Desktop/Isaac/Especialidad/Dirección de proyectos/izel/python/server"
source .venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Si `.venv` no existe:
```bash
python3.12 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

- Swagger UI: `http://localhost:8000/docs`
- Detener: `kill $(lsof -ti:8000)`

### Endpoints

| Método | Ruta | Body |
|--------|------|------|
| GET | `/health` | — |
| POST | `/predict/endometriosis` | `EndoRequest` (6 campos) |
| POST | `/predict/sop` | `SopRequest` (13 campos) |

#### `EndoRequest`
```json
{ "age": 29, "menstrual_irregularity": 1, "chronic_pain_level": 3,
  "hormone_level_abnormality": 0, "infertility": 0, "bmi": 23.4 }
```

#### `SopRequest`
```json
{ "age": 29, "weight_kg": 62, "height_cm": 163, "bmi": 23.3,
  "cycle_irregular": 1, "cycle_length_days": 32,
  "pregnant": 0, "abortions": 0,
  "weight_gain": 1, "hair_growth": 1, "skin_darkening": 0,
  "hair_loss": 1, "pimples": 1 }
```

#### `PredictionResponse` (ambos)
```json
{ "label": 1, "probability": 0.71,
  "risk_level": "high", "condition": "sop" }
```
`risk_level`: `low` (<0.35) | `moderate` (0.35–0.60) | `high` (≥0.60)

### Features SOP faltantes
El modelo espera 41 features. La app envía 13 derivables. Las 28 restantes (FSH, LH, AMH, ecografía, etc.) se rellenan con medianas del training set en `defaults.py`. Los nombres de columna tienen espacios raros (`" Age (yrs)"`, `"Height(Cm) "`) — `predictor.py` usa `.strip()` como fallback.

---

## 9. Convenciones de código (iOS)

1. **Colores/fonts:** siempre `Theme.Colors.*`, `Theme.Typography.*`, `Theme.Spacing.*`, `Theme.Radius.*`. Nunca hex hardcodeado.
2. **Colores disponibles en `Theme.Colors`:** `primary`, `primaryContainer`, `onPrimary`, `onPrimaryContainer`, `primaryFixed`, `primaryFixedDim`, `secondary`, `secondaryContainer`, `onSecondary`, `onSecondaryContainer`, `tertiary`, `tertiaryContainer`, `tertiaryFixed`, `tertiaryFixedDim`, `onTertiary`, `onTertiaryContainer`, `onTertiaryFixed`, `onTertiaryFixedVariant`, `surface`, `surfaceBright`, `surfaceDim`, `surfaceContainerLowest`, `surfaceContainerLow`, `surfaceContainer`, `surfaceContainerHigh`, `surfaceContainerHighest`, `background`, `onBackground`, `onSurface`, `onSurfaceVariant`, `outline`, `outlineVariant`, `error`, `errorContainer`, `onError`, `onErrorContainer`, `symptomChipBg`. **No existe `surfaceVariant`** — usar `surfaceContainerLow`.
3. **ViewModels:** `@Observable` + `@State` en la view. No `@StateObject`.
4. **Persistencia:** escritura con `@Environment(\.modelContext)` + `context.insert` + `try? context.save()`. Lectura con `@Query`.
5. **Previews:** siempre. Con SwiftData: `.modelContainer(PersistenceService.makeContainer(inMemory: true))`.
6. **Copy:** español, tono clínico/cálido.
7. **Iconos:** SF Symbols.
8. **Nuevos archivos** en `Izel-Data/Izel-Data/` → se incluyen automáticamente (no editar pbxproj).

---

## 10. Errores conocidos / cosas a ignorar

- **LSP / SourceKit en editores no-Xcode:** `"Cannot find 'Theme' in scope"`, `"Cannot find type 'UserProfile'"`, etc. — **ignorar**. Xcode compila bien (mismo módulo). Ocurre porque el LSP no indexa los nuevos archivos hasta que Xcode compile.
- **`Theme.Colors.surfaceVariant` no existe** — usar `surfaceContainerLow`.
- **Python 3.14 + pydantic-core** — falla al compilar. Usar Python **3.12** obligatoriamente.
- **InconsistentVersionWarning sklearn** — sólo si se instala ≠ 1.6.1. `requirements.txt` ya lo fija.
- **Carpeta `Izel-server/`** — vacía, obsoleta, se puede borrar.

---

## 11. Configuración de red (dispositivo físico)

Para conectar un iPhone físico al servidor:

1. Mac y iPhone en la misma red WiFi.
2. En `ProfileEditView` tab "Perfil" → sección "03 Servidor ML" → cambiar IP a la IP LAN del Mac (ej. `192.168.1.50`) y puerto `8000`.
3. En Xcode, target `Izel-Data` → pestaña **Info** → añadir:
   ```
   NSAppTransportSecurity
     └─ NSAllowsLocalNetworking  →  Boolean  →  YES
   ```
4. Probar con el botón "Probar" en la sección del servidor antes de analizar.

---

## 12. Cómo correr todo de cero

```bash
# Terminal 1 — servidor
cd "/Users/mpreciad/Desktop/Isaac/Especialidad/Dirección de proyectos/izel/python/server"
source .venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000 --reload

# Verificar
curl http://localhost:8000/health

# Xcode
open "/Users/mpreciad/Desktop/Isaac/Especialidad/Dirección de proyectos/izel/Izel-Data/Izel-Data.xcodeproj"
# Cmd+B para compilar, Cmd+R para ejecutar en iPhone 15 simulator
# Primera vez: completa Onboarding → MainTabView (5 tabs)
# Tab "Análisis" → badge verde = servidor en línea → "Analizar con IA"
# Tab "Perfil" → editar datos biométricos o cambiar IP/puerto del servidor
```

---

## 13. Estado actual — qué está completo

- ✅ Onboarding completo (DatePicker + Slider)
- ✅ Dashboard (copy contextual por fase, PatternAlert real, nav a Síntomas)
- ✅ SymptomLog (Slider intensidad, notas, Alert confirmación)
- ✅ History (intensityByDay 30d, top 5 síntomas con trend)
- ✅ Analysis (badge estado servidor, botón "Analizar con IA", fallback local, sin PDF)
- ✅ Profile (editar todos los campos de UserProfile + config servidor con ping)
- ✅ Servidor Python (FastAPI, 2 modelos, /health, /predict/endometriosis, /predict/sop)
- ✅ PredictionService (URL dinámica desde UserDefaults, ping, feature engineering)
- ✅ MainTabView con 5 tabs (AppTab: home/history/symptoms/analysis/profile)

---

## 14. Referencias visuales (mocks de Stitch)

| Pantalla Swift | Mock |
|---|---|
| `OnboardingView` | `stitch_screens/fecha_nacimiento/` |
| `DashboardView` | `stitch_screens/dashboard_principal/` |
| `SymptomLogView` | `stitch_screens/registro_sintomas/` |
| `HistoryView` | `stitch_screens/historico_tendencias/` |
| `AnalysisView` | `stitch_screens/analisis_predictivo/` |

Stitch PRD ID: `1568913791068517714` (accesible vía MCP `mcp__stitch__get_project`).

---

## 15. Próximos posibles pasos

1. Implementar export PDF real (`PDFKit`).
2. Re-entrenar modelos SOP con sólo las features que la app captura.
3. Dockerizar el servidor para deploy fuera de localhost.
4. Persistir histórico de predicciones en SwiftData.
5. Borrar carpeta obsoleta `Izel-server/`.
