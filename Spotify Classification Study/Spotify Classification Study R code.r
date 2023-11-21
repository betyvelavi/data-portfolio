#APPENDIX: R-CODE

#For this data set we want to program a model that classifies music_genre

setwd('C:/Users/betyv/Desktop/doc/Fall 2021/Statistical Learning/Final Project')
music <- read.csv('music_genre.csv')
head(music)
View(music)
str(music)


#EXPLORING AND PREPARING THE DATA SET

#Pie Chart of music genre (all music_genre classes have 5k obs)
par(mfrow = c(1,1))
piemusicg <- table(music$music_genre)
lbls <- paste(names(piemusicg), "\n", piemusicg, sep="")
pie(piemusicg, labels = lbls,
    main = "Pie Chart of Music Genre")

#checking for NAs in dataset
summary(music)

#from summary, need to remove rows 10,001 - 10,005 due to NAs 
which(is.na(music$instance_id))
music <- music[-c(10001:10005), ]

#checking classes
sapply(music, class)

#to see the different values in character variables
unique(music$music_genre) #10 different classes 
unique(music$key) #12 different keys 
unique(music$mode) #only minor and major

#changing tempo to numeric
music$tempo <- as.numeric(as.character(music$tempo))
#checking that it was changed to numeric
sapply(music, class)
#replacing NAs in tempo with the mean 
sum(is.na(music$tempo))
music$tempo[is.na(music$tempo)] <- mean(music$tempo, na.rm = TRUE)
music$tempo

#recoding mode to dummy variables
music$mode <- as.numeric(ifelse(music$mode=="Major", 1, 0))
#recoding key to factor 
music$key <- as.factor(music$key)
str(music$key)
#recoding response to factor 
music$music_genre <- as.factor(music$music_genre)

#removing character predictors for study 
library(dplyr)
music1 <- select(music, -c(1:4, 7, 16))
View(music1)
str(music1)

#Checking if data is normaly distributed using Shapiro-Wilk Test 
shapiro.test(music_norm$acousticness[0:5000]) #cannot conduct, dataset >5000

#Checking if data is normally distributed using Anderson-Darling test 
library(nortest)
ad.test(music$acousticness)
ad.test(music$danceability)
ad.test(music$energy)
ad.test(music$instrumentalness)
ad.test(music$liveness)
ad.test(music$loudness)
ad.test(music$speechiness)
ad.test(music$tempo)
ad.test(music_norm$valence)

#data failed normality so normalizing the data I guess 
normalize <- function(x)(
  return ((x - min(x)) / (max(x) - min(x))))

#apply normalization to columns 1-4, 6-11
music_norm <- as.data.frame(lapply(music1[,c(1:4, 6:11)], normalize))
View(music_norm)
summary(music_norm)

#adding key and music_genre to normalized data set 
music_norm$key <- music1$key
music_norm$music_genre <- music1$music_genre

#Normality visualization 
library(ggpubr)
par(mfrow = c(3,3))
ggdensity(music_norm$acousticness, 
          main = "Density plot of acousticness",
          xlab = "Acousticness")
ggdensity(music1$danceability, 
          main = "Density plot of danceability",
          xlab = "Danceability")
ggdensity(music_norm$danceability, 
          main = "Density plot of danceability",
          xlab = "Danceability")
ggdensity(music$acousticness, 
          main = "Density plot of acousticness",
          xlab = "Acousticness")

#DATA PARTITION 
library(caret)
# Create index to split based on labels  
index <- createDataPartition(music_norm$music_genre, p=0.6, list=FALSE)
# Subset training set with index
training <- music_norm[index,]
# Subset test set with index
testing <- music_norm[-index,]

#k-NN
#k-NN does not need normally distributed data 
library(class)
ktraining <- training[,c(1:10)]
ktesting <- testing[,c(1:10)]
kpredict <- training$music_genre

#building array to store accuracy values for diff k 
acc.knn <-c()
#KNN with different k-values (1-50)
for (i in 1:50){
  set.seed(1)
  testing_pred <- knn(ktraining, ktesting, kpredict, k=i)
  cm <- confusionMatrix(testing_pred, testing$music_genre)
  acc.knn[i] <- cm$overall[1]
  }
#list of accuracy for k values 
acc.knn
#getting best k 
k.best=which.max(acc.knn)
k.best
#running knn with best accuracy
set.seed(1)
knn.best <- knn(ktraining, ktesting, kpredict, k=k.best)
cm.best <- confusionMatrix(knn.best, testing$music_genre)
cm.best
#getting sensitivity and specificity by class 
cm.best$byClass[1:10,1:2]
#plotting different accuracy values 
plot(acc.knn, main ='Accuracy of k-values (1-50)',
     ylab = 'Accuracy', xlab = 'k-values')

#adding the row of Alternative in confusionMatrix (prediction)
some_sum <- sum(cm.best$table[1,1:10])
some_sum
#adding the column of Alternative in confusionMatrix (Reference)
sum(cm.best$table[1:10,1])

#One vs. all approach exploration on CM
#Genre: Alternative
#True Negatives: all non-Alt instances that are not classified as Alt (everything expect for the column of Alt)
Alt_TN <- sum(cm.best$table[1:10,2:10])
Alt_TN
#False Positive: all non-Alt instances that were classified as Alt (row of Alt except for the TP)
Alt_FP <- sum(cm.best$table[1,2:10])
Alt_FP
#False Negative: all Alt instances that are not classified as Alt (column of Alt except for TP)
Alt_FN <- sum(cm.best$table[2:10,1])
Alt_FN
#Sensitivity(TP rate): those that are Alt and were classified as Alt (TP/TP+FN)
Alt_Sens <- (cm.best$table[1,1])/((cm.best$table[1,1])+Alt_FN)
Alt_Sens
#Specificity(TN rate): those that are not Alt and were not classified as Alt (TN/TN+FP)
Alt_Sped <- Alt_TN/(Alt_TN+Alt_FP)
Alt_Sped


