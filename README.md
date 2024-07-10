# AirBnb_NN_PricingModel
Overview
This repository contains the analysis conducted by E&M Analytics Consulting Firm to develop a predictive model for Airbnb prices in Washington D.C. during July 2023. The goal is to identify factors influencing pricing strategies and provide actionable insights for Airbnb.

Files
data/: Dataset used for analysis.
scripts/: R scripts for data preprocessing, model building, and evaluation.
results/: Output files, including model performance metrics and summary reports.
README.md: This file.
Requirements
R (version 4.0.0 or higher)
R packages:
neuralnet
caret
dplyr
ggplot2
tidyverse
scales
Install required packages in R:

R
Copy code
install.packages(c("neuralnet", "caret", "dplyr", "ggplot2", "tidyverse", "scales"))
Usage
Data Preprocessing:

Load and preprocess the data using scripts in scripts/preprocessing.R.
Model Building:

Train models using scripts/model_building.R.
Model Evaluation:

Evaluate model performance using scripts/model_evaluation.R.
Results:

Review output files in the results/ directory for performance metrics and insights.
Key Models
Neural Networks with different activation functions using neuralnet and caret packages.
Best model identified: avNNET with bagging parameter from the caret package.
Recommendations
Utilize the avNNET model with bagging for optimized pricing strategies in Washington D.C. based on its superior performance metrics.
