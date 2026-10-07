# RIPER state

- Task: Home Assistant review + fixes (2026-10-07)
- Phase: EXECUTE — Batch 1 deployed + verified (0 errors). Batch 2 edits done, evals OK, code-review running
- Batch 3 additions: delete orphan automation.hallway_lights then rename hallway_lights_2
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
