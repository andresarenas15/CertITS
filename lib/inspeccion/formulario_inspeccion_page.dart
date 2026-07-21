import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // NECESARIO PARA FOTOS DE ALTA RESOLUCIÓN
import 'calculos_helper.dart';

class FormularioInpeccionPage extends StatefulWidget {
  final String? prefillOs;
  const FormularioInpeccionPage({super.key, this.prefillOs});

  @override
  State<FormularioInpeccionPage> createState() => _FormularioInpeccionPageState();
}

class _FormularioInpeccionPageState extends State<FormularioInpeccionPage> {
  final Map<String, String> _valores = {};
  bool _isSaved = false;
  final ImagePicker _picker = ImagePicker();

  final SignatureController _inspectorSignature = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    _cargarBorrador();
    if (widget.prefillOs != null) {
      _valores["os"] = widget.prefillOs!;
    }
  }

  // ============================================================
  // 1. PERSISTENCIA TOTAL (Observaciones y Fotos incluidas)
  // ============================================================
  Future<void> _cargarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _valores["os"] = prefs.getString("draft_os") ?? widget.prefillOs ?? "";
      _valores["cliente"] = prefs.getString("draft_cliente") ?? "";
      _valores["direccion_legal"] = prefs.getString("draft_direccion_legal") ?? "";
      
      // Inicializar las 111 preguntas con sus observaciones y fotos
      for (int i = 1; i <= 111; i++) {
        _valores["pe$i"] = prefs.getString("draft_pe$i") ?? "";
        _valores["po$i"] = prefs.getString("draft_po$i") ?? "";
        _valores["obs$i"] = prefs.getString("draft_obs$i") ?? "";
        _valores["foto$i"] = prefs.getString("draft_foto$i") ?? "[]"; // Array JSON
      }
      
      _valores["establecimiento"] = prefs.getString("draft_establecimiento") ?? "";
      _valores["rubro"] = prefs.getString("draft_rubro") ?? "";
      _valores["fecha_inspeccion"] = prefs.getString("draft_fecha_inspeccion") ?? "";
      _valores["hora_inicial"] = prefs.getString("draft_hora_inicial") ?? "";
      _valores["direccion_establecimiento"] = prefs.getString("draft_direccion_establecimiento") ?? "";
      _valores["representante"] = prefs.getString("draft_representante") ?? "";
      _valores["inspector"] = prefs.getString("draft_inspector") ?? "";
      _valores["equi1"] = prefs.getString("draft_equi1") ?? "";
      _valores["equi2"] = prefs.getString("draft_equi2") ?? "";
      _valores["obgen"] = prefs.getString("draft_obgen") ?? "";
      _valores["hora_final"] = prefs.getString("draft_hora_final") ?? "";
    });
  }

  Future<void> _guardarBorrador(String key, String val) async {
    final prefs = await SharedPreferences.getInstance();
    _valores[key] = val;
    await prefs.setString("draft_$key", val);
  }

  // ============================================================
  // 2. CAPTURA DE MÚLTIPLES FOTOS EN ALTA RESOLUCIÓN
  // ============================================================
  Future<void> _tomarFoto(int indexPregunta) async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 95, // Alta calidad
      maxWidth: 1920,   // Resolución controlada
      maxHeight: 1080,
    );

    if (photo != null) {
      final bytes = await photo.readAsBytes();
      final base64String = base64Encode(bytes);
      
      // Decodificar la lista actual, agregar la nueva foto y volver a guardar
      List<String> fotosActuales = [];
      String fotosGuardadas = _valores["foto$indexPregunta"] ?? "[]";
      if (fotosGuardadas.isNotEmpty) {
        fotosActuales = List<String>.from(jsonDecode(fotosGuardadas));
      }
      
      fotosActuales.add(base64String);
      
      setState(() {
        _valores["foto$indexPregunta"] = jsonEncode(fotosActuales);
      });
      _guardarBorrador("foto$indexPregunta", _valores["foto$indexPregunta"]!);
    }
  }

  void _mostrarVistaPrevia() {
    Map<String, dynamic> calculos = CalculosHelper.procesarFormulario(_valores);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vista Previa de Inspección"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Calificación: ${calculos["calif"]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text("Puntuación Total PE: ${calculos["totpe"]}"),
              Text("Puntuación Total PO: ${calculos["totpo"]}"),
              Text("Conformidad: ${calculos["portot"]}"),
              const Divider(),
              const Text("Puntos No Conformes:", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))
        ],
      ),
    );
  }

  // ============================================================
  // 3. GENERACIÓN DEL PAYLOAD CON AGRUPAMIENTO DE FOTOS
  // ============================================================
  Future<void> _guardarRegistro() async {
    if (_isSaved) return;

    if (_valores["os"] == null || _valores["os"]!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La Orden de Servicio (OS) es obligatoria")),
      );
      return;
    }

    Uint8List? firmaBytes;
    if (_inspectorSignature.isNotEmpty) {
      final imgData = await _inspectorSignature.toPngBytes();
      if (imgData != null) firmaBytes = imgData;
    }

    final Map<String, dynamic> calculos = CalculosHelper.procesarFormulario(_valores);

    Map<String, dynamic> payload = {
      "os": _valores["os"],
      "cliente": _valores["cliente"],
      "direccion_legal": _valores["direccion_legal"],
      "establecimiento": _valores["establecimiento"],
      "rubro": _valores["rubro"],
      "fecha_inspeccion": _valores["fecha_inspeccion"],
      "hora_inicial": _valores["hora_inicial"],
      "direccion_establecimiento": _valores["direccion_establecimiento"],
      "representante": _valores["representante"],
      "inspector": _valores["inspector"],
      "representante2": _valores["representante"],
      "inspector2": _valores["inspector"],
      "equi1": _valores["equi1"],
      "equi2": _valores["equi2"],
      "obgen": _valores["obgen"],
      "hora_final": _valores["hora_final"],
      "totpe": calculos["totpe"],
      "totpo": calculos["totpo"],
      "totpe1": calculos["totpe"],   
      "totpo1": calculos["totpo"],   
      "portot": calculos["portot"],
      "calificacion": calculos["calificacion"],
      "createdAt": DateTime.now().toIso8601String(),
    };

    // Procesamiento dinámico de las 111 preguntas
    for (int i = 1; i <= 111; i++) {
      payload["pe$i"] = _valores["pe$i"] ?? "";
      payload["po$i"] = _valores["po$i"] ?? "";
      payload["obs$i"] = _valores["obs$i"] ?? "";
      
      // Convertir el JSON string de fotos a un Array nativo para Firebase
      String fotosJson = _valores["foto$i"] ?? "[]";
      List<dynamic> fotosList = jsonDecode(fotosJson);
      payload["foto$i"] = fotosList; // Envía todas las fotos de la pregunta como una sola lista
    }

    if (firmaBytes != null) {
      payload["firma_ins"] = base64Encode(firmaBytes);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseFirestore.instance.collection("inspecciones").add(payload);

      final response = await http.post(
        Uri.parse('https://generador-fr246-343437321688.us-central1.run.app/generar_fr246'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception("Error en Cloud Run: ${response.body}");
      }

      setState(() => _isSaved = true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); 

      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registro guardado de forma inalterable y PDF generado")),
      );
      
      Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
      
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acta de Inspección FR 246"),
        actions: [
          IconButton(icon: const Icon(Icons.analytics), onPressed: _mostrarVistaPrevia),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _isSaved,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSeccion(
                titulo: "1. Datos del Cliente",
                children: [
                  _buildTextField("os", "Orden de Servicio (OS)"),
                  _buildTextField("cliente", "Cliente"),
                  _buildTextField("direccion_legal", "Dirección Legal"),
                ],
              ),
              _buildSeccion(
                titulo: "2. Información de la Inspección",
                children: [
                  _buildTextField("establecimiento", "Establecimiento a Inspeccionar"),
                  _buildTextField("rubro", "Rubro"),
                  _buildTextField("fecha_inspeccion", "Fecha de Inspección"),
                  _buildTextField("hora_inicial", "Hora Inicial"),
                  _buildTextField("direccion_establecimiento", "Lugar de Inspección"),
                  _buildTextField("representante", "Representante"),
                  _buildTextField("inspector", "Inspector"),
                ],
              ),
              _buildSeccion(
                titulo: "3. Equipos",
                children: [
                  _buildTextField("equi1", "Fotómetro"),
                  _buildTextField("equi2", "Luxómetro"),
                ],
              ),
              _buildSeccion(
                titulo: "4. Checklist (111 ítems)",
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 111,
                    itemBuilder: (context, index) {
                      return _buildPreguntaItem(index + 1);
                    },
                  ),
                ],
              ),
              _buildSeccion(
                titulo: "5. Observaciones Generales",
                children: [
                  TextFormField(
                    initialValue: _valores["obgen"],
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(labelText: "Observaciones Generales"),
                    onChanged: (v) => _guardarBorrador("obgen", v),
                  ),
                ],
              ),
              _buildSeccion(
                titulo: "6. Cierre y Firmas",
                children: [
                  _buildTextField("hora_final", "Hora Final"),
                  const SizedBox(height: 10),
                  const Text("Firma del Inspector"),
                  Container(
                    color: Colors.grey[200],
                    height: 200,
                    child: Signature(controller: _inspectorSignature, backgroundColor: Colors.transparent),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _isSaved ? null : _guardarRegistro,
                child: const Text("Guardar Registro de Forma Inalterable", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COMPONENTE DINÁMICO PARA PREGUNTAS
  // ============================================================
  Widget _buildPreguntaItem(int i) {
    double pe = double.tryParse(_valores["pe$i"] ?? "0") ?? 0;
    double po = double.tryParse(_valores["po$i"] ?? "0") ?? 0;
    bool noCumple = pe > 0 && po < pe;

    List<String> fotosPregunta = [];
    if (_valores["foto$i"] != null && _valores["foto$i"]!.isNotEmpty) {
      fotosPregunta = List<String>.from(jsonDecode(_valores["foto$i"]!));
    }

    return Card(
      color: noCumple ? Colors.red.shade50 : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pregunta $i", style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _valores["pe$i"],
                    decoration: const InputDecoration(labelText: "PE (Esperado)"),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      _guardarBorrador("pe$i", v);
                      setState(() {}); // Actualiza UI para detectar "no cumple"
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: _valores["po$i"],
                    decoration: const InputDecoration(labelText: "PO (Obtenido)"),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      _guardarBorrador("po$i", v);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            if (noCumple) ...[
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _valores["obs$i"],
                decoration: InputDecoration(
                  labelText: "Observación de incumplimiento",
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _guardarBorrador("obs$i", v),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Fotos adjuntas: ${fotosPregunta.length}"),
                  ElevatedButton.icon(
                    onPressed: () => _tomarFoto(i),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Añadir Foto"),
                  )
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSeccion({required String titulo, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String key, String label) {
    return TextFormField(
      initialValue: _valores[key] ?? "",
      decoration: InputDecoration(labelText: label),
      onChanged: (v) => _guardarBorrador(key, v),
    );
  }

  @override
  void dispose() {
    _inspectorSignature.dispose();
    super.dispose();
  }
}