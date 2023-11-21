###APPENDIX CASE STUDY 2 ###

setwd("C:/Users/betyv/Desktop/doc/Fall 2021/Statistical Learning/Case Studies/Case Study 2")
load("CaseStudy2.RData")


dim(train)
dim(valid)

View(train)

##Step 2: Do information value.
library(Information)
IV <- create_infotables(data=train, y="PURCHASE", ncore=2)
View(IV$Summary)
train_new <- train[,c(subset(IV$Summary, IV>0.05)$Variable, "PURCHASE")]
dim(train)
valid_new <- valid[,c(subset(IV$Summary, IV>0.05)$Variable, "PURCHASE")]
dim(valid)

##Step 3: Eliminating highly correlated variables using variable clustering 
######## Variable clustering
install.packages("ClustOfVar")
install.packages("reshape2")
install.packages("plyr")
library(ClustOfVar)
library(reshape2)
library(plyr)
tree <- hclustvar(train_new [,!(names(train_new)=="PURCHASE")])
nvars <- 20
part_init<-cutreevar(tree,nvars)$cluster
kmeans<-
  kmeansvar(X.quanti=train_new[,!(names(train_new)=="PURCHASE")],init=part_init)
clusters <- cbind.data.frame(melt(kmeans$cluster), row.names(melt(kmeans$cluster)))
names(clusters) <- c("Cluster", "Variable")
clusters <- join(clusters, IV$Summary, by="Variable", type="left")
clusters <- clusters[order(clusters$Cluster),]
clusters$Rank <- ave(-clusters$IV, clusters$Cluster, FUN=rank)
View(clusters)
variables <- as.character(subset(clusters, Rank==1)$Variable)
variables

###Adding NEWPurchase variable to train, trian_new, valid, and valid_new 

#Check is train$PURCHASE is a factor
str(train$PURCHASE)
#Creating new variable in train 
train$NEWPurchase <- as.factor(ifelse(train$PURCHASE=="1", 1, -1))

#Creating new variable in valid
valid$NEWPurchase <- as.factor(ifelse(valid$PURCHASE=="1", 1, -1))

#Creating new variable in train_new
train_new$NEWPurchase <- as.factor(ifelse(train_new$PURCHASE=="1", 1, -1))
View(train_new)
#Removing train$PURCHASE from train_new using dplyr
install.packages(dplyr)
library(dplyr)
train_new1 <- select(train_new, -(34))
View(train_new1)

#Creating new variable in valid_new
valid_new$NEWPurchase <- as.factor(ifelse(valid_new$PURCHASE=="1", 1, -1))
#Removing valid$PURCHASE from valid_new using dplyr
View(valid_new)
valid_new1 <- select(valid_new, -(34))
View(valid_new1)

##DATASETS FROM VARIABLE CLUSTERING 
train_new1.2 <- select(train_new1, -c(7, 11,  15, 18:19, 22:23, 25, 27, 29, 31:33))
View(train_new1.2)

valid_new1.2 <- select(valid_new1, -c(7, 11,  15, 18:19, 22:23, 25, 27, 29, 31:33))
View(valid_new1.2)


##RANDOM FOREST# 
#Notes... try obb.err for mtry values 

library(randomForest)
set.seed(1551)

#Building an array to store the errors 
oob.err=double(13)
#Run random forest with mtry values 1 through 13 to get OOB error. 
for(mtry in 1:13){
  fit=randomForest(NEWPurchase~., data=train_new1.2, mtry=mtry, importance=TRUE, ntree=10001)
  oob.err[mtry]=fit$err.rate[10001,1]
}
#List of OOBs for mtry 1 - 13
oob.err
#getting tree with lowest OOB to retrain later. 
fitbest=which.min(oob.err)
fitbest
#retraining Random Forest from previous step (RF 8 in my case) / make sure to use same setseed value as before
bestRF=randomForest(NEWPurchase~., data=train_new1.2, mtry=fitbest, importance=TRUE, ntree=10001)
#Check how to get error rate and check specificity and sensitivity
bestRF$err.rate[10001,]
#check specificity and sensitivity directly
bestRF$confusion
#Using best model to do a variable importance plot 
varImpPlot(bestRF)
#Making predictions 
RF.pred = predict(bestRF, newdata=valid_new1)
RF.pred[1:5]
#Confusion Matrix 
library(caret)
pRF <-confusionMatrix(RF.pred, valid_new1$NEWPurchase)
pRF
#Reading the Accuracy 
pRF$overall[1]

