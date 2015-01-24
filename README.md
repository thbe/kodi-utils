# kodi-utils

####Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with kodi utils](#setup)
  * [Setup requirements](#setup-requirements)
  * [Setup kodi utils](#setup-kodi-utils)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


##Overview

This repository contain some of my scripts and utilities I use in conjunction with
the Kodi media center

##Setup

###Setup requirements
To get kodi utils up and running you need to install ruby and some modules:

* Ruby 2.x
* gem install nokogiri
* gem install open-uri
* gem install uri
* gem install net/http

###Setup kodi utils
To install the kodi utils simply clone the git repository:

```bash
git clone https://github.com/thbe/kodi-utils.git
```

##Usage

###video_to_html.rb

This script generate a HTML page containing an overview of your movies and tv series
based on the videodb.xml export. Simply call the script like this:

```bash
ruby videodb_to_html.rb
```

## Reference

### Scripts

* videodb_to_html.rb: Generate HTML overview based on videodb.xml export

## Limitations

The scripts has been tested on Mac OS X Yosemite with brew installed. It should
work on all systems where Ruby is available.

## Development
If you like to add or improve this module, feel free to fork the module and send
me a merge request with the modification.
