<p align="center">
    <img width="150pixels" src="https://github.com/schiller-sql/chess4player/assets/65500763/e22b0430-8d61-4eb2-9596-dcfb973d8f54">
</p>

<h1 align="center">chess4player</h1>
<h3 align="center">An open source multiplayer chess game <br> for up to 4 players on windows, macOS and GNU/linux</h3>

<br>

<p align="center">
    Written in the frontend with <a Dart and href="https://flutter.dev">Flutter</a> for desktop using <a href="https://pub.dev/packages/bloc">bloc</a> as the state managment,<br> 
    as well <a href="https://go.dev/">go</a> in the backend using <a href="https://github.com/gorilla#gorilla-toolkit">gorilla</a> for websocket connections
</p>

<p float="center">
  <img src="https://github.com/schiller-sql/chess4player/assets/65500763/70706513-ffa0-482e-b7d6-e91f15058240" width="32.5%">
  <img src="https://github.com/schiller-sql/chess4player/assets/65500763/3c2e658d-0c06-4dd6-9c5f-8ed2e5d26444" width="32.5%">
  <img src="https://github.com/schiller-sql/chess4player/assets/65500763/b0f60d51-d873-4d2d-94df-fe29492cc1c8" width="32.5%">
</p>

<p float="center">
  <img src="https://github.com/schiller-sql/chess4player/assets/65500763/2da5382f-7b80-4de8-85a5-7aabd61db46e" width="24%">
  <img src="https://github.com/schiller-sql/chess4player/assets/65500763/e1cbfca7-15c5-4785-a255-694113cdced7" width="24%">
  <img src="https://github.com/schiller-sql/chess4player/assets/65500763/f20db44c-9819-4110-bdd4-430e0743049f" width="24%">
  <img src="https://github.com/schiller-sql/chess4player/assets/65500763/10cecd92-841e-4510-a329-b00f290443a9" width="24%">  
</p>

<br>

# Setup

## Flutter client

[Install flutter for your respective operating system](https://docs.flutter.dev/get-started/install)
and configure/install necessary components as per the flutter website,
which are necessary for the development of desktop apps.

Make sure flutter is in your `PATH`.

Navigate to `client/flutter` and run `flutter pub get`.

In the `client/flutter` directory create a new textfile `.env`.
This must contain the default URI/URL the client will connect to in the format:
```sh
URI='[URI]'
```
`[URI]` should be replaced by the websocket URL/URI of the chess4player server, for example:
```sh
URI='ws:://localhost:8080'
```

## Server

[Install go](https://go.dev/doc/install) and have it added to your path.

Navigate to the `server` directory and run `go mod download`.

# Running

## Flutter client

In the `client/flutter` directory run `flutter run -d [device]`
where `[device]` is substituted by either `windows`, `macos`, or `linux`,
depending on your platform.

## Go server

In the `server` directory run `PORT=[port] go run main.go`,
where `[port]` is substituted by the port you want to run the server on,
for example `8080`.

# Running/compiling for production

## Flutter client

In the `client/flutter` directory run `flutter build [device] --release`
where `[device]` is substituted by either `windows`, `macos`, or `linux`,
depending on your platform.

### macOS

The resulting `chess44.app` can be found in `client/flutter/build/macos/Build/Products/Release`.

### windows

Using [inno setup](https://jrsoftware.org/isinfo.php)
to execute `client/flutter/installers/default_windows_installation.iss`
for an installer, which is found in `client/flutter/installers/chess44.exe`.

## Server

In the `server` directory run `go build main.go`.

Now execute the resulting executable,
with the `PORT` environment variable, for example (for macos/linux):
```sh
PORT=8080 ./main
```
