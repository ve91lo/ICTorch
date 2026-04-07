-- Supabase migration for ICT Learn app
-- Run this in the Supabase SQL Editor

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  google_id TEXT UNIQUE,
  name TEXT NOT NULL,
  email TEXT,
  year_of_study TEXT,
  expected_dse_grade TEXT,
  photo_url TEXT,
  selected_elective TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Topic progress
CREATE TABLE IF NOT EXISTS topic_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  topic_id TEXT NOT NULL,
  completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ,
  UNIQUE(user_id, topic_id)
);

-- Quiz attempts with full question/answer data
CREATE TABLE IF NOT EXISTS quiz_attempts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  quiz_id TEXT,
  quiz_title TEXT NOT NULL,
  score REAL NOT NULL,
  questions JSONB,
  answers JSONB,
  completed_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE topic_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;

-- RLS Policies (allow authenticated users to manage their own data)
CREATE POLICY "Users can read own data" ON users
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own data" ON users
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (true);

CREATE POLICY "Progress read own" ON topic_progress
  FOR SELECT USING (true);

CREATE POLICY "Progress insert own" ON topic_progress
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Progress update own" ON topic_progress
  FOR UPDATE USING (true);

CREATE POLICY "Quiz read own" ON quiz_attempts
  FOR SELECT USING (true);

CREATE POLICY "Quiz insert own" ON quiz_attempts
  FOR INSERT WITH CHECK (true);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_topic_progress_user ON topic_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);
