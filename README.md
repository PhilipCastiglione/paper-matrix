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
bin/rails test
```

## TODO

- add auth
    - tests
- generate autosummary using chatty
    - basic initial functionality
    - extract title, authors, year
    - tests
- make it pretty
    - make it look okay
    - make it nice on mobile
    - flashes
    - nicer validator errors
- update README
- add all the tests
- deploy to prod
    - update README with instructions
    - backups for db, action storage
- make the summarisation good (prompt engineering lol)
    - tests
- some use of action cable..?
    - maybe nice auto updating from chatty's work; streaming
    - make the creation a watchable process where it goes and gets the file, then does the ai shit...
    - tests
- tags/labels etc
- use more services (job queues, cache servers, search engines, etc.)
    - try all the solid stuff
