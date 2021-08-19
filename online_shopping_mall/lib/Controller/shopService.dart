import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShopService {
  static final ShopService _firestoreService = ShopService._internal();
  final String shopCollection = 'shop';

  Firestore _shopDb = Firestore.instance;
  // FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  ShopService._internal();

  factory ShopService(){
    return _firestoreService;
  }

  //GET METHODS
  getMalls(){
    Stream<QuerySnapshot> shops = _shopDb.collection(shopCollection).snapshots();
    return shops;
  }

  getShopsByName(String mallName){
    return _shopDb.collection(shopCollection).where('name', isEqualTo: mallName).snapshots();
  }
}