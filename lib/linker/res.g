/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: res 15.08.07 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

type reshead32 {
   uint    ressize
   uint    hdrsize
   ushort restypeid
   ushort restype
   ushort resnameid
   ushort resname
   uint   dversion
   ushort memflag
   ushort lang
   uint   version
   uint   characts
} 

type res
{
   buf  data   
   uint iconid      // Последний занятый номер для иконок
   uint ismanifest  // Есть или нет манифест
   uint flags
   uint owner       // Linker
}

include : "ico.g"

define
{
   // Memory/ flags
   RCF_MOVEABLE    = 0x0010
   RCF_PURE          = 0x0020
   RCF_PRELOAD       = 0x0040
   RCF_DISCARDABLE =   0x1000

   // Resource type IDs 
   RC_CURSOR        = 1
   RC_BITMAP        = 2
   RC_ICON          = 3
   RC_MENU          = 4
   RC_DIALOG        = 5
   RC_STRING        = 6
   RC_FONTDIR       = 7
   RC_FONT          = 8
   RC_ACCELERATOR   = 9
   RC_RCDATA        = 10
   RC_MESSAGETABLE  = 11
   RC_GROUP_CURSOR  = 12
   RC_GROUP_ICON    = 14
   RC_VERSION       = 16
   RC_DLGINCLUDE    = 17
   RC_PLUGPLAY      = 19
   RC_VXD           = 20
   RC_ANICURSOR     = 21
   RC_ANIICON       = 22
   RC_MANIFEST      = 24
   RC_DLGINIT       = 240
   RC_TOOLBAR       = 241
   RC_BITMAPNEW     = 0x2002 
   RC_MENUNEW       = 0x2004 
   RC_DIALOGNEW     = 0x2005 
   
   CP_ACP           = 0           // default to ANSI code page
   CP_OEMCP         = 1           // default to OEM  code page
   MB_PRECOMPOSED   = 0x00000001  // use precomposed chars
}

method res res.init
{
   // Добавляем пустой reshead32
   this.data = '\h4 0 20 ffff ffff 0 0 0 0'
   return this
}

method  res.error( uint code, str param )
{
   if this.owner : this.owner->linker.errfunc->func( code, param ) 
   else : exit( 0 )
/*   print( "Resource error: \(msgtext)\nPress any key..." )
   getch()
   exit( 0 )*/
}

method  res.nfy( uint code, str param )
{
   if this.owner : this.owner->linker.nfy( code, param )
}

method res.addresource( uint typeres, str name, buf data )
{
   buf  uname
   uint headsize
   
   if name[0] > '9'  // Указано имя ресурса
   {
      uname.expand( 128 )
      // Переводим в Unicode
      uname.use = MultiByteToWideChar( $CP_ACP, $MB_PRECOMPOSED,
         name.ptr(), 0xFFFFFFFF, uname.ptr(), 64 ) * 2
      uname.align()         
   }
   this.data += *data
   if *uname 
   {
      this.data += sizeof( reshead32 ) + *uname - 4 
         /* - 4 Включенный размер reshead32 resnameid resname  */
   }
   else : this.data += sizeof( reshead32 )
   
   this.data += ushort( 0xFFFF )
   this.data += ushort( typeres )
   
   if *uname 
   {
      this.data += uname
   }
   else 
   {
      this.data += ushort( 0xFFFF )
      this.data += ushort( uint( name ))
   }   
   this.data += '\h4 0 4090000 0 0'
   this.data += data
   this.data.align()
}

method uint res.addicon( str idname iconfile )
{
   uint i added
   buf  groupicon
   arr  icons of iconinfo
   
   if !geticoninfo( iconfile, icons ) : return 0
   groupicon += ushort( 0 )
   groupicon += ushort( 1 )
   groupicon += ushort( *icons )
   
   fornum i, *icons
   {
      uint idir
      idir as icons[i].icondir
      if !idir.bWidth || !idir.bHeight || idir.bWidth > 64 || idir.bHeight > 64 : continue
      added++   
      this.addresource( $RC_ICON, str( ++this.iconid ), icons[i].data )   
      groupicon += byte( idir.bWidth )
      groupicon += byte( idir.bHeight )
      groupicon += byte( idir.bColorCount )
      groupicon += byte( 0)
      groupicon += ushort( idir.wPlanes )
      groupicon += ushort( idir.wBitCount )
      groupicon += idir.dwBytesInRes
      groupicon += ushort( this.iconid )
   }  
   ( groupicon.ptr() + 4 )->ushort = added
   this.addresource( $RC_GROUP_ICON, idname, groupicon )   
   return 1   
}

