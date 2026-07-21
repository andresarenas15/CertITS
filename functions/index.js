const admin = require("firebase-admin");
admin.initializeApp();

const { onRequest } = require("firebase-functions/v2/https");
const { PDFDocument, StandardFonts } = require("pdf-lib");
const fs = require("fs");
const path = require("path");

// -------------------------------------------------------------
// Plantillas
// -------------------------------------------------------------
const TEMPLATE_ILUMINANCIA = "FR024_template.pdf";
const TEMPLATE_INSPECCION = "acta_inspeccion.pdf"; // ← Asegurate de que este archivo exista en functions/assets/

// -------------------------------------------------------------
// Funciones auxiliares comunes
// -------------------------------------------------------------
function pick(obj, keys, def = undefined) {
  for (const k of keys) {
    if (obj && obj[k] !== undefined && obj[k] !== null) return obj[k];
  }
  return def;
}
function ensureString(v) {
  if (v === undefined || v === null) return "";
  return String(v);
}
function ensureArray(v) {
  return Array.isArray(v) ? v : [];
}
function dashIfEmpty(v) {
  const s = ensureString(v).trim();
  return s.length ? s : "-";
}

function normalizeTipo(tipoRaw) {
  const t = ensureString(tipoRaw).trim().toLowerCase();
  if (t.includes("sala")) return "sala";
  if (t.includes("examen")) return "examen";
  if (t.includes("otra")) return "otras";
  return "";
}

// -------------------------------------------------------------
// Autoajuste de texto mejorado
// -------------------------------------------------------------
/**
 * Rellena un campo AcroForm ajustando el tamaño de fuente para que
 * el texto ocupe todo el rectángulo sin desbordar.
 * Requiere que el campo en el PDF esté configurado como MULTILÍNEA.
 */
async function fillTextFieldAutoSize(pdfDoc, fieldName, text, maxFontSize = 10, font) {
  const form = pdfDoc.getForm();
  const field = form.getTextField(fieldName);
  if (!field) {
    console.warn(`Campo '${fieldName}' no encontrado`);
    return;
  }

  const widget = field.acroField.getWidgets()[0];
  const { width, height } = widget.getRectangle();

  const margin = 2.5;
  const boxWidth = width - margin * 2;
  const boxHeight = height - margin * 2;

  let usedFont = font;
  if (!usedFont) {
    usedFont = await pdfDoc.embedFont(StandardFonts.Helvetica);
  }

  let fontSize = maxFontSize;
  const minFontSize = 4;
  const lineSpacing = 1.15;

  while (fontSize >= minFontSize) {
    const lines = wrapText(text, usedFont, fontSize, boxWidth);
    const lineHeight = fontSize * lineSpacing;
    const totalHeight = lines.length * lineHeight;

    if (totalHeight <= boxHeight) break;
    fontSize -= 0.5;
  }

  if (fontSize < minFontSize) fontSize = minFontSize;

  field.acroField.setDefaultAppearance(`/Helv ${fontSize} Tf 0 g`);
  field.setText(text);
}

/**
 * Divide el texto en líneas, rompiendo palabras largas si es necesario.
 */
function wrapText(text, font, fontSize, maxWidth) {
  const words = text.split(' ');
  const lines = [];
  let currentLine = '';

  for (const word of words) {
    if (font.widthOfTextAtSize(word, fontSize) > maxWidth) {
      let remaining = word;
      while (remaining.length > 0) {
        let chunk = '';
        for (let i = 1; i <= remaining.length; i++) {
          const part = remaining.substring(0, i);
          if (font.widthOfTextAtSize(part, fontSize) > maxWidth) break;
          chunk = part;
        }
        if (chunk.length === 0) {
          chunk = remaining.charAt(0);
          remaining = remaining.slice(1);
        } else {
          remaining = remaining.slice(chunk.length);
        }
        if (currentLine.length > 0) {
          lines.push(currentLine);
          currentLine = '';
        }
        lines.push(chunk);
      }
    } else {
      const testLine = currentLine ? `${currentLine} ${word}` : word;
      if (font.widthOfTextAtSize(testLine, fontSize) > maxWidth && currentLine !== '') {
        lines.push(currentLine);
        currentLine = word;
      } else {
        currentLine = testLine;
      }
    }
  }

  if (currentLine) lines.push(currentLine);
  return lines;
}

