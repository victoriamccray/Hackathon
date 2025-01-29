#!/usr/bin/env python
# coding: utf-8

# # Python Ecosytem for Neuroimaging
# ## Accessing Datasets
# **Author:** Victoria McCray

# In[1]:


import datetime

current_date = datetime.date.today()

print("Last Updated:", current_date)


# ## Installation
# 
# Before using the code, install necessary libraries and dependencies using `pip`.

# In[2]:


#pip install nilearn nibabel datalad


# In[3]:


import os
from datalad import api
from nilearn import datasets


# ## Dataset Setup
# ### Downloading the Dataset
# 
# The script clones a dataset from OpenNeuro using the `datalad` library. The dataset used in this example is the **ds000030** dataset, which is accessed via the following GitHub URL:
# 
# [ds000030](https://github.com/OpenNeuroDatasets/ds000030.git)
# 
# BIDS File Structure
# 
# ### Path Setup
# We define the dataset path where the data will be saved. The path can be adjusted as needed. Then, we check whether the dataset exists locally, and if not it will clone the dataset and notify the user.

# In[4]:


# Clone the dataset from OpenNeuro (adjust the dataset path as needed)
dataset_url = "https://github.com/OpenNeuroDatasets/ds000030.git"
dataset_path = "./ds000030"
#dataset_path = "./ds002336"


# In[5]:


# Clone the dataset if not already present
if not os.path.exists(dataset_path):
    api.clone(source=dataset_url, path=dataset_path)
    print(f"Dataset cloned at {dataset_path}")


# In[6]:


if os.path.exists(dataset_path):
    print(f"Dataset found at {dataset_path}")
else:
    print(f"Dataset not found at {dataset_path}")


# ### Checking for Functional Data
# 
# After cloning the dataset, the script checks for the existence of the **functional data** folder (`sub-01/func`). It will print whether or not the data was found.

# In[7]:


func_data_path = os.path.join(dataset_path, "sub-10159/func")
if os.path.exists(func_data_path):
    print(f"Functional data found at: {func_data_path}")
else:
    print(f"Functional data not found at: {func_data_path}")


# In[8]:


# List the contents of the dataset directory
for root, dirs, files in os.walk(dataset_path):
    print(f"Current directory: {root}")
    print(f"Subdirectories: {dirs}")
    print(f"Files: {files}")


# ## Additional Resources

# DataLad. (n.d.). Quickstart. In DataLad Handbook. Retrieved from https://handbook.datalad.org/en/latest/usecases/openneuro.html#quickstart.
# 
# 
# 
# 
# The entire collection of OpenNeuro datasets can be found at [](github.com/OpenNeuroDatasets), but each dataset in there is identified via its OpenNeuro dataset ID. A url to an OpenNeuro dataset on GitHub thus always takes the following form: `https://github.com/OpenNeuroDatasets/ds00xxxx`. After you have installed DataLad, you can obtain the datasets just as any other DataLad dataset with datalad clone (manual):

# **Note**: The `!` syntax allows you to run shell commands from within a Jupter notebook. 
# 
# The dataset can be cloned directly without leaving to a terminal or command prompt.

# In[ ]:




