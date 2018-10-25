import 'dart:io';
import 'dart:convert';
import 'dart:math';

import "package:stream_channel/stream_channel.dart";

hybridMain(StreamChannel channel) async {
  int port = 3000 + Random().nextInt(1000);
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  channel.sink.add('${server.address.address}:${server.port}');
  await for (HttpRequest request in server) {
    request.response.headers
      ..add('Access-Control-Allow-Origin', '*')
      ..add('Access-Control-Allow-Methods',
          'GET, POST, PUT, PATCH, DELETE, OPTIONS')
      ..add('Access-Control-Allow-Headers',
          'Origin, X-Requested-With, Content-Type, Accept');

    if (request.method != 'OPTIONS') {
      if (request.headers.value('X-Requested-With') != 'XMLHttpRequest') {
        request.response.statusCode = HttpStatus.badRequest;
        request.response.write('Not AJAX-request');
      } else {
        switch (request.requestedUri.pathSegments.first) {
          case 'unauthorized':
            request.response.statusCode = HttpStatus.unauthorized;
            request.response.reasonPhrase =
                '${HttpStatus.unauthorized}-Unauthorized';
            break;
          case 'servererror':
            request.response.statusCode = HttpStatus.internalServerError;
            request.response.reasonPhrase =
                '${HttpStatus.internalServerError}-Internal Server Error';
            break;
          case 'echo-resource':
            switch (request.method) {
              case 'GET':
              case 'DELETE':
                if (request.uri.queryParameters.isEmpty &&
                    request.uri.pathSegments.length > 1) {
                  request.response.write(json.encode({'id': 1}));
                } else {
                  request.response.write(json.encode([
                    {'id': 1},
                    {'id': 2}
                  ]));
                }
                break;
              case 'POST':
              case 'PUT':
              case 'PATCH':
                String body = await request.transform(utf8.decoder).join();
                request.response.write(body);
                break;
            }
            break;
          default:
            switch (request.method) {
              case 'GET':
                request.response.write(json.encode(
                    {'method': 'GET', 'uri': '${request.requestedUri}'}));
                break;
              case 'POST':
                String body = await request.transform(utf8.decoder).join();
                request.response.write(json.encode({
                  'method': 'POST',
                  'uri': '${request.requestedUri}',
                  'body': json.decode(body)
                }));
                break;
              case 'PUT':
                String body = await request.transform(utf8.decoder).join();
                request.response.write(json.encode({
                  'method': 'PUT',
                  'uri': '${request.requestedUri}',
                  'body': json.decode(body)
                }));
                break;
              case 'PATCH':
                String body = await request.transform(utf8.decoder).join();
                request.response.write(json.encode({
                  'method': 'PATCH',
                  'uri': '${request.requestedUri}',
                  'body': json.decode(body)
                }));
                break;
              case 'DELETE':
                request.response.write(json.encode(
                    {'method': 'DELETE', 'uri': '${request.requestedUri}'}));
                break;
            }
        }
      }
    }
    request.response.close();
  }
}
