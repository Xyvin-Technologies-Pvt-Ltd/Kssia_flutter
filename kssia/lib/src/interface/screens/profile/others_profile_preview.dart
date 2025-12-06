import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kssia/src/data/globals.dart';
import 'package:kssia/src/data/models/chat_model.dart';
import 'package:kssia/src/data/models/user_model.dart';
import 'package:kssia/src/data/providers/user_provider.dart';
import 'package:kssia/src/data/services/getRatings.dart';
import 'package:kssia/src/data/services/save_contact.dart';
import 'package:kssia/src/interface/common/cards.dart';
import 'package:kssia/src/interface/common/components/svg_icon.dart';
import 'package:kssia/src/interface/common/customModalsheets.dart';
import 'package:kssia/src/interface/common/custom_button.dart';
import 'package:kssia/src/interface/common/custom_video.dart';
import 'package:kssia/src/interface/common/loading.dart';
import 'package:kssia/src/interface/common/review_card.dart';
import 'package:kssia/src/interface/screens/profilepreview/social_website_preview.dart';
import 'package:kssia/src/interface/screens/main_pages/loginPage.dart';
import 'package:kssia/src/interface/screens/menu/my_reviews.dart';
import 'package:kssia/src/interface/screens/people/chat/chatscreen.dart';
import 'package:kssia/src/interface/screens/profile/user_details.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
class OthersReviewsState extends StateNotifier<int> {
  OthersReviewsState() : super(1);

  void showMoreReviews(int totalReviews) {
    state = (state + 2).clamp(0, totalReviews);
  }
}

final otherReviewsProvider = StateNotifierProvider<ReviewsState, int>((ref) {
  return ReviewsState();
});

class OthersProfilePreview extends ConsumerWidget {
  final UserModel user;
  OthersProfilePreview({Key? key, required this.user}) : super(key: key);

  final List<String> svgIcons = [
    'assets/icons/instagram.svg',
    'assets/icons/linkedin.svg',
    'assets/icons/twitter.svg',
    'assets/icons/icons8-facebook.svg'
  ];

  final ValueNotifier<int> _currentVideo = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsToShow = ref.watch(otherReviewsProvider);
    PageController _videoCountController = PageController();

