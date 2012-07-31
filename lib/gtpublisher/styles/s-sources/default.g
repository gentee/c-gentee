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

global
{
   str   srcdir
   uint  srcgti prevsrc
}

method  str str.srcurl( gtitem gti, uint mode )
{
   uint dir
   str  filename srcout aname
   
   gti.getsubitem( "src", srcout )
   aname.fnameext( srcout )
   dir = getfileattrib( srcout ) & $FILE_ATTRIBUTE_DIRECTORY
   if dir : filename = "\(gti.name)\\index.htm" 
   else : filename = "\(gti.name).htm"
         
   srcout.fgetdir( srcout ).del( 0, *srcdir )
   
   switch mode
   {
      case 0
      { 
         aname.replacech( srcout, '.', "_" ) 
         this = "\(_gtp.output )\\source\( aname )\\\(filename)"
      }
      case 1  // url
      { 
         if gti.find( "level" )
         {
            aname.replacech( srcout, '.', "_" ) 
            this.replacech( "/source\( aname )/\(filename)", '\', "/" )
         }
         else : this = "/source/index.htm" 
      }
      case 2 // url name
      {
         if dir
         { 
             aname.fgetdir( filename ).upper()
             this.replacech( aname, '_', "." ) 
         }
         else : this = aname 
      }
      case 3 // src title
      {
         _gtp.prj.get("project/name", aname )
         if gti.find( "level" )
         {
            gti.getsubitem( "src", srcout )
            srcout.del( 0, *srcdir )
            if dir : srcout.appendch('\')
         }
         else : gti.getsubitem( "title", srcout )
         this = "\( aname ): \( srcout )" 
      }
      case 4 // src
      {
         if gti.find( "level" )
         {
            gti.getsubitem( "src", this )
            this.del( 0, *srcdir )
//            if dir : this.appendch('\')
         }
         else : this.clear()
      } 
   }
   return this   
}

text grainsrc( gtitem gti )
\{
   if !gti.find( "level" ) : return
   
}<div class="box subsrc">\{
   arrstr st
   str    url
   int    i
   
   url.srcurl( gti, 4 )
   do
   {
      str stemp
      
      stemp.fnameext( url )
      url.fgetdir( url )
      st += stemp
   } while *url  

   @"<span><a href = \"/source/index.htm\">source</a>"
   url = "/source"
     
   for i = *st - 1, i >= 0, i--
   {
      @"<span class=\"orange\">\\</span>"
      url += "/\(st[i])"
      if !i : @"\( st[i] )"
      else : @"<a href = \"\(url)/index.htm\">\( st[i] )</a>"
   }  
   @"</span>"
   
}</div>
\!


func loadsources( gt gtdir, str dirname )
{
   arrstr dirs
   arrstr files
   ffind  fd
   
//   print("dir=\(dirname)\n")
   fd.init( "\(dirname)\\*.*", $FIND_FILE | $FIND_DIR )
   foreach curfile, fd
   {
      curfile as finfo
      
      if !( curfile.attrib & $FILE_ATTRIBUTE_ARCHIVE ) : continue
      if curfile.attrib & $FILE_ATTRIBUTE_DIRECTORY : dirs += curfile.name 
      else : files += curfile.name
//      print( "Found = \( curfile.name )\n")
   } 
   dirs.sort( 0 ) 
   files.sort( 0 ) 
   foreach curf, files : dirs += curf
   
   foreach cur, dirs
   {
      str  name ext dir
      uint nofile
      
//    print( "Files = \(cur)\n")
      ext = cur.fgetext()
      if direxist( "\(dirname)\\\(cur)" )
      { 
         dir = "dir"
      } 
      elif ext %!= "g" && ext %!= "gt" && ext %!= "c" && ext %!= "h" && *ext
      { 
         nofile = 1
      }
      if ext %== "ncb" || ext %== "plg" || ext %== "opt" : continue
      
      name.replacech( cur, '.', "_" ) 
      gtdir += "<\( name ) style = S level = 1 \( ?( nofile, "nofile", "" )) \(dir)>
   <src = \"\(dirname)\\\(cur)\" />
   <content ></> 
</>" 
   }
}

text srcdirout( gtitem gti, gt gtdir )
\{
   arrstr aout[1]
   str    date  cont
   
   gti.getsubitem( "content", cont )
   if *cont :  @"<p>\(cont)</p>"
   _gtp.get( "lng/srchead", aout[0] )
   _gtp.get( "lng/date", date )
   aout[0] += "\l"
//   aout += "Filename|Size|Date|Description\l"
   foreach curgti, gtdir.root()
   {
      str sout src
      str link atext
      finfo fi 
   
      curgti as gtitem
      atext.srcurl( curgti, 2 )
      link.srcurl( curgti, 1 )
      if curgti.find( "nofile" )
      {
          sout = "\( atext )"
      }
      else : sout = "<a href = \"\( link )\">\( atext )</a><br>"
      curgti.getsubitem( "src", src )
      if curgti.find("dir")
      {
         sout += "|&nbsp;|&nbsp;|&nbsp;\l"
      }
      else
      {
         datetime dt
         
         getfileinfo( src, fi )
         ftimetodatetime( fi.lastwrite, dt, 0)
         getdateformat( dt, date, atext ) 
//         getfiledatetime( fi.lastwrite, atext, 0->str )
         sout += "|\(fi.sizelo)|\(atext)|&nbsp;\l"
      }
      aout[0] += sout
   }
   @tbllines( aout )
}\!

text anchors( str in )
\{
   spattern pattern
   uint     off newoff
   
   pattern.init( "\02A Id: ", 0 )
   if ( newoff = pattern.search( in, off )) < *in
   {
      do
      {
         uint end
         str  name
         
         this.append( in.ptr() + off, newoff - off + 1 )
         end = newoff + 6   // must be '\02A Id: <name>' 
         while in[end] > ' ' : end++
         name.substr( in, newoff + 6, end - newoff - 6 )
         this@"<a name=\"\(name)\"></a>"
         off = newoff + 1
         newoff = pattern.search( in, off )
      } while newoff < *in   
      this.append( in.ptr() + off - 1, *in - off + 1 )
   }
   else : @in
}\!

text srcfile( gtitem gti )
<pre><code>\{
   uint flag
   str src in out ext
   
   gti.getsubitem( "src", src )
   ext = src.fgetext()
   switch ext
   {
      case "c", "h" : flag = $S2H_C
      default : flag = $S2H_GENTEE  
   }
   in.read( src )
   out@src2html( in, flag | $S2H_UTF8 | $S2H_LINES )
   @anchors( out )
}</code></pre>\!

text navsrc( gt gtdir, gtitem curgti )
<div class="left-menu">
<div class="lvl l1"><p>&nbsp;&nbsp;&nbsp;<a href="\( 
?( curgti.find("dir"), "../index.htm", "index.htm" ))">..</a></p></div>\{
   foreach gti, gtdir.root()
   {
      str name
      gti as gtitem
    
      name.srcurl( gti, 2 )
      if gti.name %== curgti.name
      {
         @"<div class=\"lvl l1 act\"><p class=\"act\">&nbsp;&nbsp;&nbsp;\( name )</p></div>"
      }
      else
      { 
         if !gti.find("nofile")
         {
            str link
            
            link.srcurl( gti, 1 )
            name = "<a href=\"\(link)\">\( name )</a>"
         }
         @"<div class=\"lvl l1\"><p>&nbsp;&nbsp;&nbsp;\( name )</p></div>"
      }  
   }
}</div>\!


