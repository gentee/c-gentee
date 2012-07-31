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

method str gead.getdiskname( uint num, str result )
{
   str stemp

   if !num : return result = this.filename

//   int2str( stemp, this.pattern, num )
   stemp.out4( this.pattern, num )

   return ( result = this.lastpath ).faddname( stemp )   
}

//--------------------------------------------------------------------------

method uint gead.opendisk( uint num )
{
   str  diskname dir 
   buf  head      

   if this.curdisk == num : return 1

   close( this.handle )

   getcurdir( dir )   
   // Существует ли файл
   while 1
   {
      this.getdiskname( num + 1, diskname )
//      print( "\(num) \(this.curdisk) Disk = \(diskname) \(this.lastpath)\n")
      if !fileexist( diskname )
      {
         if this.mess( $GEAMESS_GETVOLUME, %{ diskname, num + 1 }) ==
             $GEA_ABORT : return 0
         getcurdir( this.lastpath ) 
      }
      else : break            
   }
   setcurdir( dir ) 
   this.curfilename = diskname           
   if !( this.handle = gea_fileopen( diskname, $OP_READONLY, 
      this.userfunc )) : return 0
   this.curdisk = num
   
   if num
   {  // Проверка на правильность тома
      uint gv
      long size
      
      read( this.handle, head, sizeof( geavolume ))
      gv as head.ptr()->geavolume
      if gv.name != $GEA_NAME
      {
         return this.mess( $GEAERR_NOTGEA, %{ diskname })   
      }
      if gv.unique != this.volume.unique
      {
         return this.mess( $GEAERR_WRONGVOLUME, %{ diskname })   
      }
      if num == this.head.count - 1 : size = this.head.lastsize
      else : size = this.head.volsize
      if getlongsize( this.handle ) < size
      {
         return this.mess( $GEAERR_WRONGSIZE, %{ diskname })   
      }       
   }
   return 1      
}

//--------------------------------------------------------------------------

method uint gead.read( long off, uint size )
{  // Метод читает и возвращает указатель на данные
   uint ptr = this.input.ptr()
   uint curoff

//   print("Enter = \(off) \(size) \( this.inoff ) \( this.insize )\n")
   // Данные уже прочитаны
   if off >= this.inoff && off + long( size ) <= this.inoff + long( this.insize )
   {
//      print("Ooops\n")
      return ptr + uint( off - this.inoff )
   }
//   print("Read 1 \(uint( off - this.inoff )) \(uint( this.inoff + 
//             long( this.insize ) - off ))\n")
   // Данные прочитаны частично
   if off >= this.inoff && off < this.inoff + long( this.insize )
   {
      mmove( ptr, ptr + uint( off - this.inoff ), uint( this.inoff + 
             long( this.insize ) - off ))
//      print("Move = \(off - this.inoff) size \(this.inoff + long( this.insize ) - off)\n")
      this.insize -= uint( off - this.inoff )
      size -= this.insize
      curoff = this.insize      
   }
   else : this.insize = 0
   
   this.inoff = off
   off += long( this.insize )

   if off + long( size ) > this.head.summary
   {
      return this.mess( $GEAERR_INTERNAL, %{ this.filename, 1 }) 
   }
//   print("0 = \(curoff) \(this.insize) off=\(off) \( size )\n")
   while size
   {
      uint i canread
      long moveoff 

      moveoff = this.voloff[ this.head.count ]
      // Если перемещенные данные
      if this.head.movedsize && off >= moveoff 
      {
//         print("Moved off = \( off ) \(uint( off - moveoff )) size = \(size) curoff = \(curoff)\n")
         mcopy( ptr + curoff, this.moved.ptr() + uint( off - moveoff ), 
                size )
         curoff += size
//         this.insize += size
         break
      } 
      // Определяем требуемый том
      fornum i, *this.voloff - 1
      {
         if !this.volsize[i] : continue
         if off < this.voloff[ i + 1 ] : break    
      }
      if i >= this.head.count : i = this.head.count - 1
      if !this.opendisk( i ) : return 0
      moveoff = off - this.voloff[ i ]
      canread = min( size, uint( this.volsize[i] - moveoff ))
      if !i
      {
         moveoff += long( this.head.size + this.head.movedsize + this.geaoff )
      }
      else : moveoff += long( sizeof( geavolume ))

      setlongpos( this.handle, moveoff, $FILE_BEGIN )
//      print("Read 3 \( moveoff ) Off=\( this.voloff[ i ] ) size=\(this.volsize[i]) \(canread) \(size)\n")
      size -= canread  
      off += long( canread )
/*      if uint( this.volsize[i] - moveoff ) > canread
      {
         canread = min( 0x80000, uint( this.volsize[i] - moveoff + 10L)) 
      }*/       
      canread = max( canread, min( this.input.size - curoff, 0x80000 ))
//      print("Read \( this.curfilename) fileoff = \(setpos(this.handle, 0, $FILE_CURRENT )) \( canread )\n ")
      uint ri rw
      ri = ReadFile( this.handle, ptr + curoff, canread, &canread, 0  )
      if !i && moveoff + long( canread ) > this.head.geasize
      {  // Дать возможность добавлять Digital Signature
         canread = uint( this.head.geasize - moveoff )  
      }   
/*      if !ri
      {
         ri = ReadFile( this.handle, ptr + curoff, canread, &rw, 0  )
         print("Read ERR \(ri) \(rw) \(getsize( this.handle )) \(setpos(this.handle, 0, $FILE_CURRENT )) \( curoff)\n")
      }*/
//      print("Read 4 \(ri) \(off) \(canread) \(ptr + curoff) \(setpos(this.handle, 0, $FILE_CURRENT ))\n")
      curoff += canread                  
//      print("Read 5 \(curoff) \(canread) \(size) \n")
   }
//   print("Read 6 \(curoff) \(ptr) \n")
   this.insize = curoff                  
   return ptr      
}

