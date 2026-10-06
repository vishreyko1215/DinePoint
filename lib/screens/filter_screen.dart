import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;
  const FilterScreen({super.key, this.initialFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<String> selectedCuisines = [];
  String selectedRating = '';
  String selectedPrice = '';
  List<String> selectedAmbience = [];
  List<String> selectedAreas = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      selectedCuisines = List<String>.from(widget.initialFilters!['cuisines'] ?? []);
      selectedRating = widget.initialFilters!['rating'] ?? '';
      selectedPrice = widget.initialFilters!['price'] ?? '';
      selectedAmbience = List<String>.from(widget.initialFilters!['ambience'] ?? []);
      selectedAreas = List<String>.from(widget.initialFilters!['areas'] ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B2F),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Cuisine'),
            _buildFilterChips(
              ['Italian', 'Chinese', 'Indian', 'Mexican', 'American', 'Dessert'],
              selectedCuisines,
              (val) => _toggleFilter(selectedCuisines, val),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Rating'),
            _buildFilterChips(
              ['4.5+', '4+', '3+'],
              [selectedRating],
              (val) {
                setState(() => selectedRating = val);
              },
              isSingleSelect: true,
              icon: Icons.star,
              iconColor: Colors.amber,
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Price'),
            _buildFilterChips(
              ['Under ₹300', '₹300 - ₹600', '₹600+'],
              [selectedPrice],
              (val) {
                setState(() => selectedPrice = val);
              },
              isSingleSelect: true,
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Ambience'),
            _buildFilterChips(
              ['Casual', 'Fancy', 'Café', 'Family'],
              selectedAmbience,
              (val) => _toggleFilter(selectedAmbience, val),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Area'),
             _buildFilterChips(
              [
                'Indiranagar',
                'Whitefield',
                'Koramangala',
                'HSR Layout',
                'Jayanagar',
                'Church Street',
                'BTM Layout',
                'MG Road',
                'Malleshwaram',
                'Yelahanka',
                'Hebbal',
                'Rajajinagar',
                'Electronic City',
              ],
              selectedAreas,
              (val) => _toggleFilter(selectedAreas, val),
            ),
            
            const SizedBox(height: 100), // Padding for bottom buttons
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFF1B1B2F),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    selectedCuisines.clear();
                    selectedRating = '';
                    selectedPrice = '';
                    selectedAmbience.clear();
                    selectedAreas.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFA8E6CF),
                  side: const BorderSide(color: Color(0xFFA8E6CF)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'cuisines': selectedCuisines,
                    'rating': selectedRating,
                    'price': selectedPrice,
                    'ambience': selectedAmbience,
                    'areas': selectedAreas,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    List<String> options,
    List<String> selectedOptions,
    Function(String) onToggle, {
    bool isSingleSelect = false,
    IconData? icon,
    Color? iconColor,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = selectedOptions.contains(option);
        return GestureDetector(
          onTap: () => onToggle(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFA8E6CF) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: iconColor),
                  const SizedBox(width: 4),
                ],
                Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _toggleFilter(List<String> list, String value) {
    setState(() {
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
    });
  }
}
