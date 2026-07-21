import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '/firebase_options.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import '/pdf_download.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// ✅ IMPORTACIÓN AÑADIDA
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:signature/signature.dart' as sig;

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: upper,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

/// ===============================================================
/// 🎨 PALETA (según imagen adjunta)
/// - Naranja: #FF7F00
/// - Verde:   #566B30
/// - Azul:    #003C92
/// ===============================================================
const Color kColorOrange = Color(0xFFFF7F00);
const Color kColorGreen = Color(0xFF566B30);
const Color kColorBlue = Color(0xFF003C92);

/// COLECCIONES
/// - fr024_registros: actas emitidas
/// - fr024_asignaciones: OS asignadas desde PC
/// ===============================================================
const String kAsignacionesCollection = "fr024_asignaciones";

/// ===============================================================
/// LISTA DE INSPECTORES (dropdown)
/// ===============================================================
const List<String> kInspectores = [
  "ANDRES ARENAS",
  "BRYAN RAMOS",
  "JHON VEGA",
  "OLIVER MILLA",
  "VICTOR GIL",
  "SEBASTIAN MASCHACURI",
];

/// ===============================================================
/// Helper: pedir PDF al backend (Cloud Functions) y recibir bytes.
/// ===============================================================
Future<Uint8List> _requestPdfFromBackend(Map<String, dynamic> payload) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("No hay usuario autenticado.");
  }

  final token = await user.getIdToken();

  // ✅ NUEVO: OBTENER URL DESDE FIREBASE REMOTE CONFIG
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    // Usamos cero para que actualice rápido si cambias la URL en la consola
    minimumFetchInterval: Duration.zero, 
  ));
  
  await remoteConfig.fetchAndActivate();
  final baseUrl = remoteConfig.getString('backend_url');

  if (baseUrl.isEmpty) {
    throw Exception("No se encontró la URL del servidor en Firebase.");
  }
  // -------------------------------------------------------------

  final resp = await http.post(
    // ✅ URL DINÁMICA APLICADA AQUÍ
    Uri.parse('$baseUrl/generar-pdf'), 
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode(payload),
  );

  if (resp.statusCode != 200) {
    throw Exception("HTTP ${resp.statusCode}: ${resp.body}");
  }

  return resp.bodyBytes;
}

/// ===============================================================
/// UI (según imágenes)
/// ===============================================================

const double kAppBarTitleSize = 18; // título reducido (~2 puntos)

PreferredSizeWidget _stripedAppBar(
  BuildContext context,
  String title, {
  bool showBack = true,
}) {
  return AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: Colors.black12,
    automaticallyImplyLeading: false,
    leading: showBack
        ? IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
            color: kColorBlue,
            tooltip: "Volver",
          )
        : null,
    titleSpacing: showBack ? 0 : 16,
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: kAppBarTitleSize,
        color: Colors.black,
      ),
    ),
    actions: const [
      Padding(
        padding: EdgeInsets.only(right: 12),
        child: Center(child: _BrandBlocks()),
      ),
    ],
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(8),
      child: _TopStripes(),
    ),
  );
}

/// ✅ Formulario FR024: debe mostrar SOLO las 3 líneas (sin bloques/logo)
PreferredSizeWidget _plainFormAppBar(
  BuildContext context,
  String title, {
  List<Widget>? actions,
}) {
  return AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: Colors.black12,
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: kAppBarTitleSize,
        color: Colors.black,
      ),
    ),
    actions: actions,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(8),
      child: _TopStripes(),
    ),
  );
}

class _BrandBlocks extends StatelessWidget {
  const _BrandBlocks();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _SlantBlock(color: kColorOrange, width: 28),
        SizedBox(width: 6),
        _SlantBlock(color: kColorGreen, width: 34),
        SizedBox(width: 6),
        _SlantBlock(color: kColorBlue, width: 72),
      ],
    );
  }
}

class _SlantBlock extends StatelessWidget {
  final Color color;
  final double width;

  const _SlantBlock({required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      // Compatible (sin skewX)
      transform: Matrix4.identity()..setEntry(0, 1, -0.45),
      child: Container(
        width: width,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

/// ✅ SOLO 3 líneas: naranja, verde, azul (sin la línea extra)
class _TopStripes extends StatelessWidget {
  const _TopStripes();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 3.0, color: kColorOrange),
          const SizedBox(height: 1.5),
          Container(height: 2.2, color: kColorGreen),
          const SizedBox(height: 1.5),
          Container(height: 3.0, color: kColorBlue),
        ],
      ),
    );
  }
}

