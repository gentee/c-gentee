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
* Id: stringuni L "String - Unicode"
* 
* Summary: Unicode strings. It is possible to use variables of the #b(ustr) 
           type for working with Unicode strings. The #b(ustr) type is 
           inherited from the #b(buf) type. So, you can also use 
           #a(buffer, methods of the buf type).
*
* List: *Operators,ustr_oplen,ustr_opind,ustr_opsum,ustr_opeq,ustr_opeqa,
         ustr_opadd,ustr_opeqeq,ustr_opless,ustr_opgr,ustr_str2ustr,
         ustr_ustr2str,
         *Methods,ustr_clear,ustr_copy,ustr_del,ustr_findch,ustr_fromutf8,
         ustr_insert,ustr_lines,ustr_read,ustr_replace,ustr_reserve,
         ustr_setlen,ustr_split,ustr_substr,ustr_toutf8,ustr_trim,ustr_write  
* 
-----------------------------------------------------------------------------*/

define {
   CP_ACP   = 0  
   CP_UTF8  = 65001
   MB_PRECOMPOSED = 1
}

/*-----------------------------------------------------------------------------
* Id: tustr T ustr
* 
* Summary: The Unicode string type.
*
-----------------------------------------------------------------------------*/

type ustr <index=ushort inherit = buf>
{
   
}

/*-----------------------------------------------------------------------------
* Id: ustr_opless F4
* 
* Summary: Comparison operation.
*  
* Title: ustr < ustr 
*  
* Return: Returns #b(1) if the first string is less than the second one.
          Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint <( ustr left, ustr right )
{
   if CompareStringW( 0, 0, left.ptr(), *left, right.ptr(), 
                      *right ) == 1 : return 1
   return 0
}

/*-----------------------------------------------------------------------------
* Id: ustr_opless_1 FC
* 
* Summary: Comparison operation.
*  
* Title: ustr <= ustr 
*  
* Return: Returns #b(1) if the first string is less or equal the second one.
          Otherwise, it returns #b(0).
*
* Define: operator uint <=( ustr left, ustr right )
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: ustr_opgr F4
* 
* Summary: Comparison operation.
*  
* Title: ustr > ustr 
*  
* Return: Returns #b(1) if the first string is greater than the second one.
          Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint >( ustr left, ustr right )
{
      if CompareStringW( 0, 0, left.ptr(), *left, right.ptr(), 
                         *right ) == 3 : return 1
   return 0
}

/*-----------------------------------------------------------------------------
* Id: ustr_opgr_1 FC
* 
* Summary: Comparison operation.
*  
* Title: ustr >= ustr 
*  
* Return: Returns #b(1) if the first string is greater or equal the second one.
          Otherwise, it returns #b(0).
*
* Define: operator uint >=( ustr left, ustr right )
*
-----------------------------------------------------------------------------*/

/*
operator uint %==( ustr left right )
{
   if *left != *right : return 0 
   return !ustrcmpign( left.ptr(), right.ptr())   
}

operator uint %<( ustr left right )
{
   if ustrcmpign( left.ptr(), right.ptr()) < 0 : return 1
   return 0
}

operator uint %>( ustr left right )
{
   if ustrcmpign(  left.ptr(), right.ptr() ) > 0 : return 1
   return 0
}*/

/*-----------------------------------------------------------------------------
* Id: ustr_opind F4
* 
* Summary: Getting ushort character #b([i]) of the Unicode string.
*  
* Title: ustr[ i ]
*
* Return: The #b([i]) ushort character of the Unicode string.
*
-----------------------------------------------------------------------------*/

method uint ustr.index( uint id )
{   
   return this.ptr() + ( id << 1 )
}

/*-----------------------------------------------------------------------------
* Id: ustr_oplen F4
* 
* Summary: Get the length of a unicode string.
*  
* Return: The length of the unicode string.
*
* Define: operator uint *( ustr left ) 
*
-----------------------------------------------------------------------------*/

operator uint *( ustr src )
{
   return ( src.use >> 1 ) - 1
}

/*-----------------------------------------------------------------------------
* Id: ustr_reserve F2
* 
* Summary: Memory reservation. The method increases the size of the memory 
           allocated for the unicode string. 
*  
* Params: len - The summary requested length of th eunicode string. If it is /
                less than the current size, nothing happens. If the size is /
                increased, the current string data is saved.
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method ustr.reserve( uint len )
{
   this->buf.reserve( len << 1 )
}

/*-----------------------------------------------------------------------------
* Id: ustr_opeq F4
* 
* Summary: Assign types to unicode string. Copy a string to the unicode string
           #b(ustr = str). 
* 
* Title: ustr = type
* 
* Return: The result unicode string.
*
-----------------------------------------------------------------------------*/

