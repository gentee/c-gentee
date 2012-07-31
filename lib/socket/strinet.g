/******************************************************************************
*
* Copyright (C) 2004-2008, The Gentee Group. All rights reserved. 
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
* Id: str_ihead F2
*
* Summary: Getting a header. The method is used to get the message header. 
           It will be written to the string for which the method was called.
           Besides, the header will be deleted from the data object.
*
* Params: data - The buffer of the string containing the data being processed.  
*  
* Return: #lng/retobj# 
*
-----------------------------------------------------------------------------*/

method str str.ihead( buf data )
{
   uint i
   
   this.clear()
   
   while !"\00D\00A".eqlen( data.ptr() + i )
   {
      i = data->str.findchfrom( 0x0A, i ) + 1
      if i >= data.use : return this
   }
   this.copy( data.ptr(), i + 2 )
   data.del( 0, i + 2 )
   
   return this
}

/*-----------------------------------------------------------------------------
* Id: str_iurl F2
*
* Summary: The method is used to parse a URL address. 
*
* Params: host - The string for getting the host name. 
          port - The string for getting the port. 
          path - The string for getting the relative path. 
*  
* Return: 1 is returned if the FTP protocol was specified. Otherwise, 0 is
          returned. 
*
-----------------------------------------------------------------------------*/

method uint str.iurl( str host, str port, str path )
{
   arrstr  names 
   arrstr  hosts 
   str  stemp = this
   uint ret = $INET_HTTP

   if !*this : return ret   
   if "http://".eqlenign( stemp.ptr()) : stemp.del( 0, 7 )                  
   elif "ftp://".eqlenign( stemp.ptr())
   {
      stemp.del( 0, 6 )
      ret = $INET_FTP
   }
   stemp.split( names, '/', $SPLIT_FIRST )
   names[0].split( hosts, ':', $SPLIT_FIRST )
   host = hosts[0]
   if *hosts > 1 : port = hosts[1]
   if *names > 1 : path = names[1]
         
   return ret
}

method datetime.frominet( str value )
{
   uint i
   arrstr   month 
   arrstr   day
   arrstr   arval
    
   month += "Jan"; month += "Feb"; month += "Mar"; month += "Apr"
   month += "May"; month += "Jun"; month += "Jul"; month += "Aug"
   month += "Sep"; month += "Oct"; month += "Nov"; month += "Dec"

   day += "Sun"; day += "Mon"; day += "Tue"; day += "Wed"
   day += "Thu"; day += "Fri"; day += "Sat"
   
   uint mode tmode
   arrstr  dtime 
   str  stemp
   /* 0 - RFC 1123 1 - RFC 850 2 - ASCTIME */
   
   ( stemp = value ).split( arval, ' ', $SPLIT_NOSYS )
   if *arval < 4 : return
   if !arval[0].islast( ',' ) : mode = 2
   elif *arval < 5 : mode = 1

   fornum i = 0, *day
   {
      if day[i].eqlenign( arval[0] )
      {
         this.dayofweek = i
         break
      }
   }          
   switch mode
   {
      case 0 
      {
         this.day = uint( arval[1] )
         stemp = arval[2]
         this.year = uint( arval[ 3 ] )
         tmode = 4
      }
      case 1 
      { 
         arval[1].split( dtime, '-', $SPLIT_NOSYS )
         this.day = uint( dtime[ 0 ] )
         stemp = dtime[1]
         if *dtime[2] == 2
         {
            this.year = uint( dtime[ 2 ] ) + 1900
            if this.year < 1970 : this.year += 100            
         }
         else : this.year = uint( dtime[2] )
         tmode = 2
      }
      case 2 
      {
         this.day = uint( arval[2] )
         this.year = uint( arval[ 4 ] )
         stemp = arval[1]
         tmode = 3
      }
   }
   fornum i = 0, *month
   {
      if stemp %== month[i] 
      {
         this.month = i + 1
         break
      } 
   }
   arval[ tmode ].split( dtime, ':', $SPLIT_NOSYS )
   this.hour = uint( dtime[0] )
   this.minute = uint( dtime[1] )
   this.second = uint( dtime[2] )
}

/*-----------------------------------------------------------------------------
* Id: str_ihttpinfo F2
*
* Summary: Processing a header. The method processes a string as an HTTP 
           header and writes data it gets into the #a(thttpinfo) structure.  
*
* Params: hi - The variable of the #a( thttpinfo ) type for getting the /
               results.
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/
method uint str.ihttpinfo( httpinfo hi )
{
   uint  i   
   arrstr   val 
   arrstr   lines 
   
   this.split( lines, 0xA, $SPLIT_NOSYS )
   if !*lines || !"HTTP".eqlenign( this.ptr() ) : return 0
   lines[0].split( val, ' ', $SPLIT_NOSYS )
   hi.code = uint( val[1] )
     
   foreach cur, lines
   {
      cur.split( val, ':', $SPLIT_NOSYS | $SPLIT_FIRST )
            
      if *val == 1 : continue
      switch val[0]
      {
         case "Content-Length" : hi.size = val[1]                      
         case "Location" : hi.location = val[1]
         case "Last-Modified" 
         {
            hi.dt.frominet( val[1] ) 
         }
      }
   }
   return 1
}

/*-----------------------------------------------------------------------------
* Id: str_iencoding F2
*
* Summary: Recoding a string. The method recodes the specified string in order
           to send it using the POST method. Spaces are replaced with '+',
           special characters are replaced with their hexadecimal
           representations #b(%XX). The result will be written to the string 
           for which the method was called. 
*
* Params: src - The string for recoding.      
*  
* Return: #lng/retobj# 
*
-----------------------------------------------------------------------------*/

method str str.iencoding( str src )
{
   uint i 
   
   fornum i, *src
   {
      switch src[i]
      {
         case '%', '&', 0x27, '+', '=', '?' 
         {
            this.appendch('%')
            //hex2stru( this, src[i] )
            this.hexu( src[i] )
         }
         case ' ' : this.appendch('+')
         default : this.appendch( src[i] )
      }   
   }
   return this
}