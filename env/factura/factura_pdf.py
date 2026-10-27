# PDF de una factura de ARCA (original + duplicado, QR oficial). Lo llama `ds factura pdf`.
#   uv run --with reportlab --with qrcode --with pillow python factura_pdf.py <out.pdf> <campos…>
import base64, calendar, json, sys
import qrcode
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.lib.utils import ImageReader
from reportlab.pdfgen import canvas

(out, e_nom, e_dom, e_cuit, e_iibb, e_inicio, e_iva, letra, cid, fecha, periodo, vto,
 r_cuit, r_nom, r_dom, r_iva, venta, item, monto, cae, cvto) = sys.argv[1:22]
dmy = lambda iso: "/".join(reversed(iso.split("-")))
y, m = map(int, periodo.split("-"))
pv, nro = map(int, cid.split("-"))
tipo = 6 if letra == "B" else 11
E = dict(nombre=e_nom, dom=e_dom, cuit=e_cuit, iibb=e_iibb, inicio=e_inicio, iva=e_iva)
F = dict(pv=pv, nro=nro, fecha=dmy(fecha), desde=f"01/{m:02d}/{y}", hasta=f"{calendar.monthrange(y, m)[1]}/{m:02d}/{y}",
         vto=dmy(vto), cuit=r_cuit, rs=r_nom, dom=r_dom, iva=r_iva, venta=venta, item=item, total=float(monto),
         cae=cae, caevto=f"{cvto[6:8]}/{cvto[4:6]}/{cvto[:4]}")

qr_data = {"ver": 1, "fecha": fecha, "cuit": int(E["cuit"]), "ptoVta": F["pv"], "tipoCmp": tipo,
           "nroCmp": F["nro"], "importe": F["total"], "moneda": "PES", "ctz": 1, "tipoDocRec": 80,
           "nroDocRec": int(F["cuit"]), "tipoCodAut": "E", "codAut": int(F["cae"])}
url = "https://www.afip.gob.ar/fe/qr/?p=" + base64.b64encode(json.dumps(qr_data, separators=(",", ":")).encode()).decode()
qr = qrcode.make(url, box_size=4, border=0).get_image()
money = lambda v: f"{v:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")

c = canvas.Canvas(out, pagesize=A4)
W, H = A4
L, R = 12 * mm, W - 12 * mm

