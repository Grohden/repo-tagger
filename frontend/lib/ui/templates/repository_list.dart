import 'package:flutter/material.dart';

import '../../api/tagger/repository_tagger_client.dart';
import '../molecules/detail_chip.dart';
import '../molecules/primary_raised_button.dart';
import 'page_body.dart';

/// Default repository list template
class RepositoryList extends StatelessWidget {
  const RepositoryList({
    this.title,
    @required this.items,
    @required this.onOpen,
    this.onLoadMore,
    this.isLoadingMore,
  });

  final Widget title;
  final List<SimpleRepository> items;
  final Function(SimpleRepository repository) onOpen;

  /// If specified, shows a load more button at the bottom of the page
  final Function() onLoadMore;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          if (title != null) title,
          Expanded(child: _buildList(context)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final count = MediaQuery.of(context).size.width / 450;
    final offset = onLoadMore != null ? 1 : 0;

    return Scrollbar(
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count.ceil(),
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length + offset,
          padding: const EdgeInsets.all(kStandardPadding),
          itemBuilder: (context, index) {
            if (index >= items.length) {
              return PrimaryRaisedButton(
                child: const Text('Load more'),
                onPressed: onLoadMore,
                showLoader: isLoadingMore,
              );
            }

            final item = items[index];

            return Card(
              child: InkWell(
                onTap: () => onOpen(item),
                child: Column(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: item.description?.isNotEmpty == true
                            ? Text(item.description ?? '')
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _buildChipDetails(item),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget _buildChipDetails(SimpleRepository item) {
    return Row(
      children: [
        DetailChip(
          label: Row(
            children: const [
              Icon(Icons.star_border, size: 14),
              SizedBox(width: 4),
              Text('Stars'),
            ],
          ),
          content: Text(item.stargazersCount.toString()),
        ),
        const SizedBox(width: 8),
        if (item.language?.isNotEmpty == true)
          DetailChip(
            content: Text(item.language.toString()),
            label: const Text('Lang'),
          ),
      ],
    );
  }
}
