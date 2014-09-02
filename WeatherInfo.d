/++
#Product
 WeatherInfo / SDL 2.0 UI tool kit example

#Version
 Alpha test version.

#About
 livedoorが提供する日本の天気予報を取得し表示を行います。
 This program displays a Japanese weather forecast. providing is livedoor. 
 http://weather.livedoor.com/weather_hacks/

#License
 Copyright (c) 2014- Seiji Fujita
 Distributed under the Boost Software License, Version 1.0.

++/

import std.string;

import sdl2tk;
import weather_hacks;
import debuglog;


//@----------------------------------------------------------------------------
enum Window_WIDTH  = 800;
enum Window_HEIGHT = 600; // 480;
enum Window_TITLE = "天気予報";

// window とwindow の間の隙間
enum PainXtop      = 10;
enum PainYtop      = 10;
enum PainHeight    = Window_HEIGHT - PainYtop *2;
enum LeftPainWidth = 200;
enum RightPainWidth= Window_WIDTH - LeftPainWidth - PainXtop *3;
enum RightPainXpos  = LeftPainWidth + PainXtop*2;

wcWindow[] makeWin()
{
	wcWindow[] Result;
	auto tdata = new WeatherHack(TokyoCode);
//	auto tdata = new WeatherHack(HakodateCode);
//	auto tdata = new WeatherHack(NahaCode);
	
	auto rightPain = 
		new wcWindow(tdata.description_publicTime, RightPainWidth, PainHeight, RightPainXpos, PainYtop);
	rightPain.client_addText(splitLines(tdata.description_text));
	Result ~= rightPain;
	
	auto leftPain = new wcWindow(tdata.title, LeftPainWidth, PainHeight - 40, PainXtop, PainYtop);
	Result ~= leftPain;
	
	outLog("tdata.fcs.length =", tdata.fcs.length);
	foreach (i, v ; tdata.fcs) {
		if (i >= 1)
			leftPain.client_addYPos(50);
		leftPain.client_addText(v.dateLabel ~ "(" ~ v.date ~ ")");
		leftPain.client_addImage(forcastImageGif[i]);
		leftPain.client_addText(v.image_title);
		leftPain.client_addText("(" ~ v.temperature_max_celsius ~ "℃/" ~ v.temperature_min_celsius ~ "℃)");
	}
	return Result;
}

class uiMgr
{
private:
	bool loopQuit = true;
	
	void onClick() {
		loopQuit = false;
	}
	void Settings() {
		MsgBox("*under construction*", "I thinking about the UI...");
		// UI を考え中... I thinking about the UI 
	}
	
	void startMessage()
	{
		auto msg = new wcWindow("Start", 400, 100, 200, 200);
		msg.client_addText("データ受信中.../Receiving the weather data...");
		clear();
		msg.draw();
		update();
		cw_Delay(500);
	}
public:
	this()
	{
		initProcess(Window_TITLE, Window_WIDTH, Window_HEIGHT);
	}
	void mainLoop()
	{
		startMessage();
		wcWindow[] win = makeWin();
		wcButton btnSetting = new wcButton(110, Window_HEIGHT -45, "設定", "settingIcon.png");
		btnSetting.onClick = &Settings;
		wcButton btnQuit = new wcButton(10, Window_HEIGHT -45, "終了");
		btnQuit.onClick = &onClick;
		
		while(loopQuit)
		{
			clear();
			foreach (v ; win) {
				v.draw();
			}
			btnSetting.draw();
			btnQuit.draw();
			update();
			if (wait(16)) { // about 60fps
				break;
			}
		}
	}
}

int main()
{
	try {
		setDebugLog();
		auto ui = new uiMgr;
		ui.mainLoop();
	}
	//	throw new Exception("");
	catch(Exception e) {
		outLog(e.toString());
	}
	finally	{
		finalProcess();
	}
	return 0;
}
/++
UI 作るのが面倒ｗ

北海道地方
東北地方
関東地方 
信越・北陸地方 
東海地方
近畿地方
中国地方
四国地方 
九州地方
沖縄地方 


都道府県リスト

北海道地方
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

東北地方
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

関東地方 
茨城県
080010：水戸
080020：土浦

栃木県
090010：宇都宮
090020：大田原

群馬県
100010：前橋
100020：みなかみ

埼玉県
110010：さいたま
110020：熊谷
110030：秩父

千葉県
120010：千葉
120020：銚子
120030：館山

東京都
130010：東京
130020：大島
130030：八丈島
130040：父島

神奈川県
140010：横浜
140020：小田原

山梨県
190010：甲府
190020：河口湖

信越・北陸地方 
新潟県
150010：新潟
150020：長岡
150030：高田
150040：相川

富山県
160010：富山
160020：伏木

石川県
170010：金沢
170020：輪島

福井県
180010：福井
180020：敦賀


長野県
200010：長野
200020：松本
200030：飯田

東海地方
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

近畿地方
愛知県
230010：名古屋
230020：豊橋

滋賀県
250010：大津
250020：彦根

京都府
260010：京都
260020：舞鶴

大阪府
270000：大阪

兵庫県
280010：神戸
280020：豊岡

奈良県
290010：奈良
290020：風屋

和歌山県
300010：和歌山
300020：潮岬


中国地方
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

愛媛県
380010：松山
380020：新居浜
380030：宇和島

四国地方 
徳島県
360010：徳島
360020：日和佐

香川県
370000：高松

高知県
390010：高知
390020：室戸岬
390030：清水


九州地方
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

沖縄地方 
沖縄県
471010：那覇
471020：名護
471030：久米島
472000：南大東
473000：宮古島
474010：石垣島
474020：与那国島
++/

