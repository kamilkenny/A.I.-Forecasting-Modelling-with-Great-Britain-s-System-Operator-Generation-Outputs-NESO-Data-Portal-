

# A.I. FORECASTING-MODELLING WITH GREAT BRITAIN’S SYSTEM OPERATOR GENERATION OUTPUTS TO OPTIMISE NATIONAL GRID DECARBONIZATION STRATEGIES
![grid](https://github.com/user-attachments/assets/294e39a5-84e5-4750-98d0-a16718d12741)



<img width="1536" height="1024" alt="ChatGPT Image Feb 15, 2026, 01_51_44 AM" src="https://github.com/user-attachments/assets/01db605c-2084-4b15-9b66-b8f0709966de" />

# The Model has been deployed on this web-link:https://deployment-of-uk-electricity-generation.onrender.com/
The deployed web-based-app can perform inferencing also known as HINDCASTING of past times steps to estimate the residual error and FORECASTING future time steps of generation output.
## 📖 Project Overview
The UK electricity system is transitioning rapidly. Accurate short-term forecasting is vital for balancing the grid as we integrate more intermittent renewable sources. 

This project utilizes a **Multivariate Time-Series approach** to predict Total Electricity Generation. By training on historical data (2009–2026) from the **NESO Data Portal**, the model identifies seasonal rhythms, daily demand ramps, and long-term trends to provide actionable grid analytics.

### Key Objectives:
* **Grid Balancing:** Predict supply requirements to maintain frequency stability.
* **Renewable Integration:** Optimize the dispatch of zero-carbon sources.
* **Operational Efficiency:** Reduce reliance on expensive, high-carbon reserve plants.
  
This study analyzes UK electricity generation data with the objective of understanding generation dynamics and developing a machine learning model to forecast total electricity generation.
# Data Source - Historic GB Generation Mix
Historic GB generation mix from the 1st of Jan 2009 through to 2026 (Real-Time). Data points are either MW or %

# The Design and Development was done in Python and uploaded as a file in this respository 

# Introduction

The UK electricity system has undergone significant transformation due to increasing renewable penetration, declining coal usage, and evolving demand patterns. Accurate short-term electricity generation forecasting is critical for:

- Grid stability

- Energy market operations

- Renewable integration planning

- Carbon reduction strategy

# Project Objective

The objective of this study is to:

Perform comprehensive exploratory data analysis (EDA) on UK electricity generation data.

Engineer predictive temporal and structural features.

Develop a machine learning forecasting model using XGBoost.

Evaluate forecasting performance using standard regression metrics.

Establish a benchmark model for comparison with deep learning architectures (LSTM and Informer).

# Dataset Description
# Data Overview

The dataset consists of time-indexed UK electricity generation values at hourly resolution.

Key Variables Include:

Total Generation (MW) — Target variable

Gas

Coal

Nuclear

Wind

Solar

Hydro

Biomass

Imports

Storage
<img width="1333" height="549" alt="download" src="https://github.com/user-attachments/assets/66a1fc52-c4a9-49bc-b511-c1d77be221c9" />


<img width="1466" height="645" alt="download (1)" src="https://github.com/user-attachments/assets/cd211654-f94f-4a99-b352-5b9ba5a6f610" />
<img width="1333" height="547" alt="download" src="https://github.com/user-attachments/assets/fbd843a9-74bb-44e1-9646-5defdfe3d286" />
<img width="1315" height="547" alt="download" src="https://github.com/user-attachments/assets/b0e75d0e-ef59-4b56-bb6c-423fc25093a1" />
<img width="1023" height="551" alt="download" src="https://github.com/user-attachments/assets/f4c7d6e2-09f8-4412-a486-ace0c9685958" />
<img width="1298" height="547" alt="download" src="https://github.com/user-attachments/assets/21bca1dc-b1c7-4bda-a5b6-c0b3f93b5e30" />


# EXPLORATORY DATA ANALYSIS (EDA) – UK ELECTRICITY GENERATION DATASET
# 1. Dataset Overview
Data Source: NESO Data Bank
Time Period: 2009-01-01 to 2026-02-14 (half-hourly intervals)

Total Records: 300,170 rows × 33 columns

Columns of Interest:

Generation by Source (MW): GAS, COAL, NUCLEAR, WIND, WIND_EMB, HYDRO, BIOMASS, SOLAR, OTHER, IMPORTS

Aggregated Metrics: STORAGE, GENERATION, LOW_CARBON, ZERO_CARBON, RENEWABLE, FOSSIL

Percentage Shares (%): _perc columns (e.g., GAS_perc, COAL_perc, RENEWABLE_perc)

Carbon Intensity (gCO₂/kWh)

# 2. Data Quality & Preprocessing
Datetime Parsing: Converted 'DATETIME' to datetime type and set as index.

Missing Values: None; dataset is complete with all 300,170 entries.

Data Types: 18 integer columns, 15 float columns (percentages).

Initial Observations:

Fossil fuels (GAS + COAL) dominate generation.

Renewable contributions are smaller but show gradual growth.

Imports vary and occasionally contribute significantly to total generation.

Carbon intensity fluctuates with the share of fossil fuels.

# 3. Descriptive Statistics
Generation (MW) Summary:
GAS: Mean ≈ 12,029 MW; max ≈ 27,868 MW

COAL: Mean ≈ 5,511 MW; max ≈ 26,044 MW

NUCLEAR: Mean ≈ 6,277 MW; max ≈ 9,342 MW

WIND: Mean ≈ 4,047 MW; max ≈ 18,382 MW

HYDRO: Mean ≈ 395 MW; max ≈ 1,403 MW

SOLAR: Mean ≈ 936 MW; max ≈ 14,035 MW

IMPORTS: Mean ≈ 2,541 MW; max ≈ 9,148 MW

Percentage Share Summary:

Fossil: Mean ≈ 48.9%

Renewable: Mean ≈ 20.1%

Low Carbon: Mean ≈ 41.8%

Zero Carbon: Mean ≈ 43.1%

# 4. Initial Visualization Insights A. Source Contribution Over Time
Line plots of monthly averages by source reveal:

Coal share declining over the years.

GAS remains the dominant fossil fuel.

Wind and Solar gradually increasing.

Imports vary seasonally, peaking during high-demand periods.

B. Renewable vs Fossil Share
Renewable percentage is increasing over time, while fossil share declines.

Carbon intensity closely follows fossil share – higher fossil usage → higher carbon intensity.

C. Carbon Intensity Relationship
Scatter plots and hexbin plots show:

Positive correlation between fossil share and carbon intensity.

High renewable penetration correlates with lower carbon intensity.

D. Seasonal & Hourly Patterns
Heatmaps of hourly vs monthly average generation:

Peak generation hours are generally morning and early evening.

Winter months have higher overall demand.

Solar contribution is strictly daytime; wind and hydro show variable seasonal patterns.

E. Density Analysis
KDE plots show carbon intensity distribution:

Peaks around 250–500 gCO₂/kWh (low fossil share periods).

Long tail for higher intensity during fossil-heavy periods.

# 5. Observed Trends
Fossil fuels dominate but are slowly declining.

Renewables (wind, solar, hydro, biomass) are gradually increasing.

Carbon intensity follows fossil generation trends and is mitigated by renewable uptake.

Imports occasionally supplement local generation, impacting carbon intensity and generation mix.

Hourly and seasonal patterns highlight variability in demand and renewable output.
Carbon intensity indicators

# Contribution of Renewable Energy Sources as Compared to Fossil Fuels
<img width="1306" height="509" alt="download" src="https://github.com/user-attachments/assets/49829427-6b6a-4264-b6fe-0412667fa39b" />

# Generation: Seasonal Decomposition
<img width="1590" height="1189" alt="download" src="https://github.com/user-attachments/assets/2e97837f-4c0a-4b5b-a8e4-bed6db57694b" />
<img width="1590" height="1189" alt="download" src="https://github.com/user-attachments/assets/0ba6bd95-377e-4ed2-8eb7-1c6535f554f0" />
<img width="1590" height="1189" alt="download" src="https://github.com/user-attachments/assets/5755fd0f-78ab-4745-850c-7bcc391980aa" />
<img width="1590" height="1189" alt="download" src="https://github.com/user-attachments/assets/d86a7196-db93-40f5-be2d-3d3714e76f4b" />
<img width="1589" height="1189" alt="download" src="https://github.com/user-attachments/assets/5a61e3b7-74a0-46b5-bcd2-113eb45b80d8" />

# WIND VS PHOTOVOLTAIC UPTAKE COMPARISON 
<img width="1084" height="525" alt="newplot (14)" src="https://github.com/user-attachments/assets/0d2a621a-dd26-493d-b18c-960763889675" />

# FEATURES ENGINEERING
<img width="618" height="715" alt="ChatGPT Image Feb 15, 2026, 02_21_05 PM" src="https://github.com/user-attachments/assets/b99ea926-ebb0-4436-b302-35b713faa554" />



More Time-Based Features
I want the model to capture daily, weekly, and yearly patterns:

# Original generation sources
GAS, COAL, NUCLEAR, WIND, WIND_EMB, HYDRO, SOLAR, BIOMASS, IMPORTS, OTHER, STORAGE

# Aggregate/derived columns:
GENERATION (total), CARBON_INTENSITY, LOW_CARBON, ZERO_CARBON, RENEWABLE, FOSSIL

# Percentage columns:
e.g., GAS_perc, COAL_perc, NUCLEAR_perc, WIND_perc, ... , RENEWABLE_perc, FOSSIL_perc

# Time-based features (cyclic encoding):
hour, hour_sin, hour_cos

weekday, weekday_sin, weekday_cos

month, month_sin, month_cos

# Lag/rolling features:
GENERATION_lag_1, GENERATION_lag_24, GENERATION_lag_168

GENERATION_roll_24, GENERATION_roll_168

GENERATION_std_24

# Source ratios:
GAS_ratio, COAL_ratio, WIND_ratio, SOLAR_ratio

# Weekday/weekend indicator:
is_weekend (True/False)

# DAY-AHEAD (SHORT-TERM) TOTAL GENERATION FORECASTING USING XGBOOST

<img width="1536" height="1024" alt="ChatGPT Image Feb 15, 2026, 02_42_54 PM" src="https://github.com/user-attachments/assets/7c76a548-0af0-4556-a811-62a2a4909aae" />



            





<img width="1023" height="470" alt="download" src="https://github.com/user-attachments/assets/bb0e775e-cf66-4ed2-9079-17ddb14df701" />
<img width="1158" height="528" alt="download" src="https://github.com/user-attachments/assets/fb1c815f-399d-4f4e-8581-8256fa1663d2" />
<img width="1158" height="528" alt="download" src="https://github.com/user-attachments/assets/c0436351-75a1-4823-9803-a4d8584da161" />
# 1️⃣ R² = 0.9923 → Extremely High Fit

# R² of 0.9923 means:

The model explains 99.23% of the variance in total generation. For electricity demand/generation forecasting, anything above:

0.95 = strong

0.98 = very strong

0.99 = near-perfect short-term fit

So statistically, this is excellent.

However:

High R² is expected in short-term power system forecasting because:

Electricity demand is highly autocorrelated.

Lag features (especially 1h, 24h) are extremely predictive.

Daily and weekly seasonality is very structured.

⚠️ Important: High R² alone does NOT mean operationally perfect.

# 2️⃣ MAE = 408 MW → Practical Error Interpretation

Mean Absolute Error = average absolute forecast error.

Now let's contextualize:

GB total generation typically ranges:

Night low: ~20,000 MW

Peak winter: ~45,000–50,000 MW

So 408 MW error relative to:

30,000 MW average load →
408 / 30,000 ≈ 1.36% error

That is very good for day-ahead forecasting.

In power system planning:

<2% MAE → strong 2–4% → acceptable 5% → operational concern

Your model ≈ ~1–1.5% average deviation

✅ Operationally strong.


# 3️⃣ RMSE = 543 MW → Sensitivity to Spikes

# RMSE penalizes larger errors more than MAE.

Your RMSE (543 MW) > MAE (408 MW), which means:

There are some larger occasional errors, likely during:

# Sudden wind ramps

# Evening demand ramps

# Extreme weather days

# Low solar winter periods

Difference:

543 − 408 = 135 MW

This gap is moderate → not extreme. If RMSE were much larger than MAE, we would suspect:
Severe spike failures

Storm ramp errors

Rare high-magnitude misses

But your model looks stable.

# Bias = +15.7 MW

# Interpretation:

On average, the model overpredicts generation by 15.7 MW.

Relative to total generation (~30,000–40,000 MW), this is extremely small.



# **SOURCE-LEVEL CONTRIBUTION FORECASTING (TO HELP NESO PLAN FOR RENEWABLE PENETRATION, FOSSIL FALLBACK, AND IMPORTS)**

<img width="1536" height="1024" alt="ChatGPT Image Feb 15, 2026, 02_38_21 PM" src="https://github.com/user-attachments/assets/6bce2207-3a95-4562-b3a6-5392e97f091f" />


# System-level operational forecasting

Build a Source-Level Contribution Forecasting Pipeline to predict:

Wind generation

Solar generation

Fossil fallback (gas/coal)

Imports

Renewable penetration (%)

Fossil penetration (%)

For day-ahead planning.

# STEP 1 — Define Targets
# STEP 2 — Feature Engineering (Source-Aware)
We create lags per source. Because each source has different behavior:

Wind → stochastic, autocorrelated

Solar → strong diurnal pattern

Fossil → residual balancing

Imports → interconnector-driven

# Step 3 - Lag Engineering (Half-hour data)
# Step 4 - Rolling Means (shifted)
# Step 5 - Add Time Features


# Multi-Model Forecasting

<img width="1220" height="472" alt="download" src="https://github.com/user-attachments/assets/60ed01b0-ffea-4e4b-984e-751c28dcd3c4" />
<img width="1233" height="472" alt="download" src="https://github.com/user-attachments/assets/b96ae16c-1b3b-4522-8748-9fcb5bf9ec20" />
<img width="1220" height="472" alt="download" src="https://github.com/user-attachments/assets/86de1cab-9c98-4386-a6fe-e12b7d2a7be8" />
<img width="1233" height="472" alt="download" src="https://github.com/user-attachments/assets/847ea9ba-4b73-4806-aceb-8bd31d7b3795" />
<img width="1220" height="472" alt="download" src="https://github.com/user-attachments/assets/5e2cce83-d664-41a9-b4e4-9dfae204f0d4" />

<img width="1233" height="472" alt="download" src="https://github.com/user-attachments/assets/e4c00005-4dfe-4ea5-9acb-0cf2b51d4d6b" />
<img width="1233" height="472" alt="download" src="https://github.com/user-attachments/assets/d4770bff-1f86-4a32-9212-705527bc089b" />
<img width="1220" height="472" alt="download" src="https://github.com/user-attachments/assets/97cd9cbe-f69c-4cc2-99bb-4300ef59ee42" />

# --- WIND Analysis ---
MAE: 242.96 MW
RMSE: 464.16 MW
R²: 0.9885
Forecast Bias: -149.17 MW

# --- SOLAR Analysis ---
MAE: 46.78 MW
RMSE: 257.35 MW
R²: 0.9906
Forecast Bias: -29.13 MW

# --- FOSSIL Analysis ---
MAE: 156.06 MW
RMSE: 224.23 MW
R²: 0.9986
Forecast Bias: 36.46 MW

# --- IMPORTS Analysis ---
MAE: 342.86 MW
RMSE: 649.39 MW
R²: 0.9072
Forecast Bias: -304.79 MW

# 1. WIND

MAE: 242.96 MW, RMSE: 464.16 MW, R²: 0.9885

The MAE and RMSE are reasonably close, indicating the model’s errors are not dominated by extreme outliers.

R² of 0.9885 shows the model explains ~99% of the variance, which is excellent.

Forecast Bias: -149.17 MW

Negative bias → the model tends to underpredict wind generation on average.

Considering wind’s max can reach ~18,382 MW (from your earlier stats), this bias is moderate but worth noting for operational planning.

Interpretation: High R² and moderate bias indicate good overall predictive performance, but NESO should be cautious about slight underestimation during high wind periods.

# 2. SOLAR

MAE: 46.78 MW, RMSE: 257.35 MW, R²: 0.9906

MAE is very low, indicating precise short-term forecasts on average.

RMSE is higher due to occasional peaks (solar peaks are sparse but extreme).

R² is excellent at 0.9906 → almost all variance captured.

Forecast Bias: -29.13 MW

Slight underprediction, which is very minor relative to solar’s max (~14,035 MW).

Interpretation: Highly reliable forecasts for day-ahead solar planning; minimal risk of systematic errors.

# 3. FOSSIL

MAE: 156.06 MW, RMSE: 224.23 MW, R²: 0.9986

Very low MAE and RMSE relative to average fossil generation (~17,507 MW), showing excellent model accuracy.

R² near 0.999 → model captures almost all variability.

Forecast Bias: 36.46 MW

Slight overprediction, very minor relative to total fossil output.

Interpretation: Fossil forecasts are highly dependable, providing NESO confidence in fallback and balancing strategies.

# 4. IMPORTS

MAE: 342.86 MW, RMSE: 649.39 MW, R²: 0.9072

Higher MAE and RMSE relative to other sources; imports are more volatile and less predictable.

R² of 0.9072 → model captures most, but not all, variability; some unexpected swings occur.

Forecast Bias: -304.79 MW

Negative bias → model tends to underpredict imports, which is critical as underestimation could lead to insufficient supply planning.

Interpretation: NESO should be cautious; import forecasts are less reliable, and contingency plans may be required.

# CONCLUSION 

# This study Conducted structured exploratory data analysis of UK electricity generation

- Engineered temporal and autoregressive features

- Developed an XGBoost forecasting benchmark

- Evaluated predictive performance rigorously

- Extracted operational and system-level insights

- The model has been deployed on the web-link: https://kamil-uk-energy-generation-real-time-forecast.streamlit.app/

# The results confirm that UK electricity generation is:

- Highly cyclical

- Strongly autoregressive

- Increasingly influenced by renewable variability

- The XGBoost model serves as a robust benchmark for subsequent deep learning models.


# KAMIL, RIDWAN KEHINDE 
