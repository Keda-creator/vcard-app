class HomeContent {
  final List<HomeBanner> banners;
  final List<HomeItem> news;
  final List<HomeItem> offers;

  HomeContent({
    required this.banners,
    required this.news,
    required this.offers,
  });
}

class HomeBanner {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String? actionUrl;

  HomeBanner({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.actionUrl,
  });
}

class HomeItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? date;

  HomeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.date,
  });
}
