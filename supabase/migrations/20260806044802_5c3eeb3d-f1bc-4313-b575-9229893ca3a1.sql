-- ROLES
CREATE TYPE public.app_role AS ENUM ('user', 'partner', 'admin');

CREATE TABLE public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text,
  company text,
  avatar_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Own profile read" ON public.profiles FOR SELECT TO authenticated USING (auth.uid() = id);
CREATE POLICY "Own profile insert" ON public.profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
CREATE POLICY "Own profile update" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

CREATE TABLE public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role public.app_role NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, role)
);
GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Own roles read" ON public.user_roles FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role)
$$;

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger LANGUAGE plpgsql SET search_path = public AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;

CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, avatar_url)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data ->> 'display_name', NEW.raw_user_meta_data ->> 'full_name', split_part(NEW.email, '@', 1)), NEW.raw_user_meta_data ->> 'avatar_url')
  ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.user_roles (user_id, role) VALUES (NEW.id, 'user') ON CONFLICT DO NOTHING;
  RETURN NEW;
END; $$;

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- CATALOG
CREATE TABLE public.catalog_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  name text NOT NULL,
  category text NOT NULL,
  kind text NOT NULL,
  vendor text,
  description text NOT NULL,
  tech_stack text[] NOT NULL DEFAULT '{}',
  install_command text,
  docker_compose text,
  mcp_config jsonb,
  docs_url text,
  verified boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.catalog_items TO anon;
GRANT SELECT ON public.catalog_items TO authenticated;
GRANT ALL ON public.catalog_items TO service_role;
ALTER TABLE public.catalog_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Catalog public read" ON public.catalog_items FOR SELECT TO anon, authenticated USING (true);

