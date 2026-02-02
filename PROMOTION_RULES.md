# Smart Promotion Rules - Career Progression Paths 🎯

## 🎓 **Intelligent Role Filtering**

The system now implements **realistic career progression paths** based on:
- Current role and department
- Organizational hierarchy
- Industry-standard promotion paths
- Department-specific advancement

**No more illogical promotions!** ✅
- ❌ Cashier → Head of Compliance (BLOCKED)
- ✅ Cashier → Floor Manager (ALLOWED)
- ❌ Chef → IT Manager (BLOCKED)
- ✅ Floor Manager → Branch Manager (ALLOWED)

---

## 📋 **Promotion Rules by Role**

### **RULE 1: General Staff → Floor Management**
**Current Roles:**
- Cashier
- Sales Assistant
- Attendant
- General Assistant

**Can Be Promoted To:**
- ✅ Floor Manager (in same department)
- ✅ Supervisor (in same department)

**Example:**
- Cashier (SuperMarket) → Floor Manager (SuperMarket) ✅
- Cashier (SuperMarket) → Floor Manager (Eatery) ❌

---

### **RULE 2: Floor Manager → Branch Manager**
**Current Role:**
- Floor Manager

**Can Be Promoted To:**
- ✅ Branch Manager

**Logic:** Floor Managers have operational experience managing a department, making them qualified to manage an entire branch.

---

### **RULE 3: Operations Officer → Branch Manager**
**Current Role:**
- Operations Officer
- Operation Officer

**Can Be Promoted To:**
- ✅ Branch Manager

**Logic:** Operations Officers oversee branch operations and are natural candidates for Branch Manager.

---

### **RULE 4: Supervisor → Mid-Management**
**Current Role:**
- Supervisor

**Can Be Promoted To:**
- ✅ Floor Manager
- ✅ Operations Officer

**Logic:** Supervisors have team leadership experience and can advance to department or operations management.

---

### **RULE 5: Branch Manager → Regional Leadership**
**Current Role:**
- Branch Manager

**Can Be Promoted To:**
- ✅ Regional Manager
- ✅ Group Head
- ✅ Operations Manager

**Logic:** Successful branch managers can oversee multiple branches or lead operational groups.

---

### **RULE 6: Department-Specific Roles**

#### **Compliance Department:**
```
Compliance Officer
    ↓
Compliance Manager
    ↓
Head of Compliance
```
**Rule:** Compliance staff can only advance within compliance.

#### **HR Department:**
```
HR Officer
    ↓
HR Manager
    ↓
Head of HR / HR Director
```
**Rule:** HR professionals advance within HR function.

#### **Finance Department:**
```
Finance Officer
    ↓
Finance Manager
    ↓
Head of Finance / Finance Director
```
**Rule:** Finance staff stay in finance career path.

#### **IT Department:**
```
IT Support / IT Officer
    ↓
IT Manager
    ↓
Head of IT / IT Director
```
**Rule:** Technical staff advance within IT.

#### **Audit Department:**
```
Auditor
    ↓
Senior Auditor
    ↓
Head of Audit / Audit Manager
```
**Rule:** Auditors follow audit career progression.

---

### **RULE 7: Department Heads → C-Level**
**Current Roles:**
- Group Head
- Regional Manager
- Head of [Department]

**Can Be Promoted To:**
- ✅ COO (Chief Operating Officer)
- ✅ CFO (Chief Financial Officer)
- ✅ CTO (Chief Technology Officer)
- ✅ Director

**Logic:** Department heads with proven leadership can advance to executive positions.

---

### **RULE 8: C-Level → CEO**
**Current Roles:**
- COO
- CFO
- CTO
- Director

**Can Be Promoted To:**
- ✅ CEO (Chief Executive Officer)
- ✅ Chairman

**Logic:** C-level executives are qualified for top leadership positions.

---

## 🎯 **Career Progression Paths**

### **Path 1: Branch Operations**
```
Cashier/Sales Assistant (General)
    ↓
Supervisor (General)
    ↓
Floor Manager (Admin)
    ↓
Branch Manager (Admin)
    ↓
Regional Manager (Senior Admin)
    ↓
COO (Senior Admin)
    ↓
CEO (Senior Admin)
```

### **Path 2: Specialized Departments**
```
Department Officer (General)
    ↓
Department Manager (Admin)
    ↓
Head of Department (Senior Admin)
    ↓
Director (Senior Admin)
    ↓
CEO (Senior Admin)
```

