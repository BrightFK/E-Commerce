import 'package:e_comm/extension.dart';
import 'package:e_comm/models/cart_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(cartItem) {
    _items.add(cartItem);
    notifyListeners();
  }

  double get totalPrice {
    double sum = 0;
    for (var item in _items) {
      sum += item.product.price * item.qty;
    }
    return sum;
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
