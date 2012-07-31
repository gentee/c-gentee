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
* Id: socket L "Socket"
* 
* Summary: Sockets and common internet functions. You must call 
           #a(inet_init) function before using this library. For using this
           library, it is
           required to specify the file internet.g (from lib\socket
           subfolder) with include command. #srcg[
|include : $"...\gentee\lib\socket\internet.g"]   
*
* List: *Common internet functions,inet_close,inet_error,inet_init,
         inet_proxy,inet_proxyenable,inetnotify_func,
        *Socket methods,socket_close,socket_connect,socket_isproxy,
        socket_recv,socket_send,socket_urlconnect,
        *URL strings,str_iencoding,str_ihead,str_ihttpinfo,str_iurl, 
        *#lng/types#,thttpinfo,tinetnotify,tsocket 
* 
-----------------------------------------------------------------------------*/

define
{
   AF_UNIX               = 1 
   AF_INET               = 2 
   
   IPPROTO_IP            = 0           /* dummy for IP */
   IPPROTO_ICMP          = 1           /* control message protocol */
   IPPROTO_IGMP          = 2           /* internet group management protocol */
   IPPROTO_GGP           = 3           /* gateway^2 (deprecated) */
   IPPROTO_TCP           = 6           /* tcp */
   IPPROTO_PUP           = 12          /* pup */
   IPPROTO_UDP           = 17          /* user datagram protocol */
   IPPROTO_IDP           = 22          /* xns idp */
   IPPROTO_ND            = 77          /* UNOFFICIAL net disk proto */
   IPPROTO_RAW           = 255         /* raw IP packet */
   
   SOCK_STREAM           = 1               /* stream socket */
   SOCK_DGRAM            = 2               /* datagram socket */
   SOCK_RAW              = 3               /* raw-protocol interface */
   SOCK_RDM              = 4               /* reliably-delivered message */
   SOCK_SEQPACKET        = 5               /* sequenced packet stream */

   WSADESCRIPTION_LEN    =  257 //256
   WSASYS_STATUS_LEN     =  129 //128
   INVALID_SOCKET        =  0xFFFFFFFF
   SOCKET_ERROR          =  0xFFFFFFFF
}

define <export>   
{
/*-----------------------------------------------------------------------------
* Id: ineterr D
* 
* Summary: Library error codes.
*
-----------------------------------------------------------------------------*/
   ERRINET_DLLVERSION    =  0x0001   // Unsupported version of ws2_32.dll. 
   ERRINET_HTTPDATA                  // Not HTTP data is received.
   ERRINET_USERBREAK                 // The process is interrupted by the user.
   ERRINET_OPENFILE                  // Cannot open the file. 
   ERRINET_WRITEFILE                 // Cannot write the file.
   ERRINET_READFILE                  // Cannot read the file.
	ERRFTP_RESPONSE                   // The wrong response of the server.
	ERRFTP_QUIT                       // The wrong QUIT response of the server.
	ERRFTP_BADUSER                    // The bad user name.
	ERRFTP_BADPSW                     // The wrong password.
	ERRFTP_PORT                       // Error PORT.
   
//-----------------------------------------------------------------------------
   // Команды - уведомления
   //   nfyfunc( uint code, nfyinfo ni )
/*-----------------------------------------------------------------------------
* Id: inetmsg D
* 
* Summary: Library notify codes.
*
-----------------------------------------------------------------------------*/
   NFYINET_ERROR = 0x0001 // An error occurred. The code of the error can be /
                          // got with the help of the #a(inet_error) function.
   NFYINET_CONNECT        // Server connection.
   NFYINET_SEND           // Sending a request.
   NFYINET_POST           // Sending data.
   NFYINET_HEAD           // Processing the header. ni.param points to /
                          // #a( thttpinfo ).
   NFYINET_REDIRECT       // Request redirection. ni.sparam contains /
                          // the new URL.
   NFYINET_GET            // Data is received. ni.param contains the total /
                          // size of all data.
   NFYINET_PUT            // Data is sent. ni.param contains the total /
                          // size of all data.
   NFYINET_END            // The connection is terminated.
	NFYFTP_RESPONSE        // Response of the FTP server. The field /
                          // ni.head contains it.
	NFYFTP_SENDCMD         // Sending a command to the FTP server. The field /
                          // ni.head contains it.   
	NFYFTP_NOTPASV         // Passive mode with the FTP server is unavailable.

/*-----------------------------------------------------------------------------
* Id: httpflag D
* 
* Summary: HTTP flags for http_get.
*
-----------------------------------------------------------------------------*/
   HTTPF_REDIRECT  = 0x0001 // If redirection is used, download from the /
                            // new address.
   HTTPF_STR       = 0x0010 // Add 0 to databuf after data is received. /
                            // Use this flag if databuf is a string.
   HTTPF_CONTINUE  = 0x0100 // If the file already exists, resume /
                            // downloading it. It is valid for #a(http_getfile).
   HTTPF_SETTIME   = 0x0200 // Set the same time for the file as it is on /
                            // the server. It is valid for #a(http_getfile).
//----------------------------------------------------------------------------- 
   HTTPF_FILE      = 0x1000   // databuf contains the filename. 
}

