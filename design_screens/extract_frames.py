import cv2
import os

video_path = r"C:\projects\dinepoint\design_screens\Recording 2026-05-24 195545.mp4"
output_dir = r"c:\Users\shrav\dinepoint\design_screens"

cap = cv2.VideoCapture(video_path)
fps = cap.get(cv2.CAP_PROP_FPS)
total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
duration = total_frames / fps if fps > 0 else 0

print(f"Video: {fps:.1f} FPS, {total_frames} frames, {duration:.1f}s duration")

# Extract one frame every 2 seconds to capture distinct screens
interval = int(fps * 2) if fps > 0 else 60
frame_idx = 0
saved = 0

while True:
    ret, frame = cap.read()
    if not ret:
        break
    if frame_idx % interval == 0:
        saved += 1
        out_path = os.path.join(output_dir, f"screen_{saved:03d}.jpg")
        cv2.imwrite(out_path, frame)
        print(f"Saved frame {saved} at {frame_idx/fps:.1f}s -> {out_path}")
    frame_idx += 1

cap.release()
print(f"\nDone! Extracted {saved} frames from the video.")
