# Titanium Infinity Portal — Design- & Engine-Umbau (alles in einem Durchgang)

Das bestehende Portal (Landing, Entdecken, Start, Developer, Partner, Deploy, Auth) behält seine Funktionen und wird komplett auf die Titanium-Glassmorphic-Ästhetik umgestellt — plus eine neue unendliche Node-Canvas als zentrales Arbeitsfeld. Alles wird in einem Durchgang parallel gebaut, nicht in Etappen.

## 1. Design-System (Basis für alles)

Alle Farben, Metalle, Glows und Texturen als semantische Tokens in `src/styles.css`:

- EU-Blau `#003399`, Neon-Rot `#FF2A6D`, Cyber-Orange `#FF7700`, Vibrant-Pink `#FF007F`, Titan-Dunkel `#0A0C10` (als oklch-Tokens).
- Metall-Legierungen als Gradient-Tokens: Gold, Silber, Bronze, gebürstetes Titan.
- Glass-Utilities (`@utility`): `titan-panel`, `glass-panel` (backdrop-blur, Kanten-Lichtsaum), `prism-edge`, Glow-Varianten pro Status (blau/pink/orange/rot/grün).
- Blueprint-Construction-Background als Utility: Konstruktionsraster + Schaltplan-Vektoren + Radial-Vignette.
- Status-Semantik: Blau = zertifiziert/Vertrag, Grün = live, Orange = Sync, Rot = kritisch, Pink = aktiv/Hover.

## 2. Infinite Node Canvas (neuer Bereich `/canvas`)

- Frei pan- und zoombare Fläche (Pointer-Drag zum Verschieben, Wheel/Pinch-Zoom mit Cursor-Anker, Zoom-Buttons, „Fit“/„Reset“).
- Nodes sind Partner-/Portal-Karten: Tier-Badge (Gold/Silber/Bronze), Validierungsstatus, Dev-Docs-Link, Install-Skript, Docker-Pull, MCP-Connector-Status, Aktionen (Auto-Register, Sync, Details).
- Nodes können hinzugefügt, verschoben (Drag am Node-Header), magnetisch am Raster eingerastet und entfernt werden; Position pro Node gespeichert.
- Verbindungslinien zwischen gepaarten Nodes (Partner-Geschwister) als SVG-Kurven mit Energie-Fluss-Animation.
- Blueprint-Overlay mit System-Metadaten und Live-Koordinaten/Zoomstufe.
- Datenbasis: Katalog- und Partner-Einträge aus dem Backend; Canvas-Layout (x, y, Verknüpfungen) in einer neuen Tabelle pro Nutzer.

## 3. Timeline & Timestamp Engine (global, unten fixiert)

- Millisekundengenauer Live-Zeitstempel mit Glitch-Morph beim Ziffernwechsel.
- Event-Log-Leiste: jede Aktion (Key erzeugt, Deployment, Compliance-Check, Auto-Register, Node-Sync) erscheint als Marker auf der Zeitskala.
- Laser-Nadel als Scrubber mit Nachleucht-Spur; Hover auf Marker zeigt Detail-Tooltip.
- Fortschritts-Pipeline mit Phasen (INIT → DISCOVER → VALIDATE → VAULT_PUSH → SYNC_COMPLETE).

## 4. Animationen (33+ Effekte, in Stufen konfigurierbar)

Umgesetzt als CSS-Utilities plus wenige kleine JS-Hooks, gruppiert wie in der Vision: Metallic-Shader (Specular Sweep, Liquid Gold, Mercury Wave, Patina, Damascus Shimmer), Glas-Optik (Prisma-Dispersion, Caustics, Frost-Melt, God Rays, Mirror Sheen), Energie (Tesla-Arc zwischen Nodes, Plasma-Kante, Laser-Scanline, Solar-Flare, Heartbeat-Bleed), Raum (3D-Parallax-Tilt, magnetisches Snappen, Fraktal-Zoom, Origami-Fold, Wormhole-Wechsel), Partikel (Constellation-Blueprint, Funken, Quantum-Dust mit Cursor-Verdrängung, Wireframe-Projektion, Code-Cascade), Timeline-Motion (Laser-Nadel, Elastic-Ripple, Clock-Glitch, Progress-Ring, Audit-Siegel-Stempel), Mikro-Interaktionen (Neon-Border-Tracing, haptischer Glas-Klick, Text-Elevation, Iris-Shutter).

Ein Performance-Schalter in der Top-Bar (Voll / Reduziert / Aus) und `prefers-reduced-motion` schalten die teuren Partikel-/Ray-Effekte ab, damit die Oberfläche flüssig bleibt.

## 5. Umbau der bestehenden Seiten (parallel, gleiche Sprache)

- Top-Bar: Titan-Glas, EU-Logo mit Legierungs-Puls, Systemstatus, ⌘K-Suche, Tier-/MFA-/Vault-Badges, Node-hinzufügen-Button, Motion-Schalter.
- Sidebar: Titan-Lamellen mit Iris-Shutter-Aufklappen.
- Landing, Entdecken, Start, Developer, Partner, Deploy: gleiche Panels, Metall-Badges, Glow-Status und Ripple-Aktionen; Inhalte und Server-Funktionen bleiben unverändert.
- Timeline-Footer und Construction-Background auf allen Seiten.

## 6. Technisch

- Tailwind v4: alle Tokens in `@theme inline`, Effekte als `@utility`; keine hartcodierten Farbklassen, kein hand-geschriebenes `-webkit-backdrop-filter`.
- Canvas: native non-passive Wheel-Listener, exponentielles Zoomen mit Cursor-Anker, Transform via `translate() scale()` mit `transform-origin: 0 0`, Pointer Events für Touch.
- Partikel/Rays über Canvas-2D in einem `requestAnimationFrame`-Loop, nur clientseitig gemountet; sonst reines CSS.
- Neue Migration für `canvas_nodes` (Nutzer-Layout) und `timeline_events`, jeweils mit GRANTs und RLS auf eigene Zeilen; `/canvas` liegt hinter dem Auth-Gate.
- Eigene `head()`-Metadaten für die neue Route.
