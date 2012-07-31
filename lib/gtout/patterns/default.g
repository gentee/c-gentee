/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gtout 17.11.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

text menu( str namemenu, gt2item gti )
\{
   uint idmenu
   gt2items gt2s

   idmenu as _gt->gt2.find( "root/\(namemenu)" )
   if !&idmenu : return
   foreach cur, idmenu.items( gt2s )
   {
      str head
      gti.get("headmenu", head )
      if gti.name == cur.name || head == cur.name 
      {
         @"<li><span>\(cur.value)</span></li>"
      }
      else
      {
         @"<li><a href=\"\("".getlink( _gtalias[ cur.name ]->gt2item ))\">\(cur.value)</a></li>"  
      }
   }
}\!

text menulang( gt2item gti )
\{
   uint idmenu
   gt2items gt2s

   idmenu as _gtalias["menulang"]->gt2item
   if !&idmenu : return
   foreach cur, idmenu.items( gt2s )
   {
      str  url
      if _prefix == cur.name
      {
         @"<li><span>\(cur.value)</span></li>"
      }
      else
      {
         str slink
         cur.get( "url", url )
         slink.getlink( gti ).del( 0, *_rp )
         @"<li><a href=\"\(url)/\( slink )\">\(cur.value)</a></li>"  
      }
   }
}\!

method str.splitstr( str div, arr out of str )
{
   uint prev off
   str stemp
   
   out.clear()
   spattern sp
   sp.init( div, 0 )//$QS_BEGINWORD )

   while ( off = sp.search( this, prev )) < *this 
   {
      stemp.substr( this, prev, off - prev ).trimsys()
      out += stemp
      prev = off + *div
   }
//   print("\(div) Off = \( off ) len= \( *this )")
   stemp.substr( this, prev, off - prev ).trimsys()
//   print("\(div) Off = \( off ) len= \( *this )")
   out += stemp
}

text a( arr params of str )
\{
   str atext link
   uint gti 
   if !*params : return
   link = params[0]

   gti as _gt->gt2.find( params[0] )
   if &gti
   {
      link = gti.value
   }
   else
   {
      gti as _gtalias[ params[0] ]->gt2item
      if &gti : link.getlink( gti )
   }
   if *params > 1 && *params[1] : atext = params[1]
   else : atext = params[0]  
   @"<a href = \"\(link)\">\( atext )</a>"
}\!

text ul( arr params of str )
\{  arr items of str
   uint i
   str  class div = "\l\l" 
 
   if !*params : return
 
   if *params > 1 && *params[1] : class = "class = \"\( params[1] )\""  
   if *params > 2 && *params[2] : div = params[2]  
   //gt2item.process( params[0], ret, 0->arr )
   
   params[0].splitstr( div, items )
   @"<ul \(class)>"
   fornum i, *items
   {
      @"<li>\(items[i])</li>" 
   }     
}</ul>\!

text news( arr params of str )
\{  arr items of str
   uint i
   str  class div = "\l\l" 
 
   if !*params : return
 
   if *params > 1 && *params[1] : @"<h2>\(params[1])</h2>"  
   
   params[0].splitstr( div, items )
   @"<div class = \"news\">"
   fornum i, *items
   {
      arr first of str
      
      items[i].split( first, ':', $SPLIT_FIRST )
      @"#b[\(first[0])]<p>\(first[1])</p>" 
   }     
}</div>\!

text fcombo( arr params of str )
\{  arr items of str
   uint gti
   gt2items gt2s
 
   if *params < 3 : return
   @"<tr><td class = \"ftext\">\( params[0] )</td>"
   @"<td><select name=\"\( params[1] )\">"

   gti as _gtalias[ params[2] ]->gt2item
   if &gti
   { 
      foreach cur, gti.items( gt2s )
      {
         @"<option value='\(cur.name)'>\(cur.value)</option>"
      }
   }
   @"</select></td></tr>"
}\!

text textcontent( gt2item gti )
\{
   arr items of str
   uint gtc
      
   gtc as gti.findrel("/content")
   if !&gtc : return
   gtc.value.splitstr( "\l\l", items )
   foreach cur, items
   {   
      @"<p>\(cur)</p>\l"
   }
}\!

text shots( arr params of str )
\{
   arr items of str
   str path
      
   params[0].splitstr( "\l", items )
   foreach cur, items
   {   
      arr name of str
      
      cur.split( name, ',', $SPLIT_NOSYS )
      
      @"<div class=\"shots\">#a[\(params[1])/\(name[0])][<img src=\"\(params[1])/sm_\(name[0])\">]<p>\(name[1])</p></div>\l"
   }
}\!


text fradio( arr params of str )
\{  arr items of str
   uint gti i
   gt2items gt2s
 
   if *params < 3 : return
   @"<tr><td class = \"ftext\">\( params[0] )</td>"
   @"<td>"

   gti as _gtalias[ params[2] ]->gt2item
   if &gti
   { 
      foreach cur, gti.items( gt2s )
      {
         @"<input type=radio name='\(params[1])' value='\(cur.name)' \(?( !i++, "checked" , ""))>\(cur.value)"
         if *gti > 2 : @"<br>"
      }
   }
   @"</td></tr>"
}\!

text tblhead( arr params of str )
\{  arr items of str

   if *params < 3 : return
   @"<tr><td class = \"head\">\( params[0] )</td>"
   @"<td class = \"head\">\( params[1] )</td>"
   @"<td class = \"head\">\( params[2] )</td></tr>"
}\!

