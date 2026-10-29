# Imagen de `ds render` (env/render/render.sh): Chromium headless + ffmpeg para scripts/render.py de onetake,
# Kokoro para la voz local y lo que piden score.py / sfx_palette. Los scripts de onetake no van acá: se montan.
# Cambiar este archivo cambia el tag (hash del contenido), así el próximo `ds render` la reconstruye solo.
FROM python:3.12-slim
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg && rm -rf /var/lib/apt/lists/* \
 && pip install --no-cache-dir playwright numpy pillow scipy soundfile kokoro-onnx fonttools brotli requests && playwright install --with-deps chromium
