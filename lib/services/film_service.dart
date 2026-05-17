import 'package:chopper/chopper.dart';

part 'film_service.chopper.dart';

@ChopperApi(baseUrl: '/film')
abstract interface class FilmService extends ChopperService {
  @GET()
  Future<Response<List<dynamic>>> getFilms();

  @GET(path: '/{id}')
  Future<Response<dynamic>> getFilmById(@Path('id') String id);

  @POST()
  Future<Response<dynamic>> createFilm(@Body() Map<String, dynamic> body);

  @PUT(path: '/{id}')
  Future<Response<dynamic>> updateFilm(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE(path: '/{id}')
  Future<Response<dynamic>> deleteFilm(@Path('id') String id);

  static FilmService create([ChopperClient? client]) => _$FilmService(client);
}
