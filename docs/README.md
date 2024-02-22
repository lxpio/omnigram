# Omnigram Documentation

Read more [here](../README.md)

This website is built using [Docusaurus 3](https://docusaurus.io/), a modern static website generator.

## Installation

```console
npm install
```

## Structure

All documentation is stored in the `docs` directory. The stable/outdated docs is stored at `versioned_docs/version-X.X`.

## Local Development

```console
npm run start
```

This command starts a local development server and opens up a browser window. Most changes are reflected live without having to restart the server.

## Build

```console
# "build": "pnpm build:meta && pnpm build:docs",
npm build
```

This command generates static content into the `build` directory and can be served using any static contents hosting service.
