import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kssia/src/data/models/user_model.dart';
import 'package:kssia/src/data/notifiers/events_notifier.dart';
import 'package:kssia/src/data/notifiers/people_notifier.dart';
import 'package:kssia/src/data/notifiers/promotions_notifier.dart';
import 'package:kssia/src/data/services/api_routes/events_api.dart';
import 'package:kssia/src/data/services/api_routes/products_api.dart';
import 'package:kssia/src/data/services/api_routes/promotions_api.dart';
import 'package:kssia/src/data/services/api_routes/subscription_api.dart';
import 'package:kssia/src/data/services/api_routes/user_api.dart';
import 'package:kssia/src/data/globals.dart';
import 'package:kssia/src/data/models/promotions_model.dart';
import 'package:kssia/src/data/services/launch_url.dart';
import 'package:kssia/src/interface/common/components/app_bar.dart';
import 'package:kssia/src/interface/common/custom_video.dart';
import 'package:kssia/src/interface/common/event_widget.dart';
import 'package:kssia/src/interface/common/loading.dart';
import 'package:kssia/src/interface/common/upgrade_dialog.dart';
import 'package:kssia/src/interface/screens/event_news/viewmore_event.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends ConsumerStatefulWidget {
  final UserModel user;
  const HomePage({super.key, required this.user});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentBannerIndex = 0;
  int _currentNoticeIndex = 0;
  int _currentPosterIndex = 0;
  int _currentEventIndex = 0;
  int _currentVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchInitialPromotions();
    _fetchInitialEvents();
  }

  Future<void> _fetchInitialPromotions() async {
    await ref.read(promotionsNotifierProvider.notifier).fetchMorePromotions();
  }

  Future<void> _fetchInitialEvents() async {
    await ref.read(eventsNotifierProvider.notifier).fetchMoreEvents();
  }

  void _onPageChanged(int index, int totalItems) {
    if (index == totalItems - 1) {
      ref.read(promotionsNotifierProvider.notifier).fetchMorePromotions();
    }
  }

  double _calculateDynamicHeight(List<Promotion> notices) {
    double maxHeight = 0.0;

    for (var notice in notices) {
      final double titleHeight =
          _estimateTextHeight(notice.noticeTitle ?? '', 18.0);
      final double descriptionHeight =
          _estimateTextHeight(notice.noticeDescription ?? '', 14.0);
      final double itemHeight = titleHeight + descriptionHeight;
      if (itemHeight > maxHeight) {
        maxHeight = itemHeight + 50;
      }
    }
    return maxHeight;
  }

  double _estimateTextHeight(String text, double fontSize) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final int numLines = (text.length / (screenWidth / fontSize)).ceil();
    return numLines * fontSize * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    final promotions = ref.watch(promotionsNotifierProvider);
    final isFirstLoad =
        ref.read(promotionsNotifierProvider.notifier).isFirstLoad;
    final events = ref.watch(eventsNotifierProvider);
    final filteredVideos = promotions
        .where((promo) => promo.type == 'video')
        .where((video) => video.ytLink.startsWith('http'))
        .toList();
    return Scaffold(
      backgroundColor: Colors.white,
      body: isFirstLoad
          ? Center(
              child: LoadingAnimation(),
            )
          : promotions.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomAppBar(),
                      const SizedBox(height: 20),

                      // Banner Carousel with Dot Indicator
                      if (promotions.any((promo) => promo.type == 'banner'))
                        Column(
                          children: [
                            CarouselSlider(
                              items: promotions
                                  .where((promo) => promo.type == 'banner')
                                  .map((banner) {
                                return _buildBanners(
                                    context: context, banner: banner);
                              }).toList(),
                              options: CarouselOptions(
                                height: 175,
                                scrollPhysics: promotions
                                            .where((promo) =>
                                                promo.type == 'banner')
                                            .length >
                                        1
                                    ? null
                                    : const NeverScrollableScrollPhysics(),
                                autoPlay: promotions
                                            .where((promo) =>
                                                promo.type == 'banner')
                                            .length >
                                        1
                                    ? true
                                    : false,
                                viewportFraction: 1,
                                autoPlayInterval: const Duration(seconds: 3),
                                onPageChanged: (index, reason) {
                                  _onPageChanged(index, promotions.length);
                                  setState(() {
                                    _currentBannerIndex = index;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                      // Notices Carousel with Dot Indicator
                      if (promotions.any((promo) => promo.type == 'notice'))
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Column(
                            children: [
                              CarouselSlider(
                                items: promotions
                                    .where((promo) => promo.type == 'notice')
                                    .map((notice) {
                                  return customNotice(
                                      context: context, notice: notice);
                                }).toList(),
                                options: CarouselOptions(
                                  height: _calculateDynamicHeight(promotions
                                      .where((promo) => promo.type == 'notice')
                                      .toList()),
                                  scrollPhysics: promotions
                                              .where((promo) =>
                                                  promo.type == 'notice')
                                              .length >
                                          1
                                      ? null
                                      : const NeverScrollableScrollPhysics(),
                                  autoPlay: promotions
                                              .where((promo) =>
                                                  promo.type == 'notice')
                                              .length >
                                          1
                                      ? true
                                      : false,
                                  viewportFraction: 1,
                                  autoPlayInterval: const Duration(seconds: 5),
                                  onPageChanged: (index, reason) {
                                    _onPageChanged(index, promotions.length);
                                    setState(() {
                                      _currentNoticeIndex = index;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              _buildDotIndicator(
                                  _currentNoticeIndex,
                                  promotions
                                      .where((promo) => promo.type == 'notice')
                                      .length,
                                  const Color.fromARGB(255, 62, 61, 61)),
                            ],
                          ),
                        ),
                      if (promotions.any((promo) => promo.type == 'poster'))
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              CarouselSlider(
                                items: promotions
                                    .where((promo) => promo.type == 'poster')
                                    .map((poster) {
                                  return customPoster(
                                      context: context, poster: poster);
                                }).toList(),
                                options: CarouselOptions(
                                  height: 450,
                                  scrollPhysics: promotions
                                              .where((promo) =>
                                                  promo.type == 'poster')
                                              .length >
                                          1
                                      ? null
                                      : const NeverScrollableScrollPhysics(),
                                  autoPlay: promotions
                                              .where((promo) =>
                                                  promo.type == 'poster')
                                              .length >
                                          1
                                      ? true
                                      : false,
                                  viewportFraction: 1,
                                  autoPlayInterval: const Duration(seconds: 5),
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentPosterIndex = index;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Events Carousel

                      if (events.isNotEmpty)
                        Column(
                          children: [
                            const Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 25, top: 10),
                                  child: Text(
                                    'Events',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            CarouselSlider(
                              items: events.map((event) {
                                return Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.95,
                                  child: eventWidget(
                                    withImage: true,
                                    context: context,
                                    event: event,
                                  ),
                                );
                              }).toList(),
                              options: CarouselOptions(
                                height: 395,
                                scrollPhysics: events.length > 1
                                    ? null
                                    : const NeverScrollableScrollPhysics(),
                                autoPlay: events.length > 1 ? true : false,
                                viewportFraction: 1,
                                autoPlayInterval: const Duration(seconds: 5),
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentEventIndex = index;
                                  });
                                },
                              ),
                            ),
                            _buildDotIndicator(_currentEventIndex,
                                events.length, const Color(0xFF004797)),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Videos Carousel
                      if (filteredVideos.isNotEmpty)
                        Column(
                          children: [
                            CarouselSlider(
                              items: filteredVideos.map((video) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: customVideo(
                                      title: video.videoTitle,
                                      videoId:
                                          extractYoutubeId(video.ytLink) ?? ''),
                                );
                              }).toList(),
                              options: CarouselOptions(
                                height: 225,
                                scrollPhysics: filteredVideos.length > 1
                                    ? null
                                    : const NeverScrollableScrollPhysics(),
                                viewportFraction: 1,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentVideoIndex = index;
                                  });
                                },
                              ),
                            ),
                            _buildDotIndicator(_currentVideoIndex,
                                filteredVideos.length, Colors.black),
                          ],
                        ),
                      // Repeat similar approach for Posters, Events, and Videos
                    ],
                  ),
                )
              : const Column(
                  children: [
                    CustomAppBar(),
                    SizedBox(
                      height: 50,
                    ),
                    Center(
                        child: Text(
                      'No Promotions',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    )),
                  ],
                ),
    );
  }

  // Dot indicator builder for carousels
  Widget _buildDotIndicator(int currentIndex, int itemCount, Color color) {
    return Center(
      child: SmoothPageIndicator(
        controller: PageController(initialPage: currentIndex),
        count: itemCount,
        effect: WormEffect(
          dotHeight: 10,
          dotWidth: 10,
          activeDotColor: color,
          dotColor: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildBanners(
      {required BuildContext context, required Promotion banner}) {
    return Container(
      width: MediaQuery.sizeOf(context).width / 1.15,
      child: AspectRatio(
        aspectRatio: 2 / 1, // Custom aspect ratio as 2:1
        child: Stack(
          clipBehavior: Clip.none, // This allows overflow
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Image.network(
                  errorBuilder: (context, error, stackTrace) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                        ),
                      ),
                    );
                  },
                  banner.bannerImageUrl,
                  width: double.infinity,
                  fit: BoxFit.fill,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child; // Image loaded successfully
                    }
                    // While the image is loading, show shimmer effect
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customPoster({
    required BuildContext context,
    required Promotion poster,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poster.posterTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8), // Spacing between title and image
          AspectRatio(
            aspectRatio: 19 / 20, // Approximate aspect ratio as 19:20
            child: Image.network(
              poster.posterImageUrl,
              fit: BoxFit.fill,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child; // Image loaded successfully
                } else {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  );
                }
              },
              errorBuilder: (context, error, stackTrace) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget customNotice(
      {required BuildContext context, required Promotion notice}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16), // Adjust spacing between posters
      child: Container(
        width: MediaQuery.of(context).size.width - 32,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5D0D0),
          borderRadius: BorderRadius.circular(8.0),
          // border: Border.all(
          //   color: const Color.fromARGB(
          //       255, 225, 231, 236), // Set the border color to blue
          //   width: 2.0, // Adjust the width as needed
          // ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.noticeTitle ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF004797), // Set the font color to blue
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notice.noticeDescription ?? '',
                    style: const TextStyle(
                      color: Color.fromRGBO(
                          0, 0, 0, 1), // Set the font color to blue
                    ),
                  ),
                  const Spacer(),
                  if (notice.noticeLink != null &&
                      notice.noticeLink != '' &&
                      notice.noticeLink != 'null')
                    GestureDetector(
                      onTap: () {
                        log(notice.noticeLink);
                        launchURL(notice.noticeLink);
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Text(
                              'Know more',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(
                                      0xFF004797) // Set the font color to blue
                                  ),
                            ),
                            Icon(
                              color: Color(0xFF004797),
                              Icons.arrow_forward_ios,
                              size: 14,
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildShimmerPromotionsColumn({
  required BuildContext context,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      shimmerNotice(context: context),
      const SizedBox(height: 16),
      shimmerPoster(context: context),
      const SizedBox(height: 16),
      shimmerVideo(context: context),
    ],
  );
}

Widget shimmerNotice({
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: MediaQuery.of(context).size.width - 32,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  );
}

Widget shimmerPoster({
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: MediaQuery.of(context).size.width - 32,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  );
}

Widget shimmerVideo({
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 20, // Height for the title shimmer
              color: Colors.grey[300],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: MediaQuery.of(context).size.width - 32,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ),
      ],
    ),
  );
}
