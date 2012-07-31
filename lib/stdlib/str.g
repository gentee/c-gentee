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

/*-----------------------------------------------------------------------------
* Id: string L "String"
* 
* Summary: Strings. It is possible to use variables of the #b(str) type for
 working with strings. The #b(str) type is inherited from the #b(buf) type. 
 So, you can also use #a(buffer, methods of the buf type).
*
* List: *Operators,str_oplen,str_opsum,str_opeq,str_opadd,str_opeqeq,
         str_opless,str_opgr,str_types2str,str_str2types,
         *Methods,str_append,str_appendch,str_clear,str_copy,str_crc,str_del,
         str_dellast,str_eqlen,str_fill,str_find,
         str_hex,str_insert,str_islast,str_lines,str_lower,str_out4,str_print,
         str_printf,str_read,str_repeat,
         str_replace,str_replacech,str_setlen,str_split,str_substr,str_trim,
         str_upper,str_write,str_writeappend,
         *Search methods,spattern,spattern_init,spattern_search,str_search  
* 
-----------------------------------------------------------------------------*/

define 
{
   CH_APOSTR = 0x27 
}


define <export>{
/*-----------------------------------------------------------------------------
* Id: trimflags D
* 
* Summary: Flags for str.trim method.
*
-----------------------------------------------------------------------------*/
   TRIM_LEFT    = 0x0001   // Trim the left side.
   TRIM_RIGHT   = 0x0002   // Trim the right side.
   TRIM_ONE     = 0x0004   // Delete only one character.
   TRIM_PAIR    = 0x0008   // If the character being deleted is a bracket, / 
                           // look the closing bracket on the right
   TRIM_SYS     = 0x0010   // Delete characters less or equal space.

/*-----------------------------------------------------------------------------
* Id: fillflags D
* 
* Summary: Flags for str.fill method.
*
-----------------------------------------------------------------------------*/
   FILL_LEFT = 0x01   // Filling on the left side.
   FILL_LEN  = 0x02   // The count parameter contains the final string size.
   FILL_CUT  = 0x04   // Cut if longer than the final size. Used together /
                      // with FILL_LEN.
   
//-----------------------------------------------------------------------------
}

/*-----------------------------------------------------------------------------
* Id: str_opsum F4
* 
* Summary: Putting two strings together and creating a resulting string.
*  
* Return: The new result string.
*
-----------------------------------------------------------------------------*/

operator str +<result>( str left, str right )
{
   ( result = left ) += right
}

