-- ============================================================
-- Rockstar Academy Database Management System
-- Oracle SQL Schema (3NF Normalized)
-- ============================================================


-- ------------------------------------------------------------
-- PARENT_INFO
-- Separated from MEMBER to resolve transitive dependency (3NF)
-- ------------------------------------------------------------
CREATE TABLE PARENT_INFO (
    ParentID        VARCHAR2(10)    PRIMARY KEY,
    Parent_Name     VARCHAR2(100)   NOT NULL,
    Parent_Phone    VARCHAR2(20)    NOT NULL,
    Parent_Email    VARCHAR2(100)
);


-- ------------------------------------------------------------
-- MEMBER
-- ------------------------------------------------------------
CREATE TABLE MEMBER (
    MemberID            VARCHAR2(10)    PRIMARY KEY,
    Name                VARCHAR2(100)   NOT NULL,
    Date_Of_Birth       DATE            NOT NULL,
    Address             VARCHAR2(255),
    School              VARCHAR2(100),
    ParentID            VARCHAR2(10),
    Membership_Type     VARCHAR2(20)    DEFAULT 'Normal'
                                        CHECK (Membership_Type IN ('VIP', 'Normal')),
    Total_Class_Attended NUMBER(5)      DEFAULT 0,
    Classes_Registered  NUMBER(3)       DEFAULT 0
                                        CHECK (Classes_Registered <= 21),
    Remaining_Sessions  NUMBER(5)       DEFAULT 0,
    CONSTRAINT fk_member_parent FOREIGN KEY (ParentID)
        REFERENCES PARENT_INFO(ParentID)
);


-- ------------------------------------------------------------
-- COACH
-- ------------------------------------------------------------
CREATE TABLE COACH (
    CoachID         VARCHAR2(10)    PRIMARY KEY,
    Name            VARCHAR2(100)   NOT NULL,
    Gender          VARCHAR2(10)    CHECK (Gender IN ('Male', 'Female')),
    Skill_Level     VARCHAR2(20),
    Contact_Info    VARCHAR2(100)
);


-- ------------------------------------------------------------
-- MANAGER
-- ------------------------------------------------------------
CREATE TABLE MANAGER (
    ManagerID       VARCHAR2(10)    PRIMARY KEY,
    ITTeamID        VARCHAR2(10),
    Name            VARCHAR2(100)   NOT NULL,
    Contact_Info    VARCHAR2(100),
    Academy_Managed NUMBER(3)
);


-- ------------------------------------------------------------
-- ACADEMY
-- ------------------------------------------------------------
CREATE TABLE ACADEMY (
    AcademyID       VARCHAR2(10)    PRIMARY KEY,
    Name            VARCHAR2(100)   NOT NULL,
    Location        VARCHAR2(255),
    Total_Classes   NUMBER(5)       DEFAULT 0,
    Total_Membership NUMBER(5)      DEFAULT 0,
    ManagerID       VARCHAR2(10),
    CONSTRAINT fk_academy_manager FOREIGN KEY (ManagerID)
        REFERENCES MANAGER(ManagerID)
);


-- ------------------------------------------------------------
-- CLASS
-- ------------------------------------------------------------
CREATE TABLE CLASS (
    ClassID         VARCHAR2(10)    PRIMARY KEY,
    Class_Name      VARCHAR2(100)   NOT NULL,
    Class_Type      VARCHAR2(50)    CHECK (Class_Type IN (
                        'Gymnastics', 'Basketball', 'Martial Arts',
                        'Ballet', 'Baby Jam', 'Sport', 'Private'
                    )),
    Age_Group       VARCHAR2(20),
    Skill_Level     VARCHAR2(20),
    Capacity        NUMBER(3)       DEFAULT 30,
    Start_Time      TIMESTAMP,
    End_Time        TIMESTAMP,
    AcademyID       VARCHAR2(10),
    CoachID         VARCHAR2(10),
    CONSTRAINT fk_class_academy FOREIGN KEY (AcademyID)
        REFERENCES ACADEMY(AcademyID),
    CONSTRAINT fk_class_coach FOREIGN KEY (CoachID)
        REFERENCES COACH(CoachID)
);


