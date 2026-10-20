import 'package:flutter/material.dart';
import 'theme.dart';
import 'api.dart';

// ====================== MODELS ======================
class Product {
  final String id, name, category, desc;
  final int price;
  final Color color;
  final bool drink;
  final String? badge;
  const Product(this.id, this.name, this.category, this.price, this.color,
      {this.desc = '', this.drink = true, this.badge});
}

class CartItem {
  Product p;
  String size, ice, sugar, note;
  int qty;
  CartItem(this.p,
      {this.size = 'Regular',
      this.ice = 'Normal Ice',
      this.sugar = 'Normal Sugar',
      this.note = '',
      this.qty = 1});
  int get unit => p.price + (p.drink && size == 'Large' ? 4000 : 0);
  int get total => unit * qty;
  String get variant => p.drink ? '$ice, $sugar' : '';
  String get title => p.drink ? '${p.name} $size' : p.name;
  bool same(CartItem o) =>
      o.p.id == p.id && o.size == size && o.ice == ice && o.sugar == sugar && o.note == note;
}

class Outlet {
  final String name, address, distance, hours;
  final bool delivery, pickup, drive;
  const Outlet(this.name, this.address, this.distance, this.hours,
      {this.delivery = true, this.pickup = true, this.drive = false});
}

class Addr {
  int? id; // id di database (null = alamat sementara / belum disimpan)
  String label, detail;
  Addr(this.label, this.detail, {this.id});
}

class Voucher {
  final String code, title, desc, type; // pct, flat, b1g1, free, ship
  final int value;
  final int? uvId; // id baris voucher milik user di database (null = kode promo umum)
  Voucher(this.code, this.title, this.desc, this.type, this.value, {this.uvId});
}

class OrderRec {
  final String id, date, mode, outlet, payment, status;
  final List<CartItem> items;
  final int total;
  OrderRec(this.id, this.date, this.mode, this.outlet, this.payment, this.items,
      this.total, this.status);
}

class Notif {
  final String title, body, time;
  bool read;
  final int? id; // id di database (null = notifikasi lokal untuk tamu)
  Notif(this.title, this.body, this.time, {this.read = false, this.id});
}

class PayMethod {
  final String id, name, sub;
  final Color color;
  final IconData icon;
  final bool needsLink;
  bool linked;
  PayMethod(this.id, this.name, this.sub, this.color, this.icon,
      {this.needsLink = false, this.linked = true});
}

class UserProfile {
  String name = 'Pengguna Mantan';
  String email = '';
  bool emailVerified = false;
  String phone = '';
  String gender = 'Rahasia';
  DateTime? birth;
  String city = '';
  bool googleLinked = false;
  String pin = '';
}

// ====================== DATA ======================
const _cream = Color(0xFFE8C9A0);
const _coffee = Color(0xFFB77B4B);
const _dark = Color(0xFF6B3E26);
const _taro = Color(0xFFB58BE0);
const _matcha = Color(0xFF8FC26B);
const _choc = Color(0xFF7A4A33);
const _pink = Color(0xFFE88BA0);
const _orange = Color(0xFFE9A04B);

