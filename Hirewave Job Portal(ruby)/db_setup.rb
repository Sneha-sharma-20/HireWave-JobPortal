require 'pg'

def setup_database
  conn = PG.connect(ENV['DATABASE_URL'])
  
  conn.exec("DROP TABLE IF EXISTS applications CASCADE")
  conn.exec("DROP TABLE IF EXISTS jobs CASCADE")
  conn.exec("DROP TABLE IF EXISTS users CASCADE")
  
  conn.exec("
    CREATE TABLE users (
      id SERIAL PRIMARY KEY,
      username VARCHAR(100) UNIQUE NOT NULL,
      email VARCHAR(255) UNIQUE NOT NULL,
      password_hash VARCHAR(255) NOT NULL,
      user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('employer', 'jobseeker')),
      company_name VARCHAR(255),
      full_name VARCHAR(255),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ")
  
  conn.exec("
    CREATE TABLE jobs (
      id SERIAL PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      description TEXT NOT NULL,
      company VARCHAR(255) NOT NULL,
      location VARCHAR(255),
      salary VARCHAR(100),
      job_type VARCHAR(50),
      employer_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ")
  
  conn.exec("
    CREATE TABLE applications (
      id SERIAL PRIMARY KEY,
      job_id INTEGER REFERENCES jobs(id) ON DELETE CASCADE,
      user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
      cover_letter TEXT,
      status VARCHAR(50) DEFAULT 'pending',
      applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(job_id, user_id)
    )
  ")
  
  puts "Database tables created successfully!"
  conn.close
end

setup_database if _FILE_ == $0