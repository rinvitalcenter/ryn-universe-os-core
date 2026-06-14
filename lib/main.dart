import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'core/theme/ryn_tokens.dart';
import 'core/text/app_text.dart';

void main() {
  runApp(const RynUniverseApp());
}

class RynUniverseApp extends StatelessWidget {
  const RynUniverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppText.productName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: RynPalette.navy,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: RynPalette.ivoryCanvas,
        useMaterial3: true,
      ),
      home: const CoreOsShell(),
    );
  }
}

class RynPalette {
  const RynPalette._();

  static const ivoryCanvas = Color(0xFFF7F1E8);
  static const ivory = Color(0xFFFFFCF7);
  static const ivorySoft = Color(0xFFFBF4EA);
  static const ivoryLine = Color(0xFFE7D9CA);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF647082);
  static const warmMuted = Color(0xFF8A735A);
  static const navy = Color(0xFF07101F);
  static const deepNavy = Color(0xFF101A2F);
  static const graphite = Color(0xFF1B2638);
  static const navyLine = Color(0xFF2D3B55);
  static const gold = Color(0xFFD4AF5F);
  static const goldSoft = Color(0xFFF1DFB5);
  static const lavender = Color(0xFFE9E5FF);
  static const lavenderStrong = Color(0xFF8B7CF6);
  static const success = Color(0xFF4F8A6B);
  static const warning = Color(0xFFC08337);
  static const shadow = Color(0x20513A20);
  static const darkShadow = Color(0x55000000);
}

class RynMetrics {
  const RynMetrics._();

  static const maxWidth = 1120.0;
  static const radiusShell = 32.0;
  static const radiusCard = 24.0;
  static const radiusSoft = 18.0;
  static const radiusPill = 999.0;
}

class NavItem {
  const NavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

class ModuleItem {
  const ModuleItem(this.label, this.caption, this.icon);
  final String label;
  final String caption;
  final IconData icon;
}

class AgentProfile {
  const AgentProfile(this.name, this.role, this.code, this.initial);
  final String name;
  final String role;
  final String code;
  final String initial;
}

class StaticKanbanTask {
  const StaticKanbanTask({
    required this.title,
    required this.state,
    required this.owner,
    required this.risk,
    required this.nextAction,
    required this.approval,
    required this.record,
    required this.boundary,
  });

  final String title;
  final String state;
  final String owner;
  final String risk;
  final String nextAction;
  final String approval;
  final String record;
  final String boundary;
}

class CoreOsShell extends StatelessWidget {
  const CoreOsShell({super.key});

  static const navigationItems = [
    NavItem(AppText.navHome, Icons.home_rounded),
    NavItem(AppText.navCommand, Icons.auto_awesome_rounded),
    NavItem(AppText.navControl, Icons.hub_rounded),
    NavItem(AppText.navFlow, Icons.account_tree_rounded),
    NavItem(AppText.navRecord, Icons.menu_book_rounded),
    NavItem(AppText.navOutput, Icons.outbox_rounded),
    NavItem(AppText.navSettings, Icons.tune_rounded),
  ];

  static const moduleItems = [
    ModuleItem('프로젝트', '진행 맥락', Icons.folder_special_rounded),
    ModuleItem('문서', '기록 검토', Icons.description_rounded),
    ModuleItem('AI 모델', '보조 두뇌', Icons.psychology_rounded),
    ModuleItem('데이터', '로컬 기준', Icons.storage_rounded),
    ModuleItem('자동화', '승인 후 실행', Icons.bolt_rounded),
    ModuleItem('설정', '운영 기준', Icons.settings_rounded),
  ];

  static const agents = [
    AgentProfile('한서윤', 'Chief / Final Governance', 'Ryn-Chief', '한'),
    AgentProfile(
      '강도현',
      'Product Architect / Product Strategy',
      'Ryn-Product Architect',
      '강',
    ),
    AgentProfile(
      '윤지안',
      'Flow Architect / Operational Flow',
      'Ryn-Flow Architect',
      '윤',
    ),
    AgentProfile(
      '서하린',
      'Experience Designer / Experience & Visual Trust',
      'Ryn-Experience Designer',
      '서',
    ),
    AgentProfile(
      '이유진',
      'Korean UX Writer / Language & UX Tone',
      'Ryn-Korean UX Writer',
      '이',
    ),
    AgentProfile(
      '차민준',
      'DevOps Engineer / Reliability & Safety',
      'Ryn-DevOps Engineer',
      '차',
    ),
    AgentProfile(
      '문서아',
      'Knowledge Archivist / Knowledge Continuity',
      'Ryn-Knowledge Archivist',
      '문',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useRail = constraints.maxWidth >= 2200;
            return Container(
              color: RynPalette.ivoryCanvas,
              child: useRail
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _NavigationRailPanel(),
                        Expanded(child: _ScrollableShellCanvas()),
                      ],
                    )
                  : const _ScrollableShellCanvas(showCompactNav: true),
            );
          },
        ),
      ),
    );
  }
}

class _ScrollableShellCanvas extends StatelessWidget {
  const _ScrollableShellCanvas({this.showCompactNav = false});

  final bool showCompactNav;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final ultraCompact = width < 420;
        final padding = ultraCompact
            ? 6.0
            : width < 720
            ? 12.0
            : 20.0;
        // Windows runtime screenshots at 390px still lose practical edge room
        // to the native frame/capture boundary. Keep the ultra-compact shell
        // intentionally narrower than the reported Flutter max width so the
        // premium command surface stays fully inside the visible client area.
        final railMode = !showCompactNav;
        final railCaptureGuard = railMode && width < 1400;
        final desktopCaptureGuard =
            showCompactNav && width >= 1200 && width < 2200;
        final maxContentWidth = ultraCompact
            ? 260.0
            : desktopCaptureGuard
            ? 900.0
            : railCaptureGuard
            ? 1060.0
            : RynMetrics.maxWidth;
        final runtimeEdgeReserve = ultraCompact ? 64.0 : 0.0;
        final contentWidth = math.max(
          0.0,
          math.min(width - (padding * 2) - runtimeEdgeReserve, maxContentWidth),
        );
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(padding, 16, padding, 28),
            child: Align(
              alignment: railMode || desktopCaptureGuard
                  ? Alignment.centerLeft
                  : Alignment.center,
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showCompactNav) ...[
                      const _CompactNavigationPanel(),
                      const SizedBox(height: 12),
                    ],
                    const _TopSystemBar(),
                    const SizedBox(height: 16),
                    const _CommandHome(),
                    const SizedBox(height: 16),
                    const _KanbanOrchestraLane(),
                    const SizedBox(height: 16),
                    const _ModuleAccessStrip(),
                    const SizedBox(height: 14),
                    const _PrincipleFooter(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavigationRailPanel extends StatelessWidget {
  const _NavigationRailPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 176,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: RynPalette.ivory,
        borderRadius: BorderRadius.circular(RynMetrics.radiusShell),
        border: Border.all(color: RynPalette.ivoryLine),
        boxShadow: const [
          BoxShadow(
            color: RynPalette.shadow,
            blurRadius: 26,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandBlock(compact: true),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final item in CoreOsShell.navigationItems)
                  _NavPill(item: item, active: item.label == '홈'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _BoundaryMini(text: AppText.markerStaticPreview),
          const SizedBox(height: 8),
          const _BoundaryMini(text: AppText.markerNoAutomation),
        ],
      ),
    );
  }
}

