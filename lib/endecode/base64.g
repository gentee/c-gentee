/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

func uint enbase64( uint u )
{
  if u < 26 : return 'A' + u
  if u < 52 : return 'a' + ( u-26 )
  if u < 62 : return '0' + ( u-52 )
  if u == 62 : return '+'
  
  return '/'
}

func uint debase64( uint c ) 
{
  if c >= 'A' && c <= 'Z' : return c - 'A'
  if c >= 'a' && c <= 'z' : return c - 'a' + 26
  if c >= '0' && c <= '9' : return c - '0' + 52
  if c == '+' : return 62
  
  return 63
}

func uint isbase64( uint c )
{
   if (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ||
     (c >= '0' && c <= '9') || (c == '+')             ||
     (c == '/')             || (c == '=')
   {
      return 1
   }
   return 0
}

method str str.tobase64( str input )
{
   uint size i
   
   this.clear()
   
   size = *input
   
   this.reserve( size * 4 / 3 + 4 )
        
   for i=0, i<size, i+=3
   {
      uint  b1 b2 b3 b4 b5 b6 b7
      
      b1 = input[i]
      
      if i+1 < size : b2 = input[i+1]
      
      if i+2 < size : b3 = input[i+2]
      
      b4 = b1>>2
      b5 = ((b1&0x3)<<4)|(b2>>4)
      b6 = ((b2&0xf)<<2)|(b3>>6)
      b7 = b3&0x3f
      
      this.appendch( enbase64( b4 ))
      this.appendch( enbase64( b5 ))
      
      if i+1 < size : this.appendch( enbase64( b6 ))
      else : this.appendch( '=' )
      
      if i+2 < size : this.appendch( enbase64( b7 ))
      else : this.appendch( '=' )
   }
   return this
}

method str str.frombase64( str input ) 
{
   str stemp
   uint k l
   
   this.clear()
   
   if !*input : return this

   this.reserve( *input + 4 )
   stemp.reserve( *input + 1 )     
   fornum k, *input
   {
      if isbase64( input[k] ) : stemp[l++] = input[k]
   } 
   stemp.setlen( l )
       
   for k=0, k<l, k+=4
   {
      uint c1='A', c2='A', c3='A', c4='A'
      uint b1 b2 b3 b4
      
      c1 = stemp[ k ]
      
      if k+1 < l : c2 = stemp[ k+1 ]
      if k+2 < l : c3 = stemp[ k+2 ]
      if k+3 < l : c4 = stemp[ k+3 ]
      b1= debase64(c1)
      b2= debase64(c2)
      b3= debase64(c3)
      b4= debase64(c4)
      
      this.appendch( (b1<<2)|(b2>>4) )
      
      if c3 != '=' : this.appendch( ((b2&0xf)<<4)|(b3>>2) )
      if c4 != '=' : this.appendch( ((b3&0x3)<<6)|b4 )
   }
   return this
}
