import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

void main() {
  runApp(MeuApp());
}

// Classe para a tela inicial com o logo
class TelaInicialLogo extends StatefulWidget {
  @override
  _TelaInicialLogoState createState() => _TelaInicialLogoState();
}

class _TelaInicialLogoState extends State<TelaInicialLogo> {
  @override
  void initState() {
    super.initState();
    // Aguarda 3 segundos antes de mudar para a tela principal
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => TelaPrincipal()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo com gradiente suave
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[300]!, Colors.teal[700]!], // Gradiente de verde
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            'Controle de Gastos', // Texto exibido na tela inicial
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// Classe principal do aplicativo
class MeuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModeloGastos(), // Cria o modelo para gerenciar o estado
      child: MaterialApp(
        title: 'Controle de Gastos',
        theme: ThemeData(
          primaryColor: Colors.teal,
          hintColor: Colors.amber,
          textTheme: TextTheme(
            headline6: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            bodyText2: TextStyle(fontSize: 16.0),
          ),
        ),
        home: TelaInicialLogo(), // Tela inicial com o logo
      ),
    );
  }
}

// Tela principal do aplicativo
class TelaPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtém o modelo de gastos a partir do Provider
    final modelo = Provider.of<ModeloGastos>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Controle de Gastos'),
      ),
      // Fundo com gradiente suave
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal[50]!], // Gradiente suave do branco para verde claro
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Exibe uma lista de atividades de gasto
              Expanded(
                child: ListView.builder(
                  itemCount: modelo.atividades.length,
                  itemBuilder: (context, index) {
                    final atividade = modelo.atividades[index];
                    return Card(
                      elevation: 4.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        title: Text(
                          atividade.nome,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(
                          'Gasto: R\$ ${atividade.gasto.toStringAsFixed(2)} - Data: ${DateFormat.yMMMd().format(atividade.data)}',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () => _mostrarDialogoAdicionarAtividade(context),
                  child: Text('Adicionar Gasto'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Visão Geral dos Gastos',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(
                height: 200,
                child: GraficoDeGastos(dados: modelo.atividades), // Gráfico de gastos
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Função para exibir o diálogo de adicionar nova atividade de gasto
  void _mostrarDialogoAdicionarAtividade(BuildContext context) {
    final nomeController = TextEditingController();
    final gastoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Gasto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Descrição do Gasto',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: gastoController,
                decoration: InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final nome = nomeController.text;
                final gasto = double.tryParse(gastoController.text) ?? 0.0;
                if (nome.isNotEmpty && gasto > 0) {
                  Provider.of<ModeloGastos>(context, listen: false)
                      .adicionarAtividade(Atividade(nome, gasto, DateTime.now()));
                  Navigator.of(context).pop();
                }
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }
}

// Widget para exibir o gráfico de barras dos gastos
class GraficoDeGastos extends StatelessWidget {
  final List<Atividade> dados;

  GraficoDeGastos({required this.dados});

  @override
  Widget build(BuildContext context) {
    final listaSeries = [
      charts.Series<Atividade, String>(
        id: 'Gastos',
        colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault,
        domainFn: (Atividade atividade, _) => atividade.nome,
        measureFn: (Atividade atividade, _) => atividade.gasto,
        data: dados,
      ),
    ];

    return charts.BarChart(
      listaSeries,
      animate: true,
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(fontSize: 12),
        ),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(fontSize: 12),
        ),
      ),
    );
  }
}

// Modelo que representa uma atividade de gasto
class Atividade {
  final String nome;
  final double gasto;
  final DateTime data;

  Atividade(this.nome, this.gasto, this.data);
}

// Modelo que gerencia a lista de atividades e notifica os ouvintes sobre mudanças
class ModeloGastos with ChangeNotifier {
  final List<Atividade> _atividades = [];

  List<Atividade> get atividades => _atividades;

  void adicionarAtividade(Atividade atividade) {
    _atividades.add(atividade);
    notifyListeners(); // Notifica os ouvintes sobre as mudanças na lista de atividades
  }
}
