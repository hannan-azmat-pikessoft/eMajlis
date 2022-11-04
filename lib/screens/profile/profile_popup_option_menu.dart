import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:share/share.dart';

class ProfilePopupOptionMenu extends StatefulWidget {
  final String image;
  final String name;
  final String otherMemberId;
  ProfilePopupOptionMenu({this.image, this.name, this.otherMemberId});

  @override
  _PopupOptionMenuState createState() => _PopupOptionMenuState();
}

class _PopupOptionMenuState extends State<ProfilePopupOptionMenu> {
  String path;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuOption>(
      icon: Icon(
        Icons.more_vert,
        color: appBlack,
      ),
      color: appwhite,
      onSelected: (value) async {
        if (MenuOption.save == value) {
          final response = await saveProfileForLater(widget.otherMemberId);
          if (response != '') {
            warning(context, response);
          } else {
            somethingWentWrong(context);
          }
        }
        if (MenuOption.share == value) {
          LoaderOverlay overlay = LoaderOverlay.of(context);
          overlay.show();
          _onImagDownloadButtonPressed(widget.image).whenComplete(
            () {
              overlay.hide();
              final RenderBox box = context.findRenderObject() as RenderBox;
              String text = Utility.getShareText(widget.name);
              Share.shareFiles(
                ['$path'],
                text: text,
                sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
              );
            },
          );
        }
        if (MenuOption.block == value) {
          final isSuccess = await blockUnblockMember(widget.otherMemberId, 0);
          if (isSuccess) {
            success(context, "Member Blocked Successfully");
          } else {
            somethingWentWrong(context);
          }
        }
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<MenuOption>>[
          PopupMenuItem(
            child: Text("Save user"),
            value: MenuOption.save,
          ),
          PopupMenuItem(
            child: Text("Share profile"),
            value: MenuOption.share,
          ),
          PopupMenuItem(
            child: Text("Block"),
            value: MenuOption.block,
          ),
        ];
      },
    );
  }

  Future _onImagDownloadButtonPressed(String url) async {
    try {
      // Saved with this method.
      var imageId = await ImageDownloader.downloadImage(url);
      if (imageId == null) {
        return;
      }
      path = await ImageDownloader.findPath(imageId);
      setState(() {
        path = path;
      });
    } on PlatformException catch (error) {
      print(error);
    }
    return true;
  }
}

enum MenuOption { save, share, block }
