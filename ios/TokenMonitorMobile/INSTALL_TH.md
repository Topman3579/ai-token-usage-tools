# Token Monitor (AI Monitor) · iPhone / iPad

อัปเดต: 2026-08-04

## ภาพรวม

แอปมือถืออ่าน **private hub** บน rose:

| รายการ | ค่า |
|--------|-----|
| Hub URL | `https://rose.tailf4cb89.ts.net:17321` |
| API | `GET /api/stats` + `Authorization: Bearer <secret>` |
| Secret | เก็บใน **Keychain** บนมือถือ (ห้าม commit / แชท) |
| macOS hub | Token Monitor 0.36 · `hubMode=host` · port 17321 |

บัญชี AI เดียวกัน ≠ TOTAL tokens เท่ากันทุกเครื่อง  
TOTAL = log ต่อเครื่อง · ดูรวมที่ hub (rose)

## เงื่อนไขก่อนใช้มือถือ

1. **rose** เปิด Token Monitor (hub) — launchd `com.topmanidmb.token-monitor-hub` ช่วยเปิดตอน login  
2. `tailscale serve --bg --https=17321 17321` บน rose  
3. `curl -s http://127.0.0.1:17321/api/health` → `"role":"hub"`  
4. มือถือ: Tailscale Connected บน tailnet เดียวกัน  
5. travis / macpro: Token Monitor `hubMode=client` ชี้ hub URL ด้านบน

## ทาง A — ติดตั้งพัฒนา (ทำแล้วบนเครื่องผู้การ 16 ก.ค. 69)

```bash
cd ~/projects/ai-token-usage-tools/ios/TokenMonitorMobile
xcodegen generate
open TokenMonitorMobile.xcodeproj
```

Xcode → เลือก iPhone/iPad → Run  
bundle id: `net.topmanidmb.TokenMonitorMobile` · team `PV32ZHE46M`

ในแอป Settings:

- Hub URL: `https://rose.tailf4cb89.ts.net:17321`
- Shared secret: ค่าเดียวกับ Token Monitor macOS (Hub host secret) — อย่าแปะใน Git

## ทาง B — TestFlight

ยัง**ไม่ได้**อัปโหลด TestFlight อย่างเป็นทางการในรอบก่อน (ใช้ USB/dev แทน)

ขั้นตอนเมื่อผู้การต้องการ:

1. Xcode → Archive → Upload App Store Connect  
2. สร้าง app record ถ้ายังไม่มี (bundle `net.topmanidmb.TokenMonitorMobile`)  
3. TestFlight Internal → เพิ่ม tester  
4. ติดตั้งจาก TestFlight → ใส่ hub URL + secret เหมือนเดิม  
5. ยังต้องมี **Tailscale** เสมอ (hub ไม่ public)

## ซ่อม hub เมื่อตัวเลขค้าง

```bash
# บน rose
open -a "Token Monitor"
curl -s http://127.0.0.1:17321/api/health

# บน travis / macpro
open -a "Token Monitor"
# settings: hubMode=client, hubUrl=https://rose.tailf4cb89.ts.net:17321
```

Clients ที่ online จะอัปเดต `lastSeen` บน hub ภายใน ~15–30 วินาที
