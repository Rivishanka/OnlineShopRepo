import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Shop {
  String name;
  String description;
  double longitude;
  double latitude;
  DocumentReference reference;

  Shop({this.name, this.description, this.longitude, this.latitude});

  Shop.fromMap(Map<String, dynamic> map, {this.reference}):
  //id = map["id"],
        name = map["name"],
        description = map["description"],
        longitude = map["longitude"],
        latitude = map["latitude"];


  Map<String, dynamic> toMap(){
    return {
      'name': name,
      'description': description,
      'longitude': longitude,
      'latitude': latitude
    };

  }

  Shop.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  toJson(){
    return {
      //'id': id,
      'name': name,
      'description': description,
      'longitude': longitude,
      'latitude': latitude
    };
  }
}