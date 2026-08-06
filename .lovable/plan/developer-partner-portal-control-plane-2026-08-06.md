# Developer & Partner Portal (Control Plane)

Ein zentrales Portal auf Deutsch mit Top-Navigation, kontextueller Sidebar und Dashboard-Canvas — dark-mode-first, dichtes Developer-Tooling-Layout (kein generisches SaaS-Purple).

## Backend (Lovable Cloud)

Wird aktiviert für Login, Daten und API-Keys.

- Login: E-Mail/Passwort + Google. Profile-Tabelle (Name, Avatar, Rolle-unabhängig) mit Auto-Trigger.
- Rollen in separater `user_roles`-Tabelle (`user`, `partner`, `admin`) + `has_role()`-Funktion.
- Tabellen: `catalog_items` (Tools/SDKs/MCP-Server/Docker-Images mit Kategorie, Tech-Stack-Tags, Verified-Flag), `api_keys` (Hash + Prefix, nie Klartext gespeichert), `partner_applications` (Antrag, Status, Prüfergebnisse), `badges` (Typ, Status, Slug), `repositories` (verknüpfte Git-Repos), `deployments` (Verlauf, Status).
- RLS überall: eigene Zeilen für Nutzer, Katalog öffentlich lesbar, Partner-Anträge nur für Antragsteller + Admin.
- Seed-Daten in der Migration: ca. 20 Katalog-Einträge (SDKs, MCP-Server, Docker-Templates) damit die Kataloge sofort gefüllt sind.
- Server-Funktionen: API-Key erzeugen/widerrufen, Partner-Antrag einreichen, automatisierter Compliance-Check (Regelbasiert), Deployment simulieren/protokollieren.
- Badge-Endpoint: öffentliche Route, die ein dynamisches SVG-Badge ausliefert (für GitHub-Readmes einbindbar).

## Seiten & Navigation

Top-Bar: Logo + Systemstatus-Indikator, globale Suche (Cmd/Ctrl+K) über Katalog/Docs/MCP, rechts Workspace-Auswahl, Partner-Badge und Konto-Menü.
Linke Sidebar: passt sich dem aktiven Hauptbereich an.

1. `/` — Landing: Wertversprechen, One-Click-Bootstrapper-Snippet mit Copy-Button, CTA zur Registrierung.
2. `/auth` — Anmelden/Registrieren (E-Mail + Google).
3. `/entdecken` — Kategorien, Ökosystem-Verzeichnis, Tech-Stack-Suche mit Filtern; Detailansicht je Eintrag.
4. `/start` — One-Click: Install-Skripte (curl | sh), Docker-Compose-Templates, Quick-Start-Karten mit Copy-Buttons.
5. `/developer` — Dashboard: API-Keys verwalten, SDK-Übersicht, API-Referenz (Endpunkt-Liste mit Beispielen), MCP-Katalog mit fertigen `mcpServers`-JSON-Snippets für Cursor/Windsurf/Claude.
6. `/partner` — Partnerprogramm: Antrag stellen, Verification-Suite mit Checkliste und Status, Badge Center mit SVG-Vorschau und Einbettungs-Code.
7. `/deploy` — Repository verknüpfen (Git-URL), CI/CD-Runner-Ansicht, One-Click-Deploy mit Status-Log.

Geschützte Bereiche (5–7) liegen hinter dem Auth-Gate; Landing und Entdecken bleiben öffentlich.

## Design

Dark-first, technische Ästhetik: tiefes Anthrazit, ein präziser Akzent (Cyan/Grün für Status), Mono-Schrift für Code, kompakte Karten-Grids, sichtbare Status-Punkte. Alle Farben als semantische Tokens in `src/styles.css`.

## Nicht enthalten (bewusst)

Echte Docker-/CI-Ausführung, echte GitHub-OAuth-App-Installation und echte Zertifizierungs-Audits werden simuliert bzw. protokolliert — sie brauchen externe Infrastruktur. Kann später mit echten Integrationen (GitHub App, Runner) ergänzt werden.

## Technisch

TanStack Start Routen mit eigenen `head()`-Metadaten pro Seite; Datenzugriff über Server-Funktionen + TanStack Query; Zod-Validierung für alle Eingaben; Badge-SVG über `/api/public/badge/$slug`.
