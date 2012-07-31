/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: default 17.11.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

include : "standard.g" 

text W_default( gtitem gti )
\{
   str desc title lang prjname url keys edit

   _gtp.prj.get("project/lang", lang )
   _gtp.prj.get("project/name", prjname )

   gti.getsubitem( "desc", desc )
   if !*desc : desc = "#/title#"

   gti.getsubitem( "keywords", keys )
   if !*keys : keys = "#/title#"
   
   title = "\( prjname ): #/title#"
   _gtp.geturl( gti, url )

   if !_gtp.prj.find( "project/options", "noedit" )
   {
      edit = "<a href=\"/admin/edit.phtml?url=\(url)\">#lng/edit#</a>"   
   }
   
}<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/strict.dtd"><html>
<head>
<meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8">
<!--meta http-equiv="Content-Language" content="\( lang )"-->
<meta NAME="KEYWORDS" CONTENT="\( keys )">
<meta NAME="DESCRIPTION" CONTENT="\( desc )">
<link rel="icon" href="/favicon.ico" type="image/x-icon"> 
<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon">
<link rel="stylesheet" type="text/css" href="/css/default/styles.css">
<script language="JavaScript1.2" src="/css/ddnmenu.js" type="text/javascript"></script>
<title>\( title )</title></head>
<body>
   \@header( gti, "" )

	<div id="center" >
		<div class="left-column">
\{
   str info
   gti.getsubitem( "info", info )
   if *info : @info
   
   @navmenu( gti )
}
<!--#include virtual="/adv.php" -->            
		</div>
		<div class="content">
\{
   @grainmenu( gti )
}
			<div class="box"><!--EDIT-->\@content( gti )<!--EDIT-->
         \@related( gti.name )
         </div>
         \(edit)
		</div>
		<br style="clear:left">
	</div>

<!--#include virtual="/footer.html" -->
</body></html>
\!

func W_standard< entry >
{
   str  out 
   
   out.fgetdir($_FILE).faddname( "standard.gt")
   _gtp.read( out )
}
