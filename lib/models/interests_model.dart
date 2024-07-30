class Interests {
  final String title;
  final String? imagePath;
  final bool isOriginal;

  const Interests({
    required this.title,
    this.imagePath,
    this.isOriginal = true,
  });
}