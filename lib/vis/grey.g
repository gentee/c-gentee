
type RGBQUAD {
  ubyte rgbBlue 
  ubyte rgbGreen 
  ubyte rgbRed 
  ubyte rgbReserved 
}

type PALETTEENTRY { 
  ubyte peRed 
  ubyte peGreen 
  ubyte peBlue 
  ubyte peFlags 
} 

type BITMAPINFOHEADER {
  uint  bmiSize 
  int   bmiWidth 
  int   bmiHeight 
  short bmiPlanes 
  short bmiBitCount 
  uint  bmiCompression 
  uint  bmiSizeImage 
  int   bmiXPelsPerMeter 
  int   bmiYPelsPerMeter 
  uint  bmiClrUsed 
  uint  bmiClrImportant 
}    

type BITMAPINFO { 
  BITMAPINFOHEADER bmiHeader 
  RGBQUAD          bmiColors 
} 

type LOGPALETTE { 
  short         palVersion 
  short         palNumEntries 
  PALETTEENTRY palPalEntry 
}  


type DIBSECTION { 
  BITMAP            dsBm 
  BITMAPINFOHEADER  dsBmih 
  uint              dsBitfields[3] 
  uint              dshSection 
  uint              dsOffset 
} 

define {
   PC_NOCOLLAPSE = 0x04
   
   BI_RGB       = 0
   BI_RLE8      = 1
   BI_RLE4      = 2
   BI_BITFIELDS = 3
   BI_JPEG      = 4
   BI_PNG       = 5
   
   DIB_RGB_COLORS   = 0
   DIB_PAL_COLORS   = 1


   GMEM_MOVEABLE  = 0x0002
   GMEM_ZEROINIT  = 0x0040
}

import "gdi32.dll"
{
   uint CreatePalette( LOGPALETTE )
   uint SelectPalette( uint, uint, uint )
   uint RealizePalette( uint )
   int GetDIBits( uint, uint, uint, uint, uint, BITMAPINFO, uint )
   int StretchDIBits( uint, int, int, int, int, int, int, int, int, uint, BITMAPINFO, uint, int )
   uint CreateDIBitmap( uint, BITMAPINFOHEADER, uint, uint, BITMAPINFO, uint )
   uint MaskBlt( uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint )
   uint CreateDIBSection( uint, BITMAPINFO, uint, uint, uint, uint )
}

import "kernel32.dll"
{
   uint GlobalAlloc( uint, uint )
   uint GlobalFree( uint )
   uint GlobalLock( uint )
   uint GlobalUnlock( uint )   

}

func uint PaletteFromDIB( BITMAPINFO bmi )
{
   LOGPALETTE    lp
   uint   i, p
   ubyte  tmp

   lp.palVersion = 0x300
   lp.palNumEntries = 256   
   mcopy( &lp.palPalEntry, &bmi.bmiColors, 4 * 256 )
   fornum i, 256
   {
      p as ( &lp.palPalEntry + i * 4 )->PALETTEENTRY
      tmp = p.peBlue
      p.peBlue = p.peRed
      p.peRed = tmp
      p.peFlags = $PC_NOCOLLAPSE      
   }
   return CreatePalette(lp)
}

func int BytesPerScanLine( int PixelsPerScanline BitsPerPixel Alignment )
{
   uint res
   Alignment--
   res = ((PixelsPerScanline * BitsPerPixel) + Alignment) & ~Alignment
   res = res >> 3
   return res
}

