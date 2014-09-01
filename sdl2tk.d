/++
 SDL 2.0 GUI Tool-Kit, test version 
 
 sdl2tk.d とは
 ---------------
 dhell2(http://www5.atwiki.jp/yaruhara/pages/80.html)
 というSDL 1.x のゲームライブラリを土台として
 SDL 2.x でも、とりあえず動くようにしたライブラリです。
 また、その他もろもろのコードの詰め合わせでです。
 
 この以下のコードは十分な動作検証を行っていませんので
 ご使用にあたっては動作検証を行い使用してください。
 
 このコードに起因する意図しないバグまたは動作など
 すべてにおいてまったく無保証です。
 
 ライセンスに関しては以下を選択することができます。

 sdl2tk.d SOFTWARE LICENCE
 Copyright (c) 2014- Seiji Fujita

 1.やわらかライセンセス
 http://www5.atwiki.jp/yaruhara/pages/56.html
 2.Boost Software License - Version 1.0
 http://www.boost.org/LICENSE_1_0.txt


 SDL 2.0 Home
 https://www.libsdl.org/download-2.0.php
 SDL 2.0 wiki
 https://wiki.libsdl.org/FrontPage
 SDL 2.0 japanese doc
 http://sdl2referencejp.sourceforge.jp/
 http://sdl2referencejp.sourceforge.jp/CategoryAPI.html
 
++/
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;

import std.string;
import debuglog;

//@----------------------------------------------------------------------------
static SDL_Window*   g_window;
static SDL_Renderer* g_renderer;

//@----------------------------------------------------------------------------
static int fps_cnt;
static int fps_view;
static int fps_lastTick;

void drawFPS()
{
	string title;
	title = "FPS: " ~ format("%s", fps_view);
	SDL_SetWindowTitle(g_window, toStringz(title));
}

//@----------------------------------------------------------------------------
static bool g_quit = true;
// wait
bool wait(uint ms)
{
	int nowTick;
	int leftTick;
	int prvTick;
	
	prvTick = SDL_GetTicks();
	while (true) {
	 	nowTick = SDL_GetTicks();
 		leftTick = prvTick + ms - nowTick;
 		if (leftTick < 1 || leftTick > 9999)
 			break;
 	 	SDL_Delay(1);
	}
	// fps watch
	fps_cnt++;
	if (fps_lastTick / 1000 != nowTick / 1000) {
		fps_view = fps_cnt;
		fps_cnt = 0;
		fps_lastTick = nowTick;
	}
	// mouse update
	int mouse_pos_x = -1, mouse_pos_y = -1;
	g_pressMouseButtonPrev = g_pressMouseButton;
	g_pressMouseButton = SDL_GetMouseState(&mouse_pos_x, &mouse_pos_y);
	
	// keybord update
	// g_pressKeyButtonPrev = g_pressKeyButton; 
	foreach (i, key; g_pressKeyButton) {
		g_pressKeyButtonPrev[i] = key;
	}
	int state_keys = -1;
	Uint8* keys = SDL_GetKeyboardState(&state_keys);
	for (uint i = 0; i < SDLK_LAST; i++) {
		g_pressKeyButton[i] = (keys[i] == SDL_PRESSED);
	}
	// Event update
	SDL_Event e;
	while (SDL_PollEvent(&e)) {
		g_quit = (e.type == SDL_QUIT);
	}
	if (isPressKey(SDL_SCANCODE_ESCAPE/* SDLK_ESCAPE */ )) {
		g_quit = true;
		// 
		throw new Exception("quit.[ESC-Key or SDL_QUIT]");
	}
	return g_quit;
}

//@----------------------------------------------------------------------------
/**
 * Texture class 
 * テスクチャクラス
 * 読み込み可能な画像形式はBMP, JPG, PNG など
 * IMG_Load(toStringz(filename)) が読み込める画像フォーマット
 */
class Texture
{
private:
	SDL_PixelFormat _format;
	int _width;					// * 高さ
	int _height;				// * 幅
	int[] _maskInfo;			// * マスク情報
	string _path;				// * パス
	SDL_Surface* _surface;
	SDL_Texture* _texture;

	SDL_PixelFormat getPixelFormat()
	{
		_format.palette       = null;
		_format.BitsPerPixel  = 32;
		_format.BytesPerPixel = 4;
		_format.Rmask         = 0x000000ff;
		_format.Gmask         = 0x0000ff00;
		_format.Bmask         = 0x00ff0000;
		_format.Amask         = 0xff000000;
		_format.Rshift        = 0;
		_format.Gshift        = 8;
		_format.Bshift        = 16;
		_format.Ashift        = 24;
		_format.Rloss         = 0;
		_format.Gloss         = 0;
		_format.Bloss         = 0;
		_format.Aloss         = 0;
		return _format;
	}
	
	// bitmap読み込み.bmp, .jpg, .png
	SDL_Surface* loadImage(string filename)
	{
		// ファイルパス
		_path = filename;
		// サーフェース生成
		SDL_Surface *s = IMG_Load(toStringz(filename));
		if (!s) {
			throw new Exception("Texture:SDL_IMGLoad : not found file: " ~ filename);
		}
		SDL_PixelFormat format = getPixelFormat();
		SDL_Surface *ret = SDL_ConvertSurface(s, &format, SDL_SWSURFACE);
		SDL_FreeSurface(s);
		return ret;
 	}
	// SDL_Surface ttfImage 読み込み
	SDL_Surface* loadImage(SDL_Surface* ttfImage)
	{
		if (ttfImage is null) {
			throw new Exception("Texture:loadImage:SDL_Surface");
		}
		// サーフェース生成
		SDL_PixelFormat format = getPixelFormat();
		SDL_Surface *ret = SDL_ConvertSurface(ttfImage, &format, SDL_SWSURFACE);
		SDL_FreeSurface(ttfImage);
		return ret;
 	}
	
public:
	this() {}
	/**
	 * コンストラクタ（抜き色なし）
	 * @param filename  ファイルパス
	 * @param maskColor 抜き色
	 */
	this(string filename)
	{
		_maskInfo = [-1, 0, 0];
		SDL_Surface* s = loadImage(filename);
		textureCreate(s);
	}
	this(SDL_Surface* ttfImage)
	{
		_maskInfo = [-1, 0, 0];
		SDL_Surface* s = loadImage(ttfImage);
		textureCreate(s);
	}
	/**
	 * コンストラクタ(抜き色指定)
	 * @param filename  ファイルパス
	 * @param maskColor 抜き色
	 */
	this(string filename, int r, int g, int b)
	{
		_maskInfo = [r, g, b];
		// outLog("R=", r, ", G=", g, ", B=", b);
		SDL_Surface* s = loadImage(filename);
		SDL_SetColorKey(s, SDL_TRUE, SDL_MapRGB(s.format, cast(ubyte)r, cast(ubyte)g, cast(ubyte)b));
		textureCreate(s);
	}
	this(SDL_Surface* ttfImage, int r, int g, int b)
	{
		_maskInfo = [r, g, b];
		SDL_Surface* s = loadImage(ttfImage);
//		Uint32 maskColor = (r << 16) | (g << 8) | (b);
//		s = setColorKey(s, maskColor); // 抜き色設定
		SDL_SetColorKey(s, SDL_TRUE, SDL_MapRGB(s.format, cast(ubyte)r, cast(ubyte)g, cast(ubyte)b));
		textureCreate(s);
	}
	/**
	 * コンストラクタ（指定座標の色を抜き色に）
	 * @param filename  ファイルパス
	 * @param maskColor 抜き色
	 */
	this(string filename, int x, int y)
	{
		_maskInfo = [-2, x, y];
		SDL_Surface* s = loadImage(filename);
		if ((0 <= x && x < s.w) && (0 <= y && y < s.h))
		{
			// 座標が画像の範囲内
//			SDL_LockSurface(s);	
			Uint32* surfacepixels = cast(Uint32*) s.pixels;
			Uint32 maskColor = surfacepixels[y * s.pitch / 4 + x];
//			SDL_UnlockSurface(s);
			Uint8 r = maskColor & 0xff;
			Uint8 g = (maskColor >>  8) & 0xff;
			Uint8 b = (maskColor >> 16) & 0xff;
			SDL_SetColorKey(s, SDL_TRUE, SDL_MapRGB(s.format, r, g, b));
			// outLog("R=", r, ", G=", g, ", B=", b);
		}
		textureCreate(s);
	}
	this(SDL_Surface* ttfImage, int x, int y)
	{
		_maskInfo = [-2, x, y];
		SDL_Surface* s = loadImage(ttfImage);
		if ((0 <= x && x < s.w) && (0 <= y && y < s.h))
		{
			// 座標が画像の範囲内
//			SDL_LockSurface(s);	
			Uint32* surfacepixels = cast(Uint32*) s.pixels;
			Uint32 maskColor = surfacepixels[y * s.pitch / 4  + x];
//			SDL_UnlockSurface(s);
			Uint8 r = maskColor & 0xff;
			Uint8 g = (maskColor >>  8) & 0xff;
			Uint8 b = (maskColor >> 16) & 0xff;
			SDL_SetColorKey(s, SDL_TRUE, SDL_MapRGB(s.format, r, g, b));
			// outLog("R=", r, ", G=", g, ", B=", b);
		}
		textureCreate(s);
	}
	//
	string getPath()     { return _path;     }
	int[] getMaskInfo()  { return _maskInfo; }
	
	/**
	 * Texture 生成
	 */
	void textureCreate(SDL_Surface* s)
	{
		_texture = SDL_CreateTextureFromSurface(g_renderer, s);
		if (_texture is null) {
			throw new Exception("SDL_CreateTextureFromSurface");
		}
		_width   = s.w;
		_height  = s.h;
		_surface = s;
	}
	/**
	 * 抜き色設定
	 */
/++
	SDL_Surface* setColorKey(SDL_Surface* s, Uint32 maskColor)
	{
		maskColor |= 0xff000000u;
		Uint32* surfacepixels = cast(Uint32*) s.pixels;
		SDL_LockSurface(s);
		for (int y = 0; y < s.h; y++)
		{
			for (int x = 0; x < s.w; x++)
			{
				Uint32* p = &(surfacepixels[y * s.pitch / 4  + x]);
				if (*p == maskColor)
					*p = 0x00000000u;
			}
		}
		SDL_UnlockSurface(s);
		return s;
	}
++/	
	/**
	 * デストラクタ
	 */
	~this() {
		if (_surface !is null)
			SDL_FreeSurface(_surface);
	}
}
/++
	SDL_BLENDMODE_NONE	// ブレンドしないdstRGBA = srcRGBA
	SDL_BLENDMODE_BLEND // αブレンドdstRGB = (srcRGB * srcA) + (dstRGB * (1 - srcA)), dstA = srcA + (dstA * (1 - srcA))
	SDL_BLENDMODE_ADD	// 加算ブレンド	dstRGB = (srcRGB * srcA) + dstRGB, dstA = dstA
	SDL_BLENDMODE_MOD	// 積算ブレンド	dstRGB = srcRGB * dstRGB, dstA = dstA
	http://sdl2referencejp.sourceforge.jp/SDL_BlendMode.html
	int SDL_SetTextureBlendMode(SDL_Texture* texture, SDL_BlendMode blendMode)
	
	SDL_SetTextureBlendMode(Texture, SDL_BLENDMODE_NONE);
	SDL_SetTextureBlendMode(Texture, SDL_BLENDMODE_BLEND);
	
	http://sdl2referencejp.sourceforge.jp/SDL_SetTextureColorMod.html
	int SDL_SetTextureColorMod(SDL_Texture* texture, Uint8 r, Uint8 g, Uint8 b)
	
	http://sdl2referencejp.sourceforge.jp/SDL_SetTextureAlphaMod.html
	int SDL_SetTextureAlphaMod(SDL_Texture* texture, Uint8 alpha)

http://sdl2referencejp.sourceforge.jp/SDL_SetColorKey.html
int SDL_SetColorKey(SDL_Surface* surface, int flag, Uint32 key)

int SDL_SetSurfaceRLE(SDL_Surface* surface, int flag)

//
http://stackoverflow.com/questions/6852055/how-can-i-modify-pixels-using-sdl
void PutPixel32_nolock(SDL_Surface * surface, int x, int y, Uint32 color)
{
    Uint8 * pixel = (Uint8*)surface->pixels;
    pixel += (y * surface->pitch) + (x * sizeof(Uint32));
    *((Uint32*)pixel) = color;
}

void PutPixel24_nolock(SDL_Surface * surface, int x, int y, Uint32 color)
{
    Uint8 * pixel = (Uint8*)surface->pixels;
    pixel += (y * surface->pitch) + (x * sizeof(Uint8) * 3);
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
    pixel[0] = (color >> 24) & 0xFF;
    pixel[1] = (color >> 16) & 0xFF;
    pixel[2] = (color >> 8) & 0xFF;
#else
    pixel[0] = color & 0xFF;
    pixel[1] = (color >> 8) & 0xFF;
    pixel[2] = (color >> 16) & 0xFF;
#endif
}

void PutPixel16_nolock(SDL_Surface * surface, int x, int y, Uint32 color)
{
    Uint8 * pixel = (Uint8*)surface->pixels;
    pixel += (y * surface->pitch) + (x * sizeof(Uint16));
    *((Uint16*)pixel) = color & 0xFFFF;
}

void PutPixel8_nolock(SDL_Surface * surface, int x, int y, Uint32 color)
{
    Uint8 * pixel = (Uint8*)surface->pixels;
    pixel += (y * surface->pitch) + (x * sizeof(Uint8));
    *pixel = color & 0xFF;
}

void PutPixel32(SDL_Surface * surface, int x, int y, Uint32 color)
{
    if( SDL_MUSTLOCK(surface) )
        SDL_LockSurface(surface);
    PutPixel32_nolock(surface, x, y, color);
    if( SDL_MUSTLOCK(surface) )
        SDL_UnlockSurface(surface);
}

void PutPixel24(SDL_Surface * surface, int x, int y, Uint32 color)
{
    if( SDL_MUSTLOCK(surface) )
        SDL_LockSurface(surface);
    PutPixel24_nolock(surface, x, y, color);
    if( SDL_MUSTLOCK(surface) )
        SDL_LockSurface(surface);
}

void PutPixel16(SDL_Surface * surface, int x, int y, Uint32 color)
{
    if( SDL_MUSTLOCK(surface) )
        SDL_LockSurface(surface);
    PutPixel16_nolock(surface, x, y, color);
    if( SDL_MUSTLOCK(surface) )
        SDL_UnlockSurface(surface);
}

void PutPixel8(SDL_Surface * surface, int x, int y, Uint32 color)
{
    if( SDL_MUSTLOCK(surface) )
        SDL_LockSurface(surface);
    PutPixel8_nolock(surface, x, y, color);
    if( SDL_MUSTLOCK(surface) )
        SDL_UnlockSurface(surface);

++/


static Texture[string] g_poolTexture;

/**
 * 指定のキーのテクスチャが存在するかどうか
 */
bool hasTexture(string key)
{
	if (key in g_poolTexture) {
		return true;
	}
	return false;
}

/**
 * テクスチャ読み込み
 * @parma key      キー（drawTextureで使用する）
 * @param filepath ファイルパス
 * @param mask     抜き色（mask[0]に「-1」で抜き色なし。「-2」で座標指定）
 */
void loadTexture(string key, string filepath, int[3] mask=[-1, 0, 0])
{
	// 同じキーがある場合、そのテクスチャを破棄
	if (hasTexture(key)) {
		disposeTexture(key);
	}
	if (mask[0] >= 0) {
		// 抜き色指定
		g_poolTexture[key] = new Texture(filepath, mask[0], mask[1], mask[2]);
	}
	else if (mask[0] == -1) {
		// 抜き色なし
		g_poolTexture[key] = new Texture(filepath);
	}
	else if (mask[0] == -2) {
		// 座標指定
		g_poolTexture[key] = new Texture(filepath, mask[1], mask[2]);
	}
	else {
		throw new Exception("loadTexture: Invalid parameter 'mask'");
	}
}

void loadTexture(string key, SDL_Surface* ttfImage, int[3] mask=[-1, 0, 0])
{
	// 同じキーがある場合、そのテクスチャを破棄、そして作成
	if (hasTexture(key)) {
		disposeTexture(key);
	}
	if (mask[0] >= 0) { // R:mask[0], G:mask[1], B:mask[2]
		// 抜き色指定
		g_poolTexture[key] = new Texture(ttfImage, mask[0], mask[1], mask[2]);
	}
	else if (mask[0] == -1) { // *default
		// 抜き色なし
		g_poolTexture[key] = new Texture(ttfImage);
	}
	else if (mask[0] == -2) { // X:mask[1], Y:mask[2]
		// 座標指定
		g_poolTexture[key] = new Texture(ttfImage, mask[1], mask[2]);
	}
	else {
		throw new Exception("loadTexture: Invalid parameter 'mask'");
	}
}

/**
 * テクスチャの破棄
 * @param key キー（loadTextureで指定したもの）「null」で全て破棄
 */
void disposeTexture(string key = null)
{
	if (key is null) {
		foreach(k; g_poolTexture.keys) {
			Texture tex = g_poolTexture[k];
			delete tex;
			g_poolTexture.remove(key);
		}
	}
	else {
		if (hasTexture(key) == false)
			throw new Exception("disposeTexture: Has exist key: " ~ key);
		
		Texture tex = g_poolTexture[key];
		delete tex;
		g_poolTexture.remove(key);
	}
}
/**
 * テクスチャの描画（左上から描画）
 * </pre>
 * @param key キー（loadTextureで読み込み済みのもの）
 * @param x   X座標
 * @param y   Y座標
 * @param ox  切り取り開始X座標
 * @param oy  切り取り開始Y座標
 * @param ow  切り取る幅
 * @param oh  切り取る高さ
 * @param dx  拡大サイズ（X）
 * @param dy  拡大サイズ（Y）
 */
void drawTexture(string key,
	float x, float y,
	int ox = 0, int oy = 0, int ow = 0, int oh = 0,
	float dx = 1.0f, float dy = 1.0f)
{
	if (hasTexture(key) == false) {
		throw new Exception("drawTexture: Has not exist key: " ~ key);
	}
	Texture tex = g_poolTexture[key];
	if (ow == 0 || oh == 0) {
		ow = tex._width;
		oh = tex._height;
	}
	float w  = ow * dx;
	float h  = oh * dy;
	
	SDL_Rect src;
	src.x = ox;
	src.y = oy;
	src.w = ow;
	src.h = oh;
	
	SDL_Rect dst;
	dst.x = cast(int)x;
	dst.y = cast(int)y;
	dst.w = cast(int)w;
	dst.h = cast(int)h;
	
// http://sdl2referencejp.sourceforge.jp/SDL_RenderCopy.html
//  int SDL_RenderCopy(SDL_Renderer* renderer, SDL_Texture* texture, const SDL_Rect* srcrect, const SDL_Rect* dstrect)
	
	int status = SDL_RenderCopy(g_renderer, tex._texture, &src, &dst);
	if (status)
		throw new Exception("drawTexture: SDL_RenderCopy");
}

/**
 * テクスチャの描画
 * 中心座標を指定して描画
 * </pre>
 * @param key キー（loadTextureで読み込み済みのもの）
 * @param x   X座標
 * @param y   Y座標
 * @param ox  切り取り開始X座標
 * @param oy  切り取り開始Y座標
 * @param ow  切り取る幅
 * @param oh  切り取る高さ
 * @param dx  拡大サイズ（X）
 * @param dy  拡大サイズ（Y）
 * @param rot 回転角度（0～360。左回り）
 */
void drawTextureEx(string key,
	float x, float y,
	int ox=0, int oy=0, int ow=0, int oh=0,
	float dx = 1.0f, float dy = 1.0f,
	double rot=0.0f) 
{
	if (hasTexture(key) == false) {
		throw new Exception("drawTexture: Has not exist key: " ~ key);
	}
	Texture tex = g_poolTexture[key];
	if (ow == 0 || oh == 0)
	{
		ow = tex._width;
		oh = tex._height;
	}
	float w  = ow * dx;
	float h  = oh * dy;
	
	SDL_Rect src;
	src.x = ox;
	src.y = oy;
	src.w = ow;
	src.h = oh;
	
	SDL_Rect dst;
	dst.x = cast(int)x;
	dst.y = cast(int)y;
	dst.w = cast(int)w;
	dst.h = cast(int)h;
	
// http://sdl2referencejp.sourceforge.jp/SDL_RenderCopyEx.html
// int SDL_RenderCopyEx(SDL_Renderer* renderer, SDL_Texture* texture, 
//		const SDL_Rect* srcrect, const SDL_Rect* dstrect, 
//		const double angle, const SDL_Point* center, const SDL_RendererFlip flip)

	int status = SDL_RenderCopyEx(g_renderer, tex._texture, &src, &dst, rot, null, SDL_FLIP_NONE);
	if (status)
		throw new Exception("drawTexture: SDL_RenderCopyEx");
}

int getTextureWidth(string key)
{
	if (hasTexture(key) == false) {
		throw new Exception("getTextureWidth: Has not exist key: " ~ key);
	}
	Texture tex = g_poolTexture[key];
	return tex._width;
}
int getTextureHeight(string key)
{
	if (hasTexture(key) == false) {
		throw new Exception("getTextureHeight: Has not exist key: " ~ key);
	}
	Texture tex = g_poolTexture[key];
	return tex._height;
}

//@----------------------------------------------------------------------------
class ttFont
{
private:
	string fontPath;
	SDL_Color fgColor = {47, 52, 55};
//	SDL_Color bgColor = {240, 240, 240};
	
	void setFontPath()
	{
		string fontPathArry[] = [
			"res/fonts/ipag-mona.ttf",
			"../fonts/ipag-mona.ttf"
//			"res/fonts/ipagui-mona.ttf",
//			"../fonts/ipagui-mona.ttf"
			];
		foreach (v ; fontPathArry) {
			if (std.file.exists(v)) {
				fontPath = v;
				break;
			}
		}
		if (fontPath.length == 0) {
			throw new Exception("renderText: Set the font file");
		}
	}
	
public:
	this()
	{
		setFontPath();
	}
	SDL_Surface* renderText(string msg, int fontSize)
	{
		if (msg.length == 0) {
			throw new Exception("renderText: msg argument is 0");
		}
		//Open the font
		TTF_Font* font = TTF_OpenFont(toStringz(fontPath), fontSize);
		if (font is null) {
			throw new Exception("renderText: TTF_OpenFont");
		}
		TTF_SetFontHinting(font, TTF_HINTING_MONO);
	//	
	//	SDL_Surface* image = TTF_RenderUTF8_Solid(font, toStringz(msg), fgColor);
	//	SDL_Surface* image = TTF_RenderUTF8_Shaded(font, toStringz(msg), fgColor, bgColor);
		SDL_Surface* image = TTF_RenderUTF8_Blended(font, toStringz(msg), fgColor);
		if (image is null) {
			throw new Exception("renderText: TTF_RenderUTF8_Shaded");
		}
		TTF_CloseFont(font);
		return image;
	}
}
void loadDrawString(string key, string msg, int fontSize, int[3] mask = [-1, 0, 0])
{
	scope ttFont tt = new ttFont;
	SDL_Surface* image = tt.renderText(msg, fontSize);
	loadTexture(key, image, mask);

}
//@----------------------------------------------------------------------------
void drawPoint(int x1, int y1, SDL_Color c)
{
    SDL_SetRenderDrawColor(g_renderer, c.r, c.g, c.b, 255);
	SDL_RenderDrawPoint(g_renderer, x1, y1);
}
void drawPoint(int x1, int y1, int rr, int gg, int bb, int aa = 255)
{
    SDL_SetRenderDrawColor(g_renderer, cast(ubyte)rr, cast(ubyte)gg, cast(ubyte)bb,cast(ubyte)aa);
	SDL_RenderDrawPoint(g_renderer, x1, y1);
}

void drawLine(int x1, int y1, int x2, int y2, SDL_Color c)
{
    SDL_SetRenderDrawColor(g_renderer, c.r, c.g, c.b, 255);
	SDL_RenderDrawLine(g_renderer, x1, y1, x2, y2);
}
void drawLine(int x1, int y1, int x2, int y2, int rr, int gg, int bb, int aa = 255)
{
    SDL_SetRenderDrawColor(g_renderer, cast(ubyte)rr, cast(ubyte)gg, cast(ubyte)bb,cast(ubyte)aa);
	SDL_RenderDrawLine(g_renderer, x1, y1, x2, y2);
}
void drawLine(float x1, float y1, float x2, float y2, int rr, int gg, int bb, int aa = 255)
{
    SDL_SetRenderDrawColor(g_renderer, cast(ubyte)rr, cast(ubyte)gg, cast(ubyte)bb,cast(ubyte)aa);
	SDL_RenderDrawLine(g_renderer, cast(int)x1, cast(int)y1, cast(int)x2, cast(int)y2);
}

void drawRect(int x1, int y1, int x2, int y2, SDL_Color c)
{
    SDL_SetRenderDrawColor(g_renderer, c.r, c.g, c.b, 255);
	SDL_Rect rect;
	rect.x = x1;
	rect.y = y1;
	rect.w = x2 - x1;
	rect.h = y2 - y1;
	SDL_RenderDrawRect(g_renderer, &rect);
}
void drawRect(int x1, int y1, int x2, int y2, int rr, int gg, int bb, int aa = 255)
{
    SDL_SetRenderDrawColor(g_renderer, cast(ubyte)rr, cast(ubyte)gg, cast(ubyte)bb,cast(ubyte)aa);
	SDL_Rect rect;
	rect.x = x1;
	rect.y = y1;
	rect.w = x2 - x1;
	rect.h = y2 - y1;
	SDL_RenderDrawRect(g_renderer, &rect);
}
void drawFillRect(int x1, int y1, int x2, int y2, SDL_Color c)
{
    SDL_SetRenderDrawColor(g_renderer, c.r, c.g, c.b, 255);
	SDL_Rect rect;
	rect.x = x1;
	rect.y = y1;
	rect.w = x2 - x1;
	rect.h = y2 - y1;
	SDL_RenderFillRect(g_renderer, &rect);
}
void drawFillRect(int x1, int y1, int x2, int y2, int rr, int gg, int bb, int aa = 255)
{
    SDL_SetRenderDrawColor(g_renderer, cast(ubyte)rr, cast(ubyte)gg, cast(ubyte)bb,cast(ubyte)aa);
	SDL_Rect rect;
	rect.x = x1;
	rect.y = y1;
	rect.w = x2 - x1;
	rect.h = y2 - y1;
	SDL_RenderFillRect(g_renderer, &rect);
}
//@----------------------------------------------------------------------------

// set Background color
SDL_Color g_backgroundColor;

void clear()
{
//    SDL_SetRenderDrawColor(g_renderer, 240,240,240,0);
    SDL_SetRenderDrawColor(g_renderer, 50,50,50,0);
    SDL_RenderClear(g_renderer);
}

void update()
{
    SDL_RenderPresent(g_renderer);
}

int 	g_width;
int 	g_height;
int 	g_videoFlags;
bool	g_init;

void initProcess(string caption, int width = 800, int height = 600, bool fullscreen = false)
{
	if (g_init)
		return;
	
	g_width      = width;
	g_height     = height;
//	g_videoFlags = SDL_WINDOW_RESIZABLE | SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN;
//	g_videoFlags = SDL_WINDOW_RESIZABLE | SDL_WINDOW_SHOWN;
	g_videoFlags = SDL_WINDOW_SHOWN;
	if (fullscreen) {
		g_videoFlags |= SDL_WINDOW_FULLSCREEN;
//		g_videoFlags |= SDL_FULLSCREEN;
	}
	
	DerelictSDL2.load();
	DerelictSDL2Image.load();
	DerelictSDL2ttf.load();
	
//	if (SDL_Init(SDL_INIT_EVERYTHING) < 0)
//	if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK | SDL_INIT_AUDIO) < 0)
	if (SDL_Init(SDL_INIT_VIDEO) < 0)
		throw new Exception("initProcess:SDL_Init Couldn't initialize SDL");
	
	int IMG_InitFlag = IMG_INIT_PNG | IMG_INIT_JPG;
//	int IMG_InitFlag = 0; // bmp, gif
	if (IMG_Init(IMG_InitFlag) != IMG_InitFlag)
		throw new Exception("initProcess:IMG_Init Couldn't initialize SDL");
	
	if (TTF_Init() != 0)
		throw new Exception("initProcess:TTF_Init Couldn't initialize SDL");
	
	g_window = SDL_CreateWindow(toStringz(caption),
			SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
			width, height, g_videoFlags);
	if (g_window is null)
		throw new Exception("initProcess:SDL_CreateWindow: Couldn't set window/video mode.");
	
	g_renderer = SDL_CreateRenderer(g_window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
	if (g_renderer is null)
		throw new Exception("initProcess:SDL_CreateRenderer");
	
	// setup ico
	string iconPath = "res/icon.bmp";
	if (std.file.exists(iconPath)) {
		SDL_Surface* icon = SDL_LoadBMP(toStringz(iconPath));
		SDL_SetWindowIcon(g_window, icon);
	}
	g_init = true;
	outLog("init:done");
}


void finalProcess()
{
    if (g_renderer !is null)
		SDL_DestroyRenderer(g_renderer);
	if (g_window !is null)
	    SDL_DestroyWindow(g_window);
	if (g_init)
		SDL_Quit();
}


//@----------------------------------------------------------------------------
// KeyBoard

enum uint SDLK_LAST = 300;
static bool[SDLK_LAST] g_pressKeyButtonPrev;
static bool[SDLK_LAST] g_pressKeyButton;

enum : int {
	RETURN_KEY = SDL_SCANCODE_RETURN, // SDLK_RETURN,
	ESCAPE_KEY = SDL_SCANCODE_ESCAPE, // SDLK_ESCAPE,
	SPACE_KEY  = SDL_SCANCODE_SPACE, // SDLK_SPACE,
	KEY_A      = SDL_SCANCODE_A, // SDLK_,
	KEY_B      = SDL_SCANCODE_B, // SDLK_,
	KEY_C      = SDL_SCANCODE_C, // SDLK_,
	KEY_D      = SDL_SCANCODE_D, // SDLK_,
	KEY_S      = SDL_SCANCODE_S, // SDLK_,
	KEY_X      = SDL_SCANCODE_X, // SDLK_x,
	KEY_Z      = SDL_SCANCODE_Z, // SDLK_z,
	KEY_UP     = SDL_SCANCODE_UP, // SDLK_UP,
	KEY_DOWN   = SDL_SCANCODE_DOWN, // SDLK_DOWN,
	KEY_RIGHT  = SDL_SCANCODE_RIGHT, // SDLK_RIGHT,
	KEY_LEFT   = SDL_SCANCODE_LEFT, // SDLK_LEFT,
    KEY_LCTRL  = SDL_SCANCODE_LCTRL, // 224,
    KEY_LSHIFT = SDL_SCANCODE_LSHIFT, // = 225,
    KEY_LALT   = SDL_SCANCODE_LALT, // = 226,
    KEY_LGUI   = SDL_SCANCODE_LGUI, // = 227,
    KEY_RCTRL  = SDL_SCANCODE_RCTRL, // = 228,
    KEY_RSHIFT = SDL_SCANCODE_RSHIFT // = 229,

}
//@----------------------------------------------------------------------------
// Mouse

static uint g_pressMouseButtonPrev;
static uint g_pressMouseButton;


enum : int
{
	MOUSE_BUTTON_LEFT   = SDL_PRESSED << (SDL_BUTTON_LEFT-1),
	MOUSE_BUTTON_MIDDLE = SDL_PRESSED << (SDL_BUTTON_MIDDLE-1),
	MOUSE_BUTTON_RIGHT  = SDL_PRESSED << (SDL_BUTTON_RIGHT-1),
}
/**
 * マウス座標Xの取得
 */
int getMouseX()
{
	int x, y;
	uint button = SDL_GetMouseState(&x, &y);
	return x;
}

/**
 * マウス座標Yの取得
 */
int getMouseY()
{
	int x, y;
	uint button = SDL_GetMouseState(&x, &y);
	return y;
}

/**
 * マウスを押し続けているかどうか
 */
uint isPressMouse()
{
	return g_pressMouseButton;
}

/**
 * マウスをその瞬間に押したかどうか
 * <br>
 */
uint isPushMouse()
{
	return g_pressMouseButton ^ (g_pressMouseButton & g_pressMouseButtonPrev);
}

/**
 * キーを押し続けているかどうか
 */
bool isPressKey(int id)
{
	if (id < 0 || SDLK_LAST <= id)
		return false;
	
	return g_pressKeyButton[id];
}

/**
 * キーをその瞬間に押したかどうか
 * <br>
 */
bool isPushKey(int id)
{
	if (id < 0 || SDLK_LAST <= id)
		return false;
	
	return g_pressKeyButton[id] && !g_pressKeyButtonPrev[id];
}


/**
 * キーのユーティリティ
 * Z or Return or Space or Joy0 or MouseLEFT
 */
bool isPressEnter()
{
	if (isPressKey(KEY_Z)) 		{ return true; }
	if (isPressKey(RETURN_KEY))	{ return true; }
	if (isPressKey(SPACE_KEY))		{ return true; }
	if (isPressMouse() & MOUSE_BUTTON_LEFT) { return true; }
	return false;
}

bool isPushEnter()
{
	if (isPushKey(KEY_Z)) 	 { return true; }
	if (isPushKey(RETURN_KEY)) 	{ return true; }
	if (isPushKey(SPACE_KEY)) 		{ return true; }
	if (isPushMouse() & MOUSE_BUTTON_LEFT) { return true; }
	return false;
}
// X or Joy1 or MouseRIGHT
bool isPressCancel()
{
	if (isPressKey(KEY_X)) 	 { return true; }
	if (isPressMouse() & MOUSE_BUTTON_RIGHT) { return true; }
	return false;
}
bool isPushCancel()
{
	if (isPushKey(KEY_X)) 	{ return true; }
	if (isPushMouse() & MOUSE_BUTTON_RIGHT) { return true; }
	return false;
}
// C or Joy2 or MouseMIDDLE
bool isPressMenu()
{
	if (isPressKey(KEY_C)) 	 { return true; }
	if (isPressMouse() & MOUSE_BUTTON_MIDDLE) { return true; }
	return false;
}
bool isPushMenu()
{
	if (isPushKey(KEY_C)) 	{ return true; }
	if (isPushMouse() & MOUSE_BUTTON_MIDDLE) { return true; }
	return false;
}
// Up
bool isPressUp()
{
	if (isPressKey(KEY_UP)) { return true; }
	return false;
}
bool isPushUp()
{
	if (isPushKey(KEY_UP)) { return true; }
	return false;
}

// Left
bool isPressLeft()
{
	if (isPressKey(KEY_LEFT)) { return true; }
	
	return false;
}
bool isPushLeft()
{
	if (isPushKey(KEY_LEFT)) { return true; }
	return false;
}

// Down
bool isPressDown()
{
	if (isPressKey(KEY_DOWN)) { return true; }
	return false;
}
bool isPushDown()
{
	if (isPushKey(KEY_DOWN)) { return true; }
	return false;
}

// Right
bool isPressRight()
{
	if (isPressKey(KEY_RIGHT)) { return true; }
	return false;
}
bool isPushRight()
{
	if (isPushKey(KEY_RIGHT)) { return true; }
	return false;
}
//@----------------------------------------------------------------------------
// utils

void cw_Delay(int msec = 3000)
{
	SDL_Delay(msec);
}

int MsgBox(string title, string msg)
{
	// sdl bug? : do not show buttons, message / do not system modal
	string[] btnString = ["OK", "Cancel"];
	return showMessageBox(msg, title, btnString);
}

int showMessageBox(string msg, string title, string[] buttons, int defbutton = 0)
{
	//Variables.
	SDL_MessageBoxData mbdata;
	//Set the message box information.
	mbdata.flags = SDL_MESSAGEBOX_INFORMATION;
	mbdata.message = toStringz(msg);
	mbdata.title = toStringz(title);
	mbdata.colorScheme = null;
	mbdata.window = g_window;
	mbdata.numbuttons = buttons.length;
	
	//Allocate buttons.
	SDL_MessageBoxButtonData[] btnArray = new SDL_MessageBoxButtonData[buttons.length];
//	btnArray.length = buttons.length;
	
	//Set the button values.
	foreach (i, v; btnArray) {
		v.text = toStringz(buttons[i]);
        v.buttonid = i;
		v.flags = 0;
		//Is this button the default button?
		if(i == defbutton) {
			v.flags = SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT;
		}
	}
    //Set the message box data's button array.
    mbdata.buttons = btnArray.ptr;
    //Display the message box.
	int resultButton = 0;
    int retval = SDL_ShowMessageBox(&mbdata, &resultButton);
    //Return the result (-1 on failure or if the dialog was closed).
    return retval < 0 ? -1 : resultButton;
}
//@----------------------------------------------------------------------------
// widgets
import std.file;

static uniqObjectID objID;

struct uniqObjectID
{
	void set(int id) { _objID = id; }
	int inc() { return _objID++; }
	int get() { return _objID; }
	string getString() { return format("%d", _objID); }
	string incString() { return format("%d", _objID++); }
private:
	int		_objID = 0;
}


struct wcRect
{
	int 	_x1; // start Rectangle x point
	int 	_y1; // start Rectangle y point
	int 	_x2; // end Rectangle x point
	int 	_y2; // end Rectangle y point
	
	int 	_width;	// 
	int 	_height; // 
	
	int		_xcenter;
	int 	_ycenter;
	
	void setStartXY(int x, int y)
	{
		_x1 = x;
		_y1 = y;
	}
	void setWH(int w, int h)
	{
		_width  = w;
		_height = h;
		
		_x2 = _x1 + w;
		_y2 = _y1 + h;
		
		_xcenter = _x1 + (w /2);
		_ycenter = _y1 + (h /2);
	}
	void setEndXY(int x2, int y2)
	{
		setWH(x2 - _x1, y2 - _y1);
	}
	void setRectWH(int x1, int y1, int w, int h)
	{
		setStartXY(x1, y1);
		setWH(w, h);
	}
	void setRectXY(int x1, int y1, int x2, int y2)
	{
		setStartXY(x1, y1);
		setWH(x2 - _x1, y2 - _y1);
	}
}

class wcObject
{
private:
	string	txId;	// Texture key name
	int 	Xpos;
	int 	Ypos;
	int 	Width;
	int 	Height;
	
	void setPos(int xpos, int ypos)
	{
		Xpos = xpos;
		Ypos = ypos;
	}
	void setWidthHeight()
	{
		Width = getTextureWidth(txId);
		Height = getTextureHeight(txId);
	}
	
public:
	this() {}
	
	@property int getXpos() { return Xpos; }
	@property int getYpos() { return Ypos; }
	@property int getWidth() { return Width; }
	@property int getHeight() { return Height; }
	
	void draw()
	{
		drawTexture(txId, Xpos, Ypos);
	}
}

class wcString : wcObject
{
	this(string textData, int xpos, int ypos, int fontSize = 16, int[3] mask = [-1, 0, 0])
	{
		setPos(xpos, ypos);
		txId = objID.incString();
		loadDrawString(txId, textData, fontSize, mask);
		setWidthHeight();
	}
}
class wcImage : wcObject
{
	this(string imageFile, int xpos, int ypos, int[3] mask = [-1, 0, 0])
	{
		string imagePath;
		string[] Paths = [ "res/image/", "res/" ];
		
		if (exists(imageFile)) {
			imagePath = imageFile;
		}
		else {
			foreach(v ; Paths) {
				string s = v ~ imageFile;
				if (exists(s))
					imagePath = s;
					break;
			}
		}
		if (imagePath.length == 0)
			throw new Exception("wcImage: " ~ imageFile ~ ": image file not found");
		
		setPos(xpos, ypos);
		txId = objID.incString();
		loadTexture(txId, imagePath, mask);
		setWidthHeight();
	}
}

enum ButtonStat
{
	Normal,
	Pressed,
	Selected,
	Disable,
	Hide
}

class wcButton
{
private:
	wcImage 	normal;
	wcImage 	pressed;
	wcImage 	selected;
	wcImage 	disabled;
	wcImage 	image;
	wcString	text;
	
	wcObject[]	drawArray;
	
	int 	Xpos;
	int 	Ypos;
	int 	Width;
	int 	Height;
	
	ButtonStat	bStat;
	
	void delegate() do_onClick;
	
	void setup(int xpos, int ypos)
	{
		bStat  = ButtonStat.Normal;
		Xpos = xpos;
		Ypos = ypos;
		int[3] mask = [-2, 0, 0];
		normal   = new wcImage("button_default_normal.png", xpos, ypos, mask);
		pressed  = new wcImage("button_default_pressed.png", xpos, ypos, mask);
		selected = new wcImage("button_default_selected.png", xpos, ypos, mask);
		disabled = new wcImage("button_default_disabled.png", xpos, ypos, mask);
		Width = normal.getWidth();
		Height = normal.getHeight();
		image = null;
		text  = null;
	}
	void setImage(string imageFile)
	{
		int mask[3] = [-2, 0, 0];
		image = new wcImage(imageFile, 0, 0, mask);
		
		// Center Alignment layout
		int wx = (Width /2)  - (image.getWidth /2);
		int wy = (Height /2) - (image.getHeight /2);
		if (wx < 0) wx = Xpos;
		if (wy < 0) wy = Ypos;
		image.setPos(Xpos + wx, Ypos + wy);
		if (text !is null) {
			// Horizontal layout
			int wix = (Width /2) - ((image.getWidth + text.getWidth) /2);
			if (wix < 0) wix = Xpos;
			image.setPos(Xpos + wix, image.getYpos);
			text.setPos(Xpos + wix + image.getWidth + 5, text.getYpos);
		}
	}
/++
	+----+----+
	|         |
	+  Label  +
	|         |
	+----+----+
++/
	enum	default_buttonFontSize = 14;
	int _buttonFontSize = default_buttonFontSize;
	void buttonFontSize(int size)
	{
		_buttonFontSize = size;
	}
	void setText(string textData)
	{
		text = new wcString(textData, 0, 0, _buttonFontSize);
		// Center Alignment
		int wx = (Width /2)  - (text.getWidth /2);
		int wy = (Height /2) - (text.getHeight /2);
		if (wx < 0) wx = Xpos;
		if (wy < 0) wy = Ypos;
		text.setPos(Xpos + wx, Ypos + wy);
		if (image !is null) {
			// Horizontal layout
			int wtx = (Width /2) - ((image.getWidth + text.getWidth) /2);
			if (wtx < 0) wtx = Xpos;
			image.setPos(Xpos + wtx, image.getYpos);
			text.setPos(Xpos + wtx + image.getWidth + 5, text.getYpos);
		}
	}
	// mouse のボタンが押されX,Y 位置が更新されたらtrue
	bool getMouse()
	{
		if (bStat == ButtonStat.Hide)
			return false;
		
		if (bStat == ButtonStat.Disable)
			return false;
		
		ButtonStat preStat;
		int 	mouseX;
		int 	mouseY;
		int 	mouseButtonStatus;
		int Xend = Xpos + Width;
		int Yend = Ypos + Height;
		
		mouseButtonStatus = SDL_GetMouseState(&mouseX, &mouseY);
		
		if ((Xpos < mouseX) && (Xend > mouseX) && (Ypos < mouseY) && (Yend > mouseY)) {
			preStat = ButtonStat.Selected;
			if (mouseButtonStatus & SDL_BUTTON_LMASK) {
				preStat = ButtonStat.Pressed;
				if (do_onClick !is null) {
					do_onClick();
				}
			}
			// if (mouseButtonStatus & SDL_BUTTON_RMASK)
		}
		else {
			preStat = ButtonStat.Normal;
		}
		
		if (preStat == bStat) {
			return false;
		} else {
			bStat = preStat;
		}
		return true;
	}
	void drawSet()
	{
		drawArray.length = 0;
		if (bStat == ButtonStat.Hide)
			return;
		
		switch(bStat) {
		case ButtonStat.Normal:
			drawArray ~= normal;
			break;
		case ButtonStat.Pressed:
			drawArray ~= pressed;
			break;
		case ButtonStat.Selected:
			drawArray ~= selected;
			break;
		case ButtonStat.Disable:
			drawArray ~= disabled;
			break;
		default:
			throw new Exception("buttn.drawSet: button status!");
		}
		if (image !is null)
			drawArray ~= image;
		if (text !is null)
			drawArray ~= text;
	}

public:
	this(int xpos, int ypos)
	{
		setup(xpos, ypos);
		drawSet();
	}
	this(int xpos, int ypos, string label) // ,layout = 0)
	{
		setup(xpos, ypos);
		setText(label);
		drawSet();
	}
	this(int xpos, int ypos, string label, string imageFile) // ,layout = 0)
	{
		setup(xpos, ypos);
		setText(label);
		setImage(imageFile);
		drawSet();
	}
	void setIcon(string imageFile) // ,layout = 0)
	{
		setImage(imageFile);
		drawSet();
	}
	@property void onClick(void delegate() dg)
	{
		do_onClick = dg;
	}
	void draw()
	{
		if (getMouse())
			drawSet();
		
		foreach (v ; drawArray)
			v.draw();
	}
}

struct wcColor
{
	SDL_Color	titleBar 		= {200, 200, 200};
	SDL_Color	frameBar 		= {200, 200, 200};
	SDL_Color	frameShadow 	= {100, 100, 100};
	SDL_Color	clientBackGround = {240, 240, 240};
	SDL_Color	clienFrameShadow = {100, 100, 100};
	SDL_Color	clienText 		= {50, 50, 50};
}

// 背景にWindow っぽい絵の表示を行います。
class wcWindow
{
private:
	// textString and image
	wcString 	windowTitle;	// window title text string
	wcObject[] 	clientText;		// client text string
	
	wcRect 		fRect;	// window frame
	wcRect 		cRect;	// window client
	
	// inner windows
	int titleBarHeight = 30;
	int windowFrameSize = 3;
	
	// Color
	wcColor 	c;
	
/++	
    client_LeftX / client_RightX
	+---------------------------+
	|                           |
	+------ client_TopY --------+
	|                           |
	|                           |
	+------ client_BottmY ------+
++/	
	void setClientPos()
	{
		cRect.setStartXY(fRect._x1 + windowFrameSize, fRect._y1 + titleBarHeight);
		cRect.setEndXY(fRect._x2 - windowFrameSize, fRect._y2 - windowFrameSize);
	}
	void drawWindow()
	{
		// window Rect
		drawFillRect(fRect._x1, fRect._y1, fRect._x2, fRect._y2, c.clientBackGround);
		// title bar
		drawFillRect(fRect._x1, fRect._y1, fRect._x2, cRect._y1, c.titleBar);
		drawLine(cRect._x1, cRect._y1, cRect._x2, cRect._y1, c.frameShadow);
		
		// frame and shadow
		// left Vertical line
		drawFillRect(fRect._x1, fRect._y1, cRect._x1, cRect._y2, c.frameBar);
		drawLine(cRect._x1, cRect._y1, cRect._x1, cRect._y2, c.frameShadow);
		
		// Right Vertical line
		drawFillRect(cRect._x2, fRect._y1, fRect._x2, fRect._y2, c.frameBar);
		drawLine(cRect._x2, cRect._y1, cRect._x2, cRect._y2, c.frameShadow);
		
		// Bottom Horizontal line
		drawFillRect(fRect._x1, cRect._y2, fRect._x2, fRect._y2, c.frameBar);
		drawLine(cRect._x1, cRect._y2, cRect._x2, cRect._y2, c.frameShadow);
	}

public:
	this() {}
/++
	~this()
	{
		if (windowTitle !is null) {
			delete windowTitle;
		}
		if (clientObjct.length > 0) {
			foreach (v ; clientObjct)
				delete v;
		}
	}
++/
	this(int width, int height, int x1, int y1)
	{
		createWindow(width, height, x1, y1);
	}
	this(string title, int width, int height, int x1, int y1)
	{
		createWindow(title, width, height, x1, y1);
	}
	void createWindow(int width, int height, int x1, int y1)
	{
		fRect.setRectWH(x1, y1, width, height);
		setClientPos();
	}
	void createWindow(string title, int width, int height, int x1, int y1)
	{
		fRect.setRectWH(x1, y1, width, height);
		setClientPos();
		windowTitle = new wcString(title, x1 + 10, y1 + 6);
	}
	void setWindowTitle(string title)
	{
		if (windowTitle !is null)
			delete windowTitle;
		
		windowTitle = new wcString(title, fRect._x1 + 10, fRect._y1 + 6);
	}
//@-----------------------------------------------
	int client_lastX = 0;
	int client_lastY = 0;
	
	void client_setYPos(int y1)
	{
		client_lastY = cRect._y1 + y1;
	}
	void client_addYPos(int offset)
	{
		client_lastY += offset;
	}
	void client_addText(string data, int offsetX = -1, int offsetY = -1)
	{
		if (clientText.length == 0) {
			client_lastX = cRect._x1 + 10;
			client_lastY = cRect._y1 + 10;
		}
		if (!(offsetX == -1 && offsetY == -1)) {
			// offsetX,offsetY が-1 以外ならば位置を設定
			client_lastX += offsetX;
			client_lastY += offsetY;
		}
		
		auto wc = new wcString(data, client_lastX, client_lastY);
		clientText ~= wc;
		
		if (offsetX == -1 && offsetY == -1) {
			// offsetX,offsetY が-1 ならば改行する
			// client_lastX += wc.getWidth();
			client_lastY += wc.getHeight();
		}
	}
	void client_addImage(string imagePath, int offsetX = -1, int offsetY = -1)
	{
		if (clientText.length == 0) {
			client_lastX = cRect._x1 + 10;
			client_lastY = cRect._y1 + 10;
		}
		if (!(offsetX == -1 && offsetY == -1)) {
			// offsetX,offsetY が-1 以外ならば位置を設定
			client_lastX += offsetX;
			client_lastY += offsetY;
		}
		
		auto wc = new wcImage(imagePath, client_lastX, client_lastY);
		clientText ~= wc;
		
		if (offsetX == -1 && offsetY == -1) {
			// offsetX,offsetY が-1 ならば改行する
			// client_lastX += wc.getWidth();
			client_lastY += wc.getHeight();
		}
	}
	void client_addText(string[] data)
	{
		if (clientText.length == 0) {
			client_lastX = cRect._x1 + 10;
			client_lastY = cRect._y1 + 10;
		}
		foreach (v ; data) {
			if (v.length) {
				auto wc = new wcString(v, client_lastX, client_lastY);
				clientText ~= wc;
				client_lastY += wc.getHeight();
			}
			else { // 改行が有ったばあい
				if (clientText.length > 1) {
					// 先頭に改行がある場合は改行しないです
					if (clientText[$ - 1] !is null) {
						wcObject wt = clientText[$ - 1];
						client_lastY += wt.getHeight();
					}
				}
			}
		}
	}
	
	void draw()
	{
		drawWindow();
		if (windowTitle !is null) {
			windowTitle.draw();
		}
		if (clientText.length > 0) {
			foreach (v ; clientText)
				v.draw();
		}
	}
}
/++
class msgBox : wcWindow
{
	wcRect	screen;
	
	this(string title, string msg)
	{
		screen.setRectXY(0, 0, g_width, g_height);
		
		int width  = 
		int height = 
		createWindow(string title, int width, int height, int x1, int y1);
	}
}
++/
//eof
