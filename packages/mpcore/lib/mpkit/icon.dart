part of 'mpkit.dart';

class MPIcon extends StatelessWidget {
  final String iconUrl;
  final double size;
  final Color color;

  const MPIcon(this.iconUrl, {this.size = 24, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.transparent,
    );
  }
}
