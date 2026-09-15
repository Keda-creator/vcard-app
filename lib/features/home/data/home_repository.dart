import 'package:bizkonec/features/home/domain/home_content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class HomeRepository {
  Future<HomeContent> getHomeContent();
}

class MockHomeRepository implements HomeRepository {
  @override
  Future<HomeContent> getHomeContent() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    return HomeContent(
      banners: [
        HomeBanner(
          id: '1',
          imageUrl: 'https://images.unsplash.com/photo-1540317580384-e5d43616b9aa?w=800',
          title: 'Welcome to BizKonec',
          description: 'The premium digital card experience.',
          actionUrl: '/my-vcard',
        ),
        HomeBanner(
          id: '2',
          imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800',
          title: 'Special Offer',
          description: 'Get 50% off on premium NFC cards.',
          actionUrl: 'https://example.com/shop',
        ),
      ],
      news: [
        HomeItem(
          id: 'n1',
          title: 'App Version 1.0 is Live!',
          description: 'We are excited to launch the first version of BizKonec.',
          imageUrl: 'https://images.unsplash.com/photo-1551434678-e076c223a692?w=400',
          date: '2026-09-04',
        ),
      ],
      offers: [
        HomeItem(
          id: 'o1',
          title: 'Free vCard Setup',
          description: 'Let our experts design your professional vCard.',
          imageUrl: 'https://images.unsplash.com/photo-1551434678-e076c223a692?w=800',
        ),
        HomeItem(
          id: 'o2',
          title: 'NFC Premium',
          description: 'Get 20% off on all metal cards.',
          imageUrl: 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=400',
        ),
        HomeItem(
          id: 'o3',
          title: 'Business Bundle',
          description: 'Save big with our company plans.',
          imageUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400',
        ),
      ],
    );
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return MockHomeRepository();
});

final homeContentProvider = FutureProvider<HomeContent>((ref) {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getHomeContent();
});
