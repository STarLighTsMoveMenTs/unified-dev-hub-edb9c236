CREATE TABLE public.canvas_nodes (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  catalog_item_id uuid REFERENCES public.catalog_items(id) ON DELETE SET NULL,
  title text NOT NULL,
  node_type text NOT NULL DEFAULT 'infrastructure',
  tier text NOT NULL DEFAULT 'bronze',
  status text NOT NULL DEFAULT 'pending',
  note text NOT NULL DEFAULT '',
  pos_x integer NOT NULL DEFAULT 0,
  pos_y integer NOT NULL DEFAULT 0,
  links uuid[] NOT NULL DEFAULT '{}'::uuid[],
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.canvas_nodes TO authenticated;
GRANT ALL ON public.canvas_nodes TO service_role;

ALTER TABLE public.canvas_nodes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Own canvas nodes" ON public.canvas_nodes
  FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE TRIGGER canvas_nodes_updated_at
  BEFORE UPDATE ON public.canvas_nodes
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.timeline_events (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  phase text NOT NULL DEFAULT 'INIT',
  label text NOT NULL,
  detail text NOT NULL DEFAULT '',
  severity text NOT NULL DEFAULT 'info',
  created_at timestamp with time zone NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.timeline_events TO authenticated;
GRANT ALL ON public.timeline_events TO service_role;

ALTER TABLE public.timeline_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Own timeline events" ON public.timeline_events
  FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE INDEX canvas_nodes_user_idx ON public.canvas_nodes(user_id);
CREATE INDEX timeline_events_user_idx ON public.timeline_events(user_id, created_at DESC);