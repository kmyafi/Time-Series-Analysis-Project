#### Package ####
library(TSA)
library(forecast)
library(tseries)
library(ggplot2)
library(lmtest)

#### Import Data ####
tlkm <- read.csv("E:\\Documents\\PTN\\OneDrive - UNIVERSITAS INDONESIA\\Kuliah\\Semester 4\\[SCST602201] Metode Peramalan\\Dataset\\TLKM.JK.csv")
tlkm$Date <- as.Date(tlkm$Date)
View(tlkm)

#### Identifikasi Data ####
summary(tlkm)
ts <- ts(tlkm[,5],
         start = c(2004,10),
         end = c(2023,6),
         frequency = 12)
ts

#### Plot Data ####
tsdisplay(ts)
plot(ts,
     xlab = "Waktu",
     ylab = "Harga Penutupan",
     main = "Harga penutupan Saham PT Telekomunikasi Indonesia Tbk [TLKM]",
     lwd = 2,
     col = "blue")

#### Uji Stasioner ####
# ADF
adf.test(ts)

#### Differencing Model ####
# Differencing
diff_ts <- diff(ts,
                differences = 1)
diff_ts

# Plot
tsdisplay(diff_ts)
BoxCox.ar(ts)
plot(diff_ts,
     xlab = "Waktu",
     ylab = "Harga penutupan",
     main = "Differencing (1) Harga Penutupan Saham PT Telekomunikasi Indonesia Tbk [TLKM]",
     lwd = 2,
     col = "blue")

# Uji Stasioner (ADF test)
adf.test(diff_ts)

# Transformasi setelah melihat visualisasi grafik
tf_ts <- BoxCox(ts, BoxCox.lambda(ts))
diff_tts <- diff(tf_ts, 1)
tsdisplay(diff_tts)

adf.test(diff_tts)

#### Model ARIMA ####
# ACF dan PACF
tsdisplay(diff_tts)

#EACF
eacf(diff_tts)

#Calon model: ARIMA(0,1,0), ARIMA(1,1,1), dan ARIMA(0,1,2)
model1 <- Arima(tf_ts, order = c(0,1,0), include.constant = FALSE)
model2 <- Arima(tf_ts, order = c(1,1,1), include.constant = TRUE)
model3 <- Arima(tf_ts, order = c(0,1,2), include.constant = TRUE)
cbind(model1, model2, model3)

fit <- Arima(tf_ts, order = c(0,1,0), include.constant = FALSE)
fit

auto.arima(ts, trace = TRUE)

#### Diagnosis Model ####
# Uji Stasioner
qqnorm(fit$residuals, pch = 16)
qqline(fit$residuals, lwd = 4, col = "blue")

adf.test(fit$residuals)

# Jarque-Bera
jarque.bera.test(fit$residuals)

# Independensi (Hanya berlaku asumsi kenormalan)
checkresiduals(fit)
adf.test(fit$residuals)

#### Overfitting ####
overfit1 <- Arima(tf_ts, order = c(0,1,1), include.constant = FALSE)
overfit2 <- Arima(tf_ts, order = c(1,1,0), include.constant = FALSE)
cbind(fit, overfit1, overfit2)

#### Forecasting ####
train <- window(ts, end = c(2023,2))
test <- window(ts, start = c(2023,3))

train_fit <- Arima(train, order = c(0,1,0), include.constant = FALSE)
forecast_train <- forecast(train_fit, 4)
forecast_train
cbind(test, forecast_train)

plot(forecast_train,
     fcol = "blue",
     lwd = 2,
     main = "Peramalan ARIMA(0,1,0) melalui Data Training - Testing",
     xlab = "Waktu",
     ylab = "Harga penutupan")
lines(test,
      col = "red",
      lwd = 2)
legend("topleft",
       col = c("blue", "red"), 
       legend = c("Peramalan Nilai Testing","Nilai Aktual"),
       lwd = 2,
       bty = "n")

fit <- Arima(ts, order = c(0,1,0), include.constant = FALSE, lambda = BoxCox.lambda(ts))

forecast_final <- forecast(fit, h = 4)
forecast_final
plot(fcol = "blue",
     forecast_final,
     main = "Peramalan ARIMA(0,1,0) 4 Bulan ke Depan",
     xlab = "Waktu",
     ylab = "Harga penutupan",
     lwd = 2)
legend("topleft",
       col = "blue",
       legend = "Hasil Peramalan",
       lwd = 2,
       bty = "n")

win <- window(ts, start = c(2020,1))
autoplot(win) +
  autolayer(forecast_final)
