# Home Credit Default Risk Prediction

## Background: What is it that we're actually doing?
I am brought on by Home Credit, who are an international consumer finance provider. When deciding whether or not to give out a personal loan to applicants, they are at a crossroads, given that there is little to no customer history. Therefore, I am asked to design a credit default prediction system using the data that the firm currently has. During the process, I will deal with multiple problems that arise from real-world financial datasets, and navigate them accordingly.

## Architecture + Implementation
### Technologies used
I use Pandas to store the data in a structured format, and the Python NumPy library to process this data, making use of NumPy's vectorized nature for quick and efficient operations. Other libraries used include Python's pre-built classifiers (e.g. Random Forest, Logistic Regression), as well as clustering and statistical tools.

### Exploratory Data Analysis (EDA)
In the [first notebook](notebooks/01_eda.ipynb), my focus is to explore the data, and uncover trends, distributions, statistics (what percentage of the data is missing in each column?), and correlation.

### Preprocessing
In the [second notebook](notebooks/02_preprocessing.ipynb), I deal with sentinel values; values that are a stand-in and have a certain meaning, but may not jump out when first observing the data. I also remove features that have an excessive amount of missing values - these features contribute little to the prediction and only serve to add noise. Additionally, I also imputed features with a small percentage of missing values (<5\%) with the median (numerical features, immune to outliers pulling mean either up or down), or median (categorical features).

### Feature Implementation + Unsupervised Applicant Clustering
In the [third notebook](notebooks/03_feature_engineering.ipynb), I get into the nitty-gritty work: crafting new features to enrich the data and to provide improved signal to classifiers. For example, I utilized the supplementary bureau dataset (which included credit information provided by various other institutions) to compute aggregated features for each applicant. This served to engineer features that were not originally in the dataset. Think about it as using domain knowledge to inject signal into the dataset. I also perform unsupervised learning in the form of clustering; by segmenting applicants into groups, I could profile the applicants to try and gain some insight into what kind of customer they are when it comes to paying back credit.

### Building Models + Experiments
In the [fourth notebook](notebooks/04_modeling.ipynb), I run the preprocessed data through multiple classifiers to determine which one is the most performant. Each classifier was packaged into a Pipeline that first normalized the data (centreing by subtracting the column mean, then scaling by dividing by the column standard deviation), then the classifier was trained. This prevented any one column from "dominating" over others. For example, it doesn't make sense to compare income and age using the same scale. By normalizing, it allows the model to make comparisons about a particular sample's column values relative to the values within the same column from other samples.

### Model Validation + Explainability
In the [fifth notebook](notebooks/05_explainability.ipynb), I took the champion model from the previous step and scrutinize it; is performance consistent and stable across cross-validation folds? Is there a lot of variance/deviation between for results across folds? I also use SHAP to extract the most important features when it comes to classifying credit default.

## Limitations/Next Steps
I see two glaring improvements/issues with the project as it currently stands:
1. As data volume grows, the notebooks will take more and more time to run, until the data will be too large to fit in memory
2. No automation - notebooks sit in isolation, with developers/auditors needed to run notebooks separately, then generate intermediate data files. Everything is manual, and there is a high chance of human error, after which items will become disjointed and scattered, and people will forget which part of the pipeline was run last

### The all-in-one solution: Databricks
Databricks is able to solve both of these problems at once. By using Spark under the hood, Databricks distributes data across several physical machines during computations, thereby improving efficiency and allowing Home Credit to scale the approval process without any hassle. Additionally, teams can use Databricks' Job Orchestration and ETL Pipeline capabilities to automate the entire process, end-to-end. For ingestion, raw data can be read into the Bronze tier as Delta Tables on a file arrival/scheduled trigger basis, lowering compute costs. Cleaned, feature engineered data can be written to the Silver tier. Finally, model validation results can be written to the Gold tier, ready to be used by analysts for reporting. Notebooks can be brought together to form a Pipeline, which, together with any other tasks such as reporting, form the overall Job. Databricks makes it very easy to streamline the end-to-end process, and also allows developers to easily troubleshoot errors in production without having to sift through countless files.