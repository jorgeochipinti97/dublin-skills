#!/usr/bin/env bash
# `ds factura` — facturas electrónicas de ARCA (wsfe) registradas en finanzas.md.
#
#   ds factura emitir <cuit> <monto> "<descripción>" [--periodo AAAA-MM] [--cond 4]
#                     [--vto AAAA-MM-DD] [--si]     emite (pide confirmación salvo --si)
#   ds factura pagar <nro> [AAAA-MM-DD]             marca paga + suma el ingreso a Movimientos
#   ds factura list [pendientes]
#   ds factura pdf <nro>                            (re)genera el PDF con QR (emitir ya lo genera)
#
# Credenciales FUERA del repo, en ~/.config/dublin/arca (una vez):
#   ARCA_DIR=~/.arca        carpeta con cert.crt + cert.key (o <algo>.crt/.key) del certificado de ARCA
#   ARCA_CUIT=20123456789   CUIT emisor
#   ARCA_PTOVTA=2           punto de venta "Web Services"
#   ARCA_TIPO=11            11 = Factura C (monotributo); 6 = Factura B
#   ARCA_ENV=prod           o "homo" para homologación
# Para el PDF (datos del emisor que ARCA no devuelve por web service):
#   ARCA_NOMBRE="APELLIDO NOMBRE"   ARCA_DOMICILIO="Calle 123 - Localidad, Provincia"
#   ARCA_IIBB=20123456789   ARCA_INICIO=01/06/2025   ARCA_CONDICION="Responsable Monotributo"
#   ARCA_VENTA="Contado / Transferencia Bancaria / Otra"   ARCA_PDF_DIR=~/Desktop
# El certificado tiene que estar asociado a "wsfe" en ARCA → Administrador de Relaciones.
set -uo pipefail

B=$'\e[1m'; G=$'\e[32m'; Y=$'\e[33m'; R=$'\e[31m'; D=$'\e[2m'; N=$'\e[0m'
die() { echo "${R}$*${N}" >&2; exit 1; }

CONF="$HOME/.config/dublin/arca"
[ -f "$CONF" ] || die "Falta $CONF (ARCA_DIR, ARCA_CUIT, ARCA_PTOVTA). Ver cabecera de este script."
# shellcheck disable=SC1090
. "$CONF"
ARCA_DIR="${ARCA_DIR/#\~/$HOME}"; ARCA_TIPO="${ARCA_TIPO:-11}"; ARCA_ENV="${ARCA_ENV:-prod}"
: "${ARCA_CUIT:?falta ARCA_CUIT en $CONF}" "${ARCA_PTOVTA:?falta ARCA_PTOVTA en $CONF}"
CRT="$(ls "$ARCA_DIR"/*.crt 2>/dev/null | head -1)"; KEY="$(ls "$ARCA_DIR"/*.key 2>/dev/null | head -1)"
[ -f "$CRT" ] && [ -f "$KEY" ] || die "No encuentro .crt/.key en $ARCA_DIR"

if [ "$ARCA_ENV" = homo ]; then
  WSAA=https://wsaahomo.afip.gov.ar/ws/services/LoginCms; WSFE=https://wswhomo.afip.gov.ar/wsfev1/service.asmx
  PADRON=https://awshomo.afip.gov.ar/sr-padron/webservices/personaServiceA13
else
  WSAA=https://wsaa.afip.gov.ar/ws/services/LoginCms; WSFE=https://servicios1.afip.gov.ar/wsfev1/service.asmx
  PADRON=https://aws.afip.gov.ar/sr-padron/webservices/personaServiceA13
fi

PROJECTS="${DUBLIN_PROJECTS:-$(head -1 "$HOME/.config/dublin/projects-root" 2>/dev/null)}"
PROJECTS="${PROJECTS/#\~/$HOME}"
FIN="${DUBLIN_FINANZAS:-$([ -n "$PROJECTS" ] && echo "$(dirname "$PROJECTS")/finanzas.md" || echo "$HOME/finanzas.md")}"

utc() { date -u -d "@$1" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -r "$1" +%Y-%m-%dT%H:%M:%SZ; }
tag() { sed -n "s/.*<$1>\([^<]*\)<\/$1>.*/\1/p" | head -1; }