operator ustr =( ustr left, str right )
{   
   uint len = ( MultiByteToWideChar( $CP_ACP, $MB_PRECOMPOSED, right.ptr(), 
            *right, left.ptr(), 0 ) + 1 )    
   left.reserve( len )  
   MultiByteToWideChar( $CP_ACP, $MB_PRECOMPOSED, right.ptr(), *right, 
            left.ptr(), len )
   len = len << 1
//      (&((left->buf)[len-2]))->ushort = 0
   ( left.ptr() + len - 2 )->ushort = 0       
   left.use = len   
   return left
}

/*-----------------------------------------------------------------------------
* Id: ustr_opeqa F4
* 
* Summary: Copy a unicode string to a string. 
* 
* Title: str = ustr
* 
* Return: The result string.
*
-----------------------------------------------------------------------------*/

operator str =( str left, ustr right )
{  

   uint len = WideCharToMultiByte( $CP_ACP, 0, right.ptr(), *right, 
                                 left.ptr(), 0, 0, 0 )   
   left.reserve( len + 1 )
   WideCharToMultiByte( $CP_ACP, 0, right.ptr(), *right, 
                              left.ptr(), len + 1, 0, 0  )   
   left.setlen( len /*- 1*/ )   
   return left
}

/*-----------------------------------------------------------------------------
* Id: ustr_setlen F2
* 
* Summary: Setting a new size of the unicode string. The method does not 
           reserve space. 
           You cannot specify the size of a string greater than the reserved 
           space you have. Mostly, this function is used for specifying the 
           size of a string after external functions write data to it.
*  
* Params: len - New string size. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method ustr ustr.setlen( uint len )
{
   len = ( ( len + 1 )<< 1 )
   (&((this->buf)[len-2]))->ushort = 0   
   this.use = len
   return this
}

/*-----------------------------------------------------------------------------
* Id: ustr_setlen_1 FB
* 
* Summary: Recalculate the size of a unicode string to the zero character. The 
           function can be used to determine the size of a string after 
           other functions write data into it.    
* 
-----------------------------------------------------------------------------*/

method ustr ustr.setlenptr
{
   this.setlen( max( int( ( this.size >> 1 ) - 1 ), 0 ))
   return this.setlen( this.findsh( 0, 0 ))
}

/*-----------------------------------------------------------------------------
* Id: ustr_opeq_1 FC
* 
* Summary: Copy a unicode string to another unicode string. 
* 
* Title: ustr = ustr
* 
-----------------------------------------------------------------------------*/

operator ustr =( ustr left, ustr right )
{   
   left->buf = right->buf   
   return left  
}

/*-----------------------------------------------------------------------------
* Id: ustr_str2ustr F4
* 
* Summary: Converting a string to a unicode string #b('ustr( str )'). 
*  
* Title: ustr( str )
* 
* Return: The result unicode string.
*
-----------------------------------------------------------------------------*/

method ustr str.ustr<result>()
{
   result = this   
}

/*-----------------------------------------------------------------------------
* Id: ustr_ustr2str F4
* 
* Summary: Converting a unicode string to a string #b('str( ustr )'). 
*  
* Title: str( ustr )
* 
* Return: The result string.
*
-----------------------------------------------------------------------------*/

method str ustr.str<result>()
{
   result = this   
}

/*-----------------------------------------------------------------------------
* Id: ustr_opadd F4
* 
* Summary: Appending types to the unicode string. Append #b(ustr) to #b(ustr)
           =&gt; #b( ustr += ustr ).
* 
* Title: ustr += type
*
* Return: The result unicode string.
*
-----------------------------------------------------------------------------*/

operator ustr +=( ustr left, ustr right )
{   
   left.use -= 2
   left->buf += right->buf
   return left
}

/*-----------------------------------------------------------------------------
* Id: ustr_opadd_1 FC
* 
* Summary: Append #b(str) to #b(ustr) =&gt; #b( ustr += str ). 
* 
* Title: ustr += str
*
-----------------------------------------------------------------------------*/

operator ustr +=( ustr left, str right )
{   
   return left += right.ustr()
}

/*-----------------------------------------------------------------------------
* Id: ustr_opsum F4
* 
* Summary: Add two strings. Putting two unicode strings together and creating 
           a resulting unicode string.
*  
* Return: The new result unicode string.
*
-----------------------------------------------------------------------------*/

operator ustr +<result> ( ustr left, ustr right )
{
   ( result = left ) += right
}

/*-----------------------------------------------------------------------------
* Id: ustr_opsum_1 FC
* 
* Summary: Add a unicode string and a string.
*  
* Return: The new result unicode string.
*
-----------------------------------------------------------------------------*/

operator ustr +<result>( ustr left, str right )
{
   ( result = left ) += (right.ustr())
}

