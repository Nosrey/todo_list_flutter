import 'package:flutter/material.dart';
// importo el archivo que contiene las rutas de las imágenes
import '../constants/icons.dart';
import '../constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IconSelector extends StatelessWidget {
  final Function onPressed;
  final Function saveProfileIcon;
  String icon = '';

// una funcion que trae del shared preferences el icono seleccionado llamado "profileIcon"
  void _profileIconLoader() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String profileIcon = prefs.getString('profileIcon') ?? imagePaths[0];
    icon = profileIcon;
  }

  void _iconSelectorHandler(String icon) {
    saveProfileIcon(icon);
    onPressed();
  }

  IconSelector(
      {required this.onPressed,
      required this.icon,
      required this.saveProfileIcon}) {
    _profileIconLoader();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: 500,
        ),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                // borde gris abajo solo
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text(
                      'Elige un Icono',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: tdBlack,
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tdRed,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        onPressed();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GridView.builder(
                    shrinkWrap:
                        true, // Ajusta el tamaño del GridView a su contenido
                    physics:
                        NeverScrollableScrollPhysics(), // Desactiva el scroll de GridView
                    itemCount: imagePaths.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Número de columnas en el grid
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 5,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _iconSelectorHandler(imagePaths[index]);
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: icon == imagePaths[index]
                                ? const Color.fromARGB(255, 255, 232, 27)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Image.asset(
                            imagePaths[index],
                            width: 50,
                            height: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
