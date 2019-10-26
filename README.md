# DOC website

## Develop

This app was built with [Jekyll](http://jekyllrb.com/) version 3.3.1

Install the dependencies with [Bundler](http://bundler.io/):

~~~bash
$ bundle install
~~~

Run `jekyll` commands through Bundler to ensure you're using the right versions:

~~~bash
$ bundle exec jekyll serve
~~~

## Data

### From Consonance's API:

* Add and remove products to be included on the site, on Consonance:

`https://web.consonance.com/shops/:id/products`

You need to authenticate to get data from Consonance.
`cd` into the `publisher-website` directory.
Using your API key and shop ID from Consonance, run:

`API_KEY=1234567890 SHOP_ID=123 ruby lib/seed.rb --adaptor consonance`

### From ONIX files:

A valid ONIX 3.0 file should be present in the data directory, named for the publisher.
To process a file called `snowbooks.xml`, run:

`ruby lib/seed.rb --adaptor onix --publisher snowbooks`

### For more information:

`ruby lib/seed.rb --help`

## Build and run

`jekyll build --watch`

To run the site locally:

`jekyll serve`

View the site locally:

`localhost:4000`
