import 'package:alignedstories/auth/authentication_logic.dart';
import 'package:alignedstories/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'gallery.dart';
import 'gallery_logic.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GalleryService>(create: (_) => GalleryService()),
        Provider<GalleriesHandler>(create: (_) => GalleriesHandler())
      ],
      child: Builder(
        builder: (BuildContext context) {
          return FutureBuilder<bool>(
            future: context.read<GalleriesHandler>().updateGalleriesList(
              context.read<AuthenticationService>().currentUser!.uid,
            ),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return const Home();
              } else {
                return const Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ),
                );
              }
            },
          );
        }
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Widget bodyWidget;
  late bool fabVisibility;
  bool accountFocus = false;

  @override
  void initState() {
    bodyWidget = accountPageWidget();
    super.initState();
  }

  Widget accountPageWidget() {
    fabVisibility = false;
    accountFocus = true;
    return const Center(
      child: Text('TODO : My Account'),
    );
  }

  Widget galleryPageWidget() {
    fabVisibility = true;
    accountFocus = false;
    return const MyGallery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AlignedStories'),
      ),
      body: bodyWidget,
      floatingActionButton: AddImageButton(visibility: fabVisibility),
      drawer: Drawer(
        child: ListView(
          children: [
            // List of stories 
            ListView.builder(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              itemCount: context.read<GalleriesHandler>().nbGalleries,
              itemBuilder: (BuildContext context, int idx) {
                final bool isSelected = (context.read<GalleryService>().currentGalleryID != null) ? 
                                        (context.read<GalleryService>().currentGalleryID == 
                                         context.read<GalleriesHandler>().galleryList[idx]['id']) :
                                        (false);
                return Container(
                  color: (isSelected && !accountFocus) ? Colors.lightBlue.shade100 : null,
                  child: ListTile(
                    leading: const Icon(Icons.image),
                    title: Text(context.read<GalleriesHandler>().galleryList[idx]['name']),
                    onTap: () async {
                      await context.read<GalleryService>().swapGallery(
                        uid: context.read<AuthenticationService>().currentUser!.uid, 
                        gid: context.read<GalleriesHandler>().galleryList[idx]['id']
                      );
                      setState(() {
                        bodyWidget = galleryPageWidget();
                      });
                    Navigator.pop(context);
                    },
                  ),
                );
              }
            ),
            // Add item button 
            Builder(
              builder: (context) {
                return ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New story'),
                  onTap: () async {
                    final TextEditingController nameController = TextEditingController();
                    final GalleriesHandler currentGalleriesHandler = context.read<GalleriesHandler>();
                    final GalleryService currentGalleryService = context.read<GalleryService>();
                    final String currentUID = context.read<AuthenticationService>().currentUser!.uid;
                    await showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('New Story'),
                          content: SingleChildScrollView(
                            child: MyTextField(
                              controller: nameController, 
                              hintText: 'Story name',
                              icon: const Icon(Icons.text_fields_rounded)
                            )
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Create'),
                              onPressed: () async {
                                String gid = uuid.v1();
                                await currentGalleriesHandler.addGallery(
                                  uid: currentUID,
                                  gid: gid, 
                                  gname: nameController.text
                                );
                                await currentGalleryService.swapGallery(
                                  uid: currentUID, 
                                  gid: gid
                                );
                                setState(() {
                                  bodyWidget = galleryPageWidget();
                                });
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      }
                    );
                  },
                );
              }
            ),
            // Account page
            Container(
              color: accountFocus ? Colors.lightBlue.shade100 : null,
              child: ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Account'),
                onTap: () {
                  setState(() {
                    bodyWidget = accountPageWidget();
                  });
                  Navigator.pop(context);
                },
              ),
            )
          ],
        )
      ),
    );
  }
}