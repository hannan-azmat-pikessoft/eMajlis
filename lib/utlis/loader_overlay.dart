import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoaderOverlay {
  BuildContext _context;

  void hide() {
    Navigator.of(_context).pop();
  }

  void show() {
    showDialog(
      barrierDismissible: false,
      context: _context,
      builder: (BuildContext context) {
        return _FullScreenLoader();
      },
    );
  }

  Future<T> during<T>(Future<T> future) {
    show();
    return future.whenComplete(() => hide());
  }

  LoaderOverlay._create(this._context);

  factory LoaderOverlay.of(BuildContext context) {
    return LoaderOverlay._create(context);
  }
}

class _FullScreenLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.5),
      ),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
