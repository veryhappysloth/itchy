[![Build Status](https://secure.travis-ci.org/arax/onevmcatcher.png)](http://travis-ci.org/kosoburak/itchy)
[![Dependency Status](https://gemnasium.com/arax/onevmcatcher.png)](https://gemnasium.com/kosoburak/itchy)
[![Gem Version](https://fury-badge.herokuapp.com/rb/onevmcatcher.png)](https://badge.fury.io/rb/itchy)
[![Code Climate](https://codeclimate.com/github/arax/onevmcatcher.png)](https://codeclimate.com/github/kosoburak/itchy)

# Itchy - vIrTual applianCe Handling utiliTY

ITCHY is tool for handling virtual appliances.

## Related tools
ITCHY is part of tool chain used for automated virtual applience handling.
Because of character of this tool, separated usage is not really helpfull.

Part of ITCHY is designed to be an event handler for [vmcatcher](https://github.com/hepix-virtualisation/vmcatcher).

Files created by ITCHY are intended to be uploated and registered in a cloud storage.
This can be done by our other tool [nifty](https://github.com/CESNET/nifty).

## What and how does ITCHY do?

It basically converts heterogeneous output from vmcatcher and prepare all necessary files for upload an registration into a cloud storage.

ITCHY consists of two cooperating tasks. One serves for archiving vmcatcher events, second one for further processing. This concept was needed because of two reasons. First reason is that vmcatcher run as a cron job, regularly. There is a possibility, that image processing time would be greater than time period between two vmcatcher runs. In this case, the whole process would fail. The second reason is that we can't interrupt vmcatcher event processing and start over. So, the first part of ITCHY running with vmcatcher as event handler is so simple as it can be. The other acts are separated and they can be restarted or delayed if there is a need to do so, and it won't affect vmcatcher.

## Instalation

###From distribution specific packages
Distribution specific packages can be created with [omnibus packaging for ITCHY](https://github.com/CESNET/omnibus-itchy). When installing via packages you don't have to install neither ruby nor rubygems. Packages contain embedded ruby and all the necessary gems and libraries witch will not effect your system ruby, gems and libraries.

Currently supported distributions:

    Ubuntu 12.04
    Ubuntu 14.04
    Debian 7.6
    Debian 8.2
    CentOS 6.5
    CentOS 7.1

###From RubyGems.org
To install the most recent stable version
``bash
gem install nifty
``

###From source (dev)
**Installation from source should never be your first choice! Especially, if you are not
familiar with RVM, Bundler, Rake and other dev tools for Ruby!**

**However, if you wish to contribute to our project, this is the right way to start.**

To build and install the bleeding edge version from master

```bash
git clone git://github.com/CESNET/itchy.git
cd itchy
gem install bundler
bundle install
bundle exec rake spec
```

## Configuration
###Create a configuration file for ITCHY
Configuration file can be read by ITCHY from these
three locations:

* `~/.itchy/itchy.yml`
* `/etc/itchy/itchy.yml`
* `PATH_TO_GEM_DIR/config/itchy.yml`

The default configuration file can be found at the last location
`PATH_TO_GEM_DIR/config/itchy.yml`.

## Usage
ITCHY starts with executable `itchy`. For further assistance run `itchy help`:
```bash
$ itchy help

Commands:
itchy archive         # Handle an incoming vmcatcher event and store it for...
itchy help [COMMAND]  # Describe available commands or one specific command
itchy process         # Process stored events
```
### ARCHIVE
This command is used as an event handler for `vmcatcher`.
For proper running it needs to have set required env variables by `vmcatcher`. 
```bash
$ itchy help archive

Usage:
  itchy archive

  Options:
    -m, [--metadata-dir=METADATA_DIR]          # Path to a metadata directory for storing events, must be writable
                                               # Default: /var/spool/itchy/metadata
        [--log-to=LOG_TO]                      # Logging output, file path or stderr/stdout
                                               # Default: /var/log/itchy/archive.log
    -p, [--file-permissions=FILE_PERMISSIONS]  # Sets permissions for all created files
                                               # Default: 0664
    -b, [--log-level=LOG_LEVEL]                # Logging level
                                               # Default: error
                                               # Possible values: debug, info, warn, error, fatal, unknown
    -d, [--debug], [--no-debug]                # Enable debugging

Handle an incoming vmcatcher event and store it for further processing
```
### PROCESS

```bash
$itchy help process

Usage:
  itchy process

Options:
  -m, [--metadata-dir=METADATA_DIR]          # Path to a metadata directory for stored events
                                             # Default: /var/spool/itchy/metadata
  -f, [--required-format=REQUIRED_FORMAT]    # Required output format of converted images
                                             # Default: qcow2
  -o, [--output-dir=OUTPUT_DIR]              # Path to a directory where processed events descriptors will be stored
                                             # Default: /var/spool/itchy/output
  -t, [--temp-image-dir=TEMP_IMAGE_DIR]      # Path to a directory where images will be temporary stored while being processed
                                             # Default: /var/spool/itchy/temp
  -e, [--descriptor-dir=DESCRIPTOR_DIR]      # Path to a directory where appliance descriptors will be stored
                                             # Default: /var/spool/itchy/descriptors
  -p, [--file-permissions=FILE_PERMISSIONS]  # Sets permissions for all created files
                                             # Default: 0664
  -l, [--log-to=LOG_TO]                      # Logging output, file path or stderr/stdout
                                             # Default: /var/log/itchy/process.log
  -q, [--qemu-img-binary=QEMU_IMG_BINARY]    # Path to qemu-img command binary, if not used, ITCHY will look for it in PATH
  -b, [--log-level=LOG_LEVEL]                # Logging level
                                             # Default: error
                                             # Possible values: debug, info, warn, error, fatal, unknown
  -d, [--debug], [--no-debug]                # Enable debugging

Process stored events
```
## Contributing

1. Fork it ( https://github.com/kosoburak/itchy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
