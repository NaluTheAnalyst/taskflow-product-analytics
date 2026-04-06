# TaskFlow — Product Analytics Dashboard

## Project Overview

TaskFlow is a fictional B2B project management SaaS platform. This project analyses 6 months of product data (January–June 2024) to uncover user growth trends, churn patterns, feature adoption, engagement behaviour, and revenue performance — the kind of analysis a Product Analyst would present to a product leadership team to guide roadmap prioritisation and retention strategy.

The analysis was performed using **SQL Server 2019** for data querying and **Power BI Desktop** for dashboard design and visualisation.

---

## Dataset

| Table | Description | Rows |
|---|---|---|
| `tf_users` | Every user — signup date, plan, country, company size, status, MRR | 600 |
| `tf_subscriptions` | Every subscription — plan, start/end date, status | 622 |
| `tf_sessions` | Every login session — date, duration, device, plan | 11,135 |
| `tf_feature_usage` | Every feature used — feature name, date, usage count, plan | 9,286 |
| `tf_support_tickets` | Every support ticket — category, priority, status, resolution days | 942 |

### Plans
| Plan | MRR |
|---|---|
| Trial | $0 |
| Starter | $29/month |
| Growth | $79/month |
| Enterprise | $199/month |

---

## Business Questions

1. How many users signed up each month and what is the growth trend?
2. What is the user breakdown by plan and status?
3. What is the churn rate overall and by plan?
4. What is the trial-to-paid conversion rate?
5. Which features are most and least adopted across the platform?
6. What is the average session duration and frequency by plan?
7. What is the total MRR and breakdown by plan?
8. Which countries have the most users and highest MRR?

---

## Key Findings

1. **Trial churn is the most urgent problem** — 46.67% of Trial users churn. They average only 4.94 sessions and 14.58 mins per session, compared to 40.39 sessions and 55.24 mins for Enterprise users
2. **Enterprise drives disproportionate revenue** — 16.33% of users generate 50.83% of total MRR ($15,920) with the second lowest churn rate at 18.37%
3. **Trial conversion sits mid-benchmark** — 19.64% convert to paid against an industry benchmark of 15-25%. Low trial engagement is the main constraint
4. **Task Management and Kanban Board are the core product** — Together they account for 35.5% of all feature usage. Integrations (6.58%) and Reporting (7.21%) are underused
5. **Mobile is a significant usage channel** — 29.82% of all sessions happen on mobile, making mobile experience a retention priority
6. **Feature Request is the top support category** — 203 tickets signal that users want capabilities not yet available — a direct product roadmap input

---

## Key Numbers

| Metric | Value |
|---|---|
| Total Users | 600 |
| Active Users | 428 (71.33%) |
| Churned Users | 150 (25.00%) |
| Total MRR | $31,320 |
| ARPU | $82.42 |
| Trial Conversion Rate | 19.64% |
| Total Sessions | 11,135 |
| Enterprise MRR Share | 50.83% |
| Top Feature | Task Management (14,265 usage events) |
| Mobile Session Share | 29.82% |

---

## Strategic Recommendations

| Priority | Recommendation | Based On |
|---|---|---|
| 1 | Implement 7-day onboarding checklist — guide trial users to core features within 48 hours | Q3, Q4 |
| 2 | Build Enterprise retention programme — assign account managers, run quarterly reviews | Q3, Q7 |
| 3 | Send mid-trial engagement emails on day 7 highlighting unused features | Q4, Q5 |
| 4 | Prioritise mobile app performance — 29.82% of sessions are on mobile | Q6 |
| 5 | Analyse Feature Request tickets by plan — Enterprise requests should drive the roadmap | Bonus |

---

## Tools Used

- SQL Server 2019
- SQL Server Management Studio (SSMS)
- Power BI Desktop
