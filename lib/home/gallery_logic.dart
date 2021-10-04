import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:alignedstories/home/models.dart';

class GalleriesHandler {
  late List<Map<String,dynamic>> galleryList;

  int get nbGalleries => galleryList.length;

  Future<bool> updateGalleriesList (String uid) async {
    galleryList = await queryGalleries(uid: uid);
    return true;
  }

  Future<void> addGallery({required String uid, required String gid, required String gname}) async {
    galleryList.add({
      'id': gid,
      'name': gname
    });
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('galleries')
      .doc(gid)
      .set({
        'name': gname,
        'reference': null,
        'pictures': []
      });
  }

  Future<void> deleteGallery({required String uid, required  String gid, required String gname}) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('galleries')
      .doc(gid)
      .delete();
    galleryList = galleryList.where((element) => element['id'] != gid).toList();
  }

  static Future<List<Map<String,dynamic>>> queryGalleries({required String uid}) async {
    CollectionReference users = await FirebaseFirestore.instance.collection('users');
    QuerySnapshot<Map<String, dynamic>> galleryListQuery = await users.doc(uid).collection('galleries').get();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> galleriesList = galleryListQuery.docs;
    List<Map<String,dynamic>> galleryInfoList = galleriesList.map((e) => {
      'id': e.id,
      'name': e.data()['name']
    }).toList();
    return galleryInfoList;
  }

  static Future<Gallery> queryGalleryData({required String uid, required String gid}) async {
    DocumentSnapshot<Map<String,dynamic>> query = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('galleries')
      .doc(gid)
      .get();
    return Gallery.fromFb(data: query.data()!, id: gid);
  }
}

class GalleryService extends ChangeNotifier{
  Gallery _currentGallery = Gallery.empty();

  GalleryService();

  String get currentGalleryID => _currentGallery.id;
  String? get currentGalleryRef => _currentGallery.ref;
  List<String> get currentImageList => _currentGallery.imgs;


  Future<void> swapGallery({required String uid, required String gid}) async {
    _currentGallery = await GalleriesHandler.queryGalleryData(uid: uid, gid: gid);
    notifyListeners();
  }

  Future<void> add({required String url, required String uid}) async {
    _currentGallery.imgs.add(url);
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('galleries')
      .doc(currentGalleryID)
      .update({
        "pictures": FieldValue.arrayUnion([url])
    });
    if (currentGalleryRef == null) {await changeRef(newRefURL: url, uid: uid);}
    notifyListeners();
  }

  Future<void> changeRef({required String newRefURL, required String uid}) async {
    _currentGallery.ref = newRefURL;
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('galleries')
      .doc(currentGalleryID)
      .update({
        "reference": newRefURL
    });
    notifyListeners();
  }

  static Future<String?> upload({required String uid, required String gid, required XFile image, required String iid}) async { 
    try {
      String fbStoragePath = "$uid/$gid/$iid.jpg";
      await FirebaseStorage.instance
        .ref(fbStoragePath)
        .putFile(File(image.path));
      String downloadURL = await FirebaseStorage.instance
        .ref(fbStoragePath)
        .getDownloadURL();
      return downloadURL;
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }
}

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> fetchImage(ImageSource source) async {
    final XFile? img = await _picker.pickImage(source: source);
    return img;
  }
  
  static Image file2image(XFile source) {
    return Image.file(
      File(source.path),
      fit: BoxFit.cover,
    );
  }
}