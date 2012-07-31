/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

define <export>{
/*-----------------------------------------------------------------------------
* Id: patternflags D
* 
* Summary: Flags for spattern.init method.
*
-----------------------------------------------------------------------------*/
   QS_IGNCASE  =  0x0001   // Case-insensitive search.
   QS_WORD     =  0x0002   // Search the whole word only.
   QS_BEGINWORD = 0x0004   // Search words which start with the specified /
                           // pattern.
   
//-----------------------------------------------------------------------------  
}

/*-----------------------------------------------------------------------------
* Id: spattern T 
* 
* Summary: The pattern structure for the searching. The spattern type is used 
           to search through the string for another string. Don't change 
           the fields of the spattern strcuture. The spattern variable
           must be initialized with #a(spattern_init) method.
*
-----------------------------------------------------------------------------*/

type spattern
{ 
   uint      pattern             // Hidden data.
   uint      size                // The size of the pattern.
   reserved  shift[1024]         // Hidden data. 
   uint      flag                // Search flags.
}

/*-----------------------------------------------------------------------------
* Id: spattern_init F2
*
* Summary: Creating data search pattern. Before search start-up, call this
           method in order to initialize the search pattern. Then do a search 
           of the specified pattern with #a( spattern_search ).  
*  
* Params: pattern - Search string (pattern). 
          flag - Search flags.$$[patternflags]  
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method  spattern spattern.init( buf pattern, uint flag )
{
   qs_init( &this, pattern.ptr(), *pattern, flag )
   return this
}

/*-----------------------------------------------------------------------------
* Id: spattern_search F2
*
* Summary: Search a pattern in another string. Before search start-up, call the
           #a( spattern_init ) method in order to initialize the search 
           pattern. 
*  
* Params: src - String where the specified string will be searched (search /
                pattern). 
          offset - Offset where the search must be started or proceeded. 
* 
* Return: The offset of the found fragment. If the offset is equal to string
          size,no fragment is found. 
*
-----------------------------------------------------------------------------*/

method  uint spattern.search( buf src, uint offset )
{
   return offset + qs_search( &this, src.ptr() + offset, 
                              *src - offset ) 
}

/*-----------------------------------------------------------------------------
* Id: spattern_search_1 FA
*
* Summary: Search a pattern in a memory data. 
*  
* Params: ptr - The pointer to the memory data where the pattern will be /
                searched. 
          size - The size of the memory data. 
* 
* Return: The offset of the found fragment. If the offset is equal to string
          size,no fragment is found. 
*
-----------------------------------------------------------------------------*/

method uint spattern.search( uint ptr, uint size )
{
   return qs_search( &this, ptr, size ) 
}

/*-----------------------------------------------------------------------------
* Id: spattern_init_1 FA
*
* Summary: Creating data search pattern.
*
* Params: pattern - Search string (pattern). 
          flag - Search flags.$$[patternflags]  
* 
-----------------------------------------------------------------------------*/

method  spattern spattern.init( str pattern, uint flag )
{
   qs_init( &this, pattern.ptr(), *pattern, flag )
   return this
}

/*-----------------------------------------------------------------------------
* Id: spattern_search_2 FA
*
* Summary: Search a pattern in another string.
*  
* Params: src - String where the specified string will be searched (search /
                pattern). 
          offset - Offset where the search must be started or proceeded. 
* 
* Return: The offset of the found fragment. If the offset is equal to string
          size,no fragment is found. 
*
-----------------------------------------------------------------------------*/

method  uint spattern.search( str src, uint offset )
{
   return offset + qs_search( &this, src.ptr() + offset,
                              *src - offset ) 
}

/*-----------------------------------------------------------------------------
* Id: str_search F2
*
* Summary: Substring search. The method determines if the string has been 
           found inside another string or not. 
*  
* Params: pattern - Search string (pattern). 
          flag - Search flags.$$[patternflags] 
* 
* Return: The method returns 1 if the substring is found, otherwise the return
          value is zero. 
*
-----------------------------------------------------------------------------*/

method  uint str.search( str pattern, uint flag )
{
   spattern sp

   sp.init( pattern, flag )
   return sp.search( this, 0 ) < *this 
} 
