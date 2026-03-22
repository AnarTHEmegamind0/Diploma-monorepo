---
description: QSF Audit app – screen navigation workflow (login → home → customer → map → campaign → category → images → thank you)
---

# QSF Audit – User Workflow

## Screen Flow

```
Login Page → Home Page → Customer Page → Map Page → Campaign Page → Category Page → Image Page → Thank You Page
    ▲                         ▲                                                                          │
    │                         │                                                                          │
    └─── Profile (Logout) ────┘──────────────────────────────────────────────────────────────────────────┘
```

## 1. Login Page (`features/auth/pages/login_page.dart`)
- Enter employee ID and password
- Taps "Нэвтрэх" to login
- **API**: `POST /auth/login`

## 2. Home Page (`features/home/pages/home_page.dart`)
- Shows greeting, daily task progress, XP level
- Quick action cards: Audit history, Saved drafts, Training
- Tap "Аудит эхлүүлэх" to start audit

## 3. Customer Page (`features/audit/pages/customer_page.dart`)
- Search and browse trade-shop (customer) list
- Zone-based filtering
- **API**: `GET /erp/tradeshops`
- Tap a customer to continue

## 4. Map Page (`features/audit/pages/map_page.dart`)
- Shows customer location on map
- Verifies auditor is at the location
- Tap "Аудит эхлүүлэх"

## 5. Campaign Page (`features/audit/pages/campaign_page.dart`)
- Lists available campaigns with category/question counts
- **API**: `GET /erp/audit/campaigns`
- Tap a campaign to continue

## 6. Category Page (`features/audit/pages/category_page.dart`)
- Shows categories with step-by-step progress
- Each category shows question count and image requirements
- Locked/unlocked state based on progress
- Tap image card to go to Image Page

## 7. Image Page (`features/audit/pages/image_page.dart`)
- Empty state with camera icon prompt
- Take photos via camera or pick from gallery
- Displays image grid with delete option
- Tap "Илгээх" to submit
- **API**: `POST /qsf/api/audit/submit` + `POST /qsf/api/audit/upload`

## 8. Thank You Page (`features/audit/pages/thank_you_page.dart`)
- Success confirmation with XP reward
- "Буцах" returns to Home

## Bottom Navigation Tabs
1. **Нүүр** (Home) – Home page
2. **Аудит** (Audit) – Customer selection
3. **Түүх** (History) – Audit history with filters
4. **Профайл** (Profile) – User profile & logout

---

## API Summary

### GET APIs (implemented – ready to use):
| Endpoint | Used In |
|---|---|
| `GET /erp/tradeshops` | Customer Page |
| `GET /erp/audit/campaigns` | Campaign Page |
| `GET /erp/tradeshops/version` | Cache invalidation |
| `GET /system/date` | Server time sync |
| `GET /erp/audit/training` | Training materials |

### POST APIs (stubs – user will provide details):
| Endpoint | Used In | Status |
|---|---|---|
| `POST /auth/login` | Login Page | ⚠️ Need to connect |
| `POST /erp/audit/campaign/variants` | Campaign variants | ⚠️ Need request body format |
| `POST /qsf/api/audit/submit` | Submit audit | ⚠️ Need final payload shape |
| `POST /qsf/api/audit/upload` | Upload images | ⚠️ Need final field names |
