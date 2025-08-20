# R-Bloggers Bot <img src="logo.png" align="right" height="120">

This is the bot behind <https://bsky.app/profile/r-bloggers.bsky.social>.
It parses the RSS feed of new blogs posts from the blog aggregator site https://www.r-bloggers.com/ and advertises them once per hour on Bluesky.
Learn more about R-Bloggers at <https://www.r-bloggers.com/about/>.

This bot is also meant as a showcase for how to build bots on top of the [{atrrr}](https://jbgruber.github.io/atrrr/) package.
The relevant files are:

- [bot.r](bot.r): R script that collects the RSS entries and posts them
- [bot.yml](.github/workflows/bot.yml) the Github action script running the bot once per hour
