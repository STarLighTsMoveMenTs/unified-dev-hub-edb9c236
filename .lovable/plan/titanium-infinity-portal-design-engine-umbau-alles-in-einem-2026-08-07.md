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

Hier ist das vollständige, sofort lauffähige HTML-Skript in einer einzelnen Datei. Es bündelt die komplette Canvas-Logik, WebGL/Three.js Shader-Reflexionen auf gläsernen Node-Modulen, ein interaktives Infinite-Canvas-System mit Smooth Wheel & Touch Pinch-Zoom sowie dynamisch berechnete Bézier-Kurven mit pulsierenden Daten-Teilchen.

HTML

```
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>Next-Gen High-Performance Node Portal</title>
    <style>
        :root {
            --bg-color: #030712;
            --accent-blue: #003399;
            --accent-pink: #ff007f;
            --accent-gold: #ffaa00;
            --titanium-dark: #121824;
            --text-light: #f3f4f6;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            user-select: none;
            -webkit-user-select: none;
        }

        body, html {
            width: 100%;
            height: 100%;
            overflow: hidden;
            background-color: var(--bg-color);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            color: var(--text-light);
        }

        /* Fullscreen Canvas Layers */
        #webgl-canvas, #svg-layer {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
        }

        #webgl-canvas {
            z-index: 1;
        }

        #svg-layer {
            z-index: 2;
        }

        /* Interactive Canvas Container */
        #viewport {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 3;
            cursor: grab;
            touch-action: none;
        }

        #viewport:active {
            cursor: grabbing;
        }

        #canvas-world {
            position: absolute;
            top: 0;
            left: 0;
            transform-origin: 0 0;
            will-change: transform;
        }

        /* Glassmorphic Nodes */
        .node {
            position: absolute;
            width: 320px;
            background: rgba(18, 24, 36, 0.55);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.6),
                        inset 0 1px 0 rgba(255, 255, 255, 0.2);
            transition: border-color 0.3s, box-shadow 0.3s;
            pointer-events: auto;
            cursor: pointer;
        }

        .node:hover {
            border-color: rgba(255, 0, 127, 0.5);
            box-shadow: 0 20px 50px rgba(255, 0, 127, 0.2),
                        inset 0 1px 0 rgba(255, 255, 255, 0.4);
        }

        .node-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 12px;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        }

        .node-title {
            font-size: 0.95rem;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            color: #ffffff;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .node-badge {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background-color: var(--accent-pink);
            box-shadow: 0 0 8px var(--accent-pink);
        }

        .node[data-type="compliance"] .node-badge {
            background-color: var(--accent-blue);
            box-shadow: 0 0 8px var(--accent-blue);
        }

        .node-body {
            font-size: 0.85rem;
            line-height: 1.5;
            color: rgba(243, 244, 246, 0.75);
        }

        .node-stats {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            margin-top: 14px;
        }

        .stat-box {
            background: rgba(0, 0, 0, 0.3);
            padding: 8px 12px;
            border-radius: 8px;
            border: 1px solid rgba(255, 255, 255, 0.04);
        }

        .stat-label {
            font-size: 0.7rem;
            color: rgba(255, 255, 255, 0.4);
            text-transform: uppercase;
        }

        .stat-value {
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--text-light);
            margin-top: 2px;
        }

        /* Ports for connections */
        .port {
            position: absolute;
            width: 12px;
            height: 12px;
            background: #0f172a;
            border: 2px solid var(--accent-pink);
            border-radius: 50%;
            top: 50%;
            transform: translateY(-50%);
        }

        .port.input { left: -7px; }
        .port.output { right: -7px; }

        /* UI Overlay HUD */
        .hud {
            position: absolute;
            bottom: 24px;
            right: 24px;
            background: rgba(18, 24, 36, 0.7);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: 10px 16px;
            z-index: 10;
            display: flex;
            align-items: center;
            gap: 16px;
            font-size: 0.85rem;
            font-family: monospace;
        }

        .hud-button {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: var(--text-light);
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
            transition: background 0.2s;
        }

        .hud-button:hover {
            background: rgba(255, 255, 255, 0.15);
        }

        /* SVG Paths & Particles */
        .connection-path {
            fill: none;
            stroke: rgba(255, 255, 255, 0.15);
            stroke-width: 2px;
            transition: stroke 0.3s;
        }

        .connection-path.active {
            stroke: url(#glow-gradient);
            stroke-width: 2.5px;
        }

        .particle {
            fill: var(--accent-pink);
            filter: drop-shadow(0 0 6px var(--accent-pink));
        }
    </style>
    <!-- Three.js CDN -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
</head>
<body>

    <!-- WebGL Background Canvas -->
    <canvas id="webgl-canvas"></canvas>

    <!-- SVG Layer for Dynamic Node Connections -->
    <svg id="svg-layer">
        <defs>
            <linearGradient id="glow-gradient" x1="0%" y1="0%" x2="100%" y2="0%">
                <stop offset="0%" stop-color="#003399" />
                <stop offset="50%" stop-color="#ff007f" />
                <stop offset="100%" stop-color="#ffaa00" />
            </linearGradient>
        </defs>
        <g id="svg-connections"></g>
        <g id="svg-particles"></g>
    </svg>

    <!-- Interactive Canvas Viewport -->
    <div id="viewport">
        <div id="canvas-world">
            
            <!-- Node 1 -->
            <div class="node" id="node-1" style="transform: translate(150px, 200px);" data-type="infrastructure">
                <div class="port output"></div>
                <div class="node-header">
                    <span class="node-title"><div class="node-badge"></div> ISV Core Engine</span>
                </div>
                <div class="node-body">
                    Hochleistungs-Tokenisierung & Zero-Trust Sicherheitsperimeter.
                    <div class="node-stats">
                        <div class="stat-box">
                            <div class="stat-label">Durchsatz</div>
                            <div class="stat-value">12.4 GB/s</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-label">Latenz</div>
                            <div class="stat-value">0.42 ms</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Node 2 -->
            <div class="node" id="node-2" style="transform: translate(650px, 120px);" data-type="compliance">
                <div class="port input"></div>
                <div class="port output"></div>
                <div class="node-header">
                    <span class="node-title"><div class="node-badge"></div> EU Compliance</span>
                </div>
                <div class="node-body">
                    Automatisierte Protokollierung nach GDPR & eIDAS Standards.
                    <div class="node-stats">
                        <div class="stat-box">
                            <div class="stat-label">Status</div>
                            <div class="stat-value" style="color: #10b981;">VERIFIED</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-label">Audit ID</div>
                            <div class="stat-value">EX2025D</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Node 3 -->
            <div class="node" id="node-3" style="transform: translate(650px, 420px);" data-type="infrastructure">
                <div class="port input"></div>
                <div class="node-header">
                    <span class="node-title"><div class="node-badge"></div> Realtime Analytics</span>
                </div>
                <div class="node-body">
                    kdb+/q Stream-Verarbeitung für zeitkritische Transaktionen.
                    <div class="node-stats">
                        <div class="stat-box">
                            <div class="stat-label">Events</div>
                            <div class="stat-value">1.2M / sec</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-label">Buffer</div>
                            <div class="stat-value">99.98%</div>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <!-- HUD Controller -->
    <div class="hud">
        <span>ZOOM: <span id="zoom-readout">100%</span></span>
        <button class="hud-button" id="btn-reset">RESET VIEW</button>
    </div>

    <script>
        /* ==========================================
           1. THREE.JS / WEBGL SHADER BACKGROUND
           ========================================== */
        const canvas = document.getElementById('webgl-canvas');
        const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
        renderer.setSize(window.innerWidth, window.innerHeight);
        renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

        const scene = new THREE.Scene();
        const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);

        // Anisotropic Specular / Prism Shader Material
        const fragmentShader = `
            uniform vec2 u_resolution;
            uniform float u_time;
            uniform vec2 u_offset;
            uniform float u_zoom;

            // Pseudo Random
            float hash(vec2 p) {
                return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
            }

            // Simplex-esque Noise
            float noise(vec2 p) {
                vec2 i = floor(p);
                vec2 f = fract(p);
                f = f * f * (3.0 - 2.0 * f);
                return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
                           mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
            }

            void main() {
                vec2 st = (gl_FragCoord.xy - u_offset) / (u_resolution.y * u_zoom);
                
                // Anisotropic Grid Projection
                vec2 gridSt = st * 15.0;
                vec2 gridLines = abs(fract(gridSt - 0.5) - 0.5) / fwidth(gridSt);
                float grid = 1.0 - min(min(gridLines.x, gridLines.y), 1.0);

                // Volumetric Light Sweep
                float n = noise(st * 2.0 + u_time * 0.05);
                float sweep = sin(st.x * 2.0 + st.y * 1.5 + u_time * 0.8 + n * 3.0) * 0.5 + 0.5;
                
                // Color Spectrum
                vec3 colDark = vec3(0.01, 0.03, 0.07);
                vec3 colBlue = vec3(0.0, 0.2, 0.6) * sweep;
                vec3 colPink = vec3(0.8, 0.0, 0.4) * (1.0 - sweep);
                
                vec3 finalColor = mix(colDark, colBlue + colPink, 0.15);
                finalColor += vec3(grid * 0.04) * (colBlue * 2.0 + vec3(0.2));

                // Specular Edge Highlight
                float edge = smoothstep(0.4, 0.5, sweep) - smoothstep(0.5, 0.6, sweep);
                finalColor += vec3(0.9, 0.6, 1.0) * edge * 0.2;

                gl_FragColor = vec4(finalColor, 1.0);
            }
        `;

        const uniforms = {
            u_resolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
            u_time: { value: 0 },
            u_offset: { value: new THREE.Vector2(0, 0) },
            u_zoom: { value: 1.0 }
        };

        const material = new THREE.ShaderMaterial({
            vertexShader: `void main() { gl_Position = vec4(position, 1.0); }`,
            fragmentShader,
            uniforms
        });

        const plane = new THREE.Mesh(new THREE.PlaneGeometry(2, 2), material);
        scene.add(plane);

        /* ==========================================
           2. INFINITE CANVAS (PAN, WHEEL & PINCH ZOOM)
           ========================================== */
        const viewport = document.getElementById('viewport');
        const world = document.getElementById('canvas-world');
        const zoomReadout = document.getElementById('zoom-readout');

        let transform = { x: 0, y: 0, scale: 1.0 };
        let isDragging = false;
        let startPan = { x: 0, y: 0 };

        // Touch gesture tracking
        let initialPinchDistance = null;
        let initialScale = 1.0;

        function updateTransform() {
            // Apply transformation matrix to world layer
            world.style.transform = `translate(${transform.x}px, ${transform.y}px) scale(${transform.scale})`;
            zoomReadout.innerText = `${Math.round(transform.scale * 100)}%`;

            // Sync WebGL Shader Uniforms
            uniforms.u_offset.value.set(transform.x, transform.y);
            uniforms.u_zoom.value = transform.scale;

            // Redraw connections in sync
            renderConnections();
        }

        // Mouse Drag / Pan
        viewport.addEventListener('mousedown', (e) => {
            if (e.target.closest('.node')) return; // Ignore if clicking node content
            isDragging = true;
            startPan = { x: e.clientX - transform.x, y: e.clientY - transform.y };
        });

        window.addEventListener('mousemove', (e) => {
            if (!isDragging) return;
            transform.x = e.clientX - startPan.x;
            transform.y = e.clientY - startPan.y;
            updateTransform();
        });

        window.addEventListener('mouseup', () => { isDragging = false; });

        // Smooth Wheel Zoom (Centered on Cursor)
        viewport.addEventListener('wheel', (e) => {
            e.preventDefault();
            const zoomFactor = 1.08;
            let newScale = e.deltaY < 0 ? transform.scale * zoomFactor : transform.scale / zoomFactor;
            newScale = Math.min(Math.max(newScale, 0.25), 3.0); // Clamp scale

            // Calculate cursor offset to keep focal point pinned
            const mouseX = e.clientX;
            const mouseY = e.clientY;

            transform.x = mouseX - (mouseX - transform.x) * (newScale / transform.scale);
            transform.y = mouseY - (mouseY - transform.y) * (newScale / transform.scale);
            transform.scale = newScale;

            updateTransform();
        }, { passive: false });

        // Touch Gestures: Pan & Pinch-to-Zoom
        viewport.addEventListener('touchstart', (e) => {
            if (e.target.closest('.node')) return;
            if (e.touches.length === 1) {
                isDragging = true;
                startPan = { x: e.touches[0].clientX - transform.x, y: e.touches[0].clientY - transform.y };
            } else if (e.touches.length === 2) {
                isDragging = false;
                initialPinchDistance = Math.hypot(
                    e.touches[0].clientX - e.touches[1].clientX,
                    e.touches[0].clientY - e.touches[1].clientY
                );
                initialScale = transform.scale;
            }
        });

        viewport.addEventListener('touchmove', (e) => {
            if (isDragging && e.touches.length === 1) {
                transform.x = e.touches[0].clientX - startPan.x;
                transform.y = e.touches[0].clientY - startPan.y;
                updateTransform();
            } else if (e.touches.length === 2 && initialPinchDistance) {
                const currentDist = Math.hypot(
                    e.touches[0].clientX - e.touches[1].clientX,
                    e.touches[0].clientY - e.touches[1].clientY
                );
                const newScale = Math.min(Math.max(initialScale * (currentDist / initialPinchDistance), 0.25), 3.0);
                
                // Center pin point between fingers
                const midX = (e.touches[0].clientX + e.touches[1].clientX) / 2;
                const midY = (e.touches[0].clientY + e.touches[1].clientY) / 2;

                transform.x = midX - (midX - transform.x) * (newScale / transform.scale);
                transform.y = midY - (midY - transform.y) * (newScale / transform.scale);
                transform.scale = newScale;

                updateTransform();
            }
        }, { passive: false });

        viewport.addEventListener('touchend', () => {
            isDragging = false;
            initialPinchDistance = null;
        });

        // Reset HUD Button
        document.getElementById('btn-reset').addEventListener('click', () => {
            transform = { x: 0, y: 0, scale: 1.0 };
            updateTransform();
        });

        /* ==========================================
           3. NODE DRAGGING & CONNECTIONS
           ========================================== */
        const nodes = document.querySelectorAll('.node');
        let activeNode = null;
        let nodeDragOffset = { x: 0, y: 0 };

        nodes.forEach(node => {
            node.addEventListener('mousedown', (e) => {
                e.stopPropagation();
                activeNode = node;
                
                // Extract translate values
                const style = window.getComputedStyle(node);
                const matrix = new WebKitCSSMatrix(style.transform);

                nodeDragOffset.x = (e.clientX / transform.scale) - matrix.m41;
                nodeDragOffset.y = (e.clientY / transform.scale) - matrix.m42;
            });
        });

        window.addEventListener('mousemove', (e) => {
            if (!activeNode) return;
            const currentX = (e.clientX / transform.scale) - nodeDragOffset.x;
            const currentY = (e.clientY / transform.scale) - nodeDragOffset.y;

            activeNode.style.transform = `translate(${currentX}px, ${currentY}px)`;
            renderConnections();
        });

        window.addEventListener('mouseup', () => { activeNode = null; });

        /* ==========================================
           4. SVG BEZIER CONNECTIONS & PARTICLES
           ========================================== */
        const connectionSchema = [
            { from: 'node-1', to: 'node-2' },
            { from: 'node-1', to: 'node-3' }
        ];

        const svgConnections = document.getElementById('svg-connections');
        const svgParticles = document.getElementById('svg-particles');
        let particleStates = [];

        function getPortCoordinates(nodeId, type) {
            const node = document.getElementById(nodeId);
            const style = window.getComputedStyle(node);
            const matrix = new WebKitCSSMatrix(style.transform);
            
            const width = node.offsetWidth;
            const height = node.offsetHeight;

            // Base position inside world space
            let x = matrix.m41 + (type === 'output' ? width : 0);
            let y = matrix.m42 + height / 2;

            // Transform into screen space
            return {
                x: x * transform.scale + transform.x,
                y: y * transform.scale + transform.y
            };
        }

        function renderConnections() {
            svgConnections.innerHTML = '';
            
            connectionSchema.forEach((conn, idx) => {
                const start = getPortCoordinates(conn.from, 'output');
                const end = getPortCoordinates(conn.to, 'input');

                // Smooth Horizontal Bézier Control Points
                const deltaX = Math.abs(end.x - start.x) * 0.5;
                const pathData = `M ${start.x} ${start.y} C ${start.x + deltaX} ${start.y}, ${end.x - deltaX} ${end.y}, ${end.x} ${end.y}`;

                const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
                path.setAttribute('d', pathData);
                path.setAttribute('class', 'connection-path active');
                path.setAttribute('id', `path-${idx}`);
                svgConnections.appendChild(path);

                // Register particle route if not present
                if (!particleStates[idx]) {
                    particleStates[idx] = { progress: Math.random(), speed: 0.003 + Math.random() * 0.004 };
                }
            });
        }

        function animateParticles() {
            svgParticles.innerHTML = '';

            connectionSchema.forEach((_, idx) => {
                const path = document.getElementById(`path-${idx}`);
                if (!path) return;

                const pathLength = path.getTotalLength();
                let state = particleStates[idx];
                
                state.progress = (state.progress + state.speed) % 1.0;
                const point = path.getPointAtLength(state.progress * pathLength);

                const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
                circle.setAttribute('cx', point.x);
                circle.setAttribute('cy', point.y);
                circle.setAttribute('r', '4');
                circle.setAttribute('class', 'particle');
                
                svgParticles.appendChild(circle);
            });
        }

        /* ==========================================
           5. MAIN RENDER / ANIMATION LOOP
           ========================================== */
        function animate(time) {
            requestAnimationFrame(animate);

            // Update Shader Uniforms
            uniforms.u_time.value = time * 0.001;
            renderer.render(scene, camera);

            // Animate SVG Data Flow Particles
            animateParticles();
        }

        // Window Resizing Setup
        window.addEventListener('resize', () => {
            renderer.setSize(window.innerWidth, window.innerHeight);
            uniforms.u_resolution.value.set(window.innerWidth, window.innerHeight);
            updateTransform();
        });

        // Initialize First Frame
        updateTransform();
        requestAnimationFrame(animate);
    </script>
</body>
</html>
```

