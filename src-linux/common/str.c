/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: str 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
* Summary: This file provides functionality for 'str' type.
*
******************************************************************************/

#include "str.h"
#include "../genteeapi/gentee.h"
#include "../os/user/defines.h"


#ifdef LINUX
pstr  STDCALL str_appendb( pstr str, byte one )
{
   uint temp;

   temp = one;
   str->use--;
   return ( pstr )buf_appenduint( &str, temp );
}

//--------------------------------------------------------------------------

pstr  STDCALL str_appendpsize( pstr str, pubyte src, uint len )
{
   str->use--;
   return ( pstr )buf_append( &str, src, len + 1 );
}

//--------------------------------------------------------------------------

pstr  STDCALL str_appendp( pstr str, pubyte src )
{
   return str_appendpsize( str, src, mem_len( src ));
}

#endif

/*-----------------------------------------------------------------------------
* Id: str_opadd F4
* 
* Summary: Appending types to the string. Append #b(str) to #b(str) =&gt; 
           #b( str += str ).
*  
* Title: str += type
*
* Return: The result string.
*
* Define: operator str +=( str left, str right ) 
*
-----------------------------------------------------------------------------*/

pstr  STDCALL str_add( pstr dest, pstr src )
{
   dest->use--;
   return buf_add( dest, src );
}

/*-----------------------------------------------------------------------------
* Id: str_opadd_1 FC
* 
* Summary: Append #b(uint) to #b(str) =&gt; #b( str += uint ).
*  
* Define: operator str +=( str left, uint right ) 
*
-----------------------------------------------------------------------------*/

pstr   STDCALL str_appenduint( pstr ps, uint val )
{
   return str_printf( ps, "%u", val );
}

/*-----------------------------------------------------------------------------
* str_clear F3
* 
* Summary: Clear the string.
*  
* Return: #lng/retobj#
*
* Define: method str str.clear()  
*
-----------------------------------------------------------------------------*/

pstr   STDCALL str_clear( pstr ps )
{
   ps->use = 1;
   ps->data[0] = 0;

   return ps;
}

/*-----------------------------------------------------------------------------
* Id: str_opeq F4
* 
* Summary: Copy the string.
*  
* Return: The result string.
*
* Define: operator str =( str left, str right ) 
*
-----------------------------------------------------------------------------*/

pstr  STDCALL str_copy( pstr dest, pstr src )
{
   return buf_copy( ( pbuf )dest, str_ptr( src ), src->use );
}

/*-----------------------------------------------------------------------------
* Id: str_copy F2
* 
* Summary: Copying. The method copies data into a string.
*  
* Title: str.copy...
*
* Params: ptr - The pointer to the data being copied. All data to the zero /
                character will be copied.
*
* Return: #lng/retobj#
*
* Define: method str str.copy( uint ptr ) 
*
-----------------------------------------------------------------------------*/

pstr   STDCALL str_copyzero( pstr ps, pubyte src )
{
   ps->use--;
   buf_copyzero( ps, src );
   return ps;
}

/*-----------------------------------------------------------------------------
* Id: str_copy_1 FA
* 
* Summary: The method copies the specified size of the data into a string.
*  
* Params: ptr - The pointer to the data being copied. If data does not end in /
                a zero, it will be added automatically.
          len - The size of the data being copied. 
*
* Return: #lng/retobj#
*
* Define: method str str.load( uint ptr, uint len ) 
*
-----------------------------------------------------------------------------*/

pstr   STDCALL str_copylen( pstr ps, pubyte src, uint len )
{
   ps->use--;
//   print("String Load %i %x\n", len, src );
   buf_copy( ps, src, len );
   return buf_appendch( ps, 0 );
}

//--------------------------------------------------------------------------

pstr STDCALL str_dirfile( pstr dir, pstr name, pstr ret )
{
   str_copy( ret, dir );
   str_trim( ret, SLASH, TRIM_ONE | TRIM_RIGHT );
   return str_printf( ret, "%c%s", SLASH, str_ptr( name ));
}

