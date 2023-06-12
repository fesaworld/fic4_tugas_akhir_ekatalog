import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/product/create_product/create_product_bloc.dart';
import '../../bloc/product/get_all_product/get_all_product_bloc.dart';
import '../../bloc/product/get_product_pagination/get_product_pagination_bloc.dart';
import '../../bloc/product/update_product/update_product_bloc.dart';
import '../../bloc/user/profile/profile_bloc.dart';
import '../../data/localsources/auth_local_storage.dart';
import '../../data/models/product.dart';
import '../../data/models/request/product_model.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = ScrollController();
  List<Product> products = [];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  TextEditingController titleUpdateController = TextEditingController();
  TextEditingController descriptionUpdateController = TextEditingController();
  TextEditingController priceUpdateController = TextEditingController();
  final formUpdateKey = GlobalKey<FormState>();

  @override
  void initState() {
    context.read<ProfileBloc>().add(GetProfileEvent());
    context.read<GetAllProductBloc>().add(DoGetAllProductEvent());
    super.initState();

    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        context.read<GetProductPaginationBloc>().add(LoadMoreProductEvent());
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    formKey.currentState?.dispose();
    formUpdateKey.currentState?.dispose();
  }

  String? validateTitle(String title) {
    if (title.isEmpty) {
      return "Title cannot be empty";
    }
    return null;
  }

  String? validatePrice(String price) {
    if (price.isEmpty) {
      return "Price cannot be empty";
    } else if (price == '0') {
      return "Price minimum 1";
    }
    return null;
  }

  String? validateDescription(String desc) {
    if (desc.isEmpty) {
      return "Description cannot be empty";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange.shade50,
        toolbarHeight: 70,
        title:
            BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is ProfileLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Welcome, ${state.profile.name}',
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w700),
                ),
                Text(
                  state.profile.email ?? '',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w400),
                )
              ],
            );
          }
          return Container();
        }),
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
      body: RefreshIndicator(
          onRefresh: () async {
            context
                .read<GetProductPaginationBloc>()
                .add(GetGetProductPaginationEvent());
          },
          child: BlocListener<GetProductPaginationBloc,
              GetProductPaginationSuccess>(
            listener: (context, state) {
              if (state.status == Status.loadingMore) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Loading more...')));
              }
              if (state.status == Status.moreLoaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Success get more..', style: TextStyle(color: Colors.black)), backgroundColor: Colors.green,));
              }
            },
            child: BlocBuilder<GetProductPaginationBloc,
                GetProductPaginationSuccess>(
              builder: (context, state) {
                if (state.status == Status.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state.status == Status.success) {
                  products = state.products!;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                }
                return ListView.builder(
                    controller: controller,
                    itemCount: state.products?.length,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    itemBuilder: ((context, index) {
                      final product = state.products?.toList()[index];
                      return InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return _buildUpdateProduct(
                                  id: product?.id ?? 0,
                                  title: product?.title ?? '',
                                  price: product?.price ?? 0,
                                  description: product?.description ?? '',
                                );
                              });
                        },
                        child: Card(
                          elevation: 2,
                          shadowColor: Colors.grey,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 7),
                          child: Column(
                            children: [
                              Container(
                                  height: MediaQuery.of(context).size.width,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        topLeft: Radius.circular(10),
                                      )),
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          topLeft: Radius.circular(10)),
                                      child: Image.network(
                                        product?.images[0] ?? '',
                                        fit: BoxFit.fill,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          Icons.error_outline,
                                          size: 50,
                                        ),
                                      ))),
                              ListTile(
                                leading: CircleAvatar(
                                    radius: 25, child: Text('${product?.id}')),
                                title: Text(product?.title ?? '-'),
                                subtitle: Text(product?.description ?? '-'),
                                trailing: Text('Rp.${product?.price}'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }));
              },
            ),
          )),

      // body: Column(
      //   children: [
      //     Expanded(child: BlocBuilder<GetAllProductBloc, GetAllProductState>(
      //       builder: (context, state) {
      //         if (state is GetAllProductLoading) {
      //           return const Center(
      //             child: CircularProgressIndicator(),
      //           );
      //         }
      //         if (state is GetALlProductLoaded) {
      //           return ListView.builder(
      //               itemCount: state.listProduct.length,
      //               padding: const EdgeInsets.symmetric(vertical: 5),
      //               itemBuilder: ((context, index) {
      //                 final product =
      //                     state.listProduct.reversed.toList()[index];
      //                 return InkWell(
      //                   onTap: () {
      //                     showDialog(
      //                         context: context,
      //                         builder: (context) {
      //                           return _buildUpdateProduct(
      //                             id: product.id!,
      //                             title: product.title ?? '',
      //                             price: product.price!,
      //                             description: product.description ?? '',
      //                           );
      //                         });
      //                   },
      //                   child: Card(
      //                     elevation: 2,
      //                     shadowColor: Colors.grey,
      //                     margin: const EdgeInsets.symmetric(
      //                         horizontal: 20, vertical: 7),
      //                     child: Column(
      //                       children: [
      //                         Container(
      //                             height: MediaQuery.of(context).size.width,
      //                             width: MediaQuery.of(context).size.width,
      //                             decoration: const BoxDecoration(
      //                               color: Colors.grey,
      //                               borderRadius: BorderRadius.only(
      //                                   topRight: Radius.circular(10),
      //                                   topLeft: Radius.circular(10),
      //                               )
      //                             ),
      //                             child: ClipRRect(
      //                                 borderRadius: const BorderRadius.only(
      //                                     topRight: Radius.circular(10),
      //                                     topLeft: Radius.circular(10)),
      //                                 child: Image.network(
      //                                   product.images![0],
      //                                   fit: BoxFit.fill,
      //                                   loadingBuilder: (BuildContext context,
      //                                       Widget child,
      //                                       ImageChunkEvent? loadingProgress) {
      //                                     if (loadingProgress == null) {
      //                                       return child;
      //                                     }
      //                                     return Center(
      //                                       child: CircularProgressIndicator(
      //                                         value: loadingProgress
      //                                                     .expectedTotalBytes !=
      //                                                 null
      //                                             ? loadingProgress
      //                                                     .cumulativeBytesLoaded /
      //                                                 loadingProgress
      //                                                     .expectedTotalBytes!
      //                                             : null,
      //                                       ),
      //                                     );
      //                                   },
      //                                   errorBuilder: (context, error,
      //                                           stackTrace) =>
      //                                       const Icon(Icons.error_outline, size: 50,),
      //                                 ))
      //                         ),
      //                         ListTile(
      //                           leading: CircleAvatar(
      //                               radius: 25, child: Text('${product.id}')),
      //                           title: Text(product.title ?? '-'),
      //                           subtitle: Text(product.description ?? '-'),
      //                           trailing: Text('Rp.${product.price}'),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 );
      //               }));
      //         }
      //         return const Text('no data');
      //       },
      //     ))
      //   ],
      // ),

      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add Product'),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          validator: (title) => validateTitle(title!),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              hintText: 'Insert title..',
                              hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.3))),
                          controller: titleController,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          validator: (price) => validatePrice(price!),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              hintText: 'Insert price..',
                              hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.3))),
                          controller: priceController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          maxLines: 3,
                          validator: (desc) => validateDescription(desc!),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              hintText: 'Insert description..',
                              hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.3))),
                          controller: descriptionController,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    BlocListener<CreateProductBloc, CreateProductState>(
                      listener: (context, state) {
                        if (state is CreateProductLoaded) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Create: ${state.productResponseModel.id}')));
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
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green)),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final productModel = ProductModel(
                                  title: titleController.text,
                                  price: int.parse(priceController.text),
                                  description: descriptionController.text,
                                );

                                context.read<CreateProductBloc>().add(
                                    DoCreateProductEvent(
                                        productModel: productModel));
                              }
                            },
                            child: const Text('Save',
                                style: TextStyle(color: Colors.white)),
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

  Widget _buildUpdateProduct({
    required int id,
    required String title,
    required int price,
    required String description,
  }) {
    titleUpdateController.text = title;
    priceUpdateController.text = price.toString();
    descriptionUpdateController.text = description;

    return AlertDialog(
      title: const Text('Edit Product'),
      content: Form(
        key: formUpdateKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              validator: (title) => validateTitle(title!),
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  hintText: 'Insert title..',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.3))),
              controller: titleUpdateController,
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              validator: (price) => validatePrice(price!),
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  hintText: 'Insert price..',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.3))),
              controller: priceUpdateController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              maxLines: 3,
              validator: (desc) => validateDescription(desc!),
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  hintText: 'Insert description..',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.3))),
              controller: descriptionUpdateController,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red)),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        BlocListener<UpdateProductBloc, UpdateProductState>(
          listener: (context, state) {
            if (state is UpdateProductLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Update: ${state.productResponseModel.id}')));
              Navigator.pop(context);
              context.read<GetAllProductBloc>().add(DoGetAllProductEvent());
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
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green)),
                onPressed: () {
                  if (formUpdateKey.currentState!.validate()) {
                    final productModel = ProductModel(
                      title: titleUpdateController.text,
                      price: int.parse(priceUpdateController.text),
                      description: descriptionUpdateController.text,
                    );

                    context.read<UpdateProductBloc>().add(DoUpdateProductEvent(
                        productModel: productModel, id: id));
                  }
                },
                child:
                    const Text('Save', style: TextStyle(color: Colors.white)),
              );
            },
          ),
        ),
      ],
    );
  }
}