method uint res.addmanifest( str name )
{
   str manifest access level 
   
   access = ?( this.flags & $RES_ACCESS, "true", "false" )
   level = ?( this.flags & $RES_ADMIN, "requireAdministrator", "asInvoker" )
   
   manifest = "\[..]<?xml version="1.0" encoding="UTF-8" standalone="yes"?> <assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0"> 
   <compatibility xmlns="urn:schemas-microsoft-com:compatibility.v1"> 
      <application> 
        <!--The ID below indicates application support for Windows Vista -->
          <supportedOS Id="{e2011457-1546-43c5-a5fe-008deee3d3f0}"/> 
        <!--The ID below indicates application support for Windows 7 -->
          <supportedOS Id="{35138b9a-5d96-4fbd-8e2d-a2440225f93a}"/>
      </application> 
    </compatibility>
   <assemblyIdentity version="1.0.0.0" name="[..]\(name)\[..]" processorArchitecture="*" type="win32"/> <dependency> <dependentAssembly> <assemblyIdentity type="win32" name="Microsoft.Windows.Common-Controls" version="6.0.0.0" language="*" processorArchitecture="*" publicKeyToken="6595b64144ccf1df" /> </dependentAssembly> </dependency>
   <description>Description</description> 
   <trustInfo xmlns="urn:schemas-microsoft-com:asm.v2">
    <security>
      <requestedPrivileges>
        <requestedExecutionLevel
          level="[..]\(level)\[..]"
          uiAccess="[..]\(access)\[..]"/>
        </requestedPrivileges>
       </security>
  </trustInfo>
</assembly>[..]"

   /*   <requestedExecutionLevel
          level="requireAdministrator"
          uiAccess="false"/>
        </requestedPrivileges>  */  
   manifest->buf.use--
   this.addresource( $RC_MANIFEST, "1", manifest->buf )
   this.ismanifest = 1
   return 1
}

method uint res.addres( str filename )
{
   buf  newres
   uint cur end reshead maxicon data
   
   newres.read( filename )
   if !*newres : return 0

   end = newres.ptr() + *newres
   cur = newres.ptr() + 0x20
   
   while cur < end
   {
      reshead as cur->reshead32
      if reshead.restypeid == 0xFFFF
      {
         switch reshead.restype
         {
            case $RC_ICON
            {
               if reshead.resnameid == 0xFFFF 
               {
                  reshead.resname += this.iconid
                  if maxicon < reshead.resname : maxicon = reshead.resname
               }
            }
            case $RC_GROUP_ICON
            {
               uint count
               
               data = cur + reshead.hdrsize + 4
               count = data->ushort
               data += 2
               while count--
               {
                  ( data + 12 )->ushort += this.iconid
                  data += 14
               }
            }
            case $RC_MANIFEST
            {
               this.ismanifest = 1
            }
         }
      } 
      // Переход на следующий элемент
      cur += reshead.ressize + reshead.hdrsize
      // Выравнивание
      if ( cur - newres.ptr())  & 0x3 : cur += 4 - ( ( cur - newres.ptr()) & 0x3 )      
   }
   this.data.append( newres.ptr() + 0x20, *newres - 0x20 )
   this.data.align()
   if maxicon : this.iconid = maxicon
   return 1
}

method uint res.write( str filename )
{
   return this.data.write( filename )
}

// Добавление иконок из проекта
method uint res.icons( arrstr icolist )
{
   foreach curico, icolist
   {
      arrstr icons
    
      curico.split( icons, ',', $SPLIT_FIRST | $SPLIT_NOSYS )
      if *icons == 1
      {
         icons += icons[0]
         icons[0] = "ICON_APP"
      }
      if !fileexist( icons[1] ) || !this.addicon( icons[0], icons[1] )
      {
         this.error( $RERR_LOADICON, icons[1] )
      }
   }
   return 1
}

// Упаковка и добавление временных файлов
method res.temps( arrstr temps, str geaname )
{
   uint     i
   geae     egea
   geaeinit geai
   geacomp  gc
   str      tempdir
   buf      btemp

   if *geaname : goto readtemp
   
   if !*temps : return
   
   gc.compmethod = $GEA_LZGE
   gc.order = 10
   gc.solid = 0
   geai.flags = $GEAI_IGNORECOPY
   geai.userfunc = ?( this.owner, this.owner->linker.geafunc, 0 )
   
   gettempdir( tempdir )
   geaname = "\(tempdir)\\setup_temp.gea"       
   if !egea.create( geaname, geai )
   {
      this.error( $LERR_OPEN, geaname )
   }
//   print("qqq \(geaname)\n")
   this.nfy( $LNFY_ADDTEMP, "temporary" )

   fornum i, *temps
   {
      arrstr items
      
      temps[i].split( items, ',', $SPLIT_FIRST | $SPLIT_NOSYS )
      if *items != 2 : continue
//      print("\(i)=\( temps[i] )\n")
      gc.idgroup = uint( items[0] )
      if !fileexist( items[1] ) || !egea.add( items[1], gc )
      {
         this.error( $RERR_PACK, items[1] )
      }
   }
   egea.close()
   label readtemp
   btemp.read( geaname )
   this.addresource( $RC_RCDATA, "SETUP_TEMP", btemp )   
}

// Добавление файлов ресурсов
method res.resfiles( arrstr reslist )
{
   foreach curres, reslist
   {
      if !fileexist( curres ) || !this.addres( curres )
      {
         this.error( $LERR_ADDRES, curres )
      }
   }
}