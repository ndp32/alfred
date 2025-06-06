# ---------------------------------------------------------------------------- #
if (!("fred" %in% search())) {
fred <- new.env()
# --- FUNCTIONS -------------------------------------------------------------- #
#
# NOTE:
# - internal functions start with '.'; they are hidden  
# - user facing functions are not hidden

# paste function arguments into string with appropriate formatting    [internal]
.parse_args <- \(env) { 
  env <- as.list(env) |> Filter(f = \(x) !is.null(x)) 
  env |>
    seq_along() |> 
    lapply(\(i) paste0(names(env[i]), '=', env[i])) |> 
    Reduce(f = \(...) paste(..., sep = '&'))
}

# build complete url for API call                                     [internal]
.url <- \(branch, env) {
  paste0('https://api.stlouisfed.org/',
         'fred/', branch, '?', 
         'api_key=', .api_key, "&",
         'file_type=json', "&",
         .parse_args(env))
}

# make API call and return json as a list                             [internal]
.read_fred <- \(call, simplify_df = FALSE) {
  call |>
    httr2::request() |> 
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyDataFrame = simplify_df) 
}

# build function for each API endpoint                             [user facing]
build_query_functions <- \(schema) {
  for (i in seq_along(schema)) {
    name <- names(schema[i])
    branch <- gsub('_', '/', name)
    args <- paste0(paste0(schema[[i]], '=NULL'), collapse = ',')
    f_head <- paste0('fred$', name, '<-function(', args,',simplify_df=FALSE)')
    f_body <- paste0('.read_fred(.url("', branch,'",environment()), simplify_df)')
    eval(parse(text = paste0(f_head, f_body)), envir = .GlobalEnv)
  }
}

# set API key                                                      [user facing]
set_api_key <- \(api_key) {
  .api_key <<- api_key
}

# load api key from environment, file or user prompt                 [user facing]
load_api_key <- \(
    env_var = "FRED_API_KEY",
    file = "~/.fred_api_key",
    prompt = interactive()) {
  key <- Sys.getenv(env_var, unset = "")
  if (!nzchar(key) && file.exists(path.expand(file))) {
    key <- readLines(path.expand(file), warn = FALSE)[1]
  }
  if (!nzchar(key) && isTRUE(prompt)) {
    cat("Enter FRED API key: ")
    key <- readline()
    if (nzchar(key)) {
      dir.create(dirname(path.expand(file)), showWarnings = FALSE, recursive = TRUE)
      writeLines(key, path.expand(file))
    }
  }
  if (nzchar(key)) set_api_key(key) else warning("FRED API key not found")
  invisible(key)
}

# --- FRED API OPTIONS ------------------------------------------------------- #
schema <- list(
  category = c('category_id'),
  category_children = c('category_id', 'realtime_start', 'realtime_end'),
  category_related = c('category_id', 'realtime_start', 'realtime_end'),
  category_related_tags = c('category_id', 'realtime_start', 'realtime_end', 'tag_names', 'exclude_tag_names', 'tag_group_id', 'search_text', 'limit', 'offset', 'order_by', 'sort_order'),
  category_series = c('category_id', 'realtime_start', 'realtime_end', 'limit', 'offset', 'order_by', 'sort_order', 'filter_variable', 'filter_value', 'tag_names', 'exclude_tag_names'),
  category_tags = c('category_id', 'realtime_start', 'realtime_end', 'tag_names', 'tag_group_id', 'search_text', 'limit', 'offset', 'order_by', 'sort_order'),
  related_tags = c('realtime_start', 'realtime_end', 'tag_names', 'exclude_tag_names', 'tag_group_id', 'search_text', 'limit', 'offset', 'order_by', 'sort_order'),
  release = c('release_id', 'realtime_start', 'realtime_end'),
  release_dates = c('release_id', 'realtime_start', 'realtime_end', 'limit', 'offset', 'sort_order', 'include_release_dates_with_no_data'),
  release_related_tags = c('release_id', 'realtime_start', 'realtime_end', 'tag_names', 'exclude_tag_names', 'tag_group_id', 'search_text', 'limit', 'offset', 'order_by', 'sort_order'),
  release_series = c('release_id', 'realtime_start', 'realtime_end', 'limit', 'offset', 'order_by', 'sort_order', 'filter_variable', 'filter_value', 'tag_names', 'exclude_tag_names'),
  release_sources = c('release_id', 'realtime_start', 'realtime_end'),
  release_tables = c('release_id', 'element_id', 'include_observation_values', 'observation_date'),
  release_tags = c('release_id', 'realtime_start', 'realtime_end', 'tag_names', 'tag_group_id', 'search_text', 'limit', 'offset', 'order_by', 'sort_order'),
  releases = c('realtime_start', 'realtime_end', 'limit', 'offset', 'order_by', 'sort_order'),
  releases_dates = c('realtime_start', 'realtime_end', 'limit', 'offset', 'order_by', 'sort_order', 'include_release_dates_with_no_data'),
  series = c('series_id', 'realtime_start', 'realtime_end'),
  series_categories = c('series_id', 'realtime_start', 'realtime_end'),
  series_observations = c('series_id', 'realtime_start', 'realtime_end', 'limit', 'offset', 'sort_order', 'observation_start', 'observation_end', 'units', 'frequency', 'aggregation_method', 'output_type', 'vintage_dates'),
  series_release = c('series_id', 'realtime_start', 'realtime_end'),
  series_search = c('search_text', 'search_type', 'realtime_start', 'realtime_end', 'limit', 'offset', 'order_by', 'sort_order', 'filter_variable', 'filter_value', 'tag_names', 'exclude_tag_names'),
  series_search_related_tags = c('series_search_text', 'realtime_start', 'realtime_end', 'tag_names', 'exclude_tag_names', 'tag_group_id', 'tag_search_text', 'limit', 'offset', 'order_by', 'sort_order'),
  series_search_tags = c('series_search_text', 'realtime_start', 'realtime_end', 'tag_names', 'tag_group_id', 'tag_search_text', 'limit', 'offset', 'order_by', 'sort_order'),
  series_tags = c('series_id', 'realtime_start', 'realtime_end', 'order_by', 'sort_order'),
  series_updates = c('realtime_start', 'realtime_end', 'limit', 'offset', 'filter_value', 'start_time', 'end_time'),
  series_vintagedates = c('series_id', 'realtime_start', 'realtime_end', 'limit', 'offset', 'sort_order'),
  source = c('source_id', 'realtime_start', 'realtime_end'), # conflicts with base R source() 
  source_releases = c('source_id', 'realtime_start', 'realtime_end', 'limit', 'offset', 'order_by', 'sort_order'),
  sources = c('realtime_start', 'realtime_end', 'limit', 'offset', 'order_by', 'sort_order'),
  tags = c('realtime_start', 'realtime_end', 'tag_names', 'tag_group_id', 'search_text', 'limit', 'offset', 'order_by', 'sort_order'),
  tags_series = c('tag_names', 'exclude_tag_names', 'realtime_start', 'realtime_end', 'limit', 'offset', 'order_by', 'sort_order')
)

# --- UI SETUP --------------------------------------------------------------- #
load_api_key()
build_query_functions(schema) # build all 31 api call functions

attach(fred)
rm(fred, schema, set_api_key, build_query_functions)
}