/*-----------------------------------------------------------------------------
* Id: str_substr F2
* 
* Summary: Getting a substring. 
*  
* Params: src - Initial string. 
          off - Substring offset. 
          len - Substring size. 
*
* Return: #lng/retobj#
*
* Define: method str str.substr( str src, uint off, uint len ) 
*
-----------------------------------------------------------------------------*/

pstr STDCALL str_substr( pstr dest, pstr src, uint off, uint len )
{
   uint slen = str_len( src );

   if ( len && off < slen )
   {
      if ( len > slen - off )
         len = slen - off;
      str_copylen( dest, str_ptr( src ) + off, len );
   }
   else 
      str_clear( dest );

   return dest;
}

#ifndef NOGENTEE

/*-----------------------------------------------------------------------------
*
* ID: str_getdirfile 19.10.06 0.0.A.
* 
* Summary: Get directory and filename
*
-----------------------------------------------------------------------------*/

uint STDCALL str_getdirfile( pstr src, pstr p_dir, pstr name )
{
#ifdef LINUX
   pstr p_drive1,p_path1,p_fname1,p_fext1,p_slesh1;
   ubyte gdf_drive[11];
   ubyte gdf_path[PATH_MAX+1];
   ubyte gdf_fname[71];
   ubyte gdf_fext[31];
   char  cur[512];
   os_splitpath(str_ptr(src),gdf_drive,gdf_path,gdf_fname,gdf_fext);
   p_slesh1 = str_new((pubyte)"/");
   if (strlen(gdf_path)==0)
   //if (strlen(str_ptr(dir))==0)
   {
     getcwd( cur, 512 );
     //p_path1 = str_new(cur);
     strcpy(gdf_path,cur);
     //Slesh add
     //str_setlen( dir,getcwd( str_ptr( dir), 512 ));
     //str_add(p_path1,p_slesh1);
   }
   else
     p_path1 = str_new(gdf_path);

   //p_fname1 = str_new(gdf_fname);
   //p_fext1 = str_new(gdf_fext);
   if (name) {
    str_copyzero(name,gdf_fname);
    //str_reserve( name, 512 );
    //str_add(name,p_fname1);
    str_setlen(name, str_len(name));
   }
   if (p_dir) {
    str_reserve( p_dir, 512 );
    str_copyzero(p_dir,gdf_path);
    //str_add(dir,p_path1);
    str_setlen(p_dir, str_len(p_dir));
   }

   str_destroy(p_path1);
   str_destroy(p_slesh1);
   //str_destroy(p_fname1);
   //str_destroy(p_fext1);
#else
   uint   separ = str_find( src, 0, SLASH, 1 );
   uint   off;

   off = separ >= str_len( src ) ? 0 : separ + 1;
   
   if ( name )
      str_copyzero( name, str_ptr( src ) + off );
   if ( dir )
      str_substr( p_dir, src, 0, separ < str_len( src ) ? separ : 0 );
#endif
   return 1;
}

#endif // NOGENTEE

pstr STDCALL str_init( pstr ps )
{
   mem_zero( ps, sizeof( str ));
   
   buf_alloc( ps, 32 );
   ps->data[0] = 0;
   ps->use = 1;
//   print("String Init ps=%x len = %i data = %x ptr=%s\n", ps, ps->use, ps->data,
//          ps->data );
   return ps;
}

#ifndef NOGENTEE

/*-----------------------------------------------------------------------------
* Id: str_find F2
* 
* Summary: Find the character in the string. 
*  
* Title: str.find...
*
* Params: offset - The offset to start searching from.
          symbol - Search character.
          fromend - If it equals 1, the search will be carried out from the /
                    end of the string.
*
* Return: The offset of the character if it is found. If the character is not 
          found, the length of the string is returned.
*
* Define: method uint str.findch( uint offset, uint symbol, uint fromend ) 
*
-----------------------------------------------------------------------------*/