    _videoCountController.addListener(() {
      _currentVideo.value = _videoCountController.page!.round();
    });
    final ratingDistribution = getRatingDistribution(user);
    final averageRating = getAverageRating(user);
    final totalReviews = user.reviews!.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset(
            'assets/triangles.png',
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (id.toString() == user.id.toString())
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(30)),
                            child: IconButton(
                              icon: const Icon(
                                size: 18,
                                Icons.edit,
                                color: Color(0xFF004797),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DetailsPage()), // Navigate to MenuPage
                                );
                              },
                            ),
                          ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(30)),
                          child: IconButton(
                            icon: const Icon(
                              size: 20,
                              Icons.close,
                            ),
                            onPressed: () {
                              ref.invalidate(otherReviewsProvider);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        user.profilePicture != null && user.profilePicture != ''
                            ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: InteractiveViewer(
                                          child: Image.network(
                                              user.profilePicture ?? '',
                                              fit: BoxFit.contain),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 100, // Diameter + border width
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFF004797),
                                      width: 2.0, // Border width
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      user.profilePicture ?? '',
                                      width:
                                          74, // Diameter of the circle (excluding border)
                                      height: 74,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ))
                            : Image.asset(
                                'assets/icons/dummy_person_large.png'),
                        const SizedBox(height: 10),
                        Text(
                          '${user.abbreviation ?? ''} ${user.name ?? ''}',
                          style: const TextStyle(
                            color: Color(0xFF2C2829),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Column(
                            //   children: [
                            //     user.companyLogo != null &&
                            //             user.companyLogo != ''
                            //         ? GestureDetector(
                            //             onTap: () {
                            //               showDialog(
                            //                 context: context,
                            //                 builder: (context) => Dialog(
                            //                   backgroundColor:
                            //                       Colors.transparent,
                            //                   child: GestureDetector(
                            //                     onTap: () =>
                            //                         Navigator.pop(context),
                            //                     child: InteractiveViewer(
                            //                       child: Image.network(
                            //                         user.companyLogo ?? '',
                            //                         errorBuilder: (context,
                            //                             error, stackTrace) {
                            //                           return Image.asset(
                            //                               'assets/icons/dummy_company.png');
                            //                         },
                            //                         fit: BoxFit.contain,
                            //                       ),
                            //                     ),
                            //                   ),
                            //                 ),
                            //               );
                            //             },
                            //             child: ClipRRect(
                            //               borderRadius:
                            //                   BorderRadius.circular(9),
                            //               child: Image.network(
                            //                 user.companyLogo ?? '',
                            //                 errorBuilder: (context, error,
                            //                     stackTrace) {
                            //                   return Image.asset(
                            //                       'assets/icons/dummy_company.png');
                            //                 },
                            //                 height: 33,
                            //                 width: 40,
                            //                 fit: BoxFit.cover,
                            //               ),
                            //             ),
                            //           )
                            //         : Image.asset(
                            //             'assets/icons/dummy_company.png'),
                            //   ],
                            // ),
                            // const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (user.designation != null &&
                                    user.designation != '')
                                  Text(
                                    user.designation!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 42, 41, 41),
                                    ),
                                  ),
                                if (user.companyName != null &&
                                    user.companyName != '')
                                  Text(
                                    user.companyName ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color.fromARGB(255, 234, 226, 226))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 40,
                            child: Image.asset(
                              'assets/icons/kssiaLogo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          Text(
                            'Member ID: ${user.membershipId}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.phone, color: Color(0xFF004797)),
                            const SizedBox(width: 10),
                            Text(user.phoneNumbers!.personal.toString()),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (user.email != null)
                          Row(
                            children: [
                              const Icon(Icons.email, color: Color(0xFF004797)),
                              const SizedBox(width: 10),
                              Text(user.email!),
                            ],
                          ),
                        const SizedBox(height: 10),
                        if (user.address != null && user.address != '')
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Color(0xFF004797)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  user.address!,
                                ),
                              )
                            ],
                          ),
                        const SizedBox(height: 10),
                        if (user.phoneNumbers?.whatsappNumber != null &&
                            user.phoneNumbers?.whatsappNumber != '')
                          Row(
                            children: [
                              const SvgIcon(
                                assetName: 'assets/icons/whatsapp.svg',
                                color: Color(0xFF004797),
                                size: 25,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(user.phoneNumbers!.whatsappNumber!),
                              )
                            ],
                          ),
                        const SizedBox(height: 10),
                        if (user.phoneNumbers?.whatsappBusinessNumber != null &&
                            user.phoneNumbers?.whatsappBusinessNumber != '')
                          Row(
                            children: [
                              const SvgIcon(
                                assetName: 'assets/icons/whatsapp-business.svg',
                                color: Color(0xFF004797),
                                size: 23,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                    user.phoneNumbers?.whatsappNumber ?? ''),
                              )
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    if (user.bio != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/icons/qoutes.png'),
                          ),
                        ],
                      ),
                    if (user.bio != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Flexible(child: Text('''${user.bio}''')),
                          ],
                        ),
                      ),
                    const SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ReviewBarChart(
                        ratingDistribution: ratingDistribution,
                        averageRating: averageRating,
                        totalReviews: totalReviews,
                      ),
                    ),
                    if (user.id != id)
                      Row(
                        children: [
                          SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                    ),
                                    builder: (context) => ShowWriteReviewSheet(
                                      userId: user.id!,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      EdgeInsets.zero, // Removed extra padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: const Color(
                                      0xFF004797), // Your preferred color
                                  elevation: 4,
                                ),
                                child: const IntrinsicWidth(
                                  // Ensures compact width based on content
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FittedBox(
                                          // Ensures text scales to fit within the button
                                          child: Text(
                                            'write a',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        FittedBox(
                                          child: Text(
                                            'review',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    if (user.reviews!.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviewsToShow,
                        itemBuilder: (context, index) {
                          return ReviewsCard(
                            review: user.reviews![index],
                            ratingDistribution: ratingDistribution,
                            averageRating: averageRating,
                            totalReviews: totalReviews,
                          );
                        },
                      ),
                    if (reviewsToShow < user.reviews!.length)
                      TextButton(
                        onPressed: () {
                          ref
                              .read(reviewsProvider.notifier)
                              .showMoreReviews(user.reviews!.length);
                        },
                        child: const Text('View More'),
                      ),
                    if (user.socialMedia!.isNotEmpty)
                      const Row(
                        children: [
                          Text(
                            'Social Media',
                            style: TextStyle(
                                color: Color(0xFF2C2829),
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    for (int index = 0;
                        index < user.socialMedia!.length;
                        index++)
                      customSocialPreview(index,
                          social: user.socialMedia![index]),
                    if (user.websites!.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Row(
                          children: [
                            Text(
                              'Websites & Links',
                              style: TextStyle(
                                  color: Color(0xFF2C2829),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    for (int index = 0; index < user.websites!.length; index++)
                      customWebsitePreview(index,
                          website: user.websites![index]),
                    const SizedBox(
                      height: 30,
                    ),
                    if (user.video!.isNotEmpty)
                      Column(
                        children: [
                          SizedBox(
                            width: 500,
                            height: 260,
                            child: PageView.builder(
                              controller: _videoCountController,
                              itemCount: user.video!.length,
                              physics: const PageScrollPhysics(),
                              itemBuilder: (context, index) {
                                return customVideo(
                                  title:user.video![index].name??'',videoId: extractYoutubeId(user.video![index].url??'')??'');
                              },
                            ),
                          ),
                          ValueListenableBuilder<int>(
                            valueListenable: _currentVideo,
                            builder: (context, value, child) {
                              return SmoothPageIndicator(
                                controller: _videoCountController,
                                count: user.video!.length,
                                effect: const ExpandingDotsEffect(
                                  dotHeight: 8,
                                  dotWidth: 4,
                                  activeDotColor: Colors.black,
                                  dotColor: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 40,
                    ),
                    if (user.products != null && user.products!.isNotEmpty)
                      const Row(
                        children: [
                          Text(
                            'Products',
                            style: TextStyle(
                                color: Color(0xFF2C2829),
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    if (user.products != null)
                      GridView.builder(
                        shrinkWrap:
                            true, // Let GridView take up only as much space as it needs
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable GridView's internal scrolling
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisExtent: 212,
                          crossAxisCount: 2,
                          crossAxisSpacing: 0.0,
                          mainAxisSpacing: 20.0,
                        ),
                        itemCount: user.products!.length,
                        itemBuilder: (context, index) {
                          return ProductCard(onEdit: null,
                            product: user.products![index],
                            onRemove: null,
                          );
                        },
                      ),
                    const SizedBox(
                      height: 50,
                    ),
                    if (user.certificates != null &&
                        user.certificates!.isNotEmpty)
                      const Row(
                        children: [
                          Text(
                            'Certificates',
                            style: TextStyle(
                                color: Color(0xFF2C2829),
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ListView.builder(
                      shrinkWrap:
                          true, // Let ListView take up only as much space as it needs
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable ListView's internal scrolling
                      itemCount: user.certificates!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0), // Space between items
                          child: CertificateCard(onEdit: null,
                            certificate: user.certificates![index],
                            onRemove: null,
                          ),
                        );
                      },
                    ),
                    if (user.awards != null && user.awards!.isNotEmpty)
                      const Row(
                        children: [
                          Text(
                            'Awards',
                            style: TextStyle(
                                color: Color(0xFF2C2829),
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    GridView.builder(
                      shrinkWrap:
                          true, // Let GridView take up only as much space as it needs
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable GridView's internal scrolling
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns
                        crossAxisSpacing: 8.0, // Space between columns
                        mainAxisSpacing: 8.0, // Space between rows
                      ),
                      itemCount: user.awards!.length,
                      itemBuilder: (context, index) {
                        return AwardCard(
                          onEdit: null,
                          award: user.awards![index],
                          onRemove: null,
                        );
                      },
                    ),
                    if (user.brochure != null && user.brochure!.isNotEmpty)
                      const Row(
                        children: [
                          Text(
                            'Brochure',
                            style: TextStyle(
                                color: Color(0xFF2C2829),
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    if (user.brochure != null)
                      ListView.builder(
                        shrinkWrap:
                            true, // Let ListView take up only as much space as it needs
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable ListView's internal scrolling
                        itemCount: user.brochure!.length,
                        itemBuilder: (context, index) {
                          return BrochureCard(
                            brochure: user.brochure![index],
                            // onRemove: () => _removeCertificateCard(index),
                          );
                        },
                      ),
                  ]),
                ),
                const SizedBox(height: 70)
              ],
            ),
          ),
          if (user.id != id)
            Positioned(
                bottom: 40,
                left: 15,
                right: 15,
                child: SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: customButton(
                              buttonHeight: 60,
                              fontSize: 16,
                              label: 'SAY HI',
                              onPressed: () {
                                final Participant receiver = Participant(
                                  id: user.id,
                                  profilePicture: user.profilePicture ?? '',
                                  name: user.name ?? '',
                                );
                                final Participant sender = Participant(id: id);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => IndividualPage(
                                          receiver: receiver,
                                          sender: sender,
                                        )));
                              }),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: customButton(
                              sideColor:
                                  const Color.fromARGB(255, 219, 217, 217),
                              labelColor: const Color(0xFF2C2829),
                              buttonColor:
                                  const Color.fromARGB(255, 222, 218, 218),
                              buttonHeight: 60,
                              fontSize: 14,
                              label: 'SAVE CONTACT',
                              onPressed: () {
                                if (user.phoneNumbers?.personal != null) {
                                  saveContact(
                                      name:
                                          '${user.abbreviation ?? ''} ${user.name ?? ''}',
                                      number: user.phoneNumbers?.personal ?? '',
                                      email: user.email ?? '',
                                      context: context);
                                }
                              }),
                        ),
                      ],
                    ))),
        ],
      ),
    );
  }


  Padding customProfilePreviewLinks(int index,
      {SocialMedia? social, Website? website}) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFFF2F2F2),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
                child: Align(
                  alignment: Alignment.topCenter,
                  widthFactor: 1.0,
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      width: 42,
                      height: 42,
                      child: SvgIcon(
                        assetName: svgIcons[index],
                        color: const Color(0xFF004797),
                      )),
                ),
              ),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: social != null
                      ? Text('${social.url}')
                      : Text('${website!.url}')),
            ],
          )),
    );
  }
}

class ReviewBarChart extends StatelessWidget {
  final Map<int, int> ratingDistribution;
  final double averageRating;
  final int totalReviews;

  const ReviewBarChart({
    Key? key,
    required this.ratingDistribution,
    required this.averageRating,
    required this.totalReviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Star icon, average rating, and total reviews
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Container(
                  height: 60,
                  width: 80,
                  color: const Color(0xFFFFFCF2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFF5B358)),
                      const SizedBox(width: 4),
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                            color: Color(0xFFF5B358),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$totalReviews Reviews',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(width: 16), // Space between left and right side

        // Right side: Rating bars
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(5, (index) {
                int starCount = 5 - index;
                int reviewCount = ratingDistribution[starCount] ?? 0;
                double percentage =
                    totalReviews > 0 ? reviewCount / totalReviews : 0;

                return Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        minHeight: 4.5,
                        borderRadius: BorderRadius.circular(10),
                        value: percentage,
                        backgroundColor: Colors.grey[300],
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$starCount',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
