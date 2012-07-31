/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexander Krivonogov ( algen )
*
******************************************************************************/

/*-----------------------------------------------------------------------------
* Id: arrstr L "Array Of Strings"
* 
* Summary: Array of strings. You can use variables of the #b(arrstr) type for
 working with arrays of strings. The #b(arrstr) type is inherited from the
  #b(arr) type. So, you can also use #a(array, methods of the arr type).
*
* List: *Operators,arrstr_opeq,arrstr_opeqa,arrstr_opadd,
        *Methods,arrstr_insert,arrstr_load,arrstr_read,arrstr_replace,
        arrstr_setmultistr,arrstr_sort,arrstr_unite,arrstr_write,
        *@Related Methods,buf_getmultistr,str_lines,str_split,
        *Type,tarrstr  
* 
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: tarrstr T arrstr
* 
* Summary: The main structure of array of strings.
*
-----------------------------------------------------------------------------*/

type arrstr <inherit=arr index=str> 
{
}

//-----------------------------------------------------------------------------

define <export>
{
/*-----------------------------------------------------------------------------
* Id: splitflags D
* 
* Summary: Flags for str.split method.
*
-----------------------------------------------------------------------------*/
   SPLIT_EMPTY  = 0x0001   // Take into account empty substrings.
   SPLIT_NOSYS  = 0x0002   // Delete characters <= space on the left and on /
                           // the right.
   SPLIT_FIRST  = 0x0004   // Split till the first separator.
   SPLIT_QUOTE  = 0x0008   // Take into account that elements can be enclosed /
                           // by single or double quotation marks.
   SPLIT_APPEND = 0x0010   // Adding strings. Otherwise, the array is cleared /
                           // before loading.

/*-----------------------------------------------------------------------------
* Id: astrloadflags D
* 
* Summary: Flags for arrstr.load method.
*
-----------------------------------------------------------------------------*/
   ASTR_APPEND  = 0x0010   // Adding strings. Otherwise, the array is cleared /
                           // before loading.
   ASTR_TRIM    = 0x0002   // Delete characters <= space on the left and on /
                           // the right.
                           
//---------------------------------------------------------------------------
   ASTR_LINES   = 0x0020   // Обработка для lines 
}

method arrstr.oftype( uint ctype )
{
   return  
}

method arrstr.init()
{
   this->arr.oftype( str )
}

define
{
   ST_0  = 0
   ST_0D = 1
   ST_S = 2
//   ST_0A = 2
}

/*-----------------------------------------------------------------------------
* Id: str_split F2
* 
* Summary: Splitting a string. The method splits a string into substrings 
           taking into account the specified separator. 
*
* Params: ret - The result array of strings.   
          symbol - Separator.
          flag - Flags. $$[splitflags]
*
* Return: The result array of strings. 
*
-----------------------------------------------------------------------------*/

method arrstr str.split( arrstr ret, uint symbol, uint flag )
{
   uint  cur = this.ptr()
   uint  end = cur + *this
   uint  found
   uint  i ptr len
   uint  search
   
   // Очищаем массив
   if !( flag & $SPLIT_APPEND ) : ret.clear()
   while ( cur <= end )
   {
      search = symbol
     
      if flag & $SPLIT_QUOTE 
      {
         ptr = cur
         while ptr->ubyte && ptr->ubyte <= ' ' : ptr++
         if ptr->ubyte == '"' || ptr->ubyte == $CH_APOSTR
         {
            search = ptr->ubyte
            cur = ptr + 1
         }
      }

      if !( flag & $SPLIT_FIRST ) || !*ret || search != symbol
      {         
         found = this.findch( cur - this.ptr(), search, 0 ) - cur + this.ptr()         
      }
      else : found = end - cur                        
      
      ptr = cur
      len = found 
      if len && flag & $SPLIT_NOSYS : ptr = trimsys( ptr, &len )      
      if len || flag & $SPLIT_EMPTY
      {
         i as ret[ ret.expand( 1 ) ]
         i.copy( ptr, len + 1 )
         i.setlen( len )
      }      
      cur += found + 1 
      if search != symbol
      {
         while cur < end && cur->ubyte <= ' ' : cur++
         if cur->ubyte == symbol : cur++
      }
   }   
   return ret
}

