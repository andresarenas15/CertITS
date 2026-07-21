// lib/rendicion_gastos/rendicion_gastos_app.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

const Color cOrange = Color(0xFFE37E24);
const Color cGreen = Color(0xFF5D6A35);
const Color cBlue = Color(0xFF293EBE);
const Color cBg = Color(0xFFF0F4F8);

class RendicionDraft {
  static final RendicionDraft instance = RendicionDraft._internal();
  RendicionDraft._internal();

  String? docId; 
  DateTime? fechaSol;
  String os = "";
  String lugar = "";
  DateTime? fechaSalida;
  bool refSalida = false;
  DateTime? fechaInicio;
  bool refInicio = false;
  DateTime? fechaTermino;
  bool refTermino = false;
  int diasOpe = 1;
  String? ejecutivo;
  String otroEjecutivo = "";
  String? inspector1, inspector2, inspector3;
  TimeOfDay? horaInicio;
  bool refHoraInicio = false;
  TimeOfDay? horaFin;
  bool refHoraFin = false;
  String? inspectorDeposito;
  String? realizadoPor;
  String observaciones = "";
  List<ItemRendicion> items = [];

  void clear() {
    docId = null;
    fechaSol = null; os = ""; lugar = ""; fechaSalida = null; refSalida = false;
    fechaInicio = null; refInicio = false; fechaTermino = null; refTermino = false;
    diasOpe = 1; ejecutivo = null; otroEjecutivo = ""; inspector1 = null;
    inspector2 = null; inspector3 = null; horaInicio = null; refHoraInicio = false;
    horaFin = null; refHoraFin = false; inspectorDeposito = null; realizadoPor = null;
    observaciones = ""; items.clear();
  }
}

BoxDecoration clayBox = BoxDecoration(
  color: cBg,
  borderRadius: BorderRadius.circular(15),
  boxShadow: [
    const BoxShadow(color: Colors.white, offset: Offset(-5, -5), blurRadius: 10),
    BoxShadow(color: Colors.blueGrey.withOpacity(0.2), offset: const Offset(5, 5), blurRadius: 10),
  ],
);

Widget buildClayButton(String text, IconData icon, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: clayBox,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    ),
  );
}

class RendicionGastosMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBg,
      appBar: AppBar(
        title: const Text("Viáticos y Rendición", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildClayButton("SOLICITUD DE VIÁTICOS", Icons.request_quote, cOrange, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Módulo en desarrollo...")));
            }),
            const SizedBox(height: 32),
            buildClayButton("RENDICIÓN DE GASTOS", Icons.receipt_long, cBlue, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => RendicionOpcionesPage()));
            }),
          ],
        ),
      ),
    );
  }
}

class RendicionOpcionesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBg,
      appBar: AppBar(title: const Text("Rendición de Gastos"), backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildClayButton("REALIZAR RENDICIÓN", Icons.add_task, cGreen, () {
              // SOLUCIÓN 1: COMPROBACIÓN DE BORRADOR
              if (RendicionDraft.instance.os.isNotEmpty || RendicionDraft.instance.items.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Borrador Encontrado"),
                    content: const Text("Tienes una rendición en curso. ¿Deseas retomarla o iniciar una nueva?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          RendicionDraft.instance.clear();
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => GenerarRendicionPage()));
                        }, 
                        child: const Text("NUEVA", style: TextStyle(color: Colors.grey))
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: cBlue, foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => GenerarRendicionPage()));
                        }, 
                        child: const Text("CONTINUAR")
                      )
                    ],
                  )
                );
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => GenerarRendicionPage()));
              }
            }),
            const SizedBox(height: 32),
            buildClayButton("VER RENDICIONES", Icons.format_list_bulleted, cBlue, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => VerRendicionesPage()));
            }),
          ],
        ),
      ),
    );
  }
}

class GenerarRendicionPage extends StatefulWidget {
  @override
  _GenerarRendicionPageState createState() => _GenerarRendicionPageState();
}

class _GenerarRendicionPageState extends State<GenerarRendicionPage> {
  final _formKey = GlobalKey<FormState>();
  final draft = RendicionDraft.instance; 

  final List<String> listEjecutivos = ['Gabriel Albornoz', 'Rosemery Conislla', 'Sandra Velásquez', 'Magaly Palacios', 'Marco Urrunaga', 'Giovanna Reyes', 'Rossmery Ocas', 'Mariana Romero', 'Otros'];
  final List<String> listInspectores = ['Oliver Milla', 'Jhon Vega', 'Bryan Ramos', 'Victor Gil', 'Edinson Maschacuri', 'Héctor Sandoval', 'Andrés Arenas', 'Marco Carrasco'];
  
  String _formatName(String name) {
    return name.toLowerCase()
        .replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i')
        .replaceAll('ó', 'o').replaceAll('ú', 'u').replaceAll(' ', '_');
  }

