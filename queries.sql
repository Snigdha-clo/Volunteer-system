-- ============================================================
-- VOLUNTEER OPPORTUNITY RECOMMENDATION SYSTEM
-- 50 SQL Queries
-- ============================================================

-- ============================================================
-- SECTION 1: TABLE CREATION (Schema)
-- ============================================================

CREATE TABLE Organization (
    org_id INT PRIMARY KEY AUTO_INCREMENT,
    org_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    address VARCHAR(255),
    description TEXT,
    password VARCHAR(255) NOT NULL
);

CREATE TABLE Volunteer (
    volunteer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    city VARCHAR(50),
    password VARCHAR(255) NOT NULL
);

CREATE TABLE VolunteerProfile (
    profile_id INT PRIMARY KEY AUTO_INCREMENT,
    volunteer_id INT UNIQUE,
    experience_level VARCHAR(50),
    availability_hours INT,
    preferred_mode VARCHAR(50),
    FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id) ON DELETE CASCADE
);

CREATE TABLE Skill (
    skill_id INT PRIMARY KEY AUTO_INCREMENT,
    skill_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Interest (
    interest_id INT PRIMARY KEY AUTO_INCREMENT,
    interest_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE VolunteerSkill (
    volunteer_id INT,
    skill_id INT,
    PRIMARY KEY (volunteer_id, skill_id),
    FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES Skill(skill_id) ON DELETE CASCADE
);

CREATE TABLE VolunteerInterest (
    volunteer_id INT,
    interest_id INT,
    PRIMARY KEY (volunteer_id, interest_id),
    FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id) ON DELETE CASCADE,
    FOREIGN KEY (interest_id) REFERENCES Interest(interest_id) ON DELETE CASCADE
);

CREATE TABLE Cause (
    cause_id INT PRIMARY KEY AUTO_INCREMENT,
    cause_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE Opportunity (
    opp_id INT PRIMARY KEY AUTO_INCREMENT,
    org_id INT NOT NULL,
    cause_id INT,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    location VARCHAR(100),
    category VARCHAR(100),
    mode VARCHAR(50),
    start_date DATE,
    end_date DATE,
    hours_required INT,
    FOREIGN KEY (org_id) REFERENCES Organization(org_id) ON DELETE CASCADE,
    FOREIGN KEY (cause_id) REFERENCES Cause(cause_id) ON DELETE SET NULL
);

CREATE TABLE OpportunityRequirement (
    requirement_id INT PRIMARY KEY AUTO_INCREMENT,
    opp_id INT NOT NULL,
    required_skill VARCHAR(100),
    minimum_level VARCHAR(50),
    volunteers_needed INT,
    FOREIGN KEY (opp_id) REFERENCES Opportunity(opp_id) ON DELETE CASCADE
);

CREATE TABLE Application (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    volunteer_id INT NOT NULL,
    opp_id INT NOT NULL,
    applied_date DATE DEFAULT (CURRENT_DATE),
    status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id) ON DELETE CASCADE,
    FOREIGN KEY (opp_id) REFERENCES Opportunity(opp_id) ON DELETE CASCADE
);

CREATE TABLE Participation (
    participation_id INT PRIMARY KEY AUTO_INCREMENT,
    volunteer_id INT NOT NULL,
    opp_id INT NOT NULL,
    participation_date DATE,
    hours_worked INT,
    FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id) ON DELETE CASCADE,
    FOREIGN KEY (opp_id) REFERENCES Opportunity(opp_id) ON DELETE CASCADE
);

CREATE TABLE Feedback (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    volunteer_id INT NOT NULL,
    opp_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    feedback_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (volunteer_id) REFERENCES Volunteer(volunteer_id) ON DELETE CASCADE,
    FOREIGN KEY (opp_id) REFERENCES Opportunity(opp_id) ON DELETE CASCADE
);

-- ============================================================
-- SECTION 2: INSERT QUERIES (Sample Data)
-- ============================================================

-- Query 1: Register a new volunteer
INSERT INTO Volunteer (name, email, phone, city, password)
VALUES ('Anjali Sharma', 'anjali@example.com', '9876543210', 'Chennai', 'hashed_pass_1');

-- Query 2: Register a new organization
INSERT INTO Organization (org_name, email, phone, address, description, password)
VALUES ('Green Earth NGO', 'greenearth@ngo.com', '9123456789', 'Anna Nagar, Chennai',
        'We work for environmental causes', 'hashed_pass_2');