List<Product> allProducts = [
  // Promo & Combo
  Product('p1', 'Free Upsize Large', 'Promo & Combo', 17000, _dark,
      desc: 'Gratis upsize ke ukuran Large untuk minuman pilihan.', badge: 'GRATIS UPSIZE'),
  Product('p2', 'Buy 2 Disc 25%', 'Promo & Combo', 28500, _taro,
      desc: 'Beli 2 minuman Purple Cloud Series diskon 25%.'),
  Product('p3', '2 KMN Hanya', 'Promo & Combo', 29900, _cream,
      desc: 'Dua Es Kopi Mantan hanya Rp29.900. Promo Delivery.', badge: 'Promo Delivery'),
  // Baru
  Product('n1', 'Taro Cloud Matcha', 'Baru!', 22000, _matcha,
      desc: 'Matcha creamy dengan cloud taro di atasnya.', badge: 'New'),
  Product('n2', 'Taro Milk', 'Baru!', 19000, _taro,
      desc: 'Susu taro lembut dengan cloud ungu.', badge: 'New'),
  Product('n3', 'Taro Cloud Latte', 'Baru!', 24000, _taro,
      desc: 'Espresso, susu, dan cloud taro.', badge: 'New'),
  Product('n4', 'Taro Cloud Coffee', 'Baru!', 25000, _coffee,
      desc: 'Kopi susu dengan cloud taro.', badge: 'New'),
  // Coffee
  Product('c1', 'Butterscotch Sea Salt Latte Ice Mantan Blend Milk', 'Coffee', 29000, _orange,
      desc: 'Espresso Mantan Blend, susu, sirup butterscotch dan sea salt cream.'),
  Product('c2', 'Es Kopi Mantan Blend', 'Coffee', 22000, _coffee,
      desc: 'Kopi susu khas Kopi Mantan dengan gula aren.'),
  Product('c3', 'Americano', 'Coffee', 18000, _dark, desc: 'Espresso dengan air, segar dan tegas.'),
  Product('c4', 'Caramel Macchiato', 'Coffee', 28000, _orange, desc: 'Espresso, susu, dan saus karamel.'),
  Product('c5', 'Cappuccino', 'Coffee', 26000, _cream, desc: 'Espresso dengan foam susu tebal.'),
  Product('c6', 'Kopi Susu Aren', 'Coffee', 24000, _coffee, desc: 'Kopi susu dengan gula aren asli.'),
  // Non coffee
  Product('s1', 'Chocolate', 'Non Coffee', 25000, _choc, desc: 'Cokelat pekat dengan susu segar.'),
  Product('s2', 'Matcha Latte', 'Non Coffee', 27000, _matcha, desc: 'Matcha premium dengan susu.'),
  Product('s3', 'Red Velvet', 'Non Coffee', 26000, _pink, desc: 'Red velvet creamy manis lembut.'),
  Product('s4', 'Thai Tea', 'Non Coffee', 22000, _orange, desc: 'Teh Thailand klasik dengan susu.'),
  // Toast
  Product('t1', 'Choco Cheese Toast', 'Kenangan Toast', 18000, _choc,
      drink: false, desc: 'Roti panggang isi cokelat dan keju.'),
  Product('t2', 'Beef Cheese Toast', 'Kenangan Toast', 24000, _orange,
      drink: false, desc: 'Roti panggang isi beef dan keju leleh.'),
  Product('t3', 'Egg Mayo Toast', 'Kenangan Toast', 20000, _cream,
      drink: false, desc: 'Roti panggang isi telur mayo.'),
  // Chicken & Burger
  Product('b1', 'Crispy Chicken Burger', 'Chicken & Burger', 32000, _orange,
      drink: false, desc: 'Burger dengan ayam crispy dan saus spesial.'),
  Product('b2', 'Chicken Rice Bowl', 'Chicken & Burger', 28000, _coffee,
      drink: false, desc: 'Nasi dengan ayam krispi dan saus teriyaki.'),
  Product('b3', 'Fried Chicken 2 pcs', 'Chicken & Burger', 30000, _orange,
      drink: false, desc: 'Dua potong ayam goreng renyah.'),
];

const List<String> menuCategories = [
  'Promo & Combo', 'Baru!', 'Coffee', 'Non Coffee', 'Kenangan Toast', 'Chicken & Burger'
];

String catLabel(String c) => c.replaceAll('Kenangan', 'Mantan');

List<Product> merchProducts = [
  Product('m1', 'Tumbler Mantan 500ml', 'Merch', 89000, _dark,
      drink: false, desc: 'Tumbler stainless tahan panas dan dingin.'),
  Product('m2', 'Totebag Mantan', 'Merch', 59000, _cream,
      drink: false, desc: 'Totebag kanvas dengan logo hati.'),
  Product('m3', 'Mug Keramik Mantan', 'Merch', 75000, _pink,
      drink: false, desc: 'Mug keramik cantik untuk ngopi di rumah.'),
  Product('m4', 'Topi Mantan', 'Merch', 99000, _red2,
      drink: false, desc: 'Topi baseball bordir logo Kopi Mantan.'),
];
const _red2 = C.red;

