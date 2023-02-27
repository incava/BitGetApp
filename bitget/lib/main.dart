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
      Uri.parse('https://api.bitget.com/api/mix/v1/market/tickers?productType=umcbl')
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Bitget>(
        future: futureBitget,
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return CircularProgressIndicator();
          }
          else if (snapshot.hasError) {
            return Text("error");
          }
          return Column(
            children: <Widget>[
              ...snapshot.data!.data!.map((e) =>
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 4,
                  child: Text("${e.symbol} ${e.priceChangePercent} ${e.last} "),
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
  String? msg;
  int? requestTime;
  List<Data>? data;

  Bitget({this.code, this.msg, this.requestTime, this.data});

  Bitget.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    requestTime = json['requestTime'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    data['requestTime'] = this.requestTime;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? symbol;
  String? last;
  String? bestAsk;
  String? bestBid;
  String? bidSz;
  String? askSz;
  String? high24h;
  String? low24h;
  String? timestamp;
  String? priceChangePercent;
  String? baseVolume;
  String? quoteVolume;
  String? usdtVolume;
  String? openUtc;
  String? chgUtc;

  Data(
      {this.symbol,
        this.last,
        this.bestAsk,
        this.bestBid,
        this.bidSz,
        this.askSz,
        this.high24h,
        this.low24h,
        this.timestamp,
        this.priceChangePercent,
        this.baseVolume,
        this.quoteVolume,
        this.usdtVolume,
        this.openUtc,
        this.chgUtc});

  Data.fromJson(Map<String, dynamic> json) {
    symbol = json['symbol'];
    last = json['last'];
    bestAsk = json['bestAsk'];
    bestBid = json['bestBid'];
    bidSz = json['bidSz'];
    askSz = json['askSz'];
    high24h = json['high24h'];
    low24h = json['low24h'];
    timestamp = json['timestamp'];
    priceChangePercent = json['priceChangePercent'];
    baseVolume = json['baseVolume'];
    quoteVolume = json['quoteVolume'];
    usdtVolume = json['usdtVolume'];
    openUtc = json['openUtc'];
    chgUtc = json['chgUtc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['symbol'] = this.symbol;
    data['last'] = this.last;
    data['bestAsk'] = this.bestAsk;
    data['bestBid'] = this.bestBid;
    data['bidSz'] = this.bidSz;
    data['askSz'] = this.askSz;
    data['high24h'] = this.high24h;
    data['low24h'] = this.low24h;
    data['timestamp'] = this.timestamp;
    data['priceChangePercent'] = this.priceChangePercent;
    data['baseVolume'] = this.baseVolume;
    data['quoteVolume'] = this.quoteVolume;
    data['usdtVolume'] = this.usdtVolume;
    data['openUtc'] = this.openUtc;
    data['chgUtc'] = this.chgUtc;
    return data;
  }
}





