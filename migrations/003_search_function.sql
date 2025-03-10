-- Migration: 003_search_function
-- Description: Add search function for notes and tasks

-- Insert this migration version
INSERT INTO schema_migrations (version) 
VALUES ('003_search_function')
ON CONFLICT (version) DO NOTHING;

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