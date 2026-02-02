# Ace Supermarket - Hierarchy User Credentials

## Universal Password
**Password:** `password123`

---

## 👥 Senior Admin

### HR Administrator
- **Email:** hr@acesupermarket.com
- **Name:** Mr. Chukwuma Nwosu
- **Employee ID:** ACE-HR-001
- **Password:** password123

### Auditors
1. **Auditor 1**
   - **Email:** auditor1@acemarket.com
   - **Name:** Mr. Chukwudi Nwosu
   - **Employee ID:** ACE-AUD-101
   - **Password:** password123

2. **Auditor 2**
   - **Email:** auditor2@acemarket.com
   - **Name:** Mrs. Amaka Okafor
   - **Employee ID:** ACE-AUD-102
   - **Password:** password123

---

## 👔 Group Heads (Department Heads)

### SuperMarket Department
- **Email:** gh.supermarket@acemarket.com
- **Name:** Mr. Tunde Bakare
- **Employee ID:** ACE-GH-SM-001
- **Password:** password123

### Eatery Department
- **Email:** gh.eatery@acemarket.com
- **Name:** Mrs. Ngozi Eze
- **Employee ID:** ACE-GH-ET-001
- **Password:** password123

### Lounge Department
- **Email:** gh.lounge@acemarket.com
- **Name:** Mr. Segun Afolabi
- **Employee ID:** ACE-GH-LG-001
- **Password:** password123

### Fun & Arcade Department
- **Email:** gh.arcade@acemarket.com
- **Name:** Miss Funke Adeyemi
- **Employee ID:** ACE-GH-AR-001
- **Password:** password123

### Compliance Department
- **Email:** gh.compliance@acemarket.com
- **Name:** Mr. Ibrahim Yusuf
- **Employee ID:** ACE-GH-CP-001
- **Password:** password123

### Facility Management Department
- **Email:** gh.facility@acemarket.com
- **Name:** Mr. Emeka Obi
- **Employee ID:** ACE-GH-FM-001
- **Password:** password123

---

## 📋 Existing Credentials (For Reference)

### Branch Managers
- **Abeokuta:** bm.abeokuta@acesupermarket.com
- **Other branches:** Similar pattern

### Floor Managers
- **Abeokuta Lounge:** fm.abeokuta.lounge@acesupermarket.com
- **Other locations:** Similar pattern

### General Staff
- **Cashier (Abeokuta):** cashier.abeokuta1@acesupermarket.com
- **Other staff:** Similar pattern

---

## 🔐 Security Notes

1. All users should change their password on first login
2. Universal password is for initial setup only
3. Passwords are hashed using bcrypt in the database
4. All accounts are active and ready to use

---

## 📊 Hierarchy Structure

```
Senior Admin
├── HR Administrator (hr@acesupermarket.com)
└── Auditors
    ├── Auditor 1 (auditor1@acemarket.com)
    └── Auditor 2 (auditor2@acemarket.com)

Group Heads (Department Oversight)
├── SuperMarket (gh.supermarket@acemarket.com)
├── Eatery (gh.eatery@acemarket.com)
├── Lounge (gh.lounge@acemarket.com)
├── Fun & Arcade (gh.arcade@acemarket.com)
├── Compliance (gh.compliance@acemarket.com)
└── Facility Management (gh.facility@acemarket.com)

Branch Level
├── Branch Managers (per branch)
└── Floor Managers (per department per branch)
    └── General Staff (cashiers, waiters, etc.)
```

---

## ✅ Implementation Status

- ✅ HR Administrator: Already exists
- ✅ Auditors: Created successfully
- ✅ Group Heads: All 6 created successfully
- ✅ HR Dashboard: Now shows HR name
- ✅ Password: Universal password set for all

---

**Last Updated:** December 3, 2025
**Script Location:** `/backend/scripts/populate_hierarchy.go`
