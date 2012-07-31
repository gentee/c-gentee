/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: standard 17.11.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

include : $"..\..\..\..\example\src2html\src2html.g"

global
{
   uint _gtimenu // gtitem in menu for searchroot
   uint _childmenu  // The first owner in childs
}

/*-----------------------------------------------------------------------------
*
* ID:  15.03.2007 1.0
* 
* Summary: Получить ссылку на страницу.  
*  
-----------------------------------------------------------------------------*/

text a( arrstr params )
\{
   str atext link
   uint gti 
   
   if !*params : return
   
   link = params[0]
      
   gti as _gtp.find( link )
   if &gti
   { 
      _gtp.geturl( gti, link )
      gti.getsubitem( "urlname", atext )
      if !*atext : gti.getsubitem( "title", atext )
   }
      
   if *params > 1 && *params[1] : atext = params[1]

   if !*atext
   {
      atext = link
      if "http:".eqlenign( atext ) : atext.del( 0, 7 )
   }
   @"<a href = \"\( link )\">\( atext )</a>"
}\!

text content( gtitem gti )
\{
   str  content title
   arrstr  prg

   gti.getsubitem( "content", content )
   gti.getsubitem( "pagetitle", title )
   if !*title : gti.getsubitem( "title", title )

   @"#h1( '\(title )')\l"
   if gti.find( "nop" )
   {
      @content
   }
   else
   {
      @"<p>"
      prg.load( content, 0 )
      foreach curp, prg
      {
         if !*curp : @"</p><p>\l"
         else : @"\(curp)\l" 
      }
      @"</p>"
   }
//   @content      
}\!


method uint gtpub.searchmenu( gtitem gmenu, str name )
{
   if gmenu.name %== name : return &gmenu
   
   foreach curmenu, gmenu
   {
      uint ret
      if ret = this.searchmenu( curmenu->gtitem, name ) : return ret 
   }
   return 0
}

text ulcont( gtitem root )
<ul><p>\{
   foreach cur, root
   {
      cur as gtitem
      arrstr  pars
      str     link
      
      if cur.find("nourl")
      {
         uint gtdis
         str  stemp
         
         gtdis as _gtp.find( cur.name )
         if &gtdis : gtdis.getsubitem( "title", stemp )
         else : stemp = cur.name
         link = "<span class=\"text\">\(stemp)</span>"
      }
      else
      {
         pars += cur.name
         link@a( pars )
      } 
      @"<li>\( link )"
      if cur.haschild() : @ulcont( cur )
      @"</li>\l"
   }
}</p></ul>\!

text contents( arrstr param )
\{
   uint root
   
   root as _gtp.searchmenu( _gtp.find( "menu"), param[0] )->gtitem
   
   @"<p>#h2( '#lng/tcont#' )"   
   @ulcont( root )
   @"</p>"
}\!

text adesc( arrstr params )
\{
   uint gti 
   
   if !*params : return
  
   gti as _gtp.find( params[0] )
   if &gti
   { 
      str stemp
      gti.getsubitem( "desc", stemp )
      @stemp
   }
}\!

text desc( arrstr params )
\{
   uint gti 
   
   if !*params : return
  
   gti as _gtp.find( params[0] )
   if &gti
   { 
      str stemp
      gti.getsubitem( "desc", stemp )
      @stemp
   }
}\!

text doclist( arrstr param )
#tblparam[\{
   arrstr items
   
   items.loadtrim( param[0] )
   foreach cur, items
   {
      str title desc link
      uint gti
      
      gti as _gtp.find( cur )
      if &gti
      { 
//         _gtp.geturl( gti, link )
//         gti.getsubitem( "urlname", title )
//         if !*title : gti.getsubitem( "title", title )
         gti.getsubitem( "desc", desc )
         @"#a( \( cur ))|\(desc)\l "
      }
      
   }   
}]\!