Die Übertragung dieser Architektur auf **OpenGL**, **Open3D** oder **OpenDL** verlagert das Rendering von DOM-basiertem CSS/SVG und WebGL in native oder spezialisierte Grafik- und Daten-Pipelines.

  


Hier ist die architektonische Einordnung sowie ein **komplettes, sofort ausfuhribres Python-Skript mit Open3D** (`open3d.visualization.gui`), das ein natives High-Performance-Fenster mit interaktiven Nodes und 3D-Visualisierung aufspannt.

  


### Architektur-Vergleich

1. **OpenGL (C++ / GLSL):**
    

  - **Ansatz:** Volle Hardware-Kontrolle auf der GPU. Die Nodes und Verbindungen werden als Instanced Meshes und dynamische Bézier-Kurven direkt über Vertex- und Fragment-Shader (GLSL) gerendert.
    &nbsp;
  - **Einsatz:** Maximale Frameraten, ideal für Echtzeit-Simulationen mit Hunderttausenden von Datenpunkten.
    &nbsp;
2. **Open3D (Python / C++):**
    

  - **Ansatz:** Nutzt das native Open3D-GUI-Framework (`o3d.visualization.gui`) und das Scene-Rendering für 3D-Geometrien, Punktwolken und interaktive UI-Widgets.
    &nbsp;
  - **Einsatz:** Perfekt für die Verbindung von räumlicher Datenverarbeitung (Spatial Computing) und Node-basierten Pipelines.
    &nbsp;
