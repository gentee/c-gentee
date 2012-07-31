//#!gentee.exe "%1"
/******************************************************************************
*
* Copyright (C) 2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS  FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

//include : $"..\stdlib\stdlib.g" 

type srcitem
{
   str    name
   str     summary
   str    title
   ubyte  itype
   str    urlname
   str    list
   str    desc
   str    src
   str    ret
   str    params
   uint   flag
   uint   idfile
   str    related 
}

define
{
   SF_NOPARAM = 0x1   // Function doesn't have parameters
   SF_METHOD = 0x2    // Method
   SF_OPERATOR = 0x4  // Operator
   SF_NOFILE   = 0x8  // No file
   RUSSIAN = 0
}

global
{
   ifdef $RUSSIAN
   {
      str     srcpath = $"k:\gentee\open source\gtdoc\russian\lib"
      str     relpath = $"k:\gentee\open source\srcdoc-ru"
      uint    srcutf = 1
   }
   else
   {
      str     srcpath  = $"k:\gentee\open source\gtdoc\english\lib"
      str     relpath = $"k:\gentee\open source\gentee"
      uint    srcutf
   }
   
   str     savepath = $"k:\gentee\open source\srcdoc"
   hash    hsrc of srcitem
   arrstr  srcfiles
   arrstr  srcout
   arrstr  srclib
}

method str str.replacelgt
{
   if .findch( '<' ) < *this ||
      .findch( '>' ) < *this
   { 
      str stemp
         
      stemp.replacech( this, '<', "&lt;" ) 
      this.replacech( stemp, '>', "&gt;" ) 
   }
   return this
}

include
{ 
//   $"..\..\example\src2html\src2html.g"
   $"..\thread\thread.g"
   $"..\gtpublisher\utils.g"
   "srcout.g"
}

func src_load( str filename )
{
   arrstr  lines
   str     val ext
   uint    i   id

   subfunc str getval( str div )
   {
      val.clear()
      val.copy( lines[i].ptr() + lines[i].findch(':') + 1 )
      while lines[ i + 1 ][0] != '*'
      {
         uint append
         if lines[ i + 1 ][0] == '|'
         {
            lines[ i + 1 ].del( 0, 1 )
            val += "\(lines[ i + 1 ])\l" 
            i++
            continue
         } 
         if val.islast('/')
         {
            append = 1
            val.dellast('/')
            val.trimrspace().appendch(' ')
         }
         else : val += div
         val += lines[ i + 1 ].trimsys()
         i++
      }     
      return val
   }
      
   lines.read( filename )
   ext = filename.fgetext()
   srcfiles += filename
   srcout += ""
   id = *srcout - 1
       
   fornum i, *lines
   {
      arrstr fline
      str    name out  line
      uint   si   first
      
      if !"\02A Id: ".eqlen( lines[i] ) : continue
      first = i - 1
      line = lines[i]
      line.split( fline, ' ', $SPLIT_NOSYS | $SPLIT_QUOTE )
      hsrc[ name = fline[2] ].name = name
      si as hsrc[ name ]
      si.idfile = *srcfiles - 1
      
      if *fline > 3
      { 
         si.itype = fline[3][0]
         si.flag = uint( "0x".append( fline[3].ptr() + 1, *fline[3] - 1 ))
      }
      if *fline > 4 : si.urlname = fline[4]
      
//      print("\(name) = \(hsrc[ name ].urlname)\n")
      if "* Desc: ".eqlen( lines[ i += 2 ] )
      {
         si.desc = getval(" ")
         i++         
      } 
      if "* Summary: ".eqlen( lines[ i ] )
      {
         si.summary = getval(" ")
         i+=2         
      } 
      if "* Title: ".eqlen( lines[ i ] )
      {
         si.title = getval(" ")
         i+=2         
      } 
      if "* List: ".eqlen( lines[ i ] )
      {
         si.list = getval(" ")
         i+=2
      }
      if "* Params: ".eqlen( lines[ i ] )
      {
         si.params = getval("%")
//         print("Params=\( si.params )\n")
         i+=2
      }
      if "* Return: ".eqlen( lines[ i ] )
      {
         si.ret = getval(" ")
         i+=2
      }
      if "* Define: ".eqlen( lines[ i ] )
      {
         si.src = getval(" ")
         i+=2
      }
      while !"----".eqlen( lines[i] ) : i++
      i += 2
      
      if si.itype == 'F' && !*si.src
      {
         if lines[i].findch( '(' ) < *lines[ i ] 
         {
            si.src = lines[i].trimsys()
            while lines[ i ].findch( ')' ) >= *lines[ i ] 
            {
               i++
               si.src += lines[i].trimsys()  
            }
//            print( "\(si.src)\n-----------------------\n")  
         }
         else : si.src = lines[i].trimsys()
      } 
      if si.itype == 'D' || si.itype == 'T' 
      {
         while lines[ i - 1 ][0] != '-' : i--
         while lines[ i ][0] != '/' 
         {
            lines[i].trimsys()
            if *lines[i] : si.src += "\(lines[i])"
            while si.src.islast('/')
            {
               si.src.dellast('/')
               lines[++i].trimsys()
               lines[i].trim( '/', $TRIM_LEFT )  
               si.src += " \(lines[i])"
            }
            si.src += "\l"
            i++  
         }
//         print( "\( si.name ) \(si.src)" )
      }
/*      if si.src.findch( '<' ) < *si.src ||
         si.src.findch( '>' ) < *si.src
      { 
         str stemp
         
         stemp.replacech( si.src, '<', "&lt;" ) 
         si.src.replacech( stemp, '>', "&gt;" ) 
      }*/
      si.src.replacelgt()
      if !*si.urlname
      {
         switch si.itype
         {
            case 'F', 'T'
            {
               si.urlname = si.name
            }  
         } 
      }
      if !*si.desc
      {
         si.desc = si.summary
         si.desc.setlen( si.summary.findch('.') + 1 )
      }
      while first <= i
      {
         srcout[id] += "\(lines[ first++ ])\l"         
      }
   }   
}

