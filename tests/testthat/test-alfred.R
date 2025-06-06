library(testthat)

# Helper to load functions without executing setup or cleanup
load_alfred_functions <- function() {
  code <- readLines("alfred.r")[1:87]
  eval(parse(text = code), envir = globalenv())
}

test_that("build_query_functions creates functions", {
  load_alfred_functions()
  build_query_functions(list(sample_call = c("id")))
  expect_true(exists("sample_call", envir = fred))
  expect_true(is.function(fred$sample_call))
  rm(fred, schema, build_query_functions, .parse_args, .url, .read_fred, set_api_key, sample_call, pos = globalenv())
})

test_that("API call returns expected structure", {
  load_alfred_functions()
  build_query_functions(list(sample_call = c("id")))
  sample_output <- list(result = "ok")
  assign(".read_fred", function(call, simplify_df = FALSE) sample_output, envir = globalenv())
  out <- fred$sample_call(id = 1)
  expect_equal(out, sample_output)
  rm(fred, schema, build_query_functions, .parse_args, .url, .read_fred, set_api_key, sample_call, pos = globalenv())
})
