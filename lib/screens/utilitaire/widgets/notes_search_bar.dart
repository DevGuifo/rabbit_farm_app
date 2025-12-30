import 'package:flutter/material.dart';

class NotesSearchBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final String selectedTag;
  final ValueChanged<String>? onTagSelected;
  final List<String> tags;

  const NotesSearchBar({
    super.key,
    this.searchQuery = '',
    this.onSearchChanged,
    this.selectedTag = 'Tous',
    this.onTagSelected,
    this.tags = const [
      'Tous',
      'Santé',
      'Comportement',
      'Reproduction',
      'Alimentation',
      'Génétique',
      'Administratif',
      'Autre',
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: onSearchChanged,
          ),
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              final isSelected = tag == selectedTag;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: onTagSelected != null
                      ? (selected) => onTagSelected!(tag)
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
