/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/

/*-----------------------------------------------------------------------------
* Id: arrustr L "Array Of Unicode Strings"
* 
* Summary: Array of unicode strings. You can use variables of the #b(arrustr)
   type for working with arrays of unicode strings. The #b(arrustr) type is
   inherited from the #b(arr) type. So, you can also use 
   #a(array, methods of the arr type).
*
* List: *Operators,arrustr_opeq,arrustr_opeqa,arrustr_opadd,
        *Methods,arrustr_insert,arrustr_load,arrustr_read,arrustr_setmultiustr,
        arrustr_sort,arrustr_unite,arrustr_write,
        *@Related Methods,buf_getmultiustr,ustr_lines,ustr_split,
        *Type,tarrustr  
* 
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: tarrustr T arrustr
* 
* Summary: The main structure of array of unicode strings.
*
-----------------------------------------------------------------------------*/

type arrustr <inherit=arr index=ustr> 
{
}

//-----------------------------------------------------------------------------
/*method arrstr.oftype( uint ctype )
{
   return  
}*/

method arrustr.init()
{
   this->arr.oftype( ustr )
}

/*-----------------------------------------------------------------------------
* Id: ustr_split F2
* 
* Summary: Splitting a unicode string. The method splits a string into
           substrings taking into account the specified separator. 
*
* Params: ret - The result array of unicode strings.   
          symbol - Separator.
          flag - Flags. $$[splitflags]
*
* Return: The result array of strings. 
*
-----------------------------------------------------------------------------*/

method arrustr ustr.split( arrustr ret, ushort symbol, uint flag )
{
   uint  cur = this.ptr()
   uint  end = cur + (*this<<1)
   uint  found
   uint  i ptr len
   uint  search
   // Очищаем массив
   if !( flag & $ASTR_APPEND ) : ret.clear()   
   while ( cur <= end )
   {
      search = symbol
     
      if flag & $SPLIT_QUOTE 
      {
         ptr = cur
         while ptr->ushort && ptr->ushort <= 0x0020 : ptr+=2
         if ptr->ushort == 0x0022 || ptr->ushort == $CH_APOSTR
         {
            search = ptr->ushort
            cur = ptr + 2
         }
      }
      if !( flag & $SPLIT_FIRST ) || !*ret || search != symbol
      {
         found = this.findch( (cur - this.ptr())>>1, search ) + (( this.ptr() - cur )>>1)                  
      }
      else : found = (end - cur)>>1
      ptr = cur
      len = found 
      /*if len 
      {
         if flag & $SPLIT_NOSYS : ptr = trimsys( ptr, &len )
         elif flag & $ASTR_LINES :
      }   */   
      if len || flag & $SPLIT_EMPTY
      {
         uint i as ret[ ret.expand( 1 ) ]
         i.copy( ptr, len<<1 )       
         i.setlen( len )                
         if flag & $SPLIT_NOSYS : i.trim( 0, $TRIM_SYS | $TRIM_RIGHT | $TRIM_LEFT )
         elif flag & $ASTR_LINES : i.trim( 0x000D, $TRIM_RIGHT )         
         /*i as ret[ ret.expand( 1 ) ]
         i.copy( ptr, len + 1 )
         i.setlen( len )*/
      }      
      cur += ((found + 1)<<1) 
      if search != symbol
      {
         while cur < end && cur->ushort <= 0x0020 : cur+=2
         if cur->ubyte == symbol : cur+=2
      }
   }
   return ret
}

/*-----------------------------------------------------------------------------
* Id: ustr_split_1 FA
* 
* Summary: The method splits a unicode string into the new result array of 
           unicode strings. 
*
* Params: symbol - Separator.
          flag - Flags. $$[splitflags]
*
* Return: The new result array of unicode strings. 
*
-----------------------------------------------------------------------------*/

method arrustr ustr.split <result> ( uint symbol, uint flag )
{
   this.split( result, symbol, flag )
}

/*-----------------------------------------------------------------------------
* Id: ustr_lines F2
* 
* Summary: Convert a multi-line unicode string to an array of 
           unicode strings.    
*
* Params: ret - The result array of unicode strings.   
          flag - Flags. $$[splitflags]
*
* Return: The result array of unicode strings. 
*
-----------------------------------------------------------------------------*/

method arrustr ustr.lines( arrustr ret, uint flag )
{
   return this.split( ret, 0x000A, flag | $ASTR_LINES )
   /*uint  i = *this
   
   if !( flag & $ASTR_APPEND ) : ret.clear()
   
   this.split( ret, 0x000A, 0 )
   fornum i, *ret
   {
      if flag & $ASTR_TRIM : ret[i].trimsys()
      else : ret[i].dellast( 0x000D )
   }*/ 
}