#Create the ROC curve and evaluate the AUC value.
library(pROC)
# predict test set
predictions <- as.data.frame(predict(bestRF,data=valid_new1,type = "Prob"))
predictions$predict <- names(predictions)[1:2][apply(predictions[,1:2],1, which.max)]
predictions$observed <- valid_new1$NEWPurchase
head(predictions)
rf.ROC <- roc(ifelse(predictions$observed=="1", "1", "-1"),
              as.numeric(predictions$'1'), grid=T, plot=T,
              print.auc =T, col ="red")
rf.ROC

##SUPPORT VECTOR MACHINES 
library(e1071)
?svm
#SVM wt Polynomial Kernel 
svm.poly <- svm(NEWPurchase ~., data=train_new1[,c("NEWPurchase",variables)], cost=0.01, kernel="polynomial", degree=3, probability=TRUE)
svm.poly
#predictions
svm.pred <- predict(svm.poly, newdata=valid_new1, probability=TRUE)
#Confusion Matrix 
pSVM.poly <-confusionMatrix(svm.pred, valid_new1$NEWPurchase)
pSVM.poly

#ROC and AUC
poly.predictions<- predict(svm.poly, valid_new1, decision.values = TRUE, probability = TRUE)
View(poly.predictions)
attr(poly.predictions, "probabilities")[1:4,]
poly.predictionsframe<-as.data.frame(attr(poly.predictions, "probabilities"))
View(poly.predictionsframe)
poly.prob<-as.numeric(poly.predictionsframe[,1])
poly.ROC<- roc(as.numeric(as.character(valid_new1$NEWPurchase)),poly.prob, grid=T,plot=T, print.auc =T, col ="red")
levels(poly.prob)
levels(valid_new1$NEWPurchase)

#SVM wt Gaussian Radial Kernel 
#checking if predictor is a factor to make sure it doesn't do support vector regression 
is.factor(valid_new1.2$NEWPurchase)
#SVM
svm.radial <- svm(NEWPurchase ~., data = train_new1[,c("NEWPurchase",variables)], kernel = "radial", cost = 0.01, gamma = 0.000001, probability = TRUE)
#predictions 
svmg.pred <- predict(svm.radial, newdata=valid_new1, probability=TRUE)
#Confusion Matrix 
pSVM.gauss <-confusionMatrix(svmg.pred, valid_new1$NEWPurchase)
pSVM.gauss
#Checking number of support vectors 
print(svm.radial)
#Check levels anf SVM in each level 
summary(svm.radial)
#not working // not cat variables , need to specify the predictor that we want to draw 
plot(svm.radial, train_new1.2$NEWPurchase)
#check were are the SVMS
svm.radial$index

#ROC and AUC
gauss.predictions<- predict(svm.radial, valid_new1, decision.values = TRUE, probability = TRUE)
View(gauss.predictions)
attr(gauss.predictions, "probabilities")[1:4,]
gauss.predictionsframe<-as.data.frame(attr(gauss.predictions, "probabilities"))
View(gauss.predictionsframe)
gauss.prob<-as.numeric(gauss.predictionsframe[,1])
gauss.ROC<- roc(as.numeric(as.character(valid_new1$NEWPurchase)),gauss.prob, grid=T,plot=T, print.auc =T, col ="red")
levels(gauss.prob)
levels(valid_new1$NEWPurchase)

