import 'package:alignedstories/home/gallery_logic.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:alignedstories/auth/authentication_logic.dart';
import 'package:alignedstories/home/imgzoom_page.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class MiniaturedImg extends StatelessWidget {
  final Image img;
  final String id;
  final bool ref;
  final double borderRadius = 10.0;
  const MiniaturedImg({ Key? key, required this.img, required this.id, required this.ref}) : super(key: key);

  Widget RefImg() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.lightGreen, width: 3),
        borderRadius: BorderRadius.circular(borderRadius),
        image: DecorationImage(
          image: img.image,
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.bottomRight,
      child: const Icon(Icons.check_rounded, color: Colors.lightGreen)
    );
  }

  Widget NotRefImg() {
    return img;
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: id,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: ref ? RefImg() : NotRefImg()
      ),
    );
  }
}

class ZoomedImg extends StatelessWidget {
  final Image img;
  final String id;
  const ZoomedImg({ Key? key, required this.img, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: id,
      child: img,
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
          final Image img = Image.network(
            imgList[idx], 
            fit: BoxFit.cover
          );
          final bool isRef = (context.read<GalleryService>().currentGalleryRef) == imgList[idx];
          return GestureDetector(
            onTap: () {
              GalleryService currentGS = context.read<GalleryService>();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ChangeNotifierProvider.value(
                  value: currentGS,
                  child: ImageZoomPage(img: ZoomedImg(img: img, id: imgList[idx]), ref: isRef))
                )
              );
            },
            child: MiniaturedImg(img: img, id: imgList[idx], ref: isRef),
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
                            String iid = uuid.v4();
                            String? url = await GalleryService.upload(
                              uid: currentUID,
                              gid: galleryService.currentGalleryID, 
                              image: file,
                              iid: iid
                            );
                            if (url != null) {
                              await galleryService.add(url: url, uid: currentUID);
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
                            String iid = uuid.v4();
                            String? url = await GalleryService.upload(
                              uid: currentUID,
                              gid: galleryService.currentGalleryID, 
                              image: file,
                              iid: iid
                            );
                            if (url != null) {
                              await galleryService.add(url: url, uid: currentUID);
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