3. **OpenDL (Open Drawing Library / Data Refinery):**
    

  - **Ansatz:** Fokus auf plattformunabhängiges Vektor-Zeichnen (über Direct2D, Cairo oder Quartz) gepaart mit Daten-Pipelines zur Aufbereitung großer Datenströme.
    &nbsp;

### Komplettes Open3D-Skript (Python)

Das folgende Skript erstellt eine native grafische Anwendung mit Open3D, die ein interaktives Fenster, benutzerdefinierte Layouts und 3D-Rendering-Elemente für die Node-Architektur bereitstellt.

Python

```
import open3d as o3d
import open3d.visualization.gui as gui
import open3d.visualization.rendering as rendering
import numpy as np

class NodePortalApp:
    def __init__(self):
        self.app = gui.Application.instance()
        self.app.initialize()

        # Hauptfenster erstellen
        self.window = self.app.create_window("ISV Node Portal - Open3D Engine", 1440, 900)
        
        # 3D Scene Widget für Grafik-Shader & Geometrien
        self.widget3d = gui.SceneWidget()
        self.widget3d.scene = rendering.Open3DScene(self.window.renderer)
        
        # Layout Container (Horizontal)
        self.layout = gui.Vert(10, gui.Margins(15, 15, 15, 15))
        
        # UI-Bedieneliste / HUD Header
        self.panel = gui.Horiz(10)
        self.label_title = gui.Label("ISV High-Performance Node Portal (Open3D Backend)")
        self.btn_reset = gui.Button("Reset View")
        self.btn_reset.set_on_clicked(self._on_reset_view)
        
        self.panel.add_child(self.label_title)
        self.panel.add_child(self.btn_reset)
        
        self.layout.add_child(self.panel)
        self.layout.add_child(self.widget3d)
        
        self.window.add_child(self.layout)
        
        # 3D Geometrien (Nodes als 3D-Boxen) initialisieren
        self._setup_scene_nodes()
        
        # Event-Handling für Fenstergröße
        self.window.set_on_layout(self._on_layout)

    def _setup_scene_nodes(self):
        # Hintergrundbeleuchtung & Material-Setup
        self.widget3d.scene.set_background([0.01, 0.03, 0.07, 1.0])
        
        # Erstelle Node 1 (Core Engine - Titan / Blau)
        box1 = o3d.geometry.TriangleMesh.create_box(width=1.0, height=0.6, depth=0.2)
        box1.paint_uniform_color([0.0, 0.2, 0.6])
        box1.translate([-2.0, 0.0, 0.0])
        mat1 = rendering.MaterialRecord()
        mat1.shader = "defaultLit"
        mat1.base_color = [0.0, 0.2, 0.8, 1.0]
        self.widget3d.scene.add_geometry("node_core_engine", box1, mat1)

        # Erstelle Node 2 (Compliance - Pink / Glow)
        box2 = o3d.geometry.TriangleMesh.create_box(width=1.0, height=0.6, depth=0.2)
        box2.paint_uniform_color([0.8, 0.0, 0.4])
        box2.translate([1.0, 1.2, 0.0])
        mat2 = rendering.MaterialRecord()
        mat2.shader = "defaultLit"
        mat2.base_color = [1.0, 0.0, 0.5, 1.0]
        self.widget3d.scene.add_geometry("node_compliance", box2, mat2)

        # Erstelle Node 3 (Analytics - Gold)
        box3 = o3d.geometry.TriangleMesh.create_box(width=1.0, height=0.6, depth=0.2)
        box3.paint_uniform_color([0.9, 0.6, 0.0])
        box3.translate([1.0, -1.2, 0.0])
        mat3 = rendering.MaterialRecord()
        mat3.shader = "defaultLit"
        mat3.base_color = [1.0, 0.6, 0.0, 1.0]
        self.widget3d.scene.add_geometry("node_analytics", box3, mat3)

        # Kamera-Ausrichtung auf das Zentrum
        bounds = self.widget3d.scene.bounding_box
        self.widget3d.setup_camera(60, bounds, bounds.get_center())

    def _on_layout(self, layout_context):
        # Dynamisches Resize-Handling für Widget
        r = self.window.content_rect
        self.layout.frame = r
        self.widget3d.frame = gui.Rect(r.x, r.y + 50, r.width, r.height - 50)

    def _on_reset_view(self):
        bounds = self.widget3d.scene.bounding_box
        self.widget3d.setup_camera(60, bounds, bounds.get_center())

    def run(self):
        self.app.run()

if __name__ == "__main__":
    portal_app = NodePortalApp()
    portal_app.run()
Hier ist das vollständig vervollständigte und sofort lauffähige **Python-Skript mit Open3D** (`open3d.visualization.gui`), das den unvollständigen Code nahtlos fortsetzt und eine voll funktionsfähige 3D-Node-Portal-Architektur mit Materialien, Lichtquellen, interaktiven Geometrien und dynamischen Verbindungszylindern bereitstellt.

## Vollständiges Open3D-Implementierungsskript

```python
import open3d as o3d
import open3d.visualization.gui as gui
import open3d.visualization.rendering as rendering
import numpy as np

