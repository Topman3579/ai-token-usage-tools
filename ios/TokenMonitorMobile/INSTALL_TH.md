# Token Monitor (AI Monitor) · iPhone / iPad

อัปเดต: 2026-08-12

## ภาพรวม

แอปมือถืออ่าน private Token Monitor hub ผ่าน HTTPS ภายใน Tailscale เท่านั้น โดย repository สาธารณะนี้ไม่เก็บ hostname, tailnet หรือ port ที่ใช้งานจริง

| รายการ | ค่า |
|--------|-----|
| Hub URL | กำหนดจาก `tailscale serve status` บนเครื่อง host หรือกรอกใน Settings |
| API | `GET /api/stats` + `Authorization: Bearer <secret>` |
| Secret | เก็บใน Keychain บนมือถือและ build-time plist ที่ถูก ignore จาก Git |
| ตัวอย่างที่ใช้เชื่อมต่อไม่ได้ | `https://hub.example.invalid` |

บัญชี AI เดียวกันไม่ได้หมายความว่า TOTAL tokens จะเท่ากันทุกเครื่อง เพราะ TOTAL มาจาก log ต่อเครื่องและรวมผลที่ hub

## เงื่อนไขก่อนใช้มือถือ

1. เปิด Token Monitor แบบ hub บนเครื่องส่วนตัว
2. เปิด HTTPS เฉพาะใน tailnet โดยใช้ port จาก private host configuration
3. ตรวจ `/api/health` แล้วต้องได้ `"role":"hub"`
4. iPhone/iPad ต้องเชื่อมต่อ Tailscale ใน tailnet เดียวกัน
5. เครื่อง client อื่นต้องชี้ไปยัง Hub URL เดียวกัน

ตัวอย่างตั้งค่า host โดยไม่บันทึก topology จริงลง Git:

```zsh
read -r "TOKEN_MONITOR_HUB_PORT?Private hub port: "
tailscale serve --bg --https="$TOKEN_MONITOR_HUB_PORT" "$TOKEN_MONITOR_HUB_PORT"
tailscale serve status

read -r "TOKEN_MONITOR_HUB_URL?HTTPS URL from tailscale serve status: "
export TOKEN_MONITOR_HUB_URL
curl -sS "${TOKEN_MONITOR_HUB_URL%/}/api/health"
```

ห้ามใช้ `tailscale funnel` เพราะจะเปิด service ออกสู่อินเทอร์เน็ตสาธารณะ

## ทาง A — ติดตั้งพัฒนา

```bash
cd ~/projects/ai-token-usage-tools/ios/TokenMonitorMobile
xcodegen generate
open TokenMonitorMobile.xcodeproj
```

เลือก iPhone/iPad ใน Xcode แล้วกด Run จากนั้นกรอกในหน้า Settings:

- Hub URL: ค่า HTTPS ที่ได้จาก `tailscale serve status`
- Shared secret: ค่าเดียวกับ Token Monitor host — ห้าม commit หรือใส่ใน chat

แอปจะเก็บ Hub URL ใน UserDefaults และ secret ใน Keychain การอัปเกรดจากเวอร์ชันเดิมยังคงใช้ค่าที่เคยบันทึกไว้ได้ ส่วนการติดตั้งใหม่จะไม่มี endpoint เริ่มต้นจนกว่าจะกรอก Settings หรือ inject private build configuration

## ทาง B — TestFlight

สคริปต์ archive จะอ่าน Hub URL จากตัวแปร `TOKEN_MONITOR_HUB_URL` และอ่าน secret จากไฟล์ local ของ Token Monitor จากนั้นสร้าง `Sources/PrivateHub.plist` ซึ่งถูก `.gitignore` ไว้

```zsh
cd ~/projects/ai-token-usage-tools/ios/TokenMonitorMobile
read -r "TOKEN_MONITOR_HUB_URL?Private HTTPS hub URL: "
export TOKEN_MONITOR_HUB_URL
./scripts/upload-testflight.sh --archive
```

สคริปต์จะหยุดทันทีเมื่อ URL ไม่ใช่ HTTPS, มี username/password ฝังอยู่, ใช้โดเมนตัวอย่าง `.invalid` หรือหา secret ในเครื่องไม่พบ

หลังอัปโหลด:

1. ตรวจ app record ของ bundle `net.topmanidmb.TokenMonitorMobile`
2. รอ build ประมวลผลใน TestFlight
3. เพิ่ม internal tester
4. ติดตั้งแล้วตรวจ Hub URL และการเชื่อมต่อ Tailscale

## ซ่อม hub เมื่อตัวเลขค้าง

```zsh
open -a "Token Monitor"
read -r "TOKEN_MONITOR_HUB_URL?Private HTTPS hub URL: "
curl -sS "${TOKEN_MONITOR_HUB_URL%/}/api/health"
```

เปิด Token Monitor บนเครื่อง client และตรวจว่า `hubMode=client` ชี้ไปยัง URL เดียวกัน Clients ที่ online ควรอัปเดต `lastSeen` บน hub ภายในประมาณ 15–30 วินาที