/*-----------------------------------------------------------------------------
* Id: ustr_lines_1 FA
* 
* Summary: Convert a multi-line unicode string to an array of unicode strings.  
*
* Params: trim - Specify 1 if you want to trim all characters less or  /
                 equal space in lines.
*
* Return: The new result array of unicode strings.
*
-----------------------------------------------------------------------------*/

method arrustr ustr.lines<result>( uint trim )
{
   this.lines( result, ?( trim, $SPLIT_NOSYS, 0 ))
}

/*-----------------------------------------------------------------------------
* Id: ustr_lines_2 FA
* 
* Summary: Convert a multi-line unicode string to an array of unicode 
           strings.    
*
* Params: ret - The result array of strings.   
*
-----------------------------------------------------------------------------*/

method arrustr ustr.lines( arrustr ret )
{
   return this.lines( ret, 0 )
}

/*-----------------------------------------------------------------------------
* Id: ustr_lines_3 FB
* 
* Summary: Convert a multi-line unicode string to an array of unicode 
           strings.    
*
* Return: The new result array of unicode strings.
*
-----------------------------------------------------------------------------*/

method arrustr ustr.lines<result>()
{
   this.lines( result, 0 )
}

/*-----------------------------------------------------------------------------
* Id: arrustr_load F2
* 
* Summary: Add lines to the array of unicode strings from multi-line unicode
           string. 
*
* Params: input - The input unicode string.   
          flag - Flags. $$[astrloadflags]
*
* Return: #lng/retobj#. 
*
-----------------------------------------------------------------------------*/

method arrustr arrustr.load( ustr input, uint flag )
{   
   return input.lines( this, flag )
}

/*-----------------------------------------------------------------------------
* Id: arrustr_load_1 FA
* 
* Summary: Add lines to the array of unicode strings from multi-line unicode
           string with trimming. 
*
* Params: input - The input unicode string.   
*
-----------------------------------------------------------------------------*/

method arrustr arrustr.loadtrim( ustr input )
{
   return input.lines( this, $ASTR_TRIM )
}

/*-----------------------------------------------------------------------------
* Id: arrustr_opeq F4
* 
* Summary: Convert types to the array of unicode strings. 
           Convert a multi-line unicode string to an array of unicode strings.  
*
* Title: arrustr = type
*
* Return: The array of unicode strings. 
*
-----------------------------------------------------------------------------*/

operator arrustr =( arrustr dest, ustr src )
{
   src.lines( dest, 0 )
   return dest
}

/*-----------------------------------------------------------------------------
* Id: arrustr_unite F2 
* 
* Summary: Unite unicode strings of the array. The method unites all items of
           the array to a unicode string with the specified separator string.
*
* Title: arrustr.unite...
*
* Params: dest - The result unicode string.   
          separ - A separator of the strings.
*
* Return: The result unicode string. 
*
-----------------------------------------------------------------------------*/

method ustr arrustr.unite( ustr dest, ustr separ )
{
   uint i   
   fornum i, *this
   {
      if i: dest@separ
      dest@this[i]
   }
   return dest
}

/*
method ustr arrustr.unite<result>( ustr splitter )
{
   this.unite( result )
}
*/
/*-----------------------------------------------------------------------------
* Id: arrustr_unite_1 FA
* 
* Summary: The method unites items of the array to a multi-line unicode string. 
           It inserts new-line characters between the each string of the array.
*
* Params: dest - The result unicode string.   
*
-----------------------------------------------------------------------------*/

method ustr arrustr.unitelines( ustr dest )
{
   return this.unite( dest, ustr("\l") )
}

/*
method ustr arrustr.unitelines<result>()
{
   this.unite( result, ustr("\l") )
}*/

/*-----------------------------------------------------------------------------
* Id: arrustr_opeqa F4
* 
* Summary: Convert an array of unicode strings to a multi-line unicode string.  
*
* Return: The result string. 
*
-----------------------------------------------------------------------------*/

operator ustr =( ustr dest, arrustr src )
{
   return src.unitelines( dest )
} 

/*-----------------------------------------------------------------------------
* Id: arrustr_read F2
* 
* Summary: Read a multi-line text file to array of unicode strings. 
*
* Params: filename - The filename.   
*
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint arrustr.read( str filename )
{
   ustr sfile
   
   if sfile.read( filename )
   {
      sfile.lines( this, 0 )
      return 1
   }
   return 0      
   
}

/*-----------------------------------------------------------------------------
* Id: arrustr_write F2
* 
* Summary: Write an array of unicode strings to a multi-line text file. 
*
* Params: filename - The filename.   
*
* Return: The size of written data. 
*
-----------------------------------------------------------------------------*/