### **Path 3: Operations Track**
```
Operations Officer (Admin)
    ↓
Branch Manager (Admin)
    ↓
Operations Manager (Senior Admin)
    ↓
COO (Senior Admin)
```

---

## ✅ **Examples of Valid Promotions**

### **Branch Staff:**
- ✅ Cashier → Floor Manager
- ✅ Floor Manager → Branch Manager
- ✅ Branch Manager → Regional Manager
- ✅ Operations Officer → Branch Manager

### **Department Staff:**
- ✅ HR Officer → HR Manager
- ✅ HR Manager → Head of HR
- ✅ Finance Officer → Finance Manager
- ✅ Auditor → Senior Auditor

### **Senior Leadership:**
- ✅ Head of Finance → CFO
- ✅ Regional Manager → COO
- ✅ COO → CEO

---

## ❌ **Examples of Blocked Promotions**

### **Cross-Department (Blocked):**
- ❌ Cashier → Head of Compliance
- ❌ Chef → IT Manager
- ❌ Sales Assistant → HR Manager
- ❌ Compliance Officer → Finance Manager

### **Skipping Levels (Blocked):**
- ❌ Cashier → Branch Manager (must go through Floor Manager)
- ❌ HR Officer → Head of HR (must go through HR Manager)
- ❌ Auditor → Head of Audit (must go through Senior Auditor)

### **Lateral Moves (Blocked):**
- ❌ Floor Manager → Operations Officer (different track)
- ❌ Branch Manager → Head of HR (different function)

---

## 🔧 **Technical Implementation**

### **Filtering Logic:**
```dart
List<dynamic> _getAvailableRoles() {
  // 1. Check hierarchy (must be higher)
  if (roleHierarchy <= currentHierarchy) return false;
  
  // 2. Apply specific promotion rules
  return _canBePromotedTo(currentRole, targetRole, department);
}
```

### **Rule Checking:**
```dart
bool _canBePromotedTo(String currentRole, String targetRole, String department) {
  // Check current role against target role
  // Apply department-specific rules
  // Ensure logical career progression
  // Block cross-department promotions
}
```

---

## 📊 **Benefits**

### **For HR:**
1. **Prevents Errors** - No illogical promotions
2. **Saves Time** - Only shows valid options
3. **Ensures Compliance** - Follows org structure
4. **Clear Paths** - Transparent career progression

### **For Staff:**
1. **Clear Expectations** - Know advancement paths
2. **Fair Process** - Consistent rules for all
3. **Realistic Goals** - Achievable next steps
4. **Department Focus** - Specialize in their field

### **For Organization:**
1. **Maintains Structure** - Proper hierarchy
2. **Prevents Chaos** - No random promotions
3. **Professional** - Industry-standard paths
4. **Scalable** - Works as company grows

---

## 🎯 **Key Principles**

1. **Department Alignment** - Staff advance within their department
2. **Hierarchy Respect** - Can't skip levels
3. **Experience Required** - Must have relevant background
4. **Logical Progression** - Each step builds on previous
5. **Branch to Corporate** - Clear path from branch to HQ

---

## 💡 **Special Cases**

### **Branch Manager Requirements:**
**Only these roles can become Branch Manager:**
- ✅ Floor Manager (proven department management)
- ✅ Operations Officer (proven operations management)
- ❌ Any other role (insufficient experience)

### **Department Head Requirements:**
**Must have worked in that department:**
- ✅ HR Manager → Head of HR
- ✅ Finance Manager → Head of Finance
- ❌ IT Manager → Head of HR (wrong department)

### **C-Level Requirements:**
**Must be a Department Head or Regional Manager:**
- ✅ Head of Finance → CFO
- ✅ Regional Manager → COO
- ❌ Branch Manager → COO (must be Regional first)

---

## 🚀 **Hot Restart Now!**

Test the smart filtering:

1. ✅ Select a **Cashier** → Only see Floor Manager/Supervisor
2. ✅ Select a **Floor Manager** → Only see Branch Manager
3. ✅ Select an **HR Officer** → Only see HR Manager
4. ✅ Select a **Branch Manager** → Only see Regional/Group Head
5. ✅ Try to promote **Cashier to Compliance** → Not in list! ✅

**The system now enforces realistic career progression!** 🎉✨

---

## 📝 **Summary**

**Before:**
- ❌ Could promote anyone to anything
- ❌ Illogical career jumps
- ❌ Cross-department chaos

**After:**
- ✅ Only shows valid next steps
- ✅ Logical career progression
- ✅ Department-specific paths
- ✅ Industry-standard advancement

**The promotion system is now intelligent and realistic!** 🎓
