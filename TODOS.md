Node Versions pinnen
cli versions pinnen
python version pinnen

Soll/Ist-Matrix: Docker vs. Codex vs. Vibe

A) Dateisystem & Schreibrechte

Soll (Best practice)
• Agent kann nur im Projekt schreiben.
• Agent kann keine Host-Secrets lesen (SSH, GPG, Password stores, Cloud creds).
• Baseline-Konfig ist nicht durch Repo überschreibbar.

Ist bei dir
• ✅ Nur Projekt gemountet: --mount source="$PWD",target=/workspace (gut)
• ✅ Non-root User: USER agent (gut)
• ✅ Keine Home-Mounts vom Host (gut)
• ⚠️ Repo kann die Agent-Policy überschreiben:
• Du kopierst .codex/.vibe nach /workspace/... nur wenn nicht vorhanden.
• Ein Projekt mit eigener .codex/.vibe kann deine Defaults ersetzen.
• Das ist die größte reale Lücke, weil sie die Agent-Guardrails aushebelt.

Konsequenz
• Dein „für alle Projekte gleich“ gilt nur, wenn Projekte keine eigene .codex/.vibe mitbringen.

⸻

B) Command-Ausführung (Bash / Shell)

Soll
• Commands werden nur nach expliziter Zustimmung ausgeführt (Ask/Approve).
• Optional: Commands generell verbieten oder nur “safe commands” erlauben.

Ist
• ✅ Codex: mit approval_policy="on-request" fragst du vor riskanten Actions/Commands.
• ✅ Vibe: du willst bash auf ask und Schreiben auf ask (gut).
• ⚠️ In Vibe gilt: Wenn du bash bestätigst, kann ein Command alles tun, was im Container möglich ist (inkl. Netz, Paketinstall, etc.). Das ist normal – deshalb ist die nächste Kategorie wichtig (Netz).

⸻

C) Netzwerk / Exfiltration

Soll
• Agent kann nur mit dem Modellanbieter sprechen (API).
• Sonst: kein Egress, oder nur allowlisted Egress.
• Keine “Drive-by” Downloads/Installers.

Ist
• ✅ Codex: network_access=false blockt Netzwerk in der Sandbox (sehr gut).
• ⚠️ Docker: du nutzt --network bridge → Container hat grundsätzlich Internet.
• ⚠️ Vibe: hat kein äquivalentes network_access=false in der Config.
Heißt: über bash (wenn du bestätigst) sind curl/git/pip/npm möglich.

Konsequenz
• Dein Setup ist gegen Exfiltration nur so stark wie deine Bash-Entscheidungen (bei Vibe), und gegen „Agent lädt random stuff“ ebenfalls.
• Best practice für “gleich sicher”: Netzwerk auf Container-Ebene einschränken oder Vibe ohne Bash.

⸻

D) Konfigurationshoheit (das “Policy Enforcement” Thema)

Soll
• Sicherheitsbaseline ist global erzwungen (nicht repo-abhängig).
• Projekt kann nur enger, nicht lockerer werden.

Ist
• ✅ Deine Defaults liegen im Repo-Pfad (container /home/.codex /home/.vibe).
• ⚠️ Repo kann über eigene .codex/.vibe lockern.
• ✅ Du mountest sogar Volumes auf /home/agent/.codex und /home/agent/.vibe – aber die werden aktuell von deinem Entrypoint nicht als zentrale Quelle genutzt.

Konsequenz
• Du hast bereits den richtigen Mechanismus (Home-Volumes), nutzt ihn aber noch nicht für die Baseline.

⸻

E) Supply Chain / Updates / Installationspfad

Soll
• Keine “curl | bash” Installer im Build (oder zumindest verifiziert/pinned).
• Versionen pinnen (Node, codex, vibe).
• Updates kontrolliert.

Ist
• ⚠️ curl ... nodesource | bash - ist klassisch supply-chain risk (wenn auch üblich).
• ⚠️ npm install -g @openai/codex ohne Version pin = nicht reproduzierbar.
• ⚠️ pipx install mistral-vibe ohne Version pin = dito.
• ✅ Du entfernst npm/npx danach (reduziert Angriffsfläche, gut).

Konsequenz
• Nicht der größte Security-Hebel im Daily-Run, aber für “best practice” in Firmenumfeld: version pinning ist normalerweise Pflicht.

⸻

Die 3 wichtigsten “Ist”-Lücken (priorisiert) 1. Repo kann deine Guardrails überschreiben
(weil du .codex/.vibe in /workspace ablegst und nicht erzwingst) 2. Vibe hat keine echte Netzwerk-Sperre via Config
(mit bash ask ist es “approval gated”, aber nicht technisch verhindert) 3. Ungepinnte Installationen / curl|bash (Supply chain & Repro)

⸻

Wie du “beide gleich” bekommst (ohne Anleitung, nur Entscheidungspunkte)

Du musst nur zwei Entscheidungen treffen:

Entscheidung 1: Wer hat das letzte Wort – Baseline oder Repo?

Best practice: Baseline hat das letzte Wort.

Das erreichst du konzeptionell so:
• Codex/Vibe Baseline liegt im Home (/home/agent/.codex, /home/agent/.vibe) und wird durch Volumes persistiert.
• Repo-Konfig (/workspace/.codex, /workspace/.vibe) wird entweder ignoriert oder nur als “project hints” akzeptiert, wenn du dem Repo vertraust.

Entscheidung 2: Brauchst du Vibe-Bash wirklich?
• Wenn nein: entferne bash komplett → Vibe kann dann nicht exfiltrieren/Downloads machen, und du bist sehr nah an Codex network_access=false.
• Wenn ja: dann brauchst du Netzwerk-Policy außerhalb von Vibe (Container-Egress, allowlist) oder du akzeptierst: „Netz nur, wenn ich Bash ausdrücklich bestätige“.

⸻

Wenn du sagst, welche Variante du willst:
• Variante A: Vibe ohne Bash (maximale Gleichheit zu Codex)
• Variante B: Vibe mit Bash, aber du akzeptierst “Netz nur wenn ich’s approve”
• Variante C: Vibe mit Bash + technische Egress-Sperre

…dann kann ich dir im nächsten Schritt eine “Policy-Formulierung” geben, die exakt dazu passt (wieder ohne Setup-Anleitung), inkl. klarer Regeln, wann du approve’n darfst und wann nicht.
