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
$ heroku plugins:install git://github.com/ddollar/heroku-config.git
$ heroku config:push
$ heroku scale twist=1
```
