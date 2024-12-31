import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:vigenesiass/constant/const.dart';
import 'package:vigenesiass/screens/edit_page.dart';
import 'package:vigenesiass/screens/signin_screen.dart';

import '../Models/Motivasi_Model.dart';

class MainScreens extends StatefulWidget {
  final String? nama;
  final String? iduser;

  const MainScreens({super.key, this.nama, this.iduser});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreens> {
  String baseurl = url;

  String? id;
  var dio = Dio();
  TextEditingController titleController = TextEditingController();

  Future<dynamic> sendMotivasi(String Motivasi) async {
    Map<String, dynamic> body = {
      "isi_motivasi": Motivasi,
      "iduser": widget.iduser ?? ''
    };

    try {
      final response = await dio.post("$baseurl/api/dev/POSTmotivasi",
          data: body,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            //validateStatus: (status) => true,
          ));

      print("Respon -> ${response.data} + ${response.statusCode}");
      return response;
    } catch (e) {
      print("error di -> $e");
    }
  }

  List<MotivasiModel> listproduk = [];

  Future<List<MotivasiModel>> getData() async {
    var response = await dio.get('$baseurl/api/Get_motivasi/');

    print(" ${response.data}");
    if (response.statusCode == 200) {
      var getUserData = response.data as List;
      var listUsers =
      getUserData.map((i) => MotivasiModel.fromJson(i)).toList();
      return listUsers;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<dynamic> deletePost(String id) async {
    dynamic data = {
      "id": id,
    };
    var response = await dio.delete('$baseurl/api/dev/DELETEmotivasi',
        data: data,
        options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: {"Content-type": "application/json"}));
    print("${response.data}");
    var resbody = jsonDecode(response.data);
    return resbody;
  }

  Future<void> _getData() async {
    setState(() {
      _getData();
    });
  }

  TextEditingController isiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Hallo ${widget.nama}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => const SignInScreen(),
                              ),
                            );
                          },
                          child: const Icon(Icons.logout),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FormBuilderTextField(
                      controller: isiController,
                      name: "isi_motivasi",
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.only(left: 10),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () async {
                            await sendMotivasi(isiController.text.toString())
                                .then((value) => {
                              if (value != null)
                                {
                                  Flushbar(
                                    message: "Berhasil Submit",
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: Colors.greenAccent,
                                    flushbarPosition:
                                    FlushbarPosition.TOP,
                                  ).show(context)
                                },
                              _getData(),
                              print("Sukses"),
                            });
                          },
                          child: const Text("Submit")),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    TextButton(
                        onPressed: () {
                          _getData();
                        },
                        child: const Icon(Icons.refresh)),
                    FutureBuilder(
                        future: getData(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<MotivasiModel>> snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: [
                                for (var item in snapshot.data!)
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: [
                                        //Expanded(
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(item.isiMotivasi.toString()),
                                            Row(
                                              children: [
                                                TextButton(
                                                  child: const Icon(Icons.settings),
                                                  onPressed: () {
                                                    //String id;
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (BuildContext
                                                          context) =>
                                                              EditPage(
                                                                  id: item.id,
                                                                  isiMotivasi: item
                                                                      .isiMotivasi),
                                                        ));
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Icon(Icons.delete),
                                                  onPressed: () {
                                                    deletePost(item.id!)
                                                        .then((value) => {
                                                      if (value != null)
                                                        {
                                                          Flushbar(
                                                            message:
                                                            "Berhasil Delete",
                                                            duration: const Duration(
                                                                seconds:
                                                                2),
                                                            backgroundColor:
                                                            Colors
                                                                .redAccent,
                                                            flushbarPosition:
                                                            FlushbarPosition
                                                                .TOP,
                                                          ).show(
                                                              context)
                                                        }
                                                    });
                                                    _getData();
                                                  },
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        //),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data!.isEmpty) {
                            return const Text("No Data");
                          } else {
                            return const CircularProgressIndicator();
                          }
                        })
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