uint  STDCALL str_find( pstr ps, uint offset, ubyte symbol, uint fromend )
{
   pubyte   cur = ps->data + offset;
   pubyte   end = ps->data + str_len( ps ); 
   pubyte   last;

   if ( _gentee.multib )
   {
      last = end;
      while ( cur < end )
      {
         if (
    #ifdef LINUX
       0
    #else
         os_isleadbyte( *cur )
     #endif
       )
            cur++;
         else
            if ( *cur == symbol )
               if ( fromend )
                  last = cur;
               else
                  break;
         cur++;
      }
      if ( fromend )
         cur = last;
   }
   else
      if ( fromend )
      {
         cur = end;
         while ( cur >= ps->data )
         {
            if ( *cur == symbol )
               break;
            cur--;
         }
         if ( cur < ps->data )
            cur = end;
      }
      else
      {
         while ( cur < end )
         {
            if ( *cur == symbol )
               break;
            cur++;
         }
      }

   return ( cur < end ? cur - ps->data : str_len( ps ));
}

/*-----------------------------------------------------------------------------
* Id: str_find_1 FA
* 
* Summary: Find the character from the beginning of the string. 
*  
* Params: symbol - Search character.
*
* Define: method uint str.findch( uint symbol ) 
*
-----------------------------------------------------------------------------*/

uint  STDCALL str_findch( pstr ps, ubyte symbol )
{
   return str_find( ps, 0, symbol, 0 );
}

#endif

/*-----------------------------------------------------------------------------
* Id: str_oplen F4
* 
* Summary: Get the length of a string.
*  
* Return: The length of the string.
*
* Define: operator uint *( str left ) 
*
-----------------------------------------------------------------------------*/

uint  STDCALL str_len( pstr ps )
{
   return ps->use - 1;
}

/*-----------------------------------------------------------------------------
*
* ID: str_print 19.10.06 0.0.A.
* 
* Summary: Output wsprintf to str.
*  
-----------------------------------------------------------------------------*/

pstr  CDECLCALL str_printf( pstr ps, pubyte output, ... ) 
{
   va_list args;
   uint    len = ps->use - 1;

   str_expand( ps, 512 );
   va_start( args, output );
   str_setlen( ps, len + vsprintf( ps->data + len, output, args ));
   va_end( args );

   return ps;
}

#ifndef NOGENTEE

/*-----------------------------------------------------------------------------
* Id: str_printf F2
* 
* Summary: Write formatted data to a string. The method formats and stores a 
           series of characters and values in string. Each argument is 
           converted and output according to the corresponding C/C++ format 
           specification (printf) in format parameter.
*  
* Params: format - The format of the output. 
          clt - Optional arguments.
*
* Return: #lng/retobj#
*
* Define: method str str.printf( str format, collection clt ) 
*
-----------------------------------------------------------------------------*/

pstr  STDCALL str_sprintf( pstr ps, pstr output, pcollect pclt ) 
{
   uint  args[32];
   uint  len = ps->use - 1;
   uint  i, k = 0, itype;

   str_expand( ps, 1024 );
   for ( i = 0; i < collect_count( pclt ); i++ )
   {
      itype = collect_gettype( pclt, i );
      if ( itype == TDouble || itype == TLong || itype == TUlong )
      {
         args[k++] = *( puint )collect_index( pclt, i );
         args[k++] = *(( puint )collect_index( pclt, i ) + 1 );
      }
      else
      {
         args[k++] = *( puint )collect_index( pclt, i );
         if ( itype == TStr )
            args[k - 1] = (uint)(( pstr )args[k - 1])->data;
      }
   }
   str_setlen( ps, len + vsprintf( ps->data + len, output->data, (pubyte)args ));

   return ps;
}

#endif // NOGENTEE

