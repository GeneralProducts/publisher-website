# Day Of Code website

## Develop

This app was built with [Jekyll](http://jekyllrb.com/) version 4.0.0

Install the dependencies with [Bundler](http://bundler.io/):

~~~bash
$ bundle install
~~~

This app uses Ruby 2.5.5 features. If you manage Ruby versions with RVM, run:

~~~bash
$ rvm use ruby-2.5.5
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

A valid ONIX 3.0 file should be present in the data directory, named `onix.xml`. It should include a xmlns namespace:

`http://ns.editeur.org/onix/3.0/reference`

The adaptor code uses a fuzzy match to process files by publisher name. To process the records for a publisher called `snowbooks`, run:

`ruby lib/seed.rb --adaptor onix --publisher snowbooks`

### For more information:

`ruby lib/seed.rb --help`

## Build and run

`jekyll build --watch`

To run the site locally:

`jekyll serve`

View the site locally:

`localhost:4000`
