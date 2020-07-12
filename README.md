<div style="text-align: center">
  <img src="assets/images/icon.png" height=200 width=200>
</div>

![FluterCI](https://github.com/Lutetium-Vanadium/Music-Flutter/workflows/FlutterCI/badge.svg)

# Music

Download and play songs from your phone.

> This app is still under developement so some things may not work properly

If you have any issues or suggestions, feel free to [open a pull request](https://github.com/Lutetium-Vanadium/music-flutter/pulls) or [file an issue](https://github.com/Lutetium-Vanadium/music-flutter/issues)

## Installation

### Build Dependecies

First [install flutter](https://flutter.dev/docs/get-started/install). After that run

```sh
flutter pub get
```

This will install dependecies.

### Api keys

The app requires 2 API Keys to function:

- [A napster API Key](https://developer.napster.com/api/v2.2#getting-started)
- [A Youtube data API Key](https://developers.google.com/youtube/v3/getting-started)

Once you have those created, you can move onto running the app.
You will need to enter the api keys directly in the app.

### Testing

To run the tests, written for the app, run:

```sh
flutter test
```

### Running without a regular installation

If you wish to test the app to see if it works, connect a device or run an emulator. To start the `profile` mode app (runs faster than `debug` mode, but doesn't have the developer functionalities), run:

```sh
flutter run --profile
```

### Installation

> TODO

For reference see flutter's [android](https://flutter.dev/docs/deployment/android) and [ios](https://flutter.dev/docs/deployment/ios) release documentaion.

## Issues

### IOS

The app was built with an android testing device and so it may no function fully as intended in ios. In general the UI will look and work the same, but special things like notifications may not. For example, android allows for notifications to show while the app is open, but for ios thats not true.