text dwnfile( arrstr param )
\{
   finfo fi
   datetime dt
   str   date atext name filename = "#dwnpath#\\\(param[0])"
   
   _gtp.get( "lng/date", date )
   _gtp.process( filename )
   if !getfileinfo( filename, fi )
   {
      print("File \( filename ) has not been found!\n")
   } 
   name.fnameext( filename )
   ftimetodatetime( fi.lastwrite, dt, 0)
   getdateformat( dt, date, atext )
    
   @"<strong><a href = '/download/\(name)'>\(name)</></>|\(fi.sizelo)|\(atext)|\(param[1])"      

}\!

text form( arrstr params )
\{
   str url
   uint gti
   
   gti as _gtp.find( params[0] )
   if &gti : _gtp.geturl( gti, url )
}
<form class="form1" enctype="multipart/form-data" action="\( url )"  method="post">\!

text formcombo( arrstr params )
\{  arrstr items
 
   if *params < 3 : return
   @"<h6>\( params[0] )</h6><SELECT NAME=\"\( params[1] )\" SIZE=1 class=\"combobox\">"
   items.loadtrim( params[2] )
   foreach curi, items
   {
      arrstr subi
      curi.split( subi, '|', $SPLIT_NOSYS | $SPLIT_FIRST )
      @"<option value='\(subi[0])'>\( subi[1] )</option>"
   }
   @"</select>"
}\!

text formend( arrstr params )
<br><input type="submit" value="\( params[0] )" class="button">
\{
   if *params > 1
   {
      @"<input type=\"reset\" value=\"\( params[1])\" class=\"button\">"
   }
}</form>\!

text formradio( arrstr params )
\{  arrstr items
 
   if *params < 3 : return
   @"<h6>\( params[0] )</h6>"
   items.loadtrim( params[2] )
   foreach curi, items
   {
      arrstr subi
      curi.split( subi, '|', $SPLIT_NOSYS | $SPLIT_FIRST )
      @"<input type=\"radio\" name=\"\(params[1])\" value=\"\(subi[0])\">&nbsp;\( subi[1] )</input><br>"
   }
}\!

text curlang( arrstr params )
\{
    @_gtp.lang
}\!

text mainmenu( gtitem gti )
<div class="menu-box">
	<span class="mainmenu">
\{
   uint imenu
   
   imenu as _gtp.find("menu")
   foreach curmenu, imenu
   {
      str  name
      uint mgti
      arrstr  astr
      
      curmenu as gtitem
      astr += curmenu.name
      
      _gtp.geturlname( curmenu.name, name )
      
      if _gtp.searchmenu( curmenu, gti.name )
      {
         @"<div class=\"menu-act\">\( name )</div>"
      }
      else : @a( astr )
   }         
}      
	</span>
</div>\!

method gtitem gtpub.searchroot( gtitem gti, str name attrib )
{
   if gti.name %== name
   { 
      _gtimenu = &gti
      return 0xFFFFFFFF->gtitem
   } 
   foreach curmenu, gti
   {
      uint ret
      
      curmenu as gtitem
      ret as this.searchroot( curmenu, name, attrib )
      if ret
      {
         if &ret == 0xFFFFFFFF
         {
            if gti.find( attrib ) : return gti
            else : return ret        
         }
         else : return ret 
      }      
   }
   return 0->gtitem   
}

text grainmenu( gtitem gti )
\{
   uint rootmenu
  
   rootmenu as _gtp.searchroot( _gtp.find("menu"), gti.name, "grain" )
   if !&rootmenu || &rootmenu == 0xFFFFFFFF : return
}<div class="box submenu">\{
   uint   owner 
   int    i
   arrstr st
   
   owner as _gtimenu->gtitem
   
   do
   {
      owner as owner.parent()
      if !owner.find("nourl")
      {
         st += owner.name
      }
   } while &owner != &rootmenu  
   
   for i = *st - 1, i >= 0, i--
   {
      str class
      arrstr param
      if i == *st - 1 && i : class = "class=\"first\""
      elif !i : class = "class=\"last\""
//      url@a( param += st[i] )
      @"<span \(class)>"
      @a( param += st[i] )
      @"</span>"          
   }  
//   navgenerate( rootmenu, 0, gti.name, stemp )
//   @stemp
//				<span class="first"><a href="#">Документация</a></span><span><a href="#">Описание языка</a></span><span class="last"><a href="#">Макросы</a></span>
}</div>
\!