// -------------------------------------------------------------
// FUNCIÓN ORIGINAL FR024 (sin cambios)
// -------------------------------------------------------------
exports.fr024GeneratePdf = onRequest(
  {
    region: "us-central1",
    cors: true,
    memory: "512MiB",
  },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).send("Use POST");
        return;
      }

      const authHeader = req.headers.authorization || "";
      const match = authHeader.match(/^Bearer (.+)$/);
      if (!match) {
        res.status(401).json({ error: "missing_auth_header" });
        return;
      }
      const idToken = match[1];
      await admin.auth().verifyIdToken(idToken);

      let body = req.body;
      body = body && body.data && typeof body.data === "object" ? body.data : body;
      if (typeof body === "string") {
        try { body = JSON.parse(body); } catch (_) { body = {}; }
      }
      if (!body || typeof body !== "object") body = {};

      const os = ensureString(pick(body, ["os", "OS"]));
      const fecha = ensureString(pick(body, ["fecha", "fecha_muestreo", "fechaMuestreo"]));
      const cliente = ensureString(pick(body, ["cliente"]));
      const lugar = ensureString(pick(body, ["lugar", "lugar_muestreo", "lugarMuestreo"]));
      const equipo = ensureString(pick(body, ["equipo"], "LUXOMETRO"));
      const codigoEquipo = ensureString(pick(body, ["codigoEquipo", "codigo_equipo"]));
      const inspectorNombre = ensureString(pick(body, ["inspectorNombre", "inspector_nombre"]));
      const clienteNombre = ensureString(pick(body, ["clienteNombre", "cliente_nombre"]));
      const firmaInspectorB64 = ensureString(pick(body, ["firmaInspectorPngBase64", "firma_inspector_png_base64"]));
      const firmaClienteB64 = ensureString(pick(body, ["firmaClientePngBase64", "firma_cliente_png_base64"]));
      const areasRaw = ensureArray(pick(body, ["areas"]));

      const missing = [];
      if (!os) missing.push("os");
      if (!fecha) missing.push("fecha");
      if (!cliente) missing.push("cliente");
      if (!lugar) missing.push("lugar");
      if (!codigoEquipo) missing.push("codigoEquipo");
      if (!inspectorNombre) missing.push("inspectorNombre");
      if (!clienteNombre) missing.push("clienteNombre");
      if (!firmaInspectorB64) missing.push("firmaInspectorPngBase64");
      if (!firmaClienteB64) missing.push("firmaClientePngBase64");
      if (!Array.isArray(areasRaw) || areasRaw.length === 0) missing.push("areas[]");
      if (missing.length > 0) {
        res.status(400).json({ error: "missing_data", missing, receivedKeys: Object.keys(body) });
        return;
      }

      const areas = areasRaw.map((a) => {
        const m = a && typeof a === "object" ? a : {};
        return {
          area: ensureString(pick(m, ["area"])),
          lecturaInSitu: ensureString(pick(m, ["lecturaInSitu", "lectura_in_situ"])),
          lecturaCorregida: ensureString(pick(m, ["lecturaCorregida", "lectura_corregida"])),
          tipo: ensureString(pick(m, ["tipo", "tipo_area"])),
          obs: ensureString(pick(m, ["obs", "observacion"])),
        };
      });

      const tplPath = path.join(__dirname, "assets", TEMPLATE_ILUMINANCIA);
      if (!fs.existsSync(tplPath)) {
        res.status(500).json({ error: "template_not_found", expectedPath: tplPath });
        return;
      }
      const tplBytes = fs.readFileSync(tplPath);
      const pdfDoc = await PDFDocument.load(tplBytes);

      const templatePages = pdfDoc.getPageCount();
      const pagesNeeded = Math.ceil(areas.length / 10);
      if (pagesNeeded > templatePages) {
        res.status(400).json({ error: "not_enough_pages_in_template", pagesNeeded, templatePages });
        return;
      }

      const form = pdfDoc.getForm();
      const font = await pdfDoc.embedFont(StandardFonts.Helvetica);

      const setText = (name, value) => {
        try { const f = form.getTextField(name); f.setText(ensureString(value)); } catch (_) {}
      };
      const setCheck = (name, checked) => {
        try { const cb = form.getCheckBox(name); if (checked) cb.check(); else cb.uncheck(); } catch (_) {}
      };
      const setButtonImage = (name, image) => {
        try { const b = form.getButton(name); b.setImage(image); } catch (_) {}
      };

      setText("os", dashIfEmpty(os));
      setText("fecha", dashIfEmpty(fecha));
      setText("cliente", dashIfEmpty(cliente));
      setText("lugar", dashIfEmpty(lugar));
      setText("equipo", dashIfEmpty(equipo));
      setText("codigoEquipo", dashIfEmpty(codigoEquipo));
      setText("nombre_inspector", dashIfEmpty(inspectorNombre));
      setText("nombre_cliente", dashIfEmpty(clienteNombre));

      const inspPng = await pdfDoc.embedPng(Buffer.from(firmaInspectorB64, "base64"));
      const cliPng = await pdfDoc.embedPng(Buffer.from(firmaClienteB64, "base64"));
      setButtonImage("sig_insp_af_image", inspPng);
      setButtonImage("sig_cli_af_image", cliPng);

      for (let p = 1; p <= pagesNeeded; p++) {
        for (let r = 1; r <= 10; r++) {
          const idx = (p - 1) * 10 + (r - 1);
          const prefix = `p${p}`;
          const fArea = `${prefix}_area_${r}`;
          const fIn = `${prefix}_insitu_${r}`;
          const fCo = `${prefix}_corr_${r}`;
          const fOb = `${prefix}_obs_${r}`;
          const salaName = `${prefix}_tipo_${r}_sala`;
          const exaName = `${prefix}_tipo_${r}_examen`;
          const otrName = `${prefix}_tipo_${r}_otras`;

          setCheck(salaName, false);
          setCheck(exaName, false);
          setCheck(otrName, false);
          if (p === 1) {
            setCheck(`tipo_${r}_sala`, false);
            setCheck(`tipo_${r}_examen`, false);
            setCheck(`tipo_${r}_otras`, false);
          }

          if (idx >= areas.length) {
            setText(fArea, "-");
            setText(fIn, "-");
            setText(fCo, "-");
            setText(fOb, "-");
            continue;
          }

          const row = areas[idx];
          setText(fArea, dashIfEmpty(row.area));
          setText(fIn, dashIfEmpty(row.lecturaInSitu));
          setText(fCo, dashIfEmpty(row.lecturaCorregida));
          setText(fOb, dashIfEmpty(row.obs));

          const tipoKey = normalizeTipo(row.tipo);
          if (tipoKey === "sala") setCheck(salaName, true);
          else if (tipoKey === "examen") setCheck(exaName, true);
          else if (tipoKey === "otras") setCheck(otrName, true);

          if (p === 1) {
            setCheck(`tipo_${r}_sala`, tipoKey === "sala");
            setCheck(`tipo_${r}_examen`, tipoKey === "examen");
            setCheck(`tipo_${r}_otras`, tipoKey === "otras");
          }
        }
      }

      for (let i = pdfDoc.getPageCount() - 1; i >= pagesNeeded; i--) {
        pdfDoc.removePage(i);
      }

      form.updateFieldAppearances(font);
      form.flatten();
      const outBytes = await pdfDoc.save();
      res.setHeader("Content-Type", "application/pdf");
      res.status(200).send(Buffer.from(outBytes));
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: "internal_error", message: String(err?.message || err) });
    }
  }
);

