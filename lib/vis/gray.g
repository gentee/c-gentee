/*const
  LogPaletteSize = sizeof(TLogPalette) + sizeof(TPaletteEntry) * 255
function BitmapColorsToGray( hBitMap : Cardinal Width, Height : integer ) : Cardinal stdcall
var
  hOld : Cardinal
  DC : HDC
{
  DC = CreateCompatibleDC(0)
  hOld = Selectobject( DC, hBitMap )
  FiddleBitmap( DC, hBitMap, Width, Height )
  SelectObject( DC, hOld )
  Result = hBitMap
}*/

func uint PaletteFromDIB( BITMAPINFO BitmapInfo )
{
   lp    lp
   int   i
   ubyte tmp

   lp.palVersion = 0x300
   lp.palNumEntries = 256   
   mcopy( lp.palPalEntry, BitmapInfo.bmiColors, 4 * 256 )
   for i, 256
   {
      p as ( &lp.palPalEntry + i * 4 )->PALENTRY
      tmp = p.peBlue
      p.peBlue = p.peRed
      p.peRed = tmp
      p.peFlags = $PC_NOCOLLAPSE      
   }
   return CreatePalette(lp)
}

funct int BytesPerScanline( int PixelsPerScanline, BitsPerPixel, Alignment )
{
  Alignment--
  Result = ((PixelsPerScanline * BitsPerPixel) + Alignment) & ~Alignment
  Result = Result >> 4
}

func InitializeBitmapInfoHeader( uint Bitmap, BITMAPINFOHEADER BI, int Colors )
{
   DIBSECTION DS
   int        Bytes
   
   DS.dsbmih.biSize = 0
   Bytes = GetObject(Bitmap, sizeof(DS), &DS )
   if !Bytes  
   {
      InvalidBitmap
   }
   elif (Bytes >= (sizeof(DS.dsbm) + sizeof(DS.dsbmih))) &&
      (DS.dsbmih.biSize >= DWORD(sizeof(DS.dsbmih))) 
   {
      BI = DS.dsbmih
   }
   else
   {
      FillChar(BI, sizeof(BI), 0)
      with BI, DS.dsbm do
      {
      biSize = sizeof(BI)
      biWidth = bmWidth
      biHeight = bmHeight
      }
   }
   if colors == 2 
   {
      BI.biBitCount = 1
   }
   elif colors >= 3 and colors <= 16
   {
         BI.biBitCount = 4
         BI.biClrUsed = Colors
   }
   elif colors >= 17 and colors <= 256
   {      
         BI.biBitCount = 8
         BI.biClrUsed = Colors
   }      
   else
   {
      BI.biBitCount = DS.dsbm.bmBitsPixel * DS.dsbm.bmPlanes
   }   
   BI.biPlanes = 1
   if BI.biClrImportant > BI.biClrUsed 
   {
      BI.biClrImportant = BI.biClrUsed
   }
   if !BI.biSizeImage 
   { 
      BI.biSizeImage = BytesPerScanLine(BI.biWidth, BI.biBitCount, 32) * Abs(BI.biHeight)
   }
}

func GetDIBSizes( uint Bitmap, uint pInfoHeaderSize, ImageSize, int Colors )
{
   BITMAPINFOHEADER BI
   InitializeBitmapInfoHeader(Bitmap, BI, Colors)
   if BI.biBitCount > 8 
   {
      InfoHeaderSize->uint = sizeof(BITMAPINFOHEADER)
      if BI.biCompression & $BI_BITFIELDS : InfoHeaderSize->uint += 12
   }
   elif !BI.biClrUsed
   {
      InfoHeaderSize->uint = sizeof(BITMAPINFOHEADER) + 4 * ( BI.biBitCount << 1 )
   }
   else
   {
      InfoHeaderSize = sizeof(BITMAPINFOHEADER) + 4 * BI.biClrUsed
   }
   ImageSize = BI.biSizeImage
}

func FiddleBitmap(uint HDC, uint Bitmap, int Width, Height)
{
   uint BitmapInfoSize = sizeof(BITMAPINFO) + 4 * 255
   
   BITMAPINFO BitmapInfo
   POINTER Pixels
   uint InfoSize
   uint ADC
   uint OldPalette, Palette
   int index
   ubyte Red, Green, Blue, Gray

//GetMem(BitmapInfo, BitmapInfoSize)
//меняем таблицу цветов - ПРИМЕЧАНИЕ: она использует 256 цветов DIB  
//  FillChar( &BitmapInfo^, BitmapInfoSize, 0)
  with BitmapInfo.bmiHeader 
  {
    .biSize = sizeof(BITMAPINFOHEADER)
    .biWidth = Width
    .biHeight = Height
    .biPlanes = 1
    .biBitCount = 8
    .biCompression = $BI_RGB
    .biClrUsed = 256
    .biClrImportant = 256
    //GetDIBSizes(Bitmap, InfoSize, .biSizeImage )
    /*BITMAPINFOHEADER BI 
     InitializeBitmapInfoHeader(Bitmap, BI, 0 )
  if BI.biBitCount > 8 
  {
    InfoHeaderSize = sizeof(TBitmapInfoHeader)
    if (BI.biCompression and BI_BITFIELDS) <> 0 
      Inc(InfoHeaderSize, 12)
  }
  else
    if BI.biClrUsed = 0 
      InfoHeaderSize = sizeof(TBitmapInfoHeader) +
        sizeof(TRGBQuad) * (1 shl BI.biBitCount)
    else
      InfoHeaderSize = sizeof(TBitmapInfoHeader) +
        sizeof(TRGBQuad) * BI.biClrUsed
  ImageSize = BI.biSizeImage
    */
    

    //распределяем место для пикселей 
    Pixels = GlobalAlloc( $GMEM_MOVEABLE, biSizeImage )
    
      // получаем пиксели DIB 
   ADC = GetDC(0)
   OldPalette = SelectPalette(ADC, 0, 0)
   RealizePalette(ADC)
   GetDIBits(ADC, Bitmap, 0, biHeight, Pixels, BitmapInfo^,
         DIB_RGB_COLORS)
   SelectPalette(ADC, OldPalette, true)
   
   ReleaseDC(0, ADC)
    
      
      //теперь изменяем таблицу цветов      
/*      for index = 0 to 255 do
        {
          Red  = BitmapInfo^.bmiColors[ index ].rgbRed
          Green = BitmapInfo^.bmiColors[ index ].rgbGreen
          Blue  = BitmapInfo^.bmiColors[ index ].rgbBlue

          Gray = RgbToGray( RGB( red, Green, Blue ) )

          BitmapInfo^.bmiColors[ index ].rgbRed = Gray
          BitmapInfo^.bmiColors[ index ].rgbGreen = Gray
          BitmapInfo^.bmiColors[ index ].rgbBlue = Gray
        }
*/
      //создаем палитру на основе новой таблицы цветов
   Palette = PaletteFromDIB(BitmapInfo)
   OldPalette = SelectPalette(DC, Palette, 0)
   RealizePalette(DC)
   StretchDIBits(DC, 0, 0, biWidth, biHeight, 0, 0,
         biWidth, biHeight,
         Pixels, BitmapInfo^, $DIB_RGB_COLORS, $SRCCOPY)
   
   SelectPalette(DC, OldPalette, true)      
   
   GlobalFree(Pixels)
  
}