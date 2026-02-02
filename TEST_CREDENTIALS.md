# Test Login Credentials

## 🔐 All Passwords: `password123`

---

## 👔 Senior Admin (No Branch/Department)

| Role | Email | Name |
|------|-------|------|
| **CEO** | ceo@acesupermarket.com | Chief Adebayo Williams |
| **COO** | coo@acesupermarket.com | Mrs. Folake Okonkwo |
| **HR** | hr1@acesupermarket.com | Mr. Chukwuma Nwosu |
| **HR** | hr2@acesupermarket.com | Miss Aisha Mohammed |
| **Auditor** | auditor1@acesupermarket.com | Mr. Tunde Bakare |

---

## 🏢 Branch Managers (13 Branches)

| Branch | Email | Name |
|--------|-------|------|
| Ace Mall, Oluyole | bm.mall,oluyole@acesupermarket.com | Mr. Adewale Johnson |
| Ace Mall, Bodija | bm.mall,bodija@acesupermarket.com | Mrs. Blessing Okoro |
| Ace Mall, Akobo | bm.mall,akobo@acesupermarket.com | Mr. Ibrahim Yusuf |
| Ace Mall, Oyo | bm.mall,oyo@acesupermarket.com | Mrs. Chioma Nwankwo |
| Ace Mall, Ogbomosho | bm.mall,ogbomosho@acesupermarket.com | Mr. Kunle Adeleke |

---

## 📋 Floor Managers (20 Total - SuperMarket & Lounge)

### **SuperMarket Floor Managers**

| Branch | Email | Name | Department |
|--------|-------|------|------------|
| Abeokuta | fm.abeokuta.su2@acesupermarket.com | Miss Shade Ogunleye | SuperMarket |
| Akobo | fm.akobo.su4@acesupermarket.com | Miss Zainab Ibrahim | SuperMarket |
| Bodija | fm.bodija.su6@acesupermarket.com | Miss Titilayo Ogunmola | SuperMarket |
| Ijebu | fm.ijebu.su8@acesupermarket.com | Mr. Kayode Ajayi | SuperMarket |
| Ilorin | fm.ilorin.su10@acesupermarket.com | Mr. Gbenga Afolabi | SuperMarket |

### **Lounge Floor Managers**

| Branch | Email | Name | Department |
|--------|-------|------|------------|
| Abeokuta | fm.abeokuta.lo1@acesupermarket.com | Mr. Gbenga Afolabi | Lounge |
| Akobo | fm.akobo.lo3@acesupermarket.com | Mr. Wale Akinwande | Lounge |
| Bodija | fm.bodija.lo5@acesupermarket.com | Mrs. Folashade Ajayi | Lounge |
| Ijebu | fm.ijebu.lo7@acesupermarket.com | Mr. Akeem Oladele | Lounge |
| Ilorin | fm.ilorin.lo9@acesupermarket.com | Mr. Damilola Ogunbiyi | Lounge |

---

## 👥 General Staff (107 Total)

### **Cashiers (40 staff)**
- **Email Pattern**: `cashier{1-40}.{branch}@acesupermarket.com`
- **Example**: cashier1.mall,oluyole@acesupermarket.com
- **Department**: SuperMarket

### **Waiters/Waitresses (26 staff)**
- **Email Pattern**: `waiter{1-26}.{branch}@acesupermarket.com`
- **Example**: waiter1.mall,oluyole@acesupermarket.com
- **Department**: Lounge

### **Security Guards (20 staff)**
- **Email Pattern**: `security{1-20}.{branch}@acesupermarket.com`
- **Example**: security1.mall,oluyole@acesupermarket.com
- **Department**: Facility Management

### **Cleaners (15 staff)**
- **Email Pattern**: `cleaner{1-15}.{branch}@acesupermarket.com`
- **Example**: cleaner1.mall,oluyole@acesupermarket.com
- **Department**: Facility Management

### **Arcade Attendants (7 staff)**
- **Email Pattern**: `arcade{1-7}.{branch}@acesupermarket.com`
- **Example**: arcade1.mall,oluyole@acesupermarket.com
- **Department**: Fun & Arcade

---

## 🎯 Quick Test Accounts

### **For Testing Floor Manager Features:**
```
Email: fm.abeokuta.lo1@acesupermarket.com
Password: password123
Role: Floor Manager (Lounge)
Branch: Ace Mall, Abeokuta
Department: Lounge
```

### **For Testing General Staff Features:**
```
Email: cashier1.mall,akobo@acesupermarket.com
Password: password123
Role: Cashier
Branch: Ace Mall, Akobo
Department: SuperMarket
```

### **For Testing HR Features:**
```
Email: hr1@acesupermarket.com
Password: password123
Role: Human Resource
Access: All branches, all departments
```

### **For Testing CEO Features:**
```
Email: ceo@acesupermarket.com
Password: password123
Role: Chief Executive Officer
Access: Full system access
```

---

## ✅ What Each Role Can Do

### **CEO/COO/HR/Auditor (Senior Admin)**
- ✅ View all staff across all branches
- ✅ Access all dashboards
- ✅ View all documents
- ✅ **HR Only**: Create/edit/delete staff accounts

### **Branch Managers**
- ✅ View staff in their branch
- ✅ Manage branch operations
- ✅ View branch statistics

### **Floor Managers**
- ✅ Create General Staff accounts in their department
- ✅ Manage their team roster
- ✅ Review staff performance
- ✅ Customize shift times
- ✅ View their team members

### **General Staff**
- ✅ View their own profile
- ✅ View their schedule
- ✅ View their reviews
- ✅ Update personal information
- ✅ Change password

---

## 🔒 Security Notes

- All passwords are hashed with bcrypt
- JWT tokens expire after 24 hours
- First-time login requires password change (future feature)
- Profile completion required after first login (future feature)

---

## 📊 Database Stats

- **Total Users**: 150
- **Senior Admin**: 7
- **Branch Managers**: 13
- **Floor Managers**: 20 (10 SuperMarket + 10 Lounge)
- **General Staff**: 110 (Cashiers, Waiters, Security, Cleaners, Arcade)

---

## 🚀 Testing the Floor Manager Staff Creation

1. **Login** as Floor Manager: `fm.abeokuta.lo1@acesupermarket.com`
2. **Dashboard** → Click "Add Team Member"
3. **Create Staff**:
   - Name: Test Staff Member
   - Email: teststaff@acesupermarket.com
   - Phone: 08012345678
   - Role: Select from dropdown (Lounge roles only)
   - Password: test123
4. **Submit** → Staff created successfully!
5. **Verify**: Staff can login with created credentials

---

**Last Updated**: November 26, 2025  
**Database**: aceSuperMarket  
**Seed File**: seed_150_staff_clean.sql
