# Code Structure

## Directories

- ### `assets/fonts`

  Contains the required ttf for some custom icons.

- ### `assets/icons`

  Contains the app icon. If you wish to change the app icon, replace [`icon.png`](../assets/icons/icon.png) with the icon you want, and then run:

  ```sh
  flutter pub run flutter_launcher_icons:main
  ```

  This will generate the required icons for both iOS and android.

  > This will only change the icon which is shown on your home screen or app drawer. If you wish to change the icon shown in app, go [here](#assetsimages).

- ### `assets/images`

  This contains static images used within the app. If you want to change the icon shown within the app, replace [`icon.png`](../assets/images/icon.png) with the icon you want.

  > This won't change the icon shown on the splash screen, for that you need to go to [`android/app/src/main/res`](../android/app/src/main/res) and replace `launch_image.png` within all the `mipmap` directories with an image of the correct size.

- ### `assets/fonts`

  Contains the required ttf file for some custom icons.

- ### `lib/bloc`

  The app follows the [BLoC pattern](https://bloclibrary.dev/#/) for global state management. <br>
  There are 2 blocs:

  1. QueueBloc - This handles playing songs, and things related to it
  2. DataBloc - This handles general database updates and changes, including downloading songs and custom album editing and creation.

- ### `lib/global_providers`

  This contains some widgets which allow functionality to be accessed throughout the tree. For example, the `DatabaseProvider` allows the `DatabaseFunctions` instance to be accesed throughout, so that any widget can query the database without the database needing to be passed throughout the tree.

- ### `lib/helpers`

  It contains various helper functions. For example, [`generateSubtitle`](../lib/helpers/generateSubtitle.dart), while being a very simple function, is used in many places. It allows for a cleaner function call instead of having it everywhere. This also means, if the subtitle format needs to be changed, it needs to be changed in only one place, instead of throughout the project.

- ### `lib/models`

  This has all the classes and structured data used throughtout the app.

- ### `lib/routes`

  This is where most of the UI code is present.

- ### `test`

  Has all the tests written for the app.

## routes

All the relavent pages and pverlays for these are givin within the `lib/routes` directory.

- ### `/`

  The main page, it opens to this and you can see songs, albums and artists.

- ### `/add-to-album`

  This shows an overlay, which allows you to select an album, to which a song will be added.

- ### `/album`

  Shows the songs for one Custom Album or one Album.

- ### `/artist`

  Shows the songs for one Artist.

- ### `/liked`

  This shows all the liked songs.

- ### `/player`

  This shows the controls for the playing songs, including the current playing song and the queue.

- ### `/register-api-keys`

  This is shown when the app is first installed, where user can register the API Keys.

- ### `/search`

  This is the page which shows the search results for downloading songs.

- ### `/select-songs`

  When creating an album or editing it, this overlay will allow them to select the song.

- ### `/sync-status`

  After initial API Key registration, if Firebase keys are given, they will be redirected to this page, while initial set up happens.