# Ticket de acceso por servicio, cacheado en ARCA_DIR (dura ~12 h).
ta() {
  local svc="$1" f="$ARCA_DIR/ta-$1-$ARCA_ENV.xml" now cms resp
  if [ ! -f "$f" ] || [ "$(date +%s)" -ge "$(cat "$f.exp" 2>/dev/null || echo 0)" ]; then
    now=$(date +%s)
    cms=$(printf '<?xml version="1.0" encoding="UTF-8"?><loginTicketRequest version="1.0"><header><uniqueId>%s</uniqueId><generationTime>%s</generationTime><expirationTime>%s</expirationTime></header><service>%s</service></loginTicketRequest>' \
      "$now" "$(utc $((now-600)))" "$(utc $((now+43000)))" "$svc" \
      | openssl cms -sign -signer "$CRT" -inkey "$KEY" -nodetach -outform DER | base64 | tr -d '\n')
    resp=$(curl -s "$WSAA" -H 'Content-Type: text/xml; charset=utf-8' -H 'SOAPAction: ""' \
      -d "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:wsaa=\"http://wsaa.view.sua.dvadac.desein.afip.gov\"><soapenv:Body><wsaa:loginCms><wsaa:in0>$cms</wsaa:in0></wsaa:loginCms></soapenv:Body></soapenv:Envelope>")
    grep -q loginCmsReturn <<<"$resp" || { echo "WSAA ($svc): $(tag faultstring <<<"$resp")" >&2; return 1; }
    ( umask 077; sed -e 's/.*<loginCmsReturn>//' -e 's/<\/loginCmsReturn>.*//' -e 's/&lt;/</g' -e 's/&gt;/>/g' -e 's/&quot;/"/g' -e 's/&amp;/\&/g' <<<"$resp" > "$f" )
    echo $((now+42000)) > "$f.exp"
  fi
  TOKEN=$(tr -d '\n' < "$f" | tag token); SIGN=$(tr -d '\n' < "$f" | tag sign)
}

# ARCA usa DH de 1024 bits en wsfe: hay que bajar el nivel de OpenSSL solo para este host.
fe() {
  curl -s --ciphers 'DEFAULT@SECLEVEL=1' "$WSFE" -H 'Content-Type: text/xml; charset=utf-8' -H "SOAPAction: \"http://ar.gov.afip.dif.FEV1/$1\"" \
    -d "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ar=\"http://ar.gov.afip.dif.FEV1/\"><soap:Body><ar:$1><ar:Auth><ar:Token>$TOKEN</ar:Token><ar:Sign>$SIGN</ar:Sign><ar:Cuit>$ARCA_CUIT</ar:Cuit></ar:Auth>$2</ar:$1></soap:Body></soap:Envelope>"
}

# "Razón social|domicilio" desde el padrón A13 (opcional: si el cert no tiene ese servicio, queda vacío).
padron() {
  ( ta ws_sr_padron_a13 2>/dev/null || exit 1
    curl -s "$PADRON" -H 'Content-Type: text/xml; charset=utf-8' -H 'SOAPAction: ""' \
      -d "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:a13=\"http://a13.soap.ws.server.puc.sr/\"><soapenv:Body><a13:getPersona><token>$TOKEN</token><sign>$SIGN</sign><cuitRepresentada>$ARCA_CUIT</cuitRepresentada><idPersona>$1</idPersona></a13:getPersona></soapenv:Body></soapenv:Envelope>" \
      > "$ARCA_DIR/.padron.$$"
    p=$(cat "$ARCA_DIR/.padron.$$"); rm -f "$ARCA_DIR/.padron.$$"
    nom=$(grep -oE '<(razonSocial|apellido|nombre)>[^<]*' <<<"$p" | sed 's/<[^>]*>//' | head -2 | paste -sd' ' -)
    d1=$(sed 's/<\/domicilio>.*//' <<<"$p")   # primer domicilio (el fiscal)
    dom="$(grep -oE '<direccion>[^<]*' <<<"$d1" | tail -1 | sed 's/<[^>]*>//') - $(grep -oE '<localidad>[^<]*' <<<"$d1" | tail -1 | sed 's/<[^>]*>//'), $(grep -oE '<descripcionProvincia>[^<]*' <<<"$d1" | tail -1 | sed 's/<[^>]*>//')"
    [ -n "$nom" ] && echo "$nom|$dom" ) || true
}

