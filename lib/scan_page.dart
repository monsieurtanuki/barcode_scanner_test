class ScanPage {
  static const double carouselBottomPadding = 10.0;
  static const double carouselHeightPct = 55;

  static double getCarouselHeight(final double maxHeight) =>
      (maxHeight * carouselHeightPct / 100) + carouselBottomPadding;
}