  @override
  Widget build(BuildContext context) {
    double totalGastado = draft.items.fold(0, (sum, item) => sum + item.importe);
    double porDevolver = 0.0 - totalGastado; 

    // SOLUCIÓN 2: GESTURE DETECTOR GLOBAL PARA EL TECLADO
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cBg,
        appBar: AppBar(title: Text(draft.docId == null ? "Nueva Rendición" : "Modificar Rendición"), backgroundColor: Colors.white),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: clayBox,
                child: Column(
                  children: [
                    _buildDatePicker("Fecha de solicitud", draft.fechaSol, (d) => setState(() => draft.fechaSol = d)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: "Área", border: OutlineInputBorder()),
                        initialValue: "Operaciones Alimentos", enabled: false,
                      ),
                    ),
                    TextFormField(
                      initialValue: draft.os,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: "OS"),
                      onChanged: (v) => draft.os = v.toUpperCase(),
                    ),
                    TextFormField(
                      initialValue: draft.lugar,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: "Lugar de servicio"),
                      onChanged: (v) => draft.lugar = v,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: clayBox,
                child: Column(
                  children: [
                    _buildDateWithCheckbox("Fecha de salida", draft.fechaSalida, draft.refSalida, (d) => setState(() => draft.fechaSalida = d), (v) => setState(() => draft.refSalida = v!)),
                    _buildDateWithCheckbox("Fecha de inicio servicio", draft.fechaInicio, draft.refInicio, (d) => setState(() => draft.fechaInicio = d), (v) => setState(() => draft.refInicio = v!)),
                    _buildDateWithCheckbox("Fecha de término servicio", draft.fechaTermino, draft.refTermino, (d) => setState(() => draft.fechaTermino = d), (v) => setState(() => draft.refTermino = v!)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Nº de días operativos:"),
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.remove_circle, color: cOrange), onPressed: () => setState(() { if(draft.diasOpe>1) draft.diasOpe--;})),
                            Text(draft.diasOpe.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(icon: const Icon(Icons.add_circle, color: cBlue), onPressed: () => setState(() => draft.diasOpe++)),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: clayBox,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: draft.ejecutivo,
                      decoration: const InputDecoration(labelText: "Ejecutivo Comercial"),
                      items: listEjecutivos.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => draft.ejecutivo = v),
                    ),
                    if (draft.ejecutivo == 'Otros') 
                      TextFormField(
                        initialValue: draft.otroEjecutivo, 
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: "Especificar Ejecutivo"), 
                        onChanged: (v) => draft.otroEjecutivo = v,
                      ),
                    DropdownButtonFormField<String>(value: draft.inspector1, decoration: const InputDecoration(labelText: "Inspector 1"), items: listInspectores.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => draft.inspector1 = v)),
                    DropdownButtonFormField<String>(value: draft.inspector2, decoration: const InputDecoration(labelText: "Inspector 2"), items: listInspectores.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => draft.inspector2 = v)),
                    DropdownButtonFormField<String>(value: draft.inspector3, decoration: const InputDecoration(labelText: "Inspector 3"), items: listInspectores.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => draft.inspector3 = v)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: clayBox,
                child: Column(
                  children: [
                    _buildTimeWithCheckbox("Hora de inicio de servicio", draft.horaInicio, draft.refHoraInicio, (t) => setState(() => draft.horaInicio = t), (v) => setState(() => draft.refHoraInicio = v!)),
                    _buildTimeWithCheckbox("Hora de finalización de servicio", draft.horaFin, draft.refHoraFin, (t) => setState(() => draft.horaFin = t), (v) => setState(() => draft.refHoraFin = v!)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text("ÍTEMS DE RENDICIÓN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cBlue)),
              const SizedBox(height: 10),
              ...draft.items.asMap().entries.map((entry) {
                return ItemRendicionWidget(
                  item: entry.value,
                  index: entry.key,
                  onDelete: () => setState(() => draft.items.removeAt(entry.key)),
                  onUpdate: () => setState((){}), 
                );
              }).toList(),
              
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: cGreen, foregroundColor: Colors.white),
                icon: const Icon(Icons.add),
                label: const Text("Adicionar ítem"),
                onPressed: () => setState(() => draft.items.add(ItemRendicion())),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: clayBox,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TOTAL GASTADO: S/ ${totalGastado.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text("VIÁTICOS DEPOSITADOS: -", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      "POR DEVOLVER: S/ ${porDevolver.toStringAsFixed(2)}", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: porDevolver < 0 ? Colors.red : Colors.black)
                    ),
                  ],
                )
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: clayBox,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("*NOTA 1: Los gastos deben ser descritos ordenadamente por fecha y por inspector.", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                    const Text("*Alimentación: Desayuno, almuerzo y cena.", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                    const Text("*Movilidad: Taxi, renta de vehículo, pasaje bus, combustible, peaje.", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: draft.observaciones,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: "OBSERVACIONES", border: OutlineInputBorder()),
                      onChanged: (v) => draft.observaciones = v,
                    ),
                  ],
                )
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: clayBox,
                child: Column(
                  children: [
                    const Text("El depósito debe realizarse a la siguiente cuenta:", style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      value: draft.inspectorDeposito,
                      decoration: const InputDecoration(labelText: "Inspector a depositar"),
                      items: listInspectores.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => draft.inspectorDeposito = v),
                    ),
                    if (draft.inspectorDeposito != null) 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(_getBankDetails(draft.inspectorDeposito!), style: const TextStyle(color: cBlue)),
                      ),
                    const Divider(),
                    DropdownButtonFormField<String>(
                      value: draft.realizadoPor,
                      decoration: const InputDecoration(labelText: "REALIZADO POR"),
                      items: listInspectores.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => draft.realizadoPor = v),
                    ),
                    if(draft.realizadoPor != null)
                      Image.asset('assets/firmas/${_formatName(draft.realizadoPor!)}.png', height: 80, errorBuilder: (c, e, s) => const Text("Firma no encontrada", style: TextStyle(color: Colors.red))),
                  ],
                )
              ),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
                    onPressed: () { draft.clear(); Navigator.pop(context); },
                    child: const Text("CANCELAR"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: cBlue, foregroundColor: Colors.white),
                    onPressed: _validarYMostrarPreliminar,
                    child: const Text("VER PRELIMINAR"),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onPicked) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(date != null ? DateFormat('dd/MM/yyyy').format(date) : "Seleccionar fecha"),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        DateTime? p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
        if (p != null) onPicked(p);
      },
    );
  }

  Widget _buildDateWithCheckbox(String label, DateTime? date, bool isChecked, Function(DateTime) onPicked, Function(bool?) onChanged) {
    return Column(
      children: [
        _buildDatePicker(label, date, onPicked),
        CheckboxListTile(title: const Text("Se referencia el cuadro de rendición"), value: isChecked, onChanged: onChanged, controlAffinity: ListTileControlAffinity.leading)
      ],
    );
  }

  Widget _buildTimeWithCheckbox(String label, TimeOfDay? time, bool isChecked, Function(TimeOfDay) onPicked, Function(bool?) onChanged) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          subtitle: Text(time != null ? "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}" : "Seleccionar hora"),
          trailing: const Icon(Icons.access_time),
          onTap: () async {
            TimeOfDay? p = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            if (p != null) onPicked(p);
          },
        ),
        CheckboxListTile(title: const Text("Se referencia el cuadro de rendición"), value: isChecked, onChanged: onChanged, controlAffinity: ListTileControlAffinity.leading)
      ],
    );
  }

  String _getBankDetails(String name) {
    Map<String, String> d = {
      'Edinson Maschacuri': "BANCO DESTINO: INTERBANK\nN° CUENTA: 898350800266340\nCCI: 00389801350800266340\nYAPE: 901396071\nA nombre de: EDINSON SEBADIAN MASHACURI PANAIFO",
      'Bryan Ramos': "BANCO DESTINO: BCP\nN° CUENTA: 19173399032034\nCCI: 00219117339903203458\nPLIN / YAPE: 975535617\nA nombre de: Bryan Ramos Rojas",
      'Andrés Arenas': "BANCO DESTINO: INTERBANK\nN° CUENTA: 8983163637644\nCCI: 00389801316363764447\nPLIN/YAPE: 930896191\nA nombre de: ANDRES ARTURO ARENAS RODRIGUEZ",
      'Oliver Milla': "BANCO DESTINO: INTERBANK\nN° CUENTA: 8983474957987\nCCI: 00389801347495798743\nPLIN: 915193302\nA nombre de: Juan Oliver Milla Luyo",
      'Jhon Vega': "BANCO DESTINO: BCP\nN° CUENTA: 19197591176043\nCCI: 00219119759117604359\nYAPE: 912961208\nA nombre de: Jhon Vega Huillcas",
      'Victor Gil': "BANCO DESTINO: INTERBANK\nN° CUENTA: 8983416904989\nCCI: 00389801341690498944\nPLIN: 908628513\nA nombre de: Víctor Miguel Gil Miranda",
    };
    return d[name] ?? "Datos bancarios no disponibles";
  }

  void _validarYMostrarPreliminar() {
    if(!_formKey.currentState!.validate()) return;
    
    for (int i = 0; i < draft.items.length; i++) {
      var item = draft.items[i];
      if (item.tipoComprobante != 'Efectivo' && item.archivoBase64 == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("El ítem ${i + 1} requiere comprobante adjunto obligatoriamente."),
          backgroundColor: Colors.red,
        ));
        return;
      }
    }

    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PreliminarRendicionPage(
        onEnviar: () {
          Navigator.pop(context);
          _guardarRegistroFirebaseOffline();
        }
      )
    ));
  }

  void _guardarRegistroFirebaseOffline() {
    List<Map<String, dynamic>> itemsData = draft.items.map((i) => <String, dynamic>{
      'fecha_item': i.fecha != null ? DateFormat('dd/MM/yyyy').format(i.fecha!) : null,
      'tipo_gasto': i.tipoGasto,
      'descripcion': i.descripcion,
      'comprobante': i.tipoComprobante,
      'nro_comprobante': i.nroComprobante, 
      'importe': i.importe,
      'archivo_base64': i.archivoBase64,
      'alimentos_seleccionados': i.alimentos
    }).toList();

    double tGastado = draft.items.fold(0, (sum, i) => sum + i.importe);
    
    DocumentReference docRef = draft.docId != null 
        ? FirebaseFirestore.instance.collection('rendiciones').doc(draft.docId)
        : FirebaseFirestore.instance.collection('rendiciones').doc();
    
    docRef.set(<String, dynamic>{
      'fecha_sol': draft.fechaSol != null ? DateFormat('dd/MM/yyyy').format(draft.fechaSol!) : null,
      'area': 'Operaciones Alimentos',
      'os': draft.os,
      'lugar_servicio': draft.lugar,
      'fecha_salida': draft.refSalida ? 'Se referencia el cuadro de rendición' : (draft.fechaSalida != null ? DateFormat('dd/MM/yyyy').format(draft.fechaSalida!) : null),
      'fecha_inicio': draft.refInicio ? 'Se referencia el cuadro de rendición' : (draft.fechaInicio != null ? DateFormat('dd/MM/yyyy').format(draft.fechaInicio!) : null),
      'fecha_termino': draft.refTermino ? 'Se referencia el cuadro de rendición' : (draft.fechaTermino != null ? DateFormat('dd/MM/yyyy').format(draft.fechaTermino!) : null),
      'dias_ope': draft.diasOpe,
      'ejecutivo': draft.ejecutivo == 'Otros' ? draft.otroEjecutivo : draft.ejecutivo,
      'inspector1': draft.inspector1,
      'inspector2': draft.inspector2,
      'inspector3': draft.inspector3,
      'hora_inicio': draft.refHoraInicio ? 'Se referencia el cuadro de rendición' : (draft.horaInicio != null ? "${draft.horaInicio!.hour}:${draft.horaInicio!.minute}" : null),
      'hora_fin': draft.refHoraFin ? 'Se referencia el cuadro de rendición' : (draft.horaFin != null ? "${draft.horaFin!.hour}:${draft.horaFin!.minute}" : null),
      'items_rendicion': itemsData,
      'total_gastado': tGastado,
      'viaticos': 0.0,
      'devolver': 0.0 - tGastado,
      'observaciones': draft.observaciones,
      'detalles': draft.inspectorDeposito != null ? _getBankDetails(draft.inspectorDeposito!) : null,
      'realizado': draft.realizadoPor,
      'firma_ins': draft.realizadoPor != null ? 'assets/firmas/${_formatName(draft.realizadoPor!)}.png' : null,
      'estado': 'pendiente', 
      'timestamp': FieldValue.serverTimestamp() 
    }, SetOptions(merge: true)).catchError((e) {
      debugPrint("Error interno Firebase: $e");
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Rendición procesada. Se enviará automáticamente si hay conexión."),
      backgroundColor: cGreen,
      duration: Duration(seconds: 4),
    ));
    
    draft.clear(); 
    Navigator.pop(context); 
  }
}