//--------------------------------------------------------------------------

/*func  uint  geacrc( uint ptr size param )
{
   param->uint = crc( ptr, size, param->uint )
   return 1 
}*/

//--------------------------------------------------------------------------

//method uint gead.unpack( uint off, uint size )
method uint gead.unpack( uint id out )
{
   uint  gf  ctype corder 
   uint  input
   uint  ptr size 
   geadata    gd 
   long       off
   geaparam   gp
   uint       icrc = 0xFFFFFFFF
   
//   this.output.clear()
   if id >= *this.fileinfo : return 0

//   binput.expand( this.head.blocksize )
   gf as this.fileinfo[ id ]
   if gf.flags & $GEAF_SOLID && id - 1 != this.lastsolid
   {
      uint demode ptemp = this.userfunc
      this.userfunc = 0
//      print("------------ \(id - 1) \(this.lastsolid)\n")
      this.unpack( id - 1, 0 )
      this.userfunc = ptemp   
//      print("============\n")
   }
   this.mess( $GEAMESS_DEBEGIN, %{ this.filename, &gf })
//   print("Name=\(gf.name) \(id)\n")
   
   size = gf.size
   off = this.offset[ id ]

//   print( "size 0 =\(size)\n")
   subfunc uint readdata
   {
      uint solidoff
        
      input = this.read( off, sizeof( geadata ))
         
      gd.order = uint( input->geadata.order ) & ~0x80
      gd.size = input->geadata.size
      off += long( sizeof( geadata ))
      ctype = gd.order >> 4
      corder = ( uint( gd.order ) & 0x0F ) + 1
//      print( "corder = \( corder )\n")
      // Обнуляем output
      if ( ctype != $GEA_LZGE || corder > 1 )
      {
         this.output.clear()
      }
      else
      {
         // Сдвигаем данные для solid
         if *this.output + min( size, this.blocksize ) > 
                               this.blocksize + this.solidsize
         {
            this.output.del( 0, *this.output - this.solidsize )
         }
         solidoff = *this.output
      }
      return solidoff 
   }    
   gp.done = 0
   gp.name = ""//fullname
   gp.info = &gf
   gp.mode = 1

   if gf.idpass  // разшифровываем  
   {
      label againpass
      
//      print("ID=\(gf.idpass) \()\n")
      if !*this.passwords[ gf.idpass - 1 ]
      {
         if this.mess( $GEAMESS_PASSWORD, %{ this.filename, gf })
         {
            goto againpass
         }
         else : return 0
      }
   }
   
   while size
   {
      lzge  lz
      ppmd  ppm
      
      if !gd.size : lz.solidoff = readdata()
   
//      print("1 =\( uint(off->long) + this.head.size ) \(gd.size + sizeof( geadata )) == \(size) \(gd.order) \(input->geadata.order)\n")       
         
      uint isize osize
   
      ptr = this.output.ptr()
      isize = min( this.blocksize, gd.size )
      input = this.read( off, isize )
      if gf.idpass  // раcшифровываем  
      {
         gea_protect( input, isize, this.passbufs[ gf.idpass - 1 ] )
      }
      
      off += long( isize )
      osize = ?( ctype, min( this.blocksize, size ), isize )
      switch ( ctype )
      {
         case $GEA_STORE
         { 
            ptr = input
            this.mess( $GEAMESS_PROCESS, %{ this.filename, gf, osize + gp.done })
         }
         case $GEA_LZGE
         {
//            print("Input=\(input - this.input.ptr()) Outsize=\( this.output.size) Out=\(*this.output) Solidoff=\(lz.solidoff ) osize=\( osize ) isize = \(isize)\n")
            lz.userfunc = this.userfunc
            lz.pgeaparam = &gp
//            print("\n1 \(lz.solidoff + osize) \( *this.output ) \( this.output.size )
//            Off = \( input - this.input.ptr() )\n") 
            lzge_decode( input, ptr, lz.solidoff + osize, lz )
            this.output.use = lz.solidoff + osize
            ptr += lz.solidoff 
//            ptr += lz.solidoff 
         }
         case $GEA_PPMD
         {
            ppm.order = corder
            ppm.userfunc = this.userfunc
            ppm.pgeaparam = &gp 
            ppmd_decode( input, gd.size, ptr, osize, ppm )
   //         ptr = this.output.ptr()
         }
      }
      gp.done += osize
      gd.size -= isize
      icrc = crc( ptr, osize, icrc )
      if out 
      {
         if this.demode == $GEAD_MEM : out->buf.append( ptr, osize )
         elif this.demode == $GEAD_FILE
         { 
            uint iw
            if !WriteFile( out, ptr, osize, &iw, 0 ) || iw != osize
            {
               this.mess( $GEAERR_FILEWRITE, %{ gf.name })
               return 0
            }
         }
      }
//      print( "SS = 6 \( osize ) \(*( out->buf ))\n")
//      geacrc( ptr, osize, param )
      size -= osize
   }
   if icrc != gf.crc
   { 
      this.mess( $GEAERR_CRC, %{ this.filename, &gf } ) 
   }  
   this.mess( $GEAMESS_DEEND, %{ this.filename, &gf })

   this.lastsolid = id
   return 1
}

//--------------------------------------------------------------------------

method uint gead.test( uint id )
{
   this.demode = $GEAD_TEST
   return this.unpack( id, 0 )
}

//--------------------------------------------------------------------------

method uint gead.file2mem( uint id, buf output )
{
   this.demode = $GEAD_MEM
   output.clear()
   return this.unpack( id, &output )
}

//--------------------------------------------------------------------------

method uint gead.file2file( uint id handle )
{
   this.demode = $GEAD_FILE
   return this.unpack( id, handle )
}

//--------------------------------------------------------------------------

method long gead.summarysize
{
   uint i
   long result
 
   fornum i, *this.fileinfo
   {
//      print("i =\(i) Name=\(this.fileinfo[ i ].name) Subfolder = \(this.fileinfo[ i ].subfolder) Size = \( this.fileinfo[ i ].size )\n")
      result += long( this.fileinfo[ i ].size )
   }
   return result
}

//--------------------------------------------------------------------------