method uint arrustr.write( str filename )
{
   ustr sfile
   uint i   
   fornum i, *this
   {
      if i: sfile@"\l"
      sfile@this[i]
   }
   return sfile.write( filename )
}

/*-----------------------------------------------------------------------------
* Id: arrustr_insert F2
* 
* Summary: Insert a unicode string to an array of unicode strings. 
*
* Params: index - The index of the item where the string will be inserted.
          newstr - The inserting unicode string.   
*
* Return: #lng/retobj# 
*
-----------------------------------------------------------------------------*/

method arrustr arrustr.insert( uint index, ustr newstr )
{
   this->arr.insert( index )
   this[ index ] = newstr
   return this
}


method arrustr arrustr.append( ustr newstr )
{   
   .insert( *this, newstr )
   return this
}

method arrustr arrustr.append( arrustr src )
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
* Id: arrustr_opeq_1 FC
* 
* Summary: Copy one array of unicode strings to another array of unicode
           strings.    
*
-----------------------------------------------------------------------------*/

operator arrustr =( arrustr dest, arrustr src )
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
* Id: arrustr_opadd F4
* 
* Summary: Append types to an array of unicode strings. The operator appends a
           unicode string at the end of the array of unicode strings.
*
* Title: arrustr += type
*
* Return: #lng/retobj# 
*
-----------------------------------------------------------------------------*/

operator arrustr +=( arrustr dest, ustr newstr )
{
   return dest.append( newstr )
} 

/*-----------------------------------------------------------------------------
* Id: arrustr_opadd_1 FC
* 
* Summary: The operator appends one array of unicode strings to another array 
           of unicode strings.
*
-----------------------------------------------------------------------------*/

operator arrustr +=( arrustr dest, arrustr src )
{
   return dest.append( src )
}
/*
//поменять местами
method arrustr.exchange( uint curpos, newpos )
{
   ustr tmp
   curpos = min( curpos, *this )
   newpos = min( newpos, *this )   
   
   tmp = this[newpos]
   this[newpos] = this[curpos] 
   this[curpos] = tmp     
}
*/
/*-----------------------------------------------------------------------------
* Id: arrustr_opeq_2 FC
* 
* Summary: Copy a collection of strings (simple or unicode) to the array of
           unicode strings.    
*
-----------------------------------------------------------------------------*/

operator arrustr =( arrustr left, collection right )
{
   uint i   
   fornum i=0, *right
   {
      if right.gettype(i) == ustr 
      {           
         left += right[i]->ustr
      }
      elif right.gettype(i) == str
      {
         left += right[i]->str
      }
   }
   return left
}

/*-----------------------------------------------------------------------------
* Id: buf_getmultiustr F2
* 
* Summary: Convert a buffer to array of unicode strings. Load the array of
           string from
           multi-string buffer where strings are divided by zero character.  
*
* Params: ret - The result array of unicode strings.   
*
* Return: The result array of unicode strings. 
*
-----------------------------------------------------------------------------*/

method arrustr buf.getmultiustr( arrustr ret )
{
   uint endl end
   uint start
   uint curstr   
 
   ret.clear()
   end = ( *this >> 1 ) - 1
   
   while start < end 
   {            
      endl = this.findsh( start, 0 )                  
      //if start == endl: break   
      curstr as ret[ ret.expand( 1 ) ]             
      curstr->buf.copy( this.ptr() + ( start << 1 ), 
                      ( endl - start + 1 ) << 1/* - 1*/ )
      start = endl + 1    
   }   
   return ret
}

/*method arrustr buf.getmultiustr( arrustr ret )
{
   this.getmultiustr( ret )
   return ret
}

method arrustr buf.getmultiustr<result>( )
{
   this.getmultiustr( result )
}*/

/*-----------------------------------------------------------------------------
* Id: arrustr_setmultiustr F2
* 
* Summary: Create a multi-string buffer. The method writes unicode strings to 
           a buffer.  
*
* Params: dest - The result buffer.   
*
* Return: The result buffer. 
*
-----------------------------------------------------------------------------*/

method buf arrustr.setmultiustr( buf dest )
{
   uint i   
   fornum i, *this
   {
      //if i: dest@'\h 0 0'
      dest@this[i]
      //dest@'\h2 0'  ???
   }
   dest@'\h2 0'
   return dest
} 
/*
method buf arrustr.setmultiustr <result>
{
   this.setmultiustr( result )
}
*/
/*-----------------------------------------------------------------------------
* Id: arrustr_sort F2
* 
* Summary: Sort unicode  strings in the array. 
*
* Params: mode - Specify 1 to sort with ignore-case sensitive. /
                 In default, specify 0.
*
-----------------------------------------------------------------------------*/

method arrustr.sort( uint mode )
{ 
   fastsort( this.ptr(), *this, this.isize, ?( mode, 4, 3 ))
} 
