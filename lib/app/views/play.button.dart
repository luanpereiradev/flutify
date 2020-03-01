import 'package:flutter/material.dart';

class PlayButton extends StatefulWidget {
  final bool state;
  final Function callback;

  PlayButton(this.state, this.callback);

  @override
  _PlayButtonState createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {

  bool _highlight = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(

      onHighlightChanged: (status) {
        setState(() {
          _highlight = status;
        });
      },
      onTap: (){
        widget.callback();
      },
      child: CircleAvatar(
        radius: 36,
        backgroundColor: _highlight ? Colors.grey : Colors.white,
        child: Icon(
          widget.state ? Icons.pause : Icons.play_arrow,
          size: 36,
          color: Colors.black,
        ),
      ),
    );
  }

}
