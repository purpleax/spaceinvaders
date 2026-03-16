# Bot Blaster — Conference Booth Game

Space Invaders-style bot-shooting game for tech conference booths.

---

## How config editing works

`config.json` lives on your **host machine** and is mounted directly into the container.
You never need to enter the container or rebuild the image to change any text or gameplay setting.

**Workflow:**
1. Edit `config.json` on your laptop/server with any text editor
2. Save the file
3. Refresh the browser — changes appear immediately

That's it. No `docker exec`, no rebuild, no restart.

---

## Quick Start

```bash
# 1. Build the image and start (first time only, or after editing index.html)
docker compose up -d --build

# 2. Open the game
open http://localhost       # macOS
xdg-open http://localhost  # Linux
# or just navigate to http://localhost in any browser
```

To run on a different port (if 80 is taken):
```bash
# Edit docker-compose.yml — change "80:80" to e.g. "8080:80", then:
docker compose up -d --build
open http://localhost:8080
```

---

## Editing config.json

The file is at `./config.json` next to `docker-compose.yml` on your host.
Edit it with any editor and refresh the browser — no container interaction needed.

```json
{
  "company": {
    "name": "YourCompany",
    "tagline": "Your tagline here.",
    "booth": "Booth #10"
  },
  "event": {
    "name": "EventName 2026",
    "dates": "April 1–3, 2026",
    "location": "Melbourne Convention Centre"
  },
  "attract": {
    "headline": "CAN YOU STOP THE BOTS?",
    "subheadline": "Blast the bots before they reach your servers!",
    "callToAction": "PRESS START TO PLAY",
    "leaderboardTitle": "TODAY'S TOP BOT BLASTERS",
    "prizeMessage": "🏆 Daily High Score Wins a Prize — See Booth Staff",
    "scrollingMessages": [
      "Your message 1",
      "Your message 2",
      "Your message 3"
    ]
  },
  "gameplay": {
    "lives": 1,
    "speedMultiplier": 1.5,
    "shootCooldownMs": 800
  }
}
```

### gameplay settings

| Setting | Default | Description |
|---|---|---|
| `lives` | `1` | Lives per game. `1` = one hit and you're out |
| `speedMultiplier` | `1.5` | Enemy speed. `1.0` = ~8 min game, `1.5` = ~3 min, `2.0` = ~2 min |
| `shootCooldownMs` | `800` | Ms between player shots. `800` = original Space Invaders pace |

---

## How the volume mount works (technical detail)

In `docker-compose.yml`:

```yaml
volumes:
  - ./config.json:/usr/share/nginx/html/config.json:ro
```

This binds `config.json` from your host directory into the container at nginx's web root.
The `:ro` flag makes it read-only inside the container (the container can't modify it).
nginx serves it with `no-cache` headers, so the browser always fetches the latest version on page load.

---

## Daily Leaderboard Reset

Scores are stored in the browser session (in-memory JavaScript) — they reset automatically
when the browser is refreshed or the page reloads. To deliberately reset between event days:

```bash
# Quickest reset: just refresh the browser displaying the game
# OR restart the container (also clears any cached state):
docker compose restart
```

Automated morning reset via cron:
```bash
# Add to crontab (crontab -e) — resets at 8am daily
0 8 * * * docker compose -f /path/to/bot-blaster/docker-compose.yml restart
```

---

## Stopping / updating

```bash
# Stop the container
docker compose down

# Rebuild after editing index.html (config.json changes don't need this)
docker compose up -d --build
```

---

## Controls

| Action | Keyboard | Controller |
|---|---|---|
| Move | ← → | Left stick / D-Pad |
| Fire | Space | A or B |
| Pause | Esc / P | Start |
| Quit to menu | Esc again (while paused) | Start again (while paused) or Select |

---

## Files

| File | Purpose |
|---|---|
| `index.html` | The entire game — self-contained, no external dependencies at runtime |
| `config.json` | All booth text and gameplay settings — edit freely on the host |
| `Dockerfile` | Builds the nginx:alpine image (~10MB) |
| `nginx.conf` | nginx config — no-cache for config.json, gzip, health endpoint |
| `docker-compose.yml` | One-command orchestration with live config volume mount |
