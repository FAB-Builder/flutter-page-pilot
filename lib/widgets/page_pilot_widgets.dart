import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class PagePilot {
  static OverlayEntry? _overlayEntry;

  static void showSnackbar(BuildContext context,
      {required String message, int duration = 3}) {
    if (context == null) {
      print("No Overlay widget found in the current context.");
      return;
    }

    final overlay = Overlay.of(context);
    if (overlay == null) {
      print("No Overlay available in current context.");
      return;
    }

    // Prevent multiple snackbars from appearing at the same time
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 40,
        left: 10,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  message,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Insert the overlay entry after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      overlay.insert(_overlayEntry!);
    });

    // Automatically remove the snackbar after a delay
    Future.delayed(Duration(seconds: duration), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  static void showBottomSheet(BuildContext context, {required String text}) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      // isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 16, bottom: 32, left: 16, right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text),
                SizedBox(height: 16),
                Row(
                  children: [
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("OK"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static void showOkCancelDialog(BuildContext context,
      {required String title,
      required String description,
      Function()? onOkPressed}) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
          ),
          // backgroundColor: AppTheme.backgroundColor,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  description,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: onOkPressed,
              child: const Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );
  }
}