func uint InitializebmiHeader( uint Bitmap, BITMAPINFOHEADER BIH, int colors )
{
   DIBSECTION DS
   int        Bytes
   
   DS.dsBmih.bmiSize = 0
   Bytes = GetObject(Bitmap, sizeof( DIBSECTION ), &DS )
   if !Bytes  
   {
      //print( "error\n" )
      return 0 //Error
   }
   elif Bytes >= (sizeof( BITMAP ) + sizeof( BITMAPINFOHEADER )) &&
        DS.dsBmih.bmiSize >= sizeof( BITMAPINFOHEADER ) 
   {
      mcopy( &BIH, &DS.dsBmih, sizeof( BITMAPINFOHEADER ) )
   }
   else
   {      
      mzero( &BIH, sizeof( BITMAPINFOHEADER ))     
      BIH.bmiSize = sizeof( BITMAPINFOHEADER )
      BIH.bmiWidth = DS.dsBm.bmWidth
      BIH.bmiHeight = DS.dsBm.bmHeight
   }
   if colors == 2 
   {
      BIH.bmiBitCount = 1
   }
   elif colors >= 3 && colors <= 16
   {
      BIH.bmiBitCount = 4
      BIH.bmiClrUsed = colors
   }
   elif colors >= 17 && colors <= 256
   {      
      BIH.bmiBitCount = 8
      BIH.bmiClrUsed = colors
   }      
   else
   {
      BIH.bmiBitCount = DS.dsBm.bmBitsPixel * DS.dsBm.bmPlanes
      
   }   
   BIH.bmiPlanes = 1
   if BIH.bmiClrImportant > BIH.bmiClrUsed 
   {
      BIH.bmiClrImportant = BIH.bmiClrUsed
   }
   if !BIH.bmiSizeImage 
   { 
      BIH.bmiSizeImage = BytesPerScanLine( BIH.bmiWidth, BIH.bmiBitCount, 32 ) *
          ?( BIH.bmiHeight < 0, -BIH.bmiHeight,  BIH.bmiHeight )          
   }
   return 1
}

func GetDIBSizes( uint Bitmap, uint pInfoHeaderSize pImageSize, int Colors )
{
   BITMAPINFOHEADER BIH
   InitializebmiHeader(Bitmap, BIH, Colors)
   if BIH.bmiBitCount > 8 
   {
       pInfoHeaderSize->uint = sizeof(BITMAPINFOHEADER)
       if BIH.bmiCompression & $BI_BITFIELDS : pInfoHeaderSize->uint += 12
   }
   elif !BIH.bmiClrUsed
   {
      pInfoHeaderSize->uint = sizeof(BITMAPINFOHEADER) + 4 * ( BIH.bmiBitCount << 1 )
   }
   else
   {
      pInfoHeaderSize->uint = sizeof(BITMAPINFOHEADER) + 4 * BIH.bmiClrUsed
   }
   pImageSize->uint = BIH.bmiSizeImage
}

