-- Migration: 004_storage_setup
-- Description: Set up storage buckets and policies

-- Insert this migration version
INSERT INTO schema_migrations (version) 
VALUES ('004_storage_setup')
ON CONFLICT (version) DO NOTHING;

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('profiles', 'Profile pictures', true),
  ('audio_recordings', 'Audio recordings', true)
ON CONFLICT (id) DO NOTHING;

-- Set up RLS policies for profiles bucket
CREATE POLICY "Public profiles are viewable by everyone" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'profiles' AND auth.role() = 'authenticated'
  );

CREATE POLICY "Users can upload their own profile picture" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'profiles' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update their own profile picture" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'profiles' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete their own profile picture" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'profiles' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Set up RLS policies for audio_recordings bucket
CREATE POLICY "Audio recordings are viewable by owner" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'audio_recordings' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can upload their own audio recordings" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'audio_recordings' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update their own audio recordings" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'audio_recordings' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete their own audio recordings" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'audio_recordings' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );