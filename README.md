# East Asia & Pacific GDP Forecasting

## Project Overview

This project applies **time series analysis and forecasting techniques** to analyse and forecast **Gross Domestic Product (GDP) in East Asia and the Pacific**.

Using historical data from the **World Bank World Development Indicators (WDI)** covering **1981–2023**, the project investigates historical GDP patterns, evaluates its relationship with population growth, and compares different smoothing and forecasting approaches.

The primary objective was to determine an appropriate forecasting model for GDP by comparing:

- Moving Average models
- Simple Exponential Smoothing (SES)
- Double Exponential Smoothing (Holt's Linear Trend)

GDP was selected as the **major time series**, while population was used as a secondary series to investigate its relationship with regional economic growth.

---

## Business / Research Question

Economic forecasting is important for understanding long-term economic development and supporting planning and policy decisions.

This project addresses three main questions:

1. What historical trends and patterns can be observed in East Asia and Pacific GDP?
2. What relationship exists between GDP and population growth?
3. Which forecasting approach provides the most suitable representation of future GDP — **Simple Exponential Smoothing or Double Exponential Smoothing?**

---

## Dataset

The datasets were obtained from the **World Bank World Development Indicators (WDI)**.

**Period analysed:** 1981–2023

Two variables were used:

| Variable | Role |
|---|---|
| GDP (Current US$) | Major time series / forecasting target |
| Population, Total | Secondary time series |

The original World Bank datasets were provided in wide format and transformed into a structure suitable for time series analysis in R.

---

## Data Preparation

### 1. Reshaping

The original GDP and population datasets were transformed from **wide format to long format** using `pivot_longer()`.

The year information was extracted and converted into a numerical format before the two datasets were merged by year.

### 2. Time Series Conversion

GDP and population were converted into R time series objects using:

```r
ts()
```

Because the observations were annual, a frequency of **1** was used.

### 3. Missing Value Analysis

Missing observations were checked before modelling.

No missing values were identified in the final GDP and population series used for analysis.

### 4. Outlier Detection

Potential outliers were evaluated using the **Interquartile Range (IQR)** method:

```text
Lower Bound = Q1 - 1.5 × IQR
Upper Bound = Q3 + 1.5 × IQR
```

No significant outliers were identified in either GDP or population.

---

## Exploratory Time Series Analysis

### Descriptive Analysis

GDP between 1981 and 2023 showed substantial long-term economic growth.

The analysis found:

- Mean GDP: approximately **US$12.67 trillion**
- Median GDP: approximately **US$8.41 trillion**
- Minimum GDP: approximately **US$1.99 trillion**
- Maximum GDP: approximately **US$31.16 trillion**

The mean being considerably higher than the median indicated a **right-skewed distribution**, reflecting much higher GDP levels during more recent years.

---

## Trend Analysis

A linear trend analysis showed a clear **long-term upward trajectory in GDP**, although several periods contained noticeable fluctuations.

Possible disruptions observed in the series included:

- slower growth around the **2008 Global Financial Crisis**
- economic disruption around the **COVID-19 pandemic**
- subsequent changes in the regional economic trajectory

These observations suggested that GDP contained a meaningful **trend component**, which became important when selecting an appropriate forecasting model.

---

## Autocorrelation Analysis

An **Autocorrelation Function (ACF)** was used to examine the relationship between GDP and its historical values.

The autocorrelation gradually declined as the lag increased and remained statistically significant for several initial lags.

This indicates strong persistence in GDP — recent historical GDP values contain useful information for forecasting subsequent values.

---

## Statistical Analysis

### Normality Test

A **Shapiro-Wilk test** was used to evaluate whether GDP followed a normal distribution.

```text
p-value = 0.0003749
```

Since the p-value was below 0.05, the null hypothesis of normality was rejected.

The accompanying Q-Q plot also showed deviations from the theoretical normal distribution, particularly at the tails.

### Location Test

A one-sample t-test was also conducted.

```text
p-value = 0.004028
```

The result provided further evidence of differences between the observed GDP distribution and its reference value.

---

## GDP and Population Relationship

A scatter plot was used to investigate the relationship between **population and GDP**.

The analysis showed a strong **positive relationship**:

> GDP generally increased as the population of East Asia and the Pacific increased.

At higher population levels, GDP appeared to increase at a faster rate, suggesting that economic growth may not be explained by population growth alone.

Other factors such as productivity, industrialisation, economic policy and technological development may also influence the relationship.

A regression analysis further indicated that the relationship between GDP and population was statistically significant.

---

## Seasonality Analysis

Because the dataset contains **annual observations**, conventional within-year seasonality is not present.

A longer-term seasonal investigation conducted during the project did not identify a statistically significant seasonal component.

Therefore, **Holt-Winters seasonal exponential smoothing was not selected**.

Instead, the forecasting analysis focused on models designed primarily for **level and trend**.

---

# Forecasting Methods

## 1. Moving Average

Three moving-average windows were evaluated:

- **3-Year Moving Average**
- **5-Year Moving Average**
- **7-Year Moving Average**

The models demonstrated the trade-off between responsiveness and smoothing.

### 3-Year Moving Average

Most responsive to recent GDP movements and better at capturing shorter-term fluctuations.

### 5-Year Moving Average

Provided a balance between short-term responsiveness and long-term smoothing.

### 7-Year Moving Average

Produced the smoothest representation of the underlying GDP trend but reacted more slowly to economic changes.

For short-term forecasting, the **3-year moving average** was considered the most responsive of the three approaches.

---

# Exponential Smoothing Models

Two primary forecasting models were compared.

## 2. Simple Exponential Smoothing (SES)

SES applies exponentially decreasing weights to historical observations, placing greater emphasis on recent data.

### Strengths

- Computationally simple
- Responsive to recent observations
- Suitable for short-term forecasting
- Produced relatively stable forecasts

### Limitation

SES does **not explicitly model trend**.

Because GDP exhibited substantial long-term growth, SES eventually produced a relatively flat forecast that did not adequately represent continued economic expansion.

---

## 3. Double Exponential Smoothing

**Holt's Linear Trend Method**, also known as Double Exponential Smoothing (DES), extends exponential smoothing by modelling both:

- Level
- Trend

This made the model particularly relevant for GDP because the historical series demonstrated a strong upward trend.

Unlike SES, the DES forecast continued the historical growth trajectory into the forecast period.

---

# Model Comparison

The two models produced noticeably different forecasting behaviour.

| Model | Behaviour | Main Strength | Main Limitation |
|---|---|---|---|
| SES | Relatively flat forecast | Stable short-term prediction | Does not model trend |
| DES / Holt | Upward forecast | Captures long-term GDP trend | Greater forecast uncertainty |

SES generated a forecast closer to the observed GDP value for the immediate 2023 holdout period.

However, forecasting GDP involves more than minimising a single one-year prediction error.

The historical series demonstrated a strong trend, making the trend component incorporated by **Double Exponential Smoothing** important for longer-term forecasting.

---

## Model Evaluation

The forecasting models were evaluated using several accuracy and model-selection measures, including:

- Mean Absolute Deviation (MAD)
- Mean Squared Deviation (MSD)
- Root Mean Squared Error (RMSE)
- Mean Absolute Percentage Error (MAPE)
- Akaike Information Criterion (AIC)

SES produced lower error measures in the project's comparison, while DES produced a **lower AIC** and represented the historical trend more effectively.

This highlights an important forecasting consideration:

> The model with the smallest immediate forecast error is not necessarily the model that best represents the underlying structure of a time series.

---

# Key Findings

### 1. GDP demonstrates strong long-term growth

East Asia and Pacific GDP showed a substantial upward trajectory between 1981 and 2023 despite economic disruptions.

### 2. GDP is highly persistent

Autocorrelation analysis showed that historical GDP values remain strongly related to subsequent observations.

### 3. GDP and population are positively related

Population growth was associated with increasing GDP, although the relationship suggests that other economic factors also contribute to growth.

### 4. No meaningful seasonality was identified

The annual nature of the data and statistical analysis provided little evidence supporting the use of a seasonal forecasting model.

### 5. SES performed well for immediate forecasting

Simple Exponential Smoothing generated a relatively accurate short-term forecast but failed to represent the continuing GDP trend.

### 6. Double Exponential Smoothing better represented long-term behaviour

Holt's model incorporated the trend component and therefore produced forecasts that better reflected the historical structure of GDP.

---

# Final Model Selection

## Double Exponential Smoothing (Holt's Linear Trend)

Overall, **Double Exponential Smoothing was selected as the preferred forecasting approach**.

Although SES produced lower error metrics for the immediate forecast, its flat forecast structure was inconsistent with the strong historical GDP trend.

DES provided a better balance between:

- historical fit
- trend representation
- forecasting capability
- long-term interpretability

For an economic indicator such as GDP, explicitly modelling the underlying trend provides a more meaningful basis for longer-term forecasting.

---

# Limitations

Several limitations should be considered when interpreting the forecasts.

### External Economic Shocks

Time series models primarily learn from historical patterns and may not anticipate unexpected events such as:

- financial crises
- pandemics
- geopolitical events
- major policy changes

### Limited Explanatory Variables

Population was the primary secondary variable examined.

GDP is influenced by many additional factors including productivity, investment, trade, inflation, technology and government policy.

### Annual Data

The use of annual observations limits the number of available observations and prevents analysis of shorter-term quarterly or monthly economic patterns.

### Trend Extrapolation

Holt's model assumes that historical trend behaviour provides useful information about future growth. Structural economic changes could cause future GDP to deviate substantially from this trajectory.

---

# Tools & Technologies

- **R** — Data preparation, statistical analysis and forecasting
- **tidyverse / dplyr** — Data manipulation
- **ggplot2** — Data visualisation
- **forecast** — SES and Holt forecasting models
- **TTR** — Moving-average calculations
- **tseries** — Time series statistical analysis
- **World Bank World Development Indicators** — GDP and population datasets

---

# Repository Structure

```text
east-asia-pacific-gdp-forecasting/
│
├── README.md
│
├── code/
│   └── gdp_forecasting.R
│
├── data/
│   ├── GDP.csv
│   └── Population.csv
│
└── report/
    └── ANL317_Business_Forecasting_Report.docx
```

---

# Project Context

This project was completed as a **group project for ANL317 Business Forecasting** at the Singapore University of Social Sciences (SUSS).

The project demonstrates practical application of:

**Time Series Analysis · Data Preparation · Exploratory Data Analysis · Moving Averages · Exponential Smoothing · Forecast Evaluation · Statistical Testing · R Programming**