List<Outlet> outlets = [
  Outlet('Royal Plaza Surabaya', 'Royal Plaza Surabaya, LG, Jl. Ahmad Yani No. 16-18, Ketintang, Gayungan, Surabaya',
      '436.5 M', '08.00 - 22.00'),
  Outlet('Ketintang UNESA', 'Ketintang UNESA, Ketintang, Unesa Ketintang, Surabaya', '869.7 M', '07.00 - 22.00'),
  Outlet('Adityawarman Surabaya', 'Jl. Adityawarman No. 12, Tegalsari, Surabaya', '1.2 KM', '08.00 - 22.00',
      drive: true),
  Outlet('Pakuwon Mall Surabaya', 'Pakuwon Mall, LG, Jl. Puncak Indah Lontar No.2, Surabaya', '3.1 KM', '10.00 - 22.00'),
  Outlet('Tunjungan Plaza 6', 'Tunjungan Plaza 6, GF, Jl. Basuki Rahmat No. 8-12, Surabaya', '4.5 KM', '10.00 - 22.00',
      delivery: false),
  Outlet('Galaxy Mall 3', 'Galaxy Mall 3, GF, Jl. Dharmahusada Indah Timur No.35, Surabaya', '6.2 KM', '10.00 - 22.00',
      drive: true),
];

List<PayMethod> buildPayMethods() => [
      PayMethod('qris', 'QRIS', 'Simpan QR dan bayar', Colors.black, Icons.qr_code_2),
      PayMethod('blu', 'blu by BCA Digital', 'Bayar di aplikasi blu', const Color(0xFF2AD1CF), Icons.bubble_chart),
      PayMethod('gopay', 'GoPay', 'Bayar di aplikasi Gojek', const Color(0xFF1AA6B7), Icons.account_balance_wallet,
          needsLink: true, linked: false),
      PayMethod('shopeepay', 'ShopeePay', 'Bayar dengan ShopeePay', const Color(0xFFEE4D2D), Icons.shopping_bag,
          needsLink: true, linked: false),
      PayMethod('ovo', 'OVO', 'Bayar di aplikasi OVO', const Color(0xFF4C2A86), Icons.radio_button_unchecked),
      PayMethod('dana', 'DANA', 'Bayar di aplikasi DANA', const Color(0xFF118EEA), Icons.waves),
      PayMethod('jenius', 'Jenius Pay', 'Bayar di aplikasi Jenius', const Color(0xFF0098D8), Icons.blur_circular),
      PayMethod('gopaylater', 'GoPayLater', 'Bayar di aplikasi Gojek', const Color(0xFF4DB6D8), Icons.payments,
          needsLink: true, linked: false),
    ];

const List<String> dailyRewards = ['+25', '+25', 'Voucher', '+25', '+25', 'Voucher', '+50'];

class VipPack {
  final String title, desc;
  final int price, normal, count;
  const VipPack(this.title, this.desc, this.price, this.normal, this.count);
}

const List<VipPack> vipPacks = [
  VipPack('Langganan Voucher Rp9.000',
      '1x Voucher B1G1, 2x Voucher B2G1, 30x Voucher Diskon 10%, 30x Voucher Diskon Ongkir', 9000, 630000, 65),
  VipPack('Langganan Voucher Rp24.000',
      '1x Voucher Gratis 1 Minuman, 1x Voucher B1G1, 2x Voucher B2G1, 30x Voucher Diskon 10%', 24000, 680000, 66),
];

// ====================== PARSER DATA DARI API ======================
Product _productFromJson(Map<String, dynamic> j) {
  final hex = (j['color'] ?? '#B77B4B').toString().replaceAll('#', '');
  return Product(
    j['id'].toString(),
    j['name'].toString(),
    j['category'].toString(),
    (j['price'] as num).toInt(),
    Color(int.parse('FF$hex', radix: 16)),
    desc: (j['desc'] ?? '').toString(),
    drink: j['drink'] != false,
    badge: j['badge']?.toString(),
  );
}

