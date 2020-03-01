import 'dart:async';
import 'dart:math';

import 'package:flutify/app/views/play.button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'custom_track_shape.dart';

class PlayerControlsView extends StatefulWidget {
  final Map trackInfo;

  PlayerControlsView(this.trackInfo);

  @override
  _PlayerControlsViewState createState() => _PlayerControlsViewState();
}

class _PlayerControlsViewState extends State<PlayerControlsView> {

  static const platform = const MethodChannel("flutify/player");

  double _value = 0;
  double _duration = 1;
  bool _isPlaying = false;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    print("DISPOSE CONTROLS");
    _cancelTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.trackInfo["nome"],
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      widget.trackInfo["artista"],
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                ],
              ),
              InkWell(
                child: Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 16, bottom: 2),
            child: SizedBox(
              height: 10,
              child: SliderTheme(
                data: SliderThemeData(
                  trackShape: CustomTrackShape(),
                  trackHeight: 3,
                  thumbColor: Colors.white,
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.0),
                ),
                child: _slider(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              toText(_value,
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              toText(_duration,
                  style: TextStyle(color: Colors.grey, fontSize: 12))
            ],
          ),
          buildControls()
        ],
      ),
    );
  }

  Widget _slider() {
    return Slider(
      min: 0,
      max: _duration,
      value: _value,
      onChanged: (value) async {
        await platform.invokeMethod("seekTo", {"value": value});

        setState(() {
          _value = value;
        });
      },
      onChangeStart: (value) async {
        _cancelTimer();
        await platform.invokeMethod("seekStart");
      },
      onChangeEnd: (value) async {
        await platform.invokeMethod("seekEnd");
        _timer = _createTimer();
      },
    );
  }

  Widget buildControls() {
    //Icons.speaker;
    //Icons.speaker_group;
    //Icons.playlist_play;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        InkWell(
          child: Icon(Icons.shuffle, color: Colors.white, size: 28),
          onTap: () => {},
        ),
        InkWell(
          //padding: EdgeInsets.all(0),
          child: Icon(
            Icons.skip_previous,
            color: Colors.grey,
            size: 32,
          ),
          onTap: () {
            print("Voltar");
          },
        ),
        PlayButton(_isPlaying, () async {
          bool playing = await platform.invokeMethod("playPause");
          if (_isPlaying == playing) return;

          if (_timer == null) {
            _setupTimer();
          } else {
            _cancelTimer();
          }

          setState(() {
            _isPlaying = playing;
          });
        }),
        InkWell(
          //padding: EdgeInsets.all(0),

          child: Icon(
            Icons.skip_next,
            color: Colors.grey,
            size: 32,
          ),
          onTap: () {
            print("Próxima");
          },
        ),
        InkWell(
          //padding: EdgeInsets.all(0),

          child: Icon(
            Icons.repeat,
            color: Colors.white,
            size: 32,
          ),
          onTap: () {
            print("Repetir");
          },
        ),
      ],
    );
  }

  void _initPlayer() async {
    Map args = {"url": widget.trackInfo["url"]};
    _duration = await platform.invokeMethod("playUri", args);
    _timer = _createTimer();
  }

  Timer _createTimer() {
    print("iniciando timer");

    return Timer.periodic(Duration(milliseconds: 300), (timer) async {
      bool isPlaying = await platform.invokeMethod("isPlaying");
      double position = await platform.invokeMethod("getPosition");
      position = min(position, _duration);

      if (position == _duration) {
        isPlaying = false;
        position = 0;
        _cancelTimer();
      }

      setState(() {
        _isPlaying = isPlaying;
        _value = position;
      });
    });
  }

  void _setupTimer() {
    _cancelTimer(); // garantir que não duplicou
    _timer = _createTimer();
  }

  void _cancelTimer() {
    print("cancelado o timer");

    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  Text toText(double v, {TextStyle style}) {
    int tSeconds = (v / 1000).floor();

    int minutos = (tSeconds / 60).floor();
    int segundos = tSeconds % 60;

    return Text(
      "$minutos:" + (segundos < 10 ? "0" : "") + "$segundos",
      style: style,
    );
  }
}
