import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Order/order_list_bloc.dart';
import 'package:simple/ModelClass/Order/Delete_order_model.dart';
import 'package:simple/ModelClass/Order/Get_view_order_model.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart';
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
  String? errorMessage;
  bool view = false;
  final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? fromDate;
  String? type;

  void refreshOrders() {
    if (!mounted || !context.mounted) return;
    context.read<OrderTodayBloc>().add(
          OrderTodayList(todayDate, todayDate, widget.selectedTableName ?? "",
              widget.selectedWaiterName ?? "", widget.selectOperator ?? ""),
        );
  }

  @override
  void initState() {
    super.initState();

    if (widget.sharedOrderData != null) {
      getOrderListTodayModel = widget.sharedOrderData!;
    }
  }

  @override
  void didUpdateWidget(OrderViewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sharedOrderData != null) {
      setState(() {
        getOrderListTodayModel = widget.sharedOrderData!;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      // case "HD":
      //   type = "HD";
      //   break;
      // case "SWIGGY":
      //   type = "SWIGGY";
      //   break;
      default:
        type = null;
    }

    final filteredOrders = getOrderListTodayModel.data?.where((order) {
          if (widget.type == "All") return true;
          return order.orderType?.toUpperCase() == type;
        }).toList() ??
        [];

    Widget mainContainer() {
      return widget.isLoading
          ? Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1),
              alignment: Alignment.center,
              child: const SpinKitChasingDots(color: appPrimaryColor, size: 30))
          : getOrderListTodayModel.data == null ||
                  getOrderListTodayModel.data == [] ||
                  getOrderListTodayModel.data!.isEmpty
              ? Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1),
                  alignment: Alignment.center,
                  child: Text(
                    "No Orders Today !!!",
                    style: MyTextStyle.f16(
                      greyColor,
                      weight: FontWeight.w500,
                    ),
                  ))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    itemCount: filteredOrders.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.8,
                    ),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "Order ID: ${order.orderNumber ?? '--'}",
                                      style: MyTextStyle.f14(appPrimaryColor,
                                          weight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    "₹${order.total?.toStringAsFixed(2) ?? '0.00'}",
                                    style: MyTextStyle.f14(appPrimaryColor,
                                        weight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Type: ${order.orderType ?? '--'}"),
                                  Text(
                                    "Status: ${order.orderStatus}",
                                    style: TextStyle(
                                      color: order.orderStatus == 'COMPLETED'
                                          ? greenColor
                                          : orangeColor,
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
                                        constraints: BoxConstraints(),
                                        icon: Icon(Icons.remove_red_eye,
                                            color: appPrimaryColor, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            view = true;
                                          });
                                          context
                                              .read<OrderTodayBloc>()
                                              .add(ViewOrder(order.id));
                                        },
                                      ),
                                      SizedBox(width: 4),
                                      // if (widget.operatorShared ==
                                      //     widget.selectOperator ||
                                      //     widget.selectOperator == null ||
                                      //     widget.selectOperator == "")
                                      //   IconButton(
                                      //     padding: EdgeInsets.zero,
                                      //     constraints: const BoxConstraints(),
                                      //     icon: Icon(Icons.edit, color: appPrimaryColor, size: 20),
                                      //     onPressed: ()
                                      //     {
                                      //       if (order.id == null)
                                      //       {
                                      //         debugPrint("⚠️ Order ID is null, cannot view order");
                                      //         return;
                                      //       }
                                      //       // Update UI only if widget is still mounted
                                      //       if (mounted)
                                      //       {
                                      //         setState(() {
                                      //           view = false;
                                      //         });
                                      //       }
                                      //       // Trigger bloc event with a safe order ID
                                      //       context.read<OrderTodayBloc>().add(ViewOrder(order.id!));
                                      //       debugPrint("📦 Viewing order with ID: ${order.id}");
                                      //     },
                                      //   ),
                                      //
                                      // SizedBox(width: 4),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                        icon: Icon(Icons.print_outlined,
                                            color: appPrimaryColor, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            view = true;
                                          });
                                          context
                                              .read<OrderTodayBloc>()
                                              .add(ViewOrder(order.id));
                                        },
                                      ),
                                      SizedBox(width: 4),
                                      if (order.orderStatus != 'COMPLETED')
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          icon: Icon(Icons.delete,
                                              color: appPrimaryColor, size: 20),
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
                    },
                  ),
                );
    }

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

        // Handle view order
        if (current is GetViewOrderModel) {
          try {
            getViewOrderModel = current;
            if (getViewOrderModel.errorResponse?.isUnauthorized == true) {
              _handle401Error();
              return true;
            }

            if (getViewOrderModel.success == true) {
              if (view == true) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) =>
                        ThermalReceiptDialog(getViewOrderModel),
                  );
                });
              } else {
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
            print(stackTrace);
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
    await SharedPreferences.getInstance();
    await sharedPreferences.remove("token");
    await sharedPreferences.clear();
    showToast("Session expired. Please login again.", context, color: false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
