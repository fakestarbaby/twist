# Twist

Twitter streaming API to HipChat message API.

## Setup for development

Rename `.env.sample` to `.env`.

```bash
$ cp .env.sample .env
```

## Start foreman

```bash
$ foreman start
```

## Setup for Heroku

```bash
$ heroku create twist
$ git push heroku master
$ heroku scale worker=1
```
