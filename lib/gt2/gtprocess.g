/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gt2process 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: This program creates tables for lexical analizer. It gets a
  description in gt2 format and generate .g and *.c sourse files with the
  according lexical tables.
*
******************************************************************************/

//include : "lexgt2do.g"
 
method  str str.trimrsys
{
   uint  ptr = this.ptr() 
   uint  end = ptr + *this
   
   while ( end - 1 )->byte <= ' ' && ptr < end : end-- 

   this.setlen( end - ptr )
   return this
}

define
{
   gt2_OUTPUT  = 0   // Output items as it
   gt2_TEST    = 1   // Try to detect macro
   gt2_SKIP    = 2   // Skip the output after procfail
}
/*
method str gt2item.process( str in ret, arr pars of str )
{
   uint    off start prev mode initoff end
   arrout  out
//   lex     ilex
   uint    curgt2i last quotes
   str     value
   arr     params of str

   subfunc procfail
   {
      mode = $gt2_SKIP
      while initoff < off
      {
         uint  li 
      
         li as initoff->lexitem
         
         ret.append( start + li.pos, li.len )   
         
         initoff += sizeof( lexitem )  
      }
      off -= sizeof( lexitem )      
   }
   if &pars && *pars
   {
      uint i 
      fornum i, *pars
      {
         str stemp
         this.process( pars[i], stemp, 0->arr )
         pars[i] = stemp        
      }
   }
   
   out.isize = sizeof( lexitem )
//   lex_tbl( ilex, lexgt2do.ptr())
//   gentee_lex( in->buf, ilex, out )
   gentee_lex( in->buf, this.maingt2->gt2.lexdo, out )

   off = out.data.ptr()
   start = in.ptr()
   end = out.data.ptr() + *out * sizeof( lexitem )
   while off < end
   {
      uint  li 
      
      li as off->lexitem
//      print("TYpe = \( hex2stru("", li.ltype )) Off=\(li.pos) len = \(li.len)\n")
      switch li.ltype
      {
         case $gt2DO_TEXT
         { 
            if mode == $gt2_TEST : procfail()
         }   
         case $gt2DO_HEX 
         {
            if mode == $gt2_TEST : procfail()
            else
            {
               ret.appendch( str2int( "0x".append( start + li.pos + 2, 
                                       li.len - 3 )))
               goto ok         
            }
         }
         case $gt2DO_PAR
         {
            if mode == $gt2_TEST : procfail()
            else
            {
               uint par = uint( "".copy( start + li.pos + 2, 
                                       li.len - 3 )) - 1
               if &pars && par < *pars : ret += pars[ par ]
               goto ok
            }   
         }
         case $gt2DO_SIGN
         {
            if mode == $gt2_TEST
            {
               if prev == $gt2DO_SIGN : procfail()
               else
               { 
                  mode = $gt2_OUTPUT
                  curgt2i->gt2item.process( value, ret, params )
                  goto ok
//                  print("value =\(value)\n ret=\(ret)\n")
               }  
            }
            else
            {
               params.clear()
               value.clear()
               initoff = off
               curgt2i as this 
               mode = $gt2_TEST
               goto ok
            } 
         }
      }
      if mode == $gt2_TEST
      {
         switch li.ltype
         {
            case $gt2DO_NAME
            {
               str name 
                     
               name.copy( start + li.pos, li.len )
               if prev == $gt2DO_DOT
               {
                  if curgt2i->gt2item.find( name )
                  {
                     curgt2i->gt2item.get( name, value )
                     goto ok 
                  }
               }
               elif prev = $gt2DO_SIGN
               {
                  uint it
                  it = &curgt2i->gt2item.findrel( name )
                  
                  if it
                  {
                     curgt2i = it
                     value = curgt2i->gt2item.value
                     goto ok 
                  }  
               }     
               procfail()
            }
            case $gt2DO_DOT
            {
               if prev != $gt2DO_NAME && prev != $gt2DO_SIGN : procfail()
            }
            case $gt2DO_LP
            {
               if prev == $gt2DO_NAME
               {
                  last = 0
                  params += ""
                  goto ok                
               }
               procfail()
            }
            case $gt2DO_PARTEXT//, $gt2DO_COLONTEXT
            {
//               print("COLON \( li.pos ) \( li.len )\n") 
               params[ last ].append( start + li.pos, li.len )
               quotes = 0
            } 
            case $gt2DO_COMMA
            {
               if prev == $gt2DO_SPACE && !quotes : params[ last ].trimrsys()
               params += ""
               last++
            } 
            case $gt2DO_SPACE
            {
               if *params[ last ] && !quotes
               { 
                  params[ last ].append( start + li.pos, li.len )
               }                
            } 
            case $gt2DO_RP
            {
               if prev == $gt2DO_SPACE && !quotes : params[ last ].trimrsys()
               
               mode = $gt2_OUTPUT
               curgt2i->gt2item.process( value, ret, params )
               goto ok
            } 
            case $gt2DO_DQ, $gt2DO_Q
            {
               if *params[ last ]
               { 
                  params[ last ].append( start + li.pos, li.len )
               }
               else : params[ last ].copy( start + li.pos + 1, li.len - 2 )
               quotes = 1
            }
         }
      }
      if mode == $gt2_OUTPUT 
      {
         switch li.ltype
         {
            case $gt2DO_Q, $gt2DO_DQ, $gt2DO_PARTEXT//, $gt2DO_COLONTEXT
            {
               str  val
               val.append( start + li.pos, li.len )
               curgt2i->gt2item.process( val, ret, 0->arr )             
            }
            default 
            {
               ret.append( start + li.pos, li.len )
            }
         }  
      }
      elif mode == $gt2_SKIP : mode = $gt2_OUTPUT 
      label ok
      prev = li.ltype
      off += sizeof( lexitem )            
   }
   return ret   
}
*/