# Condición frente al IVA del receptor (tabla FEParamGetCondicionIvaReceptor).
cond_desc() { case "$1" in
  1) echo "IVA Responsable Inscripto" ;; 4) echo "IVA Sujeto Exento" ;; 5) echo "Consumidor Final" ;;
  6) echo "Responsable Monotributo" ;; 7) echo "Sujeto No Categorizado" ;; 8) echo "Proveedor del Exterior" ;;
  9) echo "Cliente del Exterior" ;; 10) echo "IVA Liberado – Ley N° 19.640" ;; 13) echo "Monotributista Social" ;;
  15) echo "IVA No Alcanzado" ;; 16) echo "Monotributo Trabajador Independiente Promovido" ;; esac; }

# PDF (original + duplicado, QR de ARCA) de una factura de finanzas.md. Necesita uv.
pdf() {
  local q="${1:-}"; [ -n "$q" ] || die "Uso: ds factura pdf <nro>"
  command -v uv >/dev/null || die "Falta uv: brew install uv"
  : "${ARCA_NOMBRE:?falta ARCA_NOMBRE en $CONF}" "${ARCA_DOMICILIO:?falta ARCA_DOMICILIO en $CONF}" "${ARCA_INICIO:?falta ARCA_INICIO en $CONF}"
  local pat; [[ "$q" == *-* ]] && pat=" $q " || pat="-0*$((10#$q)) "
  local l; l=$(grep -E "^- [0-9-]{10} [BC] [0-9]{4}${pat}" "$FIN" 2>/dev/null)
  [ "$(grep -c . <<<"$l")" -eq 1 ] && [ -n "$l" ] || die "No encuentro una única factura \"$q\" en $FIN"
  local fecha letra id monto cuit desc periodo vto cae cvto rest
  read -r _ fecha letra id monto rest <<<"$l"
  cuit=$(grep -oE '\([0-9]{11}\) · ' <<<"$l" | tr -dc 0-9)
  local ivap; IFS='|' read -r _ desc periodo vto caep ivap _ <<<"$(sed 's/ · /|/g' <<<"$rest")"
  vto="${vto#vto pago }"; cae=$(awk '{print $2}' <<<"$caep"); cvto=$(awk '{print $4}' <<<"$caep")
  [[ "$vto" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || die "La línea no tiene \"vto pago AAAA-MM-DD\""
  local pd nom dom; pd=$(padron "$cuit"); nom="${pd%%|*}"; dom="${pd#*|}"
  [ -n "$pd" ] || { nom=$(sed -E 's/^- ([^ ]+ ){4}(.*) \([0-9]{11}\) · .*/\2/' <<<"$l"); dom=""; }
  local dir="${ARCA_PDF_DIR:-$HOME/Desktop}"; dir="${dir/#\~/$HOME}"
  local tipo; tipo=$([ "$letra" = B ] && echo 006 || echo 011)
  local out; out="$dir/${ARCA_CUIT}_${tipo}_$(printf '%05d_%08d' $((10#${id%-*})) $((10#${id#*-}))).pdf"
  uv run -q --with reportlab --with qrcode --with pillow python -I "$(dirname "$0")/factura_pdf.py" "$out" \
    "$ARCA_NOMBRE" "$ARCA_DOMICILIO" "$ARCA_CUIT" "${ARCA_IIBB:-$ARCA_CUIT}" "$ARCA_INICIO" "${ARCA_CONDICION:-Responsable Monotributo}" \
    "$letra" "$id" "$fecha" "$periodo" "$vto" "$cuit" "$nom" "$dom" "$(cond_desc "${ivap#iva }")" \
    "${ARCA_VENTA:-Contado / Transferencia Bancaria / Otra}" "$desc" "$monto" "$cae" "$cvto" || die "No pude generar el PDF"
  echo "${G}PDF:${N} $out"
}

ensure_fin() {
  [ -f "$FIN" ] || printf '# Finanzas\n\n<!-- Movimientos: - AAAA-MM-DD <monto, negativo = gasto> <descripción> #categoría -->\n' > "$FIN"
  # "## Facturas" va antes de "## Movimientos": el panel agrega movimientos al final del archivo.
  grep -qx '## Facturas' "$FIN" && return
  if grep -qx '## Movimientos' "$FIN"; then
    awk '$0=="## Movimientos"{print "## Facturas"; print ""} {print}' "$FIN" > "$FIN.tmp" && mv "$FIN.tmp" "$FIN"
  else printf '\n## Facturas\n\n## Movimientos\n\n' >> "$FIN"; fi
}

last_day() { local y=${1%-*} m=$((10#${1#*-})); local d=(31 28 31 30 31 30 31 31 30 31 30 31)
  (( m==2 && (y%4==0 && (y%100!=0 || y%400==0)) )) && echo 29 || echo "${d[m-1]}"; }

emitir() {
  local cuit="${1//-/}" monto="${2:-}" desc="${3:-}"; shift 3 2>/dev/null || true
  local periodo; periodo=$(date +%Y-%m); local cond=4 vto="" si=""
  while [ $# -gt 0 ]; do case "$1" in
    --periodo) periodo="$2"; shift 2 ;; --cond) cond="$2"; shift 2 ;; --vto) vto="$2"; shift 2 ;;
    --si) si=1; shift ;; *) die "Opción desconocida: $1" ;; esac; done
  [[ "$cuit" =~ ^[0-9]{11}$ ]] || die "CUIT inválido: $cuit"
  [[ "$monto" =~ ^[0-9]+(\.[0-9]{1,2})?$ ]] || die "Monto inválido: $monto"
  [ -n "$desc" ] || die "Falta la descripción"
  [[ "$periodo" =~ ^[0-9]{4}-[0-9]{2}$ ]] || die "Período inválido (AAAA-MM): $periodo"
  local hoy desde hasta; hoy=$(date +%Y%m%d); desde="${periodo/-/}01"; hasta="${periodo/-/}$(last_day "$periodo")"
  vto="${vto//-/}"; vto="${vto:-$hoy}"

  ta wsfe || exit 1
  local ult nro rs
  ult=$(fe FECompUltimoAutorizado "<ar:PtoVta>$ARCA_PTOVTA</ar:PtoVta><ar:CbteTipo>$ARCA_TIPO</ar:CbteTipo>" | tag CbteNro)
  [[ "$ult" =~ ^[0-9]+$ ]] || die "No pude leer el último comprobante autorizado"
  nro=$((ult+1)); rs=$(padron "$cuit"); rs="${rs%%|*}"; rs="${rs:-CUIT $cuit}"
  local letra; letra=$([ "$ARCA_TIPO" = 6 ] && echo B || echo C)
  local id; id=$(printf '%04d-%08d' "$ARCA_PTOVTA" "$nro")

  echo "${B}Factura $letra $id${N} ${D}($ARCA_ENV)${N}"
  echo "  Cliente   $rs ($cuit) · condición IVA $cond"
  echo "  Importe   \$ $monto"
  echo "  Concepto  $desc · servicios ${desde}–${hasta} · vto pago ${vto}"
  if [ -z "$si" ]; then
    printf "${Y}¿Emitir? Queda registrada en ARCA y no se borra (solo nota de crédito) [s/N]${N} "
    read -r ok || ok=""; [ "$ok" = s ] || die "Cancelado, no se emitió nada."
  fi

  local resp
  resp=$(fe FECAESolicitar "<ar:FeCAEReq><ar:FeCabReq><ar:CantReg>1</ar:CantReg><ar:PtoVta>$ARCA_PTOVTA</ar:PtoVta><ar:CbteTipo>$ARCA_TIPO</ar:CbteTipo></ar:FeCabReq><ar:FeDetReq><ar:FECAEDetRequest><ar:Concepto>2</ar:Concepto><ar:DocTipo>80</ar:DocTipo><ar:DocNro>$cuit</ar:DocNro><ar:CbteDesde>$nro</ar:CbteDesde><ar:CbteHasta>$nro</ar:CbteHasta><ar:CbteFch>$hoy</ar:CbteFch><ar:ImpTotal>$monto</ar:ImpTotal><ar:ImpTotConc>0</ar:ImpTotConc><ar:ImpNeto>$monto</ar:ImpNeto><ar:ImpOpEx>0</ar:ImpOpEx><ar:ImpTrib>0</ar:ImpTrib><ar:ImpIVA>0</ar:ImpIVA><ar:FchServDesde>$desde</ar:FchServDesde><ar:FchServHasta>$hasta</ar:FchServHasta><ar:FchVtoPago>$vto</ar:FchVtoPago><ar:MonId>PES</ar:MonId><ar:MonCotiz>1</ar:MonCotiz><ar:CondicionIVAReceptorId>$cond</ar:CondicionIVAReceptorId></ar:FECAEDetRequest></ar:FeDetReq></ar:FeCAEReq>")
  local res cae cvto
  res=$(tag Resultado <<<"$resp"); cae=$(tag CAE <<<"$resp"); cvto=$(tag CAEFchVto <<<"$resp")
  if [ "$res" != A ] || [ -z "$cae" ]; then
    echo "${R}Rechazada ($res).${N}" >&2
    grep -oE '<(Code|Msg)>[^<]*' <<<"$resp" | sed 's/<[^>]*>//' | grep -v 'Resolucion General Nro 5616' | paste - - >&2
    exit 1
  fi
  ensure_fin
  local line="- $(date +%Y-%m-%d) $letra $id $monto $rs ($cuit) · $desc · $periodo · vto pago ${vto:0:4}-${vto:4:2}-${vto:6:2} · CAE $cae vto $cvto · iva $cond · pendiente"
  awk -v l="$line" 'f && /^## /{print l; print ""; f=0} {print} $0=="## Facturas"{f=1}
    END{if(f) print l}' "$FIN" | cat -s > "$FIN.tmp" && mv "$FIN.tmp" "$FIN"
  echo "${G}Autorizada.${N} CAE $cae (vence $cvto) → $FIN"
  pdf "$id"
}

pagar() {
  local q="${1:-}" dia="${2:-$(date +%Y-%m-%d)}"; [ -n "$q" ] || die "Uso: ds factura pagar <nro>"
  [ -f "$FIN" ] || die "No existe $FIN"
  local pat; [[ "$q" == *-* ]] && pat=" $q " || pat="-0*$((10#$q)) "
  local hits; hits=$(grep -nE "^- [0-9-]{10} [BC] [0-9]{4}${pat}.*· pendiente$" "$FIN")
  [ "$(grep -c . <<<"$hits")" -eq 1 ] && [ -n "$hits" ] || die "No encuentro una única factura pendiente \"$q\""
  local n=${hits%%:*} l=${hits#*:}
  local letra id monto rs; read -r _ _ letra id monto _ <<<"$l"; rs=$(sed -E 's/^- [^ ]+ [^ ]+ [^ ]+ [^ ]+ (.*) \([0-9]{11}\) · .*/\1/' <<<"$l")
  sed -i.bak "${n}s/· pendiente\$/· pagada $dia/" "$FIN" && rm -f "$FIN.bak"
  grep -qx '## Movimientos' "$FIN" || printf '\n## Movimientos\n' >> "$FIN"
  sed -i.bak -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$FIN" && rm -f "$FIN.bak"
  printf -- '- %s %s Cobro factura %s %s %s #facturas\n' "$dia" "$monto" "$letra" "$id" "$rs" >> "$FIN"
  echo "${G}Pagada:${N} $letra $id · \$ $monto → ingreso en Movimientos"
}

listar() {
  [ -f "$FIN" ] || die "No existe $FIN"
  local f='^- [0-9-]{10} [BC] [0-9]{4}-'; [ "${1:-}" = pendientes ] && f="$f.*· pendiente$"
  grep -E "$f" "$FIN" | sed 's/^- //' || echo "${D}Sin facturas.${N}"
}

case "${1:-}" in
  emitir) shift; emitir "$@" ;;
  pagar)  shift; pagar "$@" ;;
  list|ls) shift; listar "$@" ;;
  pdf)    shift; pdf "$@" ;;
  *) sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//' ;;
esac
