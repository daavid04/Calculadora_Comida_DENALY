import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculadoraPollosApp());
}

class CalculadoraPollosApp extends StatelessWidget {
  const CalculadoraPollosApp({super.key});

  @override
  Widget build(BuildContext me) {
    return MaterialApp(
      title: 'Calculadora Pollos de Engorde',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F497D)),
        useMaterial3: true,
      ),
      home: const CalculadoraScreen(),
    );
  }
}

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});

  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  final TextEditingController _pollosController = TextEditingController(text: '800');
  final TextEditingController _desperdicioController = TextEditingController(text: '5');

  // Parámetros de formulación por fase
  final List<Map<String, dynamic>> _fasesParam = [
    {
      'nombre': 'Iniciador',
      'dias': '1 - 21',
      'consumoPollo': 1.00,
      'maizPct': 0.58,
      'soyaPct': 0.36,
      'aceitePct': 0.02,
      'nucleoPct': 0.04,
    },
    {
      'nombre': 'Crecimiento',
      'dias': '22 - 35',
      'consumoPollo': 1.80,
      'maizPct': 0.63,
      'soyaPct': 0.31,
      'aceitePct': 0.025,
      'nucleoPct': 0.035,
    },
    {
      'nombre': 'Engorde',
      'dias': '36 - 42',
      'consumoPollo': 1.70,
      'maizPct': 0.68,
      'soyaPct': 0.25,
      'aceitePct': 0.035,
      'nucleoPct': 0.035,
    },
  ];

  @override
  Widget build(BuildContext context) {
    int numPollos = int.tryParse(_pollosController.text) ?? 0;
    double despPct = (double.tryParse(_desperdicioController.text) ?? 0) / 100.0;

    // Cálculos por fase
    double totalMaiz = 0;
    double totalSoya = 0;
    double totalAceite = 0;
    double totalNucleo = 0;
    double totalAlimento = 0;

    List<Map<String, dynamic>> resultadosFases = [];

    for (var fase in _fasesParam) {
      double alimentoBase = numPollos * (fase['consumoPollo'] as double);
      double alimentoTotal = alimentoBase * (1 + despPct);
      double maizKg = alimentoTotal * (fase['maizPct'] as double);
      double soyaKg = alimentoTotal * (fase['soyaPct'] as double);
      double aceiteKg = alimentoTotal * (fase['aceitePct'] as double);
      double nucleoKg = alimentoTotal * (fase['nucleoPct'] as double);

      totalMaiz += maizKg;
      totalSoya += soyaKg;
      totalAceite += aceiteKg;
      totalNucleo += nucleoKg;
      totalAlimento += alimentoTotal;

      resultadosFases.add({
        'nombre': fase['nombre'],
        'baseKg': alimentoBase,
        'totalKg': alimentoTotal,
        'maizKg': maizKg,
        'soyaKg': soyaKg,
        'aceiteKg': aceiteKg,
        'nucleoKg': nucleoKg,
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Insumos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1F497D),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Corregido aquí
          children: [
            // 1. Entradas de datos
            _buildSectionHeader('1. Parámetros de Cultivo'),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pollosController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Número de Pollos',
                          border: OutlineInputBorder(),
                          suffixText: 'aves',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _desperdicioController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Desperdicio',
                          border: OutlineInputBorder(),
                          suffixText: '%',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Resumen de Compra
            _buildSectionHeader('2. Resumen de Compra y Sacos (50 kg)'),
            _buildResumenCard('Maíz Amarillo Molido', totalMaiz),
            _buildResumenCard('Torta de Soya', totalSoya),
            _buildResumenCard('Aceite Vegetal', totalAceite),
            _buildResumenCard('Núcleo / Premix', totalNucleo),
            const Divider(),
            _buildResumenCard('TOTAL ALIMENTO', totalAlimento, isTotal: true),

            const SizedBox(height: 20),

            // 3. Detalle por fase
            _buildSectionHeader('3. Desglose por Fase'),
            ...resultadosFases.map((res) => _buildFaseTile(res)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F497D)),
      ),
    );
  }

  Widget _buildResumenCard(String insumo, double kg, {bool isTotal = false}) {
    int sacos = (kg / 50.0).ceil();
    return Card(
      color: isTotal ? const Color(0xFFDCE6F1) : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(insumo, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        subtitle: Text('${kg.toStringAsFixed(1)} kg total'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1F497D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$sacos sacos',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildFaseTile(Map<String, dynamic> res) {
    return ExpansionTile(
      title: Text('${res['nombre']} (${res['totalKg'].toStringAsFixed(1)} kg)'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              _rowVal('Maíz Molido:', '${res['maizKg'].toStringAsFixed(1)} kg'),
              _rowVal('Torta de Soya:', '${res['soyaKg'].toStringAsFixed(1)} kg'),
              _rowVal('Aceite Vegetal:', '${res['aceiteKg'].toStringAsFixed(1)} kg'),
              _rowVal('Núcleo / Premix:', '${res['nucleoKg'].toStringAsFixed(1)} kg'),
            ],
          ),
        )
      ],
    );
  }

  Widget _rowVal(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