-- ------------------------------------------------------------
-- EQUIPMENT
-- ------------------------------------------------------------
CREATE TABLE EQUIPMENT (
    EquipmentID         VARCHAR2(10)    PRIMARY KEY,
    Name                VARCHAR2(100)   NOT NULL,
    Type                VARCHAR2(50),
    Quantity_Available  NUMBER(5)       DEFAULT 0
);


-- ------------------------------------------------------------
-- SPECIAL_SUPPORT
-- ------------------------------------------------------------
CREATE TABLE SPECIAL_SUPPORT (
    SupportID           VARCHAR2(10)    PRIMARY KEY,
    Type                VARCHAR2(100),
    Cost                NUMBER(10, 2),
    Sessions_Available  NUMBER(5)
);


-- ------------------------------------------------------------
-- PROGRESS_REPORT
-- ------------------------------------------------------------
CREATE TABLE PROGRESS_REPORT (
    ReportID            VARCHAR2(10)    PRIMARY KEY,
    MemberID            VARCHAR2(10)    NOT NULL,
    CoachID             VARCHAR2(10)    NOT NULL,
    ManagerID           VARCHAR2(10),
    Skills_Learned      VARCHAR2(500),
    Attendance_Count    NUMBER(3),
    CONSTRAINT fk_report_member FOREIGN KEY (MemberID)
        REFERENCES MEMBER(MemberID),
    CONSTRAINT fk_report_coach FOREIGN KEY (CoachID)
        REFERENCES COACH(CoachID),
    CONSTRAINT fk_report_manager FOREIGN KEY (ManagerID)
        REFERENCES MANAGER(ManagerID)
);


-- ------------------------------------------------------------
-- IT_TEAM
-- ------------------------------------------------------------
CREATE TABLE IT_TEAM (
    ITTeamID        VARCHAR2(10)    PRIMARY KEY,
    Name            VARCHAR2(100)   NOT NULL,
    Contact_Info    VARCHAR2(100),
    KPI_Data        VARCHAR2(255),
    Sales           NUMBER(10, 2)
);


-- ============================================================
-- BRIDGE / JUNCTION TABLES (Many-to-Many relationships)
-- ============================================================

-- MEMBER <-> CLASS (a member attends many classes; a class has many members)
CREATE TABLE MEMBER_CLASS (
    MemberID    VARCHAR2(10)    NOT NULL,
    ClassID     VARCHAR2(10)    NOT NULL,
    Status      VARCHAR2(20)    DEFAULT 'Registered'
                                CHECK (Status IN ('Registered', 'Attended', 'Removed')),
    PRIMARY KEY (MemberID, ClassID),
    CONSTRAINT fk_mc_member FOREIGN KEY (MemberID) REFERENCES MEMBER(MemberID),
    CONSTRAINT fk_mc_class  FOREIGN KEY (ClassID)  REFERENCES CLASS(ClassID)
);

-- CLASS <-> EQUIPMENT (a class uses many equipment; equipment can be used across classes)
CREATE TABLE CLASS_EQUIPMENT (
    ClassID         VARCHAR2(10)    NOT NULL,
    EquipmentID     VARCHAR2(10)    NOT NULL,
    PRIMARY KEY (ClassID, EquipmentID),
    CONSTRAINT fk_ce_class      FOREIGN KEY (ClassID)     REFERENCES CLASS(ClassID),
    CONSTRAINT fk_ce_equipment  FOREIGN KEY (EquipmentID) REFERENCES EQUIPMENT(EquipmentID)
);

-- CLASS <-> SPECIAL_SUPPORT (optional; a class may have special support)
CREATE TABLE CLASS_SPECIAL_SUPPORT (
    ClassID     VARCHAR2(10)    NOT NULL,
    SupportID   VARCHAR2(10)    NOT NULL,
    PRIMARY KEY (ClassID, SupportID),
    CONSTRAINT fk_css_class   FOREIGN KEY (ClassID)   REFERENCES CLASS(ClassID),
    CONSTRAINT fk_css_support FOREIGN KEY (SupportID) REFERENCES SPECIAL_SUPPORT(SupportID)
);
