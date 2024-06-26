#Airbnb Neural Network - R file

library(caret) #For confusionMatrix(), training ML models, and more
library(neuralnet) #For neuralnet() function
library(dplyr) #For some data manipulation and ggplot
library(fastDummies) #To create dummy variable (one hot encoding)
library(sigmoid) #For the relu activation function

#library(DT)
library(tidyverse)
library(corrplot)
library(ggpubr)
#library(visdat)
library(modeest)
#library(RColorBrewer)
#library(GGally)
#library(sf)

airbnb = read.csv("AirbnbListings.csv", stringsAsFactors = TRUE)
str(airbnb)
summary(airbnb)

#Remove variables that we will not use 
airbnb=airbnb %>% select(-c(listing_id, host_since)) #, room_type, neighborhood

blank_count <- sum(airbnb$room_type == "")
#blank_count <- sum(apply(airbnb, 2, function(x) sum(x == "")))
airbnb$room_type[airbnb$room_type == ""] <- NA
# airbnb$room_type[airbnb$room_type == ""] <- NA
# 
# #Replace NA room values with mode for room_type
# 
# #library(modeest)
# #mostOccurRoomType = mfv(airbnb$room_type, na_rm = TRUE)
# #airbnb <- airbnb %>% mutate(room_type = replace_na(room_type, mostOccurRoomType))
# 
# 
# airbnb$room_type[!(airbnb$room_type %in% c("Entire home/apt", "Private room", "Shared room"))] <- NA
# #airbnb$room_type[airbnb$room_type == ""] <- "Shared room"
# summary(airbnb$room_type)
# unique_values <- length(unique(airbnb$room_type))

#Check for columns/variables with missing values

#Variables with Missing Values
VariablesNA <- which(sapply(airbnb, anyNA)) %>% names()
cat(VariablesNA, sep = ", ")

summary(airbnb)

#Create dummy variables for each level of the categorical variables of interest
#Removing categorical variables and one dummy level of each categorical variables
final_data = dummy_cols(airbnb, select_columns = c("superhost", "neighborhood", "room_type", "bathrooms"), #"bathrooms",
                        #"room_type", Warning: No variation for for: bathrooms_4.5 baths
                        remove_selected_columns = T,
                        remove_first_dummy = T)

#rename columns
summary(final_data)



#Variables with Missing Values
VariablesNA <- which(sapply(final_data, anyNA)) %>% names()
cat(VariablesNA, sep = ", ")
#missing vals for: host_acceptance_rate, bedrooms, room_type_Entire home/apt, room_type_Private room, room_type_Shared room


#rename columns 
names(final_data)[names(final_data) == "neighborhood_Dupont Circle"] <- "Dupont_Circle"
names(final_data)[names(final_data) == "neighborhood_Foggy Bottom"] <- "Foggy_Bottom"
names(final_data)[names(final_data) == "neighborhood_Union Station"] <- "Union_Station"
names(final_data)[names(final_data) == "room_type_Entire home/apt"] <- "rt_Entire_home_apt"

names(final_data)[names(final_data) == "room_type_Private room"] <- "rt_Private"
names(final_data)[names(final_data) == "room_type_Shared room"] <- "rt_Shared"
names(final_data)[names(final_data) == "bathrooms_1 private bath"] <- "bt_1_priv_bath"
names(final_data)[names(final_data) == "bathrooms_1 shared bath"] <- "bt_1_shared_bath"

names(final_data)[names(final_data) == "bathrooms_1.5 baths"] <- "bt_1_5_baths"
names(final_data)[names(final_data) == "bathrooms_1.5 shared baths"] <- "bt_1_5_shared_baths"
names(final_data)[names(final_data) == "bathrooms_2 shared baths"] <- "bt_2_shared_baths"
names(final_data)[names(final_data) == "bathrooms_2 baths"] <- "bt_2_bath"

names(final_data)[names(final_data) == "bathrooms_2.5 baths"] <- "bt_2_5_baths"
names(final_data)[names(final_data) == "bathrooms_2.5 shared baths"] <- "bt_2_5_shared_baths"
names(final_data)[names(final_data) == "bathrooms_3 shared baths"] <- "bt_3_shared_baths"
names(final_data)[names(final_data) == "bathrooms_3 baths"] <- "bt_3_baths"
names(final_data)[names(final_data) == "bathrooms_3.5 baths"] <- "bt_3_5_baths"
names(final_data)[names(final_data) == "bathrooms_3.5 shared baths"] <- "bt_3_5_shared_baths"