/*-----------------------------------------------------------------------------
* Id: ustr_write F2
* 
* Summary: Writing a unicode string to a file. 
*  
* Params: filename - The name of the file for writing. If the file already /
                     exists, it will be overwritten. 
* 
* Return: The size of the written data.
*
-----------------------------------------------------------------------------*/

method uint ustr.write( str filename )
{
   uint wr
      
   this->buf.use -= 2
   wr = this->buf.write( filename )
   this->buf.use += 2
   return wr
}

/*-----------------------------------------------------------------------------
* Id: ustr_read F2
* 
* Summary: Read a unicode string from a file.
* 
* Params: filename - Filename.
*
* Return: The size of the read data. 
*
-----------------------------------------------------------------------------*/

method uint ustr.read( str filename )
{
   uint wr      
   
   wr = this->buf.read( filename )
   this->buf.expand(2)
   (&((this->buf)[this.use]))->ushort = 0   
   this.use += 2
   return wr
}

/*-----------------------------------------------------------------------------
* Id: ustr_toutf8 F2
* 
* Summary: Convert a unicode string to UTF-8 string.
* 
* Params: dest - Destination string.
*
* Return: The dest parameter. 
*
-----------------------------------------------------------------------------*/

method str ustr.toutf8( str dest )
{
   uint len = WideCharToMultiByte( $CP_UTF8, 0, this.ptr(), -1, dest.ptr(), 
            0, 0, 0 ) 
   dest.reserve( len )
   WideCharToMultiByte( $CP_UTF8, 0, this.ptr(), -1, dest.ptr(), len, 0, 0  )   
   dest.setlen( len - 1 )
   return dest
}

/*-----------------------------------------------------------------------------
* Id: ustr_fromutf8 F2
* 
* Summary: Convert a UTF-8 string to a unicode string.
* 
* Params: src - Source UTF-8 string.
*
* Return: #lng/retobj#. 
*
-----------------------------------------------------------------------------*/

method ustr ustr.fromutf8( str src )
{
   uint len = ( MultiByteToWideChar( $CP_UTF8, 0, src.ptr(), *src, 
               this.ptr(), 0 ) + 1 )    
   this.reserve( len )  
   len = len << 1
   MultiByteToWideChar( $CP_UTF8, 0, src.ptr(), *src, this.ptr(), len  )
   (&((this->buf)[len-2]))->ushort = 0      
   this.use = len   
   return this
}

/*func ustr fromutf8<result>( str src )
{
   result.fromutf8( src )
}*/

/*-----------------------------------------------------------------------------
* Id: ustr_substr F2
* 
* Summary: Getting a unicode substring. 
*  
* Params: src - Initial unicode string. 
          start - Substring offset. 
          len - Substring size. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method ustr ustr.substr( ustr src, uint start, uint len )
{
   uint blen = len << 1
   this.reserve( len )
   this->buf.copy( src.ptr() + ( start << 1 ), blen )
   this.setlen( len ) 
   return this
}

method ustr ustr.init()
{
   this->buf.reserve( 2 )
   this.setlen( 0 )
   return this
}

/*-----------------------------------------------------------------------------
* Id: ustr_findch F2
* 
* Summary: Find the character in the unicode string. 
*  
* Params: off - The offset to start searching from.
          symbol - Search character.
*
* Return: The offset of the character if it is found. If the character is not 
          found, the length of the string is returned.
*
-----------------------------------------------------------------------------*/

method uint ustr.findch( uint off, ushort symbol )
{
   /*uint i   
   fornum i = off, *this
   {
      if this[i] == symbol 
      {
         break
      }
   }
   return i*/
   return .findsh( off, symbol )
}

/*-----------------------------------------------------------------------------
* Id: ustr_findch_1 FA
* 
* Summary: Find the character in the unicode string from the beginning of 
           the string. 
*  
* Params:  symbol - Search character.
*
-----------------------------------------------------------------------------*/

method uint ustr.findch( ushort symbol )
{   
   //return .findch( 0, symbol )
   return .findsh( 0, symbol ) 
}

