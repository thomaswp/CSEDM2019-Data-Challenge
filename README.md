# The CSEDM 2019 Data Challenge

As part of the 2nd [Educational Data Mining in Computer Science Education](https://sites.google.com/asu.edu/csedm-ws-lak-2019/) (CSEDM) Workshop at [LAK 2019](https://lak19.solaresearch.org), we are releasing a **Data Challenge**. The goal of this challenge is to bring researchers together to tackle a common data mining task that is specific to CS Education. This year, we are focusing on the task of modeling students' programming knowledge in order to predict their performance on future tasks.
The rest of this document contains a summary of the task itself and documentation of the dataset used in the challenge.

For the most up-to-date version of this README, please see the version [hosted on GitHub](https://github.com/thomaswp/CSEDM2019-Data-Challenge).

For the most up-to-date information on the challenge and the workshop, see the workshop's [call for papers](https://sites.google.com/asu.edu/csedm-ws-lak-2019/call-for-papers).

For any questions on the Data Challenge, please contact Thomas Price at twprice@ncsu.edu.


## Accessing the Data

The dataset used in the challenge is hosted on the [PSLC Datashop](https://pslcdatashop.web.cmu.edu) at: https://pslcdatashop.web.cmu.edu/Files?datasetId=2865.

To access the data, you must create an account, and then send your account username to Thomas Price at twprice@ncsu.edu. 

We **strongly recommend** signing up for the [CSEDM data challenge email list here]([https://goo.gl/forms/8atiAOek8nJHtBSo2]). This will enable us to contact you if there are known issues or updates to the data.


## Submissions

Submissions to the contest should include the following files:

1) A 2-6 page short paper detailing the methods used to make the predictions.
2) All code used to make the predictions, including a README file explaining how to run the code, using the challenge dataset. If it is not possible to provide a runnable version of the code (e.g. because it has closed-source dependencies), please include as much code as possible, and explain the missing parts in the README.
3) For each classifier (or variant) that you evaluated, include the 3 output files, cv_predict, evaluation_by_problem, and evaluation_overall, as explained in the Example section above. These files should respectively contain the actual predictions made by the classifier, the evaluation metrics for each problem, and the evaluation metrics for the classifier overall.

Submissions can be made on the [CSEDM Easychair page](https://easychair.org/conferences/?conf=csedm2019).

Please see the CSEDM 2019 [call for papers](https://sites.google.com/asu.edu/csedm-ws-lak-2019/call-for-papers) for up-to-date information on submission deadlines.


## Challenge Summary

The goal of this Data Challenge is to use previous students' programming process data to predict whether future students will succeed at a given programming task. This is a central challenge of student modeling, often called Knowledge Tracing [1]. Such a predictive model can be used to enable Mastery Learning [2], to make adaptive or feedback that targets struggling students [3], or to encourage students through an open learner model [4]. You will be given a dataset containing records of students' attempts a set of programming problems, including whether each attempt was correct or incorrect, and the code submitted. Your task is to build a model that can predict, given a student's performance up until a given problem, whether or not that student will succeed at their first attempt at that problem. While similar knowledge tracing tasks have been attempted in many domains (including programming), they usually rely on labels for each problem, identifying which Knowledge Componentss (KCs), or domain concepts, are required by that problem (e.g. in [5]). The goal of this Data Challenge is to leverage CS-specific aspects of the data, namely the source code, to build a model without these KC labels, as was attempted in [6-7]. For example, one approach is to automatically extract concepts from code (e.g. "loop", "conditional") to use in a model of student knowledge, as in [7-9].


## Evaluation

Each classifier submitted to the Data Challenge should be evaluated based on its ability to predict students' success on their first attempt at a given problem, given their history of performance on previous problems. Participants are responsible for evaluating their classifier, but we may verify results. Participants should evaluate classifier performance on 19 problems (detailed below) separately, as well as overall performance for all problems. Performance should be measured using the standard metrics of Precision, Recall, F1 score and Cohen's kappa (measuring "agreement" between the classifier and the ground truth).

The challenge only includes predictions for the first 19 problems, for which at least 20 students made attempts at the problem. These problems, in order of most attempts are:

1) helloWorld
2) doubleX
3) raiseToPower
4) convertToDegrees
5) leftoverCandy
6) intToFloat
7) findRoot
8) howManyEggCartons
9) kthDigit
10) nearestBusStop
11) hasTwoDigits
12) overNineThousand
13) canDrinkAlcohol
14) isPunctuation
15) oneToN
16) backwardsCombine
17) isEvenPositiveInt
18) firstAndLast
19) singlePigLatin