/*-----------------------------------------------------------------------------
* Id: str_split_1 FA
* 
* Summary: The method splits a string into the new result array of strings. 
*
* Params: symbol - Separator.
          flag - Flags. $$[splitflags]
*
* Return: The new result array of strings. 
*
-----------------------------------------------------------------------------*/

method arrstr str.split <result> ( uint symbol, uint flag )
{
   this.split( result, symbol, flag )
}

/*-----------------------------------------------------------------------------
* Id: arrstr_load F2
* 
* Summary: Add lines to the array from multi-line string. 
*
* Params: input - The input string.   
          flag - Flags. $$[astrloadflags]
*
* Return: #lng/retobj#. 
*
-----------------------------------------------------------------------------*/

method arrstr arrstr.load( str input, uint flag )
{
   uint  i = *this
   
//   if !( flag & $ASTR_APPEND ) : .clear()
   
   input.split( this, 0xA, flag | $SPLIT_EMPTY )
   if !( flag & $ASTR_TRIM )
   { 
      fornum i, *this
      {
//      if flag & $ASTR_TRIM : this[i].trimsys()
//      else : this[i].dellast( 0xd )
         this[i].dellast( 0xd )
      }
   } 
   return this
}

/*-----------------------------------------------------------------------------
* Id: arrstr_load_1 FA
* 
* Summary: Add lines to the array from multi-line string with trimming. 
*
* Params: input - The input string.   
*
-----------------------------------------------------------------------------*/

method arrstr arrstr.loadtrim( str input )
{
   return this.load( input, $ASTR_TRIM )
}

/*-----------------------------------------------------------------------------
* Id: buf_getmultistr F2
* 
* Summary: Convert a buffer to array of strings. Load the array of string from
           multi-string buffer where strings are divided by zero character.  
*
* Params: ret - The result array of strings.   
          offset - The array for getting offsets of strings in the buffer. /
                   It can be 0->&gt;arr.
*
* Return: The result array of strings. 
*
-----------------------------------------------------------------------------*/

method arrstr buf.getmultistr( arrstr ret, arr offset )
{
   uint endl
   uint start
   uint curstr   
 
   ret.clear()
   if offset : offset.clear()
     
   while 1
   {      
      endl = this.findch( start, 0 )
      curstr as ret[ ret.expand( 1 ) ]             
      curstr.copy( this.ptr() + start, endl - start )
      if offset : offset[ offset.expand(1) ] = start
      if endl >= *this - 1  : break      
      start = endl + 1
   }
   return ret
}

/*-----------------------------------------------------------------------------
* Id: buf_getmultistr_1 FA
* 
* Summary: Load the array of string from multi-string buffer where strings /
           are divided by zero character.
*
* Params: ret - The result array of strings.   
*
-----------------------------------------------------------------------------*/

method arrstr buf.getmultistr( arrstr ret )
{
   this.getmultistr( ret, 0->arr )
   return ret
}
/*
method arrstr buf.getmultistr<result>( uint trim )
{
   this.getmultistr( result, trim )
}
*/
/*-----------------------------------------------------------------------------
* Id: arrstr_setmultistr F2
* 
* Summary: Create a multi-string buffer. The method writes strings to 
           a multi-string buffer where strings are divided by zero character.  
*
* Params: dest - The result buffer.   
*
* Return: The result buffer. 
*
-----------------------------------------------------------------------------*/

method buf arrstr.setmultistr( buf dest )
{
   uint i   
   fornum i, *this
   {
//      if i: dest@'\h 0'
      dest@this[i]
   }
   return dest
} 

/*-----------------------------------------------------------------------------
* Id: arrstr_setmultistr_1 FB
* 
* Summary: The method creates a multi-string buffer where strings are divided 
           by zero character.  
*
* Return: The new result buffer. 
*
-----------------------------------------------------------------------------*/

method buf arrstr.setmultistr <result>
{
   this.setmultistr( result )
}

