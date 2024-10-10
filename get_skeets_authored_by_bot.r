get_skeets_authored_by_bot <- function(limit = 100,
                                       cursor = NULL) {
  cli::cli_progress_bar(
    format = "{cli::pb_spin} Got {length(res)} skeets, but there is more.. [{cli::pb_elapsed}]",
    format_done = "Got {length(res)} records. All done! [{cli::pb_elapsed}]"
  )

  res <- list()
  while (length(res) < limit) {

    resp <- do.call(
      what = atrrr:::com_atproto_repo_list_records,
      args = list(
        repo = "did:plc:vp33iulfrhmexder6odky774",
        collection = "app.bsky.feed.post",
        limit = 100,
        cursor = cursor
      ))

    cursor <- resp$cursor
    res <- c(res, resp$records)
    cli::cli_progress_update(force = TRUE)
    if (is.null(resp$cursor)) break
  }
  cli::cli_progress_done()
  tibble::tibble(
    uri = purrr::map_chr(res, "uri"),
    text = purrr::map_chr(res, c("value", "text"))
  )
}