-- API KEYS
CREATE TABLE public.api_keys (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  key_prefix text NOT NULL,
  key_hash text NOT NULL,
  scopes text[] NOT NULL DEFAULT '{read}',
  revoked boolean NOT NULL DEFAULT false,
  last_used_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.api_keys TO authenticated;
GRANT ALL ON public.api_keys TO service_role;
ALTER TABLE public.api_keys ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Own api keys" ON public.api_keys FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- PARTNER APPLICATIONS
CREATE TABLE public.partner_applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  company_name text NOT NULL,
  website text NOT NULL,
  solution_name text NOT NULL,
  solution_description text NOT NULL,
  repo_url text,
  contact_email text NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  checks jsonb NOT NULL DEFAULT '[]'::jsonb,
  score integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.partner_applications TO authenticated;
GRANT ALL ON public.partner_applications TO service_role;
ALTER TABLE public.partner_applications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Own applications" ON public.partner_applications FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins read applications" ON public.partner_applications FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins update applications" ON public.partner_applications FOR UPDATE TO authenticated USING (public.has_role(auth.uid(), 'admin')) WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE TRIGGER partner_applications_updated_at BEFORE UPDATE ON public.partner_applications
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- BADGES
CREATE TABLE public.badges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  application_id uuid REFERENCES public.partner_applications(id) ON DELETE SET NULL,
  slug text NOT NULL UNIQUE,
  badge_type text NOT NULL,
  label text NOT NULL,
  status text NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.badges TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.badges TO authenticated;
GRANT ALL ON public.badges TO service_role;
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Badges public read" ON public.badges FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Own badges write" ON public.badges FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own badges update" ON public.badges FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own badges delete" ON public.badges FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- REPOSITORIES
CREATE TABLE public.repositories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  provider text NOT NULL DEFAULT 'github',
  full_name text NOT NULL,
  url text NOT NULL,
  default_branch text NOT NULL DEFAULT 'main',
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.repositories TO authenticated;
GRANT ALL ON public.repositories TO service_role;
ALTER TABLE public.repositories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Own repositories" ON public.repositories FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- DEPLOYMENTS
CREATE TABLE public.deployments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  repository_id uuid REFERENCES public.repositories(id) ON DELETE CASCADE,
  environment text NOT NULL DEFAULT 'production',
  status text NOT NULL DEFAULT 'queued',
  commit_sha text,
  log text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.deployments TO authenticated;
GRANT ALL ON public.deployments TO service_role;
ALTER TABLE public.deployments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Own deployments" ON public.deployments FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_catalog_category ON public.catalog_items (category);
CREATE INDEX idx_api_keys_user ON public.api_keys (user_id);
CREATE INDEX idx_deployments_user ON public.deployments (user_id);

-- SEED CATALOG
INSERT INTO public.catalog_items (slug, name, category, kind, vendor, description, tech_stack, install_command, docker_compose, mcp_config, docs_url, verified) VALUES
('platform-sdk-ts','Platform SDK (TypeScript)','SDKs & Frameworks','sdk','Platform','Typsicheres SDK für alle Plattform-APIs, inkl. Auto-Retry und Streaming.','{TypeScript,Node.js,Deno}','npm install @platform/sdk',NULL,NULL,'/developer',true),
('platform-sdk-python','Platform SDK (Python)','SDKs & Frameworks','sdk','Platform','Async-fähiger Python-Client mit Pydantic-Modellen.','{Python,FastAPI}','pip install platform-sdk',NULL,NULL,'/developer',true),
('platform-sdk-go','Platform SDK (Go)','SDKs & Frameworks','sdk','Platform','Schlanker Go-Client mit Context-Support.','{Go}','go get github.com/platform/sdk-go',NULL,NULL,'/developer',true),
('platform-sdk-rust','Platform SDK (Rust)','SDKs & Frameworks','sdk','Platform','Zero-Copy Rust-Client für hohe Durchsätze.','{Rust,Tokio}','cargo add platform-sdk',NULL,NULL,'/developer',false),
('platform-cli','Platform CLI','Tooling','cli','Platform','Kommandozeilen-Tool für Login, Deploys und Log-Streams.','{CLI,Shell}','curl -fsSL https://get.your-platform.io/install.sh | bash',NULL,NULL,'/start',true),
('nextjs-starter','Next.js Starter','Frameworks','template','Community','Produktionsreifes Next.js-Template mit Auth und Zero-Trust-Token.','{TypeScript,"Next.js",Tailwind}','npx create-platform-app --template nextjs',NULL,NULL,'/start',true),
('tanstack-starter','TanStack Start Starter','Frameworks','template','Community','SSR-Template mit Server-Functions und Edge-Deployment.','{TypeScript,React,Vite}','npx create-platform-app --template tanstack',NULL,NULL,'/start',true),
('svelte-starter','SvelteKit Starter','Frameworks','template','Community','Leichtgewichtiges SvelteKit-Template mit Passkey-Login.','{TypeScript,SvelteKit}','npx create-platform-app --template sveltekit',NULL,NULL,'/start',false),
('api-gateway','API Gateway','Infrastructure','docker','Platform','NGINX-basiertes Gateway mit Rate-Limiting und mTLS.','{Docker,NGINX}',NULL,'services:
  api-gateway:
    image: nginx:alpine
    ports:
      - "8080:80"
    environment:
      - SERVICE_NAME=developer-gateway',NULL,'/start',true),
('mcp-bridge','MCP Bridge','Infrastructure','docker','Platform','Bridge-Container, der lokale MCP-Server über HTTP erreichbar macht.','{Docker,MCP}',NULL,'services:
  mcp-bridge:
    image: platform/mcp-bridge:latest
    ports:
      - "8811:8811"
    environment:
      - MCP_SERVER_ENABLED=true',NULL,'/developer',true),
('postgres-dev','Postgres Dev Stack','Infrastructure','docker','Community','Postgres 16 mit Extensions und Seed-Skripten für lokale Entwicklung.','{Docker,Postgres}',NULL,'services:
  db:
    image: postgres:16-alpine
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_PASSWORD=platform',NULL,NULL,true),
('redis-cache','Redis Cache','Infrastructure','docker','Community','Redis 7 als Cache- und Queue-Layer.','{Docker,Redis}',NULL,'services:
  cache:
    image: redis:7-alpine
    ports:
      - "6379:6379"',NULL,NULL,false),
('mcp-platform-core','MCP: Platform Core','MCP Server','mcp','Platform','Gibt KI-Agenten Zugriff auf Projekte, Deployments und Logs.','{MCP,Docker}',NULL,NULL,'{"mcpServers":{"platform-core":{"command":"docker","args":["run","-i","--rm","-e","API_KEY","platform/mcp-core:latest"],"env":{"API_KEY":"dein_api_key"}}}}','/developer',true),
('mcp-postgres','MCP: Postgres','MCP Server','mcp','Community','Read-only SQL-Zugriff für Agenten auf eine Postgres-Datenbank.','{MCP,Postgres}',NULL,NULL,'{"mcpServers":{"postgres":{"command":"npx","args":["-y","@modelcontextprotocol/server-postgres","postgresql://localhost/mydb"]}}}',NULL,true),
('mcp-filesystem','MCP: Filesystem','MCP Server','mcp','Community','Kontrollierter Dateizugriff im Projektordner.','{MCP,Node.js}',NULL,NULL,'{"mcpServers":{"filesystem":{"command":"npx","args":["-y","@modelcontextprotocol/server-filesystem","./"]}}}',NULL,true),
('mcp-git','MCP: Git','MCP Server','mcp','Community','Commits, Diffs und Branches als Agenten-Kontext.','{MCP,Git}',NULL,NULL,'{"mcpServers":{"git":{"command":"uvx","args":["mcp-server-git","--repository","."]}}}',NULL,true),
('mcp-docs','MCP: Docs Search','MCP Server','mcp','Platform','Semantische Suche über die komplette API-Referenz.','{MCP,HTTP}',NULL,NULL,'{"mcpServers":{"platform-docs":{"url":"https://mcp.your-platform.io/docs"}}}','/developer',true),
('mcp-observability','MCP: Observability','MCP Server','mcp','Platform','Metriken, Traces und Fehler direkt in der IDE abfragen.','{MCP,OpenTelemetry}',NULL,NULL,'{"mcpServers":{"observability":{"url":"https://mcp.your-platform.io/otel"}}}',NULL,false),
('auth-identity','Identity Gateway','Security','service','Platform','OAuth 2.1, Passkeys und Zero-Trust-Token-Ausgabe.','{OAuth,Passkeys,JWT}','npm install @platform/identity',NULL,NULL,'/developer',true),
('vault-secrets','Secrets Vault','Security','service','Platform','Verschlüsselte Secrets mit kurzer Lebensdauer und Audit-Log.','{Vault,KMS}','platform secrets init',NULL,NULL,NULL,true),
('scanner-compliance','Compliance Scanner','Security','service','Platform','Automatisierter Security- und Lizenz-Check für ISV-Lösungen.','{SAST,SBOM}','platform verify --repo .',NULL,NULL,'/partner',true),
('runner-ci','CI/CD Runner','Code & Deploy','service','Platform','Selbst-hostbarer Runner für Build- und Deploy-Pipelines.','{Docker,CI}','docker run -d platform/runner:latest',NULL,NULL,'/deploy',true),
('deploy-edge','Edge Deploy','Code & Deploy','service','Platform','Globales Deployment auf Edge-Workern in unter 30 Sekunden.','{Edge,Workers}','platform deploy --env production',NULL,NULL,'/deploy',true),
('webhooks-relay','Webhook Relay','Code & Deploy','service','Community','Signierte Webhooks lokal empfangen und wiederholen.','{Webhooks,HMAC}','platform webhooks listen',NULL,NULL,NULL,false);