class _CompactNavigationPanel extends StatelessWidget {
  const _CompactNavigationPanel();

  @override
  Widget build(BuildContext context) {
    Widget navWrap(Iterable<NavItem> items) {
      return Wrap(
        spacing: 7,
        runSpacing: 8,
        children: [
          for (final item in items)
            _CompactNavChip(item: item, active: item.label == '홈'),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoLine = constraints.maxWidth < 980;
        final firstLine = CoreOsShell.navigationItems.take(4);
        final secondLine = CoreOsShell.navigationItems.skip(4);

        return _LightCard(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (twoLine) ...[
                navWrap(firstLine),
                const SizedBox(height: 8),
                navWrap(secondLine),
              ] else
                navWrap(CoreOsShell.navigationItems),
              const SizedBox(height: 8),
              const Text(
                '모든 OS 메뉴는 위 칩에서 접근합니다.',
                style: TextStyle(
                  color: RynPalette.muted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopSystemBar extends StatelessWidget {
  const _TopSystemBar();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final ultraCompact = outerConstraints.maxWidth < 360;
        return _LightCard(
          padding: ultraCompact
              ? const EdgeInsets.fromLTRB(12, 12, 12, 12)
              : const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tight = constraints.maxWidth < 1240;
              final veryTight = constraints.maxWidth < 360;
              final content = [
                const _BrandBlock(),
                if (!tight) const SizedBox(width: 16),
                if (!tight) const Expanded(child: _CommandSearchPlaceholder()),
                if (!tight) const SizedBox(width: 12),
                const _StaticMarkers(),
                const SizedBox(width: 10),
                const _OwnerChip(),
              ];
              if (tight) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (veryTight) ...[
                      const _BrandBlock(compact: true),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const _OwnerChip(),
                      ),
                    ] else
                      Row(
                        children: const [
                          Expanded(child: _BrandBlock()),
                          _OwnerChip(),
                        ],
                      ),
                    SizedBox(height: veryTight ? 8 : 10),
                    const _CommandSearchPlaceholder(),
                    SizedBox(height: veryTight ? 8 : 10),
                    const _StaticMarkers(),
                  ],
                );
              }
              return Row(children: content);
            },
          ),
        );
      },
    );
  }
}

class _CommandHome extends StatelessWidget {
  const _CommandHome();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1440;
        final medium = constraints.maxWidth >= 920;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(flex: 7, child: _CommandSurface()),
              SizedBox(width: 16),
              Expanded(flex: 3, child: _GovernanceSurface()),
            ],
          );
        }
        if (medium) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _CommandSurface(),
              SizedBox(height: 16),
              _GovernanceSurface(),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _CommandSurface(compact: true),
            SizedBox(height: 14),
            _GovernanceSurface(compact: true),
          ],
        );
      },
    );
  }
}

class _CommandSurface extends StatelessWidget {
  const _CommandSurface({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 620 : 660),
      padding: EdgeInsets.all(compact ? 16 : 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RynMetrics.radiusShell),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RynPalette.navy, RynPalette.deepNavy, Color(0xFF0B1020)],
        ),
        border: Border.all(
          color: RynTokens.borderSubtle,
          width: RynTokens.borderWidthRegular,
        ),
        boxShadow: const [
          BoxShadow(
            color: RynPalette.darkShadow,
            blurRadius: 34,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CommandStatusStrip(),
          SizedBox(height: compact ? 10 : 12),
          const _ConstructionStageBanner(),
          SizedBox(height: compact ? 10 : 12),
          const _NextPermitQueue(),
          SizedBox(height: compact ? 10 : 12),
          const _CommandSurfaceHeader(),
          SizedBox(height: compact ? 12 : 16),
          const _CommandCenterStaticShell(),
          SizedBox(height: compact ? 12 : 16),
          SizedBox(
            height: compact ? 620 : 420,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final orbitAsGrid = constraints.maxWidth < 980;
                return orbitAsGrid
                    ? const _CompactCommandObject()
                    : const _WideCommandObject();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConstructionStageBanner extends StatelessWidget {
  const _ConstructionStageBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RynPalette.gold.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _MiniHeading(
            icon: Icons.apartment_rounded,
            title: AppText.cmdConstructionStageMap,
            caption: '비개발자도 현재 공사 단계를 바로 이해하는 현장판입니다.',
            onDark: true,
          ),
          SizedBox(height: 10),
          _StaticShellWrap(
            items: [
              AppText.cmdConstructionLedgerFiled,
              AppText.cmdConstructionFenceInstalled,
              AppText.cmdConstructionNextPermit,
            ],
          ),
        ],
      ),
    );
  }
}

class _NextPermitQueue extends StatelessWidget {
  const _NextPermitQueue();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2B).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _MiniHeading(
            icon: Icons.next_plan_rounded,
            title: AppText.cmdNextPermitQueue,
            caption: '승인 대기 공사 구역을 정적으로 보여주는 대기열입니다.',
            onDark: true,
          ),
          SizedBox(height: 10),
          _StaticShellWrap(
            items: [
              AppText.cmdNextPermitPrimary,
              AppText.cmdNextPermitCouncilGrowth,
              AppText.cmdNextPermitDbBlueprint,
            ],
          ),
        ],
      ),
    );
  }
}

class _CommandSurfaceHeader extends StatelessWidget {
  const _CommandSurfaceHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Wrap(
          spacing: 9,
          runSpacing: 9,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _DarkPill(
              icon: Icons.auto_awesome_rounded,
              text: AppText.cmdHomeHub,
            ),
            _DarkPill(
              icon: Icons.radar_rounded,
              text: AppText.cmdAiCommandCenter,
            ),
          ],
        ),
        SizedBox(height: 9),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _DarkPill(
              icon: Icons.visibility_outlined,
              text: AppText.markerStaticPreview,
            ),
            _DarkPill(
              icon: Icons.pause_circle_outline_rounded,
              text: AppText.markerNoAutomation,
            ),
            _DarkPill(
              icon: Icons.near_me_disabled_rounded,
              text: AppText.markerNoTelegram,
            ),
          ],
        ),
      ],
    );
  }
}

class _CommandCenterStaticShell extends StatelessWidget {
  const _CommandCenterStaticShell();

  static const safetyItems = [
    AppText.cmdDbClosedNoWrite,
    AppText.cmdSchemaHold,
    AppText.cmdGitPushHold,
    AppText.cmdExternalLocked,
    AppText.cmdGatewayOff,
    AppText.cmdAutomationLocked,
    AppText.cmdImplementationHold,
  ];

  static const councilSessions = [
    AppText.cmdCouncilIa1SpecSaved,
    AppText.cmdCouncilGraph1Pass,
    AppText.cmdCouncilObsidianBackbone,
    AppText.cmdCouncilKanbanRuntimeHold,
  ];