/*-----------------------------------------------------------------------------
* Id: str_opeqeq F4
* 
* Summary: Comparison operation.
*  
* Return: Returns #b(1) if the strings are equal. Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint ==( str left, str right )
{
   if *left != *right : return 0 
   return !strcmp( left.ptr(), right.ptr() )   
}

/*-----------------------------------------------------------------------------
* Id: str_opeqeq_1 FC
* 
* Summary: Comparison operation.
*
* Title: str != str 
*  
* Return: Returns #b(0) if the strings are equal. Otherwise, it returns #b(1).
*
* Define: operator uint !=( str left, str right )
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: str_opeqeq_2 FC
* 
* Summary: Comparison operation with ignore case.
*
* Return: Returns #b(1) if the strings are equal with ignore case. 
          Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint %==( str left, str right )
{
   if *left != *right : return 0 
   return !strcmpign( left.ptr(), right.ptr())   
}

/*-----------------------------------------------------------------------------
* Id: str_opeqeq_3 FC
* 
* Summary: Comparison operation with ignore case.
*
* Title: str %!= str 
*  
* Return: Returns #b(0) if the strings are equal with ignore case. 
          Otherwise, it returns #b(1).
*
* Define: operator uint %!=( str left, str right )
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: str_opless F4
* 
* Summary: Comparison operation.
*  
* Title: str < str 
*  
* Return: Returns #b(1) if the first string is less than the second one.
          Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint <( str left, str right )
{
   if strcmp( left.ptr(), right.ptr() ) < 0 : return 1
   return 0
}

/*-----------------------------------------------------------------------------
* Id: str_opless_1 FC
* 
* Summary: Comparison operation.
*  
* Title: str <= str 
*  
* Return: Returns #b(1) if the first string is less or equal the second one.
          Otherwise, it returns #b(0).
*
* Define: operator uint <=( str left, str right )
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: str_opless_2 FC
* 
* Summary: Comparison operation with ignore case.
*  
* Title: str %< str 
*  
* Return: Returns #b(1) if the first string is less than the second one with
          ignore case. Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint %<( str left, str right )
{
   if strcmpign( left.ptr(), right.ptr()) < 0 : return 1
   return 0
}

/*-----------------------------------------------------------------------------
* Id: str_opless_3 FC
* 
* Summary: Comparison operation with ignore case.
*  
* Title: str %<= str 
*  
* Return: Returns #b(1) if the first string is less or equal the second one
          with ignore case. Otherwise, it returns #b(0).
*
* Define: operator uint %<=( str left, str right )
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: str_opgr F4
* 
* Summary: Comparison operation.
*  
* Title: str > str 
*  
* Return: Returns #b(1) if the first string is greater than the second one.
          Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint >( str left, str right )
{
   if strcmp( left.ptr(), right.ptr() ) > 0 : return 1
   return 0
}

/*-----------------------------------------------------------------------------
* Id: str_opgr_1 FC
* 
* Summary: Comparison operation.
*  
* Title: str >= str 
*  
* Return: Returns #b(1) if the first string is greater or equal the second one.
          Otherwise, it returns #b(0).
*
* Define: operator uint >=( str left, str right )
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: str_opgr_2 FC
* 
* Summary: Comparison operation with ignore case.
*  
* Title: str %> str 
*  
* Return: Returns #b(1) if the first string is greater than the second one
          with ignore case. Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint %>( str left, str right )
{
   if strcmpign(  left.ptr(), right.ptr() ) > 0 : return 1
   return 0
}

/*-----------------------------------------------------------------------------
* Id: str_opgr_3 FC
* 
* Summary: Comparison operation with ignore case.
*  
* Title: str %>= str 
*  
* Return: Returns #b(1) if the first string is greater or equal the second one
          with ignore case. Otherwise, it returns #b(0).
*
* Define: operator uint %>=( str left, str right )
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: str_types2str F3
*
* Summary: Converting types to str. Convert #b(int) to #b(str) =&gt; 
            #b('str( int )'). 
*  
* Title: str( type )
* 
* Return: The result string.
*
-----------------------------------------------------------------------------*/

method str int.str < result >
{
   result.out4( "%i", this )
}

/*-----------------------------------------------------------------------------
* Id: str_types2str_1 FB
*
* Summary: Convert #b(uint) to #b(str) =&gt; #b('str( uint )'). 
*  
* Title: str( uint )
*
-----------------------------------------------------------------------------*/

method str uint.str < result >
{
   result.out4( "%u", this )
}

/*-----------------------------------------------------------------------------
* Id: str_types2str_2 FB
*
* Summary: Convert #b(float) to #b(str) =&gt; #b('str( float )'). 
*  
* Title: str( float )
*
-----------------------------------------------------------------------------*/

method str float.str <result>
{
   double tmp = double(this)   
   result.out8( "%f", (&tmp)->ulong )
}

/*-----------------------------------------------------------------------------
* Id: str_types2str_3 FB
*
* Summary: Convert #b(long) to #b(str) =&gt; #b('str( long )'). 
*  
* Title: str( long )
*
-----------------------------------------------------------------------------*/

method str long.str <result>
{
   result.out8( "%I64i", this )
}

/*-----------------------------------------------------------------------------
* Id: str_types2str_4 FB
*
* Summary: Convert #b(ulong) to #b(str) =&gt; #b('str( ulong )'). 
*  
* Title: str( ulong )
*
-----------------------------------------------------------------------------*/

method str ulong.str<result>
{
   result.out8( "%I64u", this )
}

/*-----------------------------------------------------------------------------
* Id: str_types2str_5 FB
*
* Summary: Convert #b(double) to #b(str) =&gt; #b('str( double )'). 
*  
* Title: str( double )
*
-----------------------------------------------------------------------------*/

method str double.str <result>
{
   result.out8( "%g", (&this)->ulong )
}

/*-----------------------------------------------------------------------------
* Id: str_opadd_2 FC
* 
* Summary: Append #b(int) to #b(str) =&gt; #b( str += int ).
*  
-----------------------------------------------------------------------------*/

