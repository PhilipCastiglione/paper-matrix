# Paper Matrix

A web app for summarizing academic papers and keeping notes.

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
bin/rails db:create
bin/rails db:migrate
```

**Tests:**

```sh
bin/rails test test:system
```

## TODO

- some use of action cable & turbo streams
    - maybe nice auto updating from chatty's work; streaming
    - make the creation a watchable process where it goes and gets the file, then does the ai shit...
- add auth
    - disabled visual (must be logged in tooltip) and secure backend
    - specifically to mutations/posts
    - generate
    - edit
    - delete
    - any other post endpoints?
    - add tests
- update README
- deploy to prod
    - hook up deployment to my VPS
    - connect to CI/CD
    - update README with instructions
    - backups for db, action storage

### Wishlist

- put a wrapper around the ai services so I can try/swap different models in
    - extract auto summaries into a table, with a join table that records which model generated it and when
- do something smarter with the pdf source files
- tags/labels etc
- make the summarisation better (prompt engineering lol)
- use more services (solid queue, solid cache, ... etc.)

### Things To Probably Ignore

- update system tests and make them pass
- add integration tests
- trix editor doesn't breakpoint very nicely
