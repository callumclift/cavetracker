import 'dart:async';
import 'dart:io';
import 'package:caving_app/locator.dart';
import 'package:caving_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/cupertino.dart';

import 'authentication_model.dart';

class PurchasingModel with ChangeNotifier {


  AuthenticationModel authenticationModel = AuthenticationModel();
  final NavigationService _navigationService = locator<NavigationService>();


  PurchasingModel(this.authenticationModel);


  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;
  bool available = true;
  StreamSubscription subscription;
  final String myProductID = 'monthly_1';


  bool _isPurchased = false;
  bool get isPurchased => _isPurchased;
  set isPurchased(bool value) {
    _isPurchased = value;
    notifyListeners();
  }




  List _purchases = [];
  List get purchases => _purchases;
  set purchases(List value) {
    _purchases = value;
    notifyListeners();
  }


  List _products = [];
  List get products => _products;
  set products(List value) {
    _products = value;
    notifyListeners();
  }



  void initialize() async {
    available = await _iap.isAvailable();
    if (available) {
      await _getProducts();
      await _getPastPurchases();
      print('done');
      verifyPurchase();
      subscription = _iap.purchaseUpdatedStream.listen((data) {
        purchases.addAll(data);
        verifyPurchase();
      });
    }
  }


  void verifyPurchase() {
    PurchaseDetails purchase = hasPurchased(myProductID);

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
        isPurchased = true;
      }

    }
  }


  PurchaseDetails hasPurchased(String productID) {
    return purchases.firstWhere(
            (purchase) => purchase.productID == productID,
        orElse: () => null);
  }



  Future<void> _getProducts() async {
    Set<String> ids = Set.from([myProductID]);
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    print(response.notFoundIDs);
    products = response.productDetails;
    print(products);
    print('herhehrehre');

  }


  Future<void> _getPastPurchases() async {
    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();
    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        _iap.consumePurchase(purchase);
      }
    } purchases = response.pastPurchases;

  }



}