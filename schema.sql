-- Moonbeam Database Schema

-- Profiles table to store user information
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  is_onboarded BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notes table to store user notes
CREATE TABLE IF NOT EXISTS notes (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  audio_url TEXT,
  raw_transcription TEXT,
  is_favorite BOOLEAN DEFAULT FALSE,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks table to store user tasks
CREATE TABLE IF NOT EXISTS tasks (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'pending',
  priority TEXT DEFAULT 'medium',
  due_date TIMESTAMP WITH TIME ZONE,
  reminder_time TIMESTAMP WITH TIME ZONE,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

-- Recordings table to store audio recordings
CREATE TABLE IF NOT EXISTS recordings (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  audio_url TEXT NOT NULL,
  duration INTEGER NOT NULL,
  transcription TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tags table to store all unique tags
CREATE TABLE IF NOT EXISTS tags (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, name)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS notes_user_id_idx ON notes(user_id);
CREATE INDEX IF NOT EXISTS notes_is_favorite_idx ON notes(is_favorite);
CREATE INDEX IF NOT EXISTS notes_updated_at_idx ON notes(updated_at);

CREATE INDEX IF NOT EXISTS tasks_user_id_idx ON tasks(user_id);
CREATE INDEX IF NOT EXISTS tasks_status_idx ON tasks(status);
CREATE INDEX IF NOT EXISTS tasks_due_date_idx ON tasks(due_date);
CREATE INDEX IF NOT EXISTS tasks_priority_idx ON tasks(priority);
CREATE INDEX IF NOT EXISTS tasks_updated_at_idx ON tasks(updated_at);

CREATE INDEX IF NOT EXISTS recordings_user_id_idx ON recordings(user_id);
CREATE INDEX IF NOT EXISTS recordings_created_at_idx ON recordings(created_at);

CREATE INDEX IF NOT EXISTS tags_user_id_idx ON tags(user_id);
CREATE INDEX IF NOT EXISTS tags_name_idx ON tags(name);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE recordings ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;

-- Create policies for Row Level Security
CREATE POLICY profiles_policy ON profiles
  FOR ALL USING (auth.uid() = id);

CREATE POLICY notes_policy ON notes
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY tasks_policy ON tasks
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY recordings_policy ON recordings
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY tags_policy ON tags
  FOR ALL USING (auth.uid() = user_id);

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile when a new user is created
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Function to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to update the updated_at column
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_notes_updated_at
  BEFORE UPDATE ON notes
  FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at
  BEFORE UPDATE ON tasks
  FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_recordings_updated_at
  BEFORE UPDATE ON recordings
  FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Function to extract and store tags from notes and tasks
CREATE OR REPLACE FUNCTION process_tags()
RETURNS TRIGGER AS $$
DECLARE
  tag TEXT;
BEGIN
  -- Delete existing tags that are no longer in the array
  IF TG_OP = 'UPDATE' THEN
    -- No action needed for tags table as we're just ensuring they exist
  END IF;

  -- Insert new tags
  IF NEW.tags IS NOT NULL THEN
    FOREACH tag IN ARRAY NEW.tags
    LOOP
      -- Insert tag if it doesn't exist
      INSERT INTO tags (id, user_id, name)
      VALUES (gen_random_uuid(), NEW.user_id, tag)
      ON CONFLICT (user_id, name) DO NOTHING;
    END LOOP;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to process tags
CREATE TRIGGER process_note_tags
  AFTER INSERT OR UPDATE ON notes
  FOR EACH ROW EXECUTE PROCEDURE process_tags();

CREATE TRIGGER process_task_tags
  AFTER INSERT OR UPDATE ON tasks
  FOR EACH ROW EXECUTE PROCEDURE process_tags();

-- Function to search notes and tasks
CREATE OR REPLACE FUNCTION search_items(search_query TEXT, user_id UUID)
RETURNS TABLE (
  id UUID,
  title TEXT,
  content TEXT,
  item_type TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
    SELECT n.id, n.title, n.content, 'note' AS item_type, n.updated_at
    FROM notes n
    WHERE n.user_id = search_items.user_id
      AND (
        n.title ILIKE '%' || search_query || '%'
        OR n.content ILIKE '%' || search_query || '%'
        OR EXISTS (
          SELECT 1 FROM unnest(n.tags) tag
          WHERE tag ILIKE '%' || search_query || '%'
        )
      )
    UNION ALL
    SELECT t.id, t.title, t.description AS content, 'task' AS item_type, t.updated_at
    FROM tasks t
    WHERE t.user_id = search_items.user_id
      AND (
        t.title ILIKE '%' || search_query || '%'
        OR t.description ILIKE '%' || search_query || '%'
        OR EXISTS (
          SELECT 1 FROM unnest(t.tags) tag
          WHERE tag ILIKE '%' || search_query || '%'
        )
      )
    ORDER BY updated_at DESC;
END;
$$ LANGUAGE plpgsql;