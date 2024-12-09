# Paper Matrix

A web app for summarizing academic papers and keeping notes.

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

- deploy to prod
    - hook up deployment to my VPS
    - connect to CI/CD
    - update README with instructions
    - backups for db, action storage

## TODO

- put a wrapper around the ai services so I can try/swap different models in
    - extract auto summaries into a table, with a join table that records which model generated it and when
- better error handling when the generate streaming fails
- do something smarter with the pdf source files (than just reading the text content)
- tags/labels etc
- make the summarisation better (prompt engineering lol)
- add system & integration tests
- trix editor doesn't breakpoint very nicely
