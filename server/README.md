# omnigram-server

<div style="font-size: 1.5rem;">
  <a href="./README.md">English</a> | <a href="./README.zh.md">中文</a>
</div>
</br>

omnigram-server is a personal content management backend service written in Golang, providing document scraping and management features similar to Jellyfin and Navidrome.
For client support, please visit [Omnigram](github.com/lxpio/omnigram).

> Reminder: It is not allowed to publish personal websites in mainland China, maintaining publicly accessible book websites is considered illegal and against regulations! Intended for personal learning use only!

### Documentation

Official documentation (including installation manual) can be found at https://omnigram.lxpio.com/.

### Objectives and Features

1. Provide NAS privatized e-book library scraping service (currently supports only Epub format);
2. Implemented using TTS models, provide e-book reading service (additional model service reference [m4t_server](docs/en/m4t-server.md) is required);
3. Provide Chat model support for understanding and analyzing e-books, supporting the expansion and refinement of simple diaries;

## Deployment

### Quick Start

### docker

```bash
# Replace ${MY_DIR} with your actual directory containing epub files
docker run --rm -v ${MY_DIR}:/docs -p 8080:80 lxpio/omnigram-server:latest
```

TODO

### Linux server

Use Mysql or Postgresql database

1. Modify the configuration file conf.yaml

### Development Plan

- [x] Support multi-user management and user grading
- [x] Support TTS reading;
- [] Support browsing and management

## Frequently Asked Questions

For common issues, please refer to the user guide

For manual installation, refer to the [development guide](docs/dev.md)

## Project Dependencies and Third-party Framework Usage Instructions

TODO

## Acknowledgments

TODO

### Support this Project

I am dedicated to this project and will continue to update documentation, add features, and fix issues. However, I cannot do it alone; I need your help to improve this project.


