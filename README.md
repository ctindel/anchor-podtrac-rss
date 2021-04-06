# anchor-podtrac-rss

Unfortunately podtrac no longer supports rewriting your hosting provider's RSS feed and providing you with a new RSS feed that includes podtrac URLs.  In order to use podtrac you have to modify your RSS feed with the podtrac URLs prepended in the url attribute of the item enclosure tag.  Doubly unfortunate is that anchor.fm does not support modifying the RSS feed in this way when using them as a hosting provider.  There is currently no built-in mechanism to make podtrac and anchor.fm work together, for reasons passing understanding.

This script will grab your anchor.fm RSS feed, modify the URLs to prepend the podtrac prefix with m4a format, and push the new RSS feed file to some location in an S3 bucket which you can serve up to various hosting providers like spotify, apple podcasts, google podcasts, etc.

## Prerequisites

Your system needs to have xsltproc and the awscli installed.  Your environment
needs to be setup so the aws cli can run with the proper credentials.

## Running

Invoke the command like this.  The ```ANCHOR_RSS_FEED_URL``` and ```AWS_S3_RSS_URL``` environment variables are required.  If you also want the script to invalidate the xml file in a Cloudfront Distribution then include the ```CF_DISTRIBUTION_ID``` variable as well.

```
ANCHOR_RSS_FEED_URL="https://anchor.fm/s/YOUR_ANCHOR_FEED_ID/podcast/rss" AWS_S3_RSS_URL="s3://bucket/path/to/rss.xml CF_DISTRIBUTION_ID=YOUR_CLOUDFRONT_DISTRIBUTION_ID" bash anchor-podtrac-rss.sh
```

## Notes

If your s3 bucket is hosting a website inside of it also you might need to
change your website deployment tools to ignore the fact that this xml file
exists or the deployment software might be tempted to remove it.  For example,
a hugo static website deployed with the ```hugo deploy``` command would need
this configuration to be added:

```
[[deployment.targets]]
# An arbitrary name for this target.
name = "aws"
# S3; see https://gocloud.dev/howto/blob/#s3
# For S3-compatible endpoints, see https://gocloud.dev/howto/blob/#s3-compatible
URL = "s3://bucket?region=us-east-2"
# If you are using a CloudFront CDN, deploy will invalidate the cache as needed.
cloudFrontDistributionID = "YOUR_CLOUDFRONT_CDN_ID"
exclude = "/*rss*.xml"
```
