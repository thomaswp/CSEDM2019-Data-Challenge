if (!require(plyr)) install.packages("plyr")
library(plyr)

###
# This is a simple example of how to build and evaluate a classifier for the Data Challenge.
# This example does not use any of the data in the MainEvents table, nor does it use students'
# source code to build a more expressive model. The primary purpose is to demonstrate:
# 1) How to extract appropriate attributes from a student's history for a given prediction and
# 2) How to use the provided 10-fold crossvalidation datasets to evaluate a classifier.
###

runMe <- function() {
  # Get all data
  predict <- read.csv("../Predict.csv")
  # Build a model using full dataset for training
  model <- buildModel(predict)
  summary(model)
  
  # Crossvalidate the model
  results <- crossValidate()
  evaluateByProblem <- evaluatePredictions(results, c("ProblemID"))
  evaluateOverall <- evaluatePredictions(results, c())
  
  # Write the results
  write.csv(results, "cv_predict.csv", row.names = F)
  write.csv(evaluateByProblem, "evaluation_by_problem.csv", row.names = F)
  write.csv(evaluateOverall, "evaluation_overall.csv", row.names = F)
}

getProblemStats <- function(data) {
  # Calculate the average success rate on each problem and merge it into the data
  problemStats <- ddply(data, c("ProblemID"), summarize, 
                        pCorrectForProblem=mean(FirstCorrect), medAttemptsForProblem=median(Attempts))
  return (problemStats)
}

# Calculate some additional attributes to use in prediction
addAttributes <- function(data, problemStats) {
  data <- merge(data, problemStats)
  
  # Now we want to calculate the *prior* rate of success/completion for each
  # student before they attempted each problem
  
  # First, order the data by subject and then by chronological order
  data <- data[order(data$SubjectID, data$StartOrder), ]
  
  # Now we declare the columns
  # If we have no other data (e.g. first problem), we default to a 50% success rate
  data$priorPercentCorrect <- 0.5
  # Same with the percent of problems ever completed correctly
  data$priorPercentCompleted <- 0.5
  data$priorAttempts <- 0
  
  lastStudent <- ""
  # Go through each row in the data...
  for (i in 1:nrow(data)) {
    # If this is a new student, reset our counters
    student <- data$SubjectID[i]
    if (student != lastStudent) {
      attempts <- 0
      firstCorrectAttempts <- 0
      completedAttempts <- 0
    }
    lastStudent <- student
    
    data$priorAttempts[i] <- attempts
    # If this isn't their first attempt, calculate their prior percent correct and completed
    if (attempts > 0) {
      # When calculating attributes to use in prediction, make sure
      # to only use information that occurred *before* the event you
      # are predicting. In this case, we only calculate the prior percent
      # correct/completed, and don't include any information from this row
      data$priorPercentCorrect[i] <- firstCorrectAttempts / attempts
      data$priorPercentCompleted[i] <- completedAttempts / attempts
    }
    
    # Now update the number of problems they attempted and got right (on their first try)
    attempts <- attempts + 1
    if (data$FirstCorrect[i]) {
      firstCorrectAttempts <- firstCorrectAttempts + 1
    }
    if (data$EverCorrect[i]) {
      completedAttempts <- completedAttempts + 1
    }
  }
  
  return (data)
}

# Build a simple logistic model with the given training data
buildModel <- function(training) {
  # Add the needed attributes to both datasets
  training <- addAttributes(training, getProblemStats(training))
  
  # Build a simple logistic model
  model <- glm(FirstCorrect ~ pCorrectForProblem + medAttemptsForProblem + 
               priorAttempts + priorPercentCorrect + priorPercentCompleted, 
               data=training, family = "binomial")
  
  return (model)
}

# Build a model with the training data and make predictions for the test data
makePredictions <- function(training, test) {
  model <- buildModel(training)
  # Add attributes to the test dataset, but use the per-problem performance statistics from the test dataset
  # (since we would not actually know these for a real test dataset)
  test <- addAttributes(test, getProblemStats(training))
  test$prediction <- predict(model, test) > 0.5
  return (test)
}

# Load each training/test data split and build a model to evaluate
crossValidate <- function() {
  results <- NULL
  for (fold in 0:9) {
    training <- read.csv(paste0("../CV/Fold", fold, "/Training.csv"))
    test <- read.csv(paste0("../CV/Fold", fold, "/Test.csv"))
    test <- makePredictions(training, test)
    test$fold <- fold
    results <- rbind(results, test)
  }
  results
}

# Evaluate a given set of classifier prediction results using a variety of metrics
evaluatePredictions <- function(results, groupingCols) {
  eval <- ddply(results, groupingCols, summarize,
                pCorrect = mean(FirstCorrect),
                pPredicted = mean(prediction),
                tp = mean(FirstCorrect & prediction),
                tn = mean(!FirstCorrect & !prediction),
                fp = mean(!FirstCorrect & prediction),
                fn = mean(FirstCorrect & !prediction),
                accuracy = tp + tn,
                precision = tp / (tp + fp),
                recall = tp / (tp + fn)
  )
  eval$f1 <- 2 * eval$precision * eval$recall / (eval$precision + eval$recall)
  pe <- eval$pCorrect * eval$pPredicted + (1-eval$pCorrect) * (1-eval$pPredicted)
  eval$kappa <- (eval$accuracy - pe) / (1 - pe)
  return (eval)
}
