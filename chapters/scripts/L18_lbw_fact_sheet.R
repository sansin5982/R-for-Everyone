# =====================================================================
# Low birth weight fact sheet: Baystate Medical Center, 1986
# R for Everyone, Level 1 capstone (Lesson 18)
# Author: Dr. Sandeep Kumar Singh
#
# Data: birthwt (MASS package), 189 births, Hosmer and Lemeshow (1989)
# Run this script from inside the RStudio Project, top to bottom,
# on a fresh R session (Session -> Restart R).
# =====================================================================

# ---- 0. Setup ----
library(MASS)                                   # source of the birthwt data
dir.create("data", showWarnings = FALSE)        # project folders (no-op if present)
dir.create("outputs", showWarnings = FALSE)

# ---- 1. Get the raw data into the project ----
# In a real project the hospital would send this file; here we create it
# once from the package so that the analysis starts from a file.
write.csv(birthwt, "data/birthwt_raw.csv", row.names = FALSE)

# ---- 2. Read the raw data ----
raw <- read.csv("data/birthwt_raw.csv")
str(raw)

# ---- 3. Check the data ----
dim(raw)                                        # expect 189 rows, 10 columns
anyNA(raw)                                      # any missing values at all?
range(raw$bwt)                                  # plausible birth weights?
range(raw$age)                                  # plausible maternal ages?
table(raw$smoke)                                # only codes 0 and 1?

# ---- 4. Prepare an analysis copy ----
births <- raw
births$smoke <- factor(births$smoke, levels = c(0, 1),
                       labels = c("Non-smoker", "Smoker"))
births$race <- factor(births$race, levels = c(1, 2, 3),
                      labels = c("White", "Black", "Other"))
births$bwt_cat <- cut(births$bwt, breaks = c(0, 1500, 2500, Inf), right = FALSE,
                      labels = c("Very low", "Low", "Normal"))
births$lbw <- births$bwt < 2500                 # TRUE = low birth weight
births$lwt_kg <- round(births$lwt * 0.45359237, digits = 1)

# ---- 5. Describe ----
n_babies   <- nrow(births)
n_lbw      <- sum(births$lbw)
pct_lbw    <- round(mean(births$lbw) * 100, digits = 1)
n_very_low <- sum(births$bwt_cat == "Very low")
mean_bwt   <- round(mean(births$bwt))
sd_bwt     <- round(sd(births$bwt))
median_age <- median(births$age)
pct_smoke  <- round(mean(births$smoke == "Smoker") * 100, digits = 1)

summary(births$bwt)
table(births$bwt_cat)

# ---- 6. Compare by smoking status ----
smoke_table <- table(births$smoke, births$bwt_cat)
smoke_table

lbw_by_smoke <- round(c(mean(births$lbw[births$smoke == "Non-smoker"]),
                        mean(births$lbw[births$smoke == "Smoker"])) * 100, digits = 1)
mean_by_smoke <- round(c(mean(births$bwt[births$smoke == "Non-smoker"]),
                         mean(births$bwt[births$smoke == "Smoker"])))
names(lbw_by_smoke) <- levels(births$smoke)
names(mean_by_smoke) <- levels(births$smoke)
lbw_by_smoke
mean_by_smoke

# ---- 7. Figures ----
png("outputs/fig1_birthweight_histogram.png", width = 1600, height = 1000, res = 200)
hist(births$bwt, breaks = seq(500, 5000, by = 250), col = "grey85", border = "white",
     main = "Birth weight of 189 babies", xlab = "Birth weight (g)",
     ylab = "Number of babies")
abline(v = 2500, col = "tomato", lwd = 2, lty = 2)
dev.off()

png("outputs/fig2_birthweight_by_smoking.png", width = 1600, height = 1000, res = 200)
boxplot(bwt ~ smoke, data = births, col = c("#9FE1CB", "#F5C4B3"),
        main = "Birth weight by mother's smoking status",
        xlab = "", ylab = "Birth weight (g)")
abline(h = 2500, col = "grey40", lty = 3)
dev.off()

# ---- 8. Save results ----
results <- data.frame(group = levels(births$smoke),
                      n = as.vector(table(births$smoke)),
                      mean_bwt_g = as.vector(mean_by_smoke),
                      lbw_percent = as.vector(lbw_by_smoke))
write.csv(results, "outputs/table1_by_smoking.csv", row.names = FALSE)
saveRDS(births, "data/births_analysis.rds")

# ---- 9. The fact sheet ----
cat("LOW BIRTH WEIGHT FACT SHEET: Baystate Medical Center, 1986\n",
    "Babies studied: ", n_babies, "\n",
    "Low birth weight (under 2500 g): ", n_lbw, " babies (", pct_lbw, "%)\n",
    "Very low birth weight (under 1500 g): ", n_very_low, " babies\n",
    "Mean birth weight: ", mean_bwt, " g (SD ", sd_bwt, " g)\n",
    "Median age of mothers: ", median_age, " years\n",
    "Mothers who smoked in pregnancy: ", pct_smoke, "%\n",
    "Low birth weight: ", lbw_by_smoke["Non-smoker"], "% of babies of non-smokers, ",
    lbw_by_smoke["Smoker"], "% of babies of smokers\n",
    "Mean birth weight: ", mean_by_smoke["Non-smoker"], " g (non-smokers), ",
    mean_by_smoke["Smoker"], " g (smokers)\n",
    sep = "")

# ---- 10. Record the software used ----
sessionInfo()
