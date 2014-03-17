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
* Id: http L "HTTP"
* 
* Summary: HTTP protocol. You must call 
           #a(inet_init) function before using this library. For using this
           library, it is
           required to specify the file http.g (from lib\http
           subfolder) with include command. #srcg[
|include : $"...\gentee\lib\http\http.g"]   
*
* List: *,http_get,http_getfile,http_head,http_post,
        *@Common internet functions,inet_close,inet_error,inet_init,
         inet_proxy,inet_proxyenable,inetnotify_func,
        *@URL strings,str_iencoding,str_ihead,str_ihttpinfo,str_iurl, 
* 
-----------------------------------------------------------------------------*/


include : $"..\socket\internet.g"
include : $"cookies.g"

func str  http_cmd( str ret, str cmd host path more data, uint isproxy )
{
   str scookies
   if usecookies 
   {
      scookies = mcookies.get( host, "/\(path)" )   
      if *scookies : scookies = "Cookie: \(scookies)\l"
   }
    ret = "\(cmd) \(?( isproxy, "http://\(host)/\(path)","/\(path)")) HTTP/1.0
User-Agent: \( inet_useragent ) 
Accept: */*
Host: \(host)
\(scookies)\(more)\l\(data)"
   return ret
}

/*-----------------------------------------------------------------------------
* Id: http_get F
*
* Summary: Getting data via the HTTP protocol. The method sends a GET request 
           to the specified URL and writes data it receives to the databuf
           buffer.
*
* Params: url - The URL address data is received from.
          databuf - The buffer for getting data.
          notify - The #a(inetnotify_func,function) for getting /
                   notifications. It can be 0.
          flag - Flags. $$[httpflag]     
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

func uint http_get( str url, buf databuf, uint notify, uint flag, str otherpars )
{
   uint       ret i isfile data dif
   str        request host path range stemp
   socket     sock
   httpinfo   hi
   inetnotify ni
   buf        fbuf
   file       fdwn
   finfo      fi
   
   subfunc uint nfy( uint code )
   {
      if !notify : return 1
      
      if !notify->func( code, ni )
      {
         ineterror = $ERRINET_USERBREAK
         ret = 0
         return 0
      }
      return 1
   }
   ineterror = 0
   isfile = flag & $HTTPF_FILE
   url.replacech( stemp = url, ' ', "%20" )
   if !isfile : databuf.use = 0 

   ni.url = url
      
   nfy( $NFYINET_CONNECT )
   if !sock.urlconnect( url, host, path ) 
   {
      nfy( $NFYINET_ERROR )
      if flag & $HTTPF_STR : data += byte( 0 )
      return 0
   }
   if !nfy( $NFYINET_SEND ) : goto end
   if isfile && flag & $HTTPF_CONTINUE
   {  
      getfileinfo( databuf->str, fi )
      if fi.sizelo : range = "Range: bytes=\(fi.sizelo)-\l"
   }   
   
   str stmp = range
   if &otherpars: stmp@otherpars
   http_cmd( request, "GET", host, path, stmp, "", sock.isproxy() )
   
   if !sock.send( request ) : goto end
   
   data = ?( isfile, &fbuf, &databuf )
   data as buf
      
   if !sock.recv( data ) : goto end
   str shead
   if !"HTTP".eqlenign( data.ptr()) || ((shead=ni.head.ihead( data )) && !shead.ihttpinfo( hi )) 
   {
      ineterror = $ERRINET_HTTPDATA
      goto end
   }
   if usecookies : mcookies.parse( host, path, shead )
   if &otherpars : otherpars = shead     
   ni.param = &hi
   if !nfy( $NFYINET_HEAD ) : goto end

   if flag & $HTTPF_REDIRECT && *hi.location
   {
      data.clear()
      sock.close()     
       
      ni.sparam = hi.location
      if !nfy( $NFYINET_REDIRECT ) : goto end
      
      return http_get( hi.location, databuf, notify, flag, otherpars )      
   }
   if isfile
   {
      data.expand( 0x20000 )
      /*if !( fhandle = open( databuf->str, ?( flag & $HTTPF_CONTINUE,
                            $OP_ALWAYS, $OP_CREATE )))*/
      if !( fdwn.open( databuf->str, ?( flag & $HTTPF_CONTINUE,
                            $OP_ALWAYS, $OP_CREATE ) ) )
      {
         ni.sparam = databuf->str
         ineterror = $ERRINET_OPENFILE
         nfy( $NFYINET_ERROR )
         goto end
      }
   }
   else 
   {
      if uint( hi.size ) : data.expand( uint( hi.size ) + 0x7FFF )
   }
   if *range
   {
      fdwn.setpos( 0, $FILE_END )
      ni.param = fi.sizelo + *data
   }
   else : ni.param = *data
            
   do 
   {
      i = *data
      if !nfy( $NFYINET_GET ) : goto end
      sock.recv( data )
      dif = *data - i
      ni.param += dif
 
      if isfile && ( *data >= 0x7FFF || !dif )
      {
         if !( fdwn.write( data ))
         {
            ni.sparam = databuf->str
            ineterror = $ERRINET_WRITEFILE
            nfy( $NFYINET_ERROR )
            goto end
         }
         data.use = 0
      }
   } while dif
   
   nfy( $NFYINET_END )

   ret = 1   
   label end      
   if flag & $HTTPF_STR : data += byte( 0 )
   if fdwn.fopen 
   {
      if flag & $HTTPF_SETTIME && hi.dt.day
      {
         
         filetime ft               
         datetimetoftime( hi.dt, ft, 0 )
         fdwn.settime( ft )
      }
      fdwn.close()
   }
   if !ret && ineterror : nfy( $NFYINET_ERROR )
   
   sock.close( )
   return ret
}

