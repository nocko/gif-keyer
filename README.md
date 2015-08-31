# Animated GIF keyer

Inspired by Matthew Garrett, original Tweet:
https://twitter.com/mjg59/status/637878696536227840

## Requirements

 - Bash 4.x
 - ImageMagick
 - Twisted [Optional for web svc.]
 - Docker [Optional of easy web svc. deploy]

## Basic Usage

`./keyer.sh <WPM> "<phrase to key>"`

## License:

Public Domain

## Web Service:

### With Docker

1. `docker run -p 8080:8080 nocko/gif-keyer`

- or -

1. `docker build -t gif-keyer .`
2. `docker run -p 8080:8080 gif-keyer`

### Without Docker

1. Install twisted (pip install Twisted, or similar)
2. `twistd -n -y gifkeyer.py`

### Web Service Usage

`wget http://<host or ip>/<any word or phrase>.gif`