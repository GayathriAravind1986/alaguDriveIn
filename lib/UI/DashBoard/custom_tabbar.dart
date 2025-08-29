import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/Alertbox/AlertDialogBox.dart';
import 'package:simple/Bloc/Category/category_bloc.dart';
import 'package:simple/Bloc/Report/report_bloc.dart';
import 'package:simple/Bloc/StockIn/stock_in_bloc.dart';
import 'package:simple/Bloc/demo/demo_bloc.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/UI/CustomAppBar/custom_appbar.dart';
import 'package:simple/UI/Home_screen/home_screen.dart';
import 'package:simple/UI/Order/order_list.dart';
import 'package:simple/UI/Order/order_tab_page.dart';
import 'package:simple/UI/StockIn/stock_in.dart';
import '../Report/report_order.dart';

class DashBoardScreen extends StatelessWidget {
  final int? selectTab;
  final GetViewOrderModel? existingOrder;
  final bool? isEditingOrder;
  const DashBoardScreen(
      {super.key, this.selectTab, this.existingOrder, this.isEditingOrder});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DemoBloc(),
      child: DashBoard(
        selectTab: selectTab,
        existingOrder: existingOrder,
        isEditingOrder: isEditingOrder,
      ),
    );
  }
}

class DashBoard extends StatefulWidget {
  final int? selectTab;
  final GetViewOrderModel? existingOrder;
  final bool? isEditingOrder;

  const DashBoard({
    super.key,
    this.selectTab,
    this.existingOrder,
    this.isEditingOrder,
  });

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final GlobalKey<OrderViewViewState> orderAllTabKey =
      GlobalKey<OrderViewViewState>();
  final GlobalKey<FoodOrderingScreenViewState> foodKey =
      GlobalKey<FoodOrderingScreenViewState>();
  final GlobalKey<ReportViewViewState> reportKey =
      GlobalKey<ReportViewViewState>();
  final GlobalKey<StockViewViewState> stockKey =
      GlobalKey<StockViewViewState>();
  final GlobalKey<OrderTabViewViewState> orderTabKey =
      GlobalKey<OrderTabViewViewState>();
  int selectedIndex = 0;
  bool orderLoad = false;

  // FIXED: Better state management for refresh flags
  Map<int, bool> tabRefreshStates = {
    0: false, // Home
    1: false, // Orders
    2: false, // Reports
    3: false, // Stock
  };

  @override
  void initState() {
    super.initState();
    if (widget.selectTab != null) {
      selectedIndex = widget.selectTab!;
    }
  }

  void _resetOrderTab() {
    final orderTabState = orderTabKey.currentState;
    if (orderTabState != null) {
      orderTabState.resetSelections();
    } else {
      debugPrint("orderTabState is NULL — check if key is assigned properly");
    }
  }

  void _refreshOrders() {
    final orderAllTabState = orderAllTabKey.currentState;
    if (orderAllTabState != null) {
      orderAllTabState.refreshOrders();
    }
  }

  void _refreshHome() {
    final foodKeyState = foodKey.currentState;
    if (foodKeyState != null) {
      foodKeyState.refreshHome();
    } else {
      debugPrint("foodKeyState is NULL — check if key is assigned properly");
    }
  }

  void _refreshReport() {
    final reportKeyState = reportKey.currentState;
    if (reportKeyState != null) {
      reportKeyState.refreshReport();
    } else {
      debugPrint("reportKeyState is NULL — check if key is assigned properly");
    }
  }

  void _refreshStock() {
    final stockKeyState = stockKey.currentState;
    if (stockKeyState != null) {
      stockKeyState.refreshStock();
    } else {
      debugPrint("stockKeyState is NULL — check if key is assigned properly");
    }
  }

