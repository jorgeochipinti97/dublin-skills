#!/usr/bin/env bash
# Worker de `ds render` en el servidor (servicio systemd dublin-render, lo instala `ds render setup`).
# Toma de a uno los trabajos de /opt/render/cola/<id>/ (los que tienen .listo, en orden de id), renderiza en Docker
# con tope de CPU/RAM y prioridad baja, sube el mp4 a Drive (rclone), avisa por ntfy y borra el trabajo del server.
# Si el servicio o el server se reinician a mitad de un render, lo retoma con --resume (los frames hechos quedan).
set -uo pipefail
R=/opt/render
export RCLONE_CONFIG=$R/rclone.conf

avisar() {  # tag de ntfy (el emoji), título, mensaje, [link]
  [ -n "${NTFY_TOPIC:-}" ] || return 0
  curl -fsS -m 15 -H "Tags: $1" -H "Title: $2" ${4:+-H "Click: $4"} -d "$3" "https://ntfy.sh/$NTFY_TOPIC" >/dev/null || true
}

while true; do
  . $R/config   # IMAGE CPUS MEM WORKERS NTFY_TOPIC (se relee en cada vuelta: un setup nuevo vale sin reiniciar)
  job=""; for d in $R/cola/*/; do [ -f "$d.listo" ] && { job="${d%/}"; break; }; done
  [ -n "$job" ] || { sleep 10; continue; }

  id="$(basename "$job")"; log="$R/estado/$id.log"
  COMP="" ARGS="" OUT="" DESTINO="" NOMBRE=""
  . "$job/job.env"
  eval "set -- $ARGS"
  echo "▶ $(date '+%F %T') $NOMBRE → $DESTINO/$OUT" >> "$log"
  t0=$(date +%s)

  docker rm -f "render-$id" >/dev/null 2>&1
  flock $R/lock docker run --rm --init --name "render-$id" --cpus="$CPUS" --cpu-shares=256 --memory="$MEM" --memory-swap="$MEM" --shm-size=1g \
    -v "$job:/job" -v $R/onetake:/ot:ro -v $R/kokoro:/root/.cache/kokoro:ro -e PYTHONPATH=/ot/scripts -w /job "$IMAGE" \
    python3 /ot/scripts/render.py "$COMP" --workers "$WORKERS" --resume --out "$OUT" "$@" >> "$log" 2>&1
  rc=$?; mins=$(( ($(date +%s) - t0 + 59) / 60 ))

  if [ $rc -ne 0 ] || [ ! -s "$job/$OUT" ]; then
    echo "✗ render falló (código $rc)" >> "$log"
    avisar x "$NOMBRE: falló" "El render falló a los $mins min: $(grep -v '^  [0-9]' "$log" | tail -2 | tr '\n' ' ')"
    rm -rf "$job"; continue
  fi

  if rclone copyto "$job/$OUT" "drive:$DESTINO/$OUT" >> "$log" 2>&1; then
    fid="$(rclone lsjson --stat "drive:$DESTINO/$OUT" 2>/dev/null | jq -r '.ID // empty')"
    link="${fid:+https://drive.google.com/file/d/$fid/view}"
    echo "✓ $(date '+%F %T') en Drive: $DESTINO/$OUT ${link}" >> "$log"
    avisar white_check_mark "$NOMBRE listo" "$DESTINO/$OUT · $mins min" "$link"
    rm -rf "$job"
  else
    # sin Drive el video no se pierde: queda en hechos/ (sin frames) para bajarlo con `ds render bajar <id>`
    mkdir -p $R/hechos/$id && mv "$job/$OUT" $R/hechos/$id/ && rm -rf "$job"
    echo "⚠ no se pudo subir a Drive; quedó en hechos/$id" >> "$log"
    avisar warning "$NOMBRE: render ok, Drive falló" "Quedó en el server: ds render bajar $id"
  fi
  ls -1t $R/estado/*.log 2>/dev/null | tail -n +31 | xargs -r rm -f   # quedan los últimos 30 logs
done
