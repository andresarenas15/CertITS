import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'models.dart';
import 'data_checklist.dart';
import 'calculos_helper.dart'; 

const Color kColorGreen = Color(0xFF566B30);
const Color kColorBlue = Color(0xFF003C92);

const String kInspeccionAsignacionesCol = "inspeccion_asignaciones";
const String kInspeccionRegistrosCol = "inspeccion_registros";

class InspeccionLauncherPage extends StatelessWidget {
  const InspeccionLauncherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inspección Sanitaria", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
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
                  BoxShadow(blurRadius: 20, offset: Offset(0, 10), color: Color(0x14000000)),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kColorGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const InspeccionAsignacionesPage()));
                      },
                      child: const Text("ASIGNACIONES (OS)", style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kColorGreen,
                        side: const BorderSide(color: kColorGreen, width: 1.4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const InspeccionRecordsPage()));
                      },
                      child: const Text("VER ACTAS EMITIDAS", style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InspeccionAsignacionesPage extends StatelessWidget {
  const InspeccionAsignacionesPage({super.key});

  String _fmtFecha(dynamic v) {
    if (v == null) return "";
    if (v is Timestamp) return DateFormat("dd/MM/yyyy").format(v.toDate());
    return v.toString();
  }

  Future<void> _openAssignmentDialog(
    BuildContext context, {
    required String os,
    required String cliente,
    required String lugar,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("REGRESAR", style: TextStyle(color: kColorGreen)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kColorGreen, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InspeccionFormPage(
                    prefillOs: os,
                    prefillCliente: cliente,
                    prefillLugar: lugar,
                    prefillDireccionLegal: direccionLegal,
                    asignacionDocId: asignacionDocId,
                  ),
                ),
              );
            },
            child: const Text("LLENAR CHECKLIST"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance.collection(kInspeccionAsignacionesCol);

    return Scaffold(
      appBar: AppBar(title: const Text("Asignaciones (OS)"), backgroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text("Error: ${snap.error}"));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No hay OS asignadas."));

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final docId = docs[i].id;
              
              final os = (d["os"] ?? "").toString();
              final cliente = (d["cliente"] ?? "").toString();
              final lugar = (d["lugar"] ?? "").toString();
              final dirLegal = (d["direccion_legal"] ?? "").toString();
              final fechaTxt = _fmtFecha(d["fecha_inspeccion"]);

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.black.withOpacity(0.06))),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(width: 8, height: double.infinity, color: kColorGreen),
                  title: Text("OS: $os", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Cliente: $cliente\nF. Inspección: $fechaTxt"),
                  trailing: const Icon(Icons.chevron_right, color: kColorGreen),
                  onTap: () => _openAssignmentDialog(
                    context,
                    os: os,
                    cliente: cliente,
                    lugar: lugar,
                    direccionLegal: dirLegal,
                    asignacionDocId: docId,
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

class InspeccionFormPage extends StatefulWidget {
  final String prefillOs;
  final String prefillCliente;
  final String prefillLugar;
  final String prefillDireccionLegal;
  final String asignacionDocId;

  const InspeccionFormPage({
    super.key,
    required this.prefillOs,
    required this.prefillCliente,
    required this.prefillLugar,
    required this.prefillDireccionLegal,
    required this.asignacionDocId,
  });

  @override
  State<InspeccionFormPage> createState() => _InspeccionFormPageState();
}

class _InspeccionFormPageState extends State<InspeccionFormPage> {
  final ImagePicker _picker = ImagePicker();
  bool bloqueado = false;
  bool _estaCargando = false;

  final establecimientoCtrl = TextEditingController();
  final rubroCtrl = TextEditingController();
  final fechaCtrl = TextEditingController();
  final horaInitCtrl = TextEditingController();
  final horaFinCtrl = TextEditingController();
  late final TextEditingController lugarCtrl;
  final repCtrl = TextEditingController();
  
  final autCtrl = TextEditingController();
  final sanCtrl = TextEditingController(text: "-");
  final limpCtrl = TextEditingController(text: "-");
  final equi1Ctrl = TextEditingController();
  final equi2Ctrl = TextEditingController();
  
  final obsGenCtrl = TextEditingController();
  final nombreRepCtrl = TextEditingController();

  String? inspectorSel;
  final List<String> inspectores = [
    "ANDRES ARENAS", "OLIVER MILLA", "BRYAN RAMOS", 
    "JHON VEGA", "VICTOR GIL", "HECTOR SANDOVAL", "MARCO CARRASCO"
  ];

  final SignatureController _firmaIns = SignatureController(penStrokeWidth: 3, penColor: Colors.black);
  final SignatureController _firmaRep = SignatureController(penStrokeWidth: 3, penColor: Colors.black);

  // NUEVO: Mapa para gestionar el array de fotos por cada pregunta
  Map<String, List<String>> _fotosBorrador = {};

  @override
  void initState() {
    super.initState();
    lugarCtrl = TextEditingController(text: widget.prefillLugar);
    _cargarBorrador();
  }

  // --- LOGICA DE BORRADOR (AUTOGUARDADO) ---
  Future<void> _cargarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      establecimientoCtrl.text = prefs.getString("draft_est_${widget.prefillOs}") ?? "";
      rubroCtrl.text = prefs.getString("draft_rubro_${widget.prefillOs}") ?? "";
      fechaCtrl.text = prefs.getString("draft_fecha_${widget.prefillOs}") ?? "";
      horaInitCtrl.text = prefs.getString("draft_horainit_${widget.prefillOs}") ?? "";
      horaFinCtrl.text = prefs.getString("draft_horafin_${widget.prefillOs}") ?? "";
      repCtrl.text = prefs.getString("draft_rep_${widget.prefillOs}") ?? "";
      autCtrl.text = prefs.getString("draft_aut_${widget.prefillOs}") ?? "";
      sanCtrl.text = prefs.getString("draft_san_${widget.prefillOs}") ?? "-";
      limpCtrl.text = prefs.getString("draft_limp_${widget.prefillOs}") ?? "-";
      equi1Ctrl.text = prefs.getString("draft_equi1_${widget.prefillOs}") ?? "";
      equi2Ctrl.text = prefs.getString("draft_equi2_${widget.prefillOs}") ?? "";
      obsGenCtrl.text = prefs.getString("draft_obsgen_${widget.prefillOs}") ?? "";
      nombreRepCtrl.text = prefs.getString("draft_nombrerep_${widget.prefillOs}") ?? "";
      inspectorSel = prefs.getString("draft_inspector_${widget.prefillOs}");

      for (var sec in checklistDatos) {
        for (var subsec in sec.subsecciones) {
          for (var p in subsec.preguntas) {
            p.estado = prefs.getString("draft_q_${p.id}_${widget.prefillOs}") ?? "";
            p.obsCtrl.text = prefs.getString("draft_obsq_${p.id}_${widget.prefillOs}") ?? "";
            
            // Cargar listado de fotos (Array)
            String fotosJson = prefs.getString("draft_fotos_${p.id}_${widget.prefillOs}") ?? "[]";
            List<dynamic> decodificado = jsonDecode(fotosJson);
            _fotosBorrador[p.id] = decodificado.map((e) => e.toString()).toList();
          }
        }
      }
    });
  }

  Future<void> _guardarDatoBorrador(String key, String value) async {
    if (bloqueado) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("draft_${key}_${widget.prefillOs}", value);
  }

  Future<void> _limpiarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.endsWith("_${widget.prefillOs}")).toList();
    for (String key in keys) {
      await prefs.remove(key);
    }
  }
  // -----------------------------------------

  // --- LOGICA DE VISTA PREVIA ---
  void _mostrarVistaPrevia() {
    double totPe = 0;
    double totPo = 0;
    List<String> noCumplen = [];

    for (var sec in checklistDatos) {
      for (var subsec in sec.subsecciones) {
        for (var p in subsec.preguntas) {
          if (p.estado.isEmpty || p.estado == 'NO APLICA') continue;

          double peVal = double.tryParse(p.displayPe) ?? 0.0;
          double poVal = double.tryParse(p.displayPo) ?? 0.0;
          totPe += peVal;
          totPo += poVal;

          if (p.estado == 'NO CUMPLE') {
            noCumplen.add("Pregunta ${p.id}: Obtuvo $poVal / Esperado $peVal");
          }
        }
      }
    }

    double porTot = totPe > 0 ? (totPo / totPe) * 100 : 0.0;
    String calif = "";
    if (porTot >= 96) calif = "EXCELENTE";
    else if (porTot >= 86) calif = "MUY BUENO";
    else if (porTot >= 76) calif = "BUENO";
    else if (porTot >= 56) calif = "REGULAR";
    else calif = "DEFICIENTE";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.analytics, color: kColorGreen),
            const SizedBox(width: 8),
            const Text("Vista Previa"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Calificación: $calif", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kColorBlue)),
              const SizedBox(height: 10),
              Text("Puntuación Total PE: ${totPe.toStringAsFixed(0)}"),
              Text("Puntuación Total PO: ${totPo.toStringAsFixed(0)}"),
              Text("Conformidad: ${porTot.toStringAsFixed(1)}%"),
              const Divider(height: 30),
              const Text("Preguntas No Conformes:", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (noCumplen.isEmpty) const Text("No hay preguntas no conformes.", style: TextStyle(color: Colors.grey)),
              ...noCumplen.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text("• $e", style: const TextStyle(fontSize: 13)),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CERRAR", style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }
  // -----------------------------------------

  Future<void> _seleccionarFecha() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: "FECHA DE INSPECCIÓN",
    );
    if (picked != null) {
      setState(() {
        fechaCtrl.text = DateFormat("dd/MM/yyyy").format(picked);
        _guardarDatoBorrador("fecha", fechaCtrl.text);
      });
    }
  }

  Future<void> _seleccionarHora(TextEditingController ctrl, String draftKey) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final h = picked.hour.toString().padLeft(2, '0');
        final m = picked.minute.toString().padLeft(2, '0');
        ctrl.text = "$h:$m";
        _guardarDatoBorrador(draftKey, ctrl.text);
      });
    }
  }

  // --- NUEVA LÓGICA: SOPORTA MÚLTIPLES FOTOS ---
  Future<void> _tomarFoto(Pregunta p) async {
    if (bloqueado) return;
    final XFile? foto = await _picker.pickImage(
      source: ImageSource.camera, 
      imageQuality: 80, 
      maxWidth: 1200
    );
    if (foto != null) {
      setState(() {
        if (_fotosBorrador[p.id] == null) _fotosBorrador[p.id] = [];
        _fotosBorrador[p.id]!.add(foto.path);
      });
      _guardarDatoBorrador("fotos_${p.id}", jsonEncode(_fotosBorrador[p.id]));
    }
  }

  void _eliminarFoto(Pregunta p, int index) {
    setState(() {
      _fotosBorrador[p.id]?.removeAt(index);
    });
    _guardarDatoBorrador("fotos_${p.id}", jsonEncode(_fotosBorrador[p.id]));
  }

  // --- MOTOR DE GUARDADO CON CÁLCULOS INCORPORADOS ---
  Future<void> _generarFR246() async {
    if (bloqueado) return;

    if (inspectorSel == null || nombreRepCtrl.text.isEmpty || _firmaIns.isEmpty || _firmaRep.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Falta Inspector, nombre del Representante o firmas.")));
      return;
    }

    setState(() => _estaCargando = true);

    try {
      final insBytes = await _firmaIns.toPngBytes();
      final repBytes = await _firmaRep.toPngBytes();
      String firmaInsB64 = insBytes != null ? base64Encode(insBytes) : "";
      String firmaRepB64 = repBytes != null ? base64Encode(repBytes) : "";

      // 1. RECOPILAR DATOS PARA EL MOTOR DE CÁLCULO
      Map<String, String> inputsParaCalculo = {};
      for (var sec in checklistDatos) {
        for (var subsec in sec.subsecciones) {
          for (var p in subsec.preguntas) {
            inputsParaCalculo["pe${p.id}"] = p.displayPe;
            inputsParaCalculo["po${p.id}"] = p.displayPo;
          }
        }
      }
      
      // 2. EJECUTAR LOS CÁLCULOS
      Map<String, dynamic> resultadosCalculo = CalculosHelper.procesarFormulario(inputsParaCalculo);

      // 3. CONSTRUIR PAYLOAD MAESTRO (Para Cloud Run y Firestore)
      Map<String, dynamic> payloadCloudRun = {
        "os": widget.prefillOs,
        "cliente": widget.prefillCliente,
        "direccion_legal": widget.prefillDireccionLegal,
        "establecimiento": establecimientoCtrl.text,
        "rubro": rubroCtrl.text,
        "fecha_inspeccion": fechaCtrl.text,
        
        "hora_inicial": horaInitCtrl.text,
        "hora_final": horaFinCtrl.text,
        "direccion_establecimiento": lugarCtrl.text,
        "representante": repCtrl.text,
        "representante2": repCtrl.text,
        "inspector": inspectorSel ?? "",
        "inspector2": inspectorSel ?? "",
        
        "autorizacion": autCtrl.text,
        "cert_saneamiento": sanCtrl.text,
        "cert_limpieza": limpCtrl.text,
        "equi1": equi1Ctrl.text,
        "equi2": equi2Ctrl.text,
        "obgen": obsGenCtrl.text,
        "firma_ins": firmaInsB64,
        "firma_rep": firmaRepB64,
        
        "totpe": resultadosCalculo["totpe"],
        "totpo": resultadosCalculo["totpo"],
        "totpe1": resultadosCalculo["totpe"],
        "totpo1": resultadosCalculo["totpo"],
        "portot": resultadosCalculo["portot"],
        "calificacion": resultadosCalculo["calificacion"],
        
        "createdAt": DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now()), 
      };

      // Inyectamos también los porcentajes individuales generados por el helper
      resultadosCalculo.forEach((key, value) {
        if (key.startsWith("por") || key.startsWith("sum")) {
          payloadCloudRun[key] = value;
        }
      });

      // Inyectamos las respuestas individuales del checklist y codificamos el array de fotos a Base64
      for (var sec in checklistDatos) {
        for (var subsec in sec.subsecciones) {
          for (var p in subsec.preguntas) {
            payloadCloudRun["pe${p.id}"] = p.displayPe;
            payloadCloudRun["po${p.id}"] = p.displayPo;
            // GARANTIZADO: Enviar el texto vivo del controlador para evitar pérdida
            payloadCloudRun["obs${p.id}"] = p.obsCtrl.text; 

            // Procesamiento de arreglo de fotos
            List<String> fotosB64 = [];
            List<String> fotosPregunta = _fotosBorrador[p.id] ?? [];
            
            for (String pathFoto in fotosPregunta) {
              try {
                File archivoImagen = File(pathFoto);
                if (archivoImagen.existsSync()) {
                  List<int> imageBytes = archivoImagen.readAsBytesSync();
                  fotosB64.add(base64Encode(imageBytes));
                }
              } catch (e) {
                print("Error codificando foto de la pregunta ${p.id}: $e");
              }
            }

            // Enviar a la BD como un arreglo JSON (["base64...", "base64..."])
            if (fotosB64.isNotEmpty) {
              payloadCloudRun["foto${p.id}"] = jsonEncode(fotosB64);
            } else {
              payloadCloudRun["foto${p.id}"] = "[]";
            }
          }
        }
      }

      // 4. GUARDAR EN FIRESTORE
      Map<String, dynamic> payloadFirestore = Map<String, dynamic>.from(payloadCloudRun);
      payloadFirestore["createdAt"] = FieldValue.serverTimestamp(); // Timestamp nativo para BD

      await FirebaseFirestore.instance.collection(kInspeccionRegistrosCol).add(payloadFirestore);

      // Limpieza de base de datos y UI
      if (widget.asignacionDocId.isNotEmpty) {
        await FirebaseFirestore.instance.collection(kInspeccionAsignacionesCol).doc(widget.asignacionDocId).delete();
      }
      
      await _limpiarBorrador();

      setState(() {
        bloqueado = true;
        _estaCargando = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Inspección registrada exitosamente.")));

    } catch (e) {
      setState(() => _estaCargando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  // --- SEPARACIÓN EN SECCIONES UI ---
  Widget _buildSeccionCard(String titulo, List<Widget> hijos) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kColorBlue)),
            const Divider(height: 24),
            ...hijos,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, String draftKey, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: ctrl,
        readOnly: readOnly,
        textCapitalization: TextCapitalization.characters,
        onChanged: (val) => _guardarDatoBorrador(draftKey, val),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPregunta(Pregunta p) {
    List<String> fotosPregunta = _fotosBorrador[p.id] ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${p.id}. ${p.texto}", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['CUMPLE', 'NO CUMPLE', 'NO APLICA'].map((opcion) {
                final isSelected = p.estado == opcion;
                return ChoiceChip(
                  label: Text(opcion, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black)),
                  selected: isSelected,
                  selectedColor: opcion == 'CUMPLE' ? Colors.green : opcion == 'NO CUMPLE' ? Colors.red : Colors.grey.shade600,
                  onSelected: bloqueado ? null : (val) {
                    setState(() {
                      p.marcar(val ? opcion : '');
                      _guardarDatoBorrador("q_${p.id}", p.estado);
                      if (!p.requiereFotoYObs) {
                        _fotosBorrador[p.id] = [];
                        _guardarDatoBorrador("fotos_${p.id}", "[]");
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            if (p.estado.isNotEmpty) ...[
              Row(
                children: [
                  Text("pe${p.id}: ${p.displayPe}", style: const TextStyle(fontWeight: FontWeight.bold, color: kColorGreen)),
                  const SizedBox(width: 16),
                  Text("po${p.id}: ${p.displayPo}", style: const TextStyle(fontWeight: FontWeight.bold, color: kColorGreen)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                enabled: !bloqueado && p.estado != 'NO APLICA',
                controller: p.obsCtrl,
                onChanged: (val) => _guardarDatoBorrador("obsq_${p.id}", val),
                decoration: InputDecoration(
                  labelText: p.requiereFotoYObs ? "Observación (Obligatoria) *" : "Observación (Opcional)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                ),
              ),
              const SizedBox(height: 12),
              if (p.requiereFotoYObs)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: bloqueado ? null : () => _tomarFoto(p),
                      icon: const Icon(Icons.camera_alt),
                      label: Text(fotosPregunta.isEmpty ? "Tomar Foto *" : "Añadir otra foto (${fotosPregunta.length})"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: fotosPregunta.isEmpty ? Colors.red.shade100 : Colors.green.shade100,
                        foregroundColor: Colors.black,
                      ),
                    ),
                    if (fotosPregunta.isNotEmpty)
                      Container(
                        height: 70,
                        margin: const EdgeInsets.only(top: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: fotosPregunta.length,
                          itemBuilder: (context, idx) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(File(fotosPregunta[idx]), width: 55, height: 55, fit: BoxFit.cover),
                                  ),
                                ),
                                if (!bloqueado)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: InkWell(
                                      onTap: () => _eliminarFoto(p, idx),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  )
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OS: ${widget.prefillOs}"),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: kColorGreen),
            tooltip: "Vista Previa",
            onPressed: _mostrarVistaPrevia,
          )
        ],
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: bloqueado,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                
                // --- SECCION 1 ---
                _buildSeccionCard("1. Datos del cliente", [
                  TextFormField(
                    initialValue: widget.prefillOs, 
                    readOnly: true, 
                    decoration: InputDecoration(labelText: "OS", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: widget.prefillCliente, 
                    readOnly: true, 
                    decoration: InputDecoration(labelText: "CLIENTE", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: widget.prefillDireccionLegal, 
                    readOnly: true, 
                    decoration: InputDecoration(labelText: "DIRECCION LEGAL", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))
                  ),
                ]),

                // --- SECCION 2 ---
                _buildSeccionCard("2. Información de la inspección", [
                  _buildTextField(establecimientoCtrl, "ESTABLECIMIENTO A INSPECCIONAR", "est"),
                  _buildTextField(rubroCtrl, "RUBRO DEL ESTABLECIMIENTO", "rubro"),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextField(
                      controller: fechaCtrl,
                      readOnly: true,
                      onTap: _seleccionarFecha,
                      decoration: InputDecoration(labelText: "FECHA DE INSPECCION", suffixIcon: const Icon(Icons.calendar_today), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TextField(
                      controller: horaInitCtrl,
                      readOnly: true,
                      onTap: () => _seleccionarHora(horaInitCtrl, "horainit"),
                      decoration: InputDecoration(labelText: "HORA INICIAL", suffixIcon: const Icon(Icons.access_time), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                  _buildTextField(lugarCtrl, "LUGAR DE INSPECCION", "lugar"),
                  _buildTextField(repCtrl, "REPRESENTANTE", "rep"),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: DropdownButtonFormField<String>(
                      value: inspectorSel,
                      items: inspectores.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                      onChanged: bloqueado ? null : (val) {
                        setState(() {
                          inspectorSel = val;
                          _guardarDatoBorrador("inspector", val ?? "");
                        });
                      },
                      decoration: InputDecoration(labelText: "INSPECTOR", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                  _buildTextField(autCtrl, "AUTORIZACIÓN MUNICIPAL", "aut"),
                  _buildTextField(sanCtrl, "CERTIFICADO DE SANEAMIENTO AMBIENTAL", "san"),
                  _buildTextField(limpCtrl, "CERTIFICADO LIMPIEZA Y DESINFECCIÓN", "limp"),
                ]),

                // --- SECCION 3 ---
                _buildSeccionCard("3. Equipos", [
                  _buildTextField(equi1Ctrl, "FOTOMETRO DE CLORO", "equi1"),
                  _buildTextField(equi2Ctrl, "LUXOMETRO", "equi2"),
                ]),

                // --- SECCION 4 ---
                _buildSeccionCard("4. Checklist", [
                  ...checklistDatos.map((seccion) {
                    return ExpansionTile(
                      title: Text(seccion.titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: kColorGreen)),
                      children: seccion.subsecciones.map((subsec) {
                        return ExpansionTile(
                          title: Text(subsec.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                          children: subsec.preguntas.map((p) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: _buildPregunta(p),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  }),
                ]),

                // --- SECCION 5 ---
                _buildSeccionCard("5. Observaciones Generales", [
                  TextField(
                    controller: obsGenCtrl, 
                    maxLines: null, 
                    textCapitalization: TextCapitalization.sentences, 
                    onChanged: (val) => _guardarDatoBorrador("obsgen", val),
                    decoration: InputDecoration(labelText: "Observaciones generales", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))
                  ),
                ]),

                // --- SECCION 6 ---
                _buildSeccionCard("6. Cierre y Firmas", [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: horaFinCtrl,
                      readOnly: true,
                      onTap: () => _seleccionarHora(horaFinCtrl, "horafin"),
                      decoration: InputDecoration(labelText: "HORA FINAL", suffixIcon: const Icon(Icons.access_time), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                  
                  const Text("FIRMA DEL INSPECTOR", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(initialValue: inspectorSel ?? "Seleccione inspector en la sección 2", readOnly: true, decoration: const InputDecoration(border: InputBorder.none)),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Signature(controller: _firmaIns, backgroundColor: Colors.grey.shade100),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () => _firmaIns.clear(), child: const Text("Limpiar firma")),
                  ),
                  
                  const SizedBox(height: 20),
                  const Text("FIRMA DEL CLIENTE / REPRESENTANTE", style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildTextField(nombreRepCtrl, "Nombre del representante *", "nombrerep"),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Signature(controller: _firmaRep, backgroundColor: Colors.grey.shade100),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () => _firmaRep.clear(), child: const Text("Limpiar firma")),
                  ),
                ]),
                
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: bloqueado ? null : _generarFR246,
                        style: ElevatedButton.styleFrom(backgroundColor: kColorGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: Text(bloqueado ? "REGISTRO GUARDADO (INALTERABLE)" : "GUARDAR REGISTRO"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_estaCargando)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: kColorGreen)),
            ),
        ],
      ),
    );
  }
}

class InspeccionRecordsPage extends StatefulWidget {
  const InspeccionRecordsPage({super.key});

  @override
  State<InspeccionRecordsPage> createState() => _InspeccionRecordsPageState();
}

class _InspeccionRecordsPageState extends State<InspeccionRecordsPage> {

  Future<void> guardarYAbrirPDF(List<int> bytes, String fileName) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      final result = await OpenFilex.open(file.path);
      
      if (result.type != ResultType.done) {
         throw Exception("No se encontró una app para abrir PDFs.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error al abrir archivo: $e")));
      }
    }
  }

Future<void> _generarYVerPDF(Map<String, dynamic> data) async {
  // --- NUEVO: Obtener la URL dinámicamente ---
  final remoteConfig = FirebaseRemoteConfig.instance;
  // Activamos los cambios configurados en la consola
  await remoteConfig.fetchAndActivate();
  String baseUrl = remoteConfig.getString('backend_url');
  // -------------------------------------------
    Map<String, dynamic> payloadForCloudRun = Map<String, dynamic>.from(data);
    if (payloadForCloudRun["createdAt"] is Timestamp) {
      payloadForCloudRun["createdAt"] = DateFormat("dd/MM/yyyy HH:mm").format((payloadForCloudRun["createdAt"] as Timestamp).toDate());
    }
    // 👇 SECCIÓN AÑADIDA: Indicador de plantilla y adaptación de llaves para las firmas
    payloadForCloudRun["template_type"] = "ACTA";
    
    if (payloadForCloudRun.containsKey("firma_ins")) {
      payloadForCloudRun["firmaInspectorPngBase64"] = payloadForCloudRun["firma_ins"];
    }
    if (payloadForCloudRun.containsKey("firma_rep")) {
      payloadForCloudRun["firmaClientePngBase64"] = payloadForCloudRun["firma_rep"];
    }
    // 👆 -------------------------------------------------------------------------

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: kColorGreen),
            SizedBox(width: 20),
            Text("Generando acta de inspección..."),
          ],
        ),
      ),
    );

  try {
    // 👇 AQUÍ USAS LA VARIABLE 'baseUrl'
    final response = await http.post(
      Uri.parse('$baseUrl/generar-pdf'), 
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payloadForCloudRun),
    );

      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final osName = data["os"] ?? "ACTA";
        
        await guardarYAbrirPDF(bytes, "ACTA_$osName.pdf");
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ PDF Generado y abierto")));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("❌ Error ${response.statusCode}: ${response.body}"), 
              duration: const Duration(seconds: 8),
          ));
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error de conexión: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance.collection(kInspeccionRegistrosCol).orderBy("createdAt", descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("Actas Emitidas"), backgroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text("Error: ${snap.error}"));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No hay actas emitidas."));

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final os = (d["os"] ?? "").toString();
              final cliente = (d["cliente"] ?? "").toString();
              
              String fecha = "";
              if (d["createdAt"] is Timestamp) {
                fecha = DateFormat("dd/MM/yyyy HH:mm").format((d["createdAt"] as Timestamp).toDate());
              }

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.black.withOpacity(0.06))),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.check_circle, color: kColorGreen, size: 36),
                  title: Text("OS: $os", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Cliente: $cliente\nCompletado: $fecha"),
                  trailing: IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                    onPressed: () => _generarYVerPDF(d),
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