operator str +=( str left, int val )
{
   return left.out4( "%i", val )
}

/*-----------------------------------------------------------------------------
* Id: str_opadd_3 FC
* 
* Summary: Append #b(float) to #b(str) =&gt; #b( str += float ).
*  
-----------------------------------------------------------------------------*/

operator str +=( str left, float val )
{
   double tmp = double(val)   
   return left.out8( "%f", (&tmp)->ulong )
}

/*-----------------------------------------------------------------------------
* Id: str_opadd_4 FC
* 
* Summary: Append #b(long) to #b(str) =&gt; #b( str += long ).
*  
-----------------------------------------------------------------------------*/

operator str +=( str left, long val )
{
   return left.out8( "%I64i", val )
}

/*-----------------------------------------------------------------------------
* Id: str_opadd_5 FC
* 
* Summary: Append #b(ulong) to #b(str) =&gt; #b( str += ulong ).
*  
-----------------------------------------------------------------------------*/
 
operator str +=( str left, ulong val )
{
   return left.out8( "%I64u", val )
}

/*-----------------------------------------------------------------------------
* Id: str_opadd_6 FC
* 
* Summary: Append #b(double) to #b(str) =&gt; #b( str += double ).
*  
-----------------------------------------------------------------------------*/

operator str +=( str left, double val )
{
   return left.out8( "%g", (&val)->ulong )
}

/*-----------------------------------------------------------------------------
* Id: str_str2types F3
*
* Summary: Converting string to other types. Convert #b(str) to #b(int) =&gt; 
            #b('int( str )'). 
*  
* Title: type( str )
* 
* Return: The result value of the according type.
*
-----------------------------------------------------------------------------*/

method int str.int
{
   uint end start
   
   while this[ start ] == '0' && this[ start + 1 ] != 'x' &&
         this[ start + 1 ] != 'X' : start++  
   return strtol( this.ptr() + start, &end, 0 )
}

/*-----------------------------------------------------------------------------
* Id: str_str2types_1 FB
*
* Summary: Convert #b(str) to #b(uint) =&gt; #b('uint( str )'). 
*  
* Title: uint( str )
* 
-----------------------------------------------------------------------------*/

method uint str.uint
{
   uint end start
   
   while this[ start ] == '0' && this[ start + 1 ] != 'x' &&
         this[ start + 1 ] != 'X' : start++  
      
   return strtoul( this.ptr() + start, &end, 0 )
}

/*-----------------------------------------------------------------------------
* Id: str_str2types_2 FB
*
* Summary: Convert #b(str) to #b(float) =&gt; #b('float( str )'). 
*  
* Title: float( str )
* 
-----------------------------------------------------------------------------*/

method float str.float
{
   return float( atof( this.ptr() ))
}

/*-----------------------------------------------------------------------------
* Id: str_str2types_3 FB
*
* Summary: Convert #b(str) to #b(long) =&gt; #b('long( str )'). 
*  
* Title: long( str )
* 
-----------------------------------------------------------------------------*/

method long str.long
{
   return atoi64( this.ptr())
}

/*-----------------------------------------------------------------------------
* Id: str_str2types_4 FB
*
* Summary: Convert #b(str) to #b(double) =&gt; #b('double( str )'). 
*  
* Title: double( str )
* 
-----------------------------------------------------------------------------*/

method double str.double
{
   return atof( this.ptr())
}

/*-----------------------------------------------------------------------------
* Id: str_hex F2
*
* Summary: Converting an unsigned integer in the hexadecimal form. Lower characters. 
*  
* Title: str.hex...
* 
* Params: val - The unsigned integer value to be converted into the string. 
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.hexl( uint val )
{
   return this.out4( "%x", val )
}

/*-----------------------------------------------------------------------------
* Id: str_hex_1 F8
*
* Summary: Converting an unsigned integer in the hexadecimal form. 
          ( upper characters ). 
*  
* Params: val - The unsigned integer value to be converted into the string. 
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.hexu( uint val )
{
   return this.out4( "%X", val )
}

/*-----------------------------------------------------------------------------
* Id: str_hex_2 F8
*
* Summary: Converting an unsigned integer in the hexadecimal form. 
          ( lower characters ). 
*  
* Params: val - The unsigned integer value to be converted into the string. 
* 
* Return: The new result string.
*
-----------------------------------------------------------------------------*/

