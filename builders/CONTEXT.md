# CONTEXT

## Vivaldi's `libffmpeg.so.<major>.<minor>` must stay nixpkgs' codecs lib

With `proprietaryCodecs = true`, nixpkgs symlinks `libffmpeg.so.<ver>` to
`chromium-codecs-ffmpeg-extra`, and Vivaldi's launcher `LD_PRELOAD`s that name.
The `libffmpeg.so` shipped in the deb is the free build: `avcodec_find_decoder_by_name`
finds no `h264`, `aac` or `hevc` in it, so any MP4/H.264 video fails to play.

A former `postFixup` re-pointed the symlink at the bundled lib, because an older
`chromium-codecs-ffmpeg-extra` lacked `av_dynamic_hdr_smpte2094_app5_to_t35` and
Vivaldi would not start. That silently disabled proprietary codecs. If a bump
breaks startup again, fix the codecs lib (a newer `vivaldi-ffmpeg-codecs`, or
the version the launcher's `update-ffmpeg` names), not the symlink. To check a
candidate, every `libffmpeg.so` symbol `vivaldi-bin` imports must be defined in it:
`comm -23 <(nm -D --undefined-only vivaldi-bin | awk '{print $2}' | sort) <(nm -D --defined-only <lib> | awk '{print $3}' | sort)`,
filtered to `av*`/`sws*` names.
