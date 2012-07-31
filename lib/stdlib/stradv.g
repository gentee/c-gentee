/******************************************************************************
*
* Copyright (C) 2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

/*-----------------------------------------------------------------------------
* Id: str_replace_1 FA
* 
* Summary: The method looks for strings from one array and replace to strings 
           of another array. 
* 
* Params: aold - The strings to be replaced. 
          anew - The new strings. 
          flags - Flags. $$[patternflags] 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str  str.replace( arrstr aold, arrstr anew, uint flags )
{
   uint i cur ok end
   uint count = *aold
   arr  pat[ count ] of spattern
   arr  off[ count ]
   str  ret
   
   if !count : return this
   
   fornum i, count : pat[i].init( aold[i], flags )
   end = *this 
   while cur < end
   {   
      uint ioff
      fornum i = 0, count
      {
         if off[i] <= cur : off[i] = pat[i].search( this, cur )
         if off[i] < off[ ioff ] : ioff = i
//         print("\(i)=\(off[i])\n") 
      }
      ret.append( this.ptr() + cur, off[ ioff ] - cur )
      cur += off[ ioff ] - cur
      if off[ ioff ] < end
      {
//         print( "Find \(off[ ioff ]) \(end)\n")
         ret.append( anew[ ioff ].ptr(), *anew[ ioff ] )
         cur += *aold[ ioff ]
         ok = 1
      }
   }   
   if ok : this = ret
    
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_replace_2 FA
* 
* Summary: The method replaces one string to another string in the source
           string. 
* 
* Params: sold - The string to be replaced. 
          snew - The new string. 
          flags - Flags. $$[patternflags] 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str  str.replace( str sold, str snew, uint flags )
{
   uint cur ok end
   spattern pat
   uint off
   str  ret
   
   pat.init( sold, flags )
   end = *this 
   while cur < end
   {   
      uint ioff
      
      off = pat.search( this, cur )
      ret.append( this.ptr() + cur, off - cur )
      cur += off - cur
      if off < end
      {
         ret.append( snew.ptr(), *snew )
         cur += *sold
         ok = 1
      }
   }   
   if ok : this = ret
    
   return this
}

/*-----------------------------------------------------------------------------
* Id: arrstr_replace F2
* 
* Summary: Replace substrings for the each item. The method looks for 
           strings from one array and replace to strings 
           of another array for the each string of the array. 
* 
* Params: aold - The strings to be replaced. 
          anew - The new strings. 
          flags - Flags. $$[patternflags] 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method arrstr  arrstr.replace( arrstr aold, arrstr anew, uint flags )
{
   foreach cur, this : cur.replace( aold, anew, flags )
   return this
}
