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

extern : func srcitemout( str name, arrstr group, srcitem owner ) 

func defout( str def )
{
   arrstr  lines
   uint    i
   
   lines.loadtrim( hsrc[def].src )
   def.clear()
   fornum i, *lines
   {
      arrstr subit
      uint   off
      str    comment
      
      off = lines[i].findch( '/' )
      comment.copy( lines[i].ptr() + off + 2 )
      comment.trimsys()
       
      if lines[i][0] == '#'
      {
         lines[i].split( subit, ' ', $SPLIT_NOSYS )
         def += "\(subit[1])|\(comment)\l"   
      }
      elif lines[i].findch('=') < *lines[i]
      {
         lines[i].split( subit, '=', $SPLIT_NOSYS )
         def += "$\(subit[0])|\(comment)\l"   
      }
      else
      {
         lines[i].split( subit, ' ', $SPLIT_NOSYS )
         if *subit : def += "$\(subit[0])|\(comment)\l"   
      }
   }
}

text src2api( srcitem si )
<div class="box-code"><div>
\{
   str  head
   uint left right
   left = si.src.findch( ?( si.itype == 'F', '(', '{' ))
   if si.flag & $SF_NOPARAM : right = left = *si.src  
   else : right = si.src.findch(?( si.itype == 'F', ')', '}' ))
   
   if si.itype == 'F' 
   {
      head.copy( si.src.ptr(), left ) 
      @"<span class=\"key-words\">\(head)</span>"
      if left < right
      {
         str pars
         arrstr items
         uint   i
      
         @"&nbsp;(#br#"
         pars.substr( si.src, left + 1, right - left - 1 )
         pars.split( items, ',', $SPLIT_NOSYS )
         fornum i, *items
         {
            arrstr  subit
            items[i].split( subit, ' ', $SPLIT_NOSYS | $SPLIT_FIRST )
            if *subit > 1
            {
               @"&nbsp;&nbsp;&nbsp;<span class=\"key-words\">\(subit[0])</span> <span class=\"var\">\(subit[1])\( ?( i== *items - 1, "", ","))</span><br>\l"
            }
            else
            {
               @"&nbsp;&nbsp;&nbsp;<span class=\"key-words\">&nbsp;</span> <span class=\"var\">\(subit[0])\( ?( i== *items - 1, "", ","))</span><br>\l"
            }
         }
         @")"
      }
   }
   if si.itype == 'T' 
   {
      head.copy( si.src.ptr(), left ) 
      @"<span class=\"key-words\">\(head)</span>#br#"
      if left < right
      {
         str pars more
         arrstr items
         uint   i
      
         @"{#br#"
         pars.substr( si.src, left + 1, right - left - 1 )
         more.substr( si.src, right + 1, *si.src - right - 1 )
         items.loadtrim( pars )
         fornum i, *items
         {
            arrstr  subit
            uint    off
            items[i].split( subit, ' ', $SPLIT_NOSYS )
            off = items[i].findch('/')
            
            if *subit > 1
            {
               str  comment
               comment.substr( items[i], off + 2, *items[i] - off - 2 )
               @"&nbsp;&nbsp;&nbsp;<span class=\"key-words\">\(subit[0])</span> <span class=\"var\">\(subit[1])</span><br>\l"
               si.params += "\(subit[1].dellast(';'))-\(comment)%"
            }
         }
         @"} <span class=\"key-words\">\(more)</span>"
      }
   }
}</div></div>\!

func str replacelinks( str input )
{
   uint off
   
   while ( off = input.findchfrom('$', off )) < *input
   {
      uint end
      str  def

      end = input.findchfrom(']', off )
         
      if input[ off + 1 ] == '$'
      { 
         def.substr( input, off + 3, end - off - 3 )
         defout( def )
         input.replace( off, end -  off + 1, "#tblparam[\(def)]" )
      }
      elif input[ off + 1 ] == '['
      {
         def.substr( input, off + 2, end - off - 2 )
         input.replace( off, end -  off + 1, "#a[\(def)]" )
      } 
      elif input[ off + 1 ] == '#'
      {
         input.replace( off, 2, "\l" )
      }
      off += 2     
   }
   return input
}

text gttitle( srcitem si )
\{
   str ret
   
   if *si.title
   { 
      ret@si.title
   }
   elif si.flag & $SF_NOFILE && !( si.flag & $SF_OPERATOR ) 
   {
      uint off off1 = si.src.findch( '&' ) 
      uint off2 = si.src.findch( '(' )
      
      off = min( off1, off2 )
      off1 = off - 1
      while si.src[off1]!= ' ' : off1--
      ret.substr( si.src, off1 + 1, off - off1 - 1 )
   }
   elif si.flag & $SF_METHOD
   {
      str stemp = si.name 
      
      stemp[ stemp.findch('_') ] = '.'
      ret@stemp      
   }
   elif si.flag & $SF_OPERATOR
   {
      str  oper param left right
      uint off off1 = si.src.findch( '&' ) 
      uint off2 = si.src.findch( '(' )
      arrstr  pars 
      
      off = min( off1, off2 )
      while si.src[off-1]== ' ' : off--
      off1 = off - 1
      while si.src[off1]!= ' ' : off1--
      oper.substr( si.src, off1 + 1, off - off1 - 1 )
      param.substr( si.src, off2 + 1, *si.src - 2 )
      param.split( pars, ',', $SPLIT_NOSYS )
      if *pars == 2
      {
         left.substr( pars[0], 0, pars[0].findch(' '))
         right.substr( pars[1], 0, pars[1].findch(' '))
      } 
      elif *pars == 1
      {
         right.substr( pars[0], 0, pars[0].findch(' '))
      } 
      ret@"\(left) \(oper) \(right)"
   } 
   else : ret@si.urlname
   @ret.replacelgt()
}\!

