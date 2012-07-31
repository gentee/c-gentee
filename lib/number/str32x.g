/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: num32 20.11.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: 32-based numbers.
*
******************************************************************************/

private

global 
{
   collection  letters = %{ '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 
                            'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L',
                            'M', 'N', 'P', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 
                            'Y', 'Z' }
   arr  num2key key2num
}

public

func  str32x_init< entry >
{
   uint i val
   
   key2num.expand( 256 )
   fornum i, 32
   {
      val = letters[ i ]     
      num2key += val
      key2num[ val ] = i
   }
}

method  uint str.str32x2uint
{
   uint result i
      
   fornum i, *this
   {
      result <<= 5 // —двиг на 5 бит
      result += key2num[ this[ i ]]      
   }    
   return result
}

method  str str.uint2str32x( uint val )
{
   uint  i
      
   this.clear()
   while val
   {
      this.insert( 0, "".appendch( num2key[ val & 31 ] ))
      val >>= 5 // —двиг на 5 бит
   }
   if !*this : this.appendch( num2key[0] )
       
   return this
}