text linklist( arrstr params )
#h2( \( params[0] ) )
<p><ul>
\{
   arrstr items
   
   params[1].split( items, '|', $SPLIT_NOSYS )
   foreach cur, items
   {
      @"<li>#a( \( cur ) )</li>\l"
   }
}</ul></p>\!

func str navgenerate( gtitem gti, uint level, str name ret )
{
   str stemp
   
   if gti.haschild() && ( !level || name != "childs" ) && 
      ( !_childmenu || _childmenu == &gti || level != 1 )
   {
      arrstr astr

      if level
      {            
         if gti.name %== name
         {
            _gtp.geturlname( name, stemp )
            ret@"<div class=\"lvl l\(level) act  show\">
							<p class=\"act\"><!--span onclick=\"hideShow(2)\" id=\"2\">&nbsp;&ndash;&nbsp;</span-->&nbsp;&nbsp;&nbsp;\( stemp )</p>
							<div class=\"lvl l\( level + 1 ) show\" ><!-- id=\"2_1\" -->
								<ul>"
         }
         else
         {
            astr += gti.name
            if gti.find("nourl")
            {
               uint gtdis
               gtdis as _gtp.find( gti.name )
               if &gtdis : gtdis.getsubitem( "title", stemp )
               else : stemp@gti.name
            }
            else : stemp@a( astr )
            ret@"<div class=\"lvl l\(level)\">
					<p><!--span onclick=\"hideShow(3)\" id = \"3\" >&nbsp;&ndash;&nbsp;</span-->&nbsp;&nbsp;&nbsp;\( stemp )</p>
						<div class=\"lvl l\(level + 1) show\"><!-- id=\"3_1\"-->
                  <ul>"
         }            
      }
//      print("Childs \(gti.name) = \(level) \(name)\n")            
      foreach curmenu, gti
      {
         navgenerate( curmenu->gtitem, level + 1, name, ret )
      }
      if level
      {
         ret@"</ul></div></div>"
      }
   }
   else 
   {
//      print( "\(gti.name) \(level) \n")
      if gti.name %== name
      {
         _gtp.geturlname( name, stemp )
         if level == 1
         {      
            ret @ "<div class=\"lvl l\(level) act\"><p class=\"act\">&nbsp;&nbsp;&nbsp;\( stemp )</p></div>"
         }
         else : ret @ "<li class=\"act\">\( stemp )</li>"
      }
      else
      {
         arrstr astr
            
         if gti.find("nourl")
         {
            uint gtdis
            gtdis as _gtp.find( gti.name )
            if &gtdis : gtdis.getsubitem( "title", stemp )
            else : stemp@gti.name
         }
         else
         {
            astr += gti.name 
            stemp@a( astr )
         }
         if level == 1
         {         
            ret @ "<div class=\"lvl l\(level)\"><p>&nbsp;&nbsp;&nbsp;\(stemp)</p></div>"
         }
         else : ret @ "<li>\(stemp)</li>" 
      }
   }
   return ret
}

text navmenu( gtitem gti )
\{
   uint rootmenu parent
   str  name

   _gtimenu = 0
   _childmenu = 0
   name = gti.name
   rootmenu as _gtp.searchroot( _gtp.find("menu"), name, "nav" )
      
   if _gtimenu && _gtimenu->gtitem.find( "childs" ) 
   {
      name = "childs"
      rootmenu as _gtimenu->gtitem
//      return
   }
   elif !&rootmenu || &rootmenu == 0xFFFFFFFF : return
}<div class="left-menu">\{
   str stemp
   if rootmenu.find( "childs" ) && &rootmenu != _gtimenu 
   {
      _childmenu = _gtimenu
      while &_childmenu->gtitem.parent() != &rootmenu   
      {
         _childmenu = &_childmenu->gtitem.parent()
      }
//      print(" \( &rootmenu ) Child = \( _childmenu ) \(name) \( _childmenu->gtitem.name )\n")    
   }
   navgenerate( rootmenu, 0, name, stemp )
   @stemp 
/*   foreach curmenu, imenu
   {
      str  name
      uint mgti
      arrstr  astr
      
      curmenu as gtitem
   }*/         
}
</div>\!