def page(copia):
    y = H - 12 * mm
    c.setFont("Helvetica-Bold", 11); c.drawCentredString(W / 2, y, copia)
    c.rect(L, y - 4 * mm, R - L, -46 * mm)
    top = y - 4 * mm
    # letra
    c.rect(W / 2 - 8 * mm, top, 16 * mm, -14 * mm)
    c.setFont("Helvetica-Bold", 26); c.drawCentredString(W / 2, top - 9 * mm, letra)
    c.setFont("Helvetica-Bold", 7); c.drawCentredString(W / 2, top - 12.5 * mm, f"COD. {tipo:03d}")
    c.line(W / 2, top - 14 * mm, W / 2, top - 46 * mm)
    # emisor
    c.setFont("Helvetica-Bold", 15); c.drawCentredString(W / 4 + 3 * mm, top - 11 * mm, E["nombre"])
    c.setFont("Helvetica", 8.5)
    yy = top - 24 * mm
    for k, v in [("Razón Social:", E["nombre"]), ("Domicilio Comercial:", E["dom"]), ("Condición frente al IVA:", E["iva"])]:
        c.setFont("Helvetica-Bold", 8.5); c.drawString(L + 3 * mm, yy, k)
        c.setFont("Helvetica", 7.5); c.drawString(L + 3 * mm + c.stringWidth(k, "Helvetica-Bold", 8.5) + 2, yy, v); yy -= 7 * mm
    # comprobante
    x = W / 2 + 12 * mm
    c.setFont("Helvetica-Bold", 18); c.drawString(x, top - 11 * mm, "FACTURA")
    yy = top - 19 * mm
    for k, v in [("Punto de Venta:", f"{F['pv']:05d}     Comp. Nro: {F['nro']:08d}"), ("Fecha de Emisión:", F["fecha"]),
                 ("CUIT:", E["cuit"]), ("Ingresos Brutos:", E["iibb"]), ("Fecha de Inicio de Actividades:", E["inicio"])]:
        c.setFont("Helvetica-Bold", 8.5); c.drawString(x, yy, k)
        c.setFont("Helvetica", 8.5); c.drawString(x + c.stringWidth(k, "Helvetica-Bold", 8.5) + 4, yy, v); yy -= 5.5 * mm
    # periodo
    y2 = top - 46 * mm
    c.rect(L, y2 - 1.5 * mm, R - L, -8 * mm)
    c.setFont("Helvetica-Bold", 8.5)
    c.drawString(L + 3 * mm, y2 - 6.5 * mm, "Período Facturado Desde:"); c.setFont("Helvetica", 8.5); c.drawString(L + 43 * mm, y2 - 6.5 * mm, F["desde"])
    c.setFont("Helvetica-Bold", 8.5); c.drawString(L + 62 * mm, y2 - 6.5 * mm, "Hasta:"); c.setFont("Helvetica", 8.5); c.drawString(L + 73 * mm, y2 - 6.5 * mm, F["hasta"])
    c.setFont("Helvetica-Bold", 8.5); c.drawString(L + 105 * mm, y2 - 6.5 * mm, "Fecha de Vto. para el pago:"); c.setFont("Helvetica", 8.5); c.drawString(L + 146 * mm, y2 - 6.5 * mm, F["vto"])
    # receptor
    y3 = y2 - 11 * mm
    c.rect(L, y3, R - L, -22 * mm)
    rows = [((L + 3 * mm, "CUIT:", F["cuit"]), (L + 40 * mm, "Apellido y Nombre / Razón Social:", F["rs"])),
            ((L + 3 * mm, "Condición frente al IVA:", F["iva"]), (L + 95 * mm, "Domicilio:", F["dom"])),
            ((L + 3 * mm, "Condición de venta:", F["venta"]),)]
    yy = y3 - 6 * mm
    for row in rows:
        for xx, k, v in row:
            c.setFont("Helvetica-Bold", 8); c.drawString(xx, yy, k)
            c.setFont("Helvetica", 8); c.drawString(xx + c.stringWidth(k, "Helvetica-Bold", 8) + 3, yy, v)
        yy -= 6.5 * mm
    # items
    y4 = y3 - 25 * mm
    c.setFillGray(0.85); c.rect(L, y4, R - L, -6 * mm, fill=1, stroke=1); c.setFillGray(0)
    cols = [(L + 2 * mm, "Código"), (L + 18 * mm, "Producto / Servicio"), (L + 92 * mm, "Cantidad"), (L + 110 * mm, "U. Medida"),
            (L + 130 * mm, "Precio Unit."), (L + 150 * mm, "% Bonif"), (L + 166 * mm, "Subtotal")]
    c.setFont("Helvetica-Bold", 7.5)
    for xx, t in cols: c.drawString(xx, y4 - 4 * mm, t)
    c.setFont("Helvetica", 8)
    yi = y4 - 11 * mm
    c.drawString(L + 18 * mm, yi, F["item"]); c.drawRightString(L + 104 * mm, yi, "1,00"); c.drawString(L + 110 * mm, yi, "unidades")
    c.drawRightString(L + 147 * mm, yi, money(F["total"])); c.drawRightString(L + 162 * mm, yi, "0,00"); c.drawRightString(R - 2 * mm, yi, money(F["total"]))
    # totales
    y5 = 78 * mm
    c.rect(L, y5, R - L, -24 * mm)
    for i, (k, v) in enumerate([("Subtotal: $", F["total"]), ("Importe Otros Tributos: $", 0), ("Importe Total: $", F["total"])]):
        c.setFont("Helvetica-Bold", 9.5); c.drawRightString(R - 40 * mm, y5 - (6 + i * 7) * mm, k); c.drawRightString(R - 3 * mm, y5 - (6 + i * 7) * mm, money(v))
    # pie
    c.drawImage(ImageReader(qr), L, 14 * mm, 30 * mm, 30 * mm)
    c.setFont("Helvetica-Bold", 11); c.drawString(L + 34 * mm, 34 * mm, "ARCA")
    c.setFont("Helvetica-BoldOblique", 9); c.drawString(L + 34 * mm, 28 * mm, "Comprobante Autorizado")
    c.setFont("Helvetica-Oblique", 6.5); c.drawString(L + 34 * mm, 23 * mm, "Esta Agencia no se responsabiliza por los datos ingresados en el detalle de la operación")
    c.setFont("Helvetica", 8); c.drawCentredString(W / 2, 46 * mm, "Pág. 1/1")
    c.setFont("Helvetica-Bold", 9)
    c.drawRightString(R - 35 * mm, 38 * mm, "CAE N°:"); c.setFont("Helvetica", 9); c.drawString(R - 33 * mm, 38 * mm, F["cae"])
    c.setFont("Helvetica-Bold", 9); c.drawRightString(R - 35 * mm, 32 * mm, "Fecha de Vto. de CAE:"); c.setFont("Helvetica", 9); c.drawString(R - 33 * mm, 32 * mm, F["caevto"])
    c.showPage()

for copia in ("ORIGINAL", "DUPLICADO"):
    page(copia)
c.save()
