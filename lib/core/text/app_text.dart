/// Internal text registry for Ryn Universe OS Core.
///
/// This is a lightweight Priority 1 text map, not a localization system.
/// Do not add l10n/ARB/JSON/generated resource behavior here.
abstract final class AppText {
  // Navigation
  static const navHome = '홈';
  static const navStudy = '스터디';
  static const navCommand = '명령';
  static const navControl = '관제';
  static const navFlow = '흐름';
  static const navRecord = '기록';
  static const navOutput = '산출';
  static const navSettings = '설정';

  // Product / Command
  static const productName = 'Ryn Universe OS Core';
  static const cmdAiCommandCenter = 'AI Command Center';
  static const cmdHomeHub = 'Home / Command Hub';
  static const cmdStatusStaticMvpMode = '정적 MVP 검토 모드';
  static const cmdNextActionSpecAlignedPatch = 'SPEC 기준 소스 정렬';
  static const cmdApprovalRiskBoundedSource = '중간 · 승인 범위 한정';
  static const cmdSafetyStatusStrip = 'Safety Status Strip';
  static const cmdCurrentVerdict = 'Current Verdict';
  static const cmdCouncilSessions = 'Council Sessions';
  static const cmdObsidianLinks = 'Obsidian Links';
  static const cmdIa1VerdictPassWithGuards = 'IA1: PASS WITH GUARDS';
  static const cmdScopeStaticShellOnly = 'Static shell only';
  static const cmdNextGateSourcePatchVerification =
      'Next gate: source patch verification';
  static const cmdConstructionStageMap = 'Construction Stage Map';
  static const cmdConstructionLedgerFiled = '공사 장부: GitHub 보관';
  static const cmdConstructionNextPermit = '다음 허가: Command Center UI 공사';
  static const cmdConstructionFenceInstalled = '.hermes 안전 펜스 설치';
  static const cmdNextPermitQueue = 'Next Permit Queue';
  static const cmdNextPermitPrimary = '1순위 · Next Permit Queue';
  static const cmdNextPermitCouncilGrowth = '7-Profile Council Growth Plan';
  static const cmdNextPermitDbBlueprint = 'DB Schema Blueprint · 문서 전용';
  static const cmdCouncilGrowthPlanDoc = 'Council Growth Plan 문서';
  static const cmdCouncilGrowthPlanDocId = 'RYN-CORE-COUNCIL-GROWTH-PLAN1';
  static const cmdCouncilGrowthPlanVault = 'Obsidian AI Command Center 기록';
  static const cmdDbBlueprintDoc = 'DB Blueprint 문서';
  static const cmdDbBlueprintDocId = 'RYN-CORE-DB-SCHEMA-BLUEPRINT-DOC1';
  static const cmdDbBlueprintHold = 'DB 구현 HOLD';
  static const cmdExternalAutomationPolicyDoc = 'External Automation Policy 문서';
  static const cmdExternalAutomationPolicyDocId =
      'RYN-CORE-EXTERNAL-AUTOMATION-POLICY1';
  static const cmdExternalAutomationHold = '외부 자동화 HOLD';
  static const cmdDailyHomeTitle = '린님 Daily Home';
  static const cmdDailyHomeToday = 'Today';
  static const cmdDailyHomeTodayBody = '오늘 이어갈 흐름을 한눈에 확인해요';
  static const cmdDailyHomeApproval = 'Pending approval';
  static const cmdDailyHomeApprovalBody = '새로 승인할 위험 작업은 없어요';
  static const cmdDailyHomeRecent = 'Recent result';
  static const cmdDailyHomeRecentBody = '최근 정리된 결과를 짧게 확인해요';
  static const cmdDailyHomeContinueCta = 'Continue';
  static const cmdDailyHomeContinueBody = '다음에 볼 작업을 준비해 두었어요';
  static const cmdDailyHomeContinueAction = '확인 준비됨';
  static const premiumHomeTitle = 'Ryn Universe Control Center';
  static const premiumHomeCaption = '린님의 AI 세계를 조정하는 프리미엄 종합 관제센터입니다.';
  static const premiumHomeCommandKicker = '오늘의 중심 미션';
  static const premiumHomeCommandTitle = 'LLM 운영 품질을 어워드급 기준으로 정렬';
  static const premiumHomeCommandBody =
      '실행보다 먼저 방향, 기준, 다음 행동을 선명하게 정리합니다. 위험 작업은 승인 전까지 움직이지 않습니다.';
  static const premiumHomeCommandReady = 'AI 조정 대기';
  static const missionCommandTitle = 'Universe Command Center';
  static const missionCommandSearch = '미션·기록·다음 행동 검색';
  static const missionCommandGovernanceButton = '승인 경계 안전';
  static const missionCommandExecuteReady = 'AI 대기 중';
  static const missionCommandOverview = '단지 상태 요약';
  static const missionCommandActive = '진행 중';
  static const missionCommandWaiting = '대기';
  static const missionCommandDone = '완료';
  static const missionCommandReliability = '신뢰도';
  static const missionCommandLoad = '운영 부하';
  static const missionCommandSelectedMission = 'Primary Mission';
  static const missionCommandMissionId = '#M-250519-11';
  static const missionCommandSelectedTitle = 'Ryn OS Core를 믿고 쓸 수 있는 첫 관제실로 정렬';
  static const missionCommandSelectedTag = 'AI 모델 운영';
  static const missionCommandProgress = '기준 정렬 50%';
  static const missionCommandNextStep =
      '다음 행동: Home first viewport redesign 검수';
  static const missionCommandStaticNote = '정적 관제 미리보기 · 자동 실행 없음';
  static const premiumHomeDailySignal = 'Daily Signal';
  static const premiumHomeTodaySignal = '오늘 이어갈 흐름';
  static const premiumHomeApprovalSignal = '승인할 위험 작업 없음';
  static const premiumHomeRecentSignal = '최근 정리 결과 확인';
  static const premiumHomeModuleDock = 'Module Dock';
  static const premiumHomeModuleDockCaption =
      '모듈은 보조 dock으로 낮추고, 중심 미션과 다음 행동을 먼저 둡니다.';
  static const cmdDailyHomeContinue = '오늘 이어갈 일';
  static const cmdDailyHomeApprovalOnly = '승인 필요한 일만 보기';
  static const cmdCommandHubTitle = 'Command Hub';
  static const cmdCommandHubCaption = '이어서 할 작업을 고르는 곳';
  static const cmdCommandHubContinue = 'Continue work';
  static const cmdCommandHubApproval = 'Approval check';
  static const cmdCommandHubRecent = 'Recent output';
  static const cmdCommandHubContinueBody = '다음 작업을 고르는 자리';
  static const cmdCommandHubApprovalBody = '위험 작업은 승인 후 진행';
  static const cmdCommandHubRecentBody = '최근 결과를 짧게 확인';
  static const cmdCommandHubStaticPreview = '정적 카드 shell';
  static const cmdChiefGovernanceDeck = 'Chief / Governance Deck';
  static const cmdDbClosedNoWrite = 'DB CLOSED / NO WRITE';
  static const cmdSchemaHold = 'Schema HOLD';
  static const cmdGitPushHold = 'Git PUSH HOLD';
  static const cmdExternalLocked = 'External LOCKED';
  static const cmdGatewayOff = 'Gateway OFF';
  static const cmdAutomationLocked = 'Automation LOCKED';
  static const cmdImplementationHold = 'Implementation HOLD';
  static const cmdCouncilIa1SpecSaved =
      'IA1 · Spec saved · Implementation HOLD';
  static const cmdCouncilGraph1Pass =
      'GRAPH1 · PASS WITH GUARDS · Implementation HOLD';
  static const cmdCouncilObsidianBackbone =
      'Obsidian Graph Backbone · PASS · Mass patch HOLD';
  static const cmdCouncilKanbanRuntimeHold =
      'Kanban Orchestra Static1 · Runtime QA HOLD';
  static const cmdObsidianProjectHome = 'PROJECT-HOME_Ryn_Universe_OS_Core';
  static const cmdObsidianMocCommandCenter = 'MOC-AI-Command-Center';
  static const cmdObsidianReportsIndex = 'INDEX-AI-Command-Center-Reports';
  static const cmdObsidianIa1Spec = 'RYN-CORE-COMMAND-CENTER-IA1-spec';
  static const cmdObsidianGraph1Index = 'INDEX-GRAPH1-Series';
  static const cmdObsidianKanbanIndex = 'INDEX-Kanban-Orch-Series';
  static const personaHermesName = 'Hermes';
  static const personaHermesRole = 'AI 운영 비서';
  static const agentCodex = 'Codex';
  static const agentCouncil = '7-Agent Council';
  static const recordObsidian = 'Obsidian';
  static const approvalGate = 'Approval Gate';
  static const boundarySignal = 'Boundary Signal';

