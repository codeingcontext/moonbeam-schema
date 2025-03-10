-- Sample data for Moonbeam
-- Note: Replace 'your-user-id' with an actual user ID from your auth.users table

-- Sample profile data (only run this if you want to manually create a profile)
-- INSERT INTO profiles (id, email, full_name, avatar_url, is_onboarded)
-- VALUES ('your-user-id', 'user@example.com', 'Test User', 'https://example.com/avatar.jpg', true);

-- Sample notes
INSERT INTO notes (id, user_id, title, content, is_favorite, tags, created_at, updated_at)
VALUES 
  (gen_random_uuid(), 'your-user-id', 'Meeting Notes', 'Discussed project timeline and deliverables. Action items: 1) Complete wireframes by Friday, 2) Schedule follow-up meeting next week.', true, ARRAY['work', 'meeting'], NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
  
  (gen_random_uuid(), 'your-user-id', 'Shopping List', 'Milk, Eggs, Bread, Apples, Coffee, Chicken, Rice', false, ARRAY['personal', 'shopping'], NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
  
  (gen_random_uuid(), 'your-user-id', 'Book Recommendations', 'Atomic Habits by James Clear\nThe Psychology of Money by Morgan Housel\nDeep Work by Cal Newport', true, ARRAY['books', 'personal development'], NOW() - INTERVAL '5 days', NOW() - INTERVAL '3 days'),
  
  (gen_random_uuid(), 'your-user-id', 'App Ideas', 'Voice-first productivity app\nFitness tracker with social features\nMeal planning app with grocery integration', false, ARRAY['ideas', 'projects'], NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
  
  (gen_random_uuid(), 'your-user-id', 'Workout Routine', 'Monday: Upper body\nTuesday: Lower body\nWednesday: Cardio\nThursday: Rest\nFriday: Full body\nSaturday: Yoga\nSunday: Rest', false, ARRAY['fitness', 'health'], NOW() - INTERVAL '7 days', NOW() - INTERVAL '7 days');

-- Sample tasks
INSERT INTO tasks (id, user_id, title, description, status, priority, due_date, tags, created_at, updated_at, completed_at)
VALUES 
  (gen_random_uuid(), 'your-user-id', 'Complete project proposal', 'Draft the initial proposal document and share with the team for feedback', 'pending', 'high', NOW() + INTERVAL '2 days', ARRAY['work', 'urgent'], NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', NULL),
  
  (gen_random_uuid(), 'your-user-id', 'Schedule dentist appointment', 'Call Dr. Smith''s office to schedule annual checkup', 'completed', 'medium', NOW() - INTERVAL '1 day', ARRAY['health', 'personal'], NOW() - INTERVAL '5 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
  
  (gen_random_uuid(), 'your-user-id', 'Buy birthday gift', 'Get a gift for Mom''s birthday next week', 'pending', 'medium', NOW() + INTERVAL '5 days', ARRAY['personal', 'shopping'], NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', NULL),
  
  (gen_random_uuid(), 'your-user-id', 'Review code pull request', 'Review and approve the latest PR for the authentication feature', 'inProgress', 'high', NOW() + INTERVAL '1 day', ARRAY['work', 'development'], NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NULL),
  
  (gen_random_uuid(), 'your-user-id', 'Pay utility bills', 'Pay electricity, water, and internet bills', 'pending', 'high', NOW() + INTERVAL '3 days', ARRAY['finance', 'home'], NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days', NULL),
  
  (gen_random_uuid(), 'your-user-id', 'Grocery shopping', 'Buy groceries for the week', 'completed', 'medium', NOW() - INTERVAL '2 days', ARRAY['personal', 'shopping'], NOW() - INTERVAL '4 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
  
  (gen_random_uuid(), 'your-user-id', 'Prepare presentation', 'Create slides for the client meeting', 'inProgress', 'high', NOW() + INTERVAL '2 days', ARRAY['work', 'presentation'], NOW() - INTERVAL '3 days', NOW() - INTERVAL '1 day', NULL);

-- Sample recordings (without actual audio files)
INSERT INTO recordings (id, user_id, audio_url, duration, transcription, created_at, updated_at)
VALUES 
  (gen_random_uuid(), 'your-user-id', 'https://example.com/recordings/sample1.m4a', 120, 'This is a sample transcription of a meeting recording. We discussed project timelines and next steps.', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
  
  (gen_random_uuid(), 'your-user-id', 'https://example.com/recordings/sample2.m4a', 60, 'Remember to buy milk, eggs, and bread from the grocery store.', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
  
  (gen_random_uuid(), 'your-user-id', 'https://example.com/recordings/sample3.m4a', 180, 'Ideas for the new app: voice-first interface, minimalist design, focus on productivity features.', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days');

-- Note: Tags will be automatically extracted and stored in the tags table via the process_tags trigger