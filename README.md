# heroku make

Build software on Heroku

## Installation

    heroku plugins:install http://github.com/ddollar/heroku-make-client.git

## Usage

    $ heroku help make
    Usage: heroku make [COMMAND]

     build a piece of software for the heroku cloud using COMMAND as a build command
     if no COMMAND is specified, a sensible default will be chosen for you

      -n, --name   NAME    # the name of the library (will default to the directory name)
      -o, --output FILE    # output build artifacts to this filemake [COMMAND]
      -p, --prefix PREFIX  # the build/install prefix of the software
      -v, --verbose        # show the full build output

    $ cd /tmp/memcached-1.4.7
    $ heroku make
    >> Packaging local directory for upload
    >> Building with: ./configure --prefix /app/vendor/memcached-1.4.7 && make install
    >> Downloading build artifacts to: /tmp/memcached-1.4.7.tgz

## License

MIT
