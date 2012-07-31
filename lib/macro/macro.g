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

//-------------------------------------------------

type macroitem
{
   ustr  value      // value
   uint  dynamic    // dynamic function    
}

type macro< index = ustr >
{
   ushort syschar
   hash   vals of macroitem
   ubyte  slash
}

//-------------------------------------------------

method macro macro.init
{
   this.syschar = '#'
   this.vals.ignorecase()
   return this
}

//-------------------------------------------------

method uint macro.index( str key )
{
   uint  it
   
   it as this.vals[ key ]
   if it.dynamic : it.dynamic->func( key, it ) 
   return &( it.value )
}

//-------------------------------------------------

method macro.dynamic( str key, uint dynfunc )
{
   this.vals[ key ].dynamic = dynfunc
}

//-------------------------------------------------

method uint macro.ismacro( str name )
{
   return this.vals.find( name ) != 0
}

//-------------------------------------------------

method ustr macro.replace( ustr result, uint level )
{
   uint i
   ustr  val

   if !*result: return result
      
   while ( i = result.findch( i, this.syschar )) < *result
   {
      uint end
      str  key
    
      end = result.findch( ++i, this.syschar ) 
      if end >= *result : break
      key = str( val.substr( result, i, end - i ))      
      if this.vals.find( key ) && (val = this[ key ]) != result 
      {
         if level < 10 : this.replace( val, level + 1 )
         if this.slash && !level
         {
            uint off

            while ( off = val.findch( off, '\' )) < *val
            {
               val.insert( ++off, ustr( "\\" ))
               off++
            }
         } 
         result.replace( i - 1, end - i + 2, val )
         i += *val - 1
      }                  
   }
   return result
}  

method ustr macro.replace( ustr result )
{
   return this.replace( result, 0 )  
}

//-------------------------------------------------

method str macro.replace( str result )
{
   return result = str( this.replace( ustr( result )))
}

//-------------------------------------------------

method ustr macro.get( str name, ustr result )
{
   result.clear()
   if this.vals.find( name ) : this.replace( result = this[ name ] )
   
   return result
}

//-------------------------------------------------

method str macro.get( str name, str result )
{
   ustr uval
   
   return result = str( this.get( name, uval ))
}

//-------------------------------------------------

method int macro.getint( str name )
{
   ustr stemp
   
   return int( str( this.get( name, stemp )))
}

//-------------------------------------------------

method long macro.getlong( str name )
{
   ustr stemp
   
   return long( str( this.get( name, stemp )))
}

//-------------------------------------------------

method macro.set( str name, int val )
{
   this[ name ] = ustr( str( val ))
}

//-------------------------------------------------

method macro.set( str name, str value )
{
   this[ name ] = ustr( value )
}

//-------------------------------------------------

method macro.setutf8( str name, str value )
{
   this[ name ].fromutf8( value )
}

//-------------------------------------------------

method macro.set( str name, long val )
{
   this[ name ] = ustr( str( val ))
}

//-------------------------------------------------

method macro.setchar( uint syschar )
{
   this.syschar = syschar
}

//-------------------------------------------------
/*
method uint macro.load( str macrolist )
{
   uint i count
   arr  data of str
   
   macrolist.split( data, 0xA, $SPLIT_NOSYS )
   fornum i, *data
   {
      arr vals of str
      data[i].split( vals, '=', $SPLIT_NOSYS | $SPLIT_FIRST )
      if *vals > 1
      {
         this[ vals[0]] = vals[1]
         count++
      }   
   }
   return count
}
*/
//-------------------------------------------------

operator macro +=( macro left, macro right )
{
   foreach cur, right.vals.keys
   {
      left[ cur ] = right[ cur ]   
   }
   return left
}

//-------------------------------------------------
/*
func main<main>
{
   ustr result
   macro macros 
      
   macros["ve"] = ustr("ве")
   macros["test"] = ustr("Про#ve#рка")
   result = ustr("#test# esese #test# 333 #test#?")
   macros.replace( result )
   print( "val=\( hex2stru( ustr("#").ptr()->uint ))\n")
   congetch( str( result ))
}
*/