-- Query 3: Create volunteer profile
INSERT INTO VolunteerProfile (volunteer_id, experience_level, availability_hours, preferred_mode)
VALUES (1, 'Intermediate', 10, 'Online');

-- Query 4: Add a new skill
INSERT INTO Skill (skill_name) VALUES ('Teaching');

-- Query 5: Add a new interest
INSERT INTO Interest (interest_name) VALUES ('Environment');

-- Query 6: Assign skill to volunteer
INSERT INTO VolunteerSkill (volunteer_id, skill_id) VALUES (1, 1);

-- Query 7: Assign interest to volunteer
INSERT INTO VolunteerInterest (volunteer_id, interest_id) VALUES (1, 1);

-- Query 8: Add a cause
INSERT INTO Cause (cause_name, description)
VALUES ('Education', 'Promoting literacy and learning');

-- Query 9: Post a new opportunity
INSERT INTO Opportunity (org_id, cause_id, title, description, location, category, mode, start_date, end_date, hours_required)
VALUES (1, 1, 'Tree Plantation Drive', 'Plant 1000 trees in urban areas', 'Chennai',
        'Environment', 'Offline', '2025-06-01', '2025-06-30', 20);

-- Query 10: Add opportunity requirement
INSERT INTO OpportunityRequirement (opp_id, required_skill, minimum_level, volunteers_needed)
VALUES (1, 'Physical Labor', 'Beginner', 50);

-- ============================================================
-- SECTION 3: SELECT / READ QUERIES
-- ============================================================

-- Query 11: Get all opportunities with organization details
SELECT o.opp_id, o.title, o.location, o.mode, o.start_date, o.end_date,
       og.org_name, c.cause_name
FROM Opportunity o
JOIN Organization og ON o.org_id = og.org_id
LEFT JOIN Cause c ON o.cause_id = c.cause_id
ORDER BY o.start_date;

-- Query 12: Get volunteer profile with skills and interests
SELECT v.name, v.city, vp.experience_level, vp.availability_hours, vp.preferred_mode,
       GROUP_CONCAT(DISTINCT s.skill_name) AS skills,
       GROUP_CONCAT(DISTINCT i.interest_name) AS interests
FROM Volunteer v
LEFT JOIN VolunteerProfile vp ON v.volunteer_id = vp.volunteer_id
LEFT JOIN VolunteerSkill vs ON v.volunteer_id = vs.volunteer_id
LEFT JOIN Skill s ON vs.skill_id = s.skill_id
LEFT JOIN VolunteerInterest vi ON v.volunteer_id = vi.volunteer_id
LEFT JOIN Interest i ON vi.interest_id = i.interest_id
WHERE v.volunteer_id = 1
GROUP BY v.volunteer_id;

-- Query 13: Get all applications for a specific opportunity with volunteer details
SELECT a.application_id, v.name, v.email, v.phone, a.applied_date, a.status
FROM Application a
JOIN Volunteer v ON a.volunteer_id = v.volunteer_id
WHERE a.opp_id = 1
ORDER BY a.applied_date DESC;

-- Query 14: Get application history for a volunteer
SELECT a.application_id, o.title, og.org_name, a.applied_date, a.status
FROM Application a
JOIN Opportunity o ON a.opp_id = o.opp_id
JOIN Organization og ON o.org_id = og.org_id
WHERE a.volunteer_id = 1
ORDER BY a.applied_date DESC;

-- Query 15: Get all opportunities posted by an organization
SELECT opp_id, title, category, mode, location, start_date, end_date,
       hours_required
FROM Opportunity
WHERE org_id = 1
ORDER BY start_date;

-- Query 16: Get participation history of a volunteer
SELECT p.participation_id, o.title, og.org_name, p.participation_date, p.hours_worked
FROM Participation p
JOIN Opportunity o ON p.opp_id = o.opp_id
JOIN Organization og ON o.org_id = og.org_id
WHERE p.volunteer_id = 1
ORDER BY p.participation_date DESC;

-- Query 17: Get total hours volunteered by each volunteer
SELECT v.name, v.city, COALESCE(SUM(p.hours_worked), 0) AS total_hours
FROM Volunteer v
LEFT JOIN Participation p ON v.volunteer_id = p.volunteer_id
GROUP BY v.volunteer_id
ORDER BY total_hours DESC;

