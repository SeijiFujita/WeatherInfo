/++++
お天気Hack、してみませんか？
http://weather.livedoor.com/weather_hacks/

#License
 Copyright (c) 2014- Seiji Fujita
 Distributed under the Boost Software License, Version 1.0.
+++++/
module weather_hacks;

import std.net.curl;
import std.json;
import std.file;
import std.exception;
import std.stdio;
import debuglog;

enum weatherHacks_URL = r"http://weather.livedoor.com/forecast/webservice/json/v1?city=";

enum TokyoCode    = "130010"; // 東京
enum HakodateCode = "017010"; // 函館
enum NahaCode     = "471010"; //：那覇

string[] forcastImageGif = [
	"res/temp/todayImage.gif",
	"res/temp/tomorrowImage.gif",
	"res/temp/afterTomorrowImage.gif"
	];

class WeatherHack
{
	this(string areaCode)
	{
		getData(areaCode);
	}
	void getData(string areaCode)
	{
		string weatherURL = weatherHacks_URL ~ areaCode;
		JSONValue root = parseJSON(get(weatherURL));
		enforce(root.type == JSON_TYPE.OBJECT);
		
		// "forecasts"
		enforce(root.object["forecasts"].type == JSON_TYPE.ARRAY);
		foreach (elem; root.object["forecasts"].array) {
			auto f = new Forecasts;
			with (f) {
				date = elem.object["date"].str;
				dateLabel = elem.object["dateLabel"].str;
				telop = elem.object["telop"].str;
				image_title  = elem.object["image"].object["title"].str;
				image_url    = elem.object["image"].object["url"].str;
				image_width  = elem.object["image"].object["width"].integer;
				image_height = elem.object["image"].object["height"].integer;
				
				if (elem.object["temperature"].object["min"].type == JSON_TYPE.NULL) {
					temperature_min_celsius = "-";
					temperature_min_fahrenheit = "-";
				} else {
					temperature_min_celsius = elem.object["temperature"].object["min"].object["celsius"].str;
					temperature_min_fahrenheit = elem.object["temperature"].object["min"].object["fahrenheit"].str;
				}
				if (elem.object["temperature"].object["max"].type == JSON_TYPE.NULL) {
					temperature_max_celsius = "-";
					temperature_max_fahrenheit = "-";
				} else {
					temperature_max_celsius = elem.object["temperature"].object["max"].object["celsius"].str;
					temperature_max_fahrenheit = elem.object["temperature"].object["max"].object["fahrenheit"].str;
				}
			}
			fcs ~= f;
		}
		// download image
		foreach (i, v ; fcs) {
			download(v.image_url, forcastImageGif[i]);
		}
		outLog("forecasts ;----------------------------------------------");
		foreach (i, v ; fcs) {
			outLog(i, " date: ",      v.date);
			outLog(i, " dateLabel: ", v.dateLabel);
			outLog(i, " telop: ",     v.telop);
			outLog(i, " image_title: ",  v.image_title);
			outLog(i, " image_url: ",    v.image_url);
			outLog(i, " image_width: ",  v.image_width);
			outLog(i, " image_height: ", v.image_height);
			outLog(i, " temperature_min_celsius: ",    v.temperature_min_celsius);
			outLog(i, " temperature_min_fahrenheit: ", v.temperature_min_fahrenheit);
			outLog(i, " temperature_max_celsius: ",    v.temperature_max_celsius);
			outLog(i, " temperature_max_fahrenheit: ", v.temperature_max_fahrenheit);
		}
		
		// "location":
		location_city = root.object["location"].object["city"].str;
		location_area = root.object["location"].object["area"].str;
		location_prefecture = root.object["location"].object["prefecture"].str;
		//"publicTime"
		publicTime = root.object["publicTime"].str;
		//	"title":,
		title = root.object["title"].str;
		//	"description_text"
		description_text = root.object["description"].object["text"].str;
		//	"description_publicTime"
		description_publicTime = root.object["description"].object["publicTime"].str;
		
		outLog("location ;----------------------------------------------");
		outLog("city: ", location_city);
		outLog("area: ", location_area);
		outLog("prefecture: ", location_prefecture);
		//"publicTime"
		outLog("publicTime: ", publicTime);
		//	"title":,
		outLog("title: ", title);
		//	"description"
		outLog("description_text: ", description_text);
		//	"publicTime"
		outLog("description_publicTime: ", description_publicTime);
/++
		// "pinpointLocations":
		enforce(root.object["pinpointLocations"].type == JSON_TYPE.ARRAY);
		foreach (elem; root.object["pinpointLocations"].array) {
			pploc ~= new pinpointLocation(elem.object["name"].str, elem.object["link"].str);
		}
		outLog("pinpointLocations ;----------------------------------------------");
		foreach (i, v ; pploc) {
			outLog(i, " ", v.name, " ", v.link);
		} 
++/		
	}
// Data
	// location_city: 東京
	private string _location_city;
		@property void location_city(string l) { _location_city = l; }
		@property string location_city() { return _location_city; }
	