  // Ryn Study OS 2.0 shell
  static const studyOsTitle = 'Ryn Study OS 2.0';
  static const studyOsCaption = '스터디 준비, 진행, 기록을 조용히 정리하는 첫 실사용 모듈';
  static const studyOsKicker = 'Minimum Viable Core · Study Module';
  static const studyOsStaticShellMarker = '정적 화면 shell';
  static const studyOsNoRuntimeDb = 'DB 연결 없음';
  static const studyOsNoCrud = '저장/수정 없음';
  static const studyScreenHome = '스터디 홈';
  static const studyScreenSessions = '스터디';
  static const studyScreenSessionDetail = '세션 상세';
  static const studyScreenMembers = '회원';
  static const studyScreenAttendance = '출석';
  static const studyScreenMaterials = '자료';
  static const studyScreenJournal = '기록';
  static const studyScreenReports = '리포트';
  static const studyScreenSettings = '설정';
  static const studyHomeHelper = '오늘 준비할 흐름을 한 화면에서 확인합니다.';
  static const studySessionsHelper = '계획된 세션과 진행 상태를 정리합니다.';
  static const studySessionDetailHelper = '목적, 준비 항목, 연결 자료를 확인합니다.';
  static const studyMembersHelper = '참여자와 기본 상태를 확인합니다.';
  static const studyAttendanceHelper = '세션 전 출석 준비와 당일 확인 흐름을 정리합니다.';
  static const studyMaterialsHelper = '자료 링크와 참고 항목을 모아 둡니다.';
  static const studyJournalHelper = '세션 후 메모와 다음 조치를 남깁니다.';
  static const studyReportsHelper = '요약과 후속 보고 초안을 확인합니다.';
  static const studyLocalSafetyHelper = '로컬 우선 원칙과 데이터 안전 경계를 확인합니다.';
  static const studyPrimaryActionPlan = '세션 준비';
  static const studyPrimaryActionReview = '흐름 확인';
  static const studyEmptyState = '아직 실제 데이터는 연결하지 않았습니다.';
  static const studyOverviewTitle = '오늘의 스터디 운영';
  static const studyOverviewBody = '세션 준비부터 기록까지, 필요한 화면만 차분히 배치합니다.';
  static const studyScreenMapTitle = '화면 구성';
  static const studyScreenMapBody = '9개 화면은 정적 shell이며 이후 데이터 연결을 기다립니다.';
  static const studySelectedScreenLabel = '선택한 화면';
  static const studyReadinessTitle = '준비 상태';
  static const studyReadinessLocalOnly = '로컬 우선';
  static const studyReadinessStatic = '정적 표시';
  static const studyReadinessNoSave = '저장 없음';