-- Query 18: Get feedback for a specific opportunity
SELECT v.name, f.rating, f.comment, f.feedback_date
FROM Feedback f
JOIN Volunteer v ON f.volunteer_id = v.volunteer_id
WHERE f.opp_id = 1
ORDER BY f.feedback_date DESC;

-- Query 19: Get average rating for each opportunity
SELECT o.title, ROUND(AVG(f.rating), 2) AS avg_rating, COUNT(f.feedback_id) AS total_reviews
FROM Opportunity o
LEFT JOIN Feedback f ON o.opp_id = f.opp_id
GROUP BY o.opp_id
ORDER BY avg_rating DESC;

-- Query 20: Get all pending applications across system (Admin view)
SELECT a.application_id, v.name AS volunteer, o.title AS opportunity,
       og.org_name, a.applied_date
FROM Application a
JOIN Volunteer v ON a.volunteer_id = v.volunteer_id
JOIN Opportunity o ON a.opp_id = o.opp_id
JOIN Organization og ON o.org_id = og.org_id
WHERE a.status = 'Pending'
ORDER BY a.applied_date;

-- ============================================================
-- SECTION 4: RECOMMENDATION / MATCHING QUERIES
-- ============================================================

-- Query 21: Skill-based opportunity recommendation for a volunteer
SELECT DISTINCT o.opp_id, o.title, o.location, o.mode, o.start_date, og.org_name
FROM Opportunity o
JOIN Organization og ON o.org_id = og.org_id
JOIN OpportunityRequirement orq ON o.opp_id = orq.opp_id
JOIN Skill sk ON orq.required_skill = sk.skill_name
JOIN VolunteerSkill vs ON sk.skill_id = vs.skill_id
WHERE vs.volunteer_id = 1
AND o.opp_id NOT IN (SELECT opp_id FROM Application WHERE volunteer_id = 1)
ORDER BY o.start_date;

-- Query 22: Interest-based opportunity recommendation
SELECT DISTINCT o.opp_id, o.title, o.location, o.mode, c.cause_name, og.org_name
FROM Opportunity o
JOIN Organization og ON o.org_id = og.org_id
LEFT JOIN Cause c ON o.cause_id = c.cause_id
JOIN VolunteerInterest vi ON vi.volunteer_id = 1
JOIN Interest i ON vi.interest_id = i.interest_id
WHERE LOWER(c.cause_name) LIKE CONCAT('%', LOWER(i.interest_name), '%')
AND o.opp_id NOT IN (SELECT opp_id FROM Application WHERE volunteer_id = 1);

-- Query 23: Location-based opportunity filter
SELECT o.opp_id, o.title, o.location, o.mode, og.org_name, o.start_date
FROM Opportunity o
JOIN Organization og ON o.org_id = og.org_id
WHERE o.location = (SELECT city FROM Volunteer WHERE volunteer_id = 1)
ORDER BY o.start_date;

-- Query 24: Mode-based opportunity filter (Online/Offline)
SELECT o.opp_id, o.title, o.mode, og.org_name, o.start_date
FROM Opportunity o
JOIN Organization og ON o.org_id = og.org_id
WHERE o.mode = (SELECT preferred_mode FROM VolunteerProfile WHERE volunteer_id = 1);

-- Query 25: Combined recommendation (skill + interest + location + mode)
SELECT DISTINCT o.opp_id, o.title, o.location, o.mode, c.cause_name, og.org_name,
       o.start_date, o.hours_required
FROM Opportunity o
JOIN Organization og ON o.org_id = og.org_id
LEFT JOIN Cause c ON o.cause_id = c.cause_id
LEFT JOIN OpportunityRequirement orq ON o.opp_id = orq.opp_id
LEFT JOIN Skill sk ON orq.required_skill = sk.skill_name
LEFT JOIN VolunteerSkill vs ON sk.skill_id = vs.skill_id AND vs.volunteer_id = 1
LEFT JOIN VolunteerInterest vi ON vi.volunteer_id = 1
LEFT JOIN Interest i ON vi.interest_id = i.interest_id
  AND LOWER(c.cause_name) LIKE CONCAT('%', LOWER(i.interest_name), '%')
WHERE (vs.volunteer_id = 1 OR vi.volunteer_id = 1)
  AND o.opp_id NOT IN (SELECT opp_id FROM Application WHERE volunteer_id = 1)
ORDER BY o.start_date;

-- ============================================================
-- SECTION 5: FILTER / SEARCH QUERIES
-- ============================================================