	// location_area: 関東
	private string _location_area;
		@property void location_area(string l) { _location_area = l; }
		@property string location_area() { return _location_area; }
	
	// location_prefecture: 東京都
	private string _location_prefecture;
		@property void location_prefecture(string l) { _location_prefecture = l; }
		@property string location_prefecture() { return _location_prefecture; }
	
	// publicTime: 2014-08-05T17:00:00+0900
	private string _publicTime;
		@property void publicTime(string p) { _publicTime = p; }
		@property string publicTime() { return _publicTime; }
		
	// title: 東京都 東京 の天気
	private string _title;
		@property void title(string t) { _title = t; }
		@property string title() { return _title; }
		
	// description_text:  日本の東には高気圧があって...
	private string _description_text;
		@property void description_text(string d) { _description_text = d; }
		@property string description_text() { return _description_text; }
		
	// description_publicTime: 2014-08-05T16:45:00+0900
	private string _description_publicTime;
		@property void description_publicTime(string d) { _description_publicTime = d; }
		@property string description_publicTime() { return _description_publicTime; }
	
	class Forecasts
	{
		// date: 2014-08-05
		private string _date;
			@property void date(string d) { _date = d; }
			@property string date() { return _date; }
		
		// dateLabel: 今日
		private string _dateLabel;
			@property void dateLabel(string d) { _dateLabel = d; }
			@property string dateLabel() { return _dateLabel; }
		
		// telop: 晴れ
		private string _telop;
			@property void telop(string t) { _telop = t; }
			@property string telop() { return _telop; }
		
		// temperature_max_celsius: N/A,35, 摂氏　℃」
		private string _temperature_max_celsius;
			@property void  temperature_max_celsius(string t) { _temperature_max_celsius = t; }
			@property string temperature_max_celsius() { return _temperature_max_celsius; }
		
		// temperature_max_fahrenheit: N/A,95.0, 華氏　°F
		private string _temperature_max_fahrenheit;
			@property void temperature_max_fahrenheit(string t) { _temperature_max_fahrenheit = t; }
			@property string temperature_max_fahrenheit() { return _temperature_max_fahrenheit; }
		
		// temperature_min_celsius: N/A,28,
		private string _temperature_min_celsius;
			@property void temperature_min_celsius(string t) { _temperature_min_celsius = t; }
			@property string temperature_min_celsius() { return _temperature_min_celsius; }
		
		// temperature_min_fahrenheit: N/A,82.4,
		private string _temperature_min_fahrenheit;
			@property void temperature_min_fahrenheit(string t) { _temperature_min_fahrenheit = t; }
			@property string temperature_min_fahrenheit() { return _temperature_min_fahrenheit; }
		
		// image_title: 晴時々曇
		private string _image_title;
			@property void image_title(string t) { _image_title = t; }
			@property string image_title() { return _image_title; }
		
		// image_url: http://weather.livedoor.com/img/icon/2.gif
		private string _image_url;
			@property void image_url(string i) { _image_url = i; }
			@property string image_url() { return _image_url; }
		