class ItemRendicion {
  DateTime? fecha;
  String? tipoGasto;
  String descripcion = "";
  String? tipoComprobante;
  String nroComprobante = "";
  double importe = 0.0;
  String? archivoBase64;
  List<String> alimentos = []; 
}

class ItemRendicionWidget extends StatefulWidget {
  final ItemRendicion item;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const ItemRendicionWidget({required this.item, required this.index, required this.onDelete, required this.onUpdate});

  @override
  _ItemRendicionWidgetState createState() => _ItemRendicionWidgetState();
}

class _ItemRendicionWidgetState extends State<ItemRendicionWidget> {
  final picker = ImagePicker();
  String? errorLimite;

  void _validarLimites() {
    errorLimite = null;
    double maxPermitido = double.infinity;
    
    if(widget.item.tipoComprobante == 'Efectivo') maxPermitido = 8.0;
    
    if(widget.item.tipoGasto == 'Alimentación' && widget.item.alimentos.isNotEmpty) {
      List<String> a = widget.item.alimentos;
      bool hasD = a.contains('Desayuno'); bool hasA = a.contains('Almuerzo');
      bool hasC = a.contains('Cena'); bool hasB = a.contains('Bebidas');

      if (a.length == 1) {
        if(hasD) maxPermitido = 6.0; if(hasA) maxPermitido = 15.0;
        if(hasC) { maxPermitido = 15.0; WidgetsBinding.instance.addPostFrameCallback((_) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ALERTA: Cenas solo a partir de las 8:00 PM."))); }); }
        if(hasB) maxPermitido = 3.0;
      } else if (a.length == 2) {
        if(hasD && hasA) maxPermitido = 21.0; if(hasD && hasC) maxPermitido = 21.0;
        if(hasD && hasB) maxPermitido = 9.0; if(hasA && hasC) maxPermitido = 30.0;
        if(hasB && hasC) maxPermitido = 18.0; if(hasA && hasB) maxPermitido = 18.0;
      } else if (a.length >= 3) {
        maxPermitido = 35.0;
      }
    }

    if(widget.item.importe > maxPermitido) {
      errorLimite = "Excede el máximo (S/ ${maxPermitido.toStringAsFixed(2)})";
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 30);
    if (pickedFile != null) {
      List<int> imageBytes = await pickedFile.readAsBytes();
      setState(() => widget.item.archivoBase64 = base64Encode(imageBytes));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Imagen adjuntada")));
    }
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      List<int> fileBytes = await file.readAsBytes();
      setState(() => widget.item.archivoBase64 = base64Encode(fileBytes));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PDF adjuntado")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: clayBox,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Ítem ${widget.index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: cBlue)),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: widget.onDelete)
            ],
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Fecha"),
            subtitle: Text(widget.item.fecha != null ? DateFormat('dd/MM/yyyy').format(widget.item.fecha!) : "Seleccionar"),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              DateTime? p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
              if(p != null) setState(() => widget.item.fecha = p);
            },
          ),
          DropdownButtonFormField<String>(
            value: widget.item.tipoGasto,
            decoration: const InputDecoration(labelText: "Tipo de gasto"),
            items: ['Alimentación', 'Hospedaje', 'Movilidad', 'Otros'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() { widget.item.tipoGasto = v; widget.item.alimentos.clear(); _validarLimites(); widget.onUpdate(); }),
          ),
          if(widget.item.tipoGasto == 'Alimentación')
            Wrap(
              spacing: 8.0,
              children: ['Desayuno', 'Almuerzo', 'Cena', 'Bebidas'].map((meal) {
                bool isSel = widget.item.alimentos.contains(meal);
                return FilterChip(
                  label: Text(meal), selected: isSel, selectedColor: cOrange.withOpacity(0.3),
                  onSelected: (val) { setState(() { val ? widget.item.alimentos.add(meal) : widget.item.alimentos.remove(meal); _validarLimites(); widget.onUpdate(); }); },
                );
              }).toList(),
            ),
          
