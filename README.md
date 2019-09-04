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

On the command line:

`API_KEY=1234567890 ruby lib/seed.rb`

### From ONIX: 

`ruby lib/seed.rb --onix [publisher-name]`

## Build and run

`jekyll build --watch`

To run the site locally:

`jekyll serve`

View the site locally:

`localhost:4000`