Outlet _outletFromJson(Map<String, dynamic> j) => Outlet(
      j['name'].toString(),
      j['address'].toString(),
      (j['distance'] ?? '').toString(),
      j['hours'].toString(),
      delivery: j['delivery'] != false,
      pickup: j['pickup'] != false,
      drive: j['drive'] == true,
    );

/// Kotak masuk bawaan untuk tamu (belum login).
List<Notif> defaultInbox() => [
      Notif('Selamat datang di Kopi Mantan', 'Nikmati promo Beli 1 Gratis 1 setiap hari hanya di aplikasi.', 'Hari ini'),
      Notif('Purple Cloud Series', 'Beli 2 diskon 25% untuk semua varian Purple Cloud.', 'Kemarin'),
    ];

// ====================== APP STATE ======================
class AppState extends ChangeNotifier {
  // navigasi & bahasa
  int tab = 0;
  String? menuJump;
  String lang = 'id';
  void goTab(int i) {
    tab = i;
    notifyListeners();
  }

  void setLang(String l) {
    lang = l;
    notifyListeners();
  }

  // akun
  bool loggedIn = false;
  final UserProfile user = UserProfile();
  int points = 0;
  int spend = 0;

  // lokasi
  Outlet outlet = outlets[0];
  bool outletChosen = false;
  Addr? address;
  final List<Addr> addresses = [];
  String orderMode = 'Pickup';
  bool dineInAvailable = false;

  // cart
  final List<CartItem> cart = [];
  bool bag = false;
  Voucher? voucher;
  String payId = 'qris';
  final List<String> cards = [];
  final List<PayMethod> pay = buildPayMethods();

  // data akun
  final List<Voucher> vouchers = [];
  final Set<String> claimed = {};
  final List<OrderRec> orders = [];
  final List<Notif> inbox = defaultInbox();
  int checkedDays = 0;
  String lastCheckIn = '';

  // ---- derived ----
  int get cartCount => cart.fold(0, (a, b) => a + b.qty);
  int get subtotal => cart.fold(0, (a, b) => a + b.total);
  int get shipFee => orderMode == 'Delivery' && cart.isNotEmpty ? 8000 : 0;
  int get discount {
    final v = voucher;
    if (v == null || cart.isEmpty) return 0;
    final unitPrices = <int>[];
    for (final c in cart) {
      for (int i = 0; i < c.qty; i++) {
        unitPrices.add(c.unit);
      }
    }
    unitPrices.sort();
    switch (v.type) {
      case 'pct':
        return subtotal * v.value ~/ 100;
      case 'flat':
        return v.value > subtotal ? subtotal : v.value;
      case 'b1g1':
        return unitPrices.length >= 2 ? unitPrices.first : 0;
      case 'free':
        return unitPrices.first;
      default:
        return 0;
    }
  }

  int get shipDiscount {
    final v = voucher;
    if (v != null && v.type == 'ship') return v.value > shipFee ? shipFee : v.value;
    return 0;
  }

  int get total {
    final t = subtotal - discount + (bag ? 4000 : 0) + shipFee - shipDiscount;
    return t < 0 ? 0 : t;
  }

  String get level => spend >= 2000000 ? 'Platinum' : (spend >= 700000 ? 'Gold' : 'Silver');
  int get levelTarget => spend >= 2000000 ? 2000000 : (spend >= 700000 ? 2000000 : 700000);
  int get levelPct => levelTarget == 0 ? 0 : ((spend * 100) ~/ levelTarget).clamp(0, 100).toInt();
  String get nextLevel => spend >= 700000 ? 'Platinum' : 'Gold';

  String get locationTitle {
    if (orderMode == 'Delivery') return 'Dikirim ke: ${address?.label ?? 'Pilih alamat'}';
    return outletChosen ? outlet.name : 'Pilih Outlet';
  }

  String get locationSub {
    if (orderMode == 'Delivery') return address?.detail ?? 'Pilih alamat pengiriman';
    return outlet.address;
  }

