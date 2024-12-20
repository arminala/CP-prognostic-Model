Description:
This pipeline includes the CP prognostic model and the Motor Composite Score Model (based on R and Python), designed to predict CP or the Motor Score using Clinical, Structural Connectivity, Functional Connectivity, and Morphometry data.

Dependencies:
 •	RStudio
 •	Python

How to Run:
1.	Ensure that all dependencies are installed.
2.	Place your data file in the specified location.
3.	Use the flowchart in Figure 1 to run the pipeline. When running the pipeline, please consider the following points:
a.	Users must have two levels of expertise to run this pipeline:
i.	Intermediate: To feed the data into the code (Combining data, Separating data in Figure 1). 
ii.	Expert: To select the most important components (only for the CP Prognostic Model)
b.	During the imputation step, to handle missing data, a threshold of 30% missing predictors is applied.

![image](https://github.com/user-attachments/assets/20f8e9e7-9e4c-4a7e-a655-565b4b3a17b2)





 
Figure 1. Pipeline Flowchart
