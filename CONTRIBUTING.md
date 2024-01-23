# Contribution guide

There are many ways to contribute to this project.
Thanks to everyone who has contributed!
If you have any questions, please contact me at [omnigram@lxpio.com](mailto:omnigram@lxpio.com).


Please follow the [Code of Conduct](https://omnigram.lxpio.com/code-of-conduct).

## Give feedback

The best way to give feedback is to open an issue on GitHub.
Please report any bug you find [here](https://github.com/lxpio/omnigram/issues/new).

If you have a feature that you would like to see added, please open an issue [here](https://github.com/lxpio/omnigram/issues/new?assignees=CodeDoctorDE&labels=enhancement%2Ctriage&template=feature_request.yml&title=%5BFeature+request%5D%3A+).

## Test nightly builds

Nightly builds are not production ready and need to be tested.
Please report any bugs in the github issues section.

TODO
<!-- Read more about it [here](https://omnigram.lxpio.com/nightly). -->

## Write documentation

Documentation is important for users to understand the program and its features.
The documentation is written in markdown, a simple markup language. It can be found in the `docs` folder.

To start, please install [pnpm](https://pnpm.io/installation).

Get started by running:

```bash
cd docs
pnpm install
pnpm start
```

All stable documentation can be found in the `versioned_docs` folder.

Fork the project and create a pull request to add your documentation to the `main` branch.

## Translate

Crowdin is a service that allows you to translate the documentation and the app.
Click [here](https://translate.lxpio.com/omnigram) to see the project and start translating.
If you have a new language to add, please contact me.

## Code

This project is written in [Dart](https://dart.dev/) and was built with [Flutter](https://flutter.dev/).
The app source code can be found in the `./` folder.

Please install the dependencies first:

- libsecret-1-dev
- libjsoncpp-dev

On windows, please install visual studio build tools (or visual studio) and all flutter dependencies. Additionally install the atl library.

To get started, run:

```bash
cd ./
flutter pub get
flutter run
```

All subdirectories are documented in the `/README.md` file.

Fork the project and create a pull request to add your code to the `main` branch.