Evaluation metrics should be calculated using [10-fold cross validation](https://en.wikipedia.org/wiki/Cross-validation_(statistics)#k-fold_cross-validation). To ensure consistent evaluation, we have preselected the 10 folds, split by student. They can be found under the CV folder, where each fold is defined by a training dataset (consisting of 90% of the data) and a test dataset (consisting of the remaining 10%). Evaluation metrics (precision, recall, etc.) should be calculated across all 10 test datasets, which collectively include all students. They should be caculated both per-problem and across all predictions. See the Example section for how evaluation metrics should be calcuated and how crossvalidation can be performed.

## The Data

The dataset used in the challenge comes from a study of novice Python programmers working with the ITAP intelligent tutoring system [10]. For more information on the original experiment, see [7]. There are 89 total students represented, and they worked on 38 problems over time. The study lasted over 7 weeks. The students could attempt the problems in any order, though there was a default order. Students could attempt the problem any number of times, receiving feedback from test cases each time, and they could also request hints from ITAP (though access was limited for students, depending on the week and their experimental condition). The dataset itself contains a record for each attempt and hint request that students made while working.

The original data is available at the PSLC Datashop
[11] [here](https://pslcdatashop.web.cmu.edu/DatasetInfo?datasetId=1798). The data used for the challenge has been processed to make it easier to work with. The data is organized using the ProgSnap 2 format for programming process data [12], with some additional files included specifically for this challenge.

The dataset is organized as follows:

```
DataChallenge
    DatasetMetadata.csv
    MainTable.csv
    CodeStates/
        CodeState.csv
    Predict.csv
    CV/
        Fold0
            Test.csv
            Training.csv
        Fold1
        ...
        Fold9
    Example/
```

**DatasetMetadata.csv**: Required metadata information for the ProgSnap 2 format.

**MainTable.csv**: Contains all programming process data. Each row of the table represents an event: one attempt or hint request, made by one student on a given problem. The following columns are defined for each row:
* EventType: Either `Submit` if this was a submission or `X-HintRequest` if the student requested a hint.
* EventID: A Unique ID for this event.
* Order: An integer indicating the chronological order of this event, relative to each other event in the table. This is necessary to order events that occurred at the same timestamp.
* SubjectID: A unique ID for each participant in the study.
* ToolInstances: The tutoring system and programming language being used. In this case, it is always ITAP and Python.
* CodeStateID: An ID for the students code at the time of the event. This corresponds to one row in the CodeStates/CodeState.csv file, which contains the text of the code.
* ServerTime: The time of the event.
* ProblemID: An ID for the problem being worked on by the student.
* Correct: Whether the student's  code was correct at this time according to the test cases.

**CodeStates/CodeState.csv**: This file contains a mapping from each CodeStateID in the MainTable to the source code it represents.

**Predict.csv**: While the MainTable.csv table includes *all* events in the dataset, the Predict.csv table includes one row for each prediction to be made. Specifically, there is one row for each problem/student pair. The goal of the challenge is to predict, at each new problem, whether a given student will succeed on the *first attempt* at the problem, which is defined as getting it correct without requesting a hint. There are a number of additional outcomes we may wish to predict as well, such as home *many* attempts the student will take, whether they will ever get it correct and whether they will request a hint. Therefore each row of the table includes the following columns:
* SubjectID: An ID for the student attempting the problem.
* ProblemID: An ID for the problem being attempted.
* StartOrder: The first "Order" value in the MainTable corresponding to the student's attempt at this problem. When making a prediction, an algorithm may use any history and information from the student *up until* the event row with this Order value. For example, if this value is 1354, the algorithm can base its prediction on the student's performance on problems on *previous* problems, with Order values < 1354.
* FirstCorrect: Whether the student got this problem correct on their first attempt. This is the primary value to be predicted in this challenge.
* EverCorrect: Whether the student ever got this problem correct.
* UsedHint: Whether the student used a hint on this problem.
* Attempts: The total number of attempts the student made at this problem.

*Note*: The Predict.csv file only contains rows for the 19 problems being evaluated in the challenge, but there are more problems included in the Main Event Table. These may still be useful for determining, for example, how well a student performs overall.

**CV/FoldX/[Training|Test].csv**: The CV (CrossValidation) folder contains 10 "FoldX" subfolders, for X = 1..10. In each folder is a Training.csv and Test.csv file. The two files represent a division of the Predict.csv file, split into a training and test set for the given fold of crossvalidation. See the Evaluation section for more on how to evaluate your classifier using 10-fold crossvalidation.

**Example/**: A folder containing an example classifier, written in R, along with crossvalidation code. See the Example section below for more details


## An Example

The Example folder contains an example classifier, written in R, along with code for performing crossvalidation and calculating the evaluation metrics.

In this simple example classifier, we use only the data from the Predict table, without using any of the information in the MainEvents table or the students' code snapshots. The classifier contains two main pieces of logic. The first, found in the `addAttributes` function, iterates through the rows in given subset of the Predict table and calculates cumulative attributes for each student, such as their `priorPercentCorrect` for each problem - the percent of problems *before* this one that the student has gotten correct. We only use data about a student's performance on *previous* problems, since this is the only information that will be available at the time of the prediction.

> **Note**: If you plan to use the MainEvents table to calculate other attriutes, you can use the `StartOrder` column in the Predict table, which indicates the `Order` value in the MainEvents table when the prediciton should occur. Any prediction should be based only on events that occur stricly before this in the MainEvents table (`Order < StartOrder`).

Once the `addAttributes` function calculates the cumulative statistics for each student's attempt at each problem, the second piece of logic, found in the `buildModel` function, builds a simple logistic regression model to predict whether the student will get that attempt correct on their first try (`FirstCorrect`), using these attributes (this is an intentionally simple model, meant only for demmonstration). The `makePredictions` function builds a model for a given training dataset and then makes predictions for the given test dataset. Note that this funciton calculates the same cumulative attributes for the test dataset, so the model can use them in prediction.

> **Note**: We could also predict other attributes of the student's attempt, such as whether they used a hint `UsedHint`, how many attempts they made `Attempts` or whether they ever got it right `EverCorrect`, but the Data Challenge centers on the `FirstCorrect` variable.

The `crossValidate` function demonstrates how to load the various training and tests datasets from the `CV` folder to perform crossvalidation. Finally the `evaluatePerformace` function calculates performance metrics for the classifier, including the percentage of true positives (`tp`), true negatives (`tn`), false positives (`fp`) and false negatives (`fn`), the accuracy, precision, recall, F1 score (`f1`) and Cohen's kappa (`kappa`).

The code produces the following files:

1) **cv_predict.csv**: Contains predictions for each problem attempt (in the `prediction` columns) for whether the student will get the problem right on the first attempt, based on the 10-fold crossvalidation training/test splits in the CV folder.
2) **evaluation_by_problem.csv**: Evaluation metrics for the classifier, split by problem, including precision, recall, F1-score and Cohen's kappa.
3) **evaluation_overall.csv**: Evaluation metrics for the classifier over all problem attempts.

We have also included a model.txt file with the logistic regression model, showing that both the average difficulty of the problem itself, and a given student's prior percent of correct first attempts are significantly predictive of students' success on future problems. Of course, this model does not consider any information about the programming concepts in each problem, so it serves as a naive baseline against which to compare more interesting models.


## Caveats

A few important notes for the dataset:
* Remember that the problems can be completed in any order
* Each attempt is assigned correctness based on whether it passes a set of unit tests withing 0.5 seconds. Note that the original dataset on PSLC did not contain accurate information on whether each attempt was correct, and these values have been generated post hoc. The "Correct" value may therefore not align perfectly with the feedback the student actually received.
* Three problems do not have "Correct" values: `treasureHunt`, `mostAnagrams` and `findTheCircle`. These problems had few attempts and occurred after the problems for which predictions are being evaluated.


## References

[1] A. T. Corbett and J. R. Anderson, “Knowledge tracing: Modeling the acquisition of procedural knowledge,” User Model. User-adapt. Interact., vol. 4, no. 4, pp. 253–278, 1994.

[2] A. Corbett and J. Anderson, “Student modeling and mastery learning in a computer-based programming tutor,” in Proceedings of the International Conference on Intelligent Tutoring Systems, 1992, pp. 413–420.

[3] V. K. Murray R.C., “A comparison of decision-theoretic, fixed-policy and random tutorial action selection,” Lect. Notes Comput. Sci. (including Subser. Lect. Notes Artif. Intell. Lect. Notes Bioinformatics), vol. 4053 LNCS, pp. 114–123, 2006.

[4] P. Brusilovsky, S. Somyurek, J. Guerra, R. Hosseini, V. Zadorozhny, and P. J. Durlach, “Open Social Student Modeling for Personalized Learning,” IEEE Trans. Emerg. Top. Comput., vol. 4, no. 3, pp. 450–461, 2016.

[5] J. Kasurinen and U. Nikula, “Estimating programming knowledge with Bayesian knowledge tracing,” in ACM SIGCSE Bulletin, 2009, vol. 41, no. 3, pp. 313–317.

[6] M. Yudelson, R. Hosseini, A. Vihavainen, and P. Brusilovsky, “Investigating Automated Student Modeling in a Java MOOC,” in Proceedings of the International Conference on Educational Data Mining, 2014, pp. 261–264.

[7] K. Rivers, E. Harpstead, and K. Koedinger, “Learning Curve Analysis for Programming: Which Concepts do Students Struggle With?,” in Proceedings of the International Computing Education Research Conference, 2016, pp. 143–151.

[8] M. Berges and P. Hubwieser, “Evaluation of Source Code with Item Response Theory,” in Proceedings of the 2015 ACM Conference on Innovation and Technology in Computer Science Education, 2015, pp. 51–56.

[9] R. Hosseini and P. Brusilovsky, “JavaParser: A fine-grain concept indexing tool for java problems,” CEUR Workshop Proc., vol. 1009, pp. 60–63, 2013.

[10] K. Rivers and K. R. Koedinger, “Data-Driven Hint Generation in Vast Solution Spaces: a Self-Improving Python Programming Tutor,” Int. J. Artif. Intell. Educ., vol. 27, no. 1, pp. 37–64, 2017.

[11] K. R. Koedinger, R. S. J. Baker, K. Cunningham, and A. Skogsholm, “A Data Repository for the EDM community: The PSLC DataShop,” in Handbook of Educational Data Mining, C. Romero, S. Ventura, M. Pechenizkiy, and R. Sj. Baker, Eds. CRC Press, 2010, pp. 43–55.
