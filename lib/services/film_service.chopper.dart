// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'film_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$FilmService extends FilmService {
  _$FilmService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = FilmService;

  @override
  Future<Response<List<dynamic>>> getFilms() {
    final Uri $url = Uri.parse('/film');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<dynamic>, List<dynamic>>($request);
  }

  @override
  Future<Response<dynamic>> getFilmById(String id) {
    final Uri $url = Uri.parse('/film/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createFilm(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/film');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateFilm(
    String id,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/film/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteFilm(String id) {
    final Uri $url = Uri.parse('/film/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
