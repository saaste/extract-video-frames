# Video Frame Extractor with Timestamp Sync
Extract frames from a video and sync the image timestamps. This PowerShell script is based on a shell script by muffu @ OFTC/#osm-fi.

Frame extractor is useful for [OpenStreetMap](https://www.openstreetmap.org) contributors. Images with
timestamps can be shown with GPS track in [JOSM](https://josm.openstreetmap.de/) editor. This makes identifying real-world objects really easy and you don't have to rely on your memory.

Instead of taking a ton of photos manually, you can just record your whole journey as a video and then extract the images later. It is possible to adjust the offset in JOSM editor, but it is recommended to start GPS tracking and video recording at the same time.

# Prerequisites
- [ExifTool](https://exiftool.org/)
- [Exiv2](https://exiv2.org/)
- [FFmpeg](https://ffmpeg.org/)

The script expects that these tools are found in the following directories:
```
- extract_video_frames.ps1
- exiftool
  - exiftool.exe
- exiv2
  - bin
    - exiv2.exe
- ffmpeg
  - bin
    - ffmpeg.exe
```

# How to use
```
./extract_video_frames.ps1 -VideoFile [FILENAME] -FrameRate [FRAMERATE]
```

This will create a new directory `[FILENAME]-[FRAMERATE]fps` and extracts images these.

`VideoFile` parameter can be a single file or a wildcard search e.g GOPR55*.MP4. All matching files will be processed.

`FrameRate` parameter defines how many images are extracted each second. Default is `2`.

Image timestamps are calculated based on video's creation time and given framerate.