		// image_width: 50
		private long _image_width;
			@property void image_width(long i) { _image_width = i; }
			@property long image_width() { return _image_width; }
			
		//image_height: 31
		private long _image_height;
			@property void image_height(long i) { _image_height = i; }
			@property long image_height() { return _image_height; }
	}
	Forecasts[] fcs;
/++	
	class pinpointLocation
	{
		private:
			string _name;
			string _link;
		public:
		this(string n, string l) {
			_name = n;
			_link = l;
		}
		@property string name() { return _name; }
		@property string link() { return _link; }
	}
	pinpointLocation[]	pploc;
++/

} //class WeatherHack

/++
void getWeatherHack()
{
	enum TokyoURL = r"http://weather.livedoor.com/forecast/webservice/json/v1?city=130010";
	
	JSONValue root = parseJSON(get(TokyoURL));
	enforce(root.type == JSON_TYPE.OBJECT);
	std.stdio.writeln(root);
}


北海道
011000：稚内
012010：旭川
012020：留萌
016010：札幌
016020：岩見沢
016030：倶知安
013010：網走
013020：北見
013030：紋別
014010：根室
014020：釧路
014030：帯広
015010：室蘭
015020：浦河
017010：函館
017020：江差

青森県
020010：青森
020020：むつ
020030：八戸

岩手県
030010：盛岡
030020：宮古
030030：大船渡

宮城県
040010：仙台
040020：白石

秋田県
050010：秋田
050020：横手

山形県
060010：山形
060020：米沢
060030：酒田
060040：新庄

福島県
070010：福島
070020：小名浜
070030：若松

東京都
130010：東京
130020：大島
130030：八丈島
130040：父島

神奈川県
140010：横浜
140020：小田原

埼玉県
110010：さいたま
110020：熊谷
110030：秩父

千葉県
120010：千葉
120020：銚子
120030：館山

茨城県
080010：水戸
080020：土浦

栃木県
090010：宇都宮
090020：大田原

群馬県
100010：前橋
100020：みなかみ

山梨県
190010：甲府
190020：河口湖

新潟県
150010：新潟
150020：長岡
150030：高田
150040：相川

長野県
200010：長野
200020：松本
200030：飯田

富山県
160010：富山
160020：伏木

石川県
170010：金沢
170020：輪島

福井県
180010：福井
180020：敦賀

愛知県
230010：名古屋
230020：豊橋

岐阜県
210010：岐阜
210020：高山

静岡県
220010：静岡
220020：網代
220030：三島
220040：浜松

三重県
240010：津
240020：尾鷲

大阪府
270000：大阪

兵庫県
280010：神戸
280020：豊岡

京都府
260010：京都
260020：舞鶴

滋賀県
250010：大津
250020：彦根

奈良県
290010：奈良
290020：風屋

和歌山県
300010：和歌山
300020：潮岬

鳥取県
310010：鳥取
310020：米子

島根県
320010：松江
320020：浜田
320030：西郷

岡山県
330010：岡山
330020：津山

広島県
340010：広島
340020：庄原

山口県
350010：下関
350020：山口
350030：柳井
350040：萩

徳島県
360010：徳島
360020：日和佐

香川県
370000：高松

愛媛県
380010：松山
380020：新居浜
380030：宇和島

高知県
390010：高知
390020：室戸岬
390030：清水

福岡県
400010：福岡
400020：八幡
400030：飯塚
400040：久留米

大分県
440010：大分
440020：中津
440030：日田
440040：佐伯

長崎県
420010：長崎
420020：佐世保
420030：厳原
420040：福江

佐賀県
410010：佐賀
410020：伊万里

熊本県
430010：熊本
430020：阿蘇乙姫
430030：牛深
430040：人吉

宮崎県
450010：宮崎
450020：延岡
450030：都城
450040：高千穂

鹿児島県
460010：鹿児島
460020：鹿屋
460030：種子島
460040：名瀬

沖縄県
471010：那覇
471020：名護
471030：久米島
472000：南大東
473000：宮古島
474010：石垣島
474020：与那国島
++/

