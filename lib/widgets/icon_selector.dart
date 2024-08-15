// crearé un widget vacio que sea una ventana blanca para iniciar con un texto que diga "icon selector"

import 'package:flutter/material.dart';

class IconSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      padding: EdgeInsets.all(20),
      // añado bordes redondeados
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 0.0),
            blurRadius: 10.0,
            spreadRadius: 0.0,
          ),
        ],
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          'Icon Selector',
          style: TextStyle(
            color: Colors.black, fontSize: 20,
            // elimino lo subrayado
            decoration: TextDecoration.none,
            // quito la negrita
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
