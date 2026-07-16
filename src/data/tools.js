export const tools = [
  {
    name: 'WhereMyTokens',
    url: 'https://github.com/jeongwookie/WhereMyTokens',
    platform: 'Windows · macOS แยก repo',
    supports: 'Claude · Codex · Antigravity',
    highlight: 'Quota, token, cost และ session แบบ local-first',
    bestFor: 'ผู้ใช้ที่ต้องการภาพรวมละเอียดใน tray',
    tags: ['windows', 'macos', 'claude', 'codex'],
  },
  {
    name: 'Win-CodexBar',
    url: 'https://github.com/Finesssee/Win-CodexBar',
    platform: 'Windows',
    supports: '56 providers',
    highlight: 'Provider ครบมาก พร้อม tray และ CLI',
    bestFor: 'Windows ที่ใช้หลายบริการ AI',
    tags: ['windows', 'claude', 'codex'],
  },
  {
    name: 'TokenTracker',
    url: 'https://github.com/mm7894215/TokenTracker',
    platform: 'macOS · Windows · CLI',
    supports: '27 coding tools',
    highlight: 'Dashboard และ widget แบบ local-only',
    bestFor: 'ติดตามหลายเครื่องมือบนเครื่องเดียว',
    tags: ['macos', 'windows', 'claude', 'codex'],
  },
  {
    name: 'token-monitor',
    url: 'https://github.com/Javis603/token-monitor',
    platform: 'macOS · Windows · Linux',
    supports: 'Claude · Codex · Hermes · OpenClaw · Grok+',
    highlight: 'รวมหลายเครื่องผ่าน self-hosted hub ได้',
    bestFor: 'AI Fleet และงานข้ามอุปกรณ์',
    tags: ['macos', 'windows', 'fleet', 'claude', 'codex'],
  },
  {
    name: 'claude-usage',
    url: 'https://github.com/phuryn/claude-usage',
    platform: 'macOS · Linux · Windows',
    supports: 'Claude Code',
    highlight: 'สแกน JSONL เป็น token, cost และ session history',
    bestFor: 'วิเคราะห์ Claude ย้อนหลังอย่างละเอียด',
    tags: ['macos', 'windows', 'claude'],
  },
  {
    name: 'Claude-Code-Usage-Monitor',
    url: 'https://github.com/CodeZeno/Claude-Code-Usage-Monitor',
    platform: 'Windows · WSL',
    supports: 'Claude · Codex · Antigravity',
    highlight: 'แถบ quota และ reset countdown บน taskbar',
    bestFor: 'Windows ที่ต้องการดู limit ตลอดเวลา',
    tags: ['windows', 'claude', 'codex'],
  },
  {
    name: 'usage-monitor-for-claude',
    url: 'https://github.com/jens-duttke/usage-monitor-for-claude',
    platform: 'Windows',
    supports: 'Claude',
    highlight: 'Portable EXE เดียว เบาและตั้งค่าน้อย',
    bestFor: 'เช็ก Claude session/weekly limit แบบเร็ว',
    tags: ['windows', 'claude'],
  },
  {
    name: 'claude-usage-widget',
    url: 'https://github.com/SlavomirDurej/claude-usage-widget',
    platform: 'macOS · Windows · Linux',
    supports: 'Claude.ai',
    highlight: 'Widget, history 7 วัน และ usage alerts',
    bestFor: 'ผู้ใช้ที่ชอบ widget แบบ always-on-top',
    tags: ['macos', 'windows', 'claude'],
  },
]

export const filters = [
  { id: 'all', label: 'ทั้งหมด' },
  { id: 'macos', label: 'macOS' },
  { id: 'windows', label: 'Windows' },
  { id: 'fleet', label: 'หลายเครื่อง' },
  { id: 'claude', label: 'Claude' },
  { id: 'codex', label: 'Codex' },
]

export const recommendations = [
  {
    title: 'AI Fleet หลายเครื่อง',
    description: 'รองรับเครื่องมือหลายค่ายและรวมตัวเลขสรุปผ่าน self-hosted hub',
    tool: 'token-monitor',
    url: 'https://github.com/Javis603/token-monitor',
  },
  {
    title: 'Local-only เครื่องเดียว',
    description: 'รองรับ 27 coding tools โดยไม่ต้องมี cloud account หรือ API key',
    tool: 'TokenTracker',
    url: 'https://github.com/mm7894215/TokenTracker',
  },
  {
    title: 'เจาะ Claude โดยเฉพาะ',
    description: 'อ่าน local JSONL เพื่อวิเคราะห์ token, model, cost และ session ย้อนหลัง',
    tool: 'claude-usage',
    url: 'https://github.com/phuryn/claude-usage',
  },
]

export const securityChecks = [
  'อ่านสิทธิ์เข้าถึงไฟล์ session',
  'ตรวจ network และ telemetry',
  'เริ่มจาก Local Mode',
  'อย่าเปิดเผย API key หรือข้อมูลโปรเจกต์',
]
