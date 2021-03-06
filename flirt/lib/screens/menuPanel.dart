import 'package:flutter/material.dart';
import '../services/getService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './cartPage.dart';
import './custloginPage.dart';

class MenuPage extends StatefulWidget {
  var restaurant;
  SharedPreferences token;
  MenuPage(rest, user) {
    restaurant = rest;
    token = user;
  }
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool isSearch = false;
  String rest;
  int _quan = 0;
  List<dynamic> cart = List<dynamic>();

  getMenu() async {
    final menu = await GetService().getMenu(widget.restaurant);
    return menu;
  }

  @override
  void initState() {
    super.initState();
    this.rest = widget.restaurant;
    cart = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text(
          "$rest GIKI",
          style: TextStyle(color: Colors.orange[400]),
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                Cart(cart, widget.token, this.rest)));
                  },
                  child: this.cart.length == 0
                      ? Icon(Icons.shopping_cart)
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Cart(cart, widget.token, this.rest)));
                          },
                          child: new Stack(children: <Widget>[
                            new Padding(
                                padding: EdgeInsets.only(top: 15),
                                child: Icon(Icons.shopping_cart)),
                            new Positioned(
                              // draw a red marble
                              top: 12.0,
                              right: 0.0,
                              child: new Icon(Icons.brightness_1,
                                  size: 8.0, color: Colors.redAccent),
                            ),
                          ])))),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  widget.token.remove('tokken');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => CustLogin()));
                },
                child: Icon(
                  Icons.logout,
                ),
              )),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: FutureBuilder(
          future: getMenu(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: <Widget>[
                  for (var item in snapshot.data)
                    menuItems(item['name'], item['price'])
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _showMyDialog(item, val) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              actionsPadding: EdgeInsets.only(bottom: 20),
              title: Text('Qantity'),
              actions: <Widget>[
                new FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      ++_quan;
                    });
                  },
                  child: new Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                  backgroundColor: Colors.white,
                ),
                new Text('$_quan', style: new TextStyle(fontSize: 20.0)),
                new FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (_quan != 0) _quan--;
                    });
                  },
                  child: new Icon(Icons.remove, color: Colors.black),
                  backgroundColor: Colors.white,
                ),
                new TextButton(
                  child: Text('Confirm'),
                  onPressed: () {
                    cartPush(item, val, _quan);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  menuItems(String item, var val) {
    return GestureDetector(
      onTap: () async {
        await _showMyDialog(item, val);
      },
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Text(
            '$item Rs. $val',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  cartPush(item, price, quantity) {
    var choice = true;
    for (var food in this.cart) {
      if (food['item'] == item) {
        food['quantity'] = food['quantity'] + quantity;
        choice = false;
        setState(() {
          _quan = 0;
        });
        break;
      }
      choice = true;
    }
    if (choice) {
      if (quantity > 0) {
        final product = {'item': item, 'price': price, 'quantity': quantity};
        setState(() {
          cart.add(product);
        });
        Fluttertoast.showToast(
            msg: '$item added to cart',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.grey[800],
            textColor: Colors.white);
        setState(() {
          _quan = 0;
        });
      }
    }
    setState(() {});
    print(cart);
  }
}