          TextFormField(
            initialValue: widget.item.descripcion,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: "Descripción"), maxLines: null,
            onChanged: (v) => widget.item.descripcion = v,
          ),
          
          DropdownButtonFormField<String>(
            value: widget.item.tipoComprobante,
            decoration: const InputDecoration(labelText: "Tipo de comprobante"),
            items: ['Yape', 'Plin', 'Boleta', 'Factura', 'Ticket', 'Efectivo', 'Otros'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() { widget.item.tipoComprobante = v; _validarLimites(); }),
          ),
          
          TextFormField(
            initialValue: widget.item.nroComprobante,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: "N° o Serie de Comprobante (Opcional)"),
            onChanged: (v) => widget.item.nroComprobante = v,
          ),

          const Padding(padding: EdgeInsets.only(top: 15.0), child: Text("Comprobante Gráfico (Adjuntar)", style: TextStyle(fontSize: 12, color: Colors.grey))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(icon: const Icon(Icons.camera_alt, color: cBlue), onPressed: () => _pickImage(ImageSource.camera)),
              IconButton(icon: const Icon(Icons.image, color: cGreen), onPressed: () => _pickImage(ImageSource.gallery)),
              IconButton(icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent), onPressed: _pickPDF),
            ],
          ),
          if(widget.item.archivoBase64 != null)
             const Text("✅ Archivo adjunto cargado", style: TextStyle(color: cGreen, fontSize: 12, fontWeight: FontWeight.bold)),
             
          TextFormField(
            initialValue: widget.item.importe == 0 ? "" : widget.item.importe.toString(),
            decoration: InputDecoration(labelText: "Importe (S/)", errorText: errorLimite, labelStyle: TextStyle(color: errorLimite != null ? Colors.red : null)),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: errorLimite != null ? Colors.red : Colors.black, fontWeight: errorLimite != null ? FontWeight.bold : FontWeight.normal),
            onChanged: (v) {
              setState(() { widget.item.importe = double.tryParse(v.replaceAll(',', '.')) ?? 0.0; _validarLimites(); widget.onUpdate(); });
            },
          ),
        ],
      ),
    );
  }
}

