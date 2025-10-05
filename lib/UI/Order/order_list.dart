import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Order/order_list_bloc.dart';
import 'package:simple/ModelClass/Order/Delete_order_model.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart' hide Data;
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_order_model.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/text_styles.dart';
import 'package:simple/UI/Authentication/login_screen.dart';
import 'package:simple/UI/DashBoard/custom_tabbar.dart';
import 'package:simple/UI/Order/Helper/time_formatter.dart';
import 'package:simple/UI/Order/pop_view_order.dart';

class OrderView extends StatelessWidget {
  final GlobalKey<OrderViewViewState>? orderAllKey;
  final String type;
  String? selectedTableName;
  String? selectedWaiterName;
  String? selectOperator;
  String? operatorShared;
  final GetOrderListTodayModel? sharedOrderData;
  final bool isLoading;

  OrderView({
    super.key,
    required this.type,
    this.orderAllKey,
    this.selectedTableName,
    this.selectedWaiterName,
    this.selectOperator,
    this.operatorShared,
    this.sharedOrderData,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OrderViewView(
      key: orderAllKey,
      type: type,
      selectedTableName: selectedTableName,
      selectedWaiterName: selectedWaiterName,
      selectOperator: selectOperator,
      operatorShared: operatorShared,
      sharedOrderData: sharedOrderData,
      isLoading: isLoading,
    );
  }
}

class OrderViewView extends StatefulWidget {
  final String type;
  String? selectedTableName;
  String? selectedWaiterName;
  String? selectOperator;
  String? operatorShared;

  final GetOrderListTodayModel? sharedOrderData;
  final bool isLoading;

  OrderViewView({
    super.key,
    required this.type,
    this.selectedTableName,
    this.selectedWaiterName,
    this.selectOperator,
    this.operatorShared,
    this.sharedOrderData,
    this.isLoading = false,
  });

  @override
  OrderViewViewState createState() => OrderViewViewState();
}

class OrderViewViewState extends State<OrderViewView> {
  GetOrderListTodayModel getOrderListTodayModel = GetOrderListTodayModel();
  DeleteOrderModel deleteOrderModel = DeleteOrderModel();
  GetViewOrderModel getViewOrderModel = GetViewOrderModel();

  // New variables for offline orders - only pending sync
  List<HiveOrder> _pendingSyncOrders = [];
  bool _isLoadingOfflineOrders = false;

  String? errorMessage;
  bool view = false;
  final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? fromDate;
  String? type;

  void refreshOrders() {
    if (!mounted || !context.mounted) return;

    // Refresh online orders
    context.read<OrderTodayBloc>().add(
      OrderTodayList(todayDate, todayDate, widget.selectedTableName ?? "",
          widget.selectedWaiterName ?? "", widget.selectOperator ?? ""),
    );

    // Refresh offline orders - only pending sync
    _loadPendingSyncOrders();
  }

