import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future getData() async {
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot qn = await firestore.collection("Countries").get();
    //qn = allData as QuerySnapshot<Object?>;
    return qn.docs;
  }

  CollectionReference recipes =
      FirebaseFirestore.instance.collection('Countries');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Display',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: recipes.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['name']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // Press this button to edit a single product
                          IconButton(
                            onPressed: () {
                              _CreateOrUpdate(documentSnapshot);
                            },
                            icon: Icon(Icons.edit),
                          ),
                          // This icon button is used to delete a single product
                          IconButton(
                            onPressed: () {
                              _deleteProduct(documentSnapshot.id);
                            },
                            icon: Icon(Icons.delete),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _CreateOrUpdate(),
        child: const Icon(Icons.add),
      ),
      // Add new product
    );
  }

  TextEditingController _nameController = TextEditingController();

  Future<void> _CreateOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';

    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(top: 120, left: 20, right: 20),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final String? name = _nameController.text;
                    if (name != null) {
                      if (action == 'create') {
                        await recipes.add({"name": name});
                      }
                      if (action == 'update') {
                        await recipes
                            .doc(documentSnapshot!.id)
                            .update({"name": name});
                      }
                      // Clear the text fields
                      _nameController.text = '';

                      // Hide the botton sheet
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                ),
              ],
            ),
          );
        });
  }

  // deleteing a product by id
  Future<void> _deleteProduct(String productId) async {
    await recipes.doc(productId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("You have successfully deleted a product")));
  }
}