/// =====================
/// LAUNCHER (2 botones)
/// =====================
class LauncherPage extends StatelessWidget {
  const LauncherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _stripedAppBar(
        context,
        "Verificación de iluminancia",
        showBack: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 20,
                    offset: Offset(0, 10),
                    color: Color(0x14000000),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AsignacionesPage()),
                        );
                      },
                      child: const Text("ASIGNACIONES (OS)"),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RecordsPage()),
                        );
                      },
                      child: const Text("VER ACTAS EMITIDAS"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFECEFF4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: const Text(
                "Nota: El inspector debe ingresar a ASIGNACIONES para seleccionar su OS y generar el FR 024.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 34),
              child: Text(
                "Operaciones - Alimentos",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =====================
/// ASIGNACIONES (OS)
/// =====================
class AsignacionesPage extends StatelessWidget {
  const AsignacionesPage({super.key});

  String _fmtFecha(dynamic v) {
    try {
      if (v == null) return "";
      if (v is Timestamp) {
        return DateFormat("dd/MM/yyyy").format(v.toDate());
      }
      if (v is DateTime) {
        return DateFormat("dd/MM/yyyy").format(v);
      }
      return v.toString();
    } catch (_) {
      return "";
    }
  }

  Future<void> _openAssignmentDialog(
    BuildContext context, {
    required String os,
    required String cliente,
    required String direccionMuestreo,
    Timestamp? fechaMuestreo,
    required String direccionLegal,
    required String asignacionDocId,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("OS seleccionada"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("OS: $os"),
            const SizedBox(height: 6),
            Text("CLIENTE: $cliente"),
            const SizedBox(height: 6),
            Text("F. MUESTREO: ${_fmtFecha(fechaMuestreo)}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("REGRESAR"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FR024FormPage(
                    prefillOs: os,
                    prefillCliente: cliente,
                    prefillDireccionLegal: direccionLegal,
                    prefillLugar: direccionMuestreo,
                    prefillFecha:
                        (fechaMuestreo != null) ? fechaMuestreo.toDate() : null,
                    lockOsCliente: true,
                    asignacionDocId: asignacionDocId,
                  ),
                ),
              );
            },
            child: const Text("GENERAR FR 024"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance.collection(kAsignacionesCollection);

    return Scaffold(
      appBar: _stripedAppBar(context, "Asignaciones (OS)"),
      body: StreamBuilder<QuerySnapshot>(
        stream: q.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text("No hay OS asignadas en Firestore."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = (docs[i].data() as Map).cast<String, dynamic>();
              final asignacionDocId = docs[i].id;

              final os = (d["os"] ?? "").toString();
              final cliente = (d["cliente"] ?? "").toString();

              final direccionMuestreo = (d["direccion_muestreo"] ??
                      d["lugar_muestreo"] ??
                      d["lugar"] ??
                      "")
                  .toString();

              final direccionLegal = (d["direccion_legal"] ?? "").toString();

              final fecha = d["fecha_muestreo"];
              Timestamp? fechaTs = (fecha is Timestamp) ? fecha : null;

              final fechaTxt = _fmtFecha(fecha);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 18,
                      offset: Offset(0, 10),
                      color: Color(0x12000000),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => _openAssignmentDialog(
                    context,
                    os: os,
                    cliente: cliente,
                    direccionMuestreo: direccionMuestreo,
                    fechaMuestreo: fechaTs,
                    direccionLegal: direccionLegal,
                    asignacionDocId: asignacionDocId,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 12,
                          height: 62,
                          decoration: BoxDecoration(
                            color: kColorBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "OS: $os",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "CLIENTE: $cliente",
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.75),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "F. MUESTREO: $fechaTxt",
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: kColorBlue),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ===================== MODELOS =====================

class EquipmentProfile {
  final String code;
  final double factor;
  final double offset;

  const EquipmentProfile({
    required this.code,
    required this.factor,
    required this.offset,
  });

  double corrected(double inSitu) => (inSitu * factor) + offset;
}

const List<EquipmentProfile> kEquipos = [
  EquipmentProfile(
      code: "EQUI-ITS-LUX-01", factor: 1.06437267, offset: -5.03389282),
  EquipmentProfile(
      code: "EQUI-ITS-LUX-03", factor: 1.04865710, offset: -7.27454069),
  EquipmentProfile(
      code: "EQUI-ITS-LUX-04", factor: 1.03889055, offset: -18.53728107),
];

const List<String> kTiposArea = [
  "Sala de Producción",
  "Zona de examen detallado",
  "Otras zonas",
];

class AreaRowModel {
  final TextEditingController areaCtrl = TextEditingController();
  final TextEditingController lecturaCtrl = TextEditingController();
  final TextEditingController obsCtrl = TextEditingController();

  String tipo = kTiposArea.first;
  String lecturaCorregida = "-";

  void dispose() {
    areaCtrl.dispose();
    lecturaCtrl.dispose();
    obsCtrl.dispose();
  }

  Map<String, dynamic> toFirestore() => {
        "area": areaCtrl.text.trim(),
        "lectura_in_situ": lecturaCtrl.text.trim(),
        "lectura_corregida": lecturaCorregida,
        "tipo_area": tipo,
        "observacion": obsCtrl.text.trim(),
      };

  Map<String, dynamic> toDraft() => {
        "area": areaCtrl.text,
        "lectura": lecturaCtrl.text,
        "obs": obsCtrl.text,
        "tipo": tipo,
        "corr": lecturaCorregida,
      };

  void loadDraft(Map<String, dynamic> m) {
    areaCtrl.text = (m["area"] ?? "").toString();
    lecturaCtrl.text = (m["lectura"] ?? "").toString();
    obsCtrl.text = (m["obs"] ?? "").toString();
    tipo = (m["tipo"] ?? kTiposArea.first).toString();
    lecturaCorregida = (m["corr"] ?? "-").toString();
  }
}

// ===================== DRAFT STORAGE =====================

class _DraftStore {
  static const String key = "draft_fr024_v3";

  static Future<void> save(Map<String, dynamic> jsonMap) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, jsonEncode(jsonMap));
  }

  static Future<Map<String, dynamic>?> load() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(key);
    if (s == null) return null;
    try {
      return (jsonDecode(s) as Map).cast<String, dynamic>();
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(key);
  }
}

// ===================== FORM =====================

class FR024FormPage extends StatefulWidget {
  final String? prefillOs;
  final String? prefillCliente;

  /// ✅ Dirección legal (solo referencia, no editable, sí se guarda en Firestore)
  final String? prefillDireccionLegal;

  final String? prefillLugar;
  final DateTime? prefillFecha;

  final bool lockOsCliente;
  final String? asignacionDocId;

  const FR024FormPage({
    super.key,
    this.prefillOs,
    this.prefillCliente,
    this.prefillDireccionLegal,
    this.prefillLugar,
    this.prefillFecha,
    this.lockOsCliente = false,
    this.asignacionDocId,
  });

  @override
  State<FR024FormPage> createState() => _FR024FormPageState();
}

class _FR024FormPageState extends State<FR024FormPage>
    with WidgetsBindingObserver {
  final osCtrl = TextEditingController();
  DateTime? fechaMuestreo;
  final clienteCtrl = TextEditingController();
  final direccionLegalCtrl = TextEditingController();
  final lugarCtrl = TextEditingController();

  final String equipoFijo = "LUXOMETRO";
  EquipmentProfile equipoSel = kEquipos.first;

  int nAreas = 1;
  final List<AreaRowModel> areas = [];

  String? inspectorSel;
  final clienteNombreCtrl = TextEditingController();

  late final sig.SignatureController firmaInspectorCtrl;
  late final sig.SignatureController firmaClienteCtrl;

  bool bloqueado = false;

  Timer? _debounce;
  String? _asignacionDocId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _asignacionDocId = widget.asignacionDocId;

    firmaInspectorCtrl = sig.SignatureController(
      penStrokeWidth: 2.2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    firmaClienteCtrl = sig.SignatureController(
      penStrokeWidth: 2.2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    _setAreasCount(1);

    if ((widget.prefillOs ?? "").trim().isNotEmpty) {
      osCtrl.text = widget.prefillOs!.trim();
    }
    if ((widget.prefillCliente ?? "").trim().isNotEmpty) {
      clienteCtrl.text = widget.prefillCliente!.trim();
    }
    if ((widget.prefillDireccionLegal ?? "").trim().isNotEmpty) {
      direccionLegalCtrl.text = widget.prefillDireccionLegal!.trim();
    }
    if ((widget.prefillLugar ?? "").trim().isNotEmpty) {
      lugarCtrl.text = widget.prefillLugar!.trim();
    }
    if (widget.prefillFecha != null) {
      fechaMuestreo = widget.prefillFecha;
    }

    for (final c in [osCtrl, clienteCtrl, lugarCtrl, clienteNombreCtrl]) {
      c.addListener(_scheduleDraftSave);
    }

    Future.microtask(_loadDraftIfAny);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();

    osCtrl.dispose();
    clienteCtrl.dispose();
    direccionLegalCtrl.dispose();
    lugarCtrl.dispose();
    clienteNombreCtrl.dispose();

    firmaInspectorCtrl.dispose();
    firmaClienteCtrl.dispose();

    for (final a in areas) {
      a.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveDraft();
    }
  }

  void _setAreasCount(int count) {
    final target = count.clamp(1, 50);

    while (areas.length < target) {
      final model = AreaRowModel();
      model.lecturaCtrl.addListener(() {
        _recalcArea(model);
        _scheduleDraftSave();
      });
      model.areaCtrl.addListener(_scheduleDraftSave);
      model.obsCtrl.addListener(_scheduleDraftSave);
      areas.add(model);
    }

    while (areas.length > target) {
      final last = areas.removeLast();
      last.dispose();
    }

    nAreas = target;
  }

  void _recalcArea(AreaRowModel a) {
    final txt = a.lecturaCtrl.text.trim();
    if (txt.isEmpty) {
      a.lecturaCorregida = "-";
      setState(() {});
      return;
    }
    final v = double.tryParse(txt.replaceAll(",", "."));
    if (v == null) {
      a.lecturaCorregida = "-";
      setState(() {});
      return;
    }
    final corr = equipoSel.corrected(v);
    a.lecturaCorregida = corr.toStringAsFixed(2);
    setState(() {});
  }

  void _recalcAll() {
    for (final a in areas) {
      _recalcArea(a);
    }
  }

  void _scheduleDraftSave() {
    if (bloqueado) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _saveDraft);
  }

  Future<void> _saveDraft() async {
    if (bloqueado) return;

    final draft = <String, dynamic>{
      "os": osCtrl.text,
      "fecha": fechaMuestreo?.millisecondsSinceEpoch,
      "cliente": clienteCtrl.text,
      "direccion_legal": direccionLegalCtrl.text,
      "lugar": lugarCtrl.text,
      "equipo_code": equipoSel.code,
      "nAreas": nAreas,
      "areas": areas.map((e) => e.toDraft()).toList(),
      "inspNombre": inspectorSel ?? "",
      "cliNombre": clienteNombreCtrl.text,
      "firmaInspectorPoints": _serializePoints(firmaInspectorCtrl.points),
      "firmaClientePoints": _serializePoints(firmaClienteCtrl.points),
      "asignacionDocId": _asignacionDocId ?? "",
    };
    await _DraftStore.save(draft);
  }

  Future<void> _loadDraftIfAny() async {
    final d = await _DraftStore.load();
    if (d == null) return;

    final incomingOs = (widget.prefillOs ?? "").trim();
    if (incomingOs.isNotEmpty) {
      final draftOs = (d["os"] ?? "").toString().trim();
      if (draftOs.isNotEmpty && draftOs != incomingOs) return;
    }

    final draftAsignId = (d["asignacionDocId"] ?? "").toString().trim();
    if ((_asignacionDocId ?? "").trim().isEmpty && draftAsignId.isNotEmpty) {
      _asignacionDocId = draftAsignId;
    }

    osCtrl.text = (d["os"] ?? "").toString();

    final ms = d["fecha"];
    if (ms is int) {
      fechaMuestreo = DateTime.fromMillisecondsSinceEpoch(ms);
    }

    clienteCtrl.text = (d["cliente"] ?? "").toString();
    direccionLegalCtrl.text = (d["direccion_legal"] ?? "").toString();
    lugarCtrl.text = (d["lugar"] ?? "").toString();

    final code = (d["equipo_code"] ?? kEquipos.first.code).toString();
    equipoSel = kEquipos.firstWhere(
      (e) => e.code == code,
      orElse: () => kEquipos.first,
    );

    final na = (d["nAreas"] is int) ? d["nAreas"] as int : 1;
    _setAreasCount(na);

    final listAreas = (d["areas"] is List) ? (d["areas"] as List) : [];
    for (int i = 0; i < areas.length; i++) {
      if (i < listAreas.length && listAreas[i] is Map) {
        areas[i].loadDraft((listAreas[i] as Map).cast<String, dynamic>());
      }
      _recalcArea(areas[i]);
    }

    inspectorSel = (d["inspNombre"] ?? "").toString().trim();
    if (inspectorSel != null && inspectorSel!.isEmpty) inspectorSel = null;

    clienteNombreCtrl.text = (d["cliNombre"] ?? "").toString();

    final p1 = d["firmaInspectorPoints"];
    final p2 = d["firmaClientePoints"];
    if (p1 is List) firmaInspectorCtrl.points = _deserializePoints(p1);
    if (p2 is List) firmaClienteCtrl.points = _deserializePoints(p2);

    if ((widget.prefillOs ?? "").trim().isNotEmpty) {
      osCtrl.text = widget.prefillOs!.trim();
    }
    if ((widget.prefillCliente ?? "").trim().isNotEmpty) {
      clienteCtrl.text = widget.prefillCliente!.trim();
    }
    if ((widget.prefillDireccionLegal ?? "").trim().isNotEmpty) {
      direccionLegalCtrl.text = widget.prefillDireccionLegal!.trim();
    }
    if (fechaMuestreo == null && widget.prefillFecha != null) {
      fechaMuestreo = widget.prefillFecha;
    }
    if (lugarCtrl.text.trim().isEmpty &&
        (widget.prefillLugar ?? "").trim().isNotEmpty) {
      lugarCtrl.text = widget.prefillLugar!.trim();
    }

    if (mounted) setState(() {});
  }

  Future<bool> _onWillPop() async {
    await _saveDraft();
    return true;
  }

  String _fechaLabel() {
    if (fechaMuestreo == null) return "Seleccionar fecha (calendario)";
    return DateFormat("dd/MM/yyyy").format(fechaMuestreo!);
  }

  Future<void> _pickDate() async {
    if (bloqueado) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaMuestreo ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => fechaMuestreo = picked);
      _scheduleDraftSave();
    }
  }

  Future<void> _guardarBloquear() async {
    if (bloqueado) return;

    if (osCtrl.text.trim().isEmpty ||
        fechaMuestreo == null ||
        clienteCtrl.text.trim().isEmpty ||
        lugarCtrl.text.trim().isEmpty ||
        (inspectorSel ?? "").trim().isEmpty ||
        clienteNombreCtrl.text.trim().isEmpty) {
      _toast("Completa OS, Fecha, Cliente, Lugar, y Nombres.");
      return;
    }

    for (int i = 0; i < areas.length; i++) {
      if (areas[i].lecturaCtrl.text.trim().isEmpty) {
        _toast("Falta Lectura in situ en Área ${i + 1}");
        return;
      }
    }

    if (firmaInspectorCtrl.isEmpty || firmaClienteCtrl.isEmpty) {
      _toast("Faltan firmas.");
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      final doc = <String, dynamic>{
        "os": osCtrl.text.trim(),
        "fecha_muestreo": Timestamp.fromDate(fechaMuestreo!),
        "cliente": clienteCtrl.text.trim(),
        "direccion_legal": direccionLegalCtrl.text.trim(),
        "lugar_muestreo": lugarCtrl.text.trim(),
        "equipo": equipoFijo,
        "codigo_equipo": equipoSel.code,
        "inspector_nombre": (inspectorSel ?? "").trim(),
        "cliente_nombre": clienteNombreCtrl.text.trim(),
        "areas": areas.map((e) => e.toFirestore()).toList(),
        "firma_inspector_points": _serializePoints(firmaInspectorCtrl.points),
        "firma_cliente_points": _serializePoints(firmaClienteCtrl.points),
        "bloqueado": true,
        "createdAt": FieldValue.serverTimestamp(),
        "uid": uid,
      };

      final fs = FirebaseFirestore.instance;
      final batch = fs.batch();

      final regRef = fs.collection("fr024_registros").doc();
      batch.set(regRef, doc);

      final asignId = (_asignacionDocId ?? "").trim();
      if (asignId.isNotEmpty) {
        final asigRef = fs.collection(kAsignacionesCollection).doc(asignId);
        batch.delete(asigRef);
      } else {
        final os = osCtrl.text.trim();
        if (os.isNotEmpty) {
          final q = await fs
              .collection(kAsignacionesCollection)
              .where("os", isEqualTo: os)
              .limit(1)
              .get();
          for (final ad in q.docs) {
            batch.delete(ad.reference);
          }
        }
      }

      await batch.commit();

      setState(() => bloqueado = true);
      await _DraftStore.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Información registrada correctamente.")),
      );
    } catch (e) {
      _toast("❌ No se pudo guardar la información $e");
    }
  }

Future<void> _generarPdfYAbrir() async {
  try {
    final bytes = await _buildPdfBytesFromCurrent();

    // ✅ SOLO PARA WEB: descarga el PDF (no existe getApplicationDocumentsDirectory en navegador)
    if (kIsWeb) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      await downloadPdfBytes(bytes, "FR024_$ts.pdf");
      return;
    }

    // ✅ ANDROID (igual que tu código actual)
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final file = File("${dir.path}/FR024_$ts.pdf");
    await file.writeAsBytes(bytes);

    await OpenFilex.open(file.path);
  } catch (e) {
    _toast("❌ Error generando PDF: $e");
  }
}

  Future<Uint8List> _buildPdfBytesFromCurrent() async {
    if (fechaMuestreo == null) {
      throw Exception("Falta fecha de muestreo.");
    }

    final inspPng = await firmaInspectorCtrl.toPngBytes();
    final cliPng = await firmaClienteCtrl.toPngBytes();
    if (inspPng == null || cliPng == null) {
      throw Exception("No se pudo exportar firma a PNG.");
    }

    final payload = <String, dynamic>{
      "os": osCtrl.text.trim(),
      "fecha": DateFormat("dd/MM/yyyy").format(fechaMuestreo!),
      "cliente": clienteCtrl.text.trim(),
      // ⚠️ direccion_legal NO va al PDF
      "lugar": lugarCtrl.text.trim(),
      "equipo": equipoFijo,
      "codigoEquipo": equipoSel.code,
      "inspectorNombre": (inspectorSel ?? "").trim(),
      "clienteNombre": clienteNombreCtrl.text.trim(),
      "areas": areas
          .map((a) => {
                "area": a.areaCtrl.text.trim(),
                "lecturaInSitu": a.lecturaCtrl.text.trim(),
                "lecturaCorregida": a.lecturaCorregida,
                "tipo": a.tipo,
                "obs": a.obsCtrl.text.trim(),
              })
          .toList(),
      "firmaInspectorPngBase64": base64Encode(inspPng),
      "firmaClientePngBase64": base64Encode(cliPng),
    };

    return _requestPdfFromBackend(payload);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final disabled = bloqueado;
    final lockOsCliente = widget.lockOsCliente;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // ✅ Con líneas (3 colores) en el formulario
        appBar: _plainFormAppBar(
          context,
          "FR024 - Verificación de iluminancia",
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generarPdfYAbrir,
              tooltip: "Generar PDF y abrir",
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: osCtrl,
              enabled: (!disabled) && (!lockOsCliente),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              decoration: const InputDecoration(
                labelText: "OS N°",
              ),
            ),
            const SizedBox(height: 12),
            const Text("Fecha de muestreo"),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: disabled ? null : _pickDate,
                child: Text(_fechaLabel()),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: clienteCtrl,
              enabled: (!disabled) && (!lockOsCliente),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              decoration: const InputDecoration(
                labelText: "Cliente",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: direccionLegalCtrl,
              enabled: false,
              decoration: InputDecoration(
                labelText: "Dirección legal (referencia)",
                filled: true,
                fillColor: kColorBlue.withOpacity(0.05),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lugarCtrl,
              enabled: !disabled,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              decoration: const InputDecoration(
                labelText: "Lugar de muestreo",
              ),
            ),
            const SizedBox(height: 18),
            const Text("Equipo", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Equipo (fijo)\n$equipoFijo"),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: "Código de equipo",
                border: UnderlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<EquipmentProfile>(
                  isExpanded: true,
                  value: equipoSel,
                  onChanged: disabled
                      ? null
                      : (v) {
                          if (v == null) return;
                          setState(() => equipoSel = v);
                          _recalcAll();
                          _scheduleDraftSave();
                        },
                  items: kEquipos
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.code),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text("Número de áreas",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            InputDecorator(
              decoration: InputDecoration(
                labelText: "Selecciona cuántas áreas inspeccionar",
                border: const UnderlineInputBorder(),
                filled: true,
                fillColor: kColorGreen.withOpacity(0.14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: nAreas,
                  onChanged: disabled
                      ? null
                      : (v) {
                          if (v == null) return;
                          setState(() => _setAreasCount(v));
                          _scheduleDraftSave();
                        },
                  items: List.generate(50, (i) => i + 1)
                      .map((v) => DropdownMenuItem(value: v, child: Text("$v")))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Áreas", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...List.generate(areas.length, (i) {
              final a = areas[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Área ${i + 1}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          )),
                      const SizedBox(height: 10),
                      TextField(
                        controller: a.areaCtrl,
                        enabled: !disabled,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [UpperCaseTextFormatter()],
                        decoration: InputDecoration(
                          labelText: "Áreas inspeccionadas (nombre)",
                          filled: true,
                          fillColor: kColorGreen.withOpacity(0.14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: a.lecturaCtrl,
                              enabled: !disabled,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [_TwoDecimalsFormatter()],
                              decoration: const InputDecoration(
                                labelText: "Lectura in situ (Lux)",
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Lectura corregida (Lux)",
                                border: UnderlineInputBorder(),
                              ),
                              child: Text(a.lecturaCorregida),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Tipo de área de trabajo",
                          border: UnderlineInputBorder(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: a.tipo,
                            onChanged: disabled
                                ? null
                                : (v) {
                                    if (v == null) return;
                                    setState(() => a.tipo = v);
                                    _scheduleDraftSave();
                                  },
                            items: kTiposArea
                                .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: a.obsCtrl,
                        enabled: !disabled,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [UpperCaseTextFormatter()],
                        decoration: const InputDecoration(
                          labelText: "Observaciones (opcional)",
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            const Text("Firmas", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _SignatureBox(
              title: "Firma del Inspector",
              controller: firmaInspectorCtrl,
              enabled: !disabled,
              onClear: () {
                if (disabled) return;
                firmaInspectorCtrl.clear();
                _scheduleDraftSave();
              },
            ),
            const SizedBox(height: 12),
            _SignatureBox(
              title: "Firma del Cliente",
              controller: firmaClienteCtrl,
              enabled: !disabled,
              onClear: () {
                if (disabled) return;
                firmaClienteCtrl.clear();
                _scheduleDraftSave();
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: (inspectorSel != null && kInspectores.contains(inspectorSel))
                  ? inspectorSel
                  : null,
              items: kInspectores
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: disabled
                  ? null
                  : (v) {
                      setState(() => inspectorSel = v);
                      _scheduleDraftSave();
                    },
              decoration: const InputDecoration(
                labelText: "Nombre del Inspector",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: clienteNombreCtrl,
              enabled: !disabled,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              decoration: const InputDecoration(
                labelText: "Nombre del Cliente",
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: disabled ? null : _guardarBloquear,
                child: const Text("GUARDAR (Bloquear edición)"),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                // ✅ Botón PDF en verde (según pedido)
                style: OutlinedButton.styleFrom(
                  backgroundColor: kColorGreen,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: kColorGreen, width: 1.2),
                ),
                onPressed: _generarPdfYAbrir,
                child: const Text("GENERAR PDF Y ABRIR"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== SIGNATURE BOX =====================

class _SignatureBox extends StatelessWidget {
  final String title;
  final sig.SignatureController controller;
  final bool enabled;
  final VoidCallback onClear;

  const _SignatureBox({
    required this.title,
    required this.controller,
    required this.enabled,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Container(
          height: 240,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withOpacity(0.18)),
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AbsorbPointer(
              absorbing: !enabled,
              child: sig.Signature(
                controller: controller,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: enabled ? onClear : null,
          child: const Text("Limpiar"),
        ),
      ],
    );
  }
}

// ===================== INPUT FORMATTER 2 DECIMALES =====================

class _TwoDecimalsFormatter extends TextInputFormatter {
  final _reg = RegExp(r'^\d{0,7}([.,]\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final t = newValue.text;
    if (t.isEmpty) return newValue;
    if (_reg.hasMatch(t)) return newValue;
    return oldValue;
  }
}

// ===================== RECORDS LIST =====================

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final TextEditingController _osSearchCtrl = TextEditingController();
  String _q = "";

  @override
  void dispose() {
    _osSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _genPdfFromFirestore(BuildContext context, String docId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("fr024_registros")
          .doc(docId)
          .get();

      if (!snap.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No existe el registro.")),
        );
        return;
      }

      final d = snap.data()!;
      final ts = d["fecha_muestreo"] as Timestamp;
      final fecha = ts.toDate();

      final areasRaw = (d["areas"] is List) ? (d["areas"] as List) : [];
      final areasFixed = areasRaw.map((e) {
        final m = (e as Map).cast<String, dynamic>();
        return {
          "area": (m["area"] ?? "").toString(),
          "lecturaInSitu":
              (m["lectura_in_situ"] ?? m["lecturaInSitu"] ?? "").toString(),
          "lecturaCorregida": (m["lectura_corregida"] ??
                  m["lecturaCorregida"] ??
                  "")
              .toString(),
          "tipo": (m["tipo_area"] ?? m["tipo"] ?? "").toString(),
          "obs": (m["observacion"] ?? m["obs"] ?? "").toString(),
        };
      }).toList();

      Uint8List? inspPng;
      Uint8List? cliPng;

      final inspPointsRaw = d["firma_inspector_points"];
      final cliPointsRaw = d["firma_cliente_points"];

      if (inspPointsRaw is List) {
        final c = sig.SignatureController(
          penStrokeWidth: 2.2,
          penColor: Colors.black,
          exportBackgroundColor: Colors.white,
        );
        c.points = _deserializePoints(inspPointsRaw);
        inspPng = await c.toPngBytes();
        c.dispose();
      }

      if (cliPointsRaw is List) {
        final c = sig.SignatureController(
          penStrokeWidth: 2.2,
          penColor: Colors.black,
          exportBackgroundColor: Colors.white,
        );
        c.points = _deserializePoints(cliPointsRaw);
        cliPng = await c.toPngBytes();
        c.dispose();
      }

      if (inspPng == null || cliPng == null) {
        throw Exception("No se pudo reconstruir firmas en PNG.");
      }

      final payload = <String, dynamic>{
        "os": (d["os"] ?? "").toString(),
        "fecha": DateFormat("dd/MM/yyyy").format(fecha),
        "cliente": (d["cliente"] ?? "").toString(),
        "lugar": (d["lugar_muestreo"] ?? d["lugar"] ?? "").toString(),
        "equipo": (d["equipo"] ?? "LUXOMETRO").toString(),
        "codigoEquipo": (d["codigo_equipo"] ?? d["codigoEquipo"] ?? "")
            .toString(),
        "inspectorNombre":
            (d["inspector_nombre"] ?? d["inspectorNombre"] ?? "").toString(),
        "clienteNombre":
            (d["cliente_nombre"] ?? d["clienteNombre"] ?? "").toString(),
        "areas": areasFixed,
        "firmaInspectorPngBase64": base64Encode(inspPng),
        "firmaClientePngBase64": base64Encode(cliPng),
      };



      final bytes = await _requestPdfFromBackend(payload);

    // ✅ SOLO WEB: descarga el PDF (en navegador no existe path_provider)
    final tsName = DateTime.now().millisecondsSinceEpoch;
    final fileName = "FR024_${payload["os"]}_$tsName.pdf";
    if (kIsWeb) {
      await downloadPdfBytes(bytes, fileName);
      return;
    }

    // ✅ ANDROID (igual que antes)
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName");
    await file.writeAsBytes(bytes);

    await OpenFilex.open(file.path);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error generando PDF: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection("fr024_registros")
        .orderBy("createdAt", descending: true);

    return Scaffold(
      appBar: _stripedAppBar(context, "Actas emitidas"),
      body: StreamBuilder<QuerySnapshot>(
        stream: q.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          final query = _q.trim().toUpperCase();
          final filtered = (query.isEmpty)
              ? docs
              : docs.where((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final os = (d["os"] ?? "").toString().toUpperCase();
                  return os.contains(query);
                }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: TextField(
                  controller: _osSearchCtrl,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [UpperCaseTextFormatter()],
                  onChanged: (v) => setState(() => _q = v),
                  decoration: InputDecoration(
                    labelText: "Buscar OS",
                    prefixIcon: const Icon(Icons.search, color: kColorBlue),
                    suffixIcon: (_osSearchCtrl.text.trim().isEmpty)
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear, color: kColorBlue),
                            onPressed: () {
                              _osSearchCtrl.clear();
                              setState(() => _q = "");
                            },
                          ),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text("No hay registros con esa OS."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final d = filtered[i].data() as Map<String, dynamic>;
                          final docId = filtered[i].id;

                          final os = (d["os"] ?? "").toString();
                          final cliente = (d["cliente"] ?? "").toString();

                          final ts = d["fecha_muestreo"];
                          String fecha = "";
                          if (ts is Timestamp) {
                            fecha =
                                DateFormat("dd/MM/yyyy").format(ts.toDate());
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.06)),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                  color: Color(0x12000000),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "OS: $os",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Fecha: $fecha",
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.70),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Cliente: $cliente",
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.70),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      // ✅ Botón PDF en verde
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kColorGreen,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () =>
                                          _genPdfFromFirestore(context, docId),
                                      icon: const Icon(Icons.picture_as_pdf),
                                      label: const Text("GENERAR PDF Y ABRIR"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ===================== SERIALIZACIÓN DE PUNTOS (SIN NULLS) =====================

List<Map<String, dynamic>> _serializePoints(List<sig.Point> points) {
  return points.map((p) {
    return {
      "x": p.offset.dx,
      "y": p.offset.dy,
      "t": p.type.index,
      "p": p.pressure,
    };
  }).toList();
}

List<sig.Point> _deserializePoints(List raw) {
  final out = <sig.Point>[];
  for (final e in raw) {
    if (e == null) continue;
    final m = (e as Map).cast<String, dynamic>();
    final x = (m["x"] as num?)?.toDouble() ?? 0.0;
    final y = (m["y"] as num?)?.toDouble() ?? 0.0;
    final t = (m["t"] as num?)?.toInt() ?? 0;
    final p = (m["p"] as num?)?.toDouble() ?? 1.0;

    final type = sig.PointType
        .values[t.clamp(0, sig.PointType.values.length - 1)];
    out.add(sig.Point(Offset(x, y), type, p));
  }
  return out;
}