#Naive Bayes
library(e1071) 
#Bayes setup 
bayes_class <- naiveBayes(music_genre ~., data = training)
bayes_class
#Bayes predictions, type=raw needed for conditional aposterior probs 
bayes_pred <- predict(bayes_class, testing, type='raw')
summary(bayes_pred)
table(testing$music_genre, bayes_pred)
confusionMatrix(bayes_pred, testing$music_genre)

#can't get Bayes CM


#Decision Tree 
library(tree)
#fitting a tree 
tree_class <- tree(music_genre ~., training)
summary(tree_class)
tree_class
#plotting the tree 
plot(tree_class, main='Music Genre Decision Tree')
text(tree_class, pretty=0)
#Tree Predicton, confusion matrix, and test error rate 
pred_tree <- predict(tree_class, testing, type = 'class')
tree.cm <- confusionMatrix(pred_tree, testing$music_genre)
tree.cm
#f) cross validation 
set.seed(123)
tree.cv <- cv.tree(tree_class, FUN = prune.misclass)
names(tree.cv)
tree.cv
#g) produce a plot with tree size on x-axis and cross-validated classification error on y-axis
names(tree.cv)
plot(tree.cv$size,tree.cv$dev, type = "b")
#h) which tree has the lowest cross validation error rate? 
#i) Pruned tree
pruned_tree <- prune.misclass(tree_class, best = 6)
summary(pruned_tree)
plot(pruned_tree)
text(pruned_tree, pretty = 0)
#j) Compare training error rates between pruned and unpruned. higher? 
#k) Compare test error rates between pruned and unpruned. Which is higher?
predictions.pruned <- predict(pruned_tree, testing, type = 'class')
confusionMatrix(predictions.pruned, testing$music_genre)

#Best tree was the tree before cross validation 
#getting sensitivity and specificity by class 
tree.cm$byClass[1:10,1:2]

#Random Forest
library(randomForest)
set.seed(1)

#Building an array to store the errors 
oob.err=double(11)
#Run random forest with mtry values 1 through 11 to get OOB error. 
for(mtry in 1:11){
  fit=randomForest(music_genre~., data=training, mtry=mtry, importance=TRUE, ntree=1000)
  oob.err[mtry]=fit$err.rate[1000,1]
}
#List of OOBs for mtry 1 - 11
oob.err
#getting tree with lowest OOB to retrain later. 
fitbest=which.min(oob.err)
fitbest
#retraining Random Forest from previous step (RF 8 in my case) / make sure to use same setseed value as before
bestRF=randomForest(music_genre~., data=training, mtry=fitbest, importance=TRUE, ntree=1000)
#Check how to get error rate and check specificity and sensitivity
bestRF$err.rate[1000,]
#check specificity and sensitivity directly
bestRF$confusion
#Using best model to do a variable importance plot 
varImpPlot(bestRF)
#Making predictions 
RF.pred = predict(bestRF, newdata=testing)
RF.pred[1:5]
#Confusion Matrix 
library(caret)
pRF <-confusionMatrix(RF.pred, testing$music_genre)
pRF
#Reading the Accuracy 
pRF$overall[1]
#getting sensitivity and specificity by class 
pRF$byClass[1:10,1:2]

#LDA
library(MASS)
lda_fit <- lda(music_genre ~ ., data = training)
lda_fit

#Confusion matrix 
lda_pred <- predict(lda_fit, testing)$class
lda.cm <- confusionMatrix(lda_pred, testing$music_genre)
lda.cm
#getting sensitivity and specificity by class 
lda.cm$byClass[1:10,1:2]


#QDA 
#QDA automatically fits a separate Gaussian model per class. 
library(MASS)
qda_fit <- qda(music_genre ~., data = training)
qda_fit
qda_pred <- predict(qda_fit, testing)$class
qda.cm <- confusionMatrix(qda_pred, testing$music_genre)
qda.cm
#getting sensitivity and specificity by class 
qda.cm$byClass[1:10,1:2]

length(qda_pred)

#Support Vector Machines 
library(e1071)

set.seed(1)
tune_radial <- tune(svm, music_genre ~., data = training, kernel = "radial", ranges = list(cost = c(1,5, 10), 
                                                                                          gamma = c(0.0001, 1, 3)))
summary(tune_radial)
best_radial <- tune_radial$best.model
best_radial

set.seed(1)
svm.radial <- svm(music_genre~., data = training, cost=10, gamma=0.1, kernel="radial")
svm.pred <- predict(svm.radial, newdata=testing)

#Confusion Matrix 
svm.cm <- confusionMatrix(svm.pred, testing$music_genre)
svm.cm
#Checking number of support vectors 
print(svm.radial)
#Check levels anf SVM in each level 
summary(svm.radial)
#not working // not cat variables , need to specify the predictor that we want to draw 
plot(svm.radial, testing$music_genre)
#check were are the SVMS
svm.radial$index
#getting sensitivity and specificity by class 
svm.cm$byClass[1:10,1:2]

svm.poly <- svm(music_genre ~., data=training, cost=10, kernel="polynomial", degree=5)
svm.p.pred <- predict(svm.poly, newdata=testing)
confusionMatrix(svm.p.pred, testing$music_genre)

