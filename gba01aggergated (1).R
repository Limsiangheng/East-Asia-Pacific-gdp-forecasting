# Install required packages (if not already installed)
#install.packages(c("tidyverse", "forecast", "TTR", "ggplot2", "readr", "lubridate", "tseries", "mFilter"))

# Load libraries
library(tidyverse)   # For data manipulation
library(forecast)    # For forecasting models
library(TTR)         # For moving average smoothing
library(ggplot2)     # For visualization
library(readr)       # For reading CSV files
library(lubridate)   # For handling dates
library(tseries)     # For time series analysis
library(mFilter)     # To check for cyclical 


# Set working directory (Ensure this matches your local folder)
setwd("C:/Users/bryan/OneDrive/Desktop/Uni stuff/ANL317/GBA01")

# Load GDP and Population datasets
gdp_data <- read.csv("GDP.csv", header = TRUE)
pop_data <- read.csv("Population.csv", header = TRUE)


# Reshape GDP data from wide to long format
gdp_long <- gdp_data %>%
  pivot_longer(cols = starts_with("X"), 
               names_to = "Year", 
               values_to = "GDP") %>%
  mutate(Year = as.numeric(gsub("X|\\.YR.*", "", Year))) %>%
  select(Year, GDP)

# Reshape Population data from wide to long format
pop_long <- pop_data %>%
  filter(Series.Name == "Population, total") %>% # Select only Population data
  pivot_longer(cols = starts_with("X"), 
               names_to = "Year", 
               values_to = "Population") %>%
  mutate(Year = as.numeric(gsub("X|\\.YR.*", "", Year))) %>%
  select(Year, Population)

# Merge GDP and Population datasets by Year
merged_data <- merge(gdp_long, pop_long, by = "Year")

# Convert to time series format
gdp_ts <- ts(merged_data$GDP, start = min(merged_data$Year), frequency = 1)
pop_ts <- ts(merged_data$Population, start = min(merged_data$Year), frequency = 1)

# Inspect the cleaned data
head(merged_data)

##### 📌 Outlier Detection in GDP Data #####

# 1️⃣ Boxplot Method (Using Interquartile Range - IQR)
Q1 <- quantile(merged_data$GDP, 0.25, na.rm = TRUE)  # First quartile (25%)
Q3 <- quantile(merged_data$GDP, 0.75, na.rm = TRUE)  # Third quartile (75%)
IQR_value <- Q3 - Q1  # Interquartile range
lower_bound <- Q1 - 1.5 * IQR_value  # Lower fence
upper_bound <- Q3 + 1.5 * IQR_value  # Upper fence

# Identify outliers
outliers_iqr <- merged_data %>%
  filter(GDP < lower_bound | GDP > upper_bound)

cat("\n📌 Outliers detected using IQR Method:\n")
print(outliers_iqr)

# Boxplot visualization
ggplot(merged_data, aes(y = GDP)) +
  geom_boxplot(fill = "lightblue") +
  geom_jitter(aes(x = 1), width = 0.1, alpha = 0.5) +
  labs(title = "Boxplot of GDP - Identifying Outliers", y = "GDP", x = "") +
  theme_minimal()

# Compute median GDP
median_gdp <- median(merged_data$GDP, na.rm = TRUE)

# Replace outliers directly in the GDP column
merged_data$GDP <- ifelse(merged_data$GDP < lower_bound | merged_data$GDP > upper_bound, median_gdp, merged_data$GDP)

# Summary of modified GDP column
summary(merged_data$GDP)

# Visualize cleaned GDP data
ggplot(merged_data, aes(x = Year, y = GDP)) +
  geom_line(color = "blue") +
  labs(title = "GDP After Outlier Replacement", x = "Year", y = "GDP") +
  theme_minimal()

# Boxplot of GDP after outlier replacement
ggplot(merged_data, aes(y = GDP)) +
  geom_boxplot(fill = "lightblue") +
  geom_jitter(aes(x = 1), width = 0.1, alpha = 0.5) +
  labs(title = "Boxplot of GDP After Outlier Replacement", y = "GDP", x = "") +
  theme_minimal()
##### 📌 Time Series Exploration & Statistical Analysis #####

# Basic Statistics
cat("\nBasic Statistics for GDP Time Series:\n")
cat("Mean GDP:", mean(merged_data$GDP, na.rm = TRUE), "\n")
cat("Variance:", var(merged_data$GDP, na.rm = TRUE), "\n")
cat("Standard Deviation:", sd(merged_data$GDP, na.rm = TRUE), "\n")

