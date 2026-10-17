import 'package:flutter/material.dart';
import 'package:saranutri/l10n/app_localizations.dart';
import 'package:saranutri/shared/brand_mark.dart';
import 'package:saranutri/shared/language_menu.dart';
import 'package:url_launcher/link.dart';

class PublicSite extends StatefulWidget {
  const PublicSite({
    required this.onOpenApp,
    required this.onLocaleChanged,
    super.key,
  });

  final VoidCallback onOpenApp;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<PublicSite> createState() => _PublicSiteState();
}

class _PublicSiteState extends State<PublicSite> {
  final _approachKey = GlobalKey();
  final _contentKey = GlobalKey();

  void _showSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _PublicHeader(
              onOpenApp: widget.onOpenApp,
              onLocaleChanged: widget.onLocaleChanged,
              onShowApproach: () => _showSection(_approachKey),
              onShowContent: () => _showSection(_contentKey),
            ),
          ),
          SliverToBoxAdapter(
            child: _Hero(onShowApproach: () => _showSection(_approachKey)),
          ),
          SliverToBoxAdapter(
            child: _Principles(key: _approachKey),
          ),
          const SliverToBoxAdapter(child: _ProcessSection()),
          SliverToBoxAdapter(
            child: _InstagramSection(key: _contentKey),
          ),
          SliverToBoxAdapter(
            child: _CallToAction(onOpenApp: widget.onOpenApp),
          ),
          SliverToBoxAdapter(
            child: _Footer(onOpenApp: widget.onOpenApp),
          ),
        ],
      ),
    );
  }
}

class _PublicHeader extends StatelessWidget {
  const _PublicHeader({
    required this.onOpenApp,
    required this.onLocaleChanged,
    required this.onShowApproach,
    required this.onShowContent,
  });

  final VoidCallback onOpenApp;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onShowApproach;
  final VoidCallback onShowContent;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFFF8F4EC),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              return Row(
                children: [
                  const BrandMark(),
                  if (!compact) ...[
                    const SizedBox(width: 12),
                    Text(
                      localizations.publicBrand,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                    ),
                  ],
                  const Spacer(),
                  if (constraints.maxWidth >= 1000) ...[
                    TextButton(
                      onPressed: onShowApproach,
                      child: Text(localizations.publicNavApproach),
                    ),
                    TextButton(
                      onPressed: onShowContent,
                      child: Text(localizations.publicNavContent),
                    ),
                    const SizedBox(width: 8),
                  ],
                  LanguageMenu(onLocaleChanged: onLocaleChanged),
                  const SizedBox(width: 8),
                  if (compact)
                    IconButton.filledTonal(
                      key: const ValueKey('open-app-header'),
                      tooltip: localizations.openApp,
                      onPressed: onOpenApp,
                      icon: const Icon(Icons.login, size: 18),
                    )
                  else
                    FilledButton.tonalIcon(
                      key: const ValueKey('open-app-header'),
                      onPressed: onOpenApp,
                      icon: const Icon(Icons.login, size: 18),
                      label: Text(localizations.openApp),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onShowApproach});

  final VoidCallback onShowApproach;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final compact = MediaQuery.sizeOf(context).width < 700;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: SizedBox(
              height: compact ? 900 : 680,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/hero-nutrition.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xEE183C34),
                          Color(0xC9183C34),
                          Color(0x00183C34),
                        ],
                        stops: [0, 0.42, 0.78],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(
                        compact ? 28 : 58,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 545),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Eyebrow(label: localizations.publicEyebrow),
                            const SizedBox(height: 20),
                            Text(
                              localizations.publicHeroTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: compact ? 42 : null,
                                    height: 1.04,
                                    letterSpacing: -1.8,
                                  ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              localizations.publicHeroDescription,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: const Color(0xE8FFFFFF),
                                    height: 1.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            const SizedBox(height: 30),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton.icon(
                                  key: const ValueKey('discover-approach'),
                                  onPressed: onShowApproach,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFF3C66D),
                                    foregroundColor: const Color(0xFF183C34),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 18,
                                    ),
                                  ),
                                  icon: const Icon(Icons.arrow_downward),
                                  label: Text(localizations.discoverApproach),
                                ),
                                Link(
                                  uri: Uri.parse(
                                    'https://www.instagram.com/sv.nutricionista/',
                                  ),
                                  target: LinkTarget.blank,
                                  builder: (context, followLink) {
                                    return OutlinedButton.icon(
                                      onPressed: followLink,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(
                                          color: Color(0xAAFFFFFF),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 22,
                                          vertical: 18,
                                        ),
                                      ),
                                      icon:
                                          const Icon(Icons.camera_alt_outlined),
                                      label: Text(localizations.visitInstagram),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x24FFFFFF),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0x44FFFFFF)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _Principles extends StatelessWidget {
  const _Principles({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final principles = [
      (
        Icons.balance_outlined,
        localizations.principleBalanceTitle,
        localizations.principleBalanceDescription,
      ),
      (
        Icons.person_outline,
        localizations.principlePersonalTitle,
        localizations.principlePersonalDescription,
      ),
      (
        Icons.restaurant_outlined,
        localizations.principleEverydayTitle,
        localizations.principleEverydayDescription,
      ),
    ];
    return _Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            eyebrow: localizations.approachEyebrow,
            title: localizations.approachTitle,
            description: localizations.approachDescription,
          ),
          const SizedBox(height: 34),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth >= 850
                  ? (constraints.maxWidth - 40) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: principles
                    .map(
                      (principle) => SizedBox(
                        width: cardWidth,
                        child: _PrincipleCard(
                          icon: principle.$1,
                          title: principle.$2,
                          description: principle.$3,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PrincipleCard extends StatelessWidget {
  const _PrincipleCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E1D6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE1EFE7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: const Color(0xFF275F50)),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(height: 1.55)),
          ],
        ),
      ),
    );
  }
}