  // Static / honesty markers
  static const markerStaticPreview = '정적 미리보기';
  static const markerNoAutomation = '실제 자동화 없음';
  static const markerNoTelegram = '실제 Telegram 연동 없음';
  static const markerNoPortraitAsset = '초상 asset 없음';
  static const markerNoExecutionBeforeApproval = '승인 전 실행 없음';
  static const markerStaticOrchestraPreview = '정적 오케스트라 미리보기';
  static const markerNoTaskMovement = '실제 작업 이동 없음';
  static const markerNoDbPersistence = 'DB 저장 없음';
  static const markerNoTelegramSync = 'Telegram 연동 없음';
  static const markerStaticPrototypeInteraction = '정적 프로토타입 상호작용';
  static const markerNoLiveAgentExecution = '실시간 에이전트 실행 없음';
  static const markerNoExternalSending = '외부 전송 없음';
  static const markerNoTelegramApiProviderCronjob =
      'Telegram/API/Provider/Cronjob 연동 없음';
  static const markerNoRealStatusTransition = '실제 작업 상태 변경 없음';
  static const markerNoLaneMovement = '레인 이동 없음';
  static const markerNoDragDrop = '드래그 앤 드롭 없음';
  static const markerSpecMvpBaseline = 'SPEC-AI-CMD-MVP1 기준';
  static const markerApprovalPacketOnly = '승인 패킷 범위 한정';

  // Marker composites that preserve current visible wording exactly.
  static const markerStaticNoAutomationSummary = '정적 미리보기 · 실제 자동화 없음';
  static const markerStaticAutomationTelegramSummary =
      '정적 미리보기 · 실제 자동화 없음 · 실제 Telegram 연동 없음';
  static const markerPortraitAssetSummary = '전문 역할 칩 · 초상 asset 없음';

