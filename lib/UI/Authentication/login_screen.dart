import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Alertbox/snackBarAlert.dart';
import 'package:simple/Bloc/Authentication/login_bloc.dart';
import 'package:simple/ModelClass/Authentication/Post_login_model.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/bulk_product.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/customTextfield.dart';
import 'package:simple/Reusable/space.dart';
import 'package:simple/UI/DashBoard/custom_tabbar.dart';
import 'package:simple/UI/Home_screen/Helper/appconfig.dart';

import '../../Api/apiProvider.dart';
import '../../Offline/Hive_helper/localStorageHelper/hive_shop_details_service.dart';

Future<void> _initializeAppData(BuildContext context) async {
  try {
    debugPrint('🚀 Initializing app data...');

    // DEBUG: Check if we have token
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString("token");
    print("🔑 Token available: ${token != null && token.isNotEmpty}");

    // Load shop details first and wait for it to complete
    print("📡 Calling getShopDetailsAPI...");
    final shopDetails = await ApiProvider().getShopDetailsAPI();
    print("✅ API Response - success: ${shopDetails.success}");

    if (shopDetails.success == true && shopDetails.data != null) {
      print("💾 Saving shop details to Hive...");
      print("   - Shop Name: ${shopDetails.data!.name}");
      print("   - Contact: ${shopDetails.data!.contactNumber}");

      await HiveShopDetailsService.saveShopDetails(shopDetails);
      print("✅ Shop details stored in Hive after login");

      // VERIFY: Immediately check if data was saved
      print("🔍 Verifying Hive storage...");
      final savedData = await HiveShopDetailsService.getShopDetailsAsApiModel();
      if (savedData != null && savedData.data != null) {
        print("🎯 VERIFICATION SUCCESS - Data in Hive:");
        print("   - Name: ${savedData.data!.name}");
        print("   - Contact: ${savedData.data!.contactNumber}");
      } else {
        print("❌ VERIFICATION FAILED - No data in Hive!");
      }
    } else {
      print("❌ Failed to get shop details:");
      print("   - Success: ${shopDetails.success}");
      print("   - Error: ${shopDetails.errorResponse?.message}");
      print("   - Data is null: ${shopDetails.data == null}");
    }

    // Then load other data
    print("🔄 Loading categories and products...");
    await BulkDataService.fetchAllCategoriesWithProducts();
    await BulkDataService.fetchAndCacheAllCategoriesAndProducts();

    debugPrint('🎉 App data initialization complete!');
  } catch (e) {
    debugPrint('❌ App data initialization failed: $e');
    print("💥 Error details: $e");
    rethrow;
  }
}

Future<void> _loadShopDetailsManually() async {
  try {
    print("🔄 Manual shop details loading...");

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    bool hasConnection = connectivityResult != ConnectivityResult.none;
    print("📶 Connectivity: $hasConnection");

    if (!hasConnection) {
      print("❌ No internet connection for manual load");
      return;
    }

    // Load shop details
    final shopDetails = await ApiProvider().getShopDetailsAPI();
    print("📡 Manual API call - Success: ${shopDetails.success}");

    if (shopDetails.success == true && shopDetails.data != null) {
      await HiveShopDetailsService.saveShopDetails(shopDetails);
      print("✅ Manual save successful");

      // Verify
      final saved = await HiveShopDetailsService.getShopDetailsAsApiModel();
      print("🔍 Manual verification - Data exists: ${saved != null}");
    } else {
      print("❌ Manual load failed: ${shopDetails.errorResponse?.message}");
    }
  } catch (e) {
    print("💥 Manual load error: $e");
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginInBloc(),
      child: const LoginScreenView(),
    );
  }
}

class LoginScreenView extends StatefulWidget {
  const LoginScreenView({
    super.key,
  });

  @override
  LoginScreenViewState createState() => LoginScreenViewState();
}

