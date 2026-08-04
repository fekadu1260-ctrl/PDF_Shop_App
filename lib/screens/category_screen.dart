import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {

  final CategoryService service = CategoryService();

  late Future<List<CategoryModel>> categories;


  @override
  void initState() {
    super.initState();
    categories = service.fetchCategories();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Categories"),
      ),


      body: FutureBuilder<List<CategoryModel>>(

        future: categories,

        builder: (context, snapshot){

          if(snapshot.connectionState ==
              ConnectionState.waiting){

            return const Center(
              child: CircularProgressIndicator(),
            );

          }


          if(!snapshot.hasData){

            return const Center(
              child: Text("No categories"),
            );

          }


          return ListView.builder(

            itemCount: snapshot.data!.length,

            itemBuilder: (context,index){

              final category =
              snapshot.data![index];


              return ListTile(

                leading:
                const Icon(Icons.category),

                title:
                Text(category.name),

              );

            },

          );


        },

      ),

    );

  }

}
