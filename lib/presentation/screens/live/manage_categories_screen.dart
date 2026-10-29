import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/category_grouping.dart';
import '../../../core/utils/radio.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/category_preference.dart';
import '../../../domain/repositories/iptv_repository.dart';
import '../../../l10n/app_localizations.dart';

/// Visibilidad y orden de las categorías de TV o Radio para la cuenta activa.
class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key, required this.radio});

  final bool radio;

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  bool _loading = true;
  String? _error;
  final List<_UserCategory> _items = <_UserCategory>[];
  final Map<int, CategoryPreference> _otherPreferences =
      <int, CategoryPreference>{};

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final IptvRepository repository = context.read<IptvRepository>();
    try {
      final List<Category> categories = groupCategoriesByRegionAndCountry(
        await repository.fetchLiveCategories(),
      );
      final List<CategoryPreference> prefs = await repository
          .getCategoryPreferences();
      final Map<int, CategoryPreference> byId = <int, CategoryPreference>{
        for (final CategoryPreference preference in prefs)
          preference.categoryId: preference,
      };
      final List<MapEntry<int, Category>> indexed = categories
          .asMap()
          .entries
          .where(
            (MapEntry<int, Category> entry) =>
                isRadioCategory(entry.value.name) == widget.radio,
          )
          .toList();
      indexed.sort((MapEntry<int, Category> a, MapEntry<int, Category> b) {
        final CategoryPreference? pa = byId[a.value.id];
        final CategoryPreference? pb = byId[b.value.id];
        if (pa == null && pb == null) return a.key.compareTo(b.key);
        if (pa == null) return 1;
        if (pb == null) return -1;
        final int byOrder = pa.sortOrder.compareTo(pb.sortOrder);
        return byOrder != 0 ? byOrder : a.key.compareTo(b.key);
      });
      final List<Category> visible = indexed
          .map((MapEntry<int, Category> entry) => entry.value)
          .toList();
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(
            visible.map(
              (Category category) => _UserCategory(
                category: category,
                hidden: byId[category.id]?.hidden ?? false,
              ),
            ),
          );
        _otherPreferences
          ..clear()
          ..addEntries(
            byId.entries.where(
              (MapEntry<int, CategoryPreference> entry) =>
                  !visible.any((Category category) => category.id == entry.key),
            ),
          );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context)!.liveLoadError;
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final List<CategoryPreference> preferences = <CategoryPreference>[
      ..._otherPreferences.values,
      for (int i = 0; i < _items.length; i++)
        CategoryPreference(
          categoryId: _items[i].category.id,
          hidden: _items[i].hidden,
          sortOrder: i,
        ),
    ];
    setState(() => _saving = true);
    try {
      await context.read<IptvRepository>().saveCategoryPreferences(preferences);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.saveError)),
      );
    }
  }

  void _move(int index, int delta) {
    final int target = index + delta;
    if (target < 0 || target >= _items.length) return;
    setState(() {
      final _UserCategory item = _items.removeAt(index);
      _items.insert(target, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageCategories),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _loading || _error != null || _saving ? null : _save,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _items.isEmpty
          ? Center(child: Text(l10n.noChannels))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final _UserCategory item = _items[index];
                return ListTile(
                  leading: Switch(
                    value: !item.hidden,
                    onChanged: (bool value) {
                      setState(() => item.hidden = !value);
                    },
                  ),
                  title: Text(
                    item.category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        tooltip: l10n.moveUp,
                        icon: const Icon(Icons.keyboard_arrow_up),
                        onPressed: index == 0 ? null : () => _move(index, -1),
                      ),
                      IconButton(
                        tooltip: l10n.moveDown,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        onPressed: index == _items.length - 1
                            ? null
                            : () => _move(index, 1),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _UserCategory {
  _UserCategory({required this.category, required this.hidden});

  final Category category;
  bool hidden;
}