text related( str param )
\{
   uint gti gtis

   gti as _gtp.find("common/\( param )/require" )
   if &gti
   {
      @"<p>#h2(#lng/require#)#tblparam[ \( gti.value ) ]</p>"
   }
   
   gti as _gtp.find("common/\( param )/related" )
   if style[0] != 'H'
   {
      gtis as _gtp.find("common/\( param )/source" )
   }
   if &gti && gtis
   {
      @"<table border=0 width=100%><tr><td>"
   }
   if &gti
   {
      @"<p>#linklist( #lng/related#, \( gti.value ))</p>"
   }
   if &gti && gtis : @"</td><td>"
   if gtis
   {
      @"<p>#h2( '#lng/source#' )<p><ul>"
   
      arrstr items
   
      gtis->gtitem.value.split( items, '|', $SPLIT_NOSYS )
      foreach cur, items
      {
         str val anchor
         uint off
         
         off = cur.findch('#')
         if off < *cur
         {
            anchor.substr( cur, off, *cur - off )
            cur.setlen( off )
         }
         val.replacech( cur, '.', "_" ) += ".htm"
         @"<li>#a( /source/\(val)\(anchor), \(cur) )</li>\l"
      }
      @"</ul></p></p>"
   }
   if &gti && gtis
   {
      @"</td></tr></table>"
   }
}\!

text sp( arrstr param )
\{
   uint i
   fornum i, uint( param[0] ) + 1
   {
      @"&nbsp;"
   }
}\!

text srcg( arrstr params )
\{
   str  out stemp
   
   _gtp.process( params[0] )   
//   stemp.replacech( params[0], '<', "&lt;" )
//   out.replacech( stemp, '>', "&gt;" )
   out@src2html( params[0], $S2H_GENTEE )
}
<pre><code>\( out )</code></pre>
\!

text ex( arrstr params )
\{
   uint example
   
   example as _gtp.find( params[0] )
   if &example
   {
      params[0] = example->gtitem.value
      @srcg( params ) 
   }
}\!

text srchtml( arrstr params )
\{
   str  out stemp
   
   _gtp.process( params[0] )   
   stemp.replacech( params[0], '<', "&lt;" )
   out.replacech( stemp, '>', "&gt;" )
}
<pre><code><strong>\( out )</strong></code></pre>
\!

text srctxt( arrstr params )
\{
   str  out stemp
   
   _gtp.process( params[0] )   
   stemp.replacech( params[0], '<', "&lt;" )
   out.replacech( stemp, '>', "&gt;" )
}
<pre><code><strong>\( out )</strong></code></pre>
\!

text tblborder( arrstr param )
\{
   uint i, cols, width = 100
   arrstr lines items
   
   if *param > 1 : width = uint( param[1] )

   lines.loadtrim( param[0] )
   
   @"<table cellpadding=\"0\" rules=\"cols\" class=\"table1\" width=\( width )%>"
   lines[0].split( items, '|', $SPLIT_NOSYS )
   cols = *items      
   @"<col span=\( cols ) width=\"20%\">"
   fornum i, *lines
   {
      str class
      
      if !i : class = "class=\"tablehead\""
      elif i == 1 : class = "class=\"after-tablehead\""
      @"<tr \(class)>"
      lines[i].split( items, '|', $SPLIT_NOSYS )
      if *items == 1
      {
          @"<td colspan = \(cols)><span>\(items[0])</span></td>"  
      }
      else
      {
         foreach curi, items
         {
            @"<td><span>\(curi)</span></td>"
         }
      }
      @"</tr>"
   }
   @"</table>"
}\!

