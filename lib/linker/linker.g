/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: linker 15.08.07 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

define
{
   LINK_GUI   = 0x0001    // GUI application
   LINK_ONE   = 0x0002    // Just one copy can be run
   LINK_SIZE  = 0x0004    // Check the minimum size of exe file
   LINK_PACK  = 0x0008    // Compress the byte-code & DLL
   LINK_DLL   = 0x0010    // Use gentee.dll
   LINK_CHAR  = 0x0020    // Print Window characters
   LINK_ASM   = 0x0040    // The bytecode can have ASM commands 
   LINK_ASMRT = 0x0080    // Run-time converting the bytecode to ASM commands
   LINK_TMPRAND = 0x0100  // Random temporary folder
   LINK_PARAM   = 0x0200  // Specify param
   // res.flags
   RES_ACCESS = 0x1000 // Manifest uiAccess = true
   RES_ADMIN  = 0x2000 // Manifest level = requireAdministrator

   LINKSAVE_EXE  = 0x0001 // Установить exesize
   LINKSAVE_MIN  = 0x0002 // Установить minsize
   LINKSAVE_EXT  = 0x0004 // Добавить расширенный блок
   
   LINKFLD    = $"res\linker"
   
   // error codes
   LERR_OPEN = 0      
   LERR_NOTLAUNCH
   LERR_WRITE
   LERR_TMPRES
   LERR_ADDRES
   LERR_COPY
   LERR_READ
   LERR_SECTION
   LERR_MANIFEST
   RERR_LOADICON
   RERR_PACK
   LNFY_ADDTEMP = 255
}

type linker {
   str   input      // Input GE file
   str   output     // Output executable filename
   uint  flag       // Flags
   uint  param      // Additional parameter
   arrstr  icons    // Icons <idname,iconfile>
   arrstr  temps    // Temporary files <id,tempfile>
   arrstr  res      // Resource files to link
   str     geatemp  // Ready temporary GEA file
   uint    errfunc  // Error message function
   uint    geafunc  // GEA message function
   uint    nfyfunc  // Linker notify function
}

method  linker.nfy( uint code, str param )
{
   if .nfyfunc : .nfyfunc->func( code, param ) 
}               

include
{ 
   $"..\gea\gea.g"
   "res.g"
}

type linkhead
{
   uint   sign1           // 'Gentee Launcher' sign
   uint   sign2           // 
   uint   sign3           // 
   uint   sign4           // 
   uint   exesize         // Размер exe-файла.
                          // Если не 0, то файл является SFX 
                          // архивом и далее идут прикрепленныe данные
   uint   minsize         // Если не 0, то выдавать ошибку если размер файла
                          // меньше указанного
   ubyte  console         // 1 если консольное приложение
   ubyte  exeext          // Количество дополнительных блоков
   ubyte  pack            // 1 если байт код и dll упакованы
   ushort flags           // flags
   uint   dllsize         // Упакованный размер Dll файла. 
                          // Если 0, то динамическое подключение gentee.dll
   uint   gesize          // Упакованный размер байт-кода.
   uint   mutex           // ID для mutex, если не 0, то будет проверка
   uint   param           // Зашитый параметр
   uint   offset          // Смещение данной структуры
   reserved extsize[ 64 ] // Зарезервированно для размеров 8 ext блоков
                          // Каждый размер занимает long
}

import "\$LINKFLD\\EXELink.dll"<exe>
{
   uint Add_Res_Section( uint, uint )
   uint Add_Data_Section( uint, uint, uint )
   uint Set_Sub_System( uint, uint )
   uint Set_OS_Version( uint, uint )
}

import "kernel32.dll"
{
        Sleep( uint )
   uint GetTickCount()
}

method  linker.error( uint code, str param )
{
//   print( "Linker error: \(msgtext)\nPress any key..." )
//   getch()
   if .errfunc : .errfunc->func( code, param ) 
   else : exit( 0 )
}

method  linker.error( uint code )
{
   this.error( code, 0->str ) 
}

method uint linker.savehead( linkhead lnkhead, uint flags )
{
   // Записываем заголовок linkhead
   file fexe
   uint handle fsize launchoff phead
   spattern  pattern
   buf       btemp
   
//   if !fexe.open( .output, 0 ) : this.error( $LERR_OPEN, .output )
   uint itry
   label againtry

//   print( "SAVE " )
   if !fexe.open( .output, 0 )
   {
//      print(" Try 0=\( itry )\l")
      if itry >= 3 : this.error( $LERR_OPEN, .output )
      itry++
      Sleep( 500 )
      goto againtry    
   }
//   print( "OK " )
   pattern.init( '\"Gentee Launcher"', 0 )
   btemp.expand( 0x20000 )
   
   btemp.use = fexe.read( btemp.ptr(), 0x20000 )
   
   launchoff = pattern.search( btemp, 0 )
   if launchoff >= *btemp : this.error( $LERR_NOTLAUNCH, .output ) 

   phead as lnkhead
   if !&lnkhead
   {  // Читаем структуру linkhead из файла
      phead as ( btemp.ptr() + launchoff )->linkhead
   }
   phead.offset = launchoff
   fsize = fexe.getsize()
   
   if flags & $LINKSAVE_EXE : phead.exesize = fsize
   if flags & $LINKSAVE_MIN : phead.minsize = fsize
   if flags & $LINKSAVE_EXT
   {
      long prevsize
      uint i ptr
      prevsize = long( phead.exesize )
      ptr = &phead.extsize
       
      fornum i, phead.exeext  
      {
         prevsize += ptr->long
         ptr += sizeof( long )      
      }
      phead.exeext++
      ptr->long = long( fsize ) - prevsize
//      print("EXt=\( phead.exeext ) size = \( ptr->long ) exe=\(phead.exesize)\n")
   }
   if !fexe.writepos( launchoff, &phead, sizeof( linkhead ))
   {
      this.error( $LERR_WRITE, .output )
   }
   fexe.close()
   return fsize
}

