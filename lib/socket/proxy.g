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

include : $"..\registry\registry.g"

define <export>
{
/*-----------------------------------------------------------------------------
* Id: proxyflag D
* 
* Summary: Proxy types.
*
-----------------------------------------------------------------------------*/
   PROXY_HTTP  = 0x0001       // Use a proxy server for the HTTP protocol.  
   PROXY_FTP   = 0x0002       // Use a proxy server for the FTP protocol.
   PROXY_ALL   = 0x0003       // Use a proxy server for all protocols.
   PROXY_EXPLORER  = 0x0080   // Take the proxy server information from the /
                              // Internet Explorer settings. In this case /
                              // the proxyname parameter can be empty.
   
//-----------------------------------------------------------------------------
}

operator proxyinfo =( proxyinfo left right )
{
   left.host = right.host
   left.port = right.port
   left.enable = right.enable
   return left
}

/*-----------------------------------------------------------------------------
* Id: inet_proxy F
*
* Summary: Using a proxy server. The functions allows you to specify a 
           proxy server to be used for connecting to the Internet. 
*
* Params: flag - The flag specifying for which protocols the specified proxy /
                 should be used. $$[proxyflag] 
          proxyname - The name of the proxy server. It must contain a host /
                      name and a port number separated by a colon. 
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

func uint inet_proxy( uint flag, str proxyname )
{
   arrstr     shostport
   proxyinfo  ieproxy
   str        regie  stemp
   uint       i
   
   regie = $"Software\Microsoft\Windows\CurrentVersion\Internet Settings"
   
   ieproxy.enable = 1
   if flag & $PROXY_EXPLORER
   {
      ieproxy.enable = reggetnum( $HKEY_CURRENT_USER, regie,
                                     "ProxyEnable", 0 )
      stemp.regget( $HKEY_CURRENT_USER, regie, "ProxyServer" )
   }
   else : stemp = proxyname

   stemp.split( shostport, ':', $SPLIT_FIRST | $SPLIT_NOSYS )
   ieproxy.host = shostport[0]
   if *shostport > 1 : ieproxy.port = uint( shostport[1] )  

   if flag & $PROXY_HTTP : proxy[ $INET_HTTP ] = ieproxy
   if flag & $PROXY_FTP : proxy[ $INET_FTP ] = ieproxy

   return 1
}

/*-----------------------------------------------------------------------------
* Id: socket_urlconnect F2
*
* Summary: Creating and connecting a socket to a URL. The method is used to
           create and connect a socket to the specified Internet address. 
           If a proxy server is enabled, the connection will be established 
           via it.
*
* Params: url - The URL address for connecting. 
          host - The string for getting the host from the URL. 
          path - The string for getting the relative path from the URL. 
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

method uint socket.urlconnect( str url, str host, str path )
{
   str   port
   uint  protocol = $INET_HTTP
   uint  defport = 80
   
   this.flag &= ~$SOCKF_PROXY
   if url.iurl( host, port, path ) == $INET_FTP 
   {
      this.flag |= $SOCKF_FTP
   } 
   if this.flag & $SOCKF_FTP : protocol = $INET_FTP; defport = 21

   if proxy[ protocol ].enable
   {
      this.flag |= $SOCKF_PROXY
      this.host = proxy[ protocol ].host
      this.port = proxy[ protocol ].port
   }
   else
   {
      this.host = host
      this.port = ?( !*port, defport, uint( port ))
   }
   if *port : host += ":\(port)"
//   print("URL: \(this.host):\(this.port)\n")   
   return this.connect()
}

/*-----------------------------------------------------------------------------
* Id: inet_proxyenable F
*
* Summary: Enabling/disabling a proxy server. The function allows you to 
           enable or disable the proxy server for various protocols. 
           Initially, the proxy server must be specified using the 
           #a(inet_proxy) function.
*
* Params: flag - The flag specifying for which protocols the proxy should /
                 be enabled or disabled. $$[proxyflag]
          enable - Specify 1 to enable the proxy server or 0 to disable /
                   the proxy server.     
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

func uint inet_proxyenable( uint flag, uint enable )
{
   uint i

   if flag & $PROXY_HTTP 
   {
      if !*proxy[ $INET_HTTP ].host : return 0
      proxy[ $INET_HTTP ].enable = enable
   }
   if flag & $PROXY_FTP 
   {
      if !*proxy[ $INET_FTP ].host : return 0
      proxy[ $INET_FTP ].enable = enable
   }
   return 1   
}