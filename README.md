# Paper Matrix

A web app for summarizing academic papers and keeping notes.

Live at: https://pm.philipcastiglione.com/

## Technologies

I created this repo mainly to play with Ruby on Rails 8. This is using standard Rails 8 stack and defaults and is deployed bare metal style to a VPS. DHH would be proud.

## Development

### Requirements

**Ruby Version:** 3.2.2

**System dependencies:**

```sh
gem install rails
bin/bundle install
```

**Configuration:**

You will need a master key file, kept in 1password.

**Database:**

```sh
bin/rails db:setup
```

**Tests:**

```sh
bin/rails test
```

### Deployment

With docker running:

```sh
export KAMAL_REGISTRY_TOKEN=...

bin/kamal deploy
```

## TODO

- backups for db, action storage
    - mount a docker volume so you can backup sqlite and action storage
- loading spinner when waiting for api calls
- put a wrapper around the ai services so I can try/swap different models in
    - extract auto summaries into a table, with a join table that records which model generated it and when
- better error handling when the generate streaming fails
- do something smarter with the pdf source files (than just reading the text content)
- tags/labels etc
- make the summarisation better (prompt engineering lol)
- add system & integration tests
- trix editor doesn't breakpoint very nicely
