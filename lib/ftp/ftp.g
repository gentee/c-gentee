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
* Id: ftp L "FTP"
* 
* Summary: FTP protocol. You must call 
           #a(inet_init) function before using this library. For using this
           library, it is
           required to specify the file ftp.g (from lib\ftp
           subfolder) with include command. #srcg[
|include : $"...\gentee\lib\ftp\ftp.g"]   
*
* List: *,ftp_close,ftp_command,ftp_createdir,ftp_deldir,ftp_delfile,
          ftp_getcurdir,ftp_getfile,ftp_getsize,ftp_gettime,
          ftp_lastresponse,ftp_list,ftp_open,ftp_putfile,ftp_rename,
          ftp_setattrib,ftp_setcurdir,
        *@Common internet functions,inet_close,inet_error,inet_init,
         inet_proxy,inet_proxyenable,inetnotify_func,
        *@URL strings,str_iencoding,str_ihead,str_ihttpinfo,str_iurl, 
* 
-----------------------------------------------------------------------------*/

include : $"..\socket\internet.g"

type ftp
{
   str        path        // Дополнительный путь при открытии
	socket     sock        // Главный сокет
	socket     sockdata    // Сокет передачи данных
	socket     sockserv    // Сокет передачи данных PORT
	sockaddr   local       // Локальный адрес
	uint       notify      // Функция для уведомлений
	inetnotify ni
	uint       anonymous   // 1 если anonymous
	uint       passive     // 1 если passive mode
   uint       binary      // Binary mode
}

define
{
	FTP_OPENING = 150   /* 150 Opening data connection*/
	FTP_ENDTRAN = 226   /* 226 Transfer Complete */
	FTP_OK      = 200   
   FTP_FILESTAT = 213  // File status.
	FTP_HELLO   = 220
	FTP_GOODBYE = 221
	FTP_PASSIVEOK = 227 
	FTP_LOGINOK = 230   
	FTP_CWDOK   = 250    /* 250 CWD command successful. */
	FTP_MKDIROK = 257
	FTP_PASSWD  = 331
	FTP_FILEOK  = 350    /* RNFR command successful */    
	FTP_LOGINBAD = 530  
	FTP_NOTFOUND = 550   /* 550 No such file or directory */
}

define <export>
{
/*-----------------------------------------------------------------------------
* Id: ftpflag D
* 
* Summary: FTP flags.
*
-----------------------------------------------------------------------------*/
	FTP_ANONYM   = 0x0001      // Anonymous connection.
	FTP_PASV     = 0x0002      // Establishes a connection in passive mode.
   
/*-----------------------------------------------------------------------------
* Id: ftpget D
* 
* Summary: FTP flags.
*
-----------------------------------------------------------------------------*/
	FTP_BINARY = 0x0004  // A binary file is downloaded.
	FTP_TEXT   = 0x0008  // A text file is downloaded. This is a default mode.
   
/*-----------------------------------------------------------------------------
* Id: ftpgetbuf D
* 
* Summary: FTP flags.
*
-----------------------------------------------------------------------------*/
	FTP_STR      = 0x0100      // Appends zero to the end of received data. 

/*-----------------------------------------------------------------------------
* Id: ftpgetfile D
* 
* Summary: FTP flags.
*
-----------------------------------------------------------------------------*/
  	FTP_CONTINUE = 0x0010   // Proceeds with retrieving.
  	FTP_SETTIME  = 0x0020   // Sets the same file times as on the FTP server.
    
//-----------------------------------------------------------------------------
	FTP_FILE     = 0x1000      // для метода get - закачка в файл 

	S_IRWXU    = 0x0700
	S_IRUSR    = 0x0400
	S_IWUSR    = 0x0200
	S_IXUSR    = 0x0100
	S_IRWXG    = 0x0070
	S_IRGRP    = 0x0040
	S_IWGRP    = 0x0020
	S_IXGRP    = 0x0010
	S_IRWXO    = 0x0007
	S_IROTH    = 0x0004
	S_IWOTH    = 0x0002
	S_IXOTH    = 0x0001
}