/*-----------------------------------------------------------------------------
* Id: ustr_del F2
* 
* Summary: Delete a substring. 
*  
* Params: off - The offset of the substring being deleted. 
          len - The size of the substring being deleted. 
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method ustr ustr.del( uint off, uint len )
{
   uint slen = *this 

   if off > slen : return this
   if off + len > slen : len = slen - off  
   this->buf.del( off<<1, len<<1 )   
   this.setlen( slen - len )
      
   return this
}

/*-----------------------------------------------------------------------------
* Id: ustr_trim F2
* 
* Summary: Trimming a unicode string. 
* 
* Title: ustr.trim...
*
* Params: symbol - The character being deleted.
          flag - Flags. $$[trimflags]
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method ustr ustr.trim( uint symbol, uint flag )
{
   uint rsymbol = symbol
   uint i, found
   
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
   if flag & $TRIM_SYS
   {
      if  flag & $TRIM_RIGHT 
      {         
         i = *this-1
         while this[i] <= 0x0020
         {
            this.setlen( i )
            if flag & $TRIM_ONE : break
            i--
         }
      }
      if  flag & $TRIM_LEFT
      {   
         fornum i = 0, *this 
         {
            if this[i] <= 0x0020
            {
               found++
               if flag & $TRIM_ONE : break
            }
            else : break
         }
         if found : this.del( 0, found )
      }
   }
   else
   {
      if  flag & $TRIM_RIGHT 
      {
         i = *this-1
         while this[i] == symbol
         {            
            this.setlen( i )
          //  print( "setlen \(*this) \(this.str())  \(this[8]) \(this[9])\n" )
            if flag & $TRIM_ONE : break
            i--
         }
      }
      if  flag & $TRIM_LEFT
      {
         fornum i = 0, *this 
         {
            if this[i] == symbol
            {
               found++
               if flag & $TRIM_ONE : break
            }
            else : break
         }
         if found : this.del( 0, found )
      }
   }

   return this;
}

/*-----------------------------------------------------------------------------
* Id: ustr_trim_1 FB
* 
* Summary: Deleting spaces on the right.
*
-----------------------------------------------------------------------------*/

method ustr ustr.trimrspace()
{
   return this.trim( ' ', $TRIM_RIGHT )
}

/*-----------------------------------------------------------------------------
* Id: ustr_trim_2 FB
* 
* Summary: Deleting spaces on the both sides.
*
-----------------------------------------------------------------------------*/

method ustr ustr.trimspace()
{
   return this.trim( ' ', $TRIM_RIGHT | $TRIM_LEFT )
}

/*-----------------------------------------------------------------------------
* Id: ustr_copy F2
* 
* Summary: Copying. The method copies the specified size of the data into 
           a unicode string.
*  
* Params: ptr - The pointer to the data being copied. If data does not end in /
                a zero, it will be added automatically.
          size - The size of the data being copied. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method ustr ustr.copy( uint ptr, uint size )
{
   this->buf.copy( ptr, size << 1 )
   .setlen( size )
   return this
}

/*-----------------------------------------------------------------------------
* Id: ustr_copy_1 FB
* 
* Summary: The method copies data into a unicode string.
*  
* Params: ptr - The pointer to the data being copied. All data to the zero  /
          ushort will be copied.  
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method ustr ustr.copy( uint ptr )
{   
   .copy( ptr, mlensh( ptr ))
   return this   
}

/*-----------------------------------------------------------------------------
* Id: ustr_replace F2
* 
* Summary: Replacing in a unicode string. The method replaces data in 
           a unicode string. 
* 
* Params: offset - The offset of the data being replaced. 
          size - The size of the data being replaced. 
          value - The unicode string being inserted. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method ustr ustr.replace( uint offset, uint size, ustr value )
{
   if offset >= *this : this += value
   else
   {
      value->buf.use -= 2
      this->buf.replace( offset << 1, size << 1, value->buf )   
      value->buf.use += 2
   }
   return this
}

/*-----------------------------------------------------------------------------
* Id: ustr_insert F2
* 
* Summary: Insertion. The method inserts one unicode string into another. 
* 
* Params: offset - The offset where string will be inserted. 
          value - The unicode string being inserted. 
*
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method ustr ustr.insert( uint offset, ustr value )
{
   return this.replace( offset, 0, value )
}

/*-----------------------------------------------------------------------------
* Id: ustr_opeqeq F4
* 
* Summary: Comparison operation.
*  
* Return: Returns #b(1) if the strings are equal. Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint ==( str left, ustr right )
{     
   return left.ustr() == right
}

/*-----------------------------------------------------------------------------
* Id: ustr_opeqeq_1 FC
* 
* Summary: Comparison operation.
*  
* Return: Returns #b(1) if the strings are equal. Otherwise, it returns #b(0).
*
-----------------------------------------------------------------------------*/

operator uint ==( ustr left, str right )
{     
   return left == right.ustr()
}

/*-----------------------------------------------------------------------------
* Id: ustr_clear F3
* 
* Summary: Clearing a unicode string. 
* 
* Return: #lng/retobj#
*
-----------------------------------------------------------------------------*/

method ustr ustr.clear
{
   return this.setlen( 0 )
}

/* gentee !!! */
method ustr ustr.appendch( uint ch )
{
   uint len = this->buf.use      
   this->buf.expand(2)
   this->buf.use += 2   
   (&((this->buf)[len-2]))->ushort = ch
   (&((this->buf)[len]))->ushort = 0
   return this   
}