// gentee !!!
/*method uint buf.readappend( str filename )
{
   file f
   uint rd
   
   if f.open( filename, $OP_READONLY )
   {   
      uint size = f.getsize()
      .expand( size + 128 ) // резервируем для возможного str
      rd = f.read( this.data + this.use, size ) 
      this.use += rd
      f.close( )
   }
   return rd
}
*/

method  uint linker.create
{
   buf       ge
   str       pattern
   linkhead  lnkhead
   str       tempdir stemp launcher
   uint      ret last
   file      exefile
   res       exeres

   this.input.ffullname( this.input )
   if this.flag & $LINK_PACK
   {
      buf  in 
      lzge lz 
      
      ge.expand( 4200000 )
      getmodulepath( pattern, "\$LINKFLD\\genteert.bin" ) 
      if !ge.read( pattern ) : this.error( $LERR_READ, pattern )
      lnkhead.dllsize = *ge
      lnkhead.pack = 1
      this.flag &= ~( $LINK_ASMRT | $LINK_ASM | $LINK_DLL )

      in.read( this.input )
      lz.order = 10
      ge.use += lzge_encode( in.ptr(), *in, ge.ptr() + lnkhead.dllsize + 4, lz ) + 4
      ( ge.ptr() + lnkhead.dllsize )->uint = *in
//      print("Exe=\(lnkhead.dllsize) \( *in) => \(ge.use - lnkhead.dllsize)\n")
   }   
   elif !ge.read( this.input ) : this.error( $LERR_READ, this.input ) 
      
   if this.flag & $LINK_DLL
   {
      if this.flag & $LINK_ASMRT : launcher = "launcherda"
      else : launcher = "launcherd"
   }
   else
   {
      if this.flag & $LINK_ASMRT : launcher = "launcherart"
      elif this.flag & $LINK_ASM : launcher = "launchera"
      elif this.flag & $LINK_PACK : launcher = "minilauncher"
      else : launcher = "launcher"
   }      
   getmodulepath( pattern, "\$LINKFLD\\\(launcher).exe" ) 
   if !*this.output : .output.fsetext( .input, "exe" )   
   this.output.ffullname( this.output )
   
   uint itry
   label againtry
   if !( exefile.open( this.output, $OP_EXCLUSIVE | $OP_CREATE ))
   {
      if itry >= 4 : this.error( $LERR_OPEN, .output )
      itry++
      Sleep( 500 )
      goto againtry    
   }
   last = this.output[ *this.output - 1 ]
   this.output[ *this.output - 1 ] = '_'
   itry = 0
   label copytry
   if !copyfile( pattern, .output )
   {
      if itry >= 3 : this.error( $LERR_OPEN, .output )
      itry++
      Sleep( 500 )
      goto copytry    
   }
   lnkhead.sign1 = 0x746E6547
   lnkhead.sign2 = 0x4C206565
   lnkhead.sign3 = 0x636E7561
   lnkhead.sign4 = 0x00726568
   
   if !( this.flag & $LINK_GUI )
   {
      lnkhead.console = $G_CONSOLE
      Set_Sub_System( .output.ptr(), 1 )
   }   
   lnkhead.flags = 0
   if this.flag & $LINK_CHAR : lnkhead.console |= $G_CHARPRN
   if this.flag & $LINK_ONE : lnkhead.mutex = GetTickCount()
   if this.flag & $LINK_TMPRAND : lnkhead.flags = $G_TMPRAND
   if this.flag & $LINK_PARAM : lnkhead.param = this.param
   
   gettempdir( tempdir )
   ( pattern = tempdir ).faddname( "gedata" )
   lnkhead.gesize = *ge - lnkhead.dllsize 
   
   if !ge.write( pattern ) : this.error( $LERR_WRITE, pattern )
   if ret = Add_Data_Section( .output.ptr(), ".gentee".ptr(), pattern.ptr())
   {
      this.error( $LERR_SECTION )
//      if ret == 4 : mustunicows()
   }
   
   exeres.owner = &this
// Добавляем иконки
   exeres.icons( this.icons )
   exeres.temps( this.temps, this.geatemp )
   exeres.resfiles( this.res )

   if !exeres.ismanifest && this.flag & $LINK_GUI
   {
      this.output.fgetparts( 0->str, stemp, 0->str )
      exeres.flags |= this.flag & 0xF000
      if !exeres.addmanifest( stemp ) : this.error( $LERR_MANIFEST )
   }
   if *exeres.data > 0x20 
   {
      stemp = "\(tempdir)\\temp.res"
      if !exeres.write( stemp ) : this.error( $LERR_TMPRES, stemp )
      if ret = Add_Res_Section( .output.ptr(), stemp.ptr())
      {
         this.error( $LERR_ADDRES, stemp )
//         if ret == 4 : mustunicows()
      }
   }
   
   ret = this.savehead( lnkhead, $LINKSAVE_EXE | ?( this.flag & $LINK_SIZE, 
                        $LINKSAVE_MIN, 0 ))
   stemp = .output
   this.output[ *this.output - 1 ] = last
   exefile.close()
   deletefile( .output )
   if !movefile( stemp, .output ) : this.error( $LERR_COPY, .output )
   Sleep( 100 )

   return 1
}