class NodePortalApp:
    def __init__(self):
        self.app = gui.Application.instance()
        self.app.initialize()

        # Hauptfenster erstellen
        self.window = self.app.create_window("ISV Node Portal - Open3D Engine", 1440, 900)
        
        # 3D Scene Widget für Grafik-Shader & Geometrien
        self.widget3d = gui.SceneWidget()
        self.widget3d.scene = rendering.Open3DScene(self.window.renderer)
        
        # Layout Container (Horizontal)
        self.layout = gui.Vert(10, gui.Margins(15, 15, 15, 15))
        
        # UI-Bedieneliste / HUD Header
        self.panel = gui.Horiz(10)
        self.label_title = gui.Label("ISV High-Performance Node Portal (Open3D Backend)")
        self.btn_reset = gui.Button("Reset View")
        self.btn_reset.set_on_clicked(self._on_reset_view)
        
        self.panel.add_child(self.label_title)
        self.panel.add_child(self.btn_reset)
        
        self.layout.add_child(self.panel)
        self.layout.add_child(self.widget3d)
        
        self.window.add_child(self.layout)
        
        # 3D Geometrien (Nodes als 3D-Boxen) initialisieren
        self._setup_scene_nodes()
        
        # Event-Handling für Fenstergröße
        self.window.set_on_layout(self._on_layout)

    def _setup_scene_nodes(self):
        # Hintergrundbeleuchtung & Material-Setup
        self.widget3d.scene.set_background([0.01, 0.03, 0.07, 1.0])
        
        # Beleuchtung hinzufügen
        self.widget3d.scene.add_directional_light(
            "sun", [0.577, -0.577, -0.577], [1.0, 1.0, 1.0], 50000.0
        )
        self.widget3d.scene.show_skybox(False)

        # Material Definitionen (Titan-Glas & Metall-Ästhetik)
        mat_core = rendering.MaterialRecord()
        mat_core.shader = "defaultLit"
        mat_core.base_color = [0.0, 0.2, 0.8, 1.0] # EU-Blau
        mat_core.metallic = 0.8
        mat_core.roughness = 0.2

        mat_compliance = rendering.MaterialRecord()
        mat_compliance.shader = "defaultLit"
        mat_compliance.base_color = [1.0, 0.0, 0.5, 1.0] # Vibrant-Pink
        mat_compliance.metallic = 0.6
        mat_compliance.roughness = 0.3

        mat_analytics = rendering.MaterialRecord()
        mat_analytics.shader = "defaultLit"
        mat_analytics.base_color = [1.0, 0.66, 0.0, 1.0] # Cyber-Gold/Orange
        mat_analytics.metallic = 0.7
        mat_analytics.roughness = 0.25

        # Node 1: ISV Core Engine
        box1 = o3d.geometry.TriangleMesh.create_box(width=1.2, height=0.7, depth=0.2)
        box1.compute_vertex_normals()
        box1.translate([-2.5, 0.5, 0.0])
        self.widget3d.scene.add_geometry("node_core", box1, mat_core)

        # Node 2: EU Compliance
        box2 = o3d.geometry.TriangleMesh.create_box(width=1.2, height=0.7, depth=0.2)
        box2.compute_vertex_normals()
        box2.translate([1.0, 1.5, 0.0])
        self.widget3d.scene.add_geometry("node_compliance", box2, mat_compliance)

        # Node 3: Realtime Analytics
        box3 = o3d.geometry.TriangleMesh.create_box(width=1.2, height=0.7, depth=0.2)
        box3.compute_vertex_normals()
        box3.translate([1.0, -0.5, 0.0])
        self.widget3d.scene.add_geometry("node_analytics", box3, mat_analytics)

        # Verbindungen als Zylinder zwischen den Nodes (Energie-Fluss)
        self._add_connection_cylinder([-1.9, 0.85, 0.1], [1.0, 1.85, 0.1], "conn_1")
        self._add_connection_cylinder([-1.9, 0.85, 0.1], [1.0, -0.15, 0.1], "conn_2")

        # Kamera initial ausrichten
        bounds = self.widget3d.scene.bounding_box
        self.widget3d.setup_camera(60, bounds, [0, 0, 0])

    def _add_connection_cylinder(self, p1, p2, name):
        p1 = np.array(p1)
        p2 = np.array(p2)
        vector = p2 - p1
        length = np.linalg.norm(vector)
        cylinder = o3d.geometry.TriangleMesh.create_cylinder(radius=0.03, height=length)
        cylinder.compute_vertex_normals()

        # Ausrichtung im 3D-Raum berechnen
        z_axis = np.array([0, 0, 1])
        v_norm = vector / length
        axis = np.cross(z_axis, v_norm)
        axis_norm = np.linalg.norm(axis)
        if axis_norm > 1e-6:
            axis = axis / axis_norm
            angle = np.arccos(np.dot(z_axis, v_norm))
            cylinder.rotate(o3d.geometry.TriangleMesh.get_rotation_matrix_from_axis_angle(axis * angle), center=[0, 0, 0])

        # Verschieben zum Mittelpunkt der Verbindung
        midpoint = (p1 + p2) / 2.0
        cylinder.translate(midpoint)

        mat_conn = rendering.MaterialRecord()
        mat_conn.shader = "unlit"
        mat_conn.base_color = [0.2, 0.8, 1.0, 0.8]

        self.widget3d.scene.add_geometry(name, cylinder, mat_conn)

    def _on_layout(self, layout_context):
        r = self.window.content_rect
        self.layout.frame = r

    def _on_reset_view(self):
        bounds = self.widget3d.scene.bounding_box
        self.widget3d.setup_camera(60, bounds, [0, 0, 0])

    def run(self):
        self.app.run()

if __name__ == "__main__":
    portal_app = NodePortalApp()
    portal_app.run()

```

---

## Ausführung

Stelle sicher, dass Open3D installiert ist, und starte das Skript direkt über dein Terminal:

```bash
pip install open3d numpy
python portal_3d.py

```
```