import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/product.dart';

part 'get_product_pagination_event.dart';
part 'get_product_pagination_state.dart';

class GetProductPaginationBloc extends Bloc<GetProductPaginationEvent, GetProductPaginationSuccess> {
  GetProductPaginationBloc() : super(GetProductPaginationSuccess(status: Status.initial)) {

    on<GetGetProductPaginationEvent>((event, emit) async {
      emit(state.copyWith(status: Status.loading));
      final response = await http.get(
        Uri.parse('https://api.escuelajs.co/api/v1/products?offset=0&limit=10'),
        headers: {
          "Content-Type": "application/json",
        },
      );
      final products = productFromJson(response.body);
      emit(
        state.copyWith(
          size: 10,
          status: Status.success,
          products: products,
          page: 1,
          hasMore: products.length > 10,
        ),
      );
    });

    on<LoadMoreProductEvent>((event, emit) async {
      emit(state.copyWith(status: Status.loadingMore));
      // print(successState.toString());
      final response = await http.get(
        Uri.parse(
            'https://api.escuelajs.co/api/v1/products?offset=${state.page! * state.size!}&limit=${state.size!}'),
        headers: {
          "Content-Type": "application/json",
        },
      );
      final products = productFromJson(response.body);
      emit(
        state.copyWith(
          products: state.products! + products,
          page: state.page! + 1,
          hasMore: products.length > state.size!,
          status: Status.moreLoaded,
        ),
      );
    });
  }
}