  // ---- aksi ----
  void login({String phone = '', String name = ''}) {
    loggedIn = true;
    if (phone.isNotEmpty) user.phone = '0$phone';
    if (name.isNotEmpty) user.name = name;
    notifyListeners();
  }

  // ---- Tahap 3: alamat pengiriman dari REST API ----
  /// Ambil alamat milik user yang sedang login.
  Future<void> loadAddresses() async {
    if (!loggedIn) return;
    try {
      final r = await Api.get('/addresses') as List<dynamic>;
      addresses
        ..clear()
        ..addAll(r.map((e) {
          final m = e as Map<String, dynamic>;
          return Addr(m['label'].toString(), m['detail'].toString(), id: (m['id'] as num).toInt());
        }));
      notifyListeners();
    } catch (_) {
      // gagal memuat: biarkan daftar apa adanya
    }
  }

  /// Tambah alamat. Bila login, disimpan ke server; bila tamu, hanya lokal.
  Future<Addr> addAddress(String label, String detail) async {
    Addr a;
    if (loggedIn) {
      final j = await Api.post('/addresses', {'label': label, 'detail': detail}) as Map<String, dynamic>;
      a = Addr(j['label'].toString(), j['detail'].toString(), id: (j['id'] as num).toInt());
    } else {
      a = Addr(label, detail);
    }
    addresses.add(a);
    notifyListeners();
    return a;
  }

  Future<void> updateAddress(Addr a, String label, String detail) async {
    if (loggedIn && a.id != null) {
      await Api.put('/addresses/${a.id}', {'label': label, 'detail': detail});
    }
    a.label = label;
    a.detail = detail;
    notifyListeners();
  }

  Future<void> removeAddress(Addr a) async {
    if (loggedIn && a.id != null) {
      await Api.delete('/addresses/${a.id}');
    }
    addresses.remove(a);
    if (address == a) address = null;
    notifyListeners();
  }

  // ---- Tahap 2: menu, merch, dan outlet dari REST API ----
  /// Ambil katalog dari server. Bila gagal, aplikasi tetap memakai data bawaan.
  Future<void> loadCatalog() async {
    try {
      final p = await Api.get('/products') as List<dynamic>;
      final m = await Api.get('/products/merch') as List<dynamic>;
      final o = await Api.get('/outlets') as List<dynamic>;
      if (p.isNotEmpty) {
        allProducts = p.map((e) => _productFromJson(e as Map<String, dynamic>)).toList();
      }
      if (m.isNotEmpty) {
        merchProducts = m.map((e) => _productFromJson(e as Map<String, dynamic>)).toList();
      }
      if (o.isNotEmpty) {
        outlets = o.map((e) => _outletFromJson(e as Map<String, dynamic>)).toList();
        if (!outletChosen) outlet = outlets[0];
      }
      notifyListeners();
    } catch (_) {
      // server tidak bisa dihubungi: pakai data bawaan
    }
  }

  // ---- terhubung ke REST API (Tahap 1: auth & profil) ----
  void _applyUser(Map<String, dynamic> j, {bool stats = false}) {
    user.name = (j['name'] ?? user.name).toString();
    user.email = (j['email'] ?? '').toString();
    user.emailVerified = j['emailVerified'] == true;
    user.phone = (j['phone'] ?? '').toString();
    user.gender = (j['gender'] ?? 'Rahasia').toString();
    user.birth = j['birth'] != null ? DateTime.tryParse(j['birth'].toString()) : null;
    user.city = (j['city'] ?? '').toString();
    user.googleLinked = j['googleLinked'] == true;
    user.pin = j['hasPin'] == true ? '******' : '';
    if (stats) {
      points = (j['points'] as num?)?.toInt() ?? 0;
      spend = (j['spend'] as num?)?.toInt() ?? 0;
    }
  }

  Future<void> _onAuth(dynamic res) async {
    final m = res as Map<String, dynamic>;
    await Api.saveToken(m['token'] as String);
    _applyUser(m['user'] as Map<String, dynamic>, stats: true);
    login();
    await _loadAccountData();
  }

  /// Muat semua data milik akun dari server (setelah login / saat aplikasi dibuka).
  Future<void> _loadAccountData() async {
    await Future.wait([
      loadAddresses(),
      loadVouchers(),
      loadOrders(),
      loadNotifications(),
      loadCheckin(),
    ]);
  }

  /// Login nomor HP + OTP. Melempar ApiException bila gagal.
  Future<void> loginWithOtp(String phone, String otp) async =>
      _onAuth(await Api.post('/auth/otp/verify', {'phone': phone, 'otp': otp}));

  /// Login simulasi: provider = whatsapp | apple | google.
  Future<void> loginSocial(String provider) async =>
      _onAuth(await Api.post('/auth/social', {'provider': provider}));

  /// Dipanggil saat aplikasi dibuka: pulihkan sesi dari token tersimpan.
  Future<void> restoreSession() async {
    if (Api.token == null) return;
    try {
      _applyUser(await Api.get('/me') as Map<String, dynamic>, stats: true);
      loggedIn = true;
      await _loadAccountData();
    } on ApiException catch (e) {
      if (e.status == 401 || e.status == 404) await Api.saveToken(null);
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String city,
    required String gender,
    DateTime? birth,
  }) async {
    String two(int n) => n.toString().padLeft(2, '0');
    final j = await Api.put('/me', {
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'gender': gender,
      if (birth != null) 'birth': '${birth.year}-${two(birth.month)}-${two(birth.day)}',
    });
    _applyUser(j as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> changePin(String pin) async {
    await Api.put('/me/pin', {'pin': pin});
    user.pin = '******';
    notifyListeners();
  }

  void logout() {
    Api.saveToken(null);
    loggedIn = false;
    points = 0;
    spend = 0;
    vouchers.clear();
    claimed.clear();
    orders.clear();
    inbox
      ..clear()
      ..addAll(defaultInbox());
    addresses.clear();
    address = null;
    voucher = null;
    checkedDays = 0;
    lastCheckIn = '';
    tab = 4;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await Api.delete('/me');
    final u = user;
    u.name = 'Pengguna Mantan';
    u.email = '';
    u.emailVerified = false;
    u.phone = '';
    u.gender = 'Rahasia';
    u.birth = null;
    u.city = '';
    u.googleLinked = false;
    u.pin = '';
    cart.clear();
    logout();
  }

  void touch() => notifyListeners();

  void selectOutlet(Outlet o) {
    outlet = o;
    outletChosen = true;
    if (orderMode == 'Delivery') orderMode = 'Pickup';
    notifyListeners();
  }

  void selectAddress(Addr a) {
    address = a;
    orderMode = 'Delivery';
    notifyListeners();
  }

  void setMode(String m) {
    orderMode = m;
    notifyListeners();
  }

  void addToCart(CartItem n) {
    for (final c in cart) {
      if (c.same(n)) {
        c.qty += n.qty;
        notifyListeners();
        return;
      }
    }
    cart.add(n);
    notifyListeners();
  }

  void replaceItem(CartItem old, CartItem n) {
    final i = cart.indexOf(old);
    if (i >= 0) cart[i] = n;
    notifyListeners();
  }

  void changeQty(CartItem c, int d) {
    c.qty += d;
    if (c.qty <= 0) cart.remove(c);
    if (cart.isEmpty) voucher = null;
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    voucher = null;
    bag = false;
    notifyListeners();
  }

  // ---- Tahap 4: voucher dari REST API ----
  Voucher _voucherFromJson(Map<String, dynamic> j) => Voucher(
        j['code'].toString(),
        j['title'].toString(),
        (j['desc'] ?? '').toString(),
        j['type'].toString(),
        (j['value'] as num?)?.toInt() ?? 0,
        uvId: (j['id'] as num?)?.toInt(),
      );

  /// Ambil voucher milik user yang sedang login.
  Future<void> loadVouchers() async {
    if (!loggedIn) return;
    try {
      final r = await Api.get('/vouchers') as Map<String, dynamic>;
      vouchers
        ..clear()
        ..addAll((r['vouchers'] as List<dynamic>).map((e) => _voucherFromJson(e as Map<String, dynamic>)));
      claimed
        ..clear()
        ..addAll((r['claimedKeys'] as List<dynamic>).map((e) => e.toString()));
      notifyListeners();
    } catch (_) {
      // gagal memuat: biarkan daftar apa adanya
    }
  }

  /// Klaim voucher. Mengembalikan null bila berhasil, atau pesan error.
  Future<String?> claimVoucher(String key) async {
    try {
      await Api.post('/vouchers/claim', {'key': key});
      await loadVouchers();
      await loadNotifications();
      return null;
    } on ApiException catch (e) {
      if (e.status == 409) {
        claimed.add(key); // sudah pernah diklaim
        notifyListeners();
      }
      return e.message;
    }
  }

  /// Cek kode voucher ke server (voucher milik user atau kode promo umum).
  Future<Voucher?> findVoucher(String code) async {
    final c = code.trim();
    if (c.isEmpty) return null;
    try {
      final j = await Api.post('/vouchers/validate', {'code': c}) as Map<String, dynamic>;
      return _voucherFromJson(j);
    } on ApiException {
      return null;
    }
  }

  /// Beli Voucher Pack (pembayaran disimulasikan).
  Future<void> buyPack(int price, String title) async {
    await Api.post('/vouchers/buy-pack', {'price': price});
    await loadVouchers();
    await loadNotifications();
  }

  // ---- Tahap 6: notifikasi & check-in dari REST API ----
  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Baru saja';
    if (d.inMinutes < 60) return '${d.inMinutes} menit lalu';
    if (d.inHours < 24) return '${d.inHours} jam lalu';
    if (d.inDays == 1) return 'Kemarin';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.day)}/${two(t.month)}/${t.year}';
  }

  Notif _notifFromJson(Map<String, dynamic> j) {
    final t = (DateTime.tryParse(j['date'].toString()) ?? DateTime.now()).toLocal();
    return Notif(j['title'].toString(), (j['body'] ?? '').toString(), _ago(t),
        read: j['read'] == true, id: (j['id'] as num).toInt());
  }

  /// Ambil kotak masuk milik user yang sedang login.
  Future<void> loadNotifications() async {
    if (!loggedIn) return;
    try {
      final r = await Api.get('/notifications') as List<dynamic>;
      inbox
        ..clear()
        ..addAll(r.map((e) => _notifFromJson(e as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {
      // gagal memuat: biarkan daftar apa adanya
    }
  }

  /// Tambah notifikasi untuk diri sendiri (fitur simulasi). Tamu: hanya lokal.
  Future<void> addNotif(String title, String body) async {
    if (loggedIn) {
      try {
        await Api.post('/notifications', {'title': title, 'body': body});
        await loadNotifications();
        return;
      } on ApiException {
        // gagal: simpan lokal saja
      }
    }
    inbox.insert(0, Notif(title, body, 'Baru saja'));
    notifyListeners();
  }

  Future<void> markNotifRead(Notif n) async {
    if (n.read) return;
    n.read = true;
    notifyListeners();
    if (loggedIn && n.id != null) {
      try {
        await Api.put('/notifications/${n.id}/read');
      } catch (_) {}
    }
  }

  Future<void> markAllRead() async {
    for (final n in inbox) {
      n.read = true;
    }
    notifyListeners();
    if (loggedIn) {
      try {
        await Api.put('/notifications/read-all');
      } catch (_) {}
    }
  }

  /// Ambil status check-in dari server.
  Future<void> loadCheckin() async {
    if (!loggedIn) return;
    try {
      final j = await Api.get('/checkin') as Map<String, dynamic>;
      checkedDays = (j['checkedDays'] as num).toInt();
      final now = DateTime.now();
      lastCheckIn = j['checkedToday'] == true ? '${now.year}-${now.month}-${now.day}' : '';
      notifyListeners();
    } catch (_) {
      // gagal memuat: biarkan apa adanya
    }
  }

  /// Check-in hari ini. Mengembalikan null bila berhasil, atau pesan error.
  Future<String?> checkIn() async {
    try {
      final j = await Api.post('/checkin') as Map<String, dynamic>;
      checkedDays = (j['checkedDays'] as num).toInt();
      final now = DateTime.now();
      lastCheckIn = '${now.year}-${now.month}-${now.day}';
      points = (j['points'] as num).toInt();
      notifyListeners();
      if (j['reward'] == 'Voucher') await loadVouchers();
      await loadNotifications();
      return null;
    } on ApiException catch (e) {
      if (e.status == 409) {
        final now = DateTime.now();
        lastCheckIn = '${now.year}-${now.month}-${now.day}'; // sudah check-in hari ini
        notifyListeners();
      }
      return e.message;
    }
  }

  bool get checkedToday {
    final now = DateTime.now();
    return lastCheckIn == '${now.year}-${now.month}-${now.day}';
  }

  // ---- Tahap 5: pesanan dari REST API ----
  OrderRec _orderFromJson(Map<String, dynamic> j) {
    Product productFor(Map<String, dynamic> i) {
      final id = i['productId'].toString();
      for (final p in [...allProducts, ...merchProducts]) {
        if (p.id == id) return p;
      }
      return Product(id, i['name'].toString(), '', (i['unit'] as num).toInt(), C.red);
    }

    final items = (j['items'] as List<dynamic>).map((e) {
      final i = e as Map<String, dynamic>;
      return CartItem(
        productFor(i),
        size: i['size'].toString(),
        ice: i['ice'].toString(),
        sugar: i['sugar'].toString(),
        note: i['note'].toString(),
        qty: (i['qty'] as num).toInt(),
      );
    }).toList();

    String two(int n) => n.toString().padLeft(2, '0');
    final d = (DateTime.tryParse(j['date'].toString()) ?? DateTime.now()).toLocal();
    final date = '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';

    return OrderRec(j['id'].toString(), date, j['mode'].toString(), j['outlet'].toString(),
        j['payment'].toString(), items, (j['total'] as num).toInt(), j['status'].toString());
  }

  /// Ambil riwayat pesanan user yang sedang login.
  Future<void> loadOrders() async {
    if (!loggedIn) return;
    try {
      final r = await Api.get('/orders') as List<dynamic>;
      orders
        ..clear()
        ..addAll(r.map((e) => _orderFromJson(e as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {
      // gagal memuat: biarkan daftar apa adanya
    }
  }

  /// Buat pesanan di server. Harga & diskon dihitung server. Melempar ApiException bila gagal.
  Future<OrderRec> placeOrder(String paymentName) async {
    final v = voucher;
    final res = await Api.post('/orders', {
      'mode': orderMode,
      'place': orderMode == 'Delivery' ? (address?.label ?? '-') : outlet.name,
      if (orderMode == 'Delivery' && address != null) 'addressDetail': address!.detail,
      'payment': paymentName,
      'bag': bag,
      if (v != null && v.uvId != null) 'voucherId': v.uvId,
      if (v != null && v.uvId == null) 'voucherCode': v.code,
      'items': cart
          .map((c) => {
                'productId': c.p.id,
                'size': c.size,
                'ice': c.ice,
                'sugar': c.sugar,
                'note': c.note,
                'qty': c.qty,
              })
          .toList(),
    }) as Map<String, dynamic>;

    final o = _orderFromJson(res);
    orders.insert(0, o);
    points = (res['points'] as num).toInt();
    spend = (res['spend'] as num).toInt();
    if (v != null && v.uvId != null) vouchers.removeWhere((x) => x.uvId == v.uvId);
    loadNotifications(); // notifikasi pesanan dibuat oleh server
    clearCart();
    return o;
  }

  PayMethod get selectedPay {
    if (payId.startsWith('card:')) {
      return PayMethod(payId, 'Kartu ${payId.substring(5)}', 'Debit / Kredit', Colors.blueGrey, Icons.credit_card);
    }
    return pay.firstWhere((p) => p.id == payId, orElse: () => pay.first);
  }
}

final AppState app = AppState();

String t(String id, String en) => app.lang == 'id' ? id : en;