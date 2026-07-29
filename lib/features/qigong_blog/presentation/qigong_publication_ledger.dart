import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../domain/qigong_blog_models.dart';

final class QigongPublicationLedger extends StatelessWidget {
  const QigongPublicationLedger({
    super.key,
    required this.document,
    required this.onChanged,
  });

  final QigongBlogDocument document;
  final ValueChanged<QigongBlogDocument> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return ColoredBox(
      color: colors.appCanvas,
      child: ListView(
        key: const Key('qigong-publication-ledger'),
        padding: const EdgeInsets.fromLTRB(34, 30, 34, 90),
        children: [
          Text(
            '발행 데스크',
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '로그인과 자동 게시 없이, 세 채널의 마지막 상태를 한눈에 관리합니다.',
            style: TextStyle(color: colors.secondaryText, fontSize: 15),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primarySurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.post.title.isEmpty
                            ? '제목 없는 수련기'
                            : document.post.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${document.plainText.length}자 · ${document.post.status.userLabel}',
                        style: TextStyle(color: colors.mutedText),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      _copy(context, document.post.title, '제목을 복사했습니다.'),
                  icon: const Icon(Icons.title_rounded),
                  label: const Text('제목 복사'),
                ),
                const SizedBox(width: 9),
                FilledButton.tonalIcon(
                  onPressed: document.plainText.trim().isEmpty
                      ? null
                      : () => _copy(
                          context,
                          document.plainText,
                          '최종 본문을 복사했습니다.',
                        ),
                  icon: const Icon(Icons.content_copy_rounded),
                  label: const Text('최종 본문 복사'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          for (final platform in QigongPublicationPlatform.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PlatformCard(
                platform: platform,
                publication: _publicationFor(platform),
                onChanged: (publication) => _replace(publication),
              ),
            ),
        ],
      ),
    );
  }

  QigongPublication _publicationFor(QigongPublicationPlatform platform) {
    for (final publication in document.publications) {
      if (publication.platform == platform) return publication;
    }
    return QigongPublication(
      platform: platform,
      status: QigongPublicationStatus.notPublished,
    );
  }

  void _replace(QigongPublication publication) {
    final values = [...document.publications];
    final index = values.indexWhere(
      (item) => item.platform == publication.platform,
    );
    if (index == -1) {
      values.add(publication);
    } else {
      values[index] = publication;
    }
    onChanged(document.copyWith(publications: values));
  }

  Future<void> _copy(BuildContext context, String text, String notice) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(notice)));
  }
}

final class _PlatformCard extends StatefulWidget {
  const _PlatformCard({
    required this.platform,
    required this.publication,
    required this.onChanged,
  });
  final QigongPublicationPlatform platform;
  final QigongPublication publication;
  final ValueChanged<QigongPublication> onChanged;

  @override
  State<_PlatformCard> createState() => _PlatformCardState();
}

class _PlatformCardState extends State<_PlatformCard> {
  late final TextEditingController _title = TextEditingController(
    text: widget.publication.externalTitle ?? '',
  );
  late final TextEditingController _url = TextEditingController(
    text: widget.publication.externalUrl ?? '',
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.publication.note ?? '',
  );

  @override
  void didUpdateWidget(covariant _PlatformCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.publication.platform != widget.publication.platform) {
      _title.text = widget.publication.externalTitle ?? '';
      _url.text = widget.publication.externalUrl ?? '';
      _note.text = widget.publication.note ?? '';
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _url.dispose();
    _note.dispose();
    super.dispose();
  }

  void _emit({QigongPublicationStatus? status}) {
    widget.onChanged(
      widget.publication.copyWith(
        status: status,
        externalTitle: _title.text.trim().isEmpty ? null : _title.text.trim(),
        externalUrl: _url.text.trim().isEmpty ? null : _url.text.trim(),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        publishedAt:
            status == QigongPublicationStatus.published &&
                widget.publication.publishedAt == null
            ? DateTime.now().toUtc()
            : widget.publication.publishedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final publication = widget.publication;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primarySurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.hairline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.selectedState,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.public_rounded,
                  color: colors.primaryAction,
                  size: 20,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  widget.platform.userLabel,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              DropdownButton<QigongPublicationStatus>(
                value: publication.status,
                underline: const SizedBox.shrink(),
                onChanged: (value) {
                  if (value != null) _emit(status: value);
                },
                items: QigongPublicationStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.userLabel),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: '외부 제목 · 선택'),
                  onChanged: (_) => _emit(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  key: ValueKey('publication-url-${widget.platform.name}'),
                  controller: _url,
                  decoration: const InputDecoration(
                    labelText: '게시 URL · 선택',
                    hintText: 'https://',
                  ),
                  onChanged: (_) => _emit(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'URL 열기',
                onPressed: _validHttpUri(_url.text) == null
                    ? null
                    : () => launchUrl(
                        _validHttpUri(_url.text)!,
                        mode: LaunchMode.externalApplication,
                      ),
                icon: const Icon(Icons.open_in_new_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            decoration: const InputDecoration(labelText: '플랫폼 메모 · 선택'),
            maxLines: 2,
            onChanged: (_) => _emit(),
          ),
          if (publication.publishedAt case final published?)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  '발행 확인 ${published.toLocal().year}.${published.toLocal().month}.${published.toLocal().day}',
                  style: TextStyle(color: colors.mutedText, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Uri? _validHttpUri(String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null ||
      !uri.hasAuthority ||
      !{'http', 'https'}.contains(uri.scheme)) {
    return null;
  }
  return uri;
}