/*-----------------------------------------------------------------------------
* Id: str_out4 F2
* 
* Summary: Output a 32-bit value. The value is appended at the end of the 
           string.
*  
* Params: format - The format of the output. It is the same as in the function /
                   'printf' in C programming language.
          val - 32-bit value to be appended.
*
* Return: #lng/retobj#
*
* Define: method str str.out4( str format, uint val ) 
*
-----------------------------------------------------------------------------*/

pstr  STDCALL str_out4( pstr ps, pstr format, uint val ) 
{
   return str_printf( ps, str_ptr( format ), val );
}

/*-----------------------------------------------------------------------------
* Id: str_out4_1 FA
* 
* Summary: Output a 64-bit value. The value is appended at the end of the 
           string.
*  
* Params: format - The format of the output. It is the same as in the function /
                   'printf' in C programming language.
          val - 64-bit value to be appended.
*
* Return: #lng/retobj#
*
* Define: method str str.out8( str format, ulong val ) 
*
-----------------------------------------------------------------------------*/

pstr  STDCALL str_out8( pstr ps, pstr format, ulong64 val ) 
{
//   print("Printf %x %s %I64u\n", ps, str_ptr(ps), format );
//   print("Printf %s\n", str_ptr( format ) );
   return str_printf( ps, str_ptr( format ), val );
}

#ifndef NOGENTEE

/*-----------------------------------------------------------------------------
* Id: str_print F3
* 
* Summary: Print a string into the console window.
*  
* Define: method str.print() 
*
-----------------------------------------------------------------------------*/

void  STDCALL str_output( pstr ps ) 
{
   _gentee.print( str_ptr( ps ), str_len( ps ));
}

#endif

/*-----------------------------------------------------------------------------
* Id: str_print_1 F8
* 
* Summary: Print a string into the console window.
*
* Params: output - The output string.
*  
* Define: func print( str output ) 
*
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
* Id: str_setlen F2
* 
* Summary: Setting a new string size. The method does not reserve space. 
           You cannot specify the size of a string greater than the reserved 
           space you have. Mostly, this function is used for specifying the 
           size of a string after external functions write data to it.
*  
* Params: len - New string size. 
*
* Return: #lng/retobj#
*  
* Define: method str str.setlen( uint len ) 
*
-----------------------------------------------------------------------------*/

pstr   STDCALL str_setlen( pstr ps, uint len )
{
   if ( len >= ps->size )
      len = 0;

   ps->use = len + 1;
   ps->data[ len ] = 0;

   return ps;
}

/*-----------------------------------------------------------------------------
*
* ID: str_trim 19.10.06 0.0.A.
* 
* Summary: Trim left and right characters
*  
* Params: 
*
-----------------------------------------------------------------------------*/

pstr STDCALL str_trim( pstr ps, uint symbol, uint flag )
{
   uint len = str_len( ps );
/*   uint rsymbol = symbol
   
   if flag & $TRIM_PAIR
   {
      switch symbol
      {
         case '(' : rsymbol = ')'
         case '{' : rsymbol = '}'
         case '[' : rsymbol = ']'
         case '<' : rsymbol = '>'
      }      
   }*/
   if  ( flag & TRIM_RIGHT )
   {
      uint i = len;

      while ( i && ps->data[ i - 1 ] == symbol )
      {
         i--;
         if ( flag & TRIM_ONE )
            break;
      }
      if ( i < len )
         str_setlen( ps, i );
   }
/*   if  flag & $TRIM_LEFT
   {
      uint   cur = this.ptr()
      uint   end = cur + *this

      while cur < end && cur->byte == symbol
      {
         cur++
         if flag & $TRIM_ONE : break
      }
      if cur != this.ptr() : this.del( 0, cur - this.ptr())
   }
*/
   return ps;
}

/*-----------------------------------------------------------------------------
*
* ID: str_new 19.10.06 0.0.A.
* 
* Summary: Create str object.
*  
-----------------------------------------------------------------------------*/

pstr  STDCALL str_new( pubyte ptr )
{
   pstr  ret = mem_alloc( sizeof( str ));

   str_init( ret );
   if ( ptr )
      str_copyzero( ret, ptr );

   return ret;
}