text S_default( gtitem gti )
\{
   gt   gtdir
   uint attrib
   str  src url ed
   str  desc title lang prjname

   _gtp.get( "lng/edit", ed )

   gti.getsubitem( "src", src )
   if !*srcdir
   {
      srcgti = &gti 
      srcdir = src
   } 
   
   attrib = getfileattrib( src )
   if attrib & $FILE_ATTRIBUTE_DIRECTORY
   {
      uint  oldgt = prevsrc
      loadsources( gtdir, src ) 
      attrib = 1
      prevsrc = &gtdir
      foreach fgti, gtdir.root()
      {
         str out filename

         fgti as gtitem
         
         if fgti.find("nofile") : continue
         
         out@S_default( fgti )
         
         filename.srcurl( fgti, 0 )
                           
         if fileupdate( filename, out )
         {
            print("Processing \(fgti.name) => \(filename)\n")
         }
      }
      prevsrc = oldgt     
   }
   else : attrib = 0
   _gtp.prj.get("project/lang", lang )
   _gtp.prj.get("project/name", prjname )
   
/*   gti.getsubitem( "desc", desc )
   if !*desc : desc = "#/title#"

   gti.getsubitem( "keywords", keys )
   if !*keys : keys = "#/title#"
*/   
   title.srcurl( gti, 3 )
   url.srcurl( gti, 1 )
   
}<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/strict.dtd"><html>
<head>
<meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8">
<!--meta http-equiv="Content-Language" content="\( lang )"-->
<meta NAME="DESCRIPTION" CONTENT="\( desc )">
<link rel="icon" href="/favicon.ico" type="image/x-icon"> 
<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon">
<link rel="stylesheet" type="text/css" href="/css/default/styles.css">
<script language="JavaScript1.2" src="/css/ddnmenu.js" type="text/javascript"></script>
<title>\( title )</title></head>
<body>
   \@header( srcgti->gtitem, url )

	<div id="center" >
		<div class="left-column">
\{
   if gti.find( "level" ) :  @navsrc( prevsrc->gt, gti )
}
<!--#include virtual="/adv.php" -->            
		</div>
		<div class="content">
\{
   @grainsrc( gti )
}
			<div class="box"><!--EDIT-->\{ 
         if attrib : @srcdirout( gti, gtdir )
         else : @srcfile( gti )
       }<!--EDIT-->
         </div>
         <a href="/admin/edit.phtml?url=\(url)">\(ed)</a>
		</div>
		<br style="clear:left">
	</div>

<!--#include virtual="/footer.html" -->
</body></html>
\!