class LoginScreenViewState extends State<LoginScreenView> {
  PostLoginModel postLoginModel = PostLoginModel();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  RegExp emailRegex = RegExp(r'\S+@\S+\.\S+');
  String? errorMessage;
  var showPassword = true;
  bool loginLoad = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleSuccessfulLogin() async {
    try {
      setState(() {
        loginLoad = true;
      });

      final connectivityResult = await Connectivity().checkConnectivity();
      bool hasConnection = connectivityResult != ConnectivityResult.none;

      debugPrint('🌐 Connectivity: $hasConnection');

      if (hasConnection) {
        // Show loading dialog while initializing data
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SpinKitCircle(color: appPrimaryColor, size: 40),
                  SizedBox(height: 16),
                  Text('Loading shop details...'),
                ],
              ),
            );
          },
        );

        // Wait for app data to initialize
        await _initializeAppData(context);

        // Close loading dialog
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Navigate to dashboard
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const DashBoardScreen(
              selectTab: 0,
            ),
          ),
              (Route<dynamic> route) => false,
        );
      } else {
        // Offline mode - navigate directly
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const DashBoardScreen(
              selectTab: 0,
            ),
          ),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Close loading dialog if there's an error
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      showToast('Error initializing app: $e', context, color: false);
      setState(() {
        loginLoad = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Widget mainContainer() {
      return Form(
        key: _formKey,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: size.width * 0.5,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: appPrimaryColor),
                  boxShadow: [
                    BoxShadow(
                      color: blackColor12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: appPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Subtitle
                    Text('Sign in to start your session'),
                    SizedBox(height: 12),

                    // Email field
                    CustomTextField(
                        hint: "Email Address",
                        readOnly: false,
                        controller: email,
                        baseColor: appPrimaryColor,
                        borderColor: appGreyColor,
                        errorColor: redColor,
                        inputType: TextInputType.text,
                        showSuffixIcon: false,
                        FTextInputFormatter: FilteringTextInputFormatter.allow(
                            RegExp("[a-zA-Z0-9.@]")),
                        obscureText: false,
                        maxLength: 30,
                        onChanged: (val) {
                          _formKey.currentState!.validate();
                        },
                        validator: (value) {
                          if (value != null) {
                            if (value.isEmpty) {
                              return 'Please enter your email';
                            } else if (!emailRegex.hasMatch(value)) {
                              return 'Please enter valid email';
                            } else {
                              return null;
                            }
                          }
                          return null;
                        }),
                    SizedBox(height: 12),

                    // Password field
                    CustomTextField(
                        hint: "Password",
                        readOnly: false,
                        controller: password,
                        baseColor: appPrimaryColor,
                        borderColor: appGreyColor,
                        errorColor: redColor,
                        inputType: TextInputType.text,
                        obscureText: showPassword,
                        showSuffixIcon: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: appGreyColor,
                          ),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                        maxLength: 80,
                        onChanged: (val) {
                          _formKey.currentState!.validate();
                        },
                        validator: (value) {
                          if (value != null) {
                            if (value.isEmpty) {
                              return 'Please enter your password';
                            } else {
                              return null;
                            }
                          }
                          return null;
                        }),
                    SizedBox(height: 12),
                    loginLoad
                        ? const SpinKitCircle(color: appPrimaryColor, size: 30)
                        : InkWell(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            loginLoad = true;
                          });
                          context.read<LoginInBloc>().add(LoginIn(
                            email.text,
                            password.text,
                          ));
                        }
                      },
                      child: appButton(
                          height: 50,
                          width: size.width * 0.85,
                          buttonText: "Login"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
        backgroundColor: whiteColor,
        body: BlocBuilder<LoginInBloc, dynamic>(
          buildWhen: ((previous, current)  {
            if (current is PostLoginModel) {
              postLoginModel = current;
              if (postLoginModel.success == true) {
                if (postLoginModel.user!.role == "OPERATOR") {
                  // Handle successful login
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _handleSuccessfulLogin();
                  });
                } else {
                  showToast("Please Login Admin in Web", context, color: false);
                  setState(() {
                    loginLoad = false;
                  });
                }
              } else {
                final errorMsg =
                    postLoginModel.errorResponse?.errors?.first.message ??
                        postLoginModel.message ??
                        "Login failed. Please try again.";
                showToast(errorMsg, context, color: false);
                setState(() {
                  loginLoad = false;
                });
              }
              return true;
            }
            return false;
          }),
          builder: (context, dynamic) {
            return mainContainer();
          },
        ));
  }
}