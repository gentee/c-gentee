/******************************************************************************
*
* Copyright (C) 2004-2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/
include {   
   "..\\gt\\gt.g"      
}

type cookies <inherit = gt>
{
   str curfilename
   hash hosts      
}

type cookie
{
   str name
   str value
   str domain
   str path
   datetime  expires 
   uint secure
}

method cookies.read( str filename )
{
   datetime cdt, dt   
   cdt.gettime()
   this->gt.read( filename )
   .curfilename = filename   
   foreach chost, this.root()
   {      
      foreach ccookie, chost
      {
         dt.fromstr( ccookie.get( "expires" ))
         if dt < cdt 
         {
            ccookie.del()
         }
      }
      if chost.child()
      {  
         str name
         chost.get("name", name )
         this.hosts[name] = &chost
      }
      else : chost.del()
      
   }
}

method cookies.write( str filename )
{  
   if &filename && *filename : this->gt.write( filename )      
}

method cookies.write()
{   
   .write( .curfilename )
}


method str cookies.get<result>( str host, str path )
{  
   datetime cdt, dt   
   arrstr arp
   cdt.gettime()
   str domain2 
   host.split( arp, '.', 0 )
   if *arp >= 1
   {
      domain2 = "\(arp[*arp-2]).\(arp[*arp-1])"
   }
   else : domain2=host
   
   uint chost = .hosts.find(domain2)
   if chost
   {
      chost as chost->uint->gtitem
      foreach ccookie, chost
      {
         
         dt.fromstr( ccookie.get( "expires" ) )
         if dt.year!=0 && dt < cdt 
         {
            ccookie.del()
         }
         else
         {    
            if ccookie.get( "path" ).eqlen( path )
            { 
               str domain
               ccookie.get( "domain", domain ) 
               if *host >= *domain 
               {
                  if "".substr( host, *host - *domain, *domain ) == domain
                  {
                     if *result : result@"; "
                     result@"\(ccookie.get("name",""))=\(ccookie.value)"
                  }
               }
            }

/*            str cpath
            ccookie.get( "path", cpath )
            if cpath.eqlen( path )
            {
               if *result : result@"; ";
               result@"\(ccookie.name)=\(ccookie.value)"
            }*/
         }  
      }
   }      
}


method cookies.set( str host, str path, str setcookie )
{
   cookie c
   arrstr arp
   str domain2 
   host.split( arp, '.', 0 )
   if *arp >= 1
   {
      domain2="\(arp[*arp-2]).\(arp[*arp-1])"
   }
   else : domain2=host
   arp.clear()   
   
   c.path = path
   c.domain = host
   
   setcookie.split( arp, ';', $SPLIT_NOSYS )
   foreach pair, arp
   {
      arrstr arv
      pair.split( arv, '=', $SPLIT_NOSYS | $SPLIT_FIRST )
      if *arv
      {         
         str val, stmp
         
         if *arv[0] > 4096 : arv[0].setlen( 4096 )  
         if *arv > 1
         {              
            val = arv[1]
            if *val > 4096 : val.setlen( 4096 )
         }
         stmp = arv[0]
         stmp.lower()
         switch ( stmp )
         {
            case "secure": c.secure = 1
            case "path":   c.path   = val
            case "domain": c.domain = val
            case "expires": c.expires.frominet( val )
            case "httponly": ;
            default
            {                 
               c.name   = arv[0]
               c.value  = val
            }
         }
      }
   }
   if *c.name
   { 
      uint curhost      
      if curhost = this.hosts.find( domain2 )
      {
         curhost = curhost->uint
      }
      else
      {
         curhost as this.root().insertchild( "", (-1)->gtitem )
         curhost.set( "name", domain2 )
         this.hosts[ domain2 ] = &curhost
      }
      
      curhost as gtitem
      
      foreach curcookie, curhost
      {
         if curcookie.get( "name" ) == c.name  &&
            curcookie.get( "path" ) == c.path  &&
            curcookie.get( "domain" ) == c.domain 
         {
            break
         }
      }
      if !&curcookie
      {
         curcookie as curhost.insertchild( "", (-1)->gtitem  )
      }
      
      curcookie.value = c.value
      curcookie.set( "name", c.name )
      curcookie.setuint( "secure", c.secure )
      curcookie.set( "path", c.path )
      curcookie.set( "domain", c.domain )
      curcookie.set( "expires", c.expires.tostr("") )      
   }    
}

method cookies.parse( str host, str path, str shead )
{
   arrstr   val 
   arrstr   lines 
   shead.split( lines, 0xA, $SPLIT_NOSYS )
   if *lines
   {  
      foreach cur, lines
      {
         cur.split( val, ':', $SPLIT_NOSYS | $SPLIT_FIRST )                  
         if *val == 2 &&
            val[0] == "Set-Cookie" : this.set( host, path, val[1] )
      }
   }
}

global {
   cookies mcookies
   uint usecookies 
}

/*-----------------------------------------------------------------------------
* Idx: cookies_init F
*
* Summary: Cookies initialization. Функции http_get, 
           http_post, http_file, http_header будут использовать cookies.
           Cookies от предыдущих сеансов будут браться из файла. 
*
* Params: filename - The file name where stored cookies data.               
*
-----------------------------------------------------------------------------*/
func cookies_init( str filename )
{
   usecookies = 1
   mcookies.clear()
   mcookies.read( filename )
}

/*-----------------------------------------------------------------------------
* Idx: cookies_init F
*
* Summary: Cookies initialization. Функции http_get, 
           http_post, http_file, http_header будут использовать cookies.           
*
* Params: filename - The file name where stored cookies data.               
*  
-----------------------------------------------------------------------------*/
func cookies_init( )
{
   cookies_init( "" )
}

/*-----------------------------------------------------------------------------
* Idx: cookies_deinit F
*
* Summary: Отключение использования cookies и запись данных в файл, 
           если он был указан при cookies_init.
*
*
-----------------------------------------------------------------------------*/
func cookies_deinit( )
{  
   usecookies = 0  
   mcookies.write()
   mcookies.hosts.clear()
   mcookies.clear()
}
