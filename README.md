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

- add secret management for the openai key
- some use of action cable & turbo streams
    - maybe nice auto updating from chatty's work; streaming
    - make the creation a watchable process where it goes and gets the file, then does the ai shit...
- make the summarisation good (prompt engineering lol)
- add auth
    - add tests
- update README
- deploy to prod
    - hook up deployment to my VPS
    - connect to CI/CD
    - update README with instructions
    - backups for db, action storage

### Wishlist

- do something smarter with the pdf source files
- tags/labels etc

### Low Priority
- use more services (solid queue, solid cache, ... etc.)
- update system tests and make them pass
- add integration tests
- trix editor doesn't breakpoint very nicely
