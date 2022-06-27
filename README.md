# raw_api_server

A Dart library for small and simple socket-based APIs

## Features

* Declarative
* Lightweight
* Extensible
* Determines action via one `uint8` of the request

## Getting started

Start by adding `raw_api_server` to your `pubspec.yaml`: `dart pub add raw_api_server`

## Usage

### Server

The most basic implementation of a server is as follows:

```dart
final server = RawApiServer(
  port: <port>,
  endpoints: [
    ...
  ],
);

await server.start();
```

The `endpoints` parameter expects a list of type `ApiEndpoint`. An endpoint consists of an `id` to identify which action we expect, and a function to handle the request.

```dart
final echoEndpoint = ApiEndpoint(
  id: 0,
  onCall: (socket, args) {
    final argsString = String.fromCharCodes(args);
    socket.write('you said: ${argsString}');
  }
);
```

The endpoint above occupies `id = 0`, so any client requests with `id = 0` will be directed to our `echoEndpoint`. This endpoint has the basic functionality of replying to the client with their own arguments.

**Note:** Endpoints must have unique `id` values.

### Client

A very basic socket wrapper exists for some mild Dart compatibility with `raw_api_server`.

```dart
final client = RawApiClient(
  port: <port>,
  host: <host>,
  onReceive: (socket, data) {
    print('Client received: ${String.fromCharCodes(data)}');
  }
);

await client.connect();
```

We can also make requests using the client. Requests are in the format of a `List<int>` whose first value is an endpoint id. We can build these requests easily using an `ApiRequest`.

```dart
final request = ApiRequest.fromUtf8(id: 0, stringArgs: 'hello!');
```

```dart
await client.sendRequest(request);
```