/*-----------------------------------------------------------------------------
*
* ID: str_destroy 19.10.06 0.0.A.
* 
* Summary: Destroy str object.
*  
-----------------------------------------------------------------------------*/

void  STDCALL str_destroy( pstr ps )
{
   str_delete( ps );
   mem_free( ps );
}

/*-----------------------------------------------------------------------------
*
* ID: str_isequalign 19.10.06 0.0.A.
* 
* Summary: If two string equal.
*  
-----------------------------------------------------------------------------*/

uint   STDCALL str_isequalign( pstr left, pstr right )
{
   return left->use == right->use && 
           !mem_cmpign( str_ptr( left ), str_ptr( right ), left->use );
}

/*-----------------------------------------------------------------------------
*
* ID: str_pos2line 19.10.06 0.0.A.
* 
* Summary: Get the line from absolute position.
*  
-----------------------------------------------------------------------------*/

uint  STDCALL str_pos2line( pstr ps, uint pos, puint lineoff )
{
   uint    i, off = 0;
   uint    line = 0;
   pubyte  cur = str_ptr( ps );

   for ( i = 0; i < pos; i++ )
   {
      if ( cur[i] == 0xA )
      {
         line++;
         off = i + 1;
      }
   }
   if ( lineoff )
      *lineoff = pos - off;
   return line;
}

//--------------------------------------------------------------------------

uint  STDCALL ptr_wildcardignore( pubyte src, pubyte mask )
{
   while ( 1 )
   {
      if ( !*src )
         return ( !*mask || ( *mask == '*' && !*( mask + 1 ))) ? TRUE : FALSE; 
      if ( !*mask )
         break;
      if ( os_lower( ( pubyte )*src ) == os_lower( ( pubyte )*mask ) ||
                      *mask == '?' )
      {
         src++;
         mask++;
      }
      else
         if ( *mask == '*' )
         {
            if ( os_lower( ( pubyte )*src ) == os_lower( ( pubyte )*( mask + 1 )) &&
                   ptr_wildcardignore( src, mask + 1 ))
               return TRUE;
            src++;
         }
         else
            break;
   }
   return FALSE;
}

#ifndef NOGENTEE

/*-----------------------------------------------------------------------------
* Id: str_fwildcard F2
*
* Summary: Wildcard check. Check if a string coincides with the specified mask.  
* 
* Params: wildcard - The mask being checked. It can contain '?' (one character) /
                     and '*' (any number of characters).  
*
* Return: Returns 1 if the string coincides with the mask.
*
* Define: method uint str.fwildcard( str wildcard )
*
-----------------------------------------------------------------------------*/

uint   STDCALL str_fwildcard( pstr name, pstr mask )
{
   uint   ret;
   uint   dotstr;
   uint   dotmask;
   pubyte pname = str_ptr( name );
   pubyte pmask = str_ptr( mask );
   uint   isstr = FALSE;
   uint   ismask = FALSE;
   uint   empty = 0;

   dotstr = str_find( name, 0, '.', TRUE );
   dotmask = str_find( mask, 0, '.', TRUE );

   if ( pname[ dotstr ] )
   {
      pname[ dotstr ] = 0;
      isstr = TRUE;
   }
   if ( pmask[ dotmask ] )
   {
      pmask[ dotmask ] = 0;
      ismask = TRUE;
   }
   ret = ptr_wildcardignore( pname, pmask );
   if ( ismask || ( isstr && pmask[ dotmask - 1 ] != '*' ))
      ret &= ptr_wildcardignore( isstr ? pname + dotstr + 1 : ( pubyte )&empty,
                              ismask ? pmask + dotmask + 1 : ( pubyte )&empty );
   if ( isstr )
      pname[ dotstr ] = '.';
   if ( ismask )
      pmask[ dotmask ] = '.';
   return ret;
}

#endif
//--------------------------------------------------------------------------
