import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutify/app/views/player.controls.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';

class PlayerView extends StatefulWidget {
  @override
  PlayerViewState createState() => PlayerViewState();
}

class PlayerViewState extends State<PlayerView> {

  List _tracks = [
    {
      "url": "https://d.mp3-music-downloads.com/guWBZB:fsTAsB",
      "artista": "Cartoon, Daniel Levi",
      "nome": "On & On",
      "artwork": "https://i.imgur.com/3f1l5OW.jpg"
    }
  ];

  PaletteGenerator _generator;

  Future<void> _updatePaletteGenerator() async {
    String artwork = _tracks[0]["artwork"];

    _generator = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(artwork, errorListener: () {
      print("deu erro");
    }));

    setState(() {});
  }

  @override
  void initState() {
    // forcar a orientação de tela
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
    _updatePaletteGenerator();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          AnimatedContainer(
            color: _generator == null
                ? Colors.black
                : _generator.vibrantColor == null
                    ? Colors.grey
                    : _generator.vibrantColor.color,
            duration: Duration(milliseconds: 500),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromRGBO(0, 0, 0, 0.1),
                    const Color.fromRGBO(0, 0, 0, 1)
                  ],
                  stops: [
                    0.05,
                    1
                  ]),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return new Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  padding:
                      EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 60),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Tocando da sua biblioteca".toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Spotify_Book",
                            fontSize: 12),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          "Músicas curtidas",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: CachedNetworkImage(
                            imageUrl: _tracks[0]["artwork"],
                          ),
                        ),
                      ),
                      PlayerControlsView(_tracks[0])
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

}
