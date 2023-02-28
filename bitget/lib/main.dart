//모든 디바이스 일관된 디자인 가이드라인 sdk 지원.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:developer';

//runApp은 호출될 때 위젯을 가져야 한다. 그래야 호출이 됨.
//myApp위젯 -> 커스텀 위젯 최초 빌드.

//처음 실행시 MyApp 실행
void main() => runApp((const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Bitget에 오신 것을 환영합니다!",
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        home: BitgetWidget());
  }
}

Future<Bitget> fetchBitget() async {
  final response = await http.get(Uri.parse(
      'https://api.bitget.com/api/mix/v1/market/tickers?productType=umcbl'));
  if (response.statusCode == 200) {
    //uri 파싱 성공시,
    return Bitget.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

class BitgetWidget extends StatefulWidget {
  const BitgetWidget({Key? key}) : super(key: key);
  @override
  _BitgetWidgetState createState() => _BitgetWidgetState();
}

class _BitgetWidgetState extends State<BitgetWidget> {
  late Future<Bitget> futureBitget;

  //처음 상태 정의
  @override
  void initState() {
    super.initState();
    futureBitget = fetchBitget();
  }
  //build할 것 정의
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Bitget>(
          future: futureBitget,
          builder: (context, snapshot) {
            //데이터를 못가져왔을 시,
            if (snapshot.hasData == false) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("error");
            }
            //데이터를 가져왔을 때,
            return Column(
              children: [
                //마진 주기.
                Container(
                  margin: const EdgeInsets.all(32.0),
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children:[
                      //제목
                      Expanded(
                        flex:3,
                          child:gradientText()
                      ),
                      //버튼
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              futureBitget = fetchBitget();
                              //호출 할 때 마다 뷰 초기화해서 변수를 알아서 넣어줌.
                              //flutter 정말 사기다..
                            });},
                          child: const Text("화면갱신")
                        ),
                      ),
                    ],
                  ),
                ),
                // 갱신 시간
                Container(
                    margin: const EdgeInsets.all(10.0),
                    child: Row(
                      //row를 오른쪽 정렬
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        //오른쪽에 정렬
                        dateText()
                      ],
                    )
                  ),
                // field
                Container(
                  margin: const EdgeInsets.all(15.0),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 1,
                        child: Text('실시간 시세',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            textAlign: TextAlign.left),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('변동율(%)',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '단위(KRW)',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                //ListView.separated로 리스트 뷰를 expanded로 나눠서 균등하게 표현
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(5.0),
                    itemCount: snapshot.data!.data!.length,
                    itemBuilder: (context, int index) {
                      return Container(
                        //color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: coinNameText(txt: "${snapshot.data!.data![index].symbol}")
                            ),
                            Expanded(
                              flex: 1,
                              child: percentText(txt: "${snapshot.data!.data![index].priceChangePercent}")
                            ),
                            Expanded(
                              flex: 1,
                              child: toKRWText(txt:'${snapshot.data!.data![index].last}')
                              ),
                          ],
                        ),
                      );
                    },
                    // 경계선 빌더
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(thickness: 1);
                    },
                  ),
                ),
              ],
            );
          }),
    );
  }
}
Text percentText({required String txt}) {
  //문자열인 text를 숫자로 바꾸기 위해 dynamic 으로 선언
  var t = double.parse(txt); // double로 바꾸기.
  //color를 증감에 따른 설정
  var colorNum = (t == 0)? Colors.black : (t>0) ? Colors.red : Colors.blue;
  String tt = t.toStringAsFixed(3); //소수 3자리 반올림 txt
  var text = double.parse(tt);
  return Text("$text%", style: TextStyle(fontSize: 14, color:colorNum),
      textAlign: TextAlign.center);
}

Text coinNameText({required String txt}) {
  //문자열인 text를 숫자로 바꾸기 위해 dynamic 으로 선언
  txt = txt.replaceAll("USDT_UMCBL", "");
  return Text(txt, style: const TextStyle(fontSize: 14, color:Colors.black),
      textAlign: TextAlign.left);
}

Text toKRWText({required dynamic txt}) {
  //문자열인 text를 숫자로 바꾸기 위해 dynamic 으로 선언
  var dallor = 1322.76;
  var f = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
  txt = (double.parse(txt) * dallor).ceil();
  return Text(f.format(txt), style: const TextStyle(fontSize: 14, color:Colors.black),
      textAlign: TextAlign.right);
}
Text dateText(){
  //현재 시간 생성
  DateTime dt = DateTime.now();
  var t = DateFormat('갱신시간 : MM월 dd일 HH시 mm분 ss초').format(dt);
  return Text(t, style: const TextStyle(fontSize: 14, color:Colors.black),
      textAlign: TextAlign.right);
}

Widget gradientText() {
  //그라이데이션을 위한 메서드
  final Shader linearGradientShader = const LinearGradient(colors: [Colors.red, Colors.orange,Colors.blue]).createShader(const Rect.fromLTWH(0.0, 20.0, 150.0, 20.0));
  return Text('Bitget 비트겟', style: TextStyle(foreground: Paint()..shader = linearGradientShader, fontSize: 40));
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