method str gt2item.process( str in ret, arr pars of str )
{
   uint    off start prev mode initoff end
   arrout  out
//   lex     ilex
//   uint    lex
   uint    curgt2i last quotes calltext 
   str     value
   arr     params of str

   subfunc procfail
   {
      mode = $gt2_SKIP
      while initoff < off
      {
         uint  li 
      
         li as initoff->lexitem

         ret.append( start + li.pos, li.len )   
         initoff += sizeof( lexitem )  
      }
      off -= sizeof( lexitem )      
   }
   if &pars && *pars
   {
      uint i 
      fornum i, *pars
      {
         str stemp
         this.process( pars[i], stemp, 0->arr )
         pars[i] = stemp        
      }
   }
   
   out.isize = sizeof( lexitem )
//   lex = lex_init( 0, lexgt2do_.ptr())
//   gentee_lex( in->buf, lex, out )
   gentee_lex( in->buf, this.maingt2->gt2.lexdo, out )

   off = out.data.ptr()
   start = in.ptr()
   end = out.data.ptr() + *out * sizeof( lexitem )
   while off < end
   {
      uint  li 
      
      li as off->lexitem
//      print("TYpe = \( hex2stru("", li.ltype )) Off=\(li.pos) len = \(li.len)\n")
     
      switch li.ltype
      {
         case $GTDO_TEXT
         { 
            if mode == $gt2_TEST : procfail()
         }   
         case $GTDO_HEX 
         {
            if mode == $gt2_TEST : procfail()
            else
            {
               ret.appendch( str2int( "0x".append( start + li.pos + 2, 
                                       li.len - 3 )))
               goto ok         
            }
         }
         case $GTDO_PAR
         {
            if mode == $gt2_TEST : procfail()
            else
            {
               uint par = uint( "".copy( start + li.pos + 2, 
                                       li.len - 3 )) - 1
               if &pars && par < *pars : ret += pars[ par ]
               goto ok
            }   
         }
         case $GTDO_SIGN
         {
            if mode == $gt2_TEST
            {
               if prev == $GTDO_SIGN : procfail()
               else
               { 
                  mode = $gt2_OUTPUT
                  if calltext
                  {
                     str  stemp
                     
                     stemp @ calltext->func( params )
                     params.clear()
                     curgt2i->gt2item.process( stemp, ret, params )
                     calltext = 0
                  }
                  else
                  {
                     curgt2i->gt2item.process( value, ret, params )
                  }
                  goto ok
               }  
            }
            else
            {
               params.clear()
               value.clear()
               initoff = off
               calltext = 0
               curgt2i as this 
               mode = $gt2_TEST
               goto ok
            } 
         }
      }
      if mode == $gt2_TEST
      {
         switch li.ltype
         {
            case $GTDO_NAME
            {
               str name 
                     
               name.copy( start + li.pos, li.len )
               if prev == $GTDO_DOT
               {
                  if curgt2i->gt2item.find( name )
                  {
                     curgt2i->gt2item.get( name, value )
                     goto ok 
                  }
               }
               elif prev == $GTDO_SIGN // ? было prev = $gt2DO
               {
                  uint it
                  it = &curgt2i->gt2item.findrel( name )
                  
                  if it
                  {
                     curgt2i = it
                     value = curgt2i->gt2item.value
                     goto ok 
                  }
                  else
                  {
                     if calltext = getid( name, %{ arr } )
                     {
//                        value @ calltext->func( params )
//                        calltext = 0
                        goto ok
                     }
                  }  
               }     
               procfail()
            }
            case $GTDO_DOT
            {
               if prev != $GTDO_NAME && prev != $GTDO_SIGN : procfail()
            }
            case $GTDO_LP, $GTDO_LSP
            {
               if prev == $GTDO_NAME
               {
                  last = 0
                  params += ""
                  goto ok                
               }
               procfail()
            }
            case $GTDO_COLON, $GTDO_PARCALL
            {
               if prev == $GTDO_NAME
               {
                  mode = $gt2_OUTPUT
                  params.clear()
                  if li.ltype == $GTDO_COLON
                  {  
                     last = 0
                     params += ""
                     params[ last ].append( start + li.pos + 1, li.len - 1 )
                     params[ last ].trimsys()
                  }
                  else
                  {
                     foreach cur, pars : params += cur
                  }
                  if calltext
                  {
                     str  stemp
                     stemp @ calltext->func( params )
                     params.clear()
                     curgt2i->gt2item.process( stemp, ret, params )
                     calltext = 0
                  }
                  else
                  {
                     curgt2i->gt2item.process( value, ret, params )
                  }
                  goto ok                
               }
               procfail()
            }
            case $GTDO_PARTEXT, $GTDO_PARSTEXT
            {
               params[ last ].append( start + li.pos, li.len )
               if li.ltype == $GTDO_PARSTEXT
               {
                  params[ last ].trimsys()  
               } 
               quotes = 0
            } 
            case $GTDO_COMMA
            {
               if prev == $GTDO_SPACE && !quotes : params[ last ].trimrsys()
               params += ""
               last++
            } 
            case $GTDO_SPACE
            {
               if *params[ last ] && !quotes
               { 
                  params[ last ].append( start + li.pos, li.len )
               }                
            } 
            case $GTDO_RP,$GTDO_RSP
            {
               if prev == $GTDO_SPACE && !quotes : params[ last ].trimrsys()
               
               mode = $gt2_OUTPUT
//               print("value =\(value) \( *params )\n")
               if calltext
               {
                  str  stemp
                  stemp @ calltext->func( params )
                  params.clear()
                  curgt2i->gt2item.process( stemp, ret, params )
                  calltext = 0
               }
               else
               {
                  curgt2i->gt2item.process( value, ret, params )
               }
               goto ok
            } 
            case $GTDO_DQ, $GTDO_Q
            {
               if *params[ last ]
               { 
                  params[ last ].append( start + li.pos, li.len )
               }
               else : params[ last ].copy( start + li.pos + 1, li.len - 2 )
               quotes = 1
            }
         }
      }
      if mode == $gt2_OUTPUT 
      {
         switch li.ltype
         {
            case $GTDO_Q, $GTDO_DQ, $GTDO_PARTEXT, $GTDO_PARSTEXT
            {
               str  val
               val.append( start + li.pos, li.len )
/*               if calltext
               {
                  ret @ calltext->func( pars )
                  curgt2i->gt2item.process( val, ret, pars )
                  calltext = 0
               }
               else
               {*/
               if li.ltype == $GTDO_PARSTEXT
               {
                  val.trimsys()  
               } 

                  curgt2i->gt2item.process( val, ret, pars )
//               }             
            }
            default 
            {
               ret.append( start + li.pos, li.len )
            }
         }  
      }
      elif mode == $gt2_SKIP : mode = $gt2_OUTPUT 
      label ok
      prev = li.ltype
      off += sizeof( lexitem )            
   }
   return ret   
}