  static const obsidianLinks = [
    AppText.cmdObsidianProjectHome,
    AppText.cmdObsidianMocCommandCenter,
    AppText.cmdObsidianReportsIndex,
    AppText.cmdObsidianIa1Spec,
    AppText.cmdObsidianGraph1Index,
    AppText.cmdObsidianKanbanIndex,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 1080;
        final children = [
          const _StaticShellPanel(
            icon: Icons.health_and_safety_rounded,
            title: AppText.cmdSafetyStatusStrip,
            child: _StaticShellWrap(items: safetyItems),
          ),
          const _StaticShellPanel(
            icon: Icons.gavel_rounded,
            title: AppText.cmdCurrentVerdict,
            child: _StaticVerdictBody(),
          ),
          const _StaticShellPanel(
            icon: Icons.groups_2_rounded,
            title: AppText.cmdCouncilSessions,
            child: _StaticShellList(items: councilSessions),
          ),
          const _StaticShellPanel(
            icon: Icons.menu_book_rounded,
            title: AppText.cmdObsidianLinks,
            child: _StaticShellList(items: obsidianLinks),
          ),
        ];

        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: children[0]),
                const SizedBox(width: 10),
                Expanded(child: children[1]),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: children[2]),
                const SizedBox(width: 10),
                Expanded(child: children[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StaticShellPanel extends StatelessWidget {
  const _StaticShellPanel({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RynPalette.gold.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: RynPalette.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFEDE7D9),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _StaticShellWrap extends StatelessWidget {
  const _StaticShellWrap({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [for (final item in items) _StaticShellChip(text: item)],
    );
  }
}

class _StaticShellList extends StatelessWidget {
  const _StaticShellList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _StaticShellLine(text: items[index]),
          if (index != items.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _StaticVerdictBody extends StatelessWidget {
  const _StaticVerdictBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StaticShellLine(text: AppText.cmdIa1VerdictPassWithGuards),
        SizedBox(height: 6),
        _StaticShellLine(text: AppText.cmdScopeStaticShellOnly),
        SizedBox(height: 6),
        _StaticShellLine(text: AppText.cmdNextGateSourcePatchVerification),
        SizedBox(height: 6),
        _StaticShellLine(text: AppText.markerNoLiveAgentExecution),
      ],
    );
  }
}

class _StaticShellChip extends StatelessWidget {
  const _StaticShellChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: RynPalette.deepNavy.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StaticShellLine extends StatelessWidget {
  const _StaticShellLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.only(top: 6, right: 7),
          decoration: const BoxDecoration(
            color: RynPalette.gold,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFD9E0EE),
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              height: 1.18,
            ),
          ),
        ),
      ],
    );
  }
}

class _WideCommandObject extends StatelessWidget {
  const _WideCommandObject();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: const [
        Positioned.fill(child: _OrbitLineCanvas()),
        _CentralCommandOrb(),
        Positioned(
          left: 12,
          top: 30,
          child: _OrbitNode(
            icon: Icons.support_agent_rounded,
            title: AppText.personaHermesName,
            caption: AppText.personaHermesRole,
            status: '준비 중',
          ),
        ),
        Positioned(
          left: 58,
          bottom: 40,
          child: _OrbitNode(
            icon: Icons.code_rounded,
            title: AppText.agentCodex,
            caption: '구현 보조',
            status: '승인 후',
          ),
        ),
        Positioned(
          right: 18,
          top: 36,
          child: _OrbitNode(
            icon: Icons.diamond_rounded,
            title: AppText.recordObsidian,
            caption: '기록 연결',
            status: '정적',
          ),
        ),
        Positioned(
          right: 56,
          bottom: 54,
          child: _OrbitNode(
            icon: Icons.verified_user_rounded,
            title: AppText.approvalGate,
            caption: '승인 흐름',
            status: '대기',
          ),
        ),
        Positioned(
          bottom: 8,
          child: _OrbitNode(
            icon: Icons.groups_rounded,
            title: AppText.agentCouncil,
            caption: '검토 준비',
            status: 'placeholder',
          ),
        ),
      ],
    );
  }
}