func uint FiddleBitmap( uint DC, uint Bitmap, int Width Height)
{
   uint bmiSize = sizeof(BITMAPINFO) + 4 * 255
   uint hbmi
   //BITMAPINFO bmi
   uint bmi
   uint Pixels, hPixels
   uint InfoSize
   uint ADC
   uint OldPalette, Palette
   uint i
   uint Red, Green, Blue, Grey

 hbmi = GlobalAlloc( $GMEM_MOVEABLE | $GMEM_ZEROINIT, bmiSize )

 bmi as GlobalLock( hbmi )->BITMAPINFO

//GetMem(bmi, bmiSize)
//меняем таблицу цветов - ПРИМЕЧАНИЕ: она использует 256 цветов DIB  
//  FillChar( &bmi^, bmiSize, 0)
  with bmi.bmiHeader 
  {
    .bmiSize = sizeof( BITMAPINFOHEADER )
    .bmiWidth = Width
    .bmiHeight = Height
    .bmiPlanes = 1
    .bmiBitCount = 8
    .bmiCompression = $BI_RGB
    .bmiClrUsed = 256
    .bmiClrImportant = 256
  
    GetDIBSizes( Bitmap, &InfoSize, &.bmiSizeImage, 0 )   
    
  
    //распределяем место для пикселей 
    hPixels = GlobalAlloc( $GMEM_MOVEABLE, .bmiSizeImage/*  + sizeof(BITMAPINFO)*/ )
    
    Pixels = GlobalLock( hPixels )    
   
      // получаем пиксели DIB 
   ADC = GetDC(0)
   //ADC = CreateCompatibleDC(0)
   
   //SelectObject( ADC, Bitmap )
   //CreateCompatibleBitmap( ADC, 16, 16 )
   //DIBSECTION xbi
   //mcopy( Pixels, &bmi, sizeof(BITMAPINFO) )
      //uint r = GetObject( Bitmap,  sizeof( DIBSECTION ), &xbi ) 
   //uint pal = PaletteFromDIB( xbi.dsBm )
   //print( " \(r) pal =\(pal )\n" )
   OldPalette = SelectPalette(ADC,GetStockObject(15), 0 )   
   RealizePalette(ADC)
   GetDIBits(ADC, Bitmap, 0, .bmiHeight, Pixels, bmi, $DIB_RGB_COLORS )
   
   SelectPalette(ADC, OldPalette, 1)
   
   ReleaseDC(0, ADC)
       

      
      //теперь изменяем таблицу цветов      
      fornum i = 0, 256
      { 
      
         uint c as ( &bmi.bmiColors + sizeof(RGBQUAD) * i )->RGBQUAD
          
         Red  = c.rgbRed 
         Green = c.rgbGreen
         Blue  = c.rgbBlue
         //Серое с подсветкой
         /*Grey = min( 0xFF, ( Red + Green + Blue ) / 3 + 60 ) 
         c.rgbRed = Grey 
         c.rgbGreen = Grey  
         c.rgbBlue = Grey*/
          
         //Понижение контрастности           
         Grey = 0x120//min( 0xFF, ( Red + Green + Blue ) / 3 + 150 ) 
         c.rgbRed = min( 0xDD,( Grey + c.rgbRed )/2)
         c.rgbGreen = min( 0xDD,( Grey +  c.rgbGreen )/2) 
         c.rgbBlue = min( 0xDD,( Grey + c.rgbBlue )/2)//min( 0xFF, Grey + 50 )
         
//       //Подсветка
         /*Grey = 0x50//min( 0xFF, ( Red + Green + Blue ) / 3 + 150 ) 
         c.rgbRed = min( 0xFF, c.rgbRed*15/10)
         c.rgbGreen = min( 0xFF, c.rgbGreen*15/10) 
         c.rgbBlue = min( 0xFF, c.rgbBlue*15/10)//min( 0xFF, Grey + 50 )*/
      }
      //создаем палитру на основе новой таблицы цветов
   Palette = PaletteFromDIB(bmi)
   OldPalette = SelectPalette(DC, Palette, 0)

   RealizePalette(DC)
 
   StretchDIBits(DC, 0, 0, .bmiWidth, .bmiHeight, 0, 0,
         .bmiWidth, .bmiHeight,
         Pixels, bmi, $DIB_RGB_COLORS, $SRCCOPY)
   }   
   SelectPalette(DC, OldPalette, 1)
   GlobalUnlock( hPixels )
   GlobalFree( hPixels)
   GlobalUnlock( hbmi )

   GlobalFree( hbmi)  
  return 0
}


/*const
  LogPaletteSize = sizeof(TLogPalette) + sizeof(TPaletteEntry) * 255*/
func uint BitmapColorsToGrey( uint hBitMap, uint hMask, int Width Height )
{
  uint DC, MDC 
  uint hOldDC
  uint hOldMDC

  DC = CreateCompatibleDC(0)
  hOldDC = SelectObject( DC, hBitMap )  
  FiddleBitmap( DC, hBitMap, Width, Height ) 
  
  MDC = CreateCompatibleDC(0)
  hOldMDC = SelectObject( MDC, hMask )
  //uint NDC = CreateCompatibleDC(NDC) 
  //hNew = CreateCompatibleBitmap( DC, Width, Height ) 
  //hOld = SelectObject( NDC, hNew )
  //BitBlt( NDC, 0, 0, Width, Height, MDC, 0, 0,  $NOTSRCCOPY )
  BitBlt( DC, 0, 0, Width, Height, MDC, 0, 0,  0x22 << 16/*$SRCAND*/ )
  SelectObject( MDC, hOldMDC )  
  DeleteDC( MDC )
  SelectObject( DC, hOldDC )
  DeleteDC( DC )  
  return 0
}