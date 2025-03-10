# Moonbeam Database Schema

This repository contains the database schema for Moonbeam, a voice-first productivity assistant built with Flutter and Supabase.

## Schema Overview

The database schema includes the following tables:

1. **profiles** - Stores user profile information
2. **notes** - Stores user notes with content and metadata
3. **tasks** - Stores user tasks with status, priority, and due dates
4. **recordings** - Stores audio recordings and transcriptions
5. **tags** - Stores unique tags used across notes and tasks

## Features

- Row Level Security (RLS) for data protection
- Automatic user profile creation on signup
- Automatic timestamp management
- Tag extraction and management
- Full-text search functionality

## Setup Instructions

### Prerequisites

- Supabase account
- Supabase CLI (optional, for local development)

### Installation

1. **Create a new Supabase project**

2. **Run the schema SQL**
   - Go to the SQL Editor in your Supabase dashboard
   - Copy the contents of `schema.sql`
   - Paste and run the SQL in the editor

3. **Configure Authentication**
   - Enable Email/Password sign-up in Authentication settings
   - (Optional) Configure additional auth providers like Google, Apple, etc.

4. **Storage Setup**
   - Create the following buckets:
     - `profiles` - For profile pictures
     - `audio_recordings` - For audio files
   - Set appropriate RLS policies for the buckets

### Connecting to Your App

Update your Flutter app's `.env` file with your Supabase credentials:

```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

## Database Structure

### profiles
- `id` - UUID (Primary Key, references auth.users)
- `email` - TEXT
- `full_name` - TEXT
- `avatar_url` - TEXT
- `is_onboarded` - BOOLEAN
- `created_at` - TIMESTAMP
- `updated_at` - TIMESTAMP

### notes
- `id` - UUID (Primary Key)
- `user_id` - UUID (Foreign Key to profiles)
- `title` - TEXT
- `content` - TEXT
- `audio_url` - TEXT
- `raw_transcription` - TEXT
- `is_favorite` - BOOLEAN
- `tags` - TEXT[]
- `created_at` - TIMESTAMP
- `updated_at` - TIMESTAMP

### tasks
- `id` - UUID (Primary Key)
- `user_id` - UUID (Foreign Key to profiles)
- `title` - TEXT
- `description` - TEXT
- `status` - TEXT
- `priority` - TEXT
- `due_date` - TIMESTAMP
- `reminder_time` - TIMESTAMP
- `tags` - TEXT[]
- `created_at` - TIMESTAMP
- `updated_at` - TIMESTAMP
- `completed_at` - TIMESTAMP

### recordings
- `id` - UUID (Primary Key)
- `user_id` - UUID (Foreign Key to profiles)
- `audio_url` - TEXT
- `duration` - INTEGER
- `transcription` - TEXT
- `created_at` - TIMESTAMP
- `updated_at` - TIMESTAMP

### tags
- `id` - UUID (Primary Key)
- `user_id` - UUID (Foreign Key to profiles)
- `name` - TEXT
- `created_at` - TIMESTAMP

## Functions

- `handle_new_user()` - Creates a profile when a new user signs up
- `update_updated_at_column()` - Updates the updated_at timestamp on record changes
- `process_tags()` - Extracts and stores tags from notes and tasks
- `search_items()` - Searches across notes and tasks

## License

MIT License