/*-----------------------------------------------------------------------------
* Id: ftpput D
* 
* Summary: FTP flags.
*
-----------------------------------------------------------------------------
	FTP_BINARY    // A binary file is uploaded.
	FTP_TEXT      // A text file is uploaded.
   FTP_CONTINUE  // To proceed with file uploading. 

//---------------------------------------------------------------------------*//*-----------------------------------------------------------------------------
* Id: ftplist D
* 
* Summary: FTP list.
*
-----------------------------------------------------------------------------
#define "LIST" // Returns a list of files in the format of the LIST command. 
#define "NLST" // Returns a list of filenames with no other information. 
#define "MLSD" // Returns a list of files in the format of the MLSD command. 

//---------------------------------------------------------------------------*/

method uint ftp.notify( uint code )
{
   if !this.notify : return 1
      
   if !this.notify->func( code, this.ni )
   {
      ineterror = $ERRINET_USERBREAK
//      ret = 0
      return 0
   }
	if code == $NFYINET_ERROR : return 0 
   return 1
}

method uint ftp.cmdresponse
{
	uint ret i
	buf  data
	arrstr  lines 

	subfunc uint nodigit( ubyte ch )
	{
		return ch < '0' || ch > '9'
	}
	label again
	if !this.sock.recv( data ) : return 0
	data += byte( 0 )
   this.ni.head = data->str
	if *data == 1 : return 0
	this.ni.head.split( lines, 0xA, 0 )	
	foreach cur, lines
	{
		if nodigit( cur[0] ) || nodigit( cur[1] ) || nodigit( cur[2] ) ||
			( cur[3] != ' ' && cur[3] != '-' )
		{
         if cur[0] == ' ' : continue
			ineterror = $ERRFTP_RESPONSE
			return 0						
		} 
		ret = uint( cur )
	}
	if (lines[ *lines - 1 ])[ 3 ] != ' '
	{
		data.use-- 
 		goto again
	}

	this.notify( $NFYFTP_RESPONSE )
	return ret	
}

/*-----------------------------------------------------------------------------
* Id: ftp_lastresponse F2
*
* Summary: The last response from the FTP server. The method returns the 
           last response from the FTP server.
*
* Params: out - Result string.     
*  
* Return: #lng/retpar( out ) 
*
-----------------------------------------------------------------------------*/

method str ftp.lastresponse( str out )
{
	return out = this.ni.head
}

method uint ftp.sendcmd( str cmd )
{
	this.ni.head = cmd
	if !this.ni.head.islast( 0xA ) : this.ni.head += "\l"

	if !this.sock.send( this.ni.head ) : return this.notify( $NFYINET_ERROR )
	this.notify( $NFYFTP_SENDCMD )

	return 1	
}