text tblparam( arrstr param )
\{
   uint i, cols, width = 100
   uint colw = 30
   arrstr lines items
   
   if *param > 1 : width = uint( param[1] )
   if *param > 2 : colw = uint( param[2] )

   lines.loadtrim( param[0] )
   
   @"<table cellpadding=\"0\" class=\"table3\" width=\( width )%>"
   @"<col width=\"\(colw)%\">"
   fornum i, *lines
   {
      str class
      
      if !i : class = "class=\"first-row\""
      elif i == *lines - 1 : class = "class=\"last-row\""
      @"<tr \(class)>"
      lines[i].split( items, '|', $SPLIT_NOSYS )
      if *items == 1 : items += "&nbsp;"
       _gtp.process( items[0] )
       _gtp.process( items[1] )
      @"<td class=\"first-col\"><span>\(items[0])</span></td>"
      @"<td class=\"last-col\"><span>\(items[1])</span></td>"
      @"</tr>"
   }
   @"</table>"
}\!

text tbllines( arrstr param )
\{
   uint i
   arrstr lines
   
   subfunc trout( uint num )
   {
      uint k
      arrstr items
      
      _gtp.process( lines[ num ] )
      lines[ num ].split( items, '|', $SPLIT_NOSYS )
		@"<td class=\"first-col\"><span>\( items[0] )</span></td>\l"
      
      fornum k = 1, *items - 1
      {
         @"<td><span>\( items[k] )</span></td>\l"   
      }
      @"<td class=\"last-col\"><span>\( items[ *items - 1 ] )</span></td>\l"
   }
   
   lines.loadtrim( param[0] )
   
   @"<div class=\"box-no-bord\"><table cellpadding=\"0\" class=\"table2\">
<tr class=\"tablehead\">\l"
   trout( 0 )
   @"</tr>\l"
   fornum i = 1, *lines
   {
      if !*lines[i] : continue
      @"<tr class=\"\(?( i & 1, "ne-chet", "chet" ))\">\l"
      trout( i )  
      @"</tr>\l"
   }
   @"</table></div>"
}\!

text apilist( arrstr param )
\{
   arrstr items
   uint   i

   subfunc trout( str sname )
   {
      str  desc
      uint gti
      
      gti as _gtp.find( sname )
      if !&gti : return

      gti.getsubitem( "desc", desc )
      @"<td class=\"first-col\"><span class=\"api\">#a(\( sname ))</span></td>\l"
      @"<td class=\"last-col\"><span>\( desc )</span></td>\l"
   }
   
   items.loadtrim( param[0] )

   @"<div class=\"box-no-bord\"><table cellpadding=\"0\" class=\"table2\">"
   fornum i = 0, *items
   {
      @"<tr class=\"\(?( i & 1, "ne-chet", "chet" ))\">\l"
      trout( items[i] )  
      @"</tr>\l"
   }
   @"</table></div>"
}\!

text urltext( arrstr params )
\{
   arrstr links
   
   links.loadtrim( params[0] )
   foreach curlink, links
   {
      arrstr items
      
      curlink.split( items, ',', $SPLIT_FIRST | $SPLIT_NOSYS )
      if *items == 2
      {
         @"#h4( #a[\(items[0])])<p>\(items[1])</p>"
      }
   }
}\!

text header( gtitem gti, str langlink )
	<div class="header">
		<span class="logo">&nbsp;</span>
   	<noindex><span class="search">
\{
if _gtp.find("langlist")
{
   foreach curl, _gtp.find("langlist")
   {  
      str name
      curl as gtitem
          
      curl.get( "name", name )
	   @"<span class=\"lang\">"
      if curl.name %== _gtp.lang : @name
      elif *langlink
      {
         @"<a href=\"\(curl.value)\(langlink)\">\( name )</a>"
      }
      else
      {   
         str link
         _gtp.geturl( gti, link )
         @"<a href=\"\(curl.value)\(link)\">\( name )</a>"
      }
      @"</span>"
   }
}
}
			<!-- form action="" method=get>
				<input type="text" class="inp" name="search">
				<input type="submit" value="Search"  class="sub" name="submit">
            </form -->
		</span></noindex>
		<span class="head-fon">&nbsp;</span>
		<br style="clear:right">
      \@mainmenu( gti )
	</div>
\!

text ul( arrstr params )
<ul>
\{
   arrstr links
   
   links.loadtrim( params[0] )
   foreach curlink, links
   {
      @"<li><span class=\"text\">\(curlink)</span></li>\l"
   }
}</ul>\!

include : "bnf.g"