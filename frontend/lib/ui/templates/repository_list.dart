import 'package:flutter/material.dart';

import '../../api/tagger/repository_tagger_client.dart';
import '../molecules/detail_chip.dart';
import 'page_body.dart';

/// Default repository list template
class RepositoryList extends StatelessWidget {
  const RepositoryList(
      {@required this.title, @required this.items, @required this.onOpen});

  final Widget title;
  final List<SimpleRepository> items;
  final Function(SimpleRepository repository) onOpen;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          title,
          Expanded(child: _buildList(context)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final style = Theme.of(context).textTheme;

    return ListView.separated(
        itemCount: items.length,
        padding: const EdgeInsets.all(kStandardPadding),
        separatorBuilder: (_, __) => const Divider(thickness: 1),
        itemBuilder: (context, index) {
          final item = items[index];

          return ListTile(
            onTap: () => onOpen(item),
            title: Row(
              children: [
                Text('${item.ownerName} / ', style: style.subtitle1),
                Text(item.name, style: style.headline5),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.description?.isNotEmpty == true)
                  Text(item.description ?? ''),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildChipDetails(item),
                ),
              ],
            ),
          );
        });
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
