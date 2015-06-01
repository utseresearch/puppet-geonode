# geonode

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with geonode](#setup)
    * [What geonode affects](#what-geonode-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with geonode](#beginning-with-geonode)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This puppet module installs geonode (http://geonode.org).

## Module Description

Geonode makes use of a Python WSGI application, PostgreSQL database, and
Tomcat, so this module installs and configures them for you.

## Setup

### What geonode affects

* PostgreSQL
* Tomcat
* Apache/mod_wsgi
* Users: A geonode user is created to run the wsgi application

### Beginning with geonode

```
geonode { hostname => 'blah' }
```

## Usage


## Reference


## Limitations

Tested on Centos7.

## Development

Fork away!

## Release Notes

