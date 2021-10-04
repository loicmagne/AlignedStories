class Gallery {
  final String name;
  final String id;
  final List<String> imgs;
  String? ref;

  Gallery({required this.name, required this.id, required this.imgs, required this.ref});

  factory Gallery.fromFb({required Map<String,dynamic> data, required String id}) {
    return Gallery(
      name: data['name'], 
      id: id, 
      imgs: data['pictures'].cast<String>(), 
      ref: data['reference']
    );
  }

  factory Gallery.empty() {
    return Gallery(
      name: '', 
      id: '', 
      imgs: <String>[], 
      ref: ''
    );
  }
}