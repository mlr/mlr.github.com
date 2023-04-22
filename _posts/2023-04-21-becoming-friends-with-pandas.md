---
title: Becoming Friends with Pandas
subtitle: Exploring CSV Data with Pandas and Jupyter Notebooks
tags: python, pandas, jupyter-notebook, csv
---

[Pandas](https://pandas.pydata.org/) is a Python library for data analysis and manipulation, providing tools for working with structured data. It is widely used in data science and other fields where data analysis and manipulation are important.

Frequently we will work with tabular data which is often stored in comma-separated values (CSV) files. In this post, we'll look at how to read, analyze, and modify CSV files in Jupyter Notebooks using the Pandas library.

## Reading a CSV File

To read a CSV file in Jupyter Notebook, we first need to import the Pandas library. We can then use the `read_csv()` method to read the contents of the file into a Pandas DataFrame.

```python
import pandas as pd

# Read the CSV file into a DataFrame
df = pd.read_csv('file.csv')

# Output the first 5 rows of the DataFrame
df.head()
```

The `read_csv()` method takes several options to customize the way it reads the file. For example, if the CSV file uses a different delimiter than a comma, we can use the `delimiter` option to specify it. We can also use the `header` option to specify whether the file contains a header row, and the `skiprows` option to skip a specific number of rows at the beginning of the file.

## Analyzing CSV Data

Once we have read a CSV file into a Pandas DataFrame, we can use the powerful Pandas library to explore, analyze and manipulate the data.

We can use the `info()` method to get general information about the DataFrame, including the number of rows and columns, the data types of each column, and the amount of memory used by the DataFrame.

```python
# Output general info about the DataFrame
df.info()
```

To get a summary of the numerical data in the DataFrame, we can use the `describe()` method.

```python
# Output a summary of the numerical data in the DataFrame
df.describe()
```

To get a quick preview of the contents of the DataFrame, we can use the `head()` method to output the first few rows of the DataFrame.

```python
# Output the first 10 rows of the DataFrame
df.head(10)
```

To visualize the data in the DataFrame, we can use the `plot()` method to create various types of plots, such as line, bar, and scatter plots.

```python
# Create a line plot of the data
df.plot(kind='line', x='Date', y='Price')
```

```python
# Create a pie plot of the data
abs_grouped = df.groupby('Category')['Amount'].agg('sum').abs()
abs_grouped.plot(kind='pie', y='Amount', autopct='%1.1f%%', startangle=90)
```

## Modifying CSV Data

We can use the various DataFrame methods and Pandas functions to modify the data. For example, we can use the `apply()` method along with a lambda function to modify the values in a specific column of a Pandas DataFrame. The lambda function takes a single argument and applies a transformation to it, and then the `apply()` method applies this function to each value in the selected column of the DataFrame.

```python
# Double the value of 'Amount' column
df['Amount'] = df['Amount'].apply(lambda x: x * 2)
```

Here we are using this approach to multiply each value in the 'Amount' column by two. This modifies the original data in-place, and the modified DataFrame is stored in the same variable.

After modifying the data, we can use the `to_csv()` method to save the DataFrame back to a CSV file.

```python
# Save the modified DataFrame to a new CSV file
df.to_csv('modified_file.csv', index=False)
```

## Conclusion

In this post, we looked at how to read, analyze and modify CSV files in
Jupyter Notebooks using the Pandas library. We learned how to read a CSV file
into a Pandas DataFrame, how to analyze the data using various Pandas methods,
how to visualize the data using the `plot()` method, and how to modify the data
and save it back to a CSV file.

## Resources

- [Pandas official documentation](https://pandas.pydata.org/docs/)
- [Pandas Cookbook](https://pandas.pydata.org/docs/user_guide/cookbook.html)
- [10 Minutes to Pandas](https://pandas.pydata.org/pandas-docs/stable/user_guide/10min.html)
- [Pandas Cheat Sheet](https://pandas.pydata.org/Pandas_Cheat_Sheet.pdf)