-- Query 26: Filter opportunities by cause
SELECT o.opp_id, o.title, o.location, o.mode, og.org_name
FROM Opportunity o
JOIN Organization og ON o.org_id = og.org_id
JOIN Cause c ON o.cause_id = c.cause_id
WHERE c.cause_name = 'Education';

-- Query 27: Filter opportunities by location and mode
SELECT o.opp_id, o.title, o.mode, o.start_date, og.org_name
FROM Opportunity o
JOIN Organization og ON o.org_id = og.org_id
WHERE o.location = 'Chennai' AND o.mode = 'Offline';

-- Query 28: Filter opportunities by required skill
SELECT DISTINCT o.opp_id, o.title, o.location, og.org_name
FROM Opportunity o
JOIN Organization og ON o.org_id = og.org_id
JOIN OpportunityRequirement orq ON o.opp_id = orq.opp_id
WHERE orq.required_skill = 'Teaching';

-- Query 29: Filter by hours required (for volunteers with limited time)
SELECT o.opp_id, o.title, o.hours_required, o.location, og.org_name
FROM Opportunity o
JOIN Organization og ON o.org_id = og.org_id
WHERE o.hours_required <= (SELECT availability_hours FROM VolunteerProfile WHERE volunteer_id = 1);

-- Query 30: Search opportunities by keyword in title or description
SELECT o.opp_id, o.title, o.location, o.mode, og.org_name
FROM Opportunity o
JOIN Organization og ON o.org_id = og.org_id
WHERE o.title LIKE '%plantation%' OR o.description LIKE '%plantation%';

-- ============================================================
-- SECTION 6: UPDATE QUERIES
-- ============================================================

-- Query 31: Accept an application
UPDATE Application SET status = 'Accepted'
WHERE application_id = 1;

-- Query 32: Reject an application
UPDATE Application SET status = 'Rejected'
WHERE application_id = 2;

-- Query 33: Update volunteer profile availability
UPDATE VolunteerProfile
SET availability_hours = 15, preferred_mode = 'Hybrid'
WHERE volunteer_id = 1;

-- Query 34: Update opportunity details
UPDATE Opportunity
SET title = 'Mega Tree Plantation Drive', hours_required = 25
WHERE opp_id = 1;

-- Query 35: Update volunteer contact info
UPDATE Volunteer
SET phone = '9000011111', city = 'Coimbatore'
WHERE volunteer_id = 1;

-- ============================================================
-- SECTION 7: APPLICATION & PARTICIPATION MANAGEMENT
-- ============================================================

-- Query 36: Submit a new application
INSERT INTO Application (volunteer_id, opp_id, applied_date, status)
VALUES (1, 2, CURRENT_DATE, 'Pending');

-- Query 37: Record participation after acceptance
INSERT INTO Participation (volunteer_id, opp_id, participation_date, hours_worked)
VALUES (1, 1, '2025-06-15', 8);

-- Query 38: Submit feedback for a completed opportunity
INSERT INTO Feedback (volunteer_id, opp_id, rating, comment, feedback_date)
VALUES (1, 1, 5, 'Very well organized and meaningful!', CURRENT_DATE);

-- Query 39: Count applications per opportunity
SELECT o.title, COUNT(a.application_id) AS application_count,
       SUM(CASE WHEN a.status = 'Accepted' THEN 1 ELSE 0 END) AS accepted,
       SUM(CASE WHEN a.status = 'Rejected' THEN 1 ELSE 0 END) AS rejected,
       SUM(CASE WHEN a.status = 'Pending' THEN 1 ELSE 0 END) AS pending
FROM Opportunity o
LEFT JOIN Application a ON o.opp_id = a.opp_id
WHERE o.org_id = 1
GROUP BY o.opp_id;

-- Query 40: Check if volunteer already applied to an opportunity
SELECT COUNT(*) AS already_applied
FROM Application
WHERE volunteer_id = 1 AND opp_id = 1;

-- ============================================================
-- SECTION 8: ANALYTICS & REPORTING QUERIES
-- ============================================================

-- Query 41: Top 5 volunteers by hours worked
SELECT v.name, v.city, SUM(p.hours_worked) AS total_hours
FROM Volunteer v
JOIN Participation p ON v.volunteer_id = p.volunteer_id
GROUP BY v.volunteer_id
ORDER BY total_hours DESC
LIMIT 5;