# Plot GDP and Population Over Time
ggplot(merged_data, aes(x = Year, y = GDP)) +
  geom_line(color = "blue") + geom_point() +
  labs(title = "GDP Over Time", x = "Year", y = "GDP")

ggplot(merged_data, aes(x = Year, y = Population)) +
  geom_line(color = "red") + geom_point() +
  labs(title = "Population Over Time", x = "Year", y = "Population")

# Check for stationarity using Augmented Dickey-Fuller test
cat("\nADF Test for GDP:\n")
adf.test(gdp_ts)

cat("\nADF Test for Population:\n")
adf.test(pop_ts)

# Autocorrelation and Partial Autocorrelation
acf(gdp_ts, main = "GDP Autocorrelation")
pacf(gdp_ts, main = "GDP Partial Autocorrelation")

# Statistical Tests
cat("\nStatistical Tests:\n")
t.test(merged_data$GDP, mu = mean(merged_data$GDP, na.rm = TRUE))
shapiro.test(merged_data$GDP)

# Q-Q Plot for Normality
ggplot(merged_data, aes(sample = GDP)) +
  stat_qq() + stat_qq_line(color = "red") +
  labs(title = "Q-Q Plot for GDP", x = "Theoretical Quantiles", y = "Sample Quantiles")


##### 📌 Time Series Smoothing #####

##### 📌 Remove 2023 from Training Data #####
merged_data_train <- merged_data[merged_data$Year < 2023, ]  # Keep only data up to 2022

##### 📌 Compute Moving Averages (3-Year, 5-Year, 7-Year) #####
merged_data_train$GDP_MA_3 <- SMA(merged_data_train$GDP, n = 3)
merged_data_train$GDP_MA_5 <- SMA(merged_data_train$GDP, n = 5)
merged_data_train$GDP_MA_7 <- SMA(merged_data_train$GDP, n = 7)

##### 📌 Forecast GDP for 2023 Using Moving Averages #####
gdp_forecast_ma_3 <- tail(merged_data_train$GDP_MA_3, 1)  # Last 3-year MA for 2022
gdp_forecast_ma_5 <- tail(merged_data_train$GDP_MA_5, 1)  # Last 5-year MA for 2022
gdp_forecast_ma_7 <- tail(merged_data_train$GDP_MA_7, 1)  # Last 7-year MA for 2022

##### 📌 Extract Actual 2023 GDP #####
actual_gdp_2023 <- merged_data$GDP[merged_data$Year == 2023]

##### 📌 Compare Forecasted vs Actual GDP for 2023 #####
forecast_comparison_ma <- data.frame(
  Model = c("3-Year MA", "5-Year MA", "7-Year MA"),
  Forecasted_GDP_2023 = c(gdp_forecast_ma_3, gdp_forecast_ma_5, gdp_forecast_ma_7),
  Actual_GDP_2023 = actual_gdp_2023,
  Error = c(gdp_forecast_ma_3, gdp_forecast_ma_5, gdp_forecast_ma_7) - actual_gdp_2023
)

print(forecast_comparison_ma)

##### 📌 Plot GDP with Moving Average Trends #####
ggplot(merged_data_train, aes(x = Year)) +
  geom_line(aes(y = GDP), color = "blue", size = 1, alpha = 0.6) +  # Original GDP
  geom_line(aes(y = GDP_MA_3), color = "green", size = 1, linetype = "dashed") +  # 3-year MA
  geom_line(aes(y = GDP_MA_5), color = "red", size = 1) +  # 5-year MA
  geom_line(aes(y = GDP_MA_7), color = "purple", size = 1, linetype = "dotdash") +  # 7-year MA
  labs(title = "GDP with 3-Year, 5-Year, and 7-Year Moving Averages",
       x = "Year", y = "GDP",
       subtitle = "Green = 3-Year MA, Red = 5-Year MA, Purple = 7-Year MA") +
  theme_minimal()

##### 📌 Compute Residuals from Moving Averages #####
gdp_residuals_ma_3 <- merged_data_train$GDP - merged_data_train$GDP_MA_3
gdp_residuals_ma_5 <- merged_data_train$GDP - merged_data_train$GDP_MA_5
gdp_residuals_ma_7 <- merged_data_train$GDP - merged_data_train$GDP_MA_7

##### 📌 Plot Residuals #####
ggplot(data.frame(Year = merged_data_train$Year, Residuals = gdp_residuals_ma_3), aes(x = Year, y = Residuals)) +
  geom_line(color = "green") +
  labs(title = "Residuals from 3-Year Moving Average", x = "Year", y = "Residuals") +
  theme_minimal()

