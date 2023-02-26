//모든 디바이스 일관된 디자인 가이드라인 sdk 지원.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
//runApp은 호출될 때 위젯을 가져야 한다. 그래야 호출이 됨.
//myApp위젯 -> 커스텀 위젯 최초 빌드.

void main() => runApp((const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Welcome to Flutter",
      theme:ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BitgetWidget(),
    );
  }
}

Future<Bitget> fetchBitget()async{
  final response = await http.get(
      Uri.parse('https://api.bitget.com/api/mix/v1/market/contracts?productType=umcbl')
  );
  if(response.statusCode == 200){
    print("Response body: ${response.body}");
    return Bitget.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

class BitgetWidget extends StatefulWidget{
  const BitgetWidget({Key? key}) : super(key:key);

  @override
  _BitgetWidgetState createState() => _BitgetWidgetState();
}

class _BitgetWidgetState extends State<BitgetWidget> {
  late Future<Bitget> futureBitget;

  @override
  void initState() {
    super.initState();
    futureBitget = fetchBitget();
  }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "bit",
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Fetch Data Example'),
//         ),
//         body: Center(
//           child: FutureBuilder<Data>(
//             future: futureBitget,
//             builder: (context, snapshot){
//               if(snapshot.hasData){
//               return Text(snapshot.data);
//               } else if (snapshot.hasError) {
//               return Text("${snapshot.error}");
//               }
//               return CircularProgressIndicator();
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Bitget>(
        future: futureBitget,
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return const CircularProgressIndicator();
          }
          else if (snapshot.hasError) {
            return const Text("error");
          }
          return Column(
            children: <Widget>[
              ...snapshot.data!.data!.map((e) =>
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 4,
                  child: Text("${e.baseCoin!} ${e.buyLimitPriceRatio!} ${e.limitOpenTime!}"),
                ),
              )),
            ],
          );
        }
    );
  }
}



/**
 * 비트겟 object담을 그릇
 */
class Bitget {
  String? code;
  List<Data>? data;
  String? msg;
  int? requestTime;

  Bitget({this.code, this.data, this.msg, this.requestTime});

  Bitget.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    msg = json['msg'];
    requestTime = json['requestTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['msg'] = this.msg;
    data['requestTime'] = this.requestTime;
    return data;
  }
}

class Data {
  String? baseCoin;
  String? buyLimitPriceRatio;
  String? feeRateUpRatio;
  String? makerFeeRate;
  String? minTradeNum;
  String? openCostUpRatio;
  String? priceEndStep;
  String? pricePlace;
  String? quoteCoin;
  String? sellLimitPriceRatio;
  String? sizeMultiplier;
  List<String>? supportMarginCoins;
  String? symbol;
  String? takerFeeRate;
  String? volumePlace;
  String? symbolType;
  String? symbolStatus;
  String? offTime;
  String? limitOpenTime;

  Data(
      {this.baseCoin,
        this.buyLimitPriceRatio,
        this.feeRateUpRatio,
        this.makerFeeRate,
        this.minTradeNum,
        this.openCostUpRatio,
        this.priceEndStep,
        this.pricePlace,
        this.quoteCoin,
        this.sellLimitPriceRatio,
        this.sizeMultiplier,
        this.supportMarginCoins,
        this.symbol,
        this.takerFeeRate,
        this.volumePlace,
        this.symbolType,
        this.symbolStatus,
        this.offTime,
        this.limitOpenTime});

  Data.fromJson(Map<String, dynamic> json) {
    baseCoin = json['baseCoin'];
    buyLimitPriceRatio = json['buyLimitPriceRatio'];
    feeRateUpRatio = json['feeRateUpRatio'];
    makerFeeRate = json['makerFeeRate'];
    minTradeNum = json['minTradeNum'];
    openCostUpRatio = json['openCostUpRatio'];
    priceEndStep = json['priceEndStep'];
    pricePlace = json['pricePlace'];
    quoteCoin = json['quoteCoin'];
    sellLimitPriceRatio = json['sellLimitPriceRatio'];
    sizeMultiplier = json['sizeMultiplier'];
    supportMarginCoins = json['supportMarginCoins'].cast<String>();
    symbol = json['symbol'];
    takerFeeRate = json['takerFeeRate'];
    volumePlace = json['volumePlace'];
    symbolType = json['symbolType'];
    symbolStatus = json['symbolStatus'];
    offTime = json['offTime'];
    limitOpenTime = json['limitOpenTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['baseCoin'] = this.baseCoin;
    data['buyLimitPriceRatio'] = this.buyLimitPriceRatio;
    data['feeRateUpRatio'] = this.feeRateUpRatio;
    data['makerFeeRate'] = this.makerFeeRate;
    data['minTradeNum'] = this.minTradeNum;
    data['openCostUpRatio'] = this.openCostUpRatio;
    data['priceEndStep'] = this.priceEndStep;
    data['pricePlace'] = this.pricePlace;
    data['quoteCoin'] = this.quoteCoin;
    data['sellLimitPriceRatio'] = this.sellLimitPriceRatio;
    data['sizeMultiplier'] = this.sizeMultiplier;
    data['supportMarginCoins'] = this.supportMarginCoins;
    data['symbol'] = this.symbol;
    data['takerFeeRate'] = this.takerFeeRate;
    data['volumePlace'] = this.volumePlace;
    data['symbolType'] = this.symbolType;
    data['symbolStatus'] = this.symbolStatus;
    data['offTime'] = this.offTime;
    data['limitOpenTime'] = this.limitOpenTime;
    return data;
  }
}




