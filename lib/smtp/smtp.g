/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

include : $"..\socket\internet.g"
include : $"..\endecode\base64.g"

type smtp
{
   str    username
   str    password
   socket sock        // Главный сокет
	uint   notify      // Функция для уведомлений
	inetnotify ni
}

define
{
/*	SMTP_OK      = 220
	SMTP_GOODBYE = 221
   SMTP_HELLO   = 250
*/
   ERRSMTP_RESPONSE = 1
   ERRSMTP_QUIT 
   
   NFYSMTP_RESPONSE = $NFYFTP_RESPONSE
   NFYSMTP_SENDCMD = $NFYFTP_SENDCMD
}
/*
type timetm {
        int tm_sec
        int tm_min
        int tm_hour
        int tm_mday
        int tm_mon
        int tm_year
        int tm_wday
        int tm_yday
        int tm_isdst
}

import "msvcrt.dll" <cdeclare> 
{
   uint strftime( uint, uint, uint, timetm )
}

method str str.formatdate( datetime dt, str format )
{
   timetm tm
   int   len
   
   this.clear()
   this.reserve( 64 )   
   tm.tm_sec = dt.second
   tm.tm_min = dt.minute
   tm.tm_hour = dt.hour
   tm.tm_mday = dt.day
   tm.tm_mon  = dt.month - 1
   tm.tm_year = dt.year - 1900
   tm.tm_wday = dt.dayofweek

   len = strftime( this.ptr(), 64, format.ptr(), tm )
   if len > 0 : this.setlen( len )          
   return this
}
*/
func str getdateformat_en( datetime systime, str format, str date )
{
   uint locale
   //#define LANG_ENGLISH                     0x09
   //#define SUBLANG_ENGLISH_US               0x01  
   //MAKELCID(lgid, srtid) = (srtid) << 16 | lgid
   // SORT_DEFAULT 0
   locale = 0x09 | (0x01 << 10 )//MAKELCID(lgid, srtid)
   date.reserve( 64 )
   return date.setlen( GetDateFormat( locale, 0, 
            systime, format.ptr(), 
                                     date.ptr(), 64 ) - 1 )
}

method uint smtp.notify( uint code )
{
   if !this.notify : return 1
      
   if !this.notify->func( code, this.ni )
   {
      ineterror = $ERRINET_USERBREAK
      return 0
   }
	if code == $NFYINET_ERROR : return 0 
   return 1
}

method str smtp.lastresponse( str out )
{
	return out = this.ni.head
}

method uint smtp.sendcmd( str cmd )
{
	this.ni.head = cmd
	if !this.ni.head.islast( 0xA ) : this.ni.head += "\l"

	if !this.sock.send( this.ni.head ) : return this.notify( $NFYINET_ERROR )
	this.notify( $NFYSMTP_SENDCMD )

	return 1	
}


method uint smtp.cmdresponse
{
	uint ret i
	buf  data
	arrstr  lines 

	subfunc uint nodigit( ubyte ch )
	{
		return ch < '0' || ch > '9'
	}
	label again
	this.sock.recv( data )
	data += byte( 0 )
   this.ni.head = data->str

	if *data == 1 : return 0

	this.ni.head.split( lines, 0xA, 0 )
	foreach cur, lines
	{
		if nodigit( cur[0] ) || nodigit( cur[1] ) || nodigit( cur[2] ) ||
			( cur[3] != ' ' && cur[3] != '-' )
		{
			ineterror = $ERRSMTP_RESPONSE
			break						
		} 
		ret = uint( cur )
	}
/*	if (lines[ *lines - 1 ])[ 3 ] != ' '
	{
		data.use-- 
 		goto again
	}*/
   if ret >= 400 || ineterror == $ERRSMTP_RESPONSE
   {
      if ( ret >= 400 ) : ineterror = ret
      this.notify( $NFYINET_ERROR ) 
      return 0
   }
	this.notify( $NFYSMTP_RESPONSE )
	return ret	
}

method uint smtp.command( str cmd )
{
	if !this.sendcmd( cmd ) : return 0
	return this.cmdresponse()	
}

method uint smtp.close()
{
   uint cmd ret = 1

	if this.sock.socket
	{
      ret = this.command( "QUIT" )
/*		cmd = this.command( "QUIT" )
	  	if cmd && cmd != $SMTP_GOODBYE
		{
			ineterror = $ERRSMTP_QUIT
	      this.notify( $NFYINET_ERROR )
			ret = 0
		}*/
	  	this.sock.close( )
	}
   return ret
}

method uint smtp.open( str host, uint port, str username, str password, uint notify )
{
   uint rsp
   
   .username = username
   .password = password
   .notify = notify
   
   .sock.host = host
   .sock.port = port

   .ni.url = host   
   this.notify( $NFYINET_CONNECT )
   if !.sock.connect() : goto error
   if !.cmdresponse() : goto error
   if *username
   { 
      if .command("EHLO \(host)")
      {
         buf bpsw
         str spsw 
         
         bpsw = '\i 0 \( username ) \(password)'
         spsw.tobase64( bpsw->str )
         if !.command( "AUTH PLAIN \(spsw)" )
         {
            this.close()
            return 0
         } 
         return 1
      }
   }
   else : rsp = .command( "HELO \(host)")
   if !rsp : goto error
   return 1

	label error
   this.notify( $NFYINET_ERROR )
   this.close( )
   return 0
}

method uint smtp.send( str from, str to, str subject, str body, str exthead )
{
   datetime dt
   str      date time
   str      data
   arrstr   toi
   
   subfunc str getemail( str in out )
   {
      uint left right
      left = in.findch('<')
      right = in.findch('>')
      if right < *in : out.substr( in, left + 1, right - left - 1)
      else : out = in
      out.trimspace() 
      return out
   }
   
   dt.getsystime()
   getdateformat_en( dt, "ddd, dd MMM yyyy", date )
   gettimeformat ( dt, " HH:mm:ss", time )
   date += " \(time) +0000"
//   date.formatdate( dt, "%a, %d %b %Y %H:%M:%S +0000" )

   to.split( toi, ',', $SPLIT_NOSYS )
   foreach curto, toi
   {
      str efrom eto
      
      getemail( from, efrom )
      getemail( curto, eto )
      data = "MAIL FROM: <\(efrom)>
RCPT TO: <\(eto)>
DATA
From: \(from)
To: \(curto)
Subject: \(subject)
Date: \(date)
Mime-Version: 1.0
\( ?( *exthead, "\(exthead)\l", "" ))
\(body)
.
"
      uint off sent remain = *data
   
      while remain
 	   {   
         sent = send( this.sock.socket, data.ptr() + off, min( 0x7FFF, remain ), 0 )
		   if	sent == $SOCKET_ERROR 
		   {
			   inet_seterror()
			   this.sock.close()
			   goto close
		   }
		   else
		   {
   		   this.ni.param += sent
			   if !this.notify( $NFYINET_PUT )
			   {
				  this.sock.close()
 				  goto close
			   }
		   }
     	   remain -= sent
         off += sent
  	   }
      if !.cmdresponse() : return 0
   }
   return 1
   label close
   this.notify( $NFYINET_ERROR )
   return 0
}
