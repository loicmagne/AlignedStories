import 'package:alignedstories/home/gallery_logic.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:alignedstories/auth/authentication_logic.dart';

class MyImage extends StatelessWidget {
  final Image img;
  const MyImage({ Key? key,required this.img}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: img
    );
  }
}

class MyGallery extends StatelessWidget {
  const MyGallery({ Key? key }) : super(key: key);
  final double padding = 5.0;

  @override
  Widget build(BuildContext context) {
    final imgList = context.watch<GalleryService>().currentImageList;
    return Padding(
      padding: EdgeInsets.all(padding),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: padding,
          mainAxisSpacing: padding
        ),
        itemCount: imgList.length,
        itemBuilder: (BuildContext context, int idx) {
          return MyImage(img: Image.network(
            imgList[idx], 
            fit: BoxFit.cover)
          );
        }
      )
    );
  }
}

class AddImageButton extends StatelessWidget {
  final bool visibility;
  const AddImageButton({ Key? key, required this.visibility}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visibility,
      child: FloatingActionButton(
        onPressed: () {
          GalleryService galleryService = context.read<GalleryService>();
          final String currentUID = context.read<AuthenticationService>().currentUser!.uid;
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 112,
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    Center(
                      child: ListTile(
                        title: const Text('From camera',textAlign: TextAlign.center),
                        onTap: () async {
                          Navigator.pop(context);
                          XFile? file = await ImageService.fetchImage(ImageSource.camera);
                          if (file != null) {
                            String? url = await GalleryService.upload(
                              uid: currentUID,
                              gid: galleryService.currentGalleryID!, 
                              image: file
                            );
                            if (url != null) {
                              await galleryService.add(element: url, uid: currentUID);
                            } else {print('Null url');}
                          } else {print('Null file');}
                        },
                      ),
                    ),
                    Center(
                      child: ListTile(
                        title: const Text('From gallery',textAlign: TextAlign.center),
                        onTap: () async {
                          Navigator.pop(context);
                          XFile? file = await ImageService.fetchImage(ImageSource.gallery);
                          if (file != null) {
                            String? url = await GalleryService.upload(
                              uid: currentUID,
                              gid: galleryService.currentGalleryID!, 
                              image: file
                            );
                            if (url != null) {
                              await galleryService.add(element: url, uid: currentUID);
                            } else {print('Null url');}
                          } else {print('Null file');}
                        },
                      ),
                    )
                  ],
                )
              );
            }
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}