  Widget mainContainer() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: CustomAppBar(
          selectedIndex: selectedIndex,
          onTabSelected: (index) {
            setState(() {
              selectedIndex = index;
            });

            // FIXED: Simplified tab refresh logic
            switch (index) {
              case 0: // Home tab
                if (!tabRefreshStates[0]!) {
                  tabRefreshStates[0] = true;
                  _resetOtherTabStates(0);
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _refreshHome());
                }
                break;
              case 1: // Orders tab
                _resetOtherTabStates(1);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _refreshOrders();
                  _resetOrderTab();
                });
                break;
              case 2: // Reports tab
                if (!tabRefreshStates[2]!) {
                  tabRefreshStates[2] = true;
                  _resetOtherTabStates(2);
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _refreshReport());
                }
                break;
              case 3: // Stock tab
                if (!tabRefreshStates[3]!) {
                  tabRefreshStates[3] = true;
                  _resetOtherTabStates(3);
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _refreshStock());
                }
                break;
            }
          },
          onLogout: () {
            showLogoutDialog(context);
          },
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: [
            // FIXED: Use consistent widget based on refresh state
            BlocProvider(
              create: (_) => FoodCategoryBloc(),
              child: tabRefreshStates[0]!
                  ? FoodOrderingScreenView(
                      key: foodKey,
                      existingOrder: widget.existingOrder,
                      isEditingOrder: widget.isEditingOrder,
                      hasRefreshedOrder: tabRefreshStates[0]!,
                    )
                  : FoodOrderingScreen(
                      key: foodKey,
                      existingOrder: widget.existingOrder,
                      isEditingOrder: widget.isEditingOrder,
                      hasRefreshedOrder: tabRefreshStates[0]!,
                    ),
            ),
            OrdersTabbedScreen(
              key: PageStorageKey('OrdersTabbedScreen'),
              orderAllKey: orderAllTabKey,
              orderResetKey: orderTabKey,
            ),
            BlocProvider(
              create: (_) => ReportTodayBloc(),
              child: tabRefreshStates[2]!
                  ? ReportViewView(
                      key: reportKey,
                      hasRefreshedReport: tabRefreshStates[2]!,
                    )
                  : ReportView(
                      key: reportKey,
                      hasRefreshedReport: tabRefreshStates[2]!,
                    ),
            ),
            BlocProvider(
              create: (_) => StockInBloc(),
              child: tabRefreshStates[3]!
                  ? StockViewView(
                      key: stockKey,
                      hasRefreshedStock: tabRefreshStates[3]!,
                    )
                  : StockView(
                      key: stockKey,
                      hasRefreshedStock: tabRefreshStates[3]!,
                    ),
            ),
          ],
        ),
      ),
    );
    // final GlobalKey<OrderViewViewState> orderAllTabKey =
    //     GlobalKey<OrderViewViewState>();
    // final GlobalKey<FoodOrderingScreenViewState> foodKey =
    //     GlobalKey<FoodOrderingScreenViewState>();
    // final GlobalKey<ReportViewViewState> reportKey =
    //     GlobalKey<ReportViewViewState>();
    // final GlobalKey<StockViewViewState> stockKey =
    //     GlobalKey<StockViewViewState>();
    // int selectedIndex = 0;
    // bool orderLoad = false;
    // bool hasRefreshedOrder = false;
    // bool hasRefreshedReport = false;
    // bool hasRefreshedStock = false;
    //
    // @override
    // void initState() {
    //   super.initState();
    //   if (widget.selectTab != null) {
    //     selectedIndex = widget.selectTab!;
    //   }
    // }
    //
    // void _refreshOrders() {
    //   final orderAllTabState = orderAllTabKey.currentState;
    //   if (orderAllTabState != null) {
    //     orderAllTabState.refreshOrders();
    //   }
    // }
    //
    // void _refreshHome() {
    //   final foodKeyState = foodKey.currentState;
    //   if (foodKeyState != null) {
    //     foodKeyState.refreshHome();
    //   } else {
    //     debugPrint("foodKeyState is NULL — check if key is assigned properly");
    //   }
    // }
    //
    // void _refreshReport() {
    //   final reportKeyState = reportKey.currentState;
    //   if (reportKeyState != null) {
    //     reportKeyState.refreshReport();
    //   } else {
    //     debugPrint("reportKeyState is NULL — check if key is assigned properly");
    //   }
    // }
    //
    // void _refreshStock() {
    //   final stockKeyState = stockKey.currentState;
    //   if (stockKeyState != null) {
    //     stockKeyState.refreshStock();
    //   } else {
    //     debugPrint("reportKeyState is NULL — check if key is assigned properly");
    //   }
    // }
    //
    // Widget mainContainer() {
    //   return SafeArea(
    //     child: Scaffold(
    //       backgroundColor: Colors.white,
    //       appBar: CustomAppBar(
    //         selectedIndex: selectedIndex,
    //         onTabSelected: (index) {
    //           setState(() {
    //             selectedIndex = index;
    //           });
    //           if (index == 0 && !hasRefreshedOrder) {
    //             hasRefreshedOrder = true;
    //             hasRefreshedReport = false;
    //             hasRefreshedStock = false;
    //             WidgetsBinding.instance
    //                 .addPostFrameCallback((_) => _refreshHome());
    //           }
    //           if (index == 1) {
    //             hasRefreshedOrder = false;
    //             hasRefreshedReport = false;
    //             hasRefreshedStock = false;
    //             WidgetsBinding.instance.addPostFrameCallback((_) {
    //               _refreshOrders();
    //             });
    //           }
    //           if (index == 2 && !hasRefreshedReport) {
    //             hasRefreshedOrder = false;
    //             hasRefreshedReport = true;
    //             hasRefreshedStock = false;
    //             WidgetsBinding.instance.addPostFrameCallback((_) {
    //               _refreshReport();
    //             });
    //           }
    //           if (index == 3 && !hasRefreshedStock) {
    //             hasRefreshedOrder = false;
    //             hasRefreshedReport = false;
    //             hasRefreshedStock = true;
    //             WidgetsBinding.instance.addPostFrameCallback((_) {
    //               _refreshStock();
    //             });
    //           }
    //         },
    //         onLogout: () {
    //           showLogoutDialog(context);
    //         },
    //       ),
    //       body: IndexedStack(
    //         index: selectedIndex,
    //         children: [
    //           hasRefreshedOrder == true
    //               ? BlocProvider(
    //                   create: (_) => FoodCategoryBloc(),
    //                   child: FoodOrderingScreenView(
    //                     key: foodKey,
    //                     existingOrder: widget.existingOrder,
    //                     isEditingOrder: widget.isEditingOrder,
    //                     hasRefreshedOrder: hasRefreshedOrder,
    //                   ))
    //               : BlocProvider(
    //                   create: (_) => FoodCategoryBloc(),
    //                   child: FoodOrderingScreen(
    //                     key: foodKey,
    //                     existingOrder: widget.existingOrder,
    //                     isEditingOrder: widget.isEditingOrder,
    //                     hasRefreshedOrder: hasRefreshedOrder,
    //                   ),
    //                 ),
    //           OrdersTabbedScreen(
    //             key: PageStorageKey('OrdersTabbedScreen'),
    //             orderAllKey: orderAllTabKey,
    //           ),
    //           hasRefreshedReport == true
    //               ? BlocProvider(
    //                   create: (_) => ReportTodayBloc(),
    //                   child: ReportViewView(
    //                     key: reportKey,
    //                     hasRefreshedReport: hasRefreshedReport,
    //                   ))
    //               : BlocProvider(
    //                   create: (_) => ReportTodayBloc(),
    //                   child: ReportView(
    //                     key: reportKey,
    //                     hasRefreshedReport: hasRefreshedReport,
    //                   ),
    //                 ),
    //           hasRefreshedStock == true
    //               ? BlocProvider(
    //                   create: (_) => StockInBloc(),
    //                   child: StockViewView(
    //                     key: stockKey,
    //                     hasRefreshedStock: hasRefreshedStock,
    //                   ))
    //               : BlocProvider(
    //                   create: (_) => StockInBloc(),
    //                   child: StockView(
    //                     key: stockKey,
    //                     hasRefreshedStock: hasRefreshedStock,
    //                   ),
    //                 ),
    //         ],
    //       ),
    //     ),
    //   );
  }

  void _resetOtherTabStates(int currentTab) {
    for (int i = 0; i < 4; i++) {
      if (i != currentTab) {
        tabRefreshStates[i] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DemoBloc, dynamic>(
      buildWhen: (previous, current) {
        return false;
      },
      builder: (context, state) {
        return mainContainer();
      },
    );
  }
}
