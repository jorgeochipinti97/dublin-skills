# Control de calidad de un video antes de mostrarlo: lo que se escucha, lo que se ve quieto y cómo suena.
#   uv run --with faster-whisper python env/video/qa.py <video.mp4> [--guion vo/toma] [--quieto 0.5] [--silencio 1.2]
# --guion: carpeta con <bloque>.json {"texto": …} (vo/tts.py) o un .txt con todo lo que se tiene que decir.
# Sale con código 1 si algo falla: palabras que no se dicen, cuadros congelados, huecos sin sonido, volumen fuera de rango.
import argparse, difflib, glob, json, os, re, subprocess, sys, unicodedata
a = argparse.ArgumentParser(); a.add_argument("video"); a.add_argument("--guion"); a.add_argument("--quieto", type=float, default=0.5)
a.add_argument("--silencio", type=float, default=1.2); a.add_argument("--modelo", default="medium"); A = a.parse_args()
mal = []
def ff(filtro, sel):
    r = subprocess.run(["ffmpeg", "-hide_banner", "-nostats", "-i", A.video, sel, filtro, "-f", "null", "-"], capture_output=True, text=True); return r.stderr
norm = lambda s: re.sub(r"[^a-zñ0-9 ]", " ", unicodedata.normalize("NFD", s.lower()).encode("ascii", "ignore").decode().replace("n~", "ñ")).split()

# 1. lo que se escucha contra el guion
if A.guion:
    if os.path.isdir(A.guion): esperado = " ".join(json.load(open(f))["texto"] for f in sorted(glob.glob(os.path.join(A.guion, "*.json"))))
    else: esperado = open(A.guion).read()
    from faster_whisper import WhisperModel
    import numpy as np   # el audio lo decodifica ffmpeg (el av de faster-whisper falla con algunas versiones)
    pcm = subprocess.run(["ffmpeg", "-v", "error", "-i", A.video, "-ac", "1", "-ar", "16000", "-f", "f32le", "-"], capture_output=True).stdout
    segs, _ = WhisperModel(A.modelo, compute_type="int8").transcribe(np.frombuffer(pcm, np.float32), language="es", vad_filter=False)
    oido = " ".join(s.text for s in segs)
    e, o = norm(esperado), norm(oido)
    # los números se transcriben en cifras («842», «rumen360.com»): un número dicho cuenta si el audio tiene cifras
    NUM = set("cero uno una dos tres cuatro cinco seis siete ocho nueve diez once doce veinte treinta cuarenta cincuenta sesenta setenta ochenta noventa cien ciento doscientos trescientos cuatrocientos quinientos seiscientos setecientos ochocientos novecientos mil y punto".split())
    hay_cifras = bool(re.search(r"\d", oido))
    # la transcripción escribe marcas y voseo a su manera («Rummen», «sabe»): cuenta una palabra casi igual
    oye = lambda w: w in o or (len(w) >= 4 and any(difflib.SequenceMatcher(None, w, x).ratio() >= 0.8 for x in o))
    faltan = [w for w in e if not oye(w) and not (hay_cifras and w in NUM)]
    print("── se escucha:", oido.strip())
    if faltan: mal.append(f"palabras del guion que no se escuchan: {', '.join(faltan)}")
    else: print("✓ se dicen todas las palabras del guion")

# 2. cuadros congelados
q = re.findall(r"freeze_start: ([\d.]+).*?freeze_duration: ([\d.]+)", ff(f"freezedetect=n=0.003:d={A.quieto}", "-vf"), re.S)
for t0, d in q: mal.append(f"imagen quieta {float(d):.1f} s desde {float(t0):.1f} s")
if not q: print(f"✓ ninguna imagen quieta más de {A.quieto} s")

# 3. huecos sin sonido
s = re.findall(r"silence_start: ([\d.]+).*?silence_duration: ([\d.]+)", ff(f"silencedetect=n=-40dB:d={A.silencio}", "-af"), re.S)
for t0, d in s: mal.append(f"sin sonido {float(d):.1f} s desde {float(t0):.1f} s")
if not s: print(f"✓ ningún silencio de más de {A.silencio} s")

# 4. volumen (Reels/TikTok: cerca de −14 LUFS, pico por debajo de −1 dBTP)
r = ff("ebur128=peak=true", "-af"); I = re.findall(r"I:\s+(-?[\d.]+) LUFS", r); P = re.findall(r"Peak:\s+(-?[\d.]+) dBFS", r)
if I:
    i, p = float(I[-1]), float(P[-1]) if P else 0
    print(f"· volumen {i} LUFS, pico {p} dBFS")
    if not -16.5 <= i <= -12: mal.append(f"volumen {i} LUFS (esperado entre −16,5 y −12)")
    if p > -1: mal.append(f"pico {p} dBFS (se satura)")
else: mal.append("el video no tiene audio")

print("\n".join(["", "✗ " + "\n✗ ".join(mal)]) if mal else "\n✓ pasa el control")
sys.exit(1 if mal else 0)
