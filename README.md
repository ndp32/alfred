# alfred
LOAD DATA USING THE (AL)FRED API

Date: 2023-02-01
Author: Niko Paulson
The code below provides a 1-1 mapping of the FRED API to R functions. This 
makes it easier to build complex querys that are not supported by basic but
ubiquitous connection libraries like {quantmod} in R and {pandas-datareader} 
in Python. 

To gain a better understanding of the inputs and outputs of these functions,
see the FRED website, which contains extensive documentation on the API. 
https://fred.stlouisfed.org/docs/api/fred/

The goal here is to give you as much access to FRED data as the API
affords us. However, in most cases, the output of the functions provided is 
pretty bulky. Nested lists are common; more information than you want 
usually is returned. For  me, these functions are a starting point that I 
wrap in more streamlined functions.

Note that I put this script together in a hurry. It works well for me,
but has not been thoroughly tested. If you find any bugs, please let me know.
