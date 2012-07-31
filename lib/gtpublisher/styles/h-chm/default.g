/******************************************************************************
*
* Copyright (C) 2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: default 28.11.07 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

text chmimages( arrstr params )
\{
   str   output
   ffind fd

   _gtp.prj.get( "project/output", output )
   output.faddname( "css\\img\\*.*" )
   
   fd.init( output, $FIND_FILE )
   foreach curfile, fd
   {
      @"#img(\"css/img/\( curfile.name )\")\l"   
   }
}\!

text chmitem( gtitem gti, uint keyword )
\{
   arrstr  names
   str url title keys
   
   _gtp.geturl( gti, url )
   gti.getsubitem( "urlname", title )
   if !*title : gti.getsubitem( "title", title )
   if keyword
   {   
      gti.getsubitem( "keywords", keys )
      keys.split( names, ',', $SPLIT_NOSYS )
   }
   names += title
   foreach curname, names
   {
      @"   <LI><OBJECT type=\"text/sitemap\">\l"
      @"   <param name=\"Name\" value=\"\(curname)\">\l"
      if gti.findrel( "/content" )
      {
         @"   <param name=\"Local\" value=\"\(url)\">\l"
      }
      @"  </OBJECT>\l"
   }
}\!

text buildhhk( arrstr params )
\{
   foreach curitem, _gtp.root()
   {
      str out cstyle
      ustr ustemp
      curitem as gtitem
         
      curitem.get( "style", cstyle )
      cstyle.upper()
      if cstyle.findch( 'H' ) >= *cstyle : continue
      if curitem.find("text") : continue
      
      out@chmitem( curitem, 1 )      
//      ustemp.fromutf8( out )
//      @( out = ustemp )
      @out
   }   
}\!

text  hhcitem( gtitem owner )
\{
      foreach curitem, owner
      {
         str   out link
         ustr  ustemp
         
         curitem as gtitem
         out@chmitem( _gtp.find( curitem.name ), 0 )      
//         ustemp.fromutf8( out )
//         @( out = ustemp )
         @out
         
         curitem.get( "link", link )
         if curitem.haschild() || *link
         {
            @"<UL>\l"
            hhcitem( ?( *link, _gtp.find( link ), curitem ))
            @"</UL>\l"
         }         
      }   
}\! 
   
text buildhhc( arrstr params )
\{
   hhcitem( _gtp.find("chmmenu"))
}\!

text H_default( gtitem gti )
\{
   str desc title lang prjname url keys

   _gtp.prj.get("project/lang", lang )
   _gtp.prj.get("project/name", prjname )
   
   gti.getsubitem( "desc", desc )
   if !*desc : desc = "#/title#"

   gti.getsubitem( "keywords", keys )
   if !*keys : keys = "#/title#"
   
   title = "\( prjname ): #/title#"
   _gtp.geturl( gti, url )
   
}<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/strict.dtd"><html>
<head>
<meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=#chm/code#">
<!--meta http-equiv="Content-Language" content="\( lang )"-->
<meta NAME="KEYWORDS" CONTENT="\( keys )">
<meta NAME="DESCRIPTION" CONTENT="\( desc )">
<link rel="stylesheet" type="text/css" href="/css/styles.css">
<title>\( title )</title></head>
<body>
		<div class="content">
			<div class="box">\@content( gti )
         \@related( gti.name )
         </div>
		</div>
		<!--br style="clear:left"-->
   <!--hr>
      Copyright &copy; 2004-06 Gentee, Inc., 2006-08 <a href = #gentee/url# target= "_blank" >The Gentee Group</a>. All rights reserved. 
		<br style="clear:left"-->
      &nbsp;

</body></html>
\!