-- Query 42: Most popular opportunities (by application count)
SELECT o.title, og.org_name, COUNT(a.application_id) AS total_applications
FROM Opportunity o
JOIN Organization og ON o.org_id = og.org_id
LEFT JOIN Application a ON o.opp_id = a.opp_id
GROUP BY o.opp_id
ORDER BY total_applications DESC
LIMIT 10;

-- Query 43: Opportunities with unfilled volunteer slots
SELECT o.title, orq.volunteers_needed,
       COUNT(CASE WHEN a.status = 'Accepted' THEN 1 END) AS filled,
       (orq.volunteers_needed - COUNT(CASE WHEN a.status = 'Accepted' THEN 1 END)) AS remaining
FROM Opportunity o
JOIN OpportunityRequirement orq ON o.opp_id = orq.opp_id
LEFT JOIN Application a ON o.opp_id = a.opp_id
GROUP BY o.opp_id
HAVING remaining > 0;

-- Query 44: Organization performance (total volunteers, hours, avg rating)
SELECT og.org_name,
       COUNT(DISTINCT p.volunteer_id) AS total_volunteers,
       COALESCE(SUM(p.hours_worked), 0) AS total_hours_contributed,
       ROUND(AVG(f.rating), 2) AS avg_rating
FROM Organization og
LEFT JOIN Opportunity o ON og.org_id = o.org_id
LEFT JOIN Participation p ON o.opp_id = p.opp_id
LEFT JOIN Feedback f ON o.opp_id = f.opp_id
GROUP BY og.org_id
ORDER BY total_volunteers DESC;

-- Query 45: Volunteers who have never applied
SELECT v.volunteer_id, v.name, v.email, v.city
FROM Volunteer v
WHERE v.volunteer_id NOT IN (SELECT DISTINCT volunteer_id FROM Application);

-- ============================================================
-- SECTION 9: ADMIN / MANAGEMENT QUERIES
-- ============================================================

-- Query 46: All volunteers with their profile completeness status
SELECT v.volunteer_id, v.name, v.email, v.city,
       CASE WHEN vp.profile_id IS NOT NULL THEN 'Complete' ELSE 'Incomplete' END AS profile_status,
       CASE WHEN vs.volunteer_id IS NOT NULL THEN 'Yes' ELSE 'No' END AS has_skills,
       CASE WHEN vi.volunteer_id IS NOT NULL THEN 'Yes' ELSE 'No' END AS has_interests
FROM Volunteer v
LEFT JOIN VolunteerProfile vp ON v.volunteer_id = vp.volunteer_id
LEFT JOIN (SELECT DISTINCT volunteer_id FROM VolunteerSkill) vs ON v.volunteer_id = vs.volunteer_id
LEFT JOIN (SELECT DISTINCT volunteer_id FROM VolunteerInterest) vi ON v.volunteer_id = vi.volunteer_id;

-- Query 47: Monthly application trends
SELECT DATE_FORMAT(applied_date, '%Y-%m') AS month,
       COUNT(*) AS total_applications,
       SUM(CASE WHEN status = 'Accepted' THEN 1 ELSE 0 END) AS accepted,
       SUM(CASE WHEN status = 'Rejected' THEN 1 ELSE 0 END) AS rejected
FROM Application
GROUP BY month
ORDER BY month DESC;

-- Query 48: Delete opportunity and cascade
DELETE FROM Opportunity WHERE opp_id = 10;

-- Query 49: Volunteers with skills matching a specific opportunity requirement
SELECT v.volunteer_id, v.name, v.city, vp.experience_level, vp.availability_hours
FROM Volunteer v
JOIN VolunteerProfile vp ON v.volunteer_id = vp.volunteer_id
JOIN VolunteerSkill vs ON v.volunteer_id = vs.volunteer_id
JOIN Skill s ON vs.skill_id = s.skill_id
JOIN OpportunityRequirement orq ON s.skill_name = orq.required_skill
WHERE orq.opp_id = 1
  AND v.volunteer_id NOT IN (SELECT volunteer_id FROM Application WHERE opp_id = 1);

-- Query 50: Volunteer login authentication
SELECT volunteer_id, name, email, city
FROM Volunteer
WHERE email = 'anjali@example.com' AND password = 'hashed_pass_1';

-- Organization login authentication
SELECT org_id, org_name, email
FROM Organization
WHERE email = 'greenearth@ngo.com' AND password = 'hashed_pass_2';
