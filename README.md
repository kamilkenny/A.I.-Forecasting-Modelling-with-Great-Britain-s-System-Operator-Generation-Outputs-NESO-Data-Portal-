# A.I.-Forecasting-Modelling-with-Great-Britain-s-System-Operator-Generation-Outputs-NESO-Data-Portal-
<img width="1024" height="1024" alt="Gemini_Generated_Image_i8d37si8d37si8d3" src="https://github.com/user-attachments/assets/727cfe2c-433a-4c44-9ece-2c5427347219" />

This study analyzes UK electricity generation data with the objective of understanding generation dynamics and developing a machine learning model to forecast total electricity generation.

# Introduction

The UK electricity system has undergone significant transformation due to increasing renewable penetration, declining coal usage, and evolving demand patterns. Accurate short-term electricity generation forecasting is critical for:

- Grid stability

- Energy market operations

- Renewable integration planning

- Carbon reduction strategy
1.2 Objective

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


# Exploratory Data Analysis (EDA) – UK Electricity Generation Dataset
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



