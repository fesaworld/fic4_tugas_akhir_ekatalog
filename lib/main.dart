import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/product/create_product/create_product_bloc.dart';
import 'bloc/product/get_all_product/get_all_product_bloc.dart';
import 'bloc/product/get_product_pagination/get_product_pagination_bloc.dart';
import 'bloc/product/update_product/update_product_bloc.dart';
import 'bloc/user/login/login_bloc.dart';
import 'bloc/user/profile/profile_bloc.dart';
import 'bloc/user/register/register_bloc.dart';
import 'data/datasources/auth_datasources.dart';
import 'data/datasources/product_datasources.dart';
import 'presentation/pages/login_page.dart';

void main() {
  Bloc.observer = GroceryBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RegisterBloc(AuthDatasource()),
        ),
        BlocProvider(
          create: (context) => LoginBloc(AuthDatasource()),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(AuthDatasource()),
        ),
        BlocProvider(
          create: (context) => CreateProductBloc(ProductDatasources()),
        ),
        BlocProvider(
          create: (context) => GetAllProductBloc(ProductDatasources()),
        ),
        BlocProvider(
            create: (context) => UpdateProductBloc(ProductDatasources())),
        BlocProvider(
          create: (context) => GetProductPaginationBloc()..add(GetGetProductPaginationEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Catalog-e',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}

class GroceryBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }
}