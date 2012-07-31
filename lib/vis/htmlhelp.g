
import "HHCTRL.OCX"
{
   uint HtmlHelpW( uint, uint, uint, uint ) -> HtmlHelp
}

define
{
   HH_DISPLAY_TOPIC    =   0x0000
   HH_DISPLAY_TOC      =   0x0001  
   HH_DISPLAY_INDEX    =   0x0002   
}

type HelpManager 
{
   ustr HelpFile
}
/*
type htmlhelp
{
   ustr pchmfile  
}
*/
/*func helpfile( str filename )
{
   getmodulepath( chmfile, filename )   
}
*//*
property htmlhelp.chmfile( ustr value )
{
   .pchmfile = value
}

property str htmlhelp.chmfile<result>
{
   result = .pchmfile
}

method uint htmlhelp.topic( ustr topic )
{
   return HtmlHelp( 0, .pchmfile.ptr(), $HH_DISPLAY_TOPIC, topic.ptr() )  
}

method uint htmlhelp.index
{
   return HtmlHelp( 0, .pchmfile.ptr(), $HH_DISPLAY_INDEX, 0 )  
}

method uint htmlhelp.helpcontents
{
  return HtmlHelp( 0, .pchmfile.ptr(), $HH_DISPLAY_TOC, 0 )
}
*/


method uint HelpManager.Topic( ustr topic )
{
   return HtmlHelp( 0, .HelpFile.ptr(), $HH_DISPLAY_TOPIC, topic.ptr() )
}

method uint HelpManager.Index( )
{
   return HtmlHelp( 0, .HelpFile.ptr(), $HH_DISPLAY_INDEX, 0 )
}

/*method uint HelpManager.Contents( ustr contents )
{
   return HtmlHelp( 0, .HelpFile.ptr(), $HH_DISPLAY_TOC, contents.ptr() )
}*/