text trok( arr params of str )
\{  arr items of str
    str ok = "<img src = \"/img/ok.png\">"   
 
   if *params < 3 : return
   @"<tr><td class = \"tbltext\">\( params[0] )</td>"
   @"<td align = center  class = \"tbltext\">\(?( uint( params[1] ), ok, "&nbsp;" ))</td>
 <td align = center  class = \"tbltext\">\(?( uint( params[2] ), ok, "&nbsp;" ))</td></tr>"
}\!

text gtul( gt2item gti, str curname ) 
\{
   gt2items gt2s
   @"<ul class = \"ulnav\">"
   foreach cur, gti.items( gt2s )
   {
      str  url
      if curname == cur.name
      {
         @"<li><div id = \"curli\">\(cur.value)</div></li>"
      }
      else
      {
         str url
         arr params of str
         
         cur.get("url", url )
         params += ?( *url, url, cur.name )
         params += cur.value
         @"<li>"
         if params[0][0] == '_' : @cur.value
         else : @a( params )
         @"</li>"
      }
      if cur.haschild() : @gtul( cur, curname )
   }
   @"</ul>"

}\!

text navmenu( gt2item gti )
\{
   str  name
   uint idmenu
   gt2items gt2s

   if !*gti.get("navmenu", name ) : return
   idmenu as _gtalias[ name ]->gt2item
   if !&idmenu : return
   @gtul( idmenu, gti.name )
}\!

text prog( arr params of str )
\{
   str  imglink dwnlnk stemp
   uint gti
   
   gti as _gtalias[ params[0] ]->gt2item
   gti as gti.findrel("/prog")
   if !&gti : return
   gti.get("shimg", imglink )
   imglink.insert( imglink.findch('/', 1 ) + 1, "sm_" ) 
}
<div class = "prog">
   <div class = "image">#a[\(gti.get( "shlink" ))][#img( \( imglink ))]</div>
   #a( \(params[0]), '#h3( \( gti.get( "name" )) )' )
   #span[\(gti.process( "#.info#", "", 0->arr ))][ver]
   #p[\( gti.value )]
   #p[#b[ 
   #a( \(params[0]), \(gti.get( "learn" ))) | #a( \(gti.get( "dwnlink" )), \(gti.get( "download" ))
   )\{
      if gti.get("cost")
      {
         @" | #a( \(gti.get( "buylink" )), \(gti.get( "buy" ))) #b('(\(gti.get("cost")))')"
      }
      else
      {
         @" | #b( freeware )"
      }
      
   }]] 
</div>
\!

text download( arr params of str )
\{ str   filename ver size date stemp
   finfo fi
   uint  gti
   
   filename.fnameext( params[1] )
   if *params > 2
   {
      if _gtalias.find( params[2] )
      {
        gti as _gtalias[ params[2]]->gt2item
        gti as gti.findrel( "/prog" )
        gti.get("date", stemp )
        gti.get("version", ver )
        date = "v\(ver) ( \(stemp) )" 
      }
      else : ( date = params[2] ) +=" "
   } 
   getfileinfo( params[1], fi )
   size = str( fi.sizelo / 1024 )
}
<p>#b[#a( \(params[0]), \( filename ) )] \(date) \(size)KB</p> 
\!

text tblorder( arr params of str )
<table class = "price">
<tr class = "pricehead"><td>\( params[0] )</td><td>\( params[1] )</td><td>\( params[2] )</td></tr>
<tr><td>1 \(params[3])</td><td>$\( params[5] )</td><td rowspan=4>
#a( url/\(params[9])order1, Buy through ShareIt! )<br>or<br>
#a( url/\(params[9])order2, Buy through RegSoft )
</td></tr>
<tr><td>2-9 \( params[4] )</td><td>$\( params[6] )</td></tr>
<tr><td>10-25 \( params[4] )</td><td>$\( params[7] )</td></tr>
<tr><td> &gt; 25 \( params[4] )</td><td>$\( params[8] )</td></tr>
</table>
\!

text defhtm( gt2item gti )
\{
   str desc

   gti.getsubitem( "desc", desc )
   if !*desc : desc = "/#title#"
}<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN"><html><head>
<meta http-equiv="Content-Language" content="#lang/\(_prefix).htmlang#">
<meta NAME="KEYWORDS" CONTENT="#/keywords#">
<meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset="#lang/\(_prefix).charset#">
<meta NAME="DESCRIPTION" CONTENT="\(desc)">
<link rel="stylesheet" href="\(_rp)css/default.css" type="text/css">
<title>#prjname#: #/title#</title></head>
<body>
<div id = "main">
   <div id = "page">
      <div id = "head">
         <div id = "logo">
         <img alt="#prjname# Logo" src="\(_rp)img/logo.gif" width = 48 height = 48/>
         <h3>#prjname#</h3>
         </div>
         <div id = "lang">
            \@menulang( gti )
         </div>
         <div id = "menu">
            \@menu( "menumain", gti )          
         </div>
      </div>
\{
   uint inav
   inav as gti.findrel("/nav")
   if &inav
   {   
      str  stemp 
      stemp@navmenu( gti )  
      @"<div id = \"nav\">
        \( stemp )
        \( inav.value )
        <!--#include virtual=\"\(_rp)left.txt\" -->
      </div>"
   }
}
      <div id = "content">
        <h1>#/title#</h1>
\{  
   if gti.find("text") : @textcontent( gti )     
   else: @"#/content#" 
   }</div>
      <div id = "footer">
         <p>#copyright#</p>
      </div>
   </div>
   <!--div id = "adv">
      <include virtual="\(_rp)adv.html">
   </div-->
</div>
</body></html>
\!
