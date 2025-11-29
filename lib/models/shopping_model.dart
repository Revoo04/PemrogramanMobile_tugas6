class ShoppingItem {
  String id;
  String name;
  String amount; // Misal: "2 Kg", "5 Pcs"
  String category; // Makanan, Minuman, dll
  bool isBought; // Sudah dibeli atau belum

  ShoppingItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    this.isBought = false,
  });

  // Convert dari JSON (Storage) ke Object
  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      category: json['category'],
      isBought: json['isBought'],
    );
  }

  // Convert dari Object ke JSON (Storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'isBought': isBought,
    };
  }
}