// -------------------------------------------------------------
// NUEVA FUNCIÓN: Inspección Sanitaria
// -------------------------------------------------------------
exports.generateInspectionPdf = onRequest({
  region: "us-central1",
  cors: true,
  memory: "512MiB",
}, async (req, res) => {
  try {
    if (req.method !== "POST") {
      res.status(405).send("Use POST");
      return;
    }

    // Auth
    const authHeader = req.headers.authorization || "";
    const match = authHeader.match(/^Bearer (.+)$/);
    if (!match) {
      res.status(401).json({ error: "missing_auth_header" });
      return;
    }
    const idToken = match[1];
    await admin.auth().verifyIdToken(idToken);

    // Parsear body
    let body = req.body;
    if (body && body.data && typeof body.data === "object") body = body.data;
    if (typeof body === "string") {
      try { body = JSON.parse(body); } catch (_) { body = {}; }
    }
    if (!body || typeof body !== "object") body = {};

    const os = ensureString(body.os);
    const fecha = ensureString(body.fecha);
    const cliente = ensureString(body.cliente);
    const lugar = ensureString(body.lugar);
    const inspector = ensureString(body.inspectorNombre || body.inspector_nombre || "");
    const preguntas = ensureArray(body.preguntas); // array de { id: string, observacion: string }

    if (!os || !fecha || !cliente || !lugar) {
      res.status(400).json({ error: "faltan datos: os, fecha, cliente, lugar" });
      return;
    }
    if (preguntas.length === 0) {
      res.status(400).json({ error: "preguntas vacío" });
      return;
    }

    // Cargar plantilla de inspección (LOCAL, no desde Cloud Storage)
    const tplPath = path.join(__dirname, "assets", TEMPLATE_INSPECCION);
    if (!fs.existsSync(tplPath)) {
      res.status(500).json({ error: "template_not_found", expectedPath: tplPath });
      return;
    }
    const tplBytes = fs.readFileSync(tplPath);
    const pdfDoc = await PDFDocument.load(tplBytes);

    const form = pdfDoc.getForm();
    const font = await pdfDoc.embedFont(StandardFonts.Helvetica);

    // Rellenar cabecera
    const setText = (name, value) => {
      try { form.getTextField(name).setText(ensureString(value)); } catch (_) {}
    };
    setText("os", dashIfEmpty(os));
    setText("fecha", dashIfEmpty(fecha));
    setText("cliente", dashIfEmpty(cliente));
    setText("lugar", dashIfEmpty(lugar));
    if (inspector) setText("nombre_inspector", inspector);

    // Rellenar cada observación con auto‑ajuste
    for (const pregunta of preguntas) {
      const id = String(pregunta.id).replace(/[^0-9]/g, ""); // extraer número
      const fieldName = `obs${id}`;
      const texto = ensureString(pregunta.observacion || pregunta.obs || "");
      await fillTextFieldAutoSize(pdfDoc, fieldName, texto, 10, font);
    }

    // Finalizar
    form.updateFieldAppearances(font);
    form.flatten();

    const outBytes = await pdfDoc.save();
    res.setHeader("Content-Type", "application/pdf");
    res.status(200).send(Buffer.from(outBytes));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "internal_error", message: err.message });
  }
});