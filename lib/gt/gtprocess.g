/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gtprocess 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: This program creates tables for lexical analizer. It gets a
  description in gt format and generate .g and *.c sourse files with the
  according lexical tables.
*
******************************************************************************/

//include : "lexgtdo.g"

define
{
   gt_OUTPUT  = 0   // Output items as it
   gt_TEST    = 1   // Try to detect macro
   gt_SKIP    = 2   // Skip the output after procfail
}

method str gtitem.process( str in ret, arrstr pars )
{
   uint    off start prev mode initoff end
   arrout  out
//   lex     ilex
//   uint    lex
   uint    curgti last quotes calltext 
   str     value
   arrstr  params

   subfunc procfail
   {
      mode = $gt_SKIP
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
         this.process( pars[i], stemp, 0->arrstr )
         pars[i] = stemp        
      }
   }
   
   out.isize = sizeof( lexitem )
//   lex = lex_init( 0, lexgtdo_.ptr())
//   gentee_lex( in->buf, lex, out )
//   gentee_lex( in->buf, this.maingt->gt.lexdo, out )
   gentee_lex( &in, this.maingt->gt.lexdo, &out )
   
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
            if mode == $gt_TEST : procfail()
         }   
         case $GTDO_HEX 
         {
            if mode == $gt_TEST : procfail()
            else
            {
               ret.appendch( uint( "0x".append( start + li.pos + 2, 
                                       li.len - 3 )))
               goto ok         
            }
         }
         case $GTDO_PAR
         {
            if mode == $gt_TEST : procfail()
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
            if mode == $gt_TEST
            {
               if prev == $GTDO_SIGN : procfail()
               else
               { 
                  mode = $gt_OUTPUT
                  if calltext
                  {
                     str  stemp
                     
                     stemp @ calltext->func( params )
                     params.clear()
                     curgti->gtitem.process( stemp, ret, params )
                     calltext = 0
                  }
                  else
                  {
                     curgti->gtitem.process( value, ret, params )
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
               curgti as this 
               mode = $gt_TEST
               goto ok
            } 
         }
      }
      if mode == $gt_TEST
      {
         switch li.ltype
         {
            case $GTDO_NAME
            {
               str name 
                     
               name.copy( start + li.pos, li.len )
               if prev == $GTDO_DOT
               {
                  if curgti->gtitem.find( name )
                  {
                     curgti->gtitem.get( name, value )
                     goto ok 
                  }
               }
               elif prev == $GTDO_SIGN // ? было prev = $gtDO
               {
                  uint it
                  it = &curgti->gtitem.findrel( name )
                  
                  if it
                  {
                     curgti = it
                     value = curgti->gtitem.value
                     goto ok 
                  }
                  else
                  {
                     if calltext = getid( name, 0, %{ arrstr } )
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
                  mode = $gt_OUTPUT
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
                     curgti->gtitem.process( stemp, ret, params )
                     calltext = 0
                  }
                  else
                  {
                     curgti->gtitem.process( value, ret, params )
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
               
               mode = $gt_OUTPUT
//               print("value =\(value) \( *params )\n")
               if calltext
               {
                  str  stemp
                  stemp @ calltext->func( params )
                  params.clear()
                  curgti->gtitem.process( stemp, ret, params )
                  calltext = 0
               }
               else
               {
                  curgti->gtitem.process( value, ret, params )
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
      if mode == $gt_OUTPUT 
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
                  curgti->gtitem.process( val, ret, pars )
                  calltext = 0
               }
               else
               {*/
               if li.ltype == $GTDO_PARSTEXT
               {
                  val.trimsys()  
               } 

                  curgti->gtitem.process( val, ret, pars )
//               }             
            }
            default 
            {
               ret.append( start + li.pos, li.len )
            }
         }  
      }
      elif mode == $gt_SKIP : mode = $gt_OUTPUT 
      label ok
      prev = li.ltype
      off += sizeof( lexitem )            
   }
   return ret   
}

method ustr gtitem.process( ustr in ret, arrstr pars )
{
   str  stemp  sret
   
   in.toutf8( stemp )
   this.process( stemp, sret, pars )
   return ret = sret
}

method str gt.process( str in )
{
   str    stemp
   arrstr pars
   
   this.root().process( in, stemp, pars )
   return in = stemp
}