define
{
   INET_HTTP  = 0   
   INET_FTP
}

type WSAData {
   ushort                  wVersion
   ushort                  wHighVersion
   reserved                szDescription[ $WSADESCRIPTION_LEN ]
   reserved                szSystemStatus[ $WSASYS_STATUS_LEN ]
   ushort                  iMaxSockets
   ushort                  iMaxUdpDg
   uint                    lpVendorInfo
}

type sockaddr_in 
{
   short     sin_family
   ushort    sin_port
   uint      sin_addr
   reserved  sin_zero[8]
}

type sockaddr {
    ushort    sa_family
    reserved  sa_data[ 14 ]
}

type hostent 
{
   uint      h_name           /* official name of host */
   uint      h_aliases        /* alias list */
   short     h_addrtype       /* host address type */
   short     h_length         /* length of address */
   uint      h_addr_list      /* list of addresses */
}

type proxyinfo
{
   str    host    // хост прокси
   uint   port    // порт
   uint   enable  // включено или нет
}

/*-----------------------------------------------------------------------------
* Id: thttpinfo T httpinfo 
* 
* Summary: HTTP header data. The structure is used to get data from an HTTP
           header. Depending on the header, some fields may be empty.
*
-----------------------------------------------------------------------------*/

type httpinfo
{
   uint      code       // Message code.
   datetime  dt         // Last modified date.
   str       size       // File size.
   str       location   // New file location.
}

/*-----------------------------------------------------------------------------
* Id: tinetnotify T inetnotify 
* 
* Summary: Type for handling messages. This structure is passed to the 
           #a(inetnotify_func, message handling function) as a parameter.
           Additional parameters take various values depending on the message
           code. 
*
-----------------------------------------------------------------------------*/

type inetnotify
{
   str       url        // The URL address being processed.
   str       head       // The header of the received packet.
   uint      param      // Additional integer parameter.
   str       sparam     // Additional string parameter.
}

//-----------------------------------------------------------------------------
 
global 
{
   uint  ineterror         // Код последней ошибки
   arr   proxy[2] of proxyinfo   // массив proxy   
   str   inet_useragent = "User-Agent: Mozilla/4.0 (compatible; MSIE 5.0; Windows 98)"
}

import "ws2_32.dll" {
	uint accept( uint, uint, uint )
	uint bind( uint, uint, uint )
   uint closesocket( uint )
   uint connect( uint, uint, uint )
   uint gethostbyname( uint )
   uint gethostname( uint, uint )
	uint getsockname( uint, uint, uint )                    
   ushort htons( ushort )
   uint   inet_addr( uint )
   uint   inet_ntoa( uint )
	uint   listen( uint, uint )
	uint   ntohl( uint )
	ushort ntohs( ushort )  
   uint recv( uint, uint, uint, uint )
   uint send( uint, uint, uint, uint )
   uint shutdown( uint, uint )
   uint socket( uint, uint, uint ) -> createsocket
   int  WSACleanup()
   uint WSAGetLastError()
   int  WSAStartup( ushort, WSAData )
}

/*-----------------------------------------------------------------------------
* Id: inet_error F1
*
* Summary: Getting an error code. The function returns the code of the last
           error. Codes greater than 10000 are codes of errors in the 
           library #b(WinSock 2) ( ws2_32.dll ).  
*
* Return: The code of the last error.$$[ineterr]  
*
-----------------------------------------------------------------------------*/

func uint inet_error()
{
   return ineterror
}

func uint inet_seterror
{
   ineterror = WSAGetLastError()
   return 0
}

include 
{
   "strinet.g"
   "socket.g"
   "proxy.g"
}

/*-----------------------------------------------------------------------------
* Id: inet_init F1
*
* Summary: Library initialization. This function must be called before working
           with the library. 
*
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

func uint inet_init()
{
   WSAData wsaData
   
   ineterror = WSAStartup( 0x0202, wsaData )
   
   if ineterror : return 0               
   if wsaData.wVersion != 0x0202 
   {
       WSACleanup( )
       ineterror = $ERRINET_DLLVERSION
       return 0
   }
   return 1
}

/*-----------------------------------------------------------------------------
* Id: inet_close F1
*
* Summary: Closing the library. This function must be called after the work 
           with the library is finished. 
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

func uint inet_close()
{
   ineterror = WSACleanup()
   return !ineterror
}

/*-----------------------------------------------------------------------------
* Id: inetnotify_func F
*
* Summary: Message handling function. When some functions are called, you can
           specify a function for handing incoming notifications. 
           In particular, it allows you to show the working process to the 
           user. This handling function must have the following parameters.  
*
* Params: code - Message code.$$[inetmsg]
          ni - The variable of the #a(tinetnotify) type with additional data.   
*  
* Return: The function must return 1 to continue working and 0 otherwise.  
*
* Define: func uint inetnotify_func( uint code, inetnotify ni ) 
*
-----------------------------------------------------------------------------*/

//-----------------------------------------------------------------------------