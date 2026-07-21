class CalculosHelper {
  // Parsea un string de forma segura omitiendo guiones o nulos
  static double val(String? v) {
    if (v == null || v == '-' || v.trim().isEmpty) return 0.0;
    return double.tryParse(v) ?? 0.0;
  }

  static String porcentaje(double po, double pe) {
    if (pe == 0.0) return "0.0%";
    return "${((po / pe) * 100).toStringAsFixed(1)}%";
  }

  static Map<String, dynamic> procesarFormulario(Map<String, String> inputs) {
    Map<String, dynamic> r = {};

    // --- CÁLCULO DE SUMAS PE ---
    r["sum2"] = val(inputs["pe1"]) + val(inputs["pe2"]) + val(inputs["pe3"]) + val(inputs["pe4"]) + val(inputs["pe5"]);
    r["sum3"] = val(inputs["pe6"]) + val(inputs["pe7"]) + val(inputs["pe8"]) + val(inputs["pe9"]) + val(inputs["pe10"]) + val(inputs["pe11"]) + val(inputs["pe12"]);
    r["sum4"] = val(inputs["pe13"]) + val(inputs["pe14"]) + val(inputs["pe15"]);
    r["sum5"] = val(inputs["pe16"]) + val(inputs["pe17"]) + val(inputs["pe18"]) + val(inputs["pe19"]);
    r["sum6"] = val(inputs["pe20"]) + val(inputs["pe21"]) + val(inputs["pe22"]) + val(inputs["pe23"]) + val(inputs["pe24"]) + val(inputs["pe25"]);
    r["sum7"] = val(inputs["pe26"]);
    r["sum1"] = r["sum2"] + r["sum3"] + r["sum4"] + r["sum5"] + r["sum6"] + r["sum7"];

    double sum9 = 0;
    for (int i = 27; i <= 55; i++) { sum9 += val(inputs["pe$i"]); }
    r["sum9"] = sum9;

    double sum10 = 0;
    for (int i = 56; i <= 66; i++) { sum10 += val(inputs["pe$i"]); }
    r["sum10"] = sum10;

    r["sum11"] = val(inputs["pe68"]) + val(inputs["pe69"]) + val(inputs["pe70"]) + val(inputs["pe71"]) + val(inputs["pe72"]);
    r["sum8"] = r["sum9"] + r["sum10"] + r["sum11"];

    r["sum13"] = val(inputs["pe73"]) + val(inputs["pe74"]) + val(inputs["pe75"]);
    r["sum14"] = val(inputs["pe76"]);
    r["sum15"] = val(inputs["pe77"]);
    r["sum16"] = val(inputs["pe78"]) + val(inputs["pe79"]);
    r["sum12"] = r["sum13"] + r["sum14"] + r["sum15"] + r["sum16"];

    double sum18 = 0;
    for (int i = 80; i <= 94; i++) { sum18 += val(inputs["pe$i"]); }
    r["sum18"] = sum18;

    double sum19 = 0;
    for (int i = 95; i <= 101; i++) { sum19 += val(inputs["pe$i"]); }
    r["sum19"] = sum19;
    r["sum17"] = r["sum18"] + r["sum19"];

    r["sum20"] = val(inputs["pe102"]);
    r["sum21"] = val(inputs["pe103"]);
    r["sum22"] = val(inputs["pe104"]);

    double sum23pe = 0;
    for (int i = 105; i <= 111; i++) { sum23pe += val(inputs["pe$i"]); }
    r["sum23_pe_b"] = sum23pe; // Guardamos intermedio para PE de la sección final

    r["totpe"] = r["sum1"] + r["sum8"] + r["sum12"] + r["sum17"] + r["sum20"] + r["sum21"] + r["sum22"] + r["sum23_pe_b"];

    // --- CÁLCULO DE SUMAS PO ---
    r["sum24"] = val(inputs["po1"]) + val(inputs["po2"]) + val(inputs["po3"]) + val(inputs["po4"]) + val(inputs["po5"]);
    r["sum25"] = val(inputs["po6"]) + val(inputs["po7"]) + val(inputs["po8"]) + val(inputs["po9"]) + val(inputs["po10"]) + val(inputs["po11"]) + val(inputs["po12"]);
    r["sum26"] = val(inputs["po13"]) + val(inputs["po14"]) + val(inputs["po15"]);
    r["sum27"] = val(inputs["po16"]) + val(inputs["po17"])+ val(inputs["po18"]) + val(inputs["po19"]);
    r["sum28"] = val(inputs["po20"]) + val(inputs["po21"]) + val(inputs["po22"]) + val(inputs["po23"]) + val(inputs["po24"]) + val(inputs["po25"]);
    r["sum29"] = val(inputs["po26"]);
    r["sum23"] = r["sum24"] + r["sum25"] + r["sum26"] + r["sum27"] + r["sum28"] + r["sum29"];

    double sum31 = 0;
    for (int i = 27; i <= 55; i++) { sum31 += val(inputs["po$i"]); }
    r["sum31"] = sum31;

    double sum32 = 0;
    for (int i = 56; i <= 66; i++) { sum32 += val(inputs["po$i"]); }
    r["sum32"] = sum32;

    r["sum33"] = val(inputs["po68"]) + val(inputs["po69"]) + val(inputs["po70"]) + val(inputs["po71"]) + val(inputs["po72"]);
    r["sum30"] = r["sum31"] + r["sum32"] + r["sum33"];

    r["sum35"] = val(inputs["po73"]) + val(inputs["po74"]) + val(inputs["po75"]);
    r["sum36"] = val(inputs["po76"]);
    r["sum37"] = val(inputs["po77"]);
    r["sum38"] = val(inputs["po78"]) + val(inputs["po79"]);
    r["sum34"] = r["sum35"] + r["sum36"] + r["sum37"] + r["sum38"];

    double sum40 = 0;
    for (int i = 80; i <= 94; i++) { sum40 += val(inputs["po$i"]); }
    r["sum40"] = sum40;

    double sum41 = 0;
    for (int i = 95; i <= 101; i++) { sum41 += val(inputs["po$i"]); }
    r["sum41"] = sum41;
    r["sum39"] = r["sum40"] + r["sum41"];

    r["sum42"] = val(inputs["po102"]);
    r["sum43"] = val(inputs["po103"]);
    r["sum44"] = val(inputs["po104"]);
    r["sum46"] = val(inputs["po105"])+val(inputs["po106"])+val(inputs["po107"])+val(inputs["po108"])+val(inputs["po109"])+val(inputs["po110"])+val(inputs["po111"]);

    double sum45 = 0;
    for (int i = 105; i <= 111; i++) { sum45 += val(inputs["po$i"]); }
    r["sum45"] = sum45;

    r["totpo"] = r["sum23"] + r["sum30"] + r["sum34"] + r["sum39"] + r["sum42"] + r["sum43"] + r["sum44"] + r["sum45"];

    // --- CÁLCULO DE PORCENTAJES (CONVERTIDOS A CADENA PARA ACROFORM) ---
    r["por1"] = porcentaje(r["sum23"], r["sum1"]);
    r["por2"] = porcentaje(r["sum24"], r["sum2"]);
    r["por3"] = porcentaje(r["sum25"], r["sum3"]);
    r["por4"] = porcentaje(r["sum26"], r["sum4"]);
    r["por5"] = porcentaje(r["sum27"], r["sum5"]);
    r["por6"] = porcentaje(r["sum28"], r["sum6"]);
    r["por7"] = porcentaje(r["sum29"], r["sum7"]);
    r["por8"] = porcentaje(r["sum30"], r["sum8"]);
    r["por9"] = porcentaje(r["sum31"], r["sum9"]);
    r["por10"] = porcentaje(r["sum32"], r["sum10"]);
    r["por11"] = porcentaje(r["sum33"], r["sum11"]);
    r["por12"] = porcentaje(r["sum34"], r["sum12"]);
    r["por13"] = porcentaje(r["sum35"], r["sum13"]);
    r["por14"] = porcentaje(r["sum36"], r["sum14"]);
    r["por15"] = porcentaje(r["sum37"], r["sum15"]);
    r["por16"] = porcentaje(r["sum38"], r["sum16"]);
    r["por17"] = porcentaje(r["sum39"], r["sum17"]);
    r["por18"] = porcentaje(r["sum40"], r["sum18"]);
    r["por19"] = porcentaje(r["sum41"], r["sum19"]);
    r["por20"] = porcentaje(r["sum42"], r["sum20"]);
    r["por21"] = porcentaje(r["sum43"], r["sum21"]);
    r["por22"] = porcentaje(r["sum44"], r["sum22"]);
    r["por23"] = porcentaje(r["sum45"], r["sum23_pe_b"]);

    // --- CALIFICACIÓN DE CONFORMIDAD ---
    double totPeVal = r["totpe"];
    double totPoVal = r["totpo"];
    double portotNum = totPeVal > 0 ? (totPoVal / totPeVal) * 100 : 0.0;
    r["portot"] = "${portotNum.toStringAsFixed(1)}%";

    if (portotNum >= 96.0) r["calificacion"] = "EXCELENTE";
    else if (portotNum >= 86.0) r["calificacion"] = "MUY BUENO";
    else if (portotNum >= 76.0) r["calificacion"] = "BUENO";
    else if (portotNum >= 56.0) r["calificacion"] = "REGULAR";
    else r["calificacion"] = "DEFICIENTE";

    // --- MAPEO DIRECTO Y SEPARADO DE LOS CAMPOS MAESTROS ---
    r["fecha"] = inputs["fecha_inspeccion"] ?? "";
    r["hora_inicial"] = inputs["hora_inicial"] ?? "";
    r["hora_final"] = inputs["hora_final"] ?? "";
    r["direccion_establecimiento"] = inputs["direccion_establecimiento"] ?? "";
    r["representante"] = inputs["representante"] ?? "";
    r["representante2"] = inputs["representante"] ?? ""; // Se inyecta la misma variable
    r["inspector"] = inputs["inspector"] ?? "";
    r["inspector2"] = inputs["inspector"] ?? ""; // Se inyecta la misma variable

    // Convertir todos los numéricos internos a string antes de devolverlos
    r.forEach((key, value) {
      if (value is double) r[key] = value.toStringAsFixed(0);
    });

    return r;
  }
}