text gtoutput( srcitem si )
\{
   arrstr li lig
   
   subfunc groupout( str out )
   {
      uint  i
      uint skipmode
      
      if !*lig : return
      out@"#apilist["
      fornum i = 0, *lig
      {
         if lig[i][0] == '*'
         {
            skipmode = ( lig[i][1] == '@' )
            continue
         }
         if !skipmode : srcitemout( lig[i], lig, si )
         out@"\(lig[i])\l"         
      }
      out@"]"
      lig.clear()
   }
}<\(si.name) style=RH nop>
   <title = "\@gttitle( si )" />
   <desc>\(replacelinks( si.desc ))</>
   <content >
\{
   str  funcout
   uint id cursi
   arrstr links
   
   cursi as si
   while cursi
   {   
      if id
      { 
         str stitle
         stitle@gttitle( cursi )
         funcout@"<a name=\(cursi.name)></a>#hr##h2[ \( stitle ) ]"
      }
      links += "#a(\"#\(cursi.name)\", \"\(cursi.src)\")"
      funcout@"#p[\( replacelinks( cursi.summary ) )]"

      if *cursi.src : funcout@src2api( cursi )
      if *cursi.params
      {
         arrstr  items
         uint    off
      
         replacelinks( cursi.params )
         cursi.params.split( items, '%', $SPLIT_NOSYS )
         funcout@"<div class=\"box-no-bord\">#h2( #lng/\(?( cursi.itype == 'F',
                  "pars", "members" ))# )
<table cellpadding=\"0\" class=\"descript\" width=100%><col width=\"12%\">"
         foreach cur, items
         {
            arrstr subit
         
            cur.split( subit, '-', $SPLIT_FIRST | $SPLIT_NOSYS )
		      funcout@"<tr><td><span class=\"var\">\( subit[0] )</span></td>
					<td><span>\( subit[1] )</span></td></tr>" 
         }
         funcout@"</table></div>"
      }
      if *cursi.ret
      {
         replacelinks( cursi.ret )
         funcout@"<div class=\"box-no-bord\">#h2( #lng/return# )#p[\(cursi.ret
               )]</div>"
      }
      cursi as hsrc.find("\(si.name)_\(++id)") 
//      cursi as 
   }
   if *links > 1
   {
      @"#p[<ul>"
      fornum id = 0, *links
      {      
         @"<li>\(links[id])</li>"
      }
      @"</ul>]"
   }
   @funcout   
   if *si.list
   { 
      uint   i id
      str    head out
      arrstr heads
      
      si.list.split( li, ',', $SPLIT_NOSYS )
      fornum i, *li
      {
         if li[i][0] == '*'
         { 
            groupout( out )
            head.copy( li[i].ptr() + 1 + ?( li[i][1] == '@', 1, 0 ))
            if *head
            { 
               out@"<a name=\"id\(id++)\"></a>#h2( \(head) )"
               heads += head
            }
            head.clear()
         }
         lig += li[i]   
      } 
//      if *head : @"#h2( \(head) )\l"
      groupout( out )
      if *heads
      {
         @"<p><ul>"
         fornum id = 0, *heads
         {
            @"<li><a href=\"#id\(id)\">\(heads[id])</a></li>"
         }         
         @"</ul></p>&nbsp;<br>"
      }
      @out
   }
}
   </>
</>\! 

func srcfileout( str filename, srcitem si )
{
   str out
   ustr  uout
   
   if si.flag & $SF_NOFILE : return
   if !*si.name 
   {
      print("Empty name...")
      getch()
   }
   out@gtoutput( si )
   if !srcutf
   {
      uout = out
      uout.toutf8( out )
//      out.insert( 0, "﻿" )
   }
   if fileupdate( filename, "﻿" += out )
   {
      filename.del( 0, *srcpath + 1 )
      print("Processing \(si.name) => \(filename)\n")
   }
}

func srcitemout( str name, arrstr group, srcitem owner )
{
   str     filename
   uint    si
      
   si as hsrc[ name ]
   filename = "\(srcpath)\\\(owner.name)\\\(si.name).gt"
   si.related += "\(owner.name)|"
   srcfileout( filename, si )
}

func srcoutfunc
{
   foreach curitem, hsrc
   {
      str out filename
      
      if curitem.itype != 'L' : continue
      
      filename = "\(srcpath)\\\(curitem.name)\\index.gt"
      srcfileout( filename, curitem )
   }
}