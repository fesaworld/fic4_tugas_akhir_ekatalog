part of 'get_product_pagination_bloc.dart';

@immutable
abstract class GetProductPaginationEvent {}

class GetGetProductPaginationEvent extends GetProductPaginationEvent {}
class LoadMoreProductEvent extends GetProductPaginationEvent {}
