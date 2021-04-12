import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homescreen/Constants.dart';
import 'package:homescreen/plugins_utils/Location.dart';
import 'package:http/http.dart' as http;
import 'package:homescreen/AddEditPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Butonlar.dart';
import 'main.dart';
import 'widgets/potbelly_button.dart';

class Depremapi extends StatefulWidget {
  @override
  _DepremapiState createState() => _DepremapiState();
}

class _DepremapiState extends State<Depremapi> {
  LocationService loca2 = new LocationService();

  Future<void> DepremCek() async {
    final SharedPreferences sharedPreferences =
    await SharedPreferences.getInstance();

    final LOCA = (await loca2.location.getLocation()).toString();
    sharedPreferences.setString('Location2', LOCA);

    dynamic intValue = int.parse(LOCA.replaceAll(RegExp('[^0-9]'), ''));
    String konum = intValue.toString();

    var enlem=konum.substring(0,2);
     var boylam =konum.substring(9,11);

    int enlemEksi3 =int.parse(enlem)-2;
    int enlemArti3 =int.parse(enlem)+2;

    int longtitudeEksi3 =int.parse(boylam)-2;
    int longtitudeArti3 =int.parse(boylam)+2;
    var enlemliboylamli ="https://turkiyedepremapi.herokuapp.com/api?minenlem=$enlemEksi3&maxenlem=$enlemArti3&minboylam=$longtitudeEksi3&maxboylam=$longtitudeArti3&min=2";
    var url = 'https://turkiyedepremapi.herokuapp.com/api?min=2.0';


    var response = await http.get(
      Uri.parse(enlemliboylamli),
    );

    List text = jsonDecode(response.body);
    print(text);

    if(text.length!=0){
print(enlem);
      print(boylam);
      print(konum);
      print(longtitudeEksi3);
      print(longtitudeArti3);
      print("sa");
      myToast('DEPREM MEYDANA GELDİ');
    }
    return json.decode(response.body);
    /*List text = jsonDecode(response.body);
    text.forEach((element) {
      List<dynamic> as = [];
      as.add(text[0]);

      var liststr = as.toString();

      var s = as.toString();





      var a = element.toString();
      //dynamic intValue = int.parse(a.replaceAll(RegExp('[^0-9]'), ''));


      print(liststr);
    }
        //print(element.toString());

        );*/
  }

  Future getData() async {
    var url = 'https://turkiyedepremapi.herokuapp.com/api';
    var response = await http.get(url);
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('SON DEPREMLER'),
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset('assets/images/2.0x/closebutton.png'),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => MyStatefulWidget()));
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder(
          future: DepremCek(),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);
            return snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      List list = snapshot.data;
                      void vericek() async {
                        final SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        sharedPreferences.setString(
                            'buyukluk', list[index]['buyukluk']);
                        var buyukluk = sharedPreferences.getString('buyukluk');

                        sharedPreferences.setString(
                            'tarih', list[index]['tarih']);
                        var tarih = sharedPreferences.getString('tarih');

                        sharedPreferences.setString('yer', list[index]['yer']);
                        var yer = sharedPreferences.getString('yer');

                        sharedPreferences.setString(
                            'sehir', list[index]['sehir']);
                        var sehir = sharedPreferences.getString('sehir');

                        sharedPreferences.setString(
                            'saat', list[index]['saat']);
                        var saat = sharedPreferences.getString('saat');

                        String bilgimesaji =
                            ('$saat saatinde $yer yerinde $buyukluk büyüklüğünde bir deprem meydana gelmiştir');

                     myToast(bilgimesaji);
                      print(bilgimesaji);

                      }

                      return Center(
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 50,
                          ),
                          margin:
                              EdgeInsets.only(left: 10.0, right: 10.0, top: 20),
                          child: ListTile(
                            leading: GestureDetector(
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/icon.png',
                                  color: Colors.black,
                                ),
                              ),
                              onTap: () {
                                debugPrint('Düzenleme etkin');
                              },
                            ),
                            title: Text(
                                '${list[index]['yer']} ${list[index]['sehir']}'),
                            subtitle: Text(
                                '${list[index]['tarih']}  ${list[index]['saat']}'),
                            trailing: GestureDetector(
                              child: Text(
                                "${list[index]['buyukluk']}",
                                style: TextStyle(fontSize: 20),
                              ),
                              onTap: () {
                                DepremCek();
                                vericek();

                              },
                            ),
                            isThreeLine: true,
                          ),
                        ),
                      );
                    })
                : Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}