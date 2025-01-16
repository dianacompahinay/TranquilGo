import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFD7F0EC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              // button for starting walking activity
              left: MediaQuery.of(context).size.width / 2 -
                  34, // center the circle horizontally
              top: -25,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/walk');
                },
                child: Container(
                  height: 58,
                  width: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: Center(
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFF36B9A5),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: const Center(
                          child: Icon(
                        Icons.radio_button_checked,
                        color: Colors.white,
                      )),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              // four icons with space in between
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildNavigationIcons(0),
                const Expanded(child: SizedBox()),
                buildNavigationIcons(2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row buildNavigationIcons(int start) {
    return Row(
      children: List.generate(2, (index) {
        return GestureDetector(
          onTap: () => onTap(index + start),
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    if (index + start == currentIndex)
                      Positioned(
                        // horizontal line for active state
                        left: 5,
                        child: Container(
                          height: 4,
                          width: 54,
                          decoration: const BoxDecoration(
                            color: Color(0xFF35A997),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                    SizedBox(
                      // icon with its title
                      height: 55,
                      width: 64,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image(
                              image: (index + start) == currentIndex
                                  ? getActiveIcon(index + start)
                                  : getInactiveIcon(index + start),
                              width: 22,
                              height: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              getLabelForIndex(index + start),
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: Color(0xFF258471),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  AssetImage getInactiveIcon(int index) {
    switch (index) {
      case 0:
        return const AssetImage('assets/icons/home_outlined.png');
      case 1:
        return const AssetImage('assets/icons/mindfulness_outlined.png');
      case 2:
        return const AssetImage('assets/icons/group_outlined.png');
      case 3:
        return const AssetImage('assets/icons/stats.png');
      default:
        return const AssetImage('assets/icons/home_outlined.png');
    }
  }

  AssetImage getActiveIcon(int index) {
    switch (index) {
      case 0:
        return const AssetImage('assets/icons/home_filled.png');
      case 1:
        return const AssetImage('assets/icons/mindfulness_filled.png');
      case 2:
        return const AssetImage('assets/icons/group_filled.png');
      case 3:
        return const AssetImage('assets/icons/stats.png');
      default:
        return const AssetImage('assets/icons/home_filled.png');
    }
  }

  String getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Mind';
      case 2:
        return 'Social';
      case 3:
        return 'Progress';
      default:
        return '';
    }
  }
}
