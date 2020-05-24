# Design

## Technology

In order to minimise costs, this infrastucture is hosted on AWS using exclusively their managed offerings to take advantage of free tiers during low traffic and the managed scalability during high traffic periods.

In the interest of minimising cost further, the entire site will be statically generated, and delivered through the AWS CloudFront CDN. For dynamic functionality there will be a few AWS Lambda functions served through AWS API gateway to create and regenerate pages within the site.

- AWS CloudFront as a Content-Delivery Network (CDN)
- AWS S3 for site page storage (the back-end for the CDN)
- AWS Lambda to generate dynamic pages for the site
- AWS DynamoDB to persistently store data
- AWS SES to send emails
- Hugo for generating static pages

### Lambdas

- `POST /results`: Generate a new static page with the form payload. These go into the `/results` dir in S3.
- `SQS: Email`: Generate a new static page with an email. These go into the `/emails` dir in S3.
- `SQS: Generate Result Totals`: Regenerate totals page. These go into the `/totals` dir in S3.

### CI/CD

For the main site, we will utilise CD to deploy newer versions of the site and Lambdas.

#### Hugo

Hugo will be used for generating the entire site. For dynamic pages, Hugo will be invoked with a small subset of the site.