func str hex2strl<result>( uint val )
{
   result.out4( "%x", val )
}

/*-----------------------------------------------------------------------------
* Id: str_hex_3 F8
*
* Summary: Converting an unsigned integer in the hexadecimal form. 
          ( upper characters ). 
*  
* Params: val - The unsigned integer value to be converted into the string. 
* 
* Return: The new result string.
*
-----------------------------------------------------------------------------*/

func str hex2stru<result>( uint val )
{
   result.out4( "%X", val )
}

/*-----------------------------------------------------------------------------
* Id: str_appendch F2
* 
* Summary: Adding a character to a string.
*  
* Params: ch - The character to be added. 
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method  str str.appendch( uint ch )
{
   this[ *this ] = ch
   this->buf += byte( 0 )
      
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_del F2
* 
* Summary: Delete a substring. 
*  
* Params: off - The offset of the substring being deleted. 
          len - The size of the substring being deleted. 
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method  str str.del( uint off, uint len )
{
   uint slen = this->buf.use - 1 

   if off > slen : return this
   if off + len > slen : len = slen - off  
   this->buf.del( off, len )
   
   this[ this->buf.use - 1 ] = 0
      
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_find_2 FA
* 
* Summary: Find the character from the end of the string. 
*  
* Params: symbol - Search character.
*
-----------------------------------------------------------------------------*/

method uint str.findchr( uint symbol )
{
   return this.findch( 0, symbol, 1 )
}

/*-----------------------------------------------------------------------------
* Id: str_find_3 FA
* 
* Summary: Find the character from the specified offset in the string. 
*  
* Params: symbol - Search character.
          offset - The offset to start searching from.
*
-----------------------------------------------------------------------------*/

method uint str.findchfrom( uint symbol, uint offset )
{
   return this.findch( offset, symbol, 0 )
}

/*-----------------------------------------------------------------------------
* Id: str_find_4 FA
* 
* Summary: Find the #b[#glt(i)] character in the string. 
*  
* Params: symbol - Search character.
          i - The number of the character starting from 1.
*
-----------------------------------------------------------------------------*/

method uint str.findchnum( uint symbol, uint i )
{
   uint cur
   uint end = *this
   
   while i && cur < end
   {
      i--
      cur = this.findch( cur, symbol, 0 ) 
      if cur < end && i : cur++
   }
   return cur
}

/*-----------------------------------------------------------------------------
* Id: str_substr_1 FA
* 
* Summary: Get a substring. The result substring will be written over the
           existing string. 
*  
* Params: off - Substring offset. 
          len - Substring size. 
*
-----------------------------------------------------------------------------*/

method str str.substr( uint off, uint len )
{
   return this.substr( this, off, len )
}

func uint trimsys( uint ptr len )
{
   uint  end = ptr + len->uint
   
   while ptr->ubyte <= ' ' && ptr < end : ptr++
   while ( end - 1 )->ubyte <= ' ' && ptr < end : end-- 

   len->uint = end - ptr

   return ptr
}

/*-----------------------------------------------------------------------------
* Id: str_trim F3
* 
* Summary: Trimming a string. Deleting spaces and special characters on both
           sides.
* 
* Title: str.trim...
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.trimsys()
{
   uint len = *this
   uint ptr
   
   ptr = trimsys( this.ptr(), &len )
   if len != *this : this.substr( this, ptr - this.ptr(), len )
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_trim_1 FB
* 
* Summary: Deleting spaces and special characters on the right.
*
-----------------------------------------------------------------------------*/

method  str str.trimrsys()
{
   uint  ptr = this.ptr() 
   uint  end = ptr + *this
   
   while ( end - 1 )->ubyte <= ' ' && ptr < end : end-- 

   this.setlen( end - ptr )
   return this
}

/*method str str.oem2char
{
   OemToCharBuff( this.ptr(), this.ptr(), *this )
   return this
}

method str str.char2oem
{
   CharToOemBuff( this.ptr(), this.ptr(), *this )
   return this
}*/