class _ProcessSection extends StatelessWidget {
  const _ProcessSection();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final steps = [
      (
        localizations.processListenTitle,
        localizations.processListenDescription
      ),
      (localizations.processPlanTitle, localizations.processPlanDescription),
      (
        localizations.processAdjustTitle,
        localizations.processAdjustDescription
      ),
    ];
    return Container(
      color: const Color(0xFF1E4B40),
      child: _Section(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 800;
            final heading = _SectionHeading(
              eyebrow: localizations.processEyebrow,
              title: localizations.processTitle,
              description: localizations.processDescription,
              light: true,
            );
            final stepList = Column(
              children: [
                for (var index = 0; index < steps.length; index++)
                  _ProcessStep(
                    number: '${index + 1}'.padLeft(2, '0'),
                    title: steps[index].$1,
                    description: steps[index].$2,
                  ),
              ],
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [heading, const SizedBox(height: 38), stepList],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: heading),
                const SizedBox(width: 80),
                Expanded(child: stepList),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProcessStep extends StatelessWidget {
  const _ProcessStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Color(0xFFF3C66D),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(color: Color(0xCFFFFFFF), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstagramSection extends StatelessWidget {
  const _InstagramSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return _Section(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFEBD9CE),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.contentEyebrow.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF8B4E3D),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    localizations.contentTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.contentDescription,
                    style: const TextStyle(height: 1.55),
                  ),
                ],
              );
              final link = Link(
                uri: Uri.parse('https://www.instagram.com/sv.nutricionista/'),
                target: LinkTarget.blank,
                builder: (context, followLink) => FilledButton.icon(
                  onPressed: followLink,
                  icon: const Icon(Icons.arrow_outward),
                  label: Text(localizations.followOnInstagram),
                ),
              );
              if (constraints.maxWidth < 720) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [copy, const SizedBox(height: 26), link],
                );
              }
              return Row(
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: 48),
                  link,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CallToAction extends StatelessWidget {
  const _CallToAction({required this.onOpenApp});

  final VoidCallback onOpenApp;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return _Section(
      child: Column(
        children: [
          Text(
            localizations.publicCtaTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Text(
              localizations.publicCtaDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.55),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            key: const ValueKey('open-app-cta'),
            onPressed: onOpenApp,
            icon: const Icon(Icons.arrow_forward),
            label: Text(localizations.openApp),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onOpenApp});

  final VoidCallback onOpenApp;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF15372F),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 28,
            runSpacing: 16,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandMark(size: 34),
                  const SizedBox(width: 12),
                  Text(
                    localizations.publicBrand,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onOpenApp,
                child: Text(
                  localizations.openApp,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Text(
                localizations.publicDisclaimer,
                style: const TextStyle(color: Color(0xBFFFFFFF), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 76),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: child,
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
    this.light = false,
  });

  final String eyebrow;
  final String title;
  final String description;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final primaryText = light ? Colors.white : const Color(0xFF183C34);
    final secondaryText = light ? const Color(0xCFFFFFFF) : Colors.black87;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 650),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFC68A36),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: primaryText,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.1,
                  height: 1.12,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(color: secondaryText, height: 1.6, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
