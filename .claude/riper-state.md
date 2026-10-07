# RIPER state

- Task: Home Assistant review + fixes (2026-10-07)
- Phase: EXECUTE Batch 4a done (views generated, proven equal; Robynne → Girls' Room incl. group.girls_room_lights + light.girls_room renamed live via Spook) — awaiting deploy. 4b next.
- Previously: PLAN (Batch 4) approved.
- Abandoned-deps review (approved): (1) removed carbon_intensity + nationalrailuk — awaiting deploy + UI entry delete; (2) Dyson → cmgrayb/hass-dyson (package libdyson-rest) once device confirmed online; (3) stack-in-card → native vertical-stack + card-mod in 4b. stack-in-card first-load patch awaiting deploy verification. Batches 1–3 + icloud3 fix deployed + verified (startup errors 55 → 3).
- Batch 4 decisions: approach A (Nix-generated room views from rooms.nix); accent → theme var(--accent-color)

## Batch 4 plan

4a (behaviour-preserving refactor, proven by semantic diff)

1. dashboard/rooms.nix: 6 rooms (name, slug, icon, image, group, per-tab extras/filter overrides)
2. dashboard/room-view.nix: function → view attrset (hero, chips, 4 tabs)
3. default.nix: build views dir (generated room-_.yaml + home.yaml) ; delete views/room-_.yaml
4. Verify: PyYAML-load old views vs generated JSON → identical (normalised)
   4b (visual/robustness)
5. dashboard.yaml: shared `pill_card` base template; theme vars for bg/text/disabled; accent → var(--accent-color); drop :host-context dark overrides
6. esc() for calendar/media/team text; iOS-safe date parse; info_card eval() → button-card [[[ ]]] variables (home.yaml callers)

- Follow-ups offered: icloud3 www/themes permissions, RoboVac IP, BILRESA replay guard + mode
- Branch: wip (user choice)
- Vault spec: write failed (Obsidian REST 127.0.0.1:27123 connection refused); plan held here
- Decisions: AIM memory, context `config`, entity `HomeAssistant_Review_2026-10`

## Answers (2026-10-07)

- notify.family = hatchling only
- Backups: exclude /var/lib/hass/backups from restic; keep HA backups
- Discovery: add oralb + thermopro only; zha stays as-is
- http: proxy fix only (use_x_forwarded_for + trusted_proxies), no ip_ban

## Batch 1 — correctness

1. Remove `enter_home`; drop camera privacy step from `leave_home`.
2. Replace `mkMotionLightAutomation` with restore=true timer pattern with ownership (`timer.hallway_lights` 60s, `timer.living_room_lights` 300s).
3. Merge hallway day/night/door into `hallway_lights`; door = motion; 85% 07:30–20:00 else 10%.
4. `auto_turn_off_tv` only when LG source is HDMI1.
5. Delete `dishwasher_complete`; washing machine trigger `above 50 for 5 min`.
6. Low battery: crossing trigger + daily sweep incl. unavailable; iOS time-sensitive push.
7. Remove adaptive_lighting component + config.
8. Motion popup `attributes: device_class`; `unique: true` on overlapping room filters.
9. `http` trusted proxies + ip_ban.

## Batch 2 — hygiene

10. Drop 8 unused Lovelace modules (keep ha-floorplan); delete tabbed-card + circular-gauge overlays.
11. Remove `itunes`; add `zha`, `oralb`, `thermopro`.
12. Modern automation syntax throughout.
13. `notify.family` group for all notifications.
14. Remove `allowlist_external_dirs`.
15. Exclude `/var/lib/hass/backups` from restic.

## Batch 3 — cleanup

16. Delete `away_notifications`, `ipad_low_battery`.
17. UI checklist: orphan automations/entities, Jellyfin new-entity disable + session players, HomeKit exclude media_player.

## Batch 4 — dashboard (refactor/ branch, re-plan on entry)