class VerRendicionesPage extends StatefulWidget {
  @override
  _VerRendicionesPageState createState() => _VerRendicionesPageState();
}

class _VerRendicionesPageState extends State<VerRendicionesPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cBg,
        appBar: AppBar(
          title: const Text("Historial de Rendiciones"), 
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: "Buscar por OS...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: cBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  setState(() {
                    searchQuery = val.toUpperCase();
                  });
                },
              ),
            ),
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('rendiciones').orderBy('timestamp', descending: true).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            var filteredDocs = snapshot.data!.docs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String os = (data['os'] ?? '').toString().toUpperCase();
              return os.contains(searchQuery);
            }).toList();
  
            if (filteredDocs.isEmpty) return const Center(child: Text("No se encontraron rendiciones."));
  
            return ListView(
              padding: const EdgeInsets.all(16),
              children: filteredDocs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                String estado = data['estado'] ?? 'pendiente';
                Color statusColor = cOrange;
                IconData statusIcon = Icons.pending;
  
                if (estado == 'aprobada') { statusColor = cGreen; statusIcon = Icons.check_circle; }
                if (estado == 'observada') { statusColor = Colors.amber; statusIcon = Icons.warning; }
                if (estado == 'rechazada') { statusColor = Colors.red; statusIcon = Icons.cancel; }
  
                return Card(
                  color: Colors.white, elevation: 4, margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text("OS: ${data['os'] ?? 'Sin OS'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Total: S/ ${data['total_gastado']?.toStringAsFixed(2) ?? '0.00'}\nEstado: ${estado.toUpperCase()}"),
                    trailing: Icon(statusIcon, color: statusColor),
                    onTap: () => _mostrarAcciones(context, data, doc.id, estado),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  void _mostrarAcciones(BuildContext context, Map<String, dynamic> data, String docId, String estado) {
    String titulo = "";
    String cuerpo = "";
    String txtBoton = "VER RENDICIÓN";
    bool puedeModificar = false;

    if (estado == 'aprobada') {
      titulo = "Rendición de gastos aprobada";
      cuerpo = "Autorizado por: ${data['supervisor'] ?? 'N/A'}";
    } else if (estado == 'observada') {
      titulo = "Rendición de gastos observada";
      cuerpo = "Revisado por: ${data['supervisor'] ?? 'N/A'}\nMotivo: ${data['motivo_observacion'] ?? 'No especificado'}";
      txtBoton = "MODIFICAR RENDICIÓN";
      puedeModificar = true;
    } else if (estado == 'rechazada') {
      titulo = "Rendición de gastos rechazada";
      cuerpo = "Denegado por: ${data['supervisor'] ?? 'N/A'}\nMotivo: ${data['motivo_rechazo'] ?? 'No especificado'}";
    } else {
      titulo = "Rendición de gastos pendiente";
      cuerpo = "Aún no ha sido revisada.";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Text(cuerpo),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("ACEPTAR")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: puedeModificar ? cOrange : cBlue),
              onPressed: () {
                Navigator.pop(context);
                if (puedeModificar) {
                  _cargarParaEdicion(data, docId);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GenerarRendicionPage()));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => VerDetalleRendicionPage(data: data)));
                }
              },
              child: Text(txtBoton, style: const TextStyle(color: Colors.white)),
            )
          ],
        );
      }
    );
  }

  DateTime? _parseDateHelper(String? dateStr) {
    if (dateStr == null || dateStr == 'Se referencia el cuadro de rendición') return null;
    try { return DateFormat('dd/MM/yyyy').parse(dateStr); } catch (e) { return null; }
  }

  TimeOfDay? _parseTimeHelper(String? timeStr) {
    if (timeStr == null || timeStr == 'Se referencia el cuadro de rendición') return null;
    try {
      List<String> parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) { return null; }
  }

  void _cargarParaEdicion(Map<String, dynamic> data, String docId) {
    final draft = RendicionDraft.instance;
    draft.clear();
    draft.docId = docId;

    draft.fechaSol = _parseDateHelper(data['fecha_sol']);
    draft.os = data['os'] ?? '';
    draft.lugar = data['lugar_servicio'] ?? '';
    draft.refSalida = data['fecha_salida'] == 'Se referencia el cuadro de rendición';
    if (!draft.refSalida) draft.fechaSalida = _parseDateHelper(data['fecha_salida']);
    
    draft.refInicio = data['fecha_inicio'] == 'Se referencia el cuadro de rendición';
    if (!draft.refInicio) draft.fechaInicio = _parseDateHelper(data['fecha_inicio']);

    draft.refTermino = data['fecha_termino'] == 'Se referencia el cuadro de rendición';
    if (!draft.refTermino) draft.fechaTermino = _parseDateHelper(data['fecha_termino']);

    draft.diasOpe = data['dias_ope'] ?? 1;
    draft.ejecutivo = ['Gabriel Albornoz', 'Rosemery Conislla', 'Sandra Velásquez', 'Magaly Palacios', 'Marco Urrunaga', 'Giovanna Reyes', 'Rossmery Ocas', 'Mariana Romero'].contains(data['ejecutivo']) ? data['ejecutivo'] : 'Otros';
    if (draft.ejecutivo == 'Otros') draft.otroEjecutivo = data['ejecutivo'] ?? '';
    
    draft.inspector1 = data['inspector1'];
    draft.inspector2 = data['inspector2'];
    draft.inspector3 = data['inspector3'];

    draft.refHoraInicio = data['hora_inicio'] == 'Se referencia el cuadro de rendición';
    if (!draft.refHoraInicio) draft.horaInicio = _parseTimeHelper(data['hora_inicio']);

    draft.refHoraFin = data['hora_fin'] == 'Se referencia el cuadro de rendición';
    if (!draft.refHoraFin) draft.horaFin = _parseTimeHelper(data['hora_fin']);

    draft.observaciones = data['observaciones'] ?? '';
    draft.realizadoPor = data['realizado'];

    List<dynamic> itemsData = data['items_rendicion'] ?? [];
    for (var iData in itemsData) {
      ItemRendicion it = ItemRendicion();
      it.fecha = _parseDateHelper(iData['fecha_item']);
      it.tipoGasto = iData['tipo_gasto'];
      it.descripcion = iData['descripcion'] ?? '';
      it.tipoComprobante = iData['comprobante'];
      it.nroComprobante = iData['nro_comprobante'] ?? '';
      it.importe = (iData['importe'] ?? 0.0).toDouble();
      it.archivoBase64 = iData['archivo_base64'];
      it.alimentos = List<String>.from(iData['alimentos_seleccionados'] ?? []);
      draft.items.add(it);
    }
  }
}

class VerDetalleRendicionPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const VerDetalleRendicionPage({Key? key, required this.data}) : super(key: key);

  String _formatName(String name) {
    return name.toLowerCase()
        .replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i')
        .replaceAll('ó', 'o').replaceAll('ú', 'u').replaceAll(' ', '_');
  }

  void _verComprobante(BuildContext context, String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Este ítem no tiene comprobante adjunto.")));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Comprobante"),
          content: base64Str.startsWith('JVBERi0') 
            ? const SizedBox(height: 200, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.picture_as_pdf, size: 50, color: Colors.red), Text("Documento PDF adjunto (requiere visor externo)")],)))
            : Image.memory(base64Decode(base64Str)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CERRAR"))
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> itemsData = data['items_rendicion'] ?? [];
    
    List<String> inspectores = [];
    if (data['inspector1'] != null && data['inspector1'].toString().isNotEmpty) inspectores.add(data['inspector1']);
    if (data['inspector2'] != null && data['inspector2'].toString().isNotEmpty) inspectores.add(data['inspector2']);
    if (data['inspector3'] != null && data['inspector3'].toString().isNotEmpty) inspectores.add(data['inspector3']);
    String inspectoresTexto = inspectores.isEmpty ? '-' : inspectores.join(', ');

    String horaInicio = data['hora_inicio'] ?? '-';
    String horaFin = data['hora_fin'] ?? '-';
    
    return Scaffold(
      backgroundColor: cBg,
      appBar: AppBar(title: const Text("Detalle de Rendición"), backgroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: clayBox,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("OS: ${data['os'] ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text("Lugar: ${data['lugar_servicio'] ?? '-'}"),
                Text("Ejecutivo: ${data['ejecutivo'] ?? '-'}"),
                const Divider(),
                Text("Fecha de Salida: ${data['fecha_salida'] ?? '-'}"),
                Text("Fecha de Inicio: ${data['fecha_inicio'] ?? '-'}"),
                Text("Fecha de Fin: ${data['fecha_termino'] ?? '-'}"),
                Text("Hora de Inicio / Fin: $horaInicio / $horaFin"),
                const Divider(),
                Text("Inspectores: $inspectoresTexto"),
                Text("Observaciones: ${data['observaciones'] ?? '-'}"),
                const Divider(),
                const Text("Inspector a depositar:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${data['detalles'] ?? '-'}"), 
                const Divider(),
                Text("Realizado por: ${data['realizado'] ?? '-'}"),
                if (data['realizado'] != null && data['realizado'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Image.asset(
                      'assets/firmas/${_formatName(data['realizado'])}.png', 
                      height: 80, 
                      errorBuilder: (c, e, s) => const Text("Firma no encontrada", style: TextStyle(color: Colors.red))
                    ),
                  ),
                const Divider(),
                Text("Total Gastado: S/ ${data['total_gastado']?.toStringAsFixed(2) ?? '0.00'}", style: const TextStyle(fontWeight: FontWeight.bold, color: cBlue)),
              ],
            )
          ),
          const SizedBox(height: 20),
          const Text("Ítems de Rendición (Toque un ítem para ver el comprobante)", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...itemsData.map((item) {
            return Card(
              child: ListTile(
                title: Text("${item['tipo_gasto']} - ${item['descripcion']}"),
                subtitle: Text("Importe: S/ ${item['importe']} | Comp: ${item['comprobante']} ${item['nro_comprobante'] ?? ''}"),
                trailing: const Icon(Icons.image, color: cOrange),
                onTap: () => _verComprobante(context, item['archivo_base64']),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class PreliminarRendicionPage extends StatelessWidget {
  final VoidCallback onEnviar;

  const PreliminarRendicionPage({Key? key, required this.onEnviar}) : super(key: key);

  void _verComprobante(BuildContext context, String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Este ítem no tiene comprobante adjunto.")));
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Comprobante Adjunto"),
          content: base64Str.startsWith('JVBERi0')
            ? const SizedBox(height: 200, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.picture_as_pdf, size: 50, color: Colors.red), Text("Documento PDF adjunto")])))
            : Image.memory(base64Decode(base64Str)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CERRAR"))
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = RendicionDraft.instance;
    double totalGastado = draft.items.fold(0, (sum, item) => sum + item.importe);

    List<String> inspectores = [];
    if (draft.inspector1 != null && draft.inspector1!.isNotEmpty) inspectores.add(draft.inspector1!);
    if (draft.inspector2 != null && draft.inspector2!.isNotEmpty) inspectores.add(draft.inspector2!);
    if (draft.inspector3 != null && draft.inspector3!.isNotEmpty) inspectores.add(draft.inspector3!);
    String inspectoresTexto = inspectores.isEmpty ? '-' : inspectores.join(', ');

    String horaInicioStr = draft.refHoraInicio ? 'Se referencia cuadro' : (draft.horaInicio != null ? "${draft.horaInicio!.hour.toString().padLeft(2, '0')}:${draft.horaInicio!.minute.toString().padLeft(2, '0')}" : '-');
    String horaFinStr = draft.refHoraFin ? 'Se referencia cuadro' : (draft.horaFin != null ? "${draft.horaFin!.hour.toString().padLeft(2, '0')}:${draft.horaFin!.minute.toString().padLeft(2, '0')}" : '-');
    
    String fSalida = draft.refSalida ? 'Se referencia cuadro' : (draft.fechaSalida != null ? DateFormat('dd/MM/yyyy').format(draft.fechaSalida!) : '-');
    String fInicio = draft.refInicio ? 'Se referencia cuadro' : (draft.fechaInicio != null ? DateFormat('dd/MM/yyyy').format(draft.fechaInicio!) : '-');
    String fTermino = draft.refTermino ? 'Se referencia cuadro' : (draft.fechaTermino != null ? DateFormat('dd/MM/yyyy').format(draft.fechaTermino!) : '-');

    return Scaffold(
      backgroundColor: cBg,
      appBar: AppBar(title: const Text("Vista Preliminar", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Por favor, revise minuciosamente los datos antes de enviar.", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: clayBox,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("OS: ${draft.os}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text("Lugar: ${draft.lugar}"),
                Text("Ejecutivo: ${draft.ejecutivo == 'Otros' ? draft.otroEjecutivo : (draft.ejecutivo ?? '-') }"),
                const Divider(),
                Text("Fecha de Salida: $fSalida"),
                Text("Fecha de Inicio: $fInicio"),
                Text("Fecha de Fin: $fTermino"),
                Text("Hora de Inicio / Fin: $horaInicioStr / $horaFinStr"),
                const Divider(),
                Text("Inspectores: $inspectoresTexto"),
                Text("Observaciones: ${draft.observaciones.isEmpty ? '-' : draft.observaciones}"),
                const Divider(),
                Text("Inspector a depositar: ${draft.inspectorDeposito ?? '-'}"),
                const Divider(),
                Text("Realizado por: ${draft.realizadoPor ?? '-'}"),
                const Divider(),
                Text("Total Gastado: S/ ${totalGastado.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: cBlue)),
              ],
            )
          ),
          const SizedBox(height: 20),
          const Text("Ítems de Rendición (Toque un ítem para ver el comprobante)", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...draft.items.map((item) {
            String fItem = item.fecha != null ? DateFormat('dd/MM/yyyy').format(item.fecha!) : '-';
            return Card(
              elevation: 3,
              child: ListTile(
                title: Text("${item.tipoGasto} - ${item.descripcion}", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Fecha: $fItem | Importe: S/ ${item.importe}\nComp: ${item.tipoComprobante} ${item.nroComprobante}"),
                trailing: const Icon(Icons.image, color: cOrange, size: 30),
                isThreeLine: true,
                onTap: () => _verComprobante(context, item.archivoBase64),
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                icon: const Icon(Icons.arrow_back),
                label: const Text("VOLVER"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: cGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                icon: const Icon(Icons.send),
                label: const Text("ENVIAR RENDICIÓN"),
                onPressed: onEnviar,
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}