/*-----------------------------------------------------------------------------
* Id: str_clear F3
* 
* Summary: Clearing a string. 
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.clear()
{
   return this.setlen( 0 )
}

/*-----------------------------------------------------------------------------
* Id: str_replace F2
* 
* Summary: Replacing in a string. The method replaces data in a string. 
* 
* Params: offset - The offset of the data being replaced. 
          size - The size of the data being replaced. 
          value - The string being inserted. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str  str.replace( uint offset, uint size, str value )
{
   if offset >= *this : this += value
   else
   {
      value->buf.use--
      this->buf.replace( offset, size, value->buf )   
      value->buf.use++
   }
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_insert F2
* 
* Summary: Insertion. The method inserts one string into another. 
* 
* Params: offset - The offset where string will be inserted. 
          value - The string being inserted. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str  str.insert( uint offset, str value )
{
   return this.replace( offset, 0, value )
}

/*-----------------------------------------------------------------------------
* Id: str_fill F2
* 
* Summary: Filling a string. Fill a string to the left or to the right.   
* 
* Title: str.fill...
*
* Params: val - The string that will be filled. 
          count - The number of additions. 
          flag - Flags. $$[fillflags] 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.fill( str val, uint count, uint flag )
{
   uint  len
   uint  elen
   str   ret
   
   elen = ?( flag & $FILL_LEN, count, *this + count * *val )
   len = ?( elen < *this, 0, elen - *this )
   while *ret < len : ret += val
   ret.setlen( len )
   
   if len
   {
      if flag & $FILL_LEFT : this.insert( 0, ret )
      else : this += ret
   }
   if flag & $FILL_CUT && elen < *this : this.setlen( elen )
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_fill_1 FA
* 
* Summary: Fill a string with spaces to the left.    
*
* Params: len - Final string size.   
*
-----------------------------------------------------------------------------*/

method str str.fillspacel( uint len )
{
   return this.fill( " ", len, $FILL_LEFT | $FILL_LEN )
}

/*-----------------------------------------------------------------------------
* Id: str_fill_2 FA
* 
* Summary: Fill a string with spaces to the right.    
*
* Params: len - Final string size.   
*
-----------------------------------------------------------------------------*/

method str str.fillspacer( uint len )
{
   return this.fill( " ", len, $FILL_LEN )
}

/*-----------------------------------------------------------------------------
* Id: str_repeat F2
* 
* Summary: Repeating a string. Repeat a string the specified number of times.  
* 
* Params: count - The number of repeatitions. The result will be written /
                  into this very string. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.repeat( uint count )
{
   str pat = this
   return this.fill( pat, count * *pat, $FILL_CUT | $FILL_LEN )
}

/*-----------------------------------------------------------------------------
* Id: str_setlen_1 FB
* 
* Summary: Recalculate the size of a string to the zero character. The 
           function can be used to determine the size of a string after 
           other functions write data into it.    
* 
-----------------------------------------------------------------------------*/

method str str.setlenptr()
{
   return this.setlen( mlen( this.ptr()))
}

/*-----------------------------------------------------------------------------
* Id: str_crc F3
* 
* Summary: Calculating the checksum. The method calculates the checksum of a
           string. 
*  
* Return: The string checksum is returned. 
*
-----------------------------------------------------------------------------*/

method uint str.crc()
{
   return crc( this.ptr(), *this, 0xFFFFFFFF )
}

/*-----------------------------------------------------------------------------
* Id: str_lower F3
* 
* Summary: Converting to lowercase. The method converts characters in 
           a string to lowercase.   
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.lower()
{
   CharLowerBuff( this.ptr(), *this )
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_lower_1 FA
* 
* Summary: Convert a substring in the specified string to lowercase.
*
* Params: off - Substring offset. 
          size - Substring size. 
*
-----------------------------------------------------------------------------*/

