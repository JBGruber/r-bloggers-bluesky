## packages
library(atrrr)
library(anytime)
library(dplyr)
library(stringr)
library(glue)
library(purrr)
library(xml2)

## Part 1: read RSS feed
feed <- read_xml("http://r-bloggers.com/rss")
# minimal custom RSS reader
rss_posts <- tibble::tibble(
  title = xml_find_all(feed, "//item/title") |>
    xml_text(),
  creator = xml_find_all(feed, "//item/dc:creator") |>
    xml_text(),
  link = xml_find_all(feed, "//item/link") |>
    xml_text(),
  ext_link = xml_find_all(feed, "//item/guid") |>
    xml_text(),
  timestamp = xml_find_all(feed, "//item/pubDate") |>
    xml_text() |>
    utctime(tz = "UTC"),
  description = xml_find_all(feed, "//item/description") |>
    xml_text() |>
    # strip html from description
    vapply(function(d) {
      read_html(d) |>
        xml_text() |>
        trimws()
    }, FUN.VALUE = character(1))
)


## Part 2: create posts from feed
posts <- rss_posts |>
  mutate(
    desc_preview_len = 294 - nchar(title),
    desc_preview = map2_chr(description, desc_preview_len, function(x, y) str_trunc(x, y)),
    post_text = glue("{title}\n\n\"{desc_preview}\"")
  )


## Part 3: get already posted updates and de-duplicate
Sys.setenv(BSKY_TOKEN = "r-bloggers.rds")
auth(
  user = "r-bloggers.bsky.social",
  password = Sys.getenv("ATR_PW"),
  overwrite = TRUE
)
# there is a bug in this endpoint (not the function), which omits some posts
# https://github.com/bluesky-social/atproto/issues/2616
#
# old_posts <- get_skeets_authored_by("r-bloggers.bsky.social", limit = 5000L)
source("get_skeets_authored_by_bot.r")
old_posts <- get_skeets_authored_by_bot(limit = 5000L)

posts_new <- posts |>
  filter(!post_text %in% old_posts$text)


## Part 4: Post skeets!
for (i in seq_len(nrow(posts_new))) {
  # if people upload broken preview images, this fails
  resp <- try(post_skeet(
    text = posts_new$post_text[i],
    created_at = posts_new$timestamp[i]
  ))
  if (methods::is(resp, "try-error")) {
    try({
      post_skeet(
        text = posts_new$post_text[i],
        created_at = posts_new$timestamp[i],
        link = posts_new$link,
        preview_card = FALSE
      )
    })
  }
}