  Future<void> _loadPendingSyncOrders() async {
    if (!mounted) return;

    setState(() {
      _isLoadingOfflineOrders = true;
    });

    try {
      // Get only orders that are not synced
      final pendingOrders = await HiveService.getPendingSyncOrders();
      if (mounted) {
        setState(() {
          _pendingSyncOrders = pendingOrders;
          _isLoadingOfflineOrders = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading pending sync orders: $e");
      if (mounted) {
        setState(() {
          _isLoadingOfflineOrders = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.sharedOrderData != null) {
      getOrderListTodayModel = widget.sharedOrderData!;
    }

    // Load pending sync orders when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPendingSyncOrders();
    });
  }

  @override
  void didUpdateWidget(OrderViewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sharedOrderData != null) {
      setState(() {
        getOrderListTodayModel = widget.sharedOrderData!;
      });
    }

    // Reload pending sync orders when widget updates
    _loadPendingSyncOrders();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Helper method to filter orders by type
  List<dynamic> _getFilteredOrders() {
    String? type;
    switch (widget.type) {
      case "Line":
        type = "LINE";
        break;
      case "Parcel":
        type = "PARCEL";
        break;
      case "AC":
        type = "AC";
        break;
      case "HD":
        type = "HD";
        break;
      case "SWIGGY":
        type = "SWIGGY";
        break;
      default:
        type = null;
    }

    // Filter online orders
    final filteredOnlineOrders = getOrderListTodayModel.data?.where((order) {
      if (widget.type == "All") return true;
      return order.orderType?.toUpperCase() == type;
    }).toList() ??
        [];

    // Filter pending sync orders
    final filteredPendingOrders = _pendingSyncOrders.where((order) {
      if (widget.type == "All") return true;
      return order.orderType?.toUpperCase() == type;
    }).toList();

    // Combine both lists, marking pending sync orders
    final combinedOrders = [
      ...filteredOnlineOrders.map((order) => _OrderItem(order: order, isPendingSync: false)),
      ...filteredPendingOrders.map((order) => _OrderItem(order: order, isPendingSync: true)),
    ];

    return combinedOrders;
  }

  Widget _buildOrderCard(_OrderItem orderItem) {
    final isPendingSync = orderItem.isPendingSync;

    if (isPendingSync) {
      final hiveOrder = orderItem.order as HiveOrder;
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Pending Sync Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "SYNC PENDING",
                  style: MyTextStyle.f10(Colors.white, weight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Order: ${hiveOrder.orderNumber ?? 'Local'}",
                      style: MyTextStyle.f14(appPrimaryColor, weight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    "₹${hiveOrder.total?.toStringAsFixed(2)}",
                    style: MyTextStyle.f14(appPrimaryColor, weight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Time: ${DateFormat('HH:mm').format(hiveOrder.createdAt!)}",
                  ),
                  Text(
                    "Payment: ${hiveOrder.paymentMethod ?? 'Pending'}",
                    style: MyTextStyle.f12(greyColor),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Type: ${hiveOrder.orderType ?? '--'}"),
                  Text(
                    "Status: ${hiveOrder.orderStatus}",
                    style: TextStyle(
                      color: hiveOrder.orderStatus == 'COMPLETED' ? greenColor : orangeColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Text("Table: ${hiveOrder.tableName ?? 'N/A'}"),

              // 🔹 Sync Status - Always "Pending" since we only show pending ones
              Text(
                "Sync: Pending",
                style: MyTextStyle.f12(Colors.orange),
              ),

              const Spacer(),
              // NO BUTTONS HERE as requested (no View, Edit, Print, Delete)
              // The Row below is kept empty to preserve the layout structure but contains no children.
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // All previous IconButtons (View, Edit, Print, Delete) for offline orders are REMOVED.
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      );
    } else {
      // Online order card (original logic for online orders)
      final order = orderItem.order as Data;
      final payment = order.payments?.isNotEmpty == true
          ? order.payments!.first
          : null;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Order ID & Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Order ID: ${order.orderNumber ?? '--'}",
                      style: MyTextStyle.f14(appPrimaryColor, weight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    "₹${order.total?.toStringAsFixed(2) ?? '0.00'}",
                    style: MyTextStyle.f14(appPrimaryColor, weight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Time: ${formatTime(order.invoice?.date)}",
                  ),
                  Text(
                    payment?.paymentMethod != null &&
                        payment!.paymentMethod!.isNotEmpty
                        ? "Payment: ${payment.paymentMethod}: ₹${payment.amount?.toStringAsFixed(2) ?? '0.00'}"
                        : "Payment: N/A",
                    style: MyTextStyle.f12(greyColor),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Type: ${order.orderType ?? '--'}"),
                  Text(
                    "Status: ${order.orderStatus}",
                    style: TextStyle(
                      color: order.orderStatus == 'COMPLETED' ? greenColor : orangeColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Text("Table: ${order.tableName ?? 'N/A'}"),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.remove_red_eye, color: appPrimaryColor, size: 20),
                        onPressed: () {
                          setState(() {
                            view = true;
                          });
                          context
                              .read<OrderTodayBloc>()
                              .add(ViewOrder(order.id));
                        },
                      ),
                      const SizedBox(width: 4),
                      if (widget.operatorShared == widget.selectOperator ||
                          widget.selectOperator == null ||
                          widget.selectOperator == "")
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.edit, color: appPrimaryColor, size: 20),
                          onPressed: () {
                            if (order.id == null) {
                              debugPrint("⚠️ Order ID is null, cannot view order");
                              return;
                            }

                            if (mounted) {
                              setState(() {
                                view = false;
                              });
                            }

                            context.read<OrderTodayBloc>().add(ViewOrder(order.id!));
                            debugPrint("📦 Viewing order with ID: ${order.id}");
                          },
                        ),

                      const SizedBox(width: 4),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.print_outlined, color: appPrimaryColor, size: 20),
                        onPressed: () {
                          setState(() {
                            view = true;
                          });
                          context
                              .read<OrderTodayBloc>()
                              .add(ViewOrder(order.id));
                        },
                      ),
                      const SizedBox(width: 4),
                      if (order.orderStatus != 'COMPLETED')
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete, color: appPrimaryColor, size: 20),
                          onPressed: () {
                            context
                                .read<OrderTodayBloc>()
                                .add(DeleteOrder(order.id));
                          },
                        ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }
  }

  // UPDATED: View functionality for offline orders to show a receipt-like view - (Still kept here but not called)
  void _showPendingOrderDetails(HiveOrder order) {
    // This action mirrors the 'View' of an online order (showing the receipt)
    // using an AlertDialog since we don't have a GetViewOrderModel for offline.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Order Receipt (Local - ${order.orderNumber ?? 'N/A'})"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Type: ${order.orderType}"),
              Text("Table: ${order.tableName ?? 'N/A'}"),
              Text("Status: ${order.orderStatus}", style: TextStyle(color: order.orderStatus == 'COMPLETED' ? greenColor : orangeColor)),
              Text("Created: ${DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt!)}"),
              const Text("Sync Status: Pending", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              const Divider(),
              const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.items!.map((item) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text("${item.name} x ${item.quantity}")),
                        Text("₹${item.subtotal?.toStringAsFixed(2)}")
                      ],
                    ),
                  )
              ).toList(),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TOTAL:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("₹${order.total!.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              Text("Payment: ${order.paymentMethod ?? 'Pending'}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // UPDATED: Edit functionality for offline orders (Still kept here but not called)
  void _editPendingOrder(HiveOrder order) {
    // This action mirrors the 'Edit' of an online order (navigating to the dashboard in edit mode).
    // The DashBoardScreen must be capable of handling HiveOrder data for editing.
    // NOTE: This uses a placeholder toast as the actual navigation logic is external.
    // showToast(
    //     "Attempting to edit offline order ${order.orderNumber}. (Placeholder for navigation to DashBoard)",
    //     context, color: true);

    // Placeholder for actual navigation (commented out until DashBoardScreen is updated to handle HiveOrder)
    /*
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => DashBoardScreen(
          selectTab: 0,
          existingHiveOrder: order, // Assume you add this property to DashBoardScreen
          isEditingOrder: true,
        ),
      ),
      (Route<dynamic> route) => false,
    ).then((value) {
      if (value == true) {
        // If editing was successful, refresh the lists
        refreshOrders();
      }
    });
    */
  }

  // void _printPendingOrder(HiveOrder order) {
  //   // Implement pending order printing
  //   showToast("Printing pending order: ${order.orderNumber}", context, color: true);
  // }

  Future<void> _deletePendingOrder(HiveOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Pending Order?"),
        content: const Text("Are you sure you want to delete this pending sync order? This action is local and permanent."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await HiveService.deleteOrder(order.id!);
        if (mounted) {
          setState(() {
            _pendingSyncOrders.removeWhere((o) => o.id == order.id);
          });
          showToast("Pending order deleted successfully", context, color: true);
        }
      } catch (e) {
        showToast("Failed to delete pending order", context, color: false);
      }
    }
  }

  Widget mainContainer() {
    final filteredOrders = _getFilteredOrders();

    // Show loading if both online and offline are loading
    if (widget.isLoading && _isLoadingOfflineOrders) {
      return Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
          alignment: Alignment.center,
          child: const SpinKitChasingDots(color: appPrimaryColor, size: 30)
      );
    }

    // Show empty state if no orders
    if (filteredOrders.isEmpty) {
      return Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
          alignment: Alignment.center,
          child: Text(
            "No Orders Today !!!",
            style: MyTextStyle.f16(greyColor, weight: FontWeight.w500),
          )
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: filteredOrders.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.8,
        ),
        itemBuilder: (context, index) {
          return _buildOrderCard(filteredOrders[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderTodayBloc, dynamic>(
      buildWhen: (previous, current) {
        // Update order list when GetOrderListTodayModel is emitted
        if (current is GetOrderListTodayModel) {
          getOrderListTodayModel = current;
          return true;
        }

        // Handle DeleteOrder online success
        if (current is DeleteOrderSuccessState) {
          showToast(current.message, context, color: true);
          setState(() {
            getOrderListTodayModel.data?.removeWhere(
                  (order) => order.id == current.orderId,
            );
          });
          return true;
        }

        // Handle DeleteOrder offline saved
        if (current is DeleteOrderOfflineSavedState) {
          showToast(current.message, context, color: true);
          setState(() {
            getOrderListTodayModel.data?.removeWhere(
                  (order) => order.id == current.orderId,
            );
          });
          return true;
        }

        // Handle DeleteOrder failure
        if (current is DeleteOrderFailureState) {
          showToast(current.message, context, color: false);
          return true;
        }

        // Handle view order (online)
        if (current is GetViewOrderModel) {
          try {
            getViewOrderModel = current;
            if (getViewOrderModel.errorResponse?.isUnauthorized == true) {
              _handle401Error();
              return true;
            }

            if (getViewOrderModel.success == true) {
              if (view == true) {
                // View Online Order (Show Receipt Dialog)
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => ThermalReceiptDialog(getViewOrderModel),
                  );
                });
              } else {
                // Edit Online Order (Navigate to DashBoardScreen)
                Navigator.of(context)
                    .pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => DashBoardScreen(
                      selectTab: 0,
                      existingOrder: getViewOrderModel,
                      isEditingOrder: true,
                    ),
                  ),
                      (Route<dynamic> route) => false,
                )
                    .then((value) {
                  if (value == true) {
                    context.read<OrderTodayBloc>().add(
                      OrderTodayList(todayDate, todayDate, "", "", ""),
                    );
                  }
                });
              }
            }
          } catch (e, stackTrace) {
            debugPrint("Error in processing view order: $e");
            debugPrintStack(stackTrace: stackTrace);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Something went wrong: ${e.toString()}")),
            );
          }
          return true;
        }
        return false;
      },
      builder: (context, dynamic state) {
        return mainContainer();
      },
    );
  }

  void _handle401Error() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove("token");
    await sharedPreferences.clear();
    showToast("Session expired. Please login again.", context, color: false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }
}

// Helper class to combine online and pending sync orders
class _OrderItem {
  final dynamic order;
  final bool isPendingSync;

  _OrderItem({required this.order, required this.isPendingSync});
}