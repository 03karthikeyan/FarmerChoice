import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/vegetable_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/widgets/vegetable_card.dart';
import 'vegetable_detail_screen.dart';
import '../chat/chat_screen.dart';

class VegetableSearchScreen extends StatefulWidget {
  const VegetableSearchScreen({super.key});

  @override
  State<VegetableSearchScreen> createState() => _VegetableSearchScreenState();
}

class _VegetableSearchScreenState extends State<VegetableSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vegProvider = Provider.of<VegetableProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Search Fresh Vegetables',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Box & Sort Options
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => vegProvider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search vegetables, farmers, districts...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              vegProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF9FAF9),
                  ),
                ),
                const SizedBox(height: 10),

                // Sort Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('Sort by:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMedium)),
                      const SizedBox(width: 8),
                      _SortChip(label: 'Lowest Price', sortKey: 'lowest_price', vegProvider: vegProvider),
                      _SortChip(label: 'Highest Price', sortKey: 'highest_price', vegProvider: vegProvider),
                      _SortChip(label: 'Newest Listings', sortKey: 'newest', vegProvider: vegProvider),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),

          // Results
          Expanded(
            child: vegProvider.filteredVegetables.isEmpty
                ? const Center(
                    child: Text('No vegetables found matching your query.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vegProvider.filteredVegetables.length,
                    itemBuilder: (context, index) {
                      final veg = vegProvider.filteredVegetables[index];
                      return VegetableCard(
                        vegetable: veg,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VegetableDetailScreen(vegetableId: veg.id),
                            ),
                          );
                        },
                        onChat: () async {
                          if (veg.farmer != null && authProvider.currentUser != null) {
                            final chatProv = Provider.of<ChatProvider>(context, listen: false);
                            final convId = await chatProv.openConversation(
                              farmerId: veg.farmer!.id,
                              customerId: authProvider.currentUser!.id,
                              vegetableId: veg.id,
                            );
                            if (convId != null && mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    conversationId: convId,
                                    recipientName: veg.farmer!.name,
                                    vegetableName: veg.name,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String sortKey;
  final VegetableProvider vegProvider;

  const _SortChip({required this.label, required this.sortKey, required this.vegProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        onPressed: () => vegProvider.setSortBy(sortKey),
      ),
    );
  }
}
