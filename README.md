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

## Requirements

* **R version**: 4.1 or later (the script makes heavy use of the native pipe
  operator `|>` which was introduced in R 4.1).
* **Dependencies**: the [`httr2`](https://cran.r-project.org/package=httr2)
  package is required for all API requests. Install it with
  `install.packages("httr2")`.

## API Key

The script reads your FRED API key from the `FRED_API_KEY` environment
variable. Set it in your R session before sourcing the file:

```r
Sys.setenv(FRED_API_KEY = "your_api_key_here")
source("alfred.r")
```

## Example

With the API key in place and the script sourced, any of the generated
functions can be called. For example, to fetch GDP observations:

```r
gdp <- series_observations(series_id = "GDP", observation_start = "2022-01-01")
head(gdp)
```

See the [FRED API documentation](https://fred.stlouisfed.org/docs/api/fred/)
for details on the available parameters and responses.

## License

This project is distributed under the terms of the MIT License. See the
[LICENSE](LICENSE) file for more details.
