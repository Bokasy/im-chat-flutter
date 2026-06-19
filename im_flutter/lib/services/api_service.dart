import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:im_flutter/config/api_config.dart';
import 'package:im_flutter/services/storage_service.dart';

class ApiService extends GetxService {
  late Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl + ApiConfig.apiPrefix,
      connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = Get.find<StorageService>().getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) {
        print('API错误: ${error.message}');
        if (error.response?.statusCode == 401) {
          Get.find<StorageService>().removeToken();
          Get.offAllNamed('/login');
        }
        return handler.next(error);
      },
    ));
  }

  // GET请求
  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return _dio.get(path, queryParameters: params);
  }

  // POST请求
  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  // PUT请求
  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  // DELETE请求
  Future<Response> delete(String path, {Map<String, dynamic>? params}) async {
    return _dio.delete(path, queryParameters: params);
  }

  // 文件上传
  Future<Response> uploadFile(String path, String filePath, {String fieldName = 'file'}) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
    });
    return _dio.post(path, data: formData);
  }
}