ggplot(data.frame(Year = merged_data_train$Year, Residuals = gdp_residuals_ma_5), aes(x = Year, y = Residuals)) +
  geom_line(color = "red") +
  labs(title = "Residuals from 5-Year Moving Average", x = "Year", y = "Residuals") +
  theme_minimal()

ggplot(data.frame(Year = merged_data_train$Year, Residuals = gdp_residuals_ma_7), aes(x = Year, y = Residuals)) +
  geom_line(color = "purple") +
  labs(title = "Residuals from 7-Year Moving Average", x = "Year", y = "Residuals") +
  theme_minimal()

##### 📌 Test if Residuals Are White Noise #####
# If p-value < 0.05, residuals are NOT white noise

cat("\nLjung-Box Test for 3-Year MA Residuals:\n")
Box.test(na.omit(gdp_residuals_ma_3), type = "Ljung-Box")

cat("\nLjung-Box Test for 5-Year MA Residuals:\n")
Box.test(na.omit(gdp_residuals_ma_5), type = "Ljung-Box")

cat("\nLjung-Box Test for 7-Year MA Residuals:\n")
Box.test(na.omit(gdp_residuals_ma_7), type = "Ljung-Box")

# Checking for cyclical nature
#library(mFilter)

# Apply HP filter to GDP residuals
#gdp_hp <- hpfilter(gdp_residuals_ma, freq = 100)  # `freq = 100` smooths the trend

# Plot cyclical component
#ggplot(data.frame(Year = merged_data$Year, Cycle = gdp_hp$cycle), aes(x = Year, y = Cycle)) +
  #geom_line(color = "darkgreen") +
  #labs(title = "Cyclical Component of GDP Residuals", x = "Year", y = "Cycle") +
  #theme_minimal()
#summary(gdp_hp$cycle)  # Should show non-zero values



##### 📌 Remove 2023 from Training Data #####
gdp_ts_train <- window(gdp_ts, end = 2022)  # Train only on data up to 2022

##### 📌 Apply Exponential Smoothing Models #####
# Simple Exponential Smoothing (SES)
gdp_ses <- ses(gdp_ts_train, h = 1)

# Double Exponential Smoothing (Holt’s Linear Trend)
gdp_holt <- holt(gdp_ts_train, h = 1)

# Forecast GDP for 2023
gdp_forecast_ses <- forecast(gdp_ses, h = 1)
gdp_forecast_holt <- forecast(gdp_holt, h = 1)

##### 📌 Extract Actual 2023 GDP #####
actual_gdp_2023 <- merged_data$GDP[merged_data$Year == 2023]

# Print Forecasted vs Actual GDP for 2023
print(data.frame(Year = 2023, 
                 SES_Forecast = gdp_forecast_ses$mean, 
                 Holt_Forecast = gdp_forecast_holt$mean, 
                 Actual_GDP_2023 = actual_gdp_2023))

##### 📌 Plot Forecasts #####
autoplot(gdp_forecast_ses) + 
  labs(title = "Simple Exponential Smoothing Forecast", x = "Year", y = "GDP")

autoplot(gdp_forecast_holt) + 
  labs(title = "Holt’s Linear Trend Forecast (Double Exponential Smoothing)", x = "Year", y = "GDP")

##### 📌 Step 2: Compare Forecasts with Actual 2023 GDP #####
ses_forecast_2023 <- gdp_forecast_ses$mean[1]  # SES Prediction for 2023
holt_forecast_2023 <- gdp_forecast_holt$mean[1]  # Holt Prediction for 2023

forecast_comparison <- data.frame(
  Model = c("SES", "Holt"),
  Forecasted_GDP_2023 = c(ses_forecast_2023, holt_forecast_2023),
  Actual_GDP_2023 = actual_gdp_2023,
  Error = c(ses_forecast_2023, holt_forecast_2023) - actual_gdp_2023
)

print(forecast_comparison)

##### 📌 Step 3: Calculate Forecast Accuracy Metrics #####

# Function to calculate accuracy metrics
calculate_accuracy <- function(forecast, actual) {
  mae <- mean(abs(forecast - actual))  # Mean Absolute Error
  rmse <- sqrt(mean((forecast - actual)^2))  # Root Mean Squared Error
  mape <- mean(abs((forecast - actual) / actual)) * 100  # Mean Absolute Percentage Error (MAPE)
  
  return(data.frame(MAE = mae, RMSE = rmse, MAPE = mape))
}

