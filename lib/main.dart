import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PassageiroProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lota-o-de-viagem',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class Passageiro {
  String nome;
  double valor;
  bool pago;

  Passageiro({
    required this.nome,
    required this.valor,
    this.pago = false,
  });
}

class PassageiroProvider extends ChangeNotifier {
  final List<Passageiro> _lista = [];

  List<Passageiro> get lista => _lista;

  double get totalArrecadado =>
      _lista.where((p) => p.pago).fold(0, (s, p) => s + p.valor);

  double get totalNaoPago =>
      _lista.where((p) => !p.pago).fold(0, (s, p) => s + p.valor);

  void adicionar(String nome, double valor) {
    _lista.add(Passageiro(nome: nome, valor: valor));
    notifyListeners();
  }

  void alterarStatus(int index) {
    _lista[index].pago = !_lista[index].pago;
    notifyListeners();
  }

  void remover(int index) {
    _lista.removeAt(index);
    notifyListeners();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<PassageiroProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lota-o-de-viagem'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: prov.lista.length,
              itemBuilder: (_, i) {
                final p = prov.lista[i];
                return Card(
                  child: ListTile(
                    title: Text(p.nome),
                    subtitle: Text(
                      'Valor: R\$ ${p.valor.toStringAsFixed(2)} - ${p.pago ? "Pago" : "Não pago"}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: p.pago,
                          onChanged: (_) => prov.alterarStatus(i),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => prov.remover(i),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Total Pago: R\$ ${prov.totalArrecadado.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Total Não Pago: R\$ ${prov.totalNaoPago.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddPassageiroDialog(),
          );
        },
      ),
    );
  }
}

class AddPassageiroDialog extends StatefulWidget {
  const AddPassageiroDialog({super.key});

  @override
  State<AddPassageiroDialog> createState() => _AddPassageiroDialogState();
}

class _AddPassageiroDialogState extends State<AddPassageiroDialog> {
  final nomeCtrl = TextEditingController();
  final valorCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar passageiro'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nomeCtrl,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          TextField(
            controller: valorCtrl,
            decoration: const InputDecoration(labelText: 'Valor'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Adicionar'),
          onPressed: () {
            final nome = nomeCtrl.text;
            final valor = double.tryParse(valorCtrl.text) ?? 0.0;

            if (nome.isNotEmpty && valor > 0) {
              Provider.of<PassageiroProvider>(context, listen: false)
                  .adicionar(nome, valor);
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
