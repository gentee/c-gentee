type Font
{
   uint hFont
}

type FontManager <inherit=hash>
{
}

method Font FontManager.GetFont( str name )
{
   return this[name]->Font   
}

method FontManager.AddFont( str name, uint hFont )
{
   uint f as .GetFont( name )   
   if &f
   {
      DeleteObject( f.hFont )
   }
   else
   {
      f as new( Font )->Font
      this[name] = &f      
   }   
   //print( " \(&f) \(name) \(hFont )\n" )
   f.hFont = hFont   
}

method FontManager FontManager.Default()
{
   uint hfont
   int cur   
   LOGFONT lf      
   GetObject( GetStockObject( $DEFAULT_GUI_FONT ), sizeof( LOGFONT ), &lf )   
   .AddFont( "default", CreateFontIndirect( lf ) )  
   
   cur = lf.lfUnderline   
   lf.lfUnderline = 1      
   .AddFont( "default_underline", CreateFontIndirect( lf ) )
   lf.lfUnderline = cur
      
   cur = lf.lfWeight
   lf.lfWeight = 800
   .AddFont( "default_bold", CreateFontIndirect( lf ) )
   lf.lfWeight = cur
      
   cur = lf.lfHeight   
   lf.lfHeight = int( double(cur) * 1.5 )
   .AddFont( "default_big", CreateFontIndirect( lf ) )
   lf.lfHeight = cur
         
   return this
}