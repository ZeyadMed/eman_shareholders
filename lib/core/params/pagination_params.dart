part of 'params.dart';

class PaginationParams extends Equatable{
  final int page;
  final int limit;
  const PaginationParams({required this.limit,required this.page});
  Map<String,dynamic> toJson(){
    return {
      'page':page,
      'limit':limit,
    };
  }
  @override
  List<Object?> get props => [page,limit];
}