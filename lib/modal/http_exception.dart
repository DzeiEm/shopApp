

class HttpException implements Exception{
  final String message;
  HttpException(this.message);

  @override
  String toString() {

    return message;
  
    // return super.toString(); sitas grazins instance of httpException
  }

}