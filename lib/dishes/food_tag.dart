import 'package:flutter/material.dart';

enum FoodTag {
  bread,
  carrot,
  cheese,
  chicken,
  fish,
  lettuce,
  meat,
  mayonnaise,
  mushroom,
  olive,
  oliveOil,
  pasta,
  potato,
  salami,
  tomato,
  vegetable;

  AssetImage get icon {
    switch (this) {
      case FoodTag.bread:
        return const AssetImage("assets/images/category/bread.png");
      case FoodTag.carrot:
        return const AssetImage("assets/images/category/carrot.png");
      case FoodTag.cheese:
        return const AssetImage("assets/images/category/cheese.png");
      case FoodTag.chicken:
        return const AssetImage("assets/images/category/chicken.png");
      case FoodTag.fish:
        return const AssetImage("assets/images/category/fish.png");
      case FoodTag.lettuce:
        return const AssetImage("assets/images/category/lettuce.png");
      case FoodTag.meat:
        return const AssetImage("assets/images/category/meat.png");
      case FoodTag.mayonnaise:
        return const AssetImage("assets/images/category/mayonnaise.png");
      case FoodTag.mushroom:
        return const AssetImage("assets/images/category/mushroom.png");
      case FoodTag.olive:
        return const AssetImage("assets/images/category/olive.png");
      case FoodTag.oliveOil:
        return const AssetImage("assets/images/category/olive_oil.png");
      case FoodTag.pasta:
        return const AssetImage("assets/images/category/pasta.png");
      case FoodTag.potato:
        return const AssetImage("assets/images/category/potato.png");
      case FoodTag.salami:
        return const AssetImage("assets/images/category/salami.png");
      case FoodTag.tomato:
        return const AssetImage("assets/images/category/tomato.png");
      case FoodTag.vegetable:
        return const AssetImage("assets/images/category/vegetable.png");
    }
  }
}
