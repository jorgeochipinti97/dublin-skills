#!/usr/bin/env bash
# `ds render` — renderiza composiciones de onetake en un servidor, en cola y sin esperar: subís y te olvidás.
#   ds render <carpeta|comp.html> [--lindo|--final] [--destino a/b/c] [args de render.py]
#       sube la carpeta (sin _frames/ ni mp4) a la cola del server y vuelve al toque con un id.
#       Modos: rápido por defecto (sin motion blur, --shutter 0) · --lindo (blur con 4 capturas) · --final (4K60, blur completo)
#       --destino: carpeta dentro de la de Drive (default: el nombre de la carpeta del video), ej. rumen/lanzamiento/anuncio-1
#       ej: ds render videos/mi-video --width 1080 --height 1920 --sfx mix.wav
#   ds render estado          la cola, el % del que está corriendo y los últimos terminados
#   ds render log <id>        el log completo de un trabajo
#   ds render bajar <id>      baja un video que no pudo subir a Drive
#   ds render setup           imagen Docker + worker (systemd) + aviso ntfy en el server; se corre solo si falta
#   ds render drive <link>    conecta tu Google Drive (abre el navegador) a esa carpeta
#   ds render exec <carpeta> <comando…>   corre otra cosa en el server y baja la carpeta: la voz y el sonido (espera)
#     ej: ds render exec videos/mi-video python3 /ot/scripts/vo_tools.py tts vo/lines.txt --engine kokoro --voice em_alex --lang es --out vo/alex
#         ds render exec videos/mi-video python3 score.py          (score.py importa /ot/scripts/sfx_palette)
#   ds render hoja <carpeta> <t1,t2,…> [--width W --height H]   hoja de contactos en el server → baja stills.png
#   ds render verificar <carpeta> [--shots t0,t1,…] [args de render.py]   verify_promo en el server → baja verify.txt
#     el mp4 no está ni acá ni en el server (va a Drive), así que renderiza su borrador con blur (como --lindo) y lo tira
# En el server (worker.sh): de a uno, tope de CPU/RAM y prioridad baja frente a lo que ya corre ahí; al terminar sube
# a Drive, avisa por ntfy (celular/compu) con el link y borra todo del server.
#
# ~/.config/dublin/render (personal, fuera del repo), una línea:  usuario@host ~/.ssh/clave
# Opcionales por env (al hacer setup): RENDER_CPUS (3) · RENDER_MEM (4g) · RENDER_WORKERS (3)
set -euo pipefail

CONF="$HOME/.config/dublin/render"
HERE="$(cd "$(dirname "$0")" && pwd)"
ONETAKE="${ONETAKE_DIR:-$HOME/.claude/skills/onetake}"
REMOTE=/opt/render
IMAGE="dublin-render:$(shasum "$HERE/Dockerfile" | cut -c1-10)"
CPUS="${RENDER_CPUS:-3}" MEM="${RENDER_MEM:-4g}" WORKERS="${RENDER_WORKERS:-3}"

die() { echo "✗ $*" >&2; exit 1; }
[ -f "$CONF" ] || die "falta $CONF con una línea: usuario@host ~/.ssh/clave"
read -r HOST KEY _ < "$CONF"
KEY="${KEY/#\~/$HOME}"
SSH=(ssh -i "$KEY" -o BatchMode=yes -o ConnectTimeout=10 -o ServerAliveInterval=30 "$HOST")
RSYNC=(rsync -az -e "ssh -i $KEY -o BatchMode=yes -o ServerAliveInterval=30")