method str str.lower( uint off, uint size )
{
   off = min( off, *this - 1 )
   size = min( size, *this - off )
   
   CharLowerBuff( this.ptr() + off, size )
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_upper F3
* 
* Summary: Converting to uppercase. The method converts characters in a string
           to uppercase.  
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.upper()
{
   CharUpperBuff( this.ptr(), *this )
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_upper_1 FA
* 
* Summary: Convert a substring in the specified string to uppercase.
*
* Params: off - Substring offset. 
          size - Substring size. 
*
-----------------------------------------------------------------------------*/

method str str.upper( uint off, uint size )
{
   off = min( off, *this - 1 )
   size = min( size, *this - off )
   
   CharUpperBuff( this.ptr() + off, size )
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_islast F2
* 
* Summary: Check the final character.
*
* Params: symbol - The character being checked.  
* 
* Return: Returns 1 if the last character in the string coincides with the
          specified one and 0 otherwise. 
*
-----------------------------------------------------------------------------*/

method uint str.islast( uint symbol )
{
   if !*this : return 0
   
   if gentee_ptr(0)->_gentee.multib
   {
      return this.findchr( symbol ) == *this - 1
   }

   return this[ *this - 1 ] == symbol
}

/*-----------------------------------------------------------------------------
* Id: str_trim_2 FA
* 
* Summary: Delete the specified character on either sides of a string.
*
* Params: symbol - The character being deleted.
          flag - Flags. $$[trimflags]
*
-----------------------------------------------------------------------------*/

method str  str.trim( uint symbol, uint flag )
{
   uint rsymbol = symbol
   
   if flag & $TRIM_PAIR
   {
      switch symbol
      {
         case '(' : rsymbol = ')'
         case '{' : rsymbol = '}'
         case '[' : rsymbol = ']'
         case '<' : rsymbol = '>'
      }      
   }
   if  flag & $TRIM_RIGHT 
   {
      while this.islast( rsymbol )
      {
         this.setlen( *this - 1 )
         if flag & $TRIM_ONE : break
      }
   }
   if  flag & $TRIM_LEFT
   {
      uint   cur = this.ptr()
      uint   end = cur + *this

      while cur < end && cur->ubyte == symbol
      {
         cur++
         if flag & $TRIM_ONE : break
      }
      if cur != this.ptr() : this.del( 0, cur - this.ptr())
   }

   return this;
}

/*-----------------------------------------------------------------------------
* Id: str_trim_3 FB
* 
* Summary: Deleting spaces on the right.
*
-----------------------------------------------------------------------------*/

method str str.trimrspace()
{
   return this.trim( ' ', $TRIM_RIGHT )
}

/*-----------------------------------------------------------------------------
* Id: str_trim_4 FB
* 
* Summary: Deleting spaces on the both sides.
*
-----------------------------------------------------------------------------*/

method str str.trimspace()
{
   return this.trim( ' ', $TRIM_RIGHT | $TRIM_LEFT )
}

/*-----------------------------------------------------------------------------
* Id: str_eqlen F2
* 
* Summary: Comparison. Compare a string with the specified data. 
           The comparison is carried out only at the length of the string 
           the method is called for.    
*
* Title: str.eqlen...
*
* Params: ptr - The pointer to the data to be compared.  
* 
* Return: Returns 1 if there is an equality and 0 otherwise.  
*
-----------------------------------------------------------------------------*/

method uint str.eqlen( uint ptr )
{
   return !strcmplen( this->buf.data, ptr, this->buf.use - 1 )   
}

/*-----------------------------------------------------------------------------
* Id: str_eqlen_1 FA
* 
* Summary: Compare a string with the specified data. 
           The comparison is carried out only at the length of the string 
           the method is called for.    
*
* Params: ptr - The pointer to the data to be compared. The comparison is /
                case-insensitive.  
* 
-----------------------------------------------------------------------------*/

method uint str.eqlenign( uint ptr )
{   
   uint res = !strcmpignlen( this->buf.data, ptr, this->buf.use - 1 )
//   print( "\(res )\n" )
   return res
   //return !strcmpignlen( this->buf.data, ptr, this->buf.use - 1 )   
}

/*-----------------------------------------------------------------------------
* Id: str_eqlen_2 FA
* 
* Summary: Compare a string with the specified string. 
           The comparison is carried out only at the length of the string 
           the method is called for.    
*
* Params: src - The string to be compared.  
* 
-----------------------------------------------------------------------------*/

method uint str.eqlen( str src )
{
   return this.eqlen( src.ptr())
}

/*-----------------------------------------------------------------------------
* Id: str_eqlen_3 FA
* 
* Summary: Compare a string with the specified string. 
           The comparison is carried out only at the length of the string 
           the method is called for.    
*
* Params: src - The string to be compared. The comparison is case-insensitive.
* 
-----------------------------------------------------------------------------*/

method uint str.eqlenign( str src )
{
   return this.eqlenign( src.ptr())
}

/*-----------------------------------------------------------------------------
* Id: str_append F2
* 
* Summary: Data addition. Add data to a string.  
* 
* Params: src - The pointer to the data to be added. 
          size - The size of the data being added. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.append( uint src, uint size )
{
   if size 
   {
      this->buf.use--
      this->buf.append( src, size )
      this->buf += byte( 0 )
   }
   return this
}

/*method str str.quote( uint ch )
{
   str stemp
   
   if this[0] == ch && this.islast( ch ) : return this
   
   char2str( stemp, ch )
   this.insert( 0, stemp )
   return this.appendch( ch )
}*/

/*-----------------------------------------------------------------------------
* Id: str_replacech F2
* 
* Summary: Replace a character. The method copies a source string with the
           replacing a character to a string.  
* 
* Params: src - Initial string. 
          from - A character to be replaced. 
          to - A string for replacing. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method str str.replacech( str src, uint from, str to )
{
   uint i
   
   this.clear()
   fornum i, *src
   {
      if src[ i ] == from
      {
         this += to
      }
      else : this.appendch( src[i] )      
   }
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_read F2
* 
* Summary: Read a string from a file.
* 
* Params: filename - Filename.
*
* Return: The size of the read data. 
*
-----------------------------------------------------------------------------*/

method uint str.read( str filename )
{
   uint len = this->buf.read( filename )   
   this.setlen( len )   
   return len
}

/*-----------------------------------------------------------------------------
* Id: str_write F2
* 
* Summary: Writing a string to a file. 
*  
* Params: filename - The name of the file for writing. If the file already /
                     exists, it will be overwritten. 
* 
* Return: The size of the written data.
*
-----------------------------------------------------------------------------*/

method uint str.write( str filename )
{
   uint wr
      
   this->buf.use--
   wr = this->buf.write( filename )
   this->buf.use++
   return wr
}

/*-----------------------------------------------------------------------------
* Id: str_writeappend F2
* 
* Summary: Appending string to a file. The method appends a string to the
           specified file. 
*  
* Params: filename - Filename.  
* 
* Return: The size of the written data.
*
-----------------------------------------------------------------------------*/

method uint str.writeappend( str filename )
{
   uint wr
      
   this->buf.use--
   wr = this->buf.writeappend( filename )
   this->buf.use++
   return wr
}

/*-----------------------------------------------------------------------------
* Id: str_copy_1 FA
* 
* Summary: The method copies data into a string.
*
* Params: src - The pointer to the data being copied. If data does not end /
                in a zero, it will be added automatically. 
          size - The size of the data being copied. 
*
-----------------------------------------------------------------------------*/

method str str.copy( uint src, uint size )
{
   this->buf.copy( src, size )
   this->buf += ubyte(0)
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_dellast F2
* 
* Summary: Delete the last character. The method deletes the last character if
           it is equal the specified parameter.   
* 
* Params: ch - A character to be checked. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/
 
method str str.dellast( uint ch )
{
   if .islast( ch ) : .setlen( *this - 1 )
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_split_2 FA
* 
* Summary:  The method looks for the first #i(symbol) and splits a string 
            into two parts. 
* 
* Params:  symbol - Separator.
           left - The substring left on the #i(symbol). 
           right - The substring right on the #i(symbol). 
*
* Return: Returns 1 if the separator has been found. Otherwise, return 0. 
*
-----------------------------------------------------------------------------*/

method uint str.split( uint symbol, str left, str right )
{
   uint off
   
   right.clear()
   if ( off = this.findch( symbol )) < *this
   {
      left.substr( this, 0, off )
      right.substr( this, off + 1, *this - off - 1 )
   }
   else : left = this
   return *right > 0
}

/*Тип str является встроенным
Cтруктура str включена в компилятор
type str < index = byte inherit = buf>{
}
В компилятор включены следующее методы и операции:
str str.init() скрыт
str str.load( uint ptr, uint size )
str str.copy( uint ptr )
str str.findch( uint off symbol fromend )
str str.findch( uint symbol )
uint str.fwildcard( str mask )
str.print()
str str.setlen( uint )
str str.substr( str uint off len )
str = str
str += str
str += uint
*str
str.out4( str format, uint value )
str.out8( str format, ulong value )
*/
