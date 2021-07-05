import 'package:caving_app/models/authentication_model.dart';
import 'package:caving_app/models/purchasing_model.dart';
import 'package:caving_app/shared/global_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionPage extends StatefulWidget {


  SubscriptionPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return _SubscriptionPageState();
  }
}

class _SubscriptionPageState extends State<SubscriptionPage> {

  bool loading = true;
  Product product;
  Package package;
  PurchaserInfo purchaserInfo;

  @override
  initState(){
    super.initState();
    getProducts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getProducts() async {
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
      print(purchaserInfo);
      print('lalaalaa');
      Offerings offerings = await Purchases.getOfferings();
      package = offerings.current.monthly;
      if (offerings.current != null && offerings.current.monthly != null) {
        product = offerings.current.monthly.product;
        // Get the price and introductory period from the Product
        print(product.title);
        print(product.currencyCode);
        print(product.price);
        print(product.description);
      }
      setState(() {
        loading = false;
      });
    } on PlatformException catch (e) {
      // optional error handling
      setState(() {
        loading = false;
      });
    }
  }

  purchaseProduct() async {
    try {
      PurchaserInfo purchaserInfo = await Purchases.purchasePackage(package);
      print('should be here');
      print(purchaserInfo.activeSubscriptions);
      if (purchaserInfo.entitlements.all["Unlimited"].isActive) {
        print('hererere');
        // Unlock that great "pro" content
      }
    } on PlatformException catch (e) {
      print(e);
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        //showError(e);
      }
    }
  }

  Widget test(){
    return SingleChildScrollView(
      child: SafeArea(
        child: Wrap(
          children: <Widget>[
            Container(
              height: 70.0,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(25.0))),
              child: Center(
                  child:
                  Text('✨ Magic Weather Premium', style: TextStyle(color: Colors.white))),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 32, bottom: 16, left: 16.0, right: 16.0),
              child: Container(
                child: Text(
                  'MAGIC WEATHER PREMIUM',
                  style: TextStyle(color: Colors.white),
                ),
                width: double.infinity,
              ),
            ),
            Card(
              color: Colors.black,
              child: ListTile(
                  onTap: () async {
                    try {

                    } catch (e) {
                      print(e);
                    }

                    setState(() {});
                    Navigator.pop(context);
                  },
                  title: Text(
                    product.title,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    product.title,
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Text(product.priceString,
                      style: TextStyle(color: Colors.white),)),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 32, bottom: 16, left: 16.0, right: 16.0),
              child: Container(
                child: Text(
                  'text',
                  style: TextStyle(color: Colors.white),
                ),
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPageContent(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 600.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        color: whiteGreen,
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
          child: product == null ? Center(child: Text('problem loading product'),) :
          Column(
            children: [
              Text(product.title),
              Text(product.currencyCode),
              Text(product.price.toString()),
              Text(product.description),
              SizedBox(height: 10,),
              TextButton(child: Text('purchase'), onPressed: () => purchaseProduct(),),
              TextButton(child: Text('purchase'), onPressed: () => getProducts(),)
            ],
          ),
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      backgroundColor: whiteGreen,
      appBar: AppBar(iconTheme: IconThemeData(color: darkBlue), backgroundColor: mintGreen,
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Sign Up', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),)),
      ),
      body: loading ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(darkBlue),
        ),
      ) : _buildPageContent(context),
    );
  }
}
