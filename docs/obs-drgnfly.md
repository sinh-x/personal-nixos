# OBS Studio on Drgnfly

Drgnfly enables OBS Studio through Home Manager in `home/sinh/Drgnfly.nix`.
This installs OBS without automatic startup, camera access, recording, streaming,
or a remotely accessible OBS WebSocket server. OBS settings remain user-managed;
the configuration does not overwrite existing profiles or scenes.

## Apply the configuration

Sinh must run activation manually from this repository:

```console
sudo sys test
```

After testing, use `sudo sys rebuild` to apply it persistently. Launch **OBS Studio**
from the application launcher or run `obs` in a new terminal.

## Set up the EMEET PIXY

1. Connect the PIXY by USB. Close other applications that may be using it.
2. In OBS's first-run wizard, choose **Optimize just for recording, I will not be streaming**.
3. Create a scene, then select **Sources → + → Video Capture Device (V4L2)**.
4. Select the device identified as EMEET/PIXY, not the integrated laptop camera.
   Do not assume `/dev/video0` is the PIXY. If it is absent, check the USB connection
   before proceeding; Linux capture compatibility must be verified on this device.
5. Start with the device's default settings. Choose a supported resolution and
   frame rate from the dropdowns; do not assume every advertised camera mode is
   exposed on Linux. Right-click the source and choose **Transform → Fit to screen**.
6. Under **Settings → Output → Recording**, choose your recording directory and
   **Matroska (.mkv)** format. Recordings can be remuxed to MP4 using
   **File → Remux Recordings** after recording finishes.
7. Disable unwanted microphones and desktop audio in **Settings → Audio** if only
   silent camera video is desired. Preview and record only when intended. Use
   **Start Recording** and **Stop Recording**; no scheduled recording is configured.

OBS can control only settings exposed by the Linux driver. EMEET-specific AI,
gesture, audio, PTZ, and firmware controls may still require EMEET Studio on a
supported operating system.

## Persistence and scheduled snapshots

Drgnfly persists the entire `/home/sinh`, including OBS settings in
`~/.config/obs-studio` and recordings saved beneath the home directory. A recording
location outside the home directory needs its own persistence check.

OBS preview/manual video recording is separate from scheduled still-image
capture into `<destination>/YYYY-MM-DD/`. That requirement remains tracked in
**NX-062**; destination, interval, and automatic-start behavior still need Sinh's
approval. No camera test or recording is performed merely by installing OBS.
