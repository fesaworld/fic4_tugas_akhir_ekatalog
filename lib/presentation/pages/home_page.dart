import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/product/create_product/create_product_bloc.dart';
import '../../bloc/product/get_all_product/get_all_product_bloc.dart';
import '../../bloc/product/update_product/update_product_bloc.dart';
import '../../bloc/user/profile/profile_bloc.dart';
import '../../data/localsources/auth_local_storage.dart';
import '../../data/models/request/product_model.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  TextEditingController titleUpdateController = TextEditingController();
  TextEditingController descriptionUpdateController = TextEditingController();
  TextEditingController priceUpdateController = TextEditingController();

  @override
  void initState() {
    context.read<ProfileBloc>().add(GetProfileEvent());
    context.read<GetAllProductBloc>().add(DoGetAllProductEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        elevation: 0,

        backgroundColor: Colors.orange.shade50,
        toolbarHeight: 70,
        title: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is ProfileLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10,),
                  Text('Welcome, ${state.profile.name}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700),),
                  Text(state.profile.email ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),)
                ],
              );
            }
            return Container();
          }
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await AuthLocalStorage().removeToken();

                // ignore: use_build_context_synchronously
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) {
                  return const LoginPage();
                }), (route) => false);
              },
              icon: const Icon(Icons.logout_outlined))
        ],
      ),
      body: Column(
        children: [
          Expanded(child: BlocBuilder<GetAllProductBloc, GetAllProductState>(
            builder: (context, state) {
              if (state is GetAllProductLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (state is GetALlProductLoaded) {
                return ListView.builder(
                    itemCount: state.listProduct.length,
                    itemBuilder: ((context, index) {
                      final product =
                          state.listProduct.reversed.toList()[index];
                      return InkWell(
                        onTap: (){
                          showDialog(
                              context: context,
                              builder: (context) {
                                return _buildUpdateProduct(
                                  id: product.id!,
                                  title: product.title ?? '',
                                  price: product.price!,
                                  description: product.description ?? '',
                                );
                              });
                        },
                        child: Card(
                          child: ListTile(
                            leading:
                                CircleAvatar(child: Text('${product.price}')),
                            title: Text(product.title ?? '-'),
                            subtitle: Text(product.description ?? '-'),
                          ),
                        ),
                      );
                    }));
              }
              return const Text('no data');
            },
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add Product'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Title'),
                        controller: titleController,
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Price'),
                        controller: priceController,
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        maxLines: 3,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        controller: descriptionController,
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    BlocListener<CreateProductBloc, CreateProductState>(
                      listener: (context, state) {
                        if (state is CreateProductLoaded) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('Create: ${state.productResponseModel.id}')));
                          Navigator.pop(context);
                          context
                              .read<GetAllProductBloc>()
                              .add(DoGetAllProductEvent());
                        }
                      },
                      child: BlocBuilder<CreateProductBloc, CreateProductState>(
                        builder: (context, state) {
                          if (state is CreateProductLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ElevatedButton(
                            onPressed: () {
                              final productModel = ProductModel(
                                title: titleController.text,
                                price: int.parse(priceController.text),
                                description: descriptionController.text,
                              );
                              context.read<CreateProductBloc>().add(
                                  DoCreateProductEvent(
                                      productModel: productModel));

                              // context
                              //     .read<GetAllProductBloc>()
                              //     .add(DoGetAllProductEvent());
                            },
                            child: const Text('Save'),
                          );
                        },
                      ),
                    ),
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUpdateProduct({required int id, required String title, required int price, required String description}) {
    titleUpdateController.text = title;
    priceUpdateController.text = price.toString();
    descriptionUpdateController.text = description;

    return AlertDialog(
      title: const Text('Edit Product'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Title'),
            controller: titleUpdateController,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Price'),
            controller: priceUpdateController,
            keyboardType: TextInputType.number,
          ),
          TextField(
            maxLines: 3,
            decoration:
            const InputDecoration(labelText: 'Description'),
            controller: descriptionUpdateController,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        const SizedBox(
          width: 4,
        ),
        BlocListener<UpdateProductBloc, UpdateProductState>(
          listener: (context, state) {
            if (state is UpdateProductLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
              Text('Update: ${state.productResponseModel.id}')));
              Navigator.pop(context);
              context
                  .read<GetAllProductBloc>()
                  .add(DoGetAllProductEvent()
              );
            }
          },
          child: BlocBuilder<UpdateProductBloc, UpdateProductState>(
            builder: (context, state) {
              if (state is UpdateProductLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ElevatedButton(
                onPressed: () {
                  final productModel = ProductModel(
                    title: titleUpdateController.text,
                    price: int.parse(priceUpdateController.text),
                    description: descriptionUpdateController.text,
                  );
                  context.read<UpdateProductBloc>().add(
                    DoUpdateProductEvent(
                        productModel: productModel,
                        id: id)
                  );
                },
                child: const Text('Save'),
              );
            },
          ),
        ),
      ],
    );
  }
}