func uint http_get( str url, buf databuf, uint notify, uint flag )
{
   return http_get( url, databuf, notify, flag, 0->str )
}

/*-----------------------------------------------------------------------------
* Id: http_getfile F
*
* Summary: Downloading a file via the HTTP protocol. The method sends a GET
           request to the specified URL and writes data it receives to 
           the specified file.
*
* Params: url - The URL address for downloading.
          filename - The name of the file for writing.
          notify - The #a(inetnotify_func,function) for getting /
                   notifications. It can be 0.
          flag - Flags. $$[httpflag]     
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

func uint http_getfile( str url, str filename, uint notify, uint flag )
{
   flag &= 0xFF0F
   return http_get( url, filename->buf, notify, flag | $HTTPF_FILE )
}

/*-----------------------------------------------------------------------------
* Id: http_head F
*
* Summary: Getting a header via the HTTP protocol. The method sends a HEAD
           request to the specified URL address and partially parses the
           received data.
*
* Params: url - The URL address for getting the header. 
          head - The string for getting the text of the header. 
          hi - The variable of the #a( thttpinfo ) type for getting /
               information about the header. 
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

func uint http_head( str url, str head, httpinfo hi )
{
   uint       ret
   str        request host path
   socket     sock
   
   head.clear()
   if !sock.urlconnect( url, host, path ) : return 0
   
   http_cmd( request, "HEAD", host, path, "", "", sock.isproxy( ))

   if !sock.send( request ) : goto end
   if !sock.recv( head->buf ) : goto end
   head->buf.del( 0, 1 )
   head->buf += byte( 0 )
   ret = 1
   if usecookies : mcookies.parse( host, path, head )
   if &hi : head.ihttpinfo( hi )
   label end      
   sock.close( )
   return ret
}

/*-----------------------------------------------------------------------------
* Id: http_post F
*
* Summary: Sending data via the HTTP protocol. The method sends a POST 
           request with the specified string to the specified URL address. 
           It is used to fill out forms automatically.
*
* Params: url - The URL address where the data will be sent. 
          data - The string with the data being sent. Before the data is /
                 sent, request strings with parameters should be recoded /
                 with the help of the #a(str_iencoding) method. 
          result - The string for getting a response from the server. 
          notify - The #a(inetnotify_func, function ) for getting /
                   notifications. It can be 0. 
*  
* Return: #lng/retf# 
*
-----------------------------------------------------------------------------*/

func uint http_post( str url, str data, str result, uint notify, str otherpars )
{
   str        host path request
   socket     sock
   uint       i dif ret
   httpinfo   hi
   inetnotify ni   
   
   subfunc uint nfy( uint code )
   {
      if !notify : return 1
      
      if !notify->func( code, ni )
      {
         ineterror = $ERRINET_USERBREAK
         ret = 0
         return 0
      }
      return 1
   }
   ineterror = 0
   ni.url = url

   nfy( $NFYINET_CONNECT )
   if !sock.urlconnect( url, host, path ) 
   {
      nfy( $NFYINET_ERROR )
      result->buf += byte( 0 )
      return 0
   }
   
   str stmp 
   if &otherpars: stmp = otherpars 
   
   stmp@"Content-Type: application/x-www-form-urlencoded
Content-Length: \(*data)\l"
   
   http_cmd( request, "POST", host, path, stmp, data, sock.isproxy( ))
   
   if !nfy( $NFYINET_POST ) : goto end
   
   if !sock.send( request ) : goto end

   result->buf.clear()
   ni.param = 0
   do 
   {
      i = *result->buf
      if !nfy( $NFYINET_GET ) : goto end
      sock.recv( result->buf )
      dif = *result->buf - i
      ni.param += dif
   } while dif
   
   str shead
   if !"HTTP".eqlenign( result->buf.ptr()) || ((shead=ni.head.ihead( result->buf )) && !shead.ihttpinfo( hi )) 
   {
      ineterror = $ERRINET_HTTPDATA
      goto end
   }
   if usecookies : mcookies.parse( host, path, shead )
   if &otherpars : otherpars = shead   
   
   result->buf += byte( 0 )
   
   nfy( $NFYINET_END )
   ret = 1
   label end      
   sock.close( )
   return ret
}

func uint http_post( str url, str data, str result, uint notify )
{
   return http_post( url, data, result, notify, "" )
}


/*func test<main>
{   
   inet_init()   
   cookies_init( "cookies.gt" )      
   http_getfile( "http://www.gentee.com/perfect-automation/downloads/pautomation-setup.zip", "pautomation-setup.zip", 0, $HTTPF_SETTIME )
   cookies_deinit() 
   getch() 
}
*/

