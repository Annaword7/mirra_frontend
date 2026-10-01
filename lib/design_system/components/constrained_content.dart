import 'package:flutter/widgets.dart';
import '/design_system/foundations/layout.dart';

/// Центрирует контент страницы и не даёт ему растянуться шире
/// [kContentMaxWidth]: на телефоне ничего не меняет, на iPad список настроек,
/// форма или карточка продукта стоят колонкой по центру, а не во всю ширину.
///
/// Прижимает контент к верху — то же, что `Align(0, -1)` + `maxWidth: 600`,
/// которые FlutterFlow уже проставил на части страниц (настройки, пейвол,
/// редактирование профиля).
class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
        child: child,
      ),
    );
  }
}
