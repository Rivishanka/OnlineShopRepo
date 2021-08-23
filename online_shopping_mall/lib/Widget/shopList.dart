import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_shopping_mall/Controller/shopService.dart';
import 'package:online_shopping_mall/Model/shop.dart';
import 'package:online_shopping_mall/Widget/map.dart';

class ShopList extends StatefulWidget {
  ShopList({Key key}) : super(key: key);
  @override
  _ShopListState createState() => _ShopListState();
}

class _ShopListState extends State<ShopList> {
  static ShopService _shopService = ShopService();
  TextStyle mallHeadingStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
  static TextEditingController searchBarController = TextEditingController();
  static Stream<QuerySnapshot> shopList;

  @override
  void initState() {
    shopList = _shopService.getMalls();
    super.initState();
  }

  void getMalls(String shopName) async{ //search malls
    if(shopName == "ALL"){
      setState(() {
        shopList = null;
        shopList = _shopService.getMalls();
        searchBarController.text = "";
      });
      //return api.getMalls();
    }else{
      setState(() {
        shopList = null;
        shopList = _shopService.getShopsByName(shopName);
      });
    }
  }

  Widget shoppingMalSearchBar(BuildContext context){
    return TextField(
      onEditingComplete: (){
        setState(() {
          shopList = null;
          getMalls(searchBarController.text);
        });
      },
      cursorColor: Colors.green,
      textInputAction: TextInputAction.search,
      controller: searchBarController,
      decoration: InputDecoration(
          labelText: "Search",
          hintText: "Search Mall Here",
          prefixIcon: IconButton(
            splashColor: Colors.blue,
            iconSize: 20.0,
            icon: Icon(Icons.search),
            onPressed: () {
              getMalls(searchBarController.text);
            },
          ),
          suffixIcon: IconButton(
            tooltip: "Clear Search",
            splashColor: Colors.blue,
            iconSize: 20.0,
            icon: Icon(Icons.clear),
            onPressed: () {
              getMalls("ALL");
            },
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))
          )
      ),
    );
  }

  Widget buildBody(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: shopList,
      builder: (context, snapshot){
        if(snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
        if(snapshot.hasData){
          //print("Documents ${snapshot.data.documents.length}");
          return buildList(context, snapshot.data.documents);
        }
      },
    );
  }

  Widget buildList(BuildContext context, List<DocumentSnapshot> snapshot){
    return ListView(
      children: snapshot.map((data) => buildListItem(context, data)).toList(), //map snapshot items
    );
  }

  Widget buildListItem(BuildContext context, DocumentSnapshot data){
    final mall = Shop.fromSnapshot(data);
    return Card(
      borderOnForeground: true,
      color: Colors.indigo,
      elevation: 5.0,
      child: ListTile(
        title: Text(
            mall.name,
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 20.0,
                fontWeight: FontWeight.bold
            )
        ),
        subtitle: Text(
            mall.description,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 15.0,
                fontWeight: FontWeight.normal
            )
        ),
        trailing: Icon(
          Icons.touch_app,
          color: Colors.grey[300],
        ),
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MallLocatorMap(title: 'Malls Edit Console', latitude: mall.latitude, longitude: mall.longitude, locationName: mall.name)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Mall Console'),
        backgroundColor: Colors.indigo[600],
      ),
      body: Container(
        padding: EdgeInsets.all(5.0),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              shoppingMalSearchBar(context),
              SizedBox(
                  height:5.0
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.location_on, size: 12.0,),
                  Text(
                    "  Tap to view location on Map",
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.green[600]
                    ),
                  ),
                ],
              ),
              Flexible(
                  child: buildBody(context)
              )
            ],
          ),
        ),
      ),
    );
  }
}
