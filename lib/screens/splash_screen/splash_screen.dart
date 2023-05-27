import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/router/routes.dart';
import 'package:mobile_app_starter/service/client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<Pokemon>? _pokemonList;

  @override
  void initState() {
    super.initState();
    unawaited(getDate());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('SplashScreen'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_pokemonList != null)
                ..._pokemonList!.map((Pokemon e) => Text(e.name)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onPressed,
          child: const Icon(Icons.arrow_forward),
        ),
      );

  void onPressed() {
    HomeScreenPage().go(context);
  }

  Future<void> getDate() async {
    final List<Pokemon> data = await ClientAPI().getListPokemon();
    setState(() {
      _pokemonList = data;
    });
  }
}
