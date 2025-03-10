-- Migration: 002_tag_processing
-- Description: Add tag processing function and triggers

-- Insert this migration version
INSERT INTO schema_migrations (version) 
VALUES ('002_tag_processing')
ON CONFLICT (version) DO NOTHING;

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