names(final_data)[names(final_data) == "bathrooms_4 baths"] <- "bt_4_bath"
names(final_data)[names(final_data) == "bathrooms_4.5 baths"] <- "bt_4_5_baths"
names(final_data)[names(final_data) == "bathrooms_4.5 shared baths"] <- "bt_4_5_shared_baths"

names(final_data)[names(final_data) == "bathrooms_5 baths"] <- "bt5_baths"




# Assuming your data frame is named 'df'
column_names <- colnames(final_data)

# Print the list of column names
print(column_names)
cat("Column Names:", paste(column_names, collapse = ", "))


str(final_data)



#library(dplyr)
#final_data <- final_data %>% select(-bathrooms_4_5_baths)

sapply(final_data, function(x){sum(is.na(x))})
sum(is.na(final_data))

# Create data partition:
set.seed(123)  # Set a seed for reproducibility
index = sample(nrow(final_data),0.7*nrow(final_data)) 

train_data = final_data[index, ]
test_data = final_data[-index, ]

#Check for columns/variables with missing values
sapply(train_data, function(x){sum(is.na(x))})
sapply(test_data, function(x){sum(is.na(x))})
#summary(final_data)


sapply(train_data, function(x){sum(is.na(x))})
sum(is.na(train_data))

sapply(test_data, function(x){sum(is.na(x))})
sum(is.na(test_data))

#> sum(is.na(train_data))
#[1] 375

#> sum(is.na(test_data))
#[1] 153

#replace missing vals with mode
# NOTE: We always split the data before any imputation or scaling.
# Then, since we're pretending 'test' (i.e., validation) to the be an unseen dataset, 
# we will use information from train data to impute the test dataset!


#Variables with Missing Values
VariablesNA <- which(sapply(train_data, anyNA)) %>% names()
cat(VariablesNA, sep = ", ")


train_data[is.na(train_data$host_acceptance_rate),'host_acceptance_rate'] = mfv(train_data$host_acceptance_rate,na_rm=TRUE) 
test_data[is.na(test_data$host_acceptance_rate),'host_acceptance_rate'] = mfv(train_data$host_acceptance_rate,na_rm=TRUE) #mode of host_acceptance_rate in train dataset!

train_data[is.na(train_data$bedrooms),'bedrooms'] = mfv(train_data$bedrooms,na_rm=TRUE) 
test_data[is.na(test_data$bedrooms),'bedrooms'] = mfv(train_data$bedrooms,na_rm=TRUE) #mode of bedrooms in train dataset!

train_data[is.na(train_data$rt_Entire_home_apt),'rt_Entire_home_apt'] = mfv(train_data$rt_Entire_home_apt,na_rm=TRUE) 
test_data[is.na(test_data$rt_Entire_home_apt),'rt_Entire_home_apt'] = mfv(train_data$rt_Entire_home_apt,na_rm=TRUE) #mode of rt_Entire_home_apt in train dataset!

train_data[is.na(train_data$rt_Private),'rt_Private'] = mfv(train_data$rt_Private,na_rm=TRUE) 
test_data[is.na(test_data$rt_Private),'rt_Private'] = mfv(train_data$rt_Private,na_rm=TRUE) #mode of rt_Private in train dataset!

train_data[is.na(train_data$rt_Shared),'rt_Shared'] = mfv(train_data$rt_Shared,na_rm=TRUE) 
test_data[is.na(test_data$rt_Shared),'rt_Shared'] = mfv(train_data$rt_Shared,na_rm=TRUE) #mode of rt_Shared in train dataset!


sapply(train_data, function(x){sum(is.na(x))})
sum(is.na(train_data))
###261 missing values

#Scale the variables
#preProcess function from "caret" package, using "range" (min-max normalization) method
#Again, we are using train information to scale test data!
#NOTE: Predictors that are not numeric are ignored in the calculations of preProcess function
scale_vals = preProcess(train_data, method="range")
train_data_s = predict(scale_vals, train_data)
test_data_s = predict(scale_vals, test_data)


#Model 1:
NN1 = neuralnet(price ~.,
                data=train_data_s,
                linear.output = TRUE, #TRUE bc it is regression, not classification.
                stepmax = 1e+06,
                act.fct = relu,
                hidden=3) #one layer with 3 neurons

#The output model:
NN1

#predicted values for test data (these will be between 0 and 1)
pred1 = predict(NN1, test_data_s)

#Scaling back predicted values to the actual scale of price
pred1_acts = pred1*(max(train_data$price)-min(train_data$price))+min(train_data$price)

#Model 1:
NN1a = neuralnet(price ~.,
                 data=train_data_s,
                 linear.output = TRUE, #TRUE bc it is regression, not classification.
                 stepmax = 1e+06,
                 act.fct = tanh, 
                 hidden=3) #one layer with 3 neurons

#The output model:
NN1a

#predicted values for test data (these will be between 0 and 1)
pred1a = predict(NN1a, test_data_s)

#Scaling back predicted values to the actual scale of price
pred1a_acts = pred1a*(max(train_data$price)-min(train_data$price))+min(train_data$price)

############# Training the second model using caret and nnet #############

#Model 2
ctrl = trainControl(method="cv",number=10)
myGrid = expand.grid(size = seq(1,10,1),
                     decay = seq(0.01,0.2,0.04))

set.seed(123)
NN2 = train(
  price ~ ., data = train_data_s,
  linout = TRUE,
  method = "nnet", 
  tuneGrid = myGrid,
  trControl = ctrl,
  trace=FALSE)

#The output model:
NN2

#predicted values for test data (these will be between 0 and 1)
pred2 = predict(NN2, test_data_s)

#Scaling back predicted values to the actual scale of price
pred2_acts = pred2*(max(train_data$price)-min(train_data$price))+min(train_data$price)


#Model 2a
ctrl2a = trainControl(method="cv",number=10)   
#myGrid2a = expand.grid(size = seq(1,10,1),
#                     decay = seq(0.01,0.2,0.04))

myGrid2a <- expand.grid(decay = c(0, 0.01, .1), 
                        size = c(1, 3, 5, 7, 9, 11, 13), 
                        bag = FALSE)

set.seed(123)
NN2a = train(
  price ~ ., data = train_data_s,
  linout = TRUE,
  method = "avNNet",  #Aggregate several neural network models
  tuneGrid = myGrid2a,
  trControl = ctrl2a,
  trace=FALSE)

#The output model:
NN2a

#predicted values for test data (these will be between 0 and 1)
pred2a = predict(NN2a, test_data_s)

#Scaling back predicted values to the actual scale of price
pred2a_acts = pred2a*(max(train_data$price)-min(train_data$price))+min(train_data$price)

############# Training the second model using caret and avNNET #############
#For regression, the output from each network are averaged.
#avNNet is a model where the same neural network model is fit using different random number seeds.
#All the resulting models are used for prediction. For regression, the output from each network are averaged. 
#bag=true

#Model 2b
ctrl2b = trainControl(method="cv",number=10)   
#myGrid2a = expand.grid(size = seq(1,10,1),
#                     decay = seq(0.01,0.2,0.04))

myGrid2b <- expand.grid(decay = c(0, 0.01, .1), 
                        size = c(1, 3, 5, 7, 9, 11, 13), 
                        bag = TRUE)

set.seed(123)
NN2b = train(
  price ~ ., data = train_data_s,
  linout = TRUE,
  method = "avNNet",  #Aggregate several neural network models
  tuneGrid = myGrid2b,
  trControl = ctrl2b,
  trace=FALSE)

#The output model:
NN2b

#predicted values for test data (these will be between 0 and 1)
pred2b = predict(NN2b, test_data_s)

#Scaling back predicted values to the actual scale of price
pred2b_acts = pred2b*(max(train_data$price)-min(train_data$price))+min(train_data$price)

############# Plot predicted values vs. actual value #############

plot(test_data$price,pred1_acts, xlab="Price",ylab="Predicted Price",main="Model 1")
plot(test_data$price,pred1a_acts, xlab="Price",ylab="Predicted Price",main="Model 1a")

plot(test_data$price,pred2_acts,xlab="Price",ylab="Predicted Price",main="Model 2")
plot(test_data$price,pred2a_acts,xlab="Price",ylab="Predicted Price",main="Model 2a")
plot(test_data$price,pred2b_acts,xlab="Price",ylab="Predicted Price",main="Model 2b")

############# Comparing the models #############

#Models comparison
postResample(pred1_acts,test_data$price) #Model 1
postResample(pred1a_acts,test_data$price) #Model 1a

postResample(pred2_acts,test_data$price) #Model 2
postResample(pred2a_acts,test_data$price) #Model 2a

postResample(pred2b_acts,test_data$price) #Model 2b
