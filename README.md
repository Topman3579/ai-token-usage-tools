# AI Token Usage Tools

เว็บ public-safe ภาษาไทยสำหรับเปรียบเทียบ 8 GitHub repositories ที่ติดตาม Token, Usage, Quota และค่าใช้จ่ายของ AI Coding Tools

## Development

```bash
npm install
npm run dev
```

## Verification

```bash
npm run lint
npm run build
```

ข้อมูลอ้างอิงจาก README ของแต่ละ repository และตรวจล่าสุดเมื่อ 16 กรกฎาคม 2026

## iPhone and iPad app

แอป SwiftUI สำหรับดู Usage จาก private Token Monitor hub อยู่ที่ [`ios/TokenMonitorMobile`](ios/TokenMonitorMobile). แอปรองรับ iPhone และ iPad, เก็บ shared secret ใน iOS Keychain และรับเฉพาะ hub URL แบบ HTTPS
