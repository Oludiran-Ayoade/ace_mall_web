# Department Restriction - Critical Fix ✅

## 🎯 **The Core Rule**

**Staff can ONLY be promoted within their own department OR to branch-level positions.**

### **Examples:**

**✅ ALLOWED:**
- Cashier (SuperMarket) → Floor Manager (SuperMarket)
- Cashier (SuperMarket) → Branch Manager (manages all departments)
- Chef (Eatery) → Floor Manager (Eatery)
- Floor Manager (SuperMarket) → Branch Manager

**❌ BLOCKED:**
- Cashier (SuperMarket) → Floor Manager (Eatery)
- Cashier (SuperMarket) → Floor Manager (Lounge)
- Chef (Eatery) → Floor Manager (SuperMarket)
- Cleaner (Pharmacy) → Floor Manager (Boutique)

---

## 🏢 **Department-Specific Roles**

### **Branch Departments:**
Each department has its own staff hierarchy:

**SuperMarket:**
```
Cashier (SuperMarket)
    ↓
Supervisor (SuperMarket)
    ↓
Floor Manager (SuperMarket)
    ↓
Branch Manager ← Can manage ALL departments
```

**Eatery:**
```
Chef (Eatery)
    ↓
Supervisor (Eatery)
    ↓
Floor Manager (Eatery)
    ↓
Branch Manager ← Can manage ALL departments
```

**Pharmacy:**
```
Pharmacist (Pharmacy)
    ↓
Supervisor (Pharmacy)
    ↓
Floor Manager (Pharmacy)
    ↓
Branch Manager ← Can manage ALL departments
```

**Lounge:**
```
Server (Lounge)
    ↓
Supervisor (Lounge)
    ↓
Floor Manager (Lounge)
    ↓
Branch Manager ← Can manage ALL departments
```

---

## 🔐 **Branch-Level Positions**

**These positions manage ALL departments and can be promoted to from any department:**

- ✅ Branch Manager
- ✅ Regional Manager
- ✅ Operations Manager
- ✅ Group Head
- ✅ COO
- ✅ CEO
- ✅ CFO
- ✅ CTO
- ✅ Chairman

**Example:**
- Floor Manager (SuperMarket) → Branch Manager ✅
- Floor Manager (Eatery) → Branch Manager ✅
- Floor Manager (Pharmacy) → Branch Manager ✅

---

## 🏢 **Corporate Departments**

**These are company-wide departments (not branch-specific):**

### **HR Department:**
```
HR Officer
    ↓
HR Manager
    ↓
Head of HR
```
**Rule:** HR staff can only advance within HR

### **Finance Department:**
```
Finance Officer
    ↓
Finance Manager
    ↓
Head of Finance / CFO
```
**Rule:** Finance staff can only advance within Finance

### **IT Department:**
```
IT Support
    ↓
IT Manager
    ↓
Head of IT / CTO
```
**Rule:** IT staff can only advance within IT

### **Compliance Department:**
```
Compliance Officer
    ↓
Compliance Manager
    ↓
Head of Compliance
```
**Rule:** Compliance staff can only advance within Compliance

### **Audit Department:**
```
Auditor
    ↓
Senior Auditor
    ↓
Head of Audit
```
**Rule:** Audit staff can only advance within Audit

---

## 📋 **Complete Promotion Matrix**

### **SuperMarket Department:**
| Current Role | Can Be Promoted To |
|-------------|-------------------|
| Cashier (SuperMarket) | Floor Manager (SuperMarket), Supervisor (SuperMarket) |
| Supervisor (SuperMarket) | Floor Manager (SuperMarket) |
| Floor Manager (SuperMarket) | Branch Manager |
| Cashier (SuperMarket) | ❌ Floor Manager (Eatery) |
| Cashier (SuperMarket) | ❌ Floor Manager (Lounge) |

### **Eatery Department:**
| Current Role | Can Be Promoted To |
|-------------|-------------------|
| Chef (Eatery) | Floor Manager (Eatery), Supervisor (Eatery) |
| Waiter (Eatery) | Floor Manager (Eatery), Supervisor (Eatery) |
| Floor Manager (Eatery) | Branch Manager |
| Chef (Eatery) | ❌ Floor Manager (SuperMarket) |
| Chef (Eatery) | ❌ Floor Manager (Pharmacy) |

### **Pharmacy Department:**
| Current Role | Can Be Promoted To |
|-------------|-------------------|
| Pharmacist (Pharmacy) | Floor Manager (Pharmacy), Supervisor (Pharmacy) |
| Floor Manager (Pharmacy) | Branch Manager |
| Pharmacist (Pharmacy) | ❌ Floor Manager (Eatery) |

---

## 🔧 **Technical Implementation**

### **Two-Layer Filtering:**

**Layer 1: Department Match**
```dart
bool _isRoleInSameDepartmentOrBranchLevel(targetRole, currentRole, currentDepartment) {
  // Allow branch-level positions (manage all departments)
  if (targetRole is Branch Manager or above) return true;
  
  // For department roles, must match current department
  if (currentDepartment == "SuperMarket") {
    return targetRole.contains("SuperMarket");
  }
  
  // Block cross-department promotions
  return false;
}
```

**Layer 2: Role Progression**
```dart
bool _canBePromotedTo(currentRole, targetRole) {
  // Check if progression is valid
  // Cashier → Floor Manager ✅
  // Cashier → Branch Manager ❌ (must be Floor Manager first)
}
```

---

## ✅ **Now Works Correctly**

### **Scenario 1: SuperMarket Cashier**
```
Current: Cashier (SuperMarket)

Available Promotions:
✅ Floor Manager (SuperMarket)
✅ Supervisor (SuperMarket)

Blocked:
❌ Floor Manager (Eatery)
❌ Floor Manager (Lounge)
❌ Floor Manager (Pharmacy)
❌ Group Head (Compliance)
```

### **Scenario 2: Eatery Chef**
```
Current: Chef (Eatery)

Available Promotions:
✅ Floor Manager (Eatery)
✅ Supervisor (Eatery)

Blocked:
❌ Floor Manager (SuperMarket)
❌ Floor Manager (Lounge)
❌ Branch Manager (must be Floor Manager first)
```

### **Scenario 3: SuperMarket Floor Manager**
```
Current: Floor Manager (SuperMarket)

Available Promotions:
✅ Branch Manager (manages all departments)

Blocked:
❌ Floor Manager (Eatery) (lateral move)
❌ Group Head (wrong progression)
```

---

## 🎯 **Key Benefits**

1. **Department Integrity** - Staff stay in their department
2. **Clear Progression** - Advance within your area of expertise
3. **No Cross-Department Chaos** - Can't jump between unrelated departments
4. **Branch Manager Gateway** - Only way to manage multiple departments

---

## 🚀 **Hot Restart Now!**

Test the fix:
1. ✅ Select **Cashier (SuperMarket)** → Only see Floor Manager (SuperMarket)
2. ✅ Select **Chef (Eatery)** → Only see Floor Manager (Eatery)
3. ✅ Select **Floor Manager (SuperMarket)** → Only see Branch Manager
4. ✅ No more cross-department promotions!

**Department restrictions are now enforced!** 🎉✨