# Compute accuracy for each model
accuracy_ses <- calculate_accuracy(ses_forecast_2023, actual_gdp_2023)
accuracy_holt <- calculate_accuracy(holt_forecast_2023, actual_gdp_2023)

# Combine results into a single table
accuracy_results <- rbind(
  cbind(Model = "SES", accuracy_ses),
  cbind(Model = "Holt", accuracy_holt)
)

# Print accuracy results
print(accuracy_results)

##### 📌 Step 4: Visualization of Forecast Performance #####
ggplot(forecast_comparison, aes(x = Model, y = Forecasted_GDP_2023)) +
  geom_bar(stat = "identity", fill = "steelblue", width = 0.5) +
  geom_hline(aes(yintercept = actual_gdp_2023), color = "red", linetype = "dashed") +
  labs(title = "Comparison of Forecasted vs Actual GDP (2023)", 
       subtitle = "Red dashed line represents actual GDP", 
       x = "Forecast Model", y = "GDP") +
  theme_minimal()



##### 📌 Remove 2023 from Training Data #####
pop_ts_train <- window(pop_ts, end = 2022)  # Train only on data up to 2022

##### 📌 Apply Exponential Smoothing Models #####
# Simple Exponential Smoothing (SES)
pop_ses <- ses(pop_ts_train, h = 1)

# Double Exponential Smoothing (Holt’s Linear Trend)
pop_holt <- holt(pop_ts_train, h = 1)

# Forecast Population for 2023
pop_forecast_ses <- forecast(pop_ses, h = 1)
pop_forecast_holt <- forecast(pop_holt, h = 1)

##### 📌 Extract Actual Population for 2023 #####
actual_pop_2023 <- merged_data$Population[merged_data$Year == 2023]

# Print Forecasted vs Actual Population for 2023
print(data.frame(Year = 2023, 
                 SES_Forecast = pop_forecast_ses$mean, 
                 Holt_Forecast = pop_forecast_holt$mean, 
                 Actual_Pop_2023 = actual_pop_2023))

##### 📌 Plot Forecasts #####
autoplot(pop_forecast_ses) + 
  labs(title = "Simple Exponential Smoothing Forecast for Population", x = "Year", y = "Population")

autoplot(pop_forecast_holt) + 
  labs(title = "Holt’s Linear Trend Forecast for Population", x = "Year", y = "Population")

##### 📌 Step 2: Compare Forecasts with Actual 2023 Population #####
ses_forecast_2023 <- pop_forecast_ses$mean[1]  # SES Prediction for 2023
holt_forecast_2023 <- pop_forecast_holt$mean[1]  # Holt Prediction for 2023

forecast_comparison <- data.frame(
  Model = c("SES", "Holt"),
  Forecasted_Pop_2023 = c(ses_forecast_2023, holt_forecast_2023),
  Actual_Pop_2023 = actual_pop_2023,
  Error = c(ses_forecast_2023, holt_forecast_2023) - actual_pop_2023
)

print(forecast_comparison)

##### 📌 Step 3: Calculate Forecast Accuracy Metrics #####

# Function to calculate accuracy metrics
calculate_accuracy <- function(forecast, actual) {
  mae <- mean(abs(forecast - actual))  # Mean Absolute Error
  rmse <- sqrt(mean((forecast - actual)^2))  # Root Mean Squared Error
  mape <- mean(abs((forecast - actual) / actual)) * 100  # Mean Absolute Percentage Error (MAPE)
  
  return(data.frame(MAE = mae, RMSE = rmse, MAPE = mape))
}

# Compute accuracy for each model
accuracy_ses <- calculate_accuracy(ses_forecast_2023, actual_pop_2023)
accuracy_holt <- calculate_accuracy(holt_forecast_2023, actual_pop_2023)

# Combine results into a single table
accuracy_results <- rbind(
  cbind(Model = "SES", accuracy_ses),
  cbind(Model = "Holt", accuracy_holt)
)

# Print accuracy results
print(accuracy_results)

##### 📌 Step 4: Visualization of Forecast Performance #####
ggplot(forecast_comparison, aes(x = Model, y = Forecasted_Pop_2023)) +
  geom_bar(stat = "identity", fill = "steelblue", width = 0.5) +
  geom_hline(aes(yintercept = actual_pop_2023), color = "red", linetype = "dashed") +
  labs(title = "Comparison of Forecasted vs Actual Population (2023)", 
       subtitle = "Red dashed line represents actual Population", 
       x = "Forecast Model", y = "Population") +
  theme_minimal()
