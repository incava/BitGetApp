//모든 디바이스 일관된 디자인 가이드라인 sdk 지원.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
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
          primaryColor : Colors.cyan
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
  late Timer _timer;

  //처음 상태 정의
  @override
  void initState() {
    super.initState();
    futureBitget = fetchBitget();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //flutterToast();
      _start(); // 위젯이 다 불러와진 후, 콜백 받아서 1초마다 갱신.
    });
  }

// 위젯이 dispose될 때 _timer를 cancel합니다.
// ?. 옵셔널 체이닝을 통해 _timer가 null이 아닌 경우 cancel하도록 해줬습니다.
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        futureBitget = fetchBitget();
      });
    });
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


                // Container(
                //   margin: const EdgeInsets.all(10.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children:[
                //       //제목
                //       Expanded(
                //         flex:3,
                //           child:gradientText()
                //       ),
                //       //버튼
                //       Expanded(
                //         flex: 1,
                //         child: ElevatedButton(
                //           onPressed: () {
                //             setState(() {
                //               futureBitget = fetchBitget();
                //               //호출 할 때 마다 뷰 초기화해서 변수를 알아서 넣어줌.
                //               //flutter 정말 사기다..
                //             });},
                //           child: const Text("화면갱신")
                //         ),
                //       ),
                //     ],
                //   ),
                // ),


                // 갱신 시간
                // Container(
                //     margin: const EdgeInsets.all(10.0),
                //     child: Row(
                //       //row를 오른쪽 정렬
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       children: [
                //         //오른쪽에 정렬
                //         dateText()
                //       ],
                //     )
                //   ),

                // field
                Container(
                  margin: const EdgeInsets.all(15.0),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 1,
                        child: Text('Coin/Volume',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.left),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Last price',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.right),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Change%',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
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
                        padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: nameAry(mainText: coinNameText(txt: "${snapshot.data!.data![index].symbol}"),
                                  subText: volumeText(txt: "${snapshot.data!.data![index].baseVolume}"),
                                  align: MainAxisAlignment.start)
                            ),
                            Expanded(
                              flex: 1,
                              child: nameAry(mainText: toKRWText(txt:"${snapshot.data!.data![index].last}"),
                                  subText: dallorText(txt: "${snapshot.data!.data![index].last}"),
                                  align: MainAxisAlignment.end)
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    percentText(txt:"${snapshot.data!.data![index].priceChangePercent}")
                                  ],
                                )
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
// Text percentText({required String txt}) {
//   //문자열인 text를 숫자로 바꾸기 위해 dynamic 으로 선언
//   var t = double.parse(txt); // double로 바꾸기.
//   //color를 증감에 따른 설정
//   var colorNum = (t == 0)? Colors.black : (t>0) ? Colors.red : Colors.blue;
//   String tt = t.toStringAsFixed(3); //소수 3자리 반올림 txt
//   var text = double.parse(tt);
//   return Text("$text%", style: TextStyle(fontSize: 14, color:colorNum),
//       textAlign: TextAlign.right);
// }

ElevatedButton percentText({required String txt}) {
  //문자열인 text를 숫자로 바꾸기 위해 dynamic 으로 선언
  var t = double.parse(txt); // double로 바꾸기.
  //color를 증감에 따른 설정
  var colorNum = (t == 0)? Colors.black : (t>0) ? const Color(0xff4DA0B1) : Colors.red ;
  String tt = t.toStringAsFixed(4); //소수 4자리 반올림 txt
  var text = (tt[0]!='-')? '+$tt' : tt; // 만약에 음수가 아니라면 +부호 붙여주기.
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(	//모서리를 둥글게
      borderRadius: BorderRadius.circular(4)),
      backgroundColor: colorNum
      ),
    onPressed: () {  },
    child:Text(
      "$text%",
      style: const TextStyle(fontSize: 14, color:Colors.white)
    )
  );
}

Text volumeText({required dynamic txt}){
  txt = double.parse(txt);
  txt = (txt/1000).ceil();
  txt = (txt>1000)? "${(txt/1000).toStringAsFixed(2)}K" : "${txt}M";
  return Text("Vol $txt", style: const TextStyle(fontSize: 12, color:Colors.grey),
      textAlign: TextAlign.left);
}


Text coinNameText({required String txt}) {
  //문자열인 text를 숫자로 바꾸기 위해 dynamic 으로 선언
  txt = txt.replaceAll("USDT_UMCBL", "");
  return Text(txt, style: const TextStyle(fontSize: 15, color:Colors.black),
      textAlign: TextAlign.left);
}

Text toKRWText({required dynamic txt}) {
  //문자열인 text를 숫자로 바꾸기 위해 dynamic 으로 선언
  var dallor = 1322.76;
  var f = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
  txt = (double.parse(txt) * dallor).ceil();
  return Text(f.format(txt), style: const TextStyle(fontSize: 15, color:Colors.black),
      textAlign: TextAlign.right);
}

Text dallorText({required dynamic txt}){
  txt = double.parse(txt);
  txt = txt.toStringAsFixed(2);
  return Text("\$$txt", style: const TextStyle(fontSize: 12, color:Colors.grey),
      textAlign: TextAlign.right);
}



//2개읠 열로 나누기 위한 array 중복 코드를 위해 작성.
Column nameAry({required dynamic mainText, required dynamic subText, required dynamic align}){
  return Column(
    children: [
      Row(
        mainAxisAlignment: align,
        children: [
          mainText
        ],
      ),
      Row(
        mainAxisAlignment: align,
        children: [
          subText
        ],
      )
    ],
  );
}

// Text dateText(){
//   //현재 시간 생성
//   DateTime dt = DateTime.now();
//   var t = DateFormat('갱신시간 : MM월 dd일 HH시 mm분 ss초').format(dt);
//   return Text(t, style: const TextStyle(fontSize: 14, color:Colors.black),
//       textAlign: TextAlign.right);
// }

Widget gradientText() {
  //그라이데이션을 위한 메서드
  final Shader linearGradientShader = const LinearGradient(colors: [Colors.red, Colors.orange,Colors.blue]).createShader(const Rect.fromLTWH(0.0, 20.0, 150.0, 20.0));
  return Text('Bitget 비트겟', style: TextStyle(foreground: Paint()..shader = linearGradientShader, fontSize: 40));
}


// 토스트 메서드
// void flutterToast(){
//   Fluttertoast.showToast(
//       msg: "msg",
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.red,
//       fontSize: 20,
//       textColor: Colors.white,
//       toastLength: Toast.LENGTH_LONG,
//   );
// }

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
