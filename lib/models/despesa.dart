class Despesa {
  final int? id;
  final String descricao;
  final double valor;
  final DateTime data;
  final String categoria;

  Despesa({
    this.id,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.categoria,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'valor': valor,
      'data': data.toIso8601String(),
      'categoria': categoria,
    };
  }

  factory Despesa.fromMap(Map<String, dynamic> map) {
    return Despesa(
      id: map['id'],
      descricao: map['descricao'],
      valor: map['valor'],
      data: DateTime.parse(map['data']),
      categoria: map['categoria'],
    );
  }
}