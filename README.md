HireWave – Job Portal (Ruby + PostgreSQL)

HireWave is a lightweight job portal built using Ruby, ERB, and PostgreSQL.
It provides two separate user roles — Employers and Job Seekers — offering a smooth and secure hiring workflow.

📌 1. Project Overview

HireWave enables employers to post job listings and manage applications, while job seekers can browse and apply to jobs with ease.

⭐ Features for Employers

Create an account as an employer

Post job listings

View all posted jobs

View applicants and their cover letters

Manage hiring activity

⭐ Features for Job Seekers

Register as a job seeker

Browse all available job listings

View detailed job descriptions

Apply to jobs with an optional cover letter

Track past applications

🔐 Security & System Features

Secure user login with password hashing (BCrypt)

Role-based access (employer/job seeker)

Session management to maintain login status

PostgreSQL database with 3 tables:

users

jobs

applications

Clean UI using .erb templates

Implemented using Ruby (.rb) and SQL queries

⚙️ 2. Tech Stack Used
🖥 Backend

Ruby

ERB templates

Sinatra (if used) or Ruby base server logic

🗄 Database

PostgreSQL

SQL (DDL + DML queries)

🎨 Frontend

HTML

CSS

ERB

📦 Gems / Libraries

pg — PostgreSQL connection

bcrypt — password hashing

sinatra — (only if used)

🛠 3. Installation & Setup Guide

Follow these steps to run the HireWave Job Portal on your system.

📍 Step 1: Install Requirements
✔ Ruby

Check:

ruby -v


Download: https://www.ruby-lang.org/en/downloads/

✔ PostgreSQL

Check:

psql --version


Download: https://www.postgresql.org/download/

📍 Step 2: Clone the Project
git clone https://github.com/your-username/HireWave-JobPortal.git
cd HireWave-JobPortal

📍 Step 3: Install Gems

If a Gemfile exists:

bundle install


Otherwise install manually:

gem install pg bcrypt sinatra

📍 Step 4: Configure the Database

Start PostgreSQL:

psql postgres


Create the database:

CREATE DATABASE hirewave;
\c hirewave;


Create tables:

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(120) UNIQUE,
  password_hash TEXT,
  role VARCHAR(20)
);

CREATE TABLE jobs (
  id SERIAL PRIMARY KEY,
  employer_id INTEGER REFERENCES users(id),
  title VARCHAR(150),
  description TEXT,
  location VARCHAR(100)
);

CREATE TABLE applications (
  id SERIAL PRIMARY KEY,
  job_id INTEGER REFERENCES jobs(id),
  seeker_id INTEGER REFERENCES users(id),
  cover_letter TEXT
);

📍 Step 5: Run the Application

Run the main Ruby file:

ruby app.rb


Open in your browser:

http://localhost:4567/

📸 4. Output / Screens 



homePage<img width="1906" height="896" alt="Screenshot 2025-11-27 172329" src="https://github.com/user-attachments/assets/92692cfa-7bdf-4b37-8f58-6e936d658ae6" />


Login Page<img width="1918" height="876" alt="Screenshot 2025-11-27 172438" src="https://github.com/user-attachments/assets/eab19354-cc9c-4fb4-a476-af7caad0248a" />

Signup page JobSeeker<img width="1918" height="906" alt="Screenshot 2025-11-27 172511" src="https://github.com/user-attachments/assets/7a2c922c-8eae-4f95-84e7-875f767623be" />

Signup page employee<img width="1916" height="891" alt="Screenshot 2025-11-27 172647" src="https://github.com/user-attachments/assets/9bf0e625-24a1-475b-9899-6f533e330758" />

Post a Job<img width="1906" height="911" alt="Screenshot 2025-11-27 173046" src="https://github.com/user-attachments/assets/edb2f377-227f-4a87-930f-b772fe395e69" />

Apply for a Job<img width="1918" height="887" alt="Screenshot 2025-11-27 173141" src="https://github.com/user-attachments/assets/f48c1596-033e-44a6-a7ff-ccb38d276fe7" />






🎯 Summary

HireWave is a fully functional job portal built using:

Ruby + ERB

PostgreSQL

Secure login (BCrypt)

Role-based access

Session handling

Clean UI

A simple and efficient hiring system with complete backend and frontend logic.
