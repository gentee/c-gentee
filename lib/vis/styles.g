type Style
{
   //str pFontName
   //str pFontBold
   //str pFontSize
   
   uint hFont
   uint fNewFont
   uint hBrush
   uint fNewBrush
   
   uint fTextColor
   uint pTextColor
   
   str  pDescr
   //uint FontColor   
   //uint bkcolor 
}



type Styles <inherit=hash index=Style>
{
}

method Styles.oftype( uint ctype )
{
   return  
}

method Styles.init()
{
   this->hash.oftype( Style )
}
/*
property ustr Style.FontName<result>()
{
}

property Style.FontName( ustr name )
{
}

property uint Style.FontBold()
{
}

property Style.FontBold( uint val )
{
}*/ 

/*method Style.SetFont( str descr )
{
   gt fgt
   fgt.load( descr )
   
}*/




method Style Styles.GetStyle( str name )
{
   uint find = this.find(name)
   return find->Style
   //return this[name]//->Style   
}


method Style.Free()
{
   if .fNewBrush : DeleteObject( .hBrush )
   if .fNewFont : DeleteObject( .hFont )
   .hBrush = 0
   .hFont = 0
   .fNewFont = 0   
   .fNewBrush = 0
   .pTextColor = 0
   .fTextColor = 0
}

method Style.delete()
{
   .Free()  
}

func uint colorref( uint rgb )
{
   return ( rgb & 0xFF ) << 16 | ( rgb & 0xFF00 ) | ( rgb & 0xFF0000 ) >> 16   
}

method Style.Update( )
{
   .Free() 
   gt dgt
   dgt.root().load( .pDescr )
   str  attrib
   uint istyle as dgt.root().findrel("/style")
   if &istyle && 
      uint( istyle.get( "ver", "" ) ) ==  1
   {
      uint ibrush as istyle.findrel( "/brush" )
      if &ibrush 
      {            
         if *ibrush.get( "color", attrib )
         {
            if "".substr( attrib, 0, 9 ) == "syscolor_"
            {
               .hBrush = GetSysColorBrush( uint( "".substr( attrib, 9, *attrib - 9 ) ))// + 1                                
            }
            else
            {
               LOGBRUSH lb
               lb.lbStyle = 0//$BS_SOLID
               lb.lbColor = colorref( uint( attrib ) )
               lb.lbHatch = 0               
               .hBrush = CreateBrushIndirect( lb )
               .fNewBrush = 1                              
            }
            /*switch attrib
            {
               case "SCROLLBAR"         = 0
               case "BACKGROUND"        = 1
               case "ACTIVECAPTION"     = 2
               case "INACTIVECAPTION"   = 3
               case "MENU"              = 4
               case "WINDOW"            = 5
               case "WINDOWFRAME"       = 6
               case "MENUTEXT"          = 7
               case "WINDOWTEXT"        = 8
               case "CAPTIONTEXT"       = 9
               case "ACTIVEBORDER"      = 10
               case "INACTIVEBORDER"    = 11
               case "APPWORKSPACE"      = 12
               case "HIGHLIGHT"         = 13
               case "HIGHLIGHTTEXT"     = 14
               case "BTNFACE"           = 15
               case "BTNSHADOW"         = 16
               case "GRAYTEXT"          = 17
               case "BTNTEXT"           = 18
               case "INACTIVECAPTIONTEXT" = 19
               case "BTNHIGHLIGHT"      = 20
               default
               {
                  uint color = uint( attrib )
               } 
            }*/
         }
      }
      
      uint itext as istyle.findrel( "/text" )
      if &itext
      {      
         if *itext.get( "color", attrib )
         {
            .fTextColor = 1
            if "".substr( attrib, 0, 9 ) == "syscolor_"
            {               
               //.hTextColor = uint( "".substr( attrib, 9, *attrib - 9 ) )
               .pTextColor = GetSysColor( uint( "".substr( attrib, 9, *attrib - 9 ) ) )                              
            }
            else
            {               
               //.hTextColor = 0x1000               
               .pTextColor = colorref(uint( attrib ))                              
            }            
         }         
      }
      uint ifont as istyle.findrel( "/font" )
      if &ifont
      {
         LOGFONT lf         
         GetObject( GetStockObject( $DEFAULT_GUI_FONT ), sizeof( LOGFONT ), &lf )
         if *ifont.get( "name", attrib )
         {                     
            if *attrib > 63 : attrib.setlen( 63 )
            mcopy( &lf.lfFaceName, attrib.ptr(), *attrib )             
         }
         if *ifont.get( "size", attrib )
         {            
            if attrib[0] ==  '+' || attrib[1] ==  '-'
            {
               lf.lfHeight -=  int( attrib )
            }
            else
            {
               lf.lfHeight =  int( attrib )
            }             
         }
         if *ifont.get( "bold", attrib )
         {         
            lf.lfWeight =  ?( uint( attrib ), 800, 400 )
         }   
         if *ifont.get( "underline", attrib ) 
         {
            lf.lfUnderline =  uint( attrib ) 
         }
         if *ifont.get( "italic", attrib ) 
         {
            lf.lfItalic =  uint( attrib )
         }
         if *ifont.get( "strikeout", attrib ) 
         {
            lf.lfUnderline =  uint( attrib ) 
         }
         .hFont =  CreateFontIndirect( lf )
         .fNewFont = 1  
      }
   }
}


method Style Styles.AddStyle( str name, str descr )
{
   uint s as this[name]
   s.pDescr = descr   
   s.Update()
   return s     
}

method Styles.Update()
{
   foreach s, this
   {
      s.Update()
   }
}