import 'package:agent_second/providers/export.dart';
import 'package:agent_second/util/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/config.dart';
import 'package:location/location.dart';

String token;

BaseOptions options = BaseOptions(
  baseUrl: config.baseUrl,
  // connectTimeout: 10000,
  // receiveTimeout: 300000,
  headers: <String, String>{
    'X-Requested-With': 'XMLHttpRequest',
    'Accept': 'application/json',
    'authorization': ''
  },
  followRedirects: false,
  validateStatus: (int status) => status < 501,
);

Response<dynamic> response;

Dio dio = Dio(options);
Location location = Location();
double latTosend;
double longTosend;

Future<void> dioDefaults() async {
   location.getLocation().then((LocationData value) {
    latTosend = value.latitude;
    longTosend = value.longitude;
  });

  // dio.options.headers['authorization'] = 'Bearer ${config.token}';
  dio.interceptors
      .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
    // Do something before request is sent
    options.queryParameters.addAll(<String, String>{
      'latitude': latTosend.toString() ?? "0.0",
      'longitude': longTosend.toString() ?? "0.0"
    });
    return options;
    // If you want to resolve the request with some custom data，
    // you can return a `Response` object or return `dio.resolve(data)`.
    // If you want to reject the request with a error message,
    // you can return a `DioError` object or return `dio.reject(errMsg)`
  }, onResponse: (Response<dynamic> response) async {
    print("status code: ${response.statusCode}");
    if (response.statusCode == 200) {
      print("response : ${response.data}");
      //  Fluttertoast.showToast(msg: "response.statusCode ${response.statusCode}  ${response.data}",toastLength: Toast.LENGTH_SHORT);
    } else if (response.statusCode == 401) {
      Fluttertoast.showToast(msg: "Login please");
      getIt<NavigationService>().navigateTo('/login', null);
    }
    return response; // continue
  }, onError: (DioError e) async {
      Fluttertoast.showToast(msg: "Error Happened");
    print(e.message);
    // Do something with response error
    return e; //continue
  }));
}
