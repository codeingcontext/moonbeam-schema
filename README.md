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
- Bash shell (for running the migration script)
- curl (for API requests in the migration script)

### Installation Options

#### Option 1: Manual Setup

1. **Create a new Supabase project**

2. **Run the schema SQL**
   - Go to the SQL Editor in your Supabase dashboard
   - Copy the contents of `schema.sql`
   - Paste and run the SQL in the editor

3. **Set up storage buckets**
   - Run the `storage_setup.sql` script in the SQL Editor

4. **Load sample data (optional)**
   - Edit the `sample_data.sql` file to replace `'your-user-id'` with your actual user ID
   - Run the modified script in the SQL Editor

#### Option 2: Using Migrations

1. **Create a new Supabase project**

2. **Run the migration script**
   ```bash
   # Make the script executable
   chmod +x run_migrations.sh
   
   # Run the migrations
   SUPABASE_URL=https://your-project-id.supabase.co SUPABASE_KEY=your-anon-key ./run_migrations.sh
   ```

3. **Load sample data (optional)**
   - Edit the `sample_data.sql` file to replace `'your-user-id'` with your actual user ID
   - Run the modified script in the SQL Editor

### Configure Authentication

- Enable Email/Password sign-up in Authentication settings
- (Optional) Configure additional auth providers like Google, Apple, etc.

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

## Migrations

The `migrations` directory contains SQL scripts for incremental database updates:

1. `001_initial_schema.sql` - Creates the base tables and functions
2. `002_tag_processing.sql` - Adds tag processing functionality
3. `003_search_function.sql` - Adds search functionality
4. `004_storage_setup.sql` - Sets up storage buckets and policies

## License

MIT License