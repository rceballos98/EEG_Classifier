# EEG_classification_framework

## Framework

This is an EEG classification framework that allows for easier, more stuctured machine learning based classification of EEG data in MATLAB.
It does this by breaking down EEG classification into its fundamental elements:

* Data Pre-processing 
* Feature Generation 
* Feature Selection 
* Classification

This framework is meant to allow users to easily create function wrappers for their particular applications that fit the classification framework, allowing them to seemlessly re-use pre-existing methods that they or others have created.

## Implementations

Here is the list of implementations that fit the framework:

### Data Pre-processing

* EEGLAB 

### Feature Generation

* PSD
* Hemisphere Assymetry
* Free Asymmetry

### Feature Selection

* mRMR

### Classification

* SVM


## How to use
Run the provided demo to see the how all the units can be put together to classify emotion in a given EEG dataset.