func srccommon
{
   str out
   str src
   
   out = "<common>\l"
   foreach cur, hsrc 
   {
      uint id next
      
      if !*cur.related : continue
      src.replacech( srcfiles[cur.idfile], '\', "/" )
      src.del( 0, *relpath + 1 )
      out +="<\(cur.name)>
         <related>\( cur.related )</>
         <source>\( src )#\(cur.name)"
      while next = hsrc.find("\(cur.name)_\(++id)")
      {
         next as srcitem
         src.replacech( srcfiles[next.idfile], '\', "/" )
         src.del( 0, *relpath + 1 )
         out += "|\( src )#\(next.name)"
      } 
      out += "</>
</>\l"
//         <require>Library|-</>
   }      
   out += "</common>\l"
   out.write( "\(srcpath)\\common.gt")   
}

func srcmenu
{
   str out
   str src
   arrstr libs
   
   out = "<menu><doc><lib>\l"
   foreach cur, hsrc 
   {
      if !*cur.list : continue
      libs += cur.name 
   }
   libs.sort( 0 )
   foreach curl, libs 
   {
      uint   i skipmode
      arrstr  li
      uint    cur
      
      cur as hsrc[ curl ]
      
      if !*cur.list : continue
      out@"<\(cur.name)>\l"
      cur.list.split( li, ',', $SPLIT_NOSYS )
      fornum i, *li
      {
         if li[i][0] == '*'
         { 
            skipmode = ( li[i][1] == '@' )  
            continue
         }
         if skipmode : continue
         out@"<\( hsrc[ li[i]].name ) />\l"
      } 
      out@"</>\l"
   }      
   out += "</></></menu>\l"
   out.write( "\(srcpath)\\menu.gt")   
}

func srcsave
{
   uint i
   
   fornum i, *srcfiles
   {
      str  filename
      if !*srcout[i] : continue
      filename = srcfiles[i]
      filename.replace( 0, *relpath, savepath )
   
      if fileupdate( filename, srcout[i] )
      {
         print("Copy \(filename)\n")
      }
   }
}

func src2gt<main>
{
   ffind fd
   
   arrstr filelist = %{ $"src\genteeapi\*.*", $"src\compiler\compile.*",
                        $"src\vm\vmrun.c",$"src\vm\vmtype.c", 
                        $"src\common\*.c",$"src\vm\vm.c",
                        $"lib\stdlib\*.g",$"lib\tree\tree.g",
                        $"lib\dbf\*.g",$"lib\thread\thread.g",
                        $"lib\ini\ini.g",$"lib\registry\registry.g",
                        $"lib\odbc\*.g", $"lib\csv\csv.g",
                        $"lib\xml\*.g", $"lib\olecom\*.g",
                        $"lib\clipboard\*.g",$"lib\keyboard\*.g",
                        $"lib\socket\*.g",
                        $"lib\ftp\*.g",$"lib\http\*.g" }
   
   foreach curfile, filelist
   {
      fd.init( "\(relpath)\\\(curfile)", 
             $FIND_FILE | $FIND_DIR | $FIND_RECURSE )
      foreach cur, fd
      {
         print("Source:\(cur.fullname)\n")
         src_load( cur.fullname )
      }
   }
   srcoutfunc()
   srccommon()
   srcmenu()
   if !srcutf : srcsave()
   print("Press any key...")
   Sleep( 3000 )
//   getch()
}