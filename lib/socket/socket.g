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

define
{
   SD_RECEIVE     = 0x00
   SD_SEND        = 0x01
   SD_BOTH        = 0x02
   
   SOCKF_PROXY    = 0x0001  // Соединение через прокси
   SOCKF_FTP      = 0x0002  // FTP соединение 
}

include : $"..\thread\thread.g"

/*-----------------------------------------------------------------------------
* Id: tsocket T socket 
* 
* Summary: Socket structure.
*
-----------------------------------------------------------------------------*/

type socket
{
   str     host    // Host name.
   ushort  port    // Port number.
   uint    socket  // Open socket identifier.
   uint    flag    // Additional flags. #b($SOCKF_PROXY) - The socket is /
                   // opened via a proxy server. 
}

/*-----------------------------------------------------------------------------
* Id: socket_isproxy F3
*
* Summary: Connecting via a proxy or not. This method can be used to determine
           if a socket is connected via a proxy server or not. 
*
* Return: 1 is returned if the socket is connected via a proxy server and 0 
          is returned otherwise. 
*
-----------------------------------------------------------------------------*/

method uint socket.isproxy()
{
   return this.flag & $SOCKF_PROXY
}

/*-----------------------------------------------------------------------------
* Id: socket_close F3
*
* Summary: Closes a socket.
*
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint socket.close()
{
   ineterror = shutdown( this.socket, $SD_BOTH )
   if !ineterror : ineterror = closesocket( this.socket )
   return !ineterror   
}

/*-----------------------------------------------------------------------------
* Id: socket_connect F3
*
* Summary: Opens a socket. The method creates a socket and establishes a
           connection to the #b(host) and #b(port) specified in the host and
           port fields of the #a(tsocket) structure. 
*
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint socket.connect()
{
   sockaddr_in saddr    
   uint        he ret

   // Получение хоста по имени
   saddr.sin_addr = inet_addr( this.host.ptr() )
   if saddr.sin_addr == 0xFFFFFFFF 
   {
      he = gethostbyname( this.host.ptr() )
      if !he : return inet_seterror()
      saddr.sin_addr = ( he->hostent.h_addr_list->uint)->uint
   }
   // Открытие сокета   
   this.socket = createsocket( $AF_INET, $SOCK_STREAM, $IPPROTO_TCP )
   if this.socket == $INVALID_SOCKET : return inet_seterror()

   saddr.sin_family = $AF_INET
   saddr.sin_port = htons( this.port )

   // Соединение   
   ret = connect( this.socket, &saddr, sizeof( sockaddr ))
   if ret == $SOCKET_ERROR
   {
      // Закрытие сокета в случае ошибки
      this.close( )
      return inet_seterror()   
   }   
   return 1
}

/*-----------------------------------------------------------------------------
* Id: socket_recv F2
*
* Summary: The method gets a packet from the connected server.
*
* Params: data - The buffer for writing data. The received packet will be /
                 added to the data already existing in the buffer.     
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/
 
type sp_socket {
   uint pdata
   uint psock
}
 
func uint socket_recv( uint param )
{
   uint ret
 
   param as sp_socket  
   ret = recv( param.psock, param.pdata->buf.ptr() + param.pdata->buf.use, 0x7FFF, 0  )
   
   return ret
} 
 
method uint thread.wait( uint time )
{
   return WaitForSingleObject( this.handle, time ) != 0x00000102 // TIMEOUT
}
    
method uint socket.recv( buf data )
{
   uint ret
   
   if data.use + 0x7FFF > data.size
   {
      data.expand( data.size + 0x7FFF )
   }
   thread th
   sp_socket spp
   spp.pdata = &data
   spp.psock = this.socket
   th.create( &socket_recv, &spp )
   if !th.wait( 20000 )
   { 
      th.terminate(0)
      this.close()
      return inet_seterror()
   }
   th.getexitcode( &ret )    
//   ret = recv( this.socket, data.ptr() + data.use, 0x7FFF, 0  )
   if ret == $SOCKET_ERROR
   {
      return inet_seterror()
   }
   data.use += ret
   return 1
}
   
/*-----------------------------------------------------------------------------
* Id: socket_send F2
*
* Summary: The method sends a request to the connected server.
*
* Params: data - Request string.     
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/
   
method uint socket.send( str data )
{
   if send( this.socket, data.ptr(), *data, 0  ) == $SOCKET_ERROR
   {
      return inet_seterror()
   }
   return 1
}   

/*-----------------------------------------------------------------------------
* Id: socket_send_1 FA
*
* Summary: The method sends a request data to the connected server.
*
* Params: data - Request buffer.     
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint socket.send( buf data )
{
   uint off last = *data
   uint sent
   
   while last
   {   
      sent = send( this.socket, data.ptr() + off, last, 0  )
      if sent == $SOCKET_ERROR
      {
         return inet_seterror()
      }
      last -= sent
      off += sent
   }
   return 1
}   