/*-----------------------------------------------------------------------------
* Id: str_lines F2
* 
* Summary: Convert a multi-line string to an array of strings.    
*
* Params: ret - The result array of strings.   
          trim - Specify 1 if you want to trim all characters less or /
                 equal space in lines.
          offset - The array for getting offsets of lines in the string. /
                   It can be 0->&gt;arr.
*
* Return: The result array of strings. 
*
-----------------------------------------------------------------------------*/

method arrstr str.lines( arrstr ret, uint trim, arr offset )
{
   uint endl
   uint start
   uint curstr   
 
   ret.clear()
   if offset : offset.clear()
     
   while 1
   {      
      endl = this.findch( start, 0x0A, 0 )
        
      curstr as ret[ ret.expand( 1 ) ]  
      if endl == *this : curstr.substr( this, start, endl - start ) 
      else : curstr.substr( this, start, endl - start )
      if curstr.islast( 0x0D ) : curstr.setlen( *curstr - 1 )
      if offset : offset[ offset.expand(1) ] = start
      if trim : curstr.trimsys() 
      if endl == *this : break      
      start = endl + 1
   }  
   return ret
}

/*-----------------------------------------------------------------------------
* Id: str_lines_1 FA
* 
* Summary: Convert a multi-line string to an array of strings.    
*
* Params: ret - The result array of strings.   
          trim - Specify 1 if you want to trim all characters less or /
                 equal space in lines.
*
-----------------------------------------------------------------------------*/

method arrstr str.lines( arrstr ret, uint trim )
{
   this.lines( ret, trim, 0->arr )
   return ret
}

/*-----------------------------------------------------------------------------
* Id: str_lines_2 FA
* 
* Summary: Convert a multi-line string to an array of strings.    
*
* Params: trim - Specify 1 if you want to trim all characters less or  /
                 equal space in lines.
*
* Return: The new result array of strings.
*
-----------------------------------------------------------------------------*/

method arrstr str.lines<result>( uint trim )
{
   this.lines( result, trim )
}


/*-----------------------------------------------------------------------------
* Id: arrstr_opeq F4
* 
* Summary: Convert types to the array of strings. 
           Convert a multi-line string to an array of strings.    
*
* Title: arrstr = type
*
* Return: The array of strings. 
*
-----------------------------------------------------------------------------*/

operator arrstr =( arrstr dest, str src )
{
   src.lines( dest, 0 )
   return dest
}

/*-----------------------------------------------------------------------------
* Id: arrstr_unite F2 
* 
* Summary: Unite strings of the array. The method unites all items of the 
           array to a string with the specified separator string.
*
* Title: arrstr.unite...
*
* Params: dest - The result string.   
          separ - A separator of the strings.
*
* Return: The result string. 
*
-----------------------------------------------------------------------------*/

method str arrstr.unite( str dest, str separ )
{
   uint i   
   fornum i, *this
   {
      if i: dest@separ
      dest@this[i]
   }
   return dest
}

/*-----------------------------------------------------------------------------
* Id: arrstr_unite_1 FA
* 
* Summary: The method unites all items of the array to a string.
*
* Params: dest - The result string.   
*
-----------------------------------------------------------------------------*/

method str arrstr.unite( str dest )
{
   return this.unite( dest, "" )
}

/*-----------------------------------------------------------------------------
* Id: arrstr_unite_2 FA
* 
* Summary: The method unites items of the array to a multi-line string. 
           It inserts new-line characters between the each string of the array.
*
* Params: dest - The result string.   
*
-----------------------------------------------------------------------------*/

method str arrstr.unitelines( str dest )
{
   return this.unite( dest, "\l" )
}
/*
method str arrstr.unitelines<result>()
{
   this.unite( result, "\l" )
}
*/
/*-----------------------------------------------------------------------------
* Id: arrstr_opeqa F4
* 
* Summary: Convert an array of strings to a multi-line string.    
*
* Return: The result string. 
*
-----------------------------------------------------------------------------*/

operator str =( str dest, arrstr src )
{
   return src.unitelines( dest )
} 

/*-----------------------------------------------------------------------------
* Id: arrstr_read F2
* 
* Summary: Read a multi-line text file to array of strings. 
*
* Params: filename - The filename.   
*
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint arrstr.read( str filename )
{
   str sfile
   
   if sfile.read( filename )
   {
      sfile.lines( this, 0 )
      return 1
   }
   return 0      
   
}

/*-----------------------------------------------------------------------------
* Id: arrstr_write F2
* 
* Summary: Write an array of strings to a multi-line text file. 
*
* Params: filename - The filename.   
*
* Return: The size of written data. 
*
-----------------------------------------------------------------------------*/

method uint arrstr.write( str filename )
{
   str sfile
   uint i   
   fornum i, *this
   {
      if i: sfile@"\l"
      sfile@this[i]
   }
   return sfile.write( filename )
}

/*-----------------------------------------------------------------------------
* Id: arrstr_insert F2
* 
* Summary: Insert a string to an array of strings. 
*
* Params: index - The index of the item where the string will be inserted.
          newstr - The inserting string.   
*
* Return: #lng/retobj# 
*
-----------------------------------------------------------------------------*/

method arrstr arrstr.insert( uint index, str newstr )
{
   this->arr.insert( index )
   this[ index ] = newstr
   return this
}


method arrstr arrstr.append( str newstr )
{   
   .insert( *this, newstr )
   return this
}

method arrstr arrstr.append( arrstr src )
{
   uint i, j   
   j = this.expand( *src )   
   fornum i, *src 
   {
      this[j++] = src[i]
   }   
   return this
}

/*-----------------------------------------------------------------------------
* Id: arrstr_opeq_1 FC
* 
* Summary: Copy one array of strings to another array of strings.    
*
-----------------------------------------------------------------------------*/

operator arrstr =( arrstr dest, arrstr src )
{
   uint i
   dest.clear()
   dest.expand( *src )
   fornum i, *src 
   {
      dest[i] = src[i]
   }   
   return dest
}

/*-----------------------------------------------------------------------------
* Id: arrstr_opadd F4
* 
* Summary: Append types to an array of strings. The operator appends a string 
           at the end of the array of strings.
*
* Title: arrstr += type
*
* Return: #lng/retobj# 
*
-----------------------------------------------------------------------------*/

operator arrstr +=( arrstr dest, str newstr )
{
   return dest.append( newstr )
} 

/*-----------------------------------------------------------------------------
* Id: arrstr_opadd_1 FC
* 
* Summary: The operator appends one array of strings to another array 
           of strings.
*
-----------------------------------------------------------------------------*/

operator arrstr +=( arrstr dest, arrstr src )
{
   return dest.append( src )
}

/*
//поменять местами
method arrstr.exchange( uint curpos, uint newpos )
{
   str tmp
   curpos = min( curpos, *this )
   newpos = min( newpos, *this )   
   
   tmp = this[newpos]
   this[newpos] = this[curpos] 
   this[curpos] = tmp     
}
*/
/*-----------------------------------------------------------------------------
* Id: arrstr_opeq_2 FC
* 
* Summary: Copy a collection of strings to the array of strings.    
*
-----------------------------------------------------------------------------*/

operator arrstr =( arrstr left, collection right )
{
   uint i   
   fornum i=0, *right
   {
      if right.gettype(i) == str 
      {           
         left += right[i]->str
      }
   }
   return left
}

/*-----------------------------------------------------------------------------
* Id: arrstr_sort F2
* 
* Summary: Sort strings in the array. 
*
* Params: mode - Specify 1 to sort with ignore-case sensitive. /
                 In default, specify 0.
*
-----------------------------------------------------------------------------*/

method arrstr.sort( uint mode )
{ 
   fastsort( this.ptr(), *this, this.isize, mode )
} 

// переместить с места на место
/*method arrstr.move( uint curpos, newpos )
{
   
   
   uint i
   str  tmp
   
   curpos = min( curpos, *this )
   newpos = min( newpos, *this )
      
   tmp = this[ curpos ]
   if newpos < curpos 
   {      
      for i = curpos, i > newpos,
      {
         this[ i ] = this[ --i ]
      }
   }
   else
   {
      for i = curpos, i < newpos,
      {
         this[ i ] = this[ ++i ]
      }
   }
   this[ newpos ] = tmp
}*/

/*/sort отсортировать
uint find( str fstr, uint index ) найти строку начиная с index, если не нашлась, то возвращаем -1
Можно ли строку связывать с указателем на что-нибудь*/



