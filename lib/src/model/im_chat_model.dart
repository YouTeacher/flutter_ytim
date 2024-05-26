import 'dart:convert';

import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_group.dart';
import 'package:flutter_ytim/src/model/im_message.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';

/// IM用户信息
class IMChatModel {
  ChatType chatType;

  ///来源
  String? userId;
  String? groupId;
  String? storeId;
  StoreModel? store;
  int? unreadMessageCount;

  ///最后时间‘1700132091676’
  String? lastTalkAt;

  IMUser? userInfo;

  //需要本地数据赋值
  IMGroup? gourp;

  List<IMMessage>? unreadMessageList;

  IMChatModel({
    required this.chatType,
    this.userId,
    this.groupId,
    this.storeId,
    this.store,
    this.lastTalkAt,
    this.userInfo,
    this.gourp,
    this.unreadMessageList,
    this.unreadMessageCount,
  });

  factory IMChatModel.fromJson(Map<String, dynamic> json) {
    return IMChatModel(
      chatType: json['type']?.toString() == '1' ? ChatType.user : json['type']?.toString() == '2' ? ChatType.groups : ChatType.store,
      groupId: json['groupId'].toString(),
      storeId: json['storeId'].toString(),
      userId: json['userId'].toString(),
      lastTalkAt: json['lastTalkAt'] ?? IMUtils.getTimestamp(),
      unreadMessageCount: json['unreadMessageCount'],
      unreadMessageList: json['unreadMessageList'] == null
          ? null
          : (json['unreadMessageList'] as List)
              .map((e) => IMMessage.fromJson(e,ChatType.user))
              .toList(),
      userInfo: json['userInfo'] == null
          ? null
          : IMUser.fromJson(
              json['userInfo'],
            ),
      store: json['store'] == null
          ? null
          : StoreModel.fromJson(
              json['store'],
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': chatType,
      'userId': userId,
      'groupId': groupId,
      'storeId': storeId,
      'lastTalkAt': lastTalkAt,
      'unreadMessageList': unreadMessageList,
      'userInfo': userInfo,
      'unreadMessageCount': unreadMessageCount,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}

class StoreModel {
  String? provinceId,
      name,
      tel,
      cover,
      logo,
      fax,
      openingHours,
      regularHoliday,
      otherHoliday,
      postcode,
      province,
      depositMonthlyPrice,
      isFavorite,
      memberBenefits;
  Geo? geo;
  Address? address;
  List<String>? images;
  int? star;
  int? commentCount, storeId, isStoreMember, deleted, hasStaff;

  StoreModel({
    this.storeId,
    this.provinceId,
    this.name,
    this.tel,
    this.cover,
    this.logo,
    this.fax,
    this.openingHours,
    this.regularHoliday,
    this.otherHoliday,
    this.postcode,
    this.province,
    this.geo,
    this.isFavorite,
    this.depositMonthlyPrice,
    this.address,
    this.images,
    this.star,
    this.commentCount,
    this.memberBenefits,
    this.isStoreMember,
    this.deleted,
    this.hasStaff,
  });

  factory StoreModel.fromJson(Map<String, dynamic>? data) {
    if (data == null) {
      return StoreModel();
    }
    List<String> imageList = [];
    if (data.containsKey("images") && data['images'] != null) {
      for (var item in data['images']) {
        imageList.add(item.toString());
      }
    }

    return StoreModel(
      storeId: data['storeId'],
      name: data['name'] ?? '',
      cover: data['cover'] ?? '',
      logo: data['logo'] ?? '',
      fax: data['fax'] ?? '',
      tel: data['tel'] ?? '',
      openingHours: data['openingHours'] ?? '',
      regularHoliday: data['regularHoliday'] ?? '',
      postcode: data['postcode'] ?? '',
      province: data['province'] ?? '',
      isFavorite: data['isFavorite'].toString(),
      geo: data['geo'] != null
          ? Geo.fromJson(Map<String, dynamic>.from(data['geo']))
          : null,
      address: data['address'] != null
          ? Address.fromJson(Map<String, dynamic>.from(data['address']))
          : null,
      provinceId: data['provinceId'].toString(),
      depositMonthlyPrice: data['depositMonthlyPrice'] != null
          ? data['depositMonthlyPrice'].toString()
          : '',
      images: imageList,
      star: data['star'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      memberBenefits: data['memberBenefits'],
      isStoreMember: data['isStoreMember'] ?? 0,
      deleted: data['deleted'] ?? 0,
      hasStaff: data['hasStaff'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'name': name,
      'cover': cover,
      'fax': fax,
      'openingHours': openingHours,
      'regularHoliday': regularHoliday,
      'tel': tel,
      'geo': geo,
      'postcode': postcode,
      'province': province,
      'address': address,
      'isFavorite': isFavorite,
      'provinceId': provinceId,
    };
  }
}

class Geo {
  String? lat, lng;

  Geo({this.lat, this.lng});

  factory Geo.fromJson(Map<String, dynamic>? data) {
    if (data == null) {
      return Geo();
    }
    return Geo(
      lat: data['lat'] ?? '',
      lng: data['lng'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

class Address {
  String? city, town, building;

  Address({this.city, this.town, this.building});

  factory Address.fromJson(Map<String, dynamic>? data) {
    if (data == null) {
      return Address();
    }
    return Address(
      city: data['city'] ?? '',
      town: data['town'] ?? '',
      building: data['building'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'town': town,
      'building': building,
    };
  }
}
