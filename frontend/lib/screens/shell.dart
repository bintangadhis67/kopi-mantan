import 'package:flutter/material.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets.dart';
import 'home.dart';
import 'menu.dart';
import 'vip.dart';
import 'merch.dart';
import 'profile.dart';
import 'login.dart';
import 'order_flow.dart';

class Shell extends StatelessWidget {
  const Shell({super.key});

  Widget navItem(int i, IconData off, IconData on, String label) {
    final sel = app.tab == i;
    return Expanded(
      child: InkWell(
        onTap: () => app.goTab(i),
        child: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: sel ? 52 : 36,
              height: sel ? 52 : 36,
              decoration: BoxDecoration(shape: BoxShape.circle, color: sel ? C.redSoft : Colors.transparent),
              child: Icon(sel ? on : off, size: sel ? 30 : 28, color: sel ? C.red : const Color(0xFF777777)),
            ),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.w800 : FontWeight.w500, color: sel ? C.red : const Color(0xFF777777))),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final showCart = app.tab != 2 && app.cart.isNotEmpty;
          final showLogin = app.tab == 0 && !app.loggedIn && !showCart;
          return PopScope(
            canPop: app.tab == 0,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) app.goTab(0);
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              body: IndexedStack(index: app.tab, children: const [HomePage(), MenuPage(), VipPage(), MerchPage(), ProfilePage()]),
              bottomNavigationBar: Container(
                decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: C.line))),
                child: SafeArea(
                  top: false,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    if (showCart)
                      Padding(padding: const EdgeInsets.only(top: 8), child: CartBar(onTap: () => push(context, const ConfirmOrderPage()))),
                    if (showLogin)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                        child: PrimaryBtn('Daftar atau Masuk', () => showLoginSheet(context)),
                      ),
                    Row(children: [
                      navItem(0, Icons.home_outlined, Icons.home, t('Beranda', 'Home')),
                      navItem(1, Icons.local_cafe_outlined, Icons.local_cafe, 'Menu'),
                      navItem(2, Icons.workspace_premium_outlined, Icons.workspace_premium, 'VIP'),
                      navItem(3, Icons.local_drink_outlined, Icons.local_drink, 'Merch'),
                      navItem(4, Icons.account_circle_outlined, Icons.account_circle, t('Saya', 'Me')),
                    ]),
                  ]),
                ),
              ),
            ),
          );
        },
      );
}