part of 'get_product_pagination_bloc.dart';

@immutable
abstract class GetProductPaginationState {}

class GetProductPaginationInitial extends GetProductPaginationState {}

class GetProductPaginationLoading extends GetProductPaginationState {}

enum Status {
  initial,
  loading,
  loadingMore,
  moreLoaded,
  success,
  error,
}

// ignore: must_be_immutable
class GetProductPaginationSuccess extends GetProductPaginationState {
  Status? status;
  List<Product>? products;
  int? page = 0;
  int? size = 10;
  bool? hasMore = true;

  GetProductPaginationSuccess({
    this.status,
    this.products,
    this.page,
    this.size,
    this.hasMore,
  });


  @override
  String toString() {
    return 'ProductSuccess(products: $products, page: $page, size: $size, hasMore: $hasMore)';
  }

  GetProductPaginationSuccess copyWith({
    Status? status,
    List<Product>? products,
    int? page,
    int? size,
    bool? hasMore,
  }) {
    return GetProductPaginationSuccess(
      status: status ?? this.status,
      products: products ?? this.products,
      page: page ?? this.page,
      size: size ?? this.size,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