/*-----------------------------------------------------------------------------
* Id: ftp_command F2
*
* Summary: Sends a command. This methos is used to send the specified 
           command directly to an FTP server. The response from the server 
           can be received with help of the #a(ftp_lastresponse) method.
*
* Params: cmd - The command text.     
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.command( str cmd )
{
	if !this.sendcmd( cmd ) : return 0
	return this.cmdresponse()	
}

/*-----------------------------------------------------------------------------
* Id: ftp_close F3
*
* Summary: Terminates the FTP connection. The method terminates the connection
           on the FTP server.
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.close()
{
	uint cmd ret = 1

	if this.sock.socket
	{
		cmd = this.command( "QUIT" )
	  	if cmd && cmd != $FTP_GOODBYE
		{
			ineterror = $ERRFTP_QUIT
	      this.notify( $NFYINET_ERROR )
			ret = 0
		}
	  	this.sock.close( )
	}
	return ret
}

/*-----------------------------------------------------------------------------
* Id: ftp_open F2
*
* Summary: Establishes an FTP connection. This method establishes an FTP
           connection with the server. This method must be called before other
           methods dealing with the FTP server are called. 
*
* Params: url - The name or address of the FTP server. 
          user - A user name. If the string is empty, anonymous connections /
                 are used. 
          password - A user password. If the connection is anonymous, your /
                     e-mail address is required. 
          flag - Connection flags.$$[ftpflag]
          notify - #a(inetnotify_func, Function ) is used to receive /
                   notification messages. This parameter can be zero. 
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.open( str url, str user, str password, uint flag, uint notify )
{
	uint len
	str  host

	this.notify = notify
   ineterror = 0
   this.ni.url = url
   this.binary = 0

	if flag & $FTP_ANONYM : this.anonymous = 1 
	if flag & $FTP_PASV : this.passive = 1 

   this.notify( $NFYINET_CONNECT )

	this.sock.flag |= $SOCKF_FTP

   if !this.sock.urlconnect( url, host, this.path ) : goto error 
	if this.cmdresponse() != $FTP_HELLO : goto error
	len = sizeof( sockaddr )

   if getsockname( this.sock.socket, &this.local, &len )  
   {
		inet_seterror()
		goto error
   }
	if !*user || this.anonymous : user = "anonymous"
 
	if !this.sendcmd( "USER \( user )" ) : return 0
  
   switch this.cmdresponse( )
   {
		case $FTP_LOGINOK {}   
      case $FTP_LOGINBAD
		{
			ineterror = $ERRFTP_BADUSER
			goto error	
		}
	   case $FTP_PASSWD
		{
	      if !this.sendcmd( "PASS \( password )" ) : return 0
      
	      switch this.cmdresponse()
			{
				case $FTP_LOGINOK {}
				case $FTP_LOGINBAD
				{
					ineterror = $ERRFTP_BADPSW
					goto error	
				}
				default 
 				{
					ineterror = $ERRFTP_RESPONSE
					goto error
				}
			}
	   }
    	default
		{
			ineterror = $ERRFTP_RESPONSE
			goto error
		}
   }
	return 1

	label error
   this.notify( $NFYINET_ERROR )
   this.close( )
   return 0
}

method uint ftp.listen
{
	uint cmd sin addr port
	sockaddr in  

	if this.passive
   {
      cmd = this.command( "PASV" )
      if !cmd : return 0
      if cmd == $FTP_PASSIVEOK 
		{
			str   ports response 
			uint  off till
			arrstr   portval 

			off = this.lastresponse( response ).findch( '(' ) + 1
			till = response.findchfrom( ')', off )
			ports.substr( response, off, till - off )
			ports.split( portval, ',', 0 )
			if *portval != 6 
			{
				ineterror = $ERRFTP_RESPONSE
				goto error
			}
			this.sockdata.host = "\(portval[0]).\(portval[1]).\(portval[2]).\(portval[3])"
			this.sockdata.port = (uint( portval[4] ) << 8) + uint( portval[5] )
			if this.sockdata.connect() : return 1
		}
		this.passive = 0
		this.notify( $NFYFTP_NOTPASV )
	}

	this.sockserv.socket = createsocket( $AF_INET, $SOCK_STREAM, $IPPROTO_TCP ) 
  
   if this.sockserv.socket == $INVALID_SOCKET : return inet_seterror()

	sin = sizeof( sockaddr )
	mcopy( &in, &this.local, sin )
  	in->sockaddr_in.sin_port = 0
  
 	if bind( this.sockserv.socket, &in, sin ) ||
		listen( this.sockserv.socket, 1 ) ||
		getsockname( this.sockserv.socket, &in, &sin )
   {
		inet_seterror()
		goto error
   }

  	addr = ntohl( this.local->sockaddr_in.sin_addr )
  	port = ntohs( in->sockaddr_in.sin_port )
  
	if this.command( "PORT \((addr >> 24) & 0xFF ),\((addr >> 16) & 0xFF ),\((addr >> 8) & 0xFF ),\(addr & 0xFF ),\((port >> 8) & 0xFF ),\(port & 0xFF )") != $FTP_OK
   {
		ineterror = $ERRFTP_PORT
      goto error
   }
	return 1

	label error
	this.notify( $NFYINET_ERROR )
	return 0
}

method uint ftp.accept
{
	if !this.passive && ( this.sockdata.socket = 
                accept( this.sockserv.socket, 0, 0 )) == $INVALID_SOCKET 
	{
		inet_seterror()
		this.notify( $NFYINET_ERROR )
		return 0
	}
  	return this.sockdata.socket
}

/*-----------------------------------------------------------------------------
* Id: ftp_list F2
*
* Summary: List of files. The method retrieves a list of files and 
           directories from the FTP server. 
*
* Params: list - Result string. 
          cmd - The command is used to retrieve a list of files.$$[ftplist]
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.list( str data, str mode )
{
	uint i dif

	if !this.listen() : return 0

//	if this.command( "MLSD" ) != $FTP_OPENING : return 0
	if this.command( mode ) != $FTP_OPENING : return 0

	if !this.accept() : return 0

	data->buf.use = 0
   do 
   {
      i = *data
      this.sockdata.recv( data->buf )
      dif = *data - i
   } while dif

	data->buf += byte( 0 )

	this.sockdata.close()

	// ? надо или нет закрывать
	if !this.passive : this.sockserv.close()
 
	if this.cmdresponse() != $FTP_ENDTRAN
   {
		ineterror = $ERRFTP_RESPONSE
		this.notify( $NFYINET_ERROR )
		return 0
   }
	return 1
}

/*-----------------------------------------------------------------------------
* Id: ftp_createdir F2
*
* Summary: Creates a new directory. The method creates a new directory on 
           the FTP server.
*
* Params: dirname - The name of the directory      
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.createdir( str dirname )
{
	return this.command("MKD \(dirname)") == $FTP_MKDIROK
}

/*-----------------------------------------------------------------------------
* Id: ftp_deldir F2
*
* Summary: Deletes a directory. This method deletes a directory stored on 
           the FTP server. 
*
* Params: dirname - The name of the required directory       
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.deldir( str dirname )
{
	return this.command("RMD \(dirname)") == $FTP_CWDOK
}

/*-----------------------------------------------------------------------------
* Id: ftp_delfile F2
*
* Summary: Deletes a file. The method deletes a file stored on the FTP server. 
*
* Params: filename - The name of the required file.      
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.delfile( str filename )
{
	return this.command("DELE \(filename)") == $FTP_CWDOK
}

/*-----------------------------------------------------------------------------
* Id: ftp_setcurdir F2
*
* Summary: Sets the current directory. This method sets a new current 
           directory.
*
* Params: dirname - The name of a new directory.      
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.setcurdir( str dirname )
{
	return this.command("CWD \(dirname)") == $FTP_CWDOK
}

/*-----------------------------------------------------------------------------
* Id: ftp_getcurdir F2
*
* Summary: Retrieves the current directory. The method retrieves the current
           directory name from the FTP server.
*
* Params: dirname - Result string.      
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.getcurdir( str dirname )
{
	str   response 
	uint  off till

	dirname.clear()
	if this.command("PWD") != $FTP_MKDIROK : return 0

	off = this.lastresponse( response ).findch( '"' ) + 1
	till = response.findchfrom( '"', off )
	dirname.substr( response, off, till - off )
	if !*dirname : return 0

	return 1
}

/*-----------------------------------------------------------------------------
* Id: ftp_rename F2
*
* Summary: Renames a file. This method renames a file or directory stored 
           on the FTP server.
*
* Params: from - The current name of the file or directory. 
          to - A new name.  
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.rename( str from, str to )
{
	if this.command("RNFR \(from)") != $FTP_FILEOK : return 0
	return this.command("RNTO \(to)") == $FTP_CWDOK 
}

/*-----------------------------------------------------------------------------
* Id: ftp_getsize F2
*
* Summary: Retrieves the file size from the FTP server.
*
* Params: name - Filename. 
          psize - A pointer to uint value is used to store the file size. 
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.getsize( str name, uint psize )
{
	str size

	psize->uint = 0
	if this.command("SIZE \(name)") != $FTP_FILESTAT : return 0
	this.lastresponse( size ).del( 0, 4 )
	psize->uint = uint( size )
	return 1 
}

/*-----------------------------------------------------------------------------
* Id: ftp_gettime F2
*
* Summary: Retrieves the file time. Retrieves last write times for the file 
           on the FTP server. 
*
* Params: name - Filename. 
          dt - The variable of #a( tdatetime ) type is used to retrieve the /
               file time. 
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.gettime( str name, datetime dt )
{
	str time year month day

	mzero( &dt, sizeof( datetime ))
	if this.command("MDTM \(name)") != $FTP_FILESTAT : return 0

	this.lastresponse( time ).del( 0, 4 )
	time.trimspace()
	year.substr( time, 0, 4 )
	month.substr( time, 4, 2 )
	day.substr( time, 6, 2 )
	dt.setdate( uint( day ), uint( month ), uint( year ))
	dt.hour = uint( year.substr( time, 8, 2 ))
	dt.minute = uint( month.substr( time, 10, 2 ))
	dt.second = uint( day.substr( time, 12, 2 ))
	
	return 1 
}

/*-----------------------------------------------------------------------------
* Id: ftp_setattrib F2
*
* Summary: Sets the attributes. This method sets the attributes for the file 
           or the directory.
*
* Params: name - The name of a file or directory. 
          mode - The attributes for the file. 
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.setattrib( str name, uint mode )
{
//	str  chmode

	mode &= $S_IRWXU | $S_IRWXG | $S_IRWXO
	
	if this.command("SITE CHMOD \(hex2strl( mode)) \(name)") != $FTP_OK
	{ 
 		return 0
	}
	return 1 
}

/*-----------------------------------------------------------------------------
* Id: ftp_getfile F2
*
* Summary: Retrieves a file. The method retrieves files from the FTP server.
*
* Params: filename - The downloaded file name. 
          databuf - The received data buffer. Data are not stored on a drive. 
          flag - Additional flags. $$[ftpget]$$[ftpgetbuf]
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.getfile( str filename, buf databuf, uint flag )
{
	uint       data dif i 
   buf        fbuf
   uint       ret range
   file       fdwn
	uint       isfile = flag & $FTP_FILE
	finfo      fi 

   if (( flag & $FTP_BINARY ) && !this.binary ) || (!(flag & $FTP_BINARY ) && this.binary )
   {
      if this.command( "TYPE \(?( flag & $FTP_BINARY, "I", "A" ))") != $FTP_OK :	return 0
      this.binary = ?( flag & $FTP_BINARY, 1, 0 ) 
   }	
	if !this.listen() : return 0

	this.ni.param = 0
 
	if isfile && flag & $FTP_CONTINUE
   {  
      getfileinfo( databuf->str, fi )
      if fi.sizelo
		{
			if this.command( "REST \(fi.sizelo)" ) != $FTP_FILEOK
			{
				flag &= ~$FTP_CONTINUE
			}
			else : this.ni.param = fi.sizelo
		}	 
   }
	data = ?( isfile, &fbuf, &databuf )
   data as buf

   if isfile
   {
      data.expand( 0x20000 )
      if !( fdwn.open( databuf->str, ?( flag & $FTP_CONTINUE,
                            $OP_ALWAYS, $OP_CREATE )))
      {
         this.ni.sparam = databuf->str
         ineterror = $ERRINET_OPENFILE
         this.notify( $NFYINET_ERROR )
         goto end
      }
		if this.ni.param : fdwn.setpos( 0, $FILE_END )
   }
   else 
   {
		uint fullsize

		data.clear()
		this.getsize( filename, &fullsize )
      if uint( fullsize ) : data.expand( uint( fullsize ) + 0x7FFF )
   }
  	if this.command( "RETR \(filename)" ) != $FTP_OPENING : return 0 
 
	if !this.accept() : return 0

	do 
   {
      i = *data
      if !this.sockdata.recv( data ) : return 0
      
		dif = *data - i
      this.ni.param += dif
      if isfile && ( *data >= 0x7FFF || !dif )
      {
         if *data && !( fdwn.write( data ))
         {
            this.ni.sparam = databuf->str
            ineterror = $ERRINET_WRITEFILE
            this.notify( $NFYINET_ERROR )
            goto end
         }
         if !this.notify( $NFYINET_GET )
		   {
   			this.sockdata.close()
//	   		this.command("ABOR") 
 	     		goto end
   		}
         data.use = 0
      }
   } while dif
   if flag & $FTP_STR : data += byte( 0 )
   this.notify( $NFYINET_END )
	this.sockdata.close()

	if this.cmdresponse() != $FTP_ENDTRAN
	{
		ineterror = $ERRFTP_RESPONSE
		goto end
	}

   ret = 1   
   label end      
   if fdwn.fopen 
   {
      if ret && flag & $FTP_SETTIME
      {
         filetime ft
			datetime dt
         
			if this.gettime( filename, dt )
			{
         	datetimetoftime( dt, ft )
         	fdwn.settime( ft )
			}
      }
      fdwn.close( )
   }
   if !ret && ineterror : this.notify( $NFYINET_ERROR )

   return ret
}

/*-----------------------------------------------------------------------------
* Id: ftp_getfile_1 FA
*
* Summary: The method retrieves files from the FTP server.
*
* Params: srcname - The downloaded file name. 
          destname - A new file name on user's machine.  
          flag - Flags.$$[ftpget]$$[ftpgetfile]
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.getfile( str srcname, str destname, uint flag )
{
   flag &= 0xF0FF
   return this.getfile( srcname, destname->buf, flag | $FTP_FILE )
}

/*-----------------------------------------------------------------------------
* Id: ftp_putfile F2
*
* Summary: Stores a file on the FTP server. This method is used to upload 
           the required file from the remote host to the FTP server. 
*
* Params: srcname - The name of the required source file. 
          destname - The name of a file stored on the FTP server. 
          flag - Flags. If the flag of the binary or text mode is not /
                 specified, the method makes effort to determine a file /
                 type. $$[ftpput]    
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint ftp.putfile( str srcname, str destname, uint flag )
{
	uint  offset size cur ret i
   file  fdwn
	buf   data
	str   tmode

	subfunc uint nextread
	{
		cur = min( size, 0x20000 )
		data.use = 0
		if fdwn.read( data, cur ) != cur
		{
   		this.ni.sparam = srcname
      	ineterror = $ERRINET_READFILE
      	return 0
		}
		size -= cur
		return 1
	}

   if !( fdwn.open( srcname, $OP_READONLY ))
   {
   	this.ni.sparam = srcname
      ineterror = $ERRINET_OPENFILE
      this.notify( $NFYINET_ERROR )
      return 0
   }
	size = fdwn.getsize( ) 
	if flag & $FTP_CONTINUE
	{ 
		if !this.getsize( destname, &offset ) || offset >= size
		{
			flag &= ~$FTP_CONTINUE
		}
		else
		{
			this.ni.param = offset
			size -= offset
			fdwn.setpos(  offset, $FILE_BEGIN )
		}
	}
   data.expand( 0x20000 )
	if !nextread() : goto end

	tmode = "TYPE A"	
	if flag & $FTP_BINARY : tmode = "TYPE I" 	
	elif !( flag & $FTP_TEXT )
	{
		fornum i = 0, *data - 1
		{
			if !data[i] || ( data[i] == 0xD && data[i + 1] != 0xA )
			{
				tmode = "TYPE I"
				break		
			}    
		}		
	}
	if this.command( tmode ) != $FTP_OK : goto close	
	if !this.listen() : goto close
	
	if this.command( "\(?( flag & $FTP_CONTINUE, "APPE", 
                    "STOR")) \( destname )") != $FTP_OPENING : goto close  

	if !this.accept() : goto close 

	while 1
	{
		uint off last
	   uint sent

	  	last = *data
   
	   while last
   	{   
      	sent = send( this.sockdata.socket, data.ptr() + off, min( 0x7FFF, last ), 
                      0  )
			if	sent == $SOCKET_ERROR 
			{
				inet_seterror()
				this.sockdata.close()
				goto close
			}
			else
			{
				this.ni.param += sent
				if !this.notify( $NFYINET_PUT )
				{
					this.sockdata.close()
 					goto close
				}
			}
      	last -= sent
      	off += sent
   	}
//		this.sockdata.send( data )
		if !size : break
		nextread()
	}
   this.notify( $NFYINET_END )
	this.sockdata.close()
	if this.cmdresponse() != $FTP_ENDTRAN
	{
		ineterror = $ERRFTP_RESPONSE
		goto end
	}
   ret = 1   
   label end      
   if !ret && ineterror : this.notify( $NFYINET_ERROR )
	label close
   fdwn.close( )
   
   return ret
}
