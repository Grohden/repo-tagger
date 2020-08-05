# Repo tagger

Front end application for github tagger

## Getting Started

This project is written in flutter using dio and dart's retrofit.

## Development


### Requirements

* [flutter](https://flutter.dev/docs/get-started/install)
    * You need to [enable the web support](https://flutter.dev/docs/get-started/web).
* Repo tagger backend

Note: Although it's possible to run on android and/or IOS, the app has been designed 
for web and will probably not have a good layout on mobile devices.

### Run

Generate needed sources:
```shell script
flutter packages pub run build_runner build
flutter run -d chrome
```

Note: the app expects the backend to be at localhost 8080. You can manually change this
in the `main.dart`, for now a env variable is not supported. 