  // Kanban core
  static const kanbanTitleOrchestra = 'Kanban Orchestra';
  static const kanbanCaptionStaticOperationsLane =
      'AI 작업 흐름을 정적으로 미리 보는 운영 레인입니다.';
  static const kanbanSnapshotTitle = '운영 스냅샷';
  static const kanbanSnapshotBaseline = '계약 기준선';
  static const kanbanSnapshotBaselineValue = 'Mission/TaskCard fake PASS';
  static const kanbanSnapshotNextSlice = '다음 구현';
  static const kanbanSnapshotNextSliceValue = '정적 오케스트라 개선';
  static const kanbanSnapshotBoundary = '금지 경계';
  static const kanbanSnapshotBoundaryValue = 'DB·실행·외부연동 HOLD';
  static const kanbanEmptyStaticSample = '정적 샘플 없음';
  static const kanbanColumnReady = 'Ready';
  static const kanbanColumnRunning = 'Running';
  static const kanbanColumnReview = 'Review';
  static const kanbanColumnApprovalWaiting = 'Approval Waiting';
  static const kanbanColumnDoneRecorded = 'Done / Recorded';
  static const kanbanColumnBlocked = 'Blocked';
  static const kanbanColumnDeferred = 'Deferred';

  // Approved future card-field labels from TEXT-GOV3.
  static const kanbanCardRiskLevel = 'Risk Level';
  static const kanbanCardOwnerAgent = 'Owner / Agent';
  static const kanbanCardNextAction = 'Next Action';
  static const kanbanCardRecordStatus = 'Record Status';
  static const kanbanCardBoundarySignal = 'Boundary Signal';

  // Current card-field labels retained to preserve visible UI exactly in TEXT-GOV4.
  static const kanbanCardOwner = 'Owner';
  static const kanbanCardNext = 'Next';
  static const kanbanCardApproval = 'Approval';
  static const kanbanCardRecord = 'Record';
  static const kanbanCardBoundary = 'Boundary';

  // Kanban interaction prototype text from KANBAN-ORCH6.
  static const kanbanCardSamplePlanningOnly = '샘플/기획용 카드';
  static const kanbanSelectionCardSelected = '카드가 선택되었습니다';
  static const kanbanSelectionNoneSelected = '선택된 카드 없음';
  static const kanbanSelectionOnlyNoMove = '선택만 가능하며 작업은 이동하지 않습니다';
  static const kanbanSelectionPrototypeOnly = '프로토타입 상호작용만 제공됩니다';
  static const kanbanSelectionResetsOnRestart = '앱을 다시 열면 선택 상태가 초기화됩니다';
  static const kanbanDetailOpen = '카드 상세 보기';
  static const kanbanDetailClose = '상세 닫기';
  static const kanbanDetailTaskSummary = '작업 요약';
  static const kanbanDetailOwnerRole = '담당 역할';
  static const kanbanDetailAgentRole = '에이전트 역할';
  static const kanbanDetailRiskLevel = '위험도';
  static const kanbanDetailApprovalState = '승인 상태';
  static const kanbanDetailCurrentState = '현재 상태';
  static const kanbanDetailRecordStatus = '기록 상태';
  static const kanbanDetailBoundarySignal = '경계 신호';
  static const kanbanDetailInspectionOnlyNote = '이 동작은 확인용이며 작업을 실행하지 않습니다';
  static const approvalRequired = '승인 필요';
  static const approvalNotRequired = '승인 불필요';
  static const approvalPending = '승인 대기';
  static const approvalCompletedPreview = 'completed';
  static const approvalReviewPreview = 'review';
  static const approvalWaitingPreview = 'waiting';
  static const approvalNotRequestedPreview = 'not requested';
  static const riskLevelOne = 'Level 1';
  static const riskLevelTwo = 'Level 2';
  static const riskLevelFour = 'Level 4';
  static const kanbanStateQaPending = 'QA 대기';
  static const kanbanStateCompleted = '완료됨';
  static const kanbanMsgSelectCardToPreview = '카드를 선택하면 상세 미리보기가 표시됩니다';
  static const a11yKanbanSelectCard = 'Kanban 카드 선택';
  static const a11yKanbanSelectedCard = '선택된 Kanban 카드';
  static const a11yKanbanDetailInspection = '카드 상세 확인';
}
