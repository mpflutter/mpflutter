void requestAnimationFrame(Function(num) callback) async {
  await Future.delayed(Duration(milliseconds: 16));
  callback(DateTime.now().millisecondsSinceEpoch);
}
