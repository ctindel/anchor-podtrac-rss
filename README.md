# anchor-podtrac-rss

Unfortunately podtrac no longer supports rewriting your hosting provider's RSS feed and providing you with a new RSS feed that includes podtrac URLs.  In order to use podtrac you have to modify your RSS feed with the podtrac URLs prepended in the url attribute of the item enclosure tag.  Doubly unfortunate is that anchor.fm does not support modifying the RSS feed in this way when using them as a hosting provider.  There is currently no built-in mechanism to make podtrac and anchor.fm work together, for reasons passing understanding.

This script will grab your anchor.fm RSS feed, modify the URLs to prepend the podtrac prefix with m4a format, and push the new RSS feed file to some location in an S3 bucket which you can serve up to various hosting providers like spotify, apple podcasts, google podcasts, etc.

## Prerequisites

Your system needs to have xsltproc and the awscli installed.

## Running

Invoke the command like this:

```
ANCHOR_RSS_FEED_URL="https://anchor.fm/s/YOUR_ANCHOR_FEED_ID/podcast/rss" AWS_S3_RSS_URL="s3://bucket/path/to/rss.xml" bash anchor-podtrac-rss.sh
```