setup() {
  "${SSH[@]}" "mkdir -p $REMOTE/onetake $REMOTE/kokoro $REMOTE/jobs $REMOTE/cola $REMOTE/estado $REMOTE/hechos
    command -v rclone >/dev/null || { apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq rclone >/dev/null 2>&1; }"
  "${RSYNC[@]}" --delete "$ONETAKE/scripts/" "$HOST:$REMOTE/onetake/scripts/"
  # Kokoro (voz local): los modelos viven en el server, montados donde vo_tools los busca
  for f in kokoro-v1.0.onnx voices-v1.0.bin; do
    "${SSH[@]}" "test -s $REMOTE/kokoro/$f" || { [ -s "$HOME/.cache/kokoro/$f" ] && "${RSYNC[@]}" "$HOME/.cache/kokoro/$f" "$HOST:$REMOTE/kokoro/" ||
      "${SSH[@]}" "curl -fsSL -o $REMOTE/kokoro/$f https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/$f"; }
  done
  "${RSYNC[@]}" "$HERE/Dockerfile" "$HERE/worker.sh" "$HOST:$REMOTE/"
  "${SSH[@]}" "cd $REMOTE && chmod +x worker.sh
    docker image inspect $IMAGE >/dev/null 2>&1 || { docker build -q -t $IMAGE . >/dev/null && echo '✓ imagen $IMAGE'; }
    docker images dublin-render --format '{{.Repository}}:{{.Tag}}' | grep -vx $IMAGE | xargs -r docker rmi >/dev/null 2>&1 || true
    topic=\$(sed -n 's/^NTFY_TOPIC=//p' config 2>/dev/null); [ -n \"\$topic\" ] || topic=render-\$(head -c 12 /dev/urandom | od -An -tx1 | tr -d ' \n')
    umask 077; printf 'IMAGE=%s\nCPUS=%s\nMEM=%s\nWORKERS=%s\nNTFY_TOPIC=%s\n' $IMAGE $CPUS $MEM $WORKERS \$topic > config
    cat > /etc/systemd/system/dublin-render.service <<'EOF'
[Unit]
Description=ds render: cola de renders de onetake
After=docker.service
Requires=docker.service

[Service]
ExecStart=$REMOTE/worker.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload && systemctl enable -q dublin-render && systemctl restart dublin-render
    echo \"✓ worker andando · avisos: suscribite al tema \$topic en la app ntfy (o https://ntfy.sh/\$topic)\""
}

drive() {
  local fid="${1:-}"
  fid="$(printf '%s' "$fid" | sed -E 's#.*/folders/##; s#[?/].*##')"
  [ -n "$fid" ] || die "uso: ds render drive <link de la carpeta de Drive>"
  command -v rclone >/dev/null || brew install rclone
  echo "→ se abre el navegador: elegí tu cuenta de Google y aceptá (acceso a Drive para subir los videos)"
  local tok
  tok="$(rclone authorize drive | sed -n '/--->$/,/^<---End paste/p' | sed '1d;$d' | tr -d '\n')"
  [ -n "$tok" ] || die "no llegó el permiso de Google; probá de nuevo"
  # el token va por stdin, nunca como argumento (no queda en ps ni en el historial)
  printf '[drive]\ntype = drive\nscope = drive\nroot_folder_id = %s\ntoken = %s\n' "$fid" "$tok" |
    "${SSH[@]}" "umask 077; cat > $REMOTE/rclone.conf && RCLONE_CONFIG=$REMOTE/rclone.conf rclone lsd drive: >/dev/null && echo '✓ Drive conectado a la carpeta'"
}

estado() {
  "${SSH[@]}" "cd $REMOTE; systemctl is-active -q dublin-render || echo '⚠ el worker no está corriendo (ds render setup)'
    n=0; for d in cola/*/; do [ -f \"\$d.listo\" ] || continue; id=\$(basename \"\$d\"); n=\$((n+1))
      p=\$(grep '^  [0-9]*/[0-9]*  [0-9]*s\$' estado/\$id.log 2>/dev/null | tail -1)
      if [ -n \"\$p\" ]; then echo \"▶ \$id  \$p\"; elif [ \$n -eq 1 ]; then echo \"▶ \$id  arrancando\"; else echo \"· \$id  en cola\"; fi; done
    [ \$n -eq 0 ] && echo 'cola vacía'
    echo '— últimos:'; ls -1t estado/*.log 2>/dev/null | head -5 | while read l; do echo \"  \$(basename \$l .log)  \$(tail -1 \$l | cut -c1-120)\"; done" |
    awk '/^▶ .*  [0-9]+\/[0-9]+  [0-9]+s$/ { split($(NF-1), f, "/"); s = $NF + 0; p = f[2] ? f[1] / f[2] : 0
           printf "▶ %s  %d%%  %s/%s frames%s\n", $2, p * 100, f[1], f[2], (p > 0.02 ? sprintf(" · faltan ~%d min", (s / p - s) / 60 + 1) : ""); next }
         { print }'
}

case "${1:-}" in
  setup) setup; exit 0 ;;
  drive) drive "${2:-}"; exit 0 ;;
  estado) estado; exit 0 ;;
  log) [ -n "${2:-}" ] || die "uso: ds render log <id>"; "${SSH[@]}" "cat $REMOTE/estado/$(printf '%q' "$2").log"; exit 0 ;;
  bajar) [ -n "${2:-}" ] || die "uso: ds render bajar <id>"
    "${RSYNC[@]}" "$HOST:$REMOTE/hechos/$2/" ./ && "${SSH[@]}" "rm -rf $REMOTE/hechos/$(printf '%q' "$2")" && echo "✓ bajado acá"; exit 0 ;;
esac

EXEC=""; case "${1:-}" in exec|hoja|verificar) EXEC="$1"; shift ;; esac
[ $# -ge 1 ] || die "uso: ds render <carpeta|comp.html> [--lindo|--final] [--destino a/b] [args de render.py]  ·  ds render estado"

SRC="$1"; shift
COMP=comp.html
[ -f "$SRC" ] && { COMP="$(basename "$SRC")"; SRC="$(dirname "$SRC")"; }
[ -f "$SRC/$COMP" ] || die "no encuentro $SRC/$COMP"
SRC="$(cd "$SRC" && pwd)"
JOB="$(basename "$SRC")"

"${SSH[@]}" "docker image inspect $IMAGE >/dev/null 2>&1 && systemctl is-active -q dublin-render" || setup
"${RSYNC[@]}" --delete "$ONETAKE/scripts/" "$HOST:$REMOTE/onetake/scripts/"

if [ -n "$EXEC" ]; then
  case "$EXEC" in
    hoja) [ $# -ge 1 ] || die "uso: ds render hoja <carpeta> <t1,t2,…> [--width W --height H]"
      t="$1"; shift; set -- python3 /ot/scripts/stills.py "$COMP" --times "$t" --out stills.png "$@" ;;
    verificar) SHOTS="" R=""
      while [ $# -gt 0 ]; do case "$1" in --shots) SHOTS=" --shots $(printf '%q' "${2:?falta --shots t0,t1,…}")"; shift ;; *) R+=" $(printf '%q' "$1")" ;; esac; shift; done
      c="$(printf '%q' "$COMP")"   # verify_promo sale con 1 si algo falla: el tee deja bajar verify.txt igual
      set -- sh -c "python3 /ot/scripts/render.py $c --samples 4 --samples-max 4 --workers $WORKERS --out _verif.mp4$R && { python3 /ot/scripts/verify_promo.py _verif.mp4 --comp $c$SHOTS 2>&1 | tee verify.txt; rm -f _verif.*; }" ;;
  esac
  [ $# -ge 1 ] || die "uso: ds render exec <carpeta> <comando…>"
  ARGS=""; for a in "$@"; do ARGS+=" $(printf '%q' "$a")"; done
  "${RSYNC[@]}" --delete --exclude _frames --exclude chk --exclude '*.mp4' "$SRC/" "$HOST:$REMOTE/jobs/$JOB/"
  echo "→ corriendo en $HOST:$ARGS"
  "${SSH[@]}" "${ELEVENLABS_API_KEY:+ELEVENLABS_API_KEY=$(printf '%q' "$ELEVENLABS_API_KEY") }flock $REMOTE/lock docker run --rm --init --cpus=$CPUS --cpu-shares=256 --memory=$MEM --memory-swap=$MEM --shm-size=1g \
    -v $REMOTE/jobs/$JOB:/job -v $REMOTE/onetake:/ot:ro -v $REMOTE/kokoro:/root/.cache/kokoro:ro -e PYTHONPATH=/ot/scripts${ELEVENLABS_API_KEY:+ -e ELEVENLABS_API_KEY} -w /job $IMAGE$ARGS"
  "${RSYNC[@]}" --exclude _frames --exclude '*.mp4' "$HOST:$REMOTE/jobs/$JOB/" "$SRC/"
  "${SSH[@]}" "rm -rf $REMOTE/jobs/$JOB"
  echo "✓ $SRC actualizado"; exit 0
fi

# modo + destino + nombre de salida; el resto va tal cual a render.py
MODO=rapido DESTINO="$JOB" OUT="" PASS=()
while [ $# -gt 0 ]; do case "$1" in
  --lindo) MODO=lindo ;; --final) MODO=final ;;
  --destino) DESTINO="${2:?falta la carpeta de --destino}"; shift ;;
  --out) OUT="${2:?}"; shift ;;
  *) PASS+=("$1") ;;
esac; shift; done
case "$MODO" in
  rapido) PASS=(--shutter 0 "${PASS[@]+"${PASS[@]}"}") ;;
  lindo) PASS=(--samples 4 --samples-max 4 "${PASS[@]+"${PASS[@]}"}") ;;
  final) PASS=(--final "${PASS[@]+"${PASS[@]}"}") ;;
esac
OUT="${OUT:-$JOB-$MODO.mp4}"
ARGS=""; for a in "${PASS[@]}"; do ARGS+=" $(printf '%q' "$a")"; done
ID="$(date +%Y%m%d-%H%M%S)-$JOB"

echo "→ subiendo $JOB ($MODO)"
"${RSYNC[@]}" --exclude _frames --exclude chk --exclude '*.mp4' "$SRC/" "$HOST:$REMOTE/cola/$ID/"
printf 'COMP=%q\nARGS=%q\nOUT=%q\nDESTINO=%q\nNOMBRE=%q\n' "$COMP" "$ARGS" "$OUT" "${DESTINO%/}" "$JOB" |
  "${SSH[@]}" "cat > $REMOTE/cola/$ID/job.env && touch $REMOTE/cola/$ID/.listo"
echo "✓ en cola: $ID → Drive/${DESTINO%/}/$OUT"
echo "  ds render estado   para ver cómo va · te avisa ntfy cuando esté"
