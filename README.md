#

<picture>
  <source
    srcset="https://omnigram.nexptr.com/images/logo_with_letter_dark.svg"
    media="(prefers-color-scheme: dark)"
  />
  <source
    srcset="https://omnigram.nexptr.com/images/logo_with_letter_white.svg"
    media="(prefers-color-scheme: light), (prefers-color-scheme: no-preference)"
  />
  <img src="https://omnigram.nexptr.com/images/logo_with_letter_white.svg" />
</picture>


<div style="font-size: 1.5rem;">
  <a href="./README.md">English</a> | <a href="./README.zh.md">中文</a>
</div>
</br>

## About Omnigram

Omnigram is a multi-platform (iOS, Android, Web, Windows, Linux, Mac) file reading and audiobook client written in Flutter. It supports multiple formats, including EPUB and PDF. It provides audiobook functionality through TTS models and supports other AI models for assisted reading. In addition, it has local book management capabilities, allowing users to easily manage book storage on NAS. For its backend service deployment, refer to [omnigam-server](https://github.com/nexptr/omnigram-server). Or check the [official project documentation](https://omnigram.nexptr.com/).

## Features

- [X] Supports iOS and Android for EPUB ebook reading
- [X] Supports TTS text-to-speech, allows custom TTS engines
- [X] Supports local book management (NAS), including searching, reading, listening, notes, favorites, downloading, deleting books, settings, etc.
- [X] Supports conversational assistant with Markdown support, code block highlighting, conversation settings
- [X] Books support TTS reading using models
- [ ] Supports PDF, documents and other NAS content services management
- [ ] Supports Web, Windows, Linux, Mac

## Official Documentation

You can find the official documentation (including installation manuals) at <https://omnigram.nexptr.com/>.

## Examples

TODO

## For Dev

This project uses a three-way repository including:

- [riverpod](https://docs-v2.riverpod.dev/docs)
- [objectbox](https://docs.objectbox.io/getting-started)

### build

```bash

git clone github.com/nexptr/omnigram.git
cd omnigram
fultter clean && dart run build_runner build

make
```
