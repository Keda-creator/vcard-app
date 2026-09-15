import 'package:bizkonec/features/pcards/domain/pcard_repository.dart';
import 'package:bizkonec/features/pcards/domain/physical_card.dart';
import 'package:bizkonec/features/pcards/presentation/widgets/pcard_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

final pCardsProvider = AsyncNotifierProvider<PCardsNotifier, List<PhysicalCard>>(PCardsNotifier.new);

class PCardsNotifier extends AsyncNotifier<List<PhysicalCard>> {
  @override
  Future<List<PhysicalCard>> build() {
    return ref.watch(pCardRepositoryProvider).getPCards();
  }

  Future<void> addCard(PhysicalCard card) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(pCardRepositoryProvider).savePCard(card);
      return ref.read(pCardRepositoryProvider).getPCards();
    });
  }

  Future<void> removeCard(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(pCardRepositoryProvider).deletePCard(id);
      return ref.read(pCardRepositoryProvider).getPCards();
    });
  }
}

class PCardsScreen extends ConsumerWidget {
  const PCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pCardsAsync = ref.watch(pCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('pCards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: pCardsAsync.when(
        data: (pCards) => pCards.isEmpty 
            ? _buildEmptyState(context) 
            : _buildGrid(context, ref, pCards),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptions(context),
        label: const Text('Add Card'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'No physical cards yet.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Turn your paper business cards into digital cards.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _showAddOptions(context),
              child: const Text('Add Your First Card'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, List<PhysicalCard> cards) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: PCardWidget(
                card: card,
                onTap: () {
                  // Navigate to detail
                },
                onDelete: () {
                  _showDeleteDialog(context, () {
                    ref.read(pCardsProvider.notifier).removeCard(card.id);
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: const Text('Are you sure you want to delete this card? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Add Physical Card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/add-pcard', extra: ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/add-pcard', extra: ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
