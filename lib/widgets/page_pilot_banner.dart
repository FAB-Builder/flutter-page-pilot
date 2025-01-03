import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';

class PagePilotBanner extends StatefulWidget {
  List<String> images;
  bool autoplay;
  double itemWidth, itemHeight;

  PagePilotBanner({
    super.key,
    required this.images,
    this.autoplay = true,
    this.itemWidth = 350,
    this.itemHeight = 150,
  });

  @override
  State<PagePilotBanner> createState() => _PagePilotBannerState();
}

class _PagePilotBannerState extends State<PagePilotBanner> {
  @override
  Widget build(BuildContext context) {
    return Swiper(
      autoplay: widget.images.length == 1 ? false : widget.autoplay,
      autoplayDisableOnInteraction: true,
      autoplayDelay: 5000,
      duration: 1000,
      itemBuilder: (BuildContext context, int index) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: () {
          widget.autoplay = false;
        },
        onLongPressEnd: (_) {
          widget.autoplay = true;
        },
        child: Image.network(
          widget.images[index],
          fit: BoxFit.fill,
        ),
      ),
      itemCount: widget.images.length,
      layout: SwiperLayout.STACK,
      itemWidth: widget.itemWidth,
      itemHeight: widget.itemHeight,
      axisDirection: AxisDirection.right,
      pagination: const SwiperPagination(builder: SwiperPagination.rect),
      // control: SwiperControl(),
    );
  }
}