class _CompactCommandObject extends StatelessWidget {
  const _CompactCommandObject();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ultraCompact = constraints.maxWidth < 360;
        final orbSize = ultraCompact ? 204.0 : 230.0;
        final nodeWidth = ultraCompact ? 126.0 : 138.0;
        final nodeGap = ultraCompact ? 8.0 : 10.0;

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CentralCommandOrb(compact: true, compactSize: orbSize),
              SizedBox(height: ultraCompact ? 14 : 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: nodeGap,
                runSpacing: nodeGap,
                children: [
                  _OrbitNode(
                    icon: Icons.support_agent_rounded,
                    title: AppText.personaHermesName,
                    caption: AppText.personaHermesRole,
                    status: '준비 중',
                    small: true,
                    width: nodeWidth,
                  ),
                  _OrbitNode(
                    icon: Icons.code_rounded,
                    title: AppText.agentCodex,
                    caption: '구현 보조',
                    status: '승인 후',
                    small: true,
                    width: nodeWidth,
                  ),
                  _OrbitNode(
                    icon: Icons.groups_rounded,
                    title: AppText.agentCouncil,
                    caption: '검토 준비',
                    status: 'placeholder',
                    small: true,
                    width: nodeWidth,
                  ),
                  _OrbitNode(
                    icon: Icons.diamond_rounded,
                    title: AppText.recordObsidian,
                    caption: '기록 연결',
                    status: '정적',
                    small: true,
                    width: nodeWidth,
                  ),
                  _OrbitNode(
                    icon: Icons.verified_user_rounded,
                    title: AppText.approvalGate,
                    caption: '승인 흐름',
                    status: '대기',
                    small: true,
                    width: nodeWidth,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CentralCommandOrb extends StatelessWidget {
  const _CentralCommandOrb({this.compact = false, this.compactSize});

  final bool compact;
  final double? compactSize;

  @override
  Widget build(BuildContext context) {
    final size = compact ? compactSize ?? 230.0 : 290.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  RynPalette.lavenderStrong.withValues(alpha: 0.24),
                  RynPalette.deepNavy.withValues(alpha: 0.70),
                  RynPalette.navy.withValues(alpha: 0.96),
                ],
              ),
              border: Border.all(
                color: RynPalette.gold.withValues(alpha: 0.65),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: RynPalette.gold.withValues(alpha: 0.26),
                  blurRadius: 32,
                ),
                BoxShadow(
                  color: RynPalette.lavenderStrong.withValues(alpha: 0.20),
                  blurRadius: 58,
                ),
              ],
            ),
          ),
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 28),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: size * 0.68,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppText.cmdAiCommandCenter,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 22 : 27,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: compact ? 8 : 12),
                    const Text(
                      '현재 핵심 명령',
                      style: TextStyle(
                        color: RynPalette.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: compact ? 4 : 6),
                    Text(
                      'AI 전략 보고서 작성',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFEDE7D9),
                        fontSize: compact ? 14 : 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: compact ? 10 : 16),
                    const _CommandCta(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandCta extends StatelessWidget {
  const _CommandCta();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
        border: Border.all(color: RynPalette.gold.withValues(alpha: 0.50)),
      ),
      child: const Text(
        '명령 열기',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _OrbitLineCanvas extends StatelessWidget {
  const _OrbitLineCanvas();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _OrbitPainter());
  }
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final goldPaint = Paint()
      ..color = RynPalette.gold.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final lavenderPaint = Paint()
      ..color = RynPalette.lavenderStrong.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final scale in [0.48, 0.62, 0.76]) {
      final rect = Rect.fromCenter(
        center: center,
        width: size.width * scale,
        height: size.height * scale * 0.48,
      );
      canvas.drawOval(rect, scale == 0.62 ? goldPaint : lavenderPaint);
    }

    final dotPaint = Paint()..color = RynPalette.gold.withValues(alpha: 0.85);
    for (var i = 0; i < 9; i++) {
      final angle = i * math.pi / 4.5;
      final x = center.dx + math.cos(angle) * size.width * 0.30;
      final y = center.dy + math.sin(angle) * size.height * 0.18;
      canvas.drawCircle(Offset(x, y), i.isEven ? 3.0 : 2.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrbitNode extends StatelessWidget {
  const _OrbitNode({
    required this.icon,
    required this.title,
    required this.caption,
    required this.status,
    this.small = false,
    this.width,
  });

  final IconData icon;
  final String title;
  final String caption;
  final String status;
  final bool small;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? (small ? 138 : 158),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RynPalette.deepNavy.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: RynPalette.navyLine),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DarkIconBadge(icon: icon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFB9C2D5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: const TextStyle(
              color: RynPalette.gold,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandStatusStrip extends StatelessWidget {
  const _CommandStatusStrip();

  @override
  Widget build(BuildContext context) {
    const primaryItems = [
      ('현재 상태', AppText.cmdStatusStaticMvpMode, Icons.radar_rounded),
      ('다음 행동', AppText.cmdNextActionSpecAlignedPatch, Icons.next_plan_rounded),
      (
        '승인 / 위험',
        AppText.cmdApprovalRiskBoundedSource,
        Icons.verified_user_rounded,
      ),
    ];
    const secondaryItems = [
      ('기록 연결', 'Obsidian 보고 중심', Icons.menu_book_rounded),
      ('경계 신호', AppText.markerStaticNoAutomationSummary, Icons.shield_rounded),
      (
        '외부 연동',
        AppText.markerNoExternalSending,
        Icons.near_me_disabled_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackDecisionTiles = constraints.maxWidth < 1120;
          final stackSecondaryTiles = constraints.maxWidth < 760;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.space_dashboard_rounded,
                    size: 14,
                    color: RynPalette.gold,
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Mission Control Decision Surface',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFFEDE7D9),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (stackDecisionTiles)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (
                      var index = 0;
                      index < primaryItems.length;
                      index++
                    ) ...[
                      _DarkDecisionTile(
                        label: primaryItems[index].$1,
                        value: primaryItems[index].$2,
                        icon: primaryItems[index].$3,
                        dense: true,
                      ),
                      if (index != primaryItems.length - 1)
                        const SizedBox(height: 8),
                    ],
                  ],
                )
              else
                Row(
                  children: [
                    for (
                      var index = 0;
                      index < primaryItems.length;
                      index++
                    ) ...[
                      Expanded(
                        child: _DarkDecisionTile(
                          label: primaryItems[index].$1,
                          value: primaryItems[index].$2,
                          icon: primaryItems[index].$3,
                          dense: true,
                        ),
                      ),
                      if (index != primaryItems.length - 1)
                        const SizedBox(width: 8),
                    ],
                  ],
                ),
              const SizedBox(height: 8),
              if (stackSecondaryTiles)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (
                      var index = 0;
                      index < secondaryItems.length;
                      index++
                    ) ...[
                      _DarkStatusTile(
                        label: secondaryItems[index].$1,
                        value: secondaryItems[index].$2,
                        icon: secondaryItems[index].$3,
                        fullWidth: true,
                      ),
                      if (index != secondaryItems.length - 1)
                        const SizedBox(height: 8),
                    ],
                  ],
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in secondaryItems)
                      _DarkStatusTile(
                        label: item.$1,
                        value: item.$2,
                        icon: item.$3,
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DarkDecisionTile extends StatelessWidget {
  const _DarkDecisionTile({
    required this.label,
    required this.value,
    required this.icon,
    this.dense = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 10 : 13,
        vertical: dense ? 9 : 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(dense ? 16 : 18),
        border: Border.all(color: RynPalette.gold.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(icon, size: dense ? 16 : 18, color: RynPalette.gold),
          SizedBox(width: dense ? 7 : 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFAEB8CA),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: dense ? 2 : 4),
                Text(
                  value,
                  maxLines: 2,
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: dense ? 13 : 14,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GovernanceSurface extends StatelessWidget {
  const _GovernanceSurface({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _LightCard(
      padding: EdgeInsets.all(compact ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _SectionHeader(
            title: 'Governance / Record / Boundary',
            caption: '승인, 기록, 경계가 명령을 안전하게 감쌉니다.',
          ),
          SizedBox(height: 14),
          _ApprovalFlowCard(),
          SizedBox(height: 12),
          _RecordStateCard(),
          SizedBox(height: 12),
          _HermesCard(),
          SizedBox(height: 12),
          _CouncilReviewStrip(),
          SizedBox(height: 12),
          _BoundaryCard(),
        ],
      ),
    );
  }
}

class _ApprovalFlowCard extends StatelessWidget {
  const _ApprovalFlowCard();

  @override
  Widget build(BuildContext context) {
    return _InnerLightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _MiniHeading(
            icon: Icons.verified_user_rounded,
            title: '승인 흐름',
            caption: '요청 → 검토 → 승인 → 기록',
          ),
          SizedBox(height: 12),
          _ProcessRow(labels: ['요청', '검토', '승인', '기록']),
          SizedBox(height: 10),
          Text(
            '린님 최종 승인 전까지 실제 실행은 일어나지 않습니다.',
            style: TextStyle(
              color: RynPalette.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordStateCard extends StatelessWidget {
  const _RecordStateCard();

  @override
  Widget build(BuildContext context) {
    return _InnerLightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _MiniHeading(
            icon: Icons.diamond_rounded,
            title: 'Obsidian 기록 상태',
            caption: '기록은 지식 연속성의 중심입니다.',
          ),
          SizedBox(height: 10),
          _MetricWrap(
            metrics: [('오늘 생성', '8건'), ('연결 문서', '32건'), ('기록 열기', '준비')],
          ),
        ],
      ),
    );
  }
}

class _HermesCard extends StatelessWidget {
  const _HermesCard();

  @override
  Widget build(BuildContext context) {
    return _InnerLightCard(
      child: Row(
        children: const [
          _InitialAvatar(initial: 'H', accent: RynPalette.navy),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.personaHermesName,
                  style: TextStyle(
                    color: RynPalette.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'AI 운영 비서 · 미래 co-pilot 개념 · 준비 중',
                  style: TextStyle(
                    color: RynPalette.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CouncilReviewStrip extends StatelessWidget {
  const _CouncilReviewStrip();

  @override
  Widget build(BuildContext context) {
    return _InnerLightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MiniHeading(
            icon: Icons.groups_rounded,
            title: '7-Agent Review',
            caption: AppText.markerPortraitAssetSummary,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final agent in CoreOsShell.agents) _AgentChip(agent: agent),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoundaryCard extends StatelessWidget {
  const _BoundaryCard();

  @override
  Widget build(BuildContext context) {
    return _InnerLightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _MiniHeading(
            icon: Icons.shield_outlined,
            title: AppText.kanbanCardBoundary,
            caption: AppText.markerStaticAutomationTelegramSummary,
          ),
          SizedBox(height: 10),
          _BoundaryList(),
        ],
      ),
    );
  }
}

class _KanbanOrchestraLane extends StatefulWidget {
  const _KanbanOrchestraLane();

  @override
  State<_KanbanOrchestraLane> createState() => _KanbanOrchestraLaneState();
}

class _KanbanOrchestraLaneState extends State<_KanbanOrchestraLane> {
  String? selectedTaskTitle;

  static const columns = [
    AppText.kanbanColumnReady,
    AppText.kanbanColumnRunning,
    AppText.kanbanColumnReview,
    AppText.kanbanColumnApprovalWaiting,
    AppText.kanbanColumnDoneRecorded,
    AppText.kanbanColumnBlocked,
    AppText.kanbanColumnDeferred,
  ];

  static const tasks = [
    StaticKanbanTask(
      title: 'FLUTTER-REDESIGN4-FIX3-QA',
      state: AppText.kanbanColumnDoneRecorded,
      owner: 'Hermes / QA',
      risk: AppText.riskLevelOne,
      nextAction: 'stable shell baseline',
      approval: AppText.approvalCompletedPreview,
      record: 'Obsidian QA report',
      boundary: 'QA-only · no source changes',
    ),
    StaticKanbanTask(
      title: 'TEXT-GOV1',
      state: AppText.kanbanColumnDoneRecorded,
      owner: 'ChatGPT PM / Hermes',
      risk: AppText.riskLevelOne,
      nextAction: 'namespace inventory later',
      approval: AppText.approvalCompletedPreview,
      record: 'Text Governance strategy',
      boundary: 'documentation-only',
    ),
    StaticKanbanTask(
      title: 'KANBAN-ORCH1',
      state: AppText.kanbanColumnDoneRecorded,
      owner: 'ChatGPT PM / Hermes',
      risk: AppText.riskLevelOne,
      nextAction: 'concept accepted',
      approval: AppText.approvalCompletedPreview,
      record: 'Concept Review',
      boundary: 'documentation-only',
    ),
    StaticKanbanTask(
      title: 'KANBAN-ORCH2',
      state: AppText.kanbanColumnReview,
      owner: 'ChatGPT PM',
      risk: AppText.riskLevelOne,
      nextAction: '린님 approval for static lane',
      approval: AppText.approvalReviewPreview,
      record: 'Approval packet',
      boundary: 'documentation-only',
    ),
    StaticKanbanTask(
      title: 'KANBAN-ORCH3',
      state: AppText.kanbanColumnApprovalWaiting,
      owner: 'Codex',
      risk: AppText.riskLevelTwo,
      nextAction: 'static UI source patch approval',
      approval: AppText.approvalWaitingPreview,
      record: 'pending implementation report',
      boundary: 'static UI only · no DB',
    ),
    StaticKanbanTask(
      title: 'TELEGRAM-APPROVAL1',
      state: AppText.kanbanColumnDeferred,
      owner: '린님 / ChatGPT PM',
      risk: AppText.riskLevelFour,
      nextAction: 'future approval protocol planning',
      approval: AppText.approvalNotRequestedPreview,
      record: 'future planning',
      boundary: 'deferred · no Telegram',
    ),
  ];

  StaticKanbanTask? get selectedTask {
    final title = selectedTaskTitle;
    if (title == null) {
      return null;
    }
    for (final task in tasks) {
      if (task.title == title) {
        return task;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return _LightCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : RynMetrics.maxWidth;
          final stackedGroups = availableWidth < 1320;
          final safeInset = availableWidth < 480
              ? 120.0
              : availableWidth < 640
              ? 96.0
              : availableWidth < 960
              ? 72.0
              : availableWidth < 1320
              ? 36.0
              : 0.0;
          final rawLaneWidth = math.max(0.0, availableWidth - safeInset);
          final laneWidth = availableWidth < 480
              ? rawLaneWidth.clamp(220.0, availableWidth).toDouble()
              : rawLaneWidth;
          final columnWidth = ((laneWidth - 12) / 2).clamp(280.0, 520.0);

          Widget boundedLane(Widget child) {
            return Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(width: laneWidth, child: child),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              boundedLane(
                const _SectionHeader(
                  title: AppText.kanbanTitleOrchestra,
                  caption: AppText.kanbanCaptionStaticOperationsLane,
                ),
              ),
              const SizedBox(height: 12),
              boundedLane(const _KanbanStaticMarkerStrip()),
              const SizedBox(height: 14),
              boundedLane(const _KanbanOperationSnapshot()),
              const SizedBox(height: 14),
              boundedLane(_KanbanDetailPreview(task: selectedTask)),
              const SizedBox(height: 14),
              boundedLane(
                stackedGroups
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final column in columns) ...[
                            _KanbanColumn(
                              title: column,
                              tasks: tasks
                                  .where((task) => task.state == column)
                                  .toList(),
                              width: laneWidth,
                              compactCards: true,
                              selectedTaskTitle: selectedTaskTitle,
                              onTaskSelected: (task) => setState(() {
                                selectedTaskTitle = task.title;
                              }),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      )
                    : Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final column in columns)
                            _KanbanColumn(
                              title: column,
                              tasks: tasks
                                  .where((task) => task.state == column)
                                  .toList(),
                              width: columnWidth,
                              selectedTaskTitle: selectedTaskTitle,
                              onTaskSelected: (task) => setState(() {
                                selectedTaskTitle = task.title;
                              }),
                            ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KanbanOperationSnapshot extends StatelessWidget {
  const _KanbanOperationSnapshot();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.fact_check_rounded,
        AppText.kanbanSnapshotBaseline,
        AppText.kanbanSnapshotBaselineValue,
      ),
      (
        Icons.view_kanban_rounded,
        AppText.kanbanSnapshotNextSlice,
        AppText.kanbanSnapshotNextSliceValue,
      ),
      (
        Icons.shield_rounded,
        AppText.kanbanSnapshotBoundary,
        AppText.kanbanSnapshotBoundaryValue,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RynPalette.navy,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: RynPalette.navyLine),
        boxShadow: const [
          BoxShadow(
            color: RynPalette.darkShadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackItems = constraints.maxWidth < 980;
          final cards = [
            for (final item in items)
              _KanbanSnapshotTile(
                icon: item.$1,
                label: item.$2,
                value: item.$3,
              ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.radar_rounded, size: 15, color: RynPalette.gold),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      AppText.kanbanSnapshotTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFFEDE7D9),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (stackItems)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < cards.length; index++) ...[
                      cards[index],
                      if (index != cards.length - 1) const SizedBox(height: 8),
                    ],
                  ],
                )
              else
                Row(
                  children: [
                    for (var index = 0; index < cards.length; index++) ...[
                      Expanded(child: cards[index]),
                      if (index != cards.length - 1) const SizedBox(width: 8),
                    ],
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _KanbanSnapshotTile extends StatelessWidget {
  const _KanbanSnapshotTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RynPalette.gold.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: RynPalette.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFAEB8CA),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanStaticMarkerStrip extends StatelessWidget {
  const _KanbanStaticMarkerStrip();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : RynMetrics.maxWidth;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MarkerPillRow(
                children: [
                  _MarkerPill(
                    icon: Icons.visibility_outlined,
                    text: AppText.markerStaticOrchestraPreview,
                  ),
                  _MarkerPill(
                    icon: Icons.swap_calls_rounded,
                    text: AppText.markerNoTaskMovement,
                  ),
                ],
              ),
              SizedBox(height: 7),
              _MarkerPillRow(
                children: [
                  _MarkerPill(
                    icon: Icons.storage_rounded,
                    text: AppText.markerNoDbPersistence,
                  ),
                  _MarkerPill(
                    icon: Icons.smart_toy_outlined,
                    text: AppText.markerNoLiveAgentExecution,
                  ),
                  _MarkerPill(
                    icon: Icons.near_me_disabled_rounded,
                    text: AppText.markerNoExternalSending,
                  ),
                ],
              ),
              SizedBox(height: 7),
              _MarkerPillRow(
                children: [
                  _MarkerPill(
                    icon: Icons.link_off_rounded,
                    text: AppText.markerNoTelegramApiProviderCronjob,
                  ),
                  _MarkerPill(
                    icon: Icons.timeline_rounded,
                    text: AppText.markerNoRealStatusTransition,
                  ),
                ],
              ),
              SizedBox(height: 7),
              _MarkerPillRow(
                children: [
                  _MarkerPill(
                    icon: Icons.view_column_outlined,
                    text: AppText.markerNoLaneMovement,
                  ),
                  _MarkerPill(
                    icon: Icons.back_hand_outlined,
                    text: AppText.markerNoDragDrop,
                  ),
                  _MarkerPill(
                    icon: Icons.near_me_disabled_rounded,
                    text: AppText.markerNoTelegramSync,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KanbanDetailPreview extends StatelessWidget {
  const _KanbanDetailPreview({required this.task});

  final StaticKanbanTask? task;

  @override
  Widget build(BuildContext context) {
    final selected = task;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RynPalette.ivorySoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected == null
              ? RynPalette.ivoryLine
              : RynPalette.gold.withValues(alpha: 0.55),
        ),
      ),
      child: Semantics(
        liveRegion: true,
        label: selected == null
            ? AppText.kanbanSelectionNoneSelected
            : '${AppText.a11yKanbanDetailInspection}: ${selected.title}',
        child: selected == null
            ? const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MiniHeading(
                    icon: Icons.touch_app_rounded,
                    title: AppText.kanbanSelectionNoneSelected,
                    caption: AppText.kanbanMsgSelectCardToPreview,
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MarkerPillRow(
                        children: [
                          _MarkerPill(
                            icon: Icons.visibility_outlined,
                            text: AppText.markerStaticPrototypeInteraction,
                          ),
                          _MarkerPill(
                            icon: Icons.swap_calls_rounded,
                            text: AppText.kanbanSelectionOnlyNoMove,
                          ),
                        ],
                      ),
                      SizedBox(height: 7),
                      _MarkerPillRow(
                        children: [
                          _MarkerPill(
                            icon: Icons.restart_alt_rounded,
                            text: AppText.kanbanSelectionResetsOnRestart,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MiniHeading(
                    icon: Icons.fact_check_rounded,
                    title: AppText.kanbanSelectionCardSelected,
                    caption: AppText.kanbanDetailInspectionOnlyNote,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selected.title,
                    style: const TextStyle(
                      color: RynPalette.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _KanbanSignalPill(
                        icon: Icons.warning_amber_rounded,
                        label: AppText.kanbanDetailRiskLevel,
                        value: selected.risk,
                      ),
                      _KanbanSignalPill(
                        icon: Icons.verified_user_rounded,
                        label: AppText.kanbanDetailApprovalState,
                        value: selected.approval,
                      ),
                      _KanbanSignalPill(
                        icon: Icons.flag_rounded,
                        label: AppText.kanbanDetailCurrentState,
                        value: selected.state,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final detailWidth = constraints.maxWidth.isFinite
                          ? constraints.maxWidth
                          : RynMetrics.maxWidth;
                      final singleColumnFields = detailWidth < 1520;
                      final fieldWidth = singleColumnFields
                          ? detailWidth
                          : ((detailWidth - 12) / 2).clamp(220.0, 360.0);
                      final fields = [
                        _KanbanDetailField(
                          width: fieldWidth,
                          label: AppText.kanbanDetailTaskSummary,
                          value: selected.nextAction,
                        ),
                        _KanbanDetailField(
                          width: fieldWidth,
                          label: AppText.kanbanDetailOwnerRole,
                          value: selected.owner,
                        ),
                        _KanbanDetailField(
                          width: fieldWidth,
                          label: AppText.kanbanDetailAgentRole,
                          value: selected.owner,
                        ),
                        _KanbanDetailField(
                          width: fieldWidth,
                          label: AppText.kanbanDetailRecordStatus,
                          value: selected.record,
                        ),
                        _KanbanDetailField(
                          width: fieldWidth,
                          label: AppText.kanbanDetailBoundarySignal,
                          value: selected.boundary,
                        ),
                      ];

                      return Wrap(spacing: 12, runSpacing: 8, children: fields);
                    },
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MarkerPillRow(
                        children: [
                          _MarkerPill(
                            icon: Icons.info_outline_rounded,
                            text: AppText.kanbanCardSamplePlanningOnly,
                          ),
                          _MarkerPill(
                            icon: Icons.visibility_outlined,
                            text: AppText.markerStaticPrototypeInteraction,
                          ),
                        ],
                      ),
                      SizedBox(height: 7),
                      _MarkerPillRow(
                        children: [
                          _MarkerPill(
                            icon: Icons.storage_rounded,
                            text: AppText.markerNoDbPersistence,
                          ),
                          _MarkerPill(
                            icon: Icons.smart_toy_outlined,
                            text: AppText.markerNoLiveAgentExecution,
                          ),
                          _MarkerPill(
                            icon: Icons.near_me_disabled_rounded,
                            text: AppText.markerNoExternalSending,
                          ),
                        ],
                      ),
                      SizedBox(height: 7),
                      _MarkerPillRow(
                        children: [
                          _MarkerPill(
                            icon: Icons.view_column_outlined,
                            text: AppText.markerNoLaneMovement,
                          ),
                          _MarkerPill(
                            icon: Icons.back_hand_outlined,
                            text: AppText.markerNoDragDrop,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _KanbanSignalPill extends StatelessWidget {
  const _KanbanSignalPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: RynPalette.goldSoft,
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
        border: Border.all(color: RynPalette.gold.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: RynPalette.warning),
          const SizedBox(width: 6),
          Text(
            '$label · $value',
            style: const TextStyle(
              color: RynPalette.warning,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanDetailField extends StatelessWidget {
  const _KanbanDetailField({
    required this.label,
    required this.value,
    required this.width,
  });

  final String label;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: RynPalette.ivory,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RynPalette.ivoryLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: RynPalette.warmMuted,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: RynPalette.ink,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.title,
    required this.tasks,
    required this.width,
    required this.selectedTaskTitle,
    required this.onTaskSelected,
    this.compactCards = false,
  });

  final String title;
  final List<StaticKanbanTask> tasks;
  final double width;
  final String? selectedTaskTitle;
  final ValueChanged<StaticKanbanTask> onTaskSelected;
  final bool compactCards;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: RynPalette.ivorySoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: RynPalette.ivoryLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _KanbanStatePill(label: title),
          const SizedBox(height: 9),
          if (tasks.isEmpty)
            const _KanbanEmptyState()
          else
            for (final task in tasks) ...[
              _KanbanTaskCard(
                task: task,
                compact: compactCards,
                selected: task.title == selectedTaskTitle,
                onSelected: () => onTaskSelected(task),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _KanbanEmptyState extends StatelessWidget {
  const _KanbanEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: RynPalette.ivory,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RynPalette.ivoryLine),
      ),
      child: const Text(
        AppText.kanbanEmptyStaticSample,
        style: TextStyle(
          color: RynPalette.muted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _KanbanTaskCard extends StatelessWidget {
  const _KanbanTaskCard({
    required this.task,
    required this.selected,
    required this.onSelected,
    this.compact = false,
  });

  final StaticKanbanTask task;
  final bool selected;
  final VoidCallback onSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final stateColor = _stateColor(task.state);
    return Semantics(
      button: true,
      selected: selected,
      label: selected
          ? '${AppText.a11yKanbanSelectedCard}: ${task.title}'
          : '${AppText.a11yKanbanSelectCard}: ${task.title}',
      hint: AppText.kanbanDetailInspectionOnlyNote,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onSelected,
          child: Container(
            padding: EdgeInsets.all(compact ? 12 : 10),
            decoration: BoxDecoration(
              color: selected
                  ? RynPalette.goldSoft.withValues(alpha: 0.58)
                  : RynPalette.ivory,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? RynPalette.gold
                    : stateColor.withValues(alpha: 0.38),
                width: selected ? 1.8 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? RynPalette.gold.withValues(alpha: 0.18)
                      : const Color(0x12513A20),
                  blurRadius: selected ? 16 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _KanbanStatePill(label: task.state, small: true),
                    _KanbanMetaPill(label: task.risk),
                    const _KanbanMetaPill(
                      label: AppText.kanbanCardSamplePlanningOnly,
                    ),
                    if (selected)
                      const _KanbanMetaPill(
                        label: AppText.kanbanSelectionCardSelected,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task.title,
                  maxLines: compact ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RynPalette.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                _KanbanMetaLine(
                  label: AppText.kanbanCardOwner,
                  value: task.owner,
                  compact: compact,
                ),
                _KanbanMetaLine(
                  label: AppText.kanbanCardNext,
                  value: task.nextAction,
                  compact: compact,
                ),
                _KanbanMetaLine(
                  label: AppText.kanbanCardApproval,
                  value: task.approval,
                  compact: compact,
                ),
                _KanbanMetaLine(
                  label: AppText.kanbanCardRecord,
                  value: task.record,
                  compact: compact,
                ),
                _KanbanMetaLine(
                  label: AppText.kanbanCardBoundary,
                  value: task.boundary,
                  compact: compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _stateColor(String state) {
    return switch (state) {
      AppText.kanbanColumnRunning => RynPalette.lavenderStrong,
      AppText.kanbanColumnReview => RynPalette.warning,
      AppText.kanbanColumnApprovalWaiting => RynPalette.gold,
      AppText.kanbanColumnDoneRecorded => RynPalette.success,
      AppText.kanbanColumnBlocked => const Color(0xFFB4535D),
      AppText.kanbanColumnDeferred => RynPalette.warmMuted,
      _ => RynPalette.navy,
    };
  }
}

class _KanbanStatePill extends StatelessWidget {
  const _KanbanStatePill({required this.label, this.small = false});

  final String label;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: RynPalette.navy,
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _KanbanMetaPill extends StatelessWidget {
  const _KanbanMetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: RynPalette.goldSoft,
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: RynPalette.warning,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _KanbanMetaLine extends StatelessWidget {
  const _KanbanMetaLine({
    required this.label,
    required this.value,
    this.compact = false,
  });

  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: compact ? 54 : 58,
            child: Text(
              label,
              style: const TextStyle(
                color: RynPalette.warmMuted,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: compact ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: RynPalette.muted,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleAccessStrip extends StatelessWidget {
  const _ModuleAccessStrip();

  @override
  Widget build(BuildContext context) {
    return _LightCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Module Access',
            caption: '필요한 모듈만 조용히 열고, 명령 흐름을 방해하지 않습니다.',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final item in CoreOsShell.moduleItems)
                _ModuleChip(item: item),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrincipleFooter extends StatelessWidget {
  const _PrincipleFooter();

  @override
  Widget build(BuildContext context) {
    const principles = [
      ('Calm', '조용한 집중'),
      ('Control', '사용자 승인'),
      ('Continuity', '기록 연결'),
      ('Local-First', '로컬 우선'),
      ('AI-Native', 'AI 중심 설계'),
    ];
    return _LightCard(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final item in principles)
            _PrincipleChip(title: item.$1, caption: item.$2),
          const _QuoteBlock(),
        ],
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ultraCompact = compact && constraints.maxWidth < 260;
        final iconSize = ultraCompact ? 36.0 : 40.0;
        final gap = ultraCompact ? 8.0 : 10.0;
        final titleSize = ultraCompact ? 14.0 : 16.0;

        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ultraCompact ? 13 : 15),
                gradient: const LinearGradient(
                  colors: [RynPalette.navy, RynPalette.graphite],
                ),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: RynPalette.gold,
                size: ultraCompact ? 20 : 22,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppText.productName,
                    maxLines: ultraCompact ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: RynPalette.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: titleSize,
                      height: 1.05,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (!compact)
                    const Text(
                      'AI-native · Local-first · Calm · Premium',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: RynPalette.warmMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CommandSearchPlaceholder extends StatelessWidget {
  const _CommandSearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: RynPalette.ivorySoft,
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
        border: Border.all(color: RynPalette.ivoryLine),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: RynPalette.muted),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '검색 / 명령 / 흐름 / 기록...',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: RynPalette.muted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticMarkers extends StatelessWidget {
  const _StaticMarkers();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _MarkerPillRow(
              children: [
                _MarkerPill(
                  icon: Icons.visibility_outlined,
                  text: AppText.markerStaticPreview,
                ),
                _MarkerPill(
                  icon: Icons.pause_circle_outline_rounded,
                  text: AppText.markerNoAutomation,
                ),
              ],
            ),
            SizedBox(height: compact ? 7 : 8),
            const _MarkerPillRow(
              children: [
                _MarkerPill(
                  icon: Icons.rule_rounded,
                  text: AppText.markerSpecMvpBaseline,
                ),
                _MarkerPill(
                  icon: Icons.approval_rounded,
                  text: AppText.markerApprovalPacketOnly,
                ),
              ],
            ),
            SizedBox(height: compact ? 7 : 8),
            const _MarkerPillRow(
              children: [
                _MarkerPill(
                  icon: Icons.near_me_disabled_rounded,
                  text: AppText.markerNoTelegram,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _OwnerChip extends StatelessWidget {
  const _OwnerChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: RynPalette.ivorySoft,
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
        border: Border.all(color: RynPalette.ivoryLine),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InitialAvatar(initial: '린', size: 28, accent: RynPalette.gold),
          SizedBox(width: 7),
          Text(
            '린님',
            style: TextStyle(
              color: RynPalette.ink,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({required this.item, required this.active});
  final NavItem item;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: active ? RynPalette.navy : Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: active ? RynPalette.navy : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            item.icon,
            size: 18,
            color: active ? RynPalette.gold : RynPalette.muted,
          ),
          const SizedBox(width: 9),
          Text(
            item.label,
            style: TextStyle(
              color: active ? Colors.white : RynPalette.ink,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactNavChip extends StatelessWidget {
  const _CompactNavChip({required this.item, required this.active});
  final NavItem item;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active ? RynPalette.navy : RynPalette.ivorySoft,
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
        border: Border.all(
          color: active ? RynPalette.navy : RynPalette.ivoryLine,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            size: 16,
            color: active ? RynPalette.gold : RynPalette.muted,
          ),
          const SizedBox(width: 6),
          Text(
            item.label,
            style: TextStyle(
              color: active ? Colors.white : RynPalette.ink,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LightCard extends StatelessWidget {
  const _LightCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: RynPalette.ivory,
        borderRadius: BorderRadius.circular(RynMetrics.radiusShell),
        border: Border.all(color: RynPalette.ivoryLine),
        boxShadow: const [
          BoxShadow(
            color: RynPalette.shadow,
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InnerLightCard extends StatelessWidget {
  const _InnerLightCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RynPalette.ivorySoft,
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(color: RynPalette.ivoryLine),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.caption});
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: RynPalette.ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          caption,
          style: const TextStyle(
            color: RynPalette.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _MiniHeading extends StatelessWidget {
  const _MiniHeading({
    required this.icon,
    required this.title,
    required this.caption,
    this.onDark = false,
  });
  final IconData icon;
  final String title;
  final String caption;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: RynPalette.goldSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 17, color: RynPalette.warning),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: onDark ? const Color(0xFFEDE7D9) : RynPalette.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                caption,
                style: TextStyle(
                  color: onDark ? const Color(0xFFB9C2D5) : RynPalette.muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProcessRow extends StatelessWidget {
  const _ProcessRow({required this.labels});
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < labels.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TinyStep(label: labels[i], active: i < 2),
              if (i != labels.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: RynPalette.warmMuted,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _TinyStep extends StatelessWidget {
  const _TinyStep({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: active ? RynPalette.navy : RynPalette.ivory,
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
        border: Border.all(
          color: active ? RynPalette.navy : RynPalette.ivoryLine,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : RynPalette.muted,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MetricWrap extends StatelessWidget {
  const _MetricWrap({required this.metrics});
  final List<(String, String)> metrics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final metric in metrics)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: RynPalette.ivory,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: RynPalette.ivoryLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.$1,
                  style: const TextStyle(
                    color: RynPalette.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metric.$2,
                  style: const TextStyle(
                    color: RynPalette.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BoundaryList extends StatelessWidget {
  const _BoundaryList();

  @override
  Widget build(BuildContext context) {
    const items = [
      AppText.markerNoAutomation,
      AppText.markerNoTelegram,
      AppText.markerNoPortraitAsset,
      AppText.markerNoExecutionBeforeApproval,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 15,
                  color: RynPalette.success,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: RynPalette.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AgentChip extends StatelessWidget {
  const _AgentChip({required this.agent});
  final AgentProfile agent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 176),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: RynPalette.ivory,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RynPalette.ivoryLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InitialAvatar(
            initial: agent.initial,
            size: 30,
            accent: RynPalette.deepNavy,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RynPalette.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  agent.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RynPalette.muted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleChip extends StatelessWidget {
  const _ModuleChip({required this.item});
  final ModuleItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RynPalette.ivorySoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RynTokens.borderApproval,
          width: RynTokens.borderWidthHairline,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: RynPalette.lavender,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(item.icon, size: 18, color: RynPalette.lavenderStrong),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RynPalette.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                Text(
                  item.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RynPalette.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrincipleChip extends StatelessWidget {
  const _PrincipleChip({required this.title, required this.caption});
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: RynPalette.ivorySoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RynPalette.ivoryLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: RynPalette.warning,
          ),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: RynPalette.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                caption,
                style: const TextStyle(
                  color: RynPalette.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuoteBlock extends StatelessWidget {
  const _QuoteBlock();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        'AI와 사람, 기록과 승인이 하나로 연결된 조용한 Core OS',
        style: TextStyle(
          color: RynPalette.warmMuted,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DarkStatusTile extends StatelessWidget {
  const _DarkStatusTile({
    required this.label,
    required this.value,
    required this.icon,
    this.fullWidth = false,
  });
  final String label;
  final String value;
  final IconData icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: fullWidth
          ? const BoxConstraints(minWidth: 0)
          : const BoxConstraints(minWidth: 156, maxWidth: 210),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: RynTokens.borderSubtle,
          width: RynTokens.borderWidthHairline,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: RynPalette.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFAEB8CA),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  softWrap: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkerPillRow extends StatelessWidget {
  const _MarkerPillRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : RynMetrics.maxWidth;
        final compact = rowWidth < 980;

        if (compact) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: rowWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < children.length; index++) ...[
                  SizedBox(width: rowWidth, child: children[index]),
                  if (index != children.length - 1) const SizedBox(height: 7),
                ],
              ],
            ),
          );
        }

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: rowWidth),
          child: Wrap(spacing: 7, runSpacing: 7, children: children),
        );
      },
    );
  }
}

class _MarkerPill extends StatelessWidget {
  const _MarkerPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final finiteWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 320.0;
        final compact = finiteWidth < 980;
        final maxChipWidth = compact
            ? finiteWidth
            : math.min(finiteWidth, 320.0);
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxChipWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RynTokens.space3,
              vertical: RynTokens.space2,
            ),
            decoration: BoxDecoration(
              color: RynTokens.surfaceMarker,
              borderRadius: RynTokens.radiusChip,
              border: Border.all(color: RynTokens.borderStatic),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 15, color: RynTokens.kanbanMarkerStatic),
                const SizedBox(width: RynTokens.space2),
                Flexible(
                  child: Text(
                    text,
                    softWrap: true,
                    style: const TextStyle(
                      color: RynTokens.textStatic,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      height: 1.18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DarkPill extends StatelessWidget {
  const _DarkPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: RynPalette.gold),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                maxLines: 2,
                softWrap: true,
                style: const TextStyle(
                  color: Color(0xFFEDE7D9),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  height: 1.16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoundaryMini extends StatelessWidget {
  const _BoundaryMini({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: RynPalette.muted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _DarkIconBadge extends StatelessWidget {
  const _DarkIconBadge({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: RynPalette.lavenderStrong.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: RynPalette.lavenderStrong.withValues(alpha: 0.25),
        ),
      ),
      child: Icon(icon, color: RynPalette.gold, size: 17),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({
    required this.initial,
    this.size = 38,
    this.accent = RynPalette.navy,
  });
  final String initial;
  final double size;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [accent, RynPalette.graphite]),
        border: Border.all(color: RynPalette.gold.withValues(alpha: 0.45)),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.34,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
