# Tdarr H.265 VAAPI Flow Setup

Target: Transcode all media to H.265 using VAAPI hardware acceleration, with HDR→SDR tone mapping and English audio only.

## URLs

- Tdarr UI: https://tdarr.gilberts.one
- Media paths (inside container): `/media/movies`, `/media/tv`
- Transcode cache (inside container): `/temp`

---

## Flow Logic Overview

Single path — no branching. Every file is re-encoded to H.265 SDR via VAAPI, HDR content is tone-mapped to SDR, and non-English audio is removed.

```
[Input File]
     |
[Begin Command]
     |
[Set Container: mkv]
     |
[Custom Arguments: VAAPI + tone map + hevc_vaapi]
     |
[Remove Non-English Audio]
     |
[Execute]
     |
[Replace Original File]
```

---

## Part 1: Create the Flow

1. Left sidebar → **Flows** → **+ New Flow**
2. Name it: `H265 VAAPI SDR`
3. Drag plugins from the left panel onto the canvas
4. Connect nodes by dragging from the output dot (bottom) to the input dot (top) of the next node

---

## Part 2: Nodes

### Node 1 — Input File

**Category: Input** → `Input File`

- No configuration
- Entry point of the flow

---

### Node 2 — Begin Command

**Category: FfmpegCommand** → `Begin Command`

- No configuration

---

### Node 3 — Set Container

**Category: FfmpegCommand** → `Set Container`

- Container: `mkv`

---

### Node 4 — Custom Arguments (VAAPI encode + tone map)

**Category: FfmpegCommand** → `Custom Arguments`

Arguments:

```
-vaapi_device /dev/dri/renderD128 -vf "format=nv12|p010|vaapi,hwupload,tonemap_vaapi=format=nv12:primaries=bt709:transfer=bt709:matrix=bt709" -c:v hevc_vaapi -qp 24
```

**What this does:**

- `format=nv12|p010|vaapi` — accepts both 8-bit SDR (nv12) and 10-bit HDR (p010) input
- `hwupload` — uploads frames to the GPU
- `tonemap_vaapi=...` — tone-maps HDR to SDR BT.709; no-op on content that is already SDR
- `-c:v hevc_vaapi` — encodes output as H.265 using VAAPI
- `-qp 24` — quality level (lower = better quality / larger file; 18–28 is the practical range)

Do **not** use the `Set Video Encoder` plugin — it conflicts with the custom filter chain above.

---

### Node 5 — Remove Non-English Audio

**Category: FfmpegCommand** → `Remove Stream By Property`

- Stream type: `audio`
- Property: `tags:language`
- Condition: `not equal`
- Value: `eng`
- **Keep if only stream**: `true` (or equivalent "keep if last stream" toggle)

This setting prevents the node from removing a non-English track when it is the _only_ audio track — preserving audio for foreign-language films rather than producing a silent file.

---

### Node 6 — Execute

**Category: FfmpegCommand** → `Execute`

- No configuration

---

### Node 7 — Replace Original File

**Category: File** → `Replace Original File`

- No configuration

---

## Connection Summary

```
Node 1 (Input File)
  |
Node 2 (Begin Command)
  |
Node 3 (Set Container: mkv)
  |
Node 4 (Custom Arguments: VAAPI + tone map + hevc_vaapi qp=24)
  |
Node 5 (Remove Non-English Audio)
  |
Node 6 (Execute)
  |
Node 7 (Replace Original File)
```

---

## Part 3: Save, Add Libraries, and Start

### Save

Click **Save** (top right of canvas).

### Add Libraries

1. Go to **Libraries** tab → **+ Add Library**

| Library | Source path     | Cache path |
| ------- | --------------- | ---------- |
| Movies  | `/media/movies` | `/temp`    |
| TV      | `/media/tv`     | `/temp`    |

2. Under **Transcode options** → set **Flow** to `H265 VAAPI SDR`
3. Enable **Find new files on start**

### Verify GPU Worker

1. Go to **Nodes** tab
2. Confirm `rubecula` shows connected
3. **GPU transcode workers** should be `1` — if 0, click the node and set it manually

### Initial Test

1. Click the scan button on each library
2. Test on 1–2 files (ideally one SDR and one HDR) before processing the full library
3. Check output quality in Jellyfin — verify HDR content looks correct (not washed out)
4. If tone mapping fails, check the Tdarr logs — `tonemap_vaapi` requires Mesa with VAAPI tone mapping support

---

## Notes

- `qp 24` is a starting point — lower values (e.g. 20) give better quality at larger file size
- Tdarr tracks processed files internally; re-scans won't re-process already-done files
- After a batch completes, run: Jellyfin → Dashboard → Libraries → Scan All Libraries
- `tonemap_vaapi` is hardware-accelerated on AMD RDNA2+ (780M is RDNA3 — should work)
- If `tonemap_vaapi` errors on SDR content, add `tonemap_vaapi=format=nv12` with no colour space args as a fallback
