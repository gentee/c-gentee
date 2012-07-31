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

type geacomp
{
    uint    idgroup     // id of the file group
    str     subfolder   // subfolder
    str     password    // password
    uint    compmethod  // compression algorithms
    uint    order       // compression order
    uint    solid       // 1 if solid archive
}

// Функция прямой записи в файл
method uint geae.write( uint ptr size )
{
   uint iw
   
   if !WriteFile( this.curhandle, ptr, size, &iw, 0 ) || 
                  iw != size
   {
      this.mess( $GEAERR_FILEWRITE, %{ this.curfilename })
      return 0
   }
//   this.volumes[ *this.volumes - 1 ] += long( size )
   this.volumes[ this.curvol ] = getlongsize( this.curhandle )
   return 1
}

// Функция записи в файл с учетом разбивки на тома
method uint geae.writevolume( uint ptr size )
{
   uint num 
   str  stemp
   
   if !size : return 1
   
   if !*this.volumes   // Первая запись данных
   {
      buf   btemp
      
      btemp.expand( $GEA_DESCRESERVE )
      mzero( btemp.ptr(), $GEA_DESCRESERVE )
      btemp.use = $GEA_DESCRESERVE
      this.volumes.expand( 1 )
      this.volumes[ 0 ] = long( this.geaoff ) 
      if this.volsize && this.volsize < long( this.geaoff +
                                                 $GEA_DESCRESERVE )
      {    // Оставляем первый том полностью пустым
         this.emptyvol = 1    
//         this.volumes.expand( 1 )
//         this.curvol = 1
      } 
      else  // Резервируем место 
      {
         if !this.write( btemp.ptr(), $GEA_DESCRESERVE ) : return 0
      }
   }
   label volume
   if this.volsize  // Проверка на заполнение тома
   {
      num = this.curvol //= *this.volumes - 1
//         print("OK 1 \(this.volumes[ num ]) \(wsize) \(this.volsize)\n") 
      if this.volumes[ num ] + long( size ) >= this.volsize
      {
         uint rem
         
         if this.volsize > this.volumes[ num ] && ( num || !this.emptyvol )
         {  // Дописываем остатки
            rem = uint( this.volsize - this.volumes[ num ] )
            if !this.write( ptr, rem ) : return 0
         }
         size -= rem
         ptr += rem
         // Закрываем том
         if num : close( this.curhandle )
         // Создаем новый том
         num++
         if num > $GEA_MAXVOLUMES
         {
            this.mess( $GEAERR_MANYVOLUMES, %{this.curfilename })
            return 0
         }
         this.curvol = this.volumes.expand( 1 )
         geavolume gv
         gv.name = 0x414547 
         gv.unique = this.unique
         gv.number = num
//         int2str( stemp.clear(), this.pattern, num + 1 )
         stemp.clear()
         stemp.out4( this.pattern, num + 1 )                   
         this.volnames += stemp
         ( this.curfilename = this.volpath ).faddname( stemp )
         label again
         if !( this.curhandle = open( this.curfilename, $OP_EXCLUSIVE | 
                                       $OP_CREATE ))
         {
            switch this.mess( $GEAERR_FILEOPEN, %{ this.curfilename })
            {
               case $GEA_RETRY : goto again
               case $GEA_ABORT : return 0
            }
         }
         if !this.write( &gv, sizeof( geavolume )) : return 0
         goto volume
      }
   }
   if !this.write( ptr, size ) : return 0
//   congetch("Ooops = \(size)\n")
   return 1
}

method uint geae.put( uint ptr size )
{
   uint avail
   uint pout  full end start stop
   
   subfunc uint  storebuf( uint rem )
   {
      uint iw = full - avail - rem        // Сколько записать

      if start + iw < stop
      {
         if !this.writevolume( start, iw ) : return 0
         start += iw
      }
      else
      {
         if !this.writevolume( start, stop - start ) : return 0
         iw -= stop - start
         if !this.writevolume( pout, iw ) : return 0
         start = pout + iw
      }
      if !rem
      {
         start = pout
         end = pout 
      }
      avail = full - rem
      return 1
   }
   subfunc uint finish()
   {  // Запись оставшихся данных
      if !*this.volumes
      {   // Записей не было и заголовок уже записан. Пишем все данные
         this.volumes.expand( 1 )
         this.volumes[ 0 ] = getlongsize( this.curhandle )
//         print("Volume = \( this.volumes[ 0 ] )\n")
      }
      else  // Есть зарезервированное место
      {
         if this.emptyvol
         {  // Нет зарезервированного места
            this.volumes[ 0 ] = getlongsize( this.handle )
            if this.volsize > this.volumes[ 0 ]
            {
               // this.volsize - this.volumes[ 0 ] не больше uint иначе не
               //  может быть emptyvol 
               this.head.movedsize = uint( this.volsize - this.volumes[ 0 ] )
            }
         }
         else
         {
            this.head.movedsize = $GEA_DESCRESERVE - this.head.size
         }
         setpos( this.curhandle, 0, $FILE_END )
         // Дописываем остатки
         if !storebuf( this.head.movedsize ) : return 0
         if this.curhandle != this.handle : close( this.curhandle )
         // Дописываем в главный файл
         this.curhandle = this.handle
         setpos( this.handle, this.geaoff + this.head.size, $FILE_BEGIN )
         this.curvol = 0
         this.volsize = 0L
      }
      // Записываем все из буфера в первый том
      if !storebuf( 0 ) : return 0

      return 1
   }
   pout = this.out.ptr()
   full = *this.out
   end = this.end
   start = this.start
   stop = this.stop
   avail = ?( end >= start, full - ( end - start ), start - end )

   if !ptr : return finish()

   this.head.summary += long( size )
   this.fileinfo[ *this.fileinfo - 1 ].compsize += size
//   print("\n\(this.fileinfo[ *this.fileinfo - 1 ].compsize)\n")

   if size >= avail
   {  // Необходимо записать лишнее на диск
      if size > $GEA_DESCRESERVE
      {
         // Записываем все из буфера
         if !storebuf( 0 ) : return 0
         // Записываем часть из ptr
         if !this.writevolume( ptr, size - $GEA_DESCRESERVE ) : return 0
         ptr += size - $GEA_DESCRESERVE
         size = $GEA_DESCRESERVE
      }
      else
      {     // Записываем часть из буфера
         if !storebuf( $GEA_DESCRESERVE - size ) : return 0
      } 
   }
   // Записываем данные в буфер
   if stop - end  > size
   {
      mcopy( end, ptr, size )
      end += size
   }     
   else
   {
      uint rem = stop - end
      mcopy( end, ptr, rem )
      mcopy( pout, ptr + rem, size - rem )
      end = pout + size - rem     
   }
   this.end = end
   this.start = start
   return 1
}

method  uint geae.add( str filename, geacomp gc )
{
   geaparam   gp
   uint cursize blocksize solidsize
   uint handle curid gf i
   str  fullname fpath fname
   buf  in out
   
   fullname.ffullname( filename )
   fname.fnameext( fullname )
   fpath.fgetdir( fullname )
   if fpath %== this.volpath   // Проверка на имя тома
   { 
      foreach curvol, this.volnames : if curvol %== fname : return 1  
   }
   // Проверка на то, что уже добавлен
   if i = this.addedfiles.find( fullname )
   {
      this.mess( $GEAMESS_COPY, %{ fullname })
      if this.flags & $GEAI_IGNORECOPY : return 1
   } 
   else
   {  // Добавление в добавленные
      this.addedfiles[ fullname ] = 1 
   }

   // Открываем файл
   if !( handle = gea_fileopen( fullname, $OP_READONLY, this.userfunc ))
   {
      return 0
   }
   // Не принимаем слишком большие файлы
   if getlongsize( handle ) >= 0xFFFF0000L
   {
      close( handle )  
      return this.mess( $GEAERR_TOOBIG, %{ fullname }) == $GEA_IGNORE
   }  
   curid = this.fileinfo.expand( 1 ) 
   gf as this.fileinfo[ curid ]
   gf.name = fname
   gf.crc = 0xFFFFFFFF
   gf.idgroup = gc.idgroup
   gf.subfolder = gc.subfolder
   // Получаем время, размер, атрибуты, версию 
   getftime( handle, gf.ft )
   gf.size = getsize( handle )
   gf.attrib = getfileattrib( fullname ) 
   getfversion( fullname, &gf.hiver, &gf.lowver )
   if *gc.password
   {  // Есть такой пароль или нет
      fornum i = 0, *this.passwords
      { 
         if this.passwords[ i ] == gc.password
         { 
            gf.idpass = i + 1
            break
         }
      }
      if !gf.idpass   // Если не нашли то добавляем пароль
      {
         this.passwords += gc.password
         gea_passgen( this.passbufs[ this.passbufs.expand( 1 ) ], 
                      gc.password )
         gf.idpass = *this.passwords
      }
   }
   this.mess( $GEAMESS_ENBEGIN, %{ fullname, gf })
   blocksize = 0x40000 * this.head.blocksize
   solidsize = 0x40000 * this.head.solidsize
   in.expand( blocksize + solidsize )
   out.expand( blocksize + blocksize / 10 )
   
   uint       store failpack leadorder
   lzge       lz
   ppmd       ppm
   
   gc.order = max( 1, min( 10, gc.order ))
   
   gp.done = 0
   gp.name = fullname
   gp.info = &gf
   gp.mode = 0
   switch gc.compmethod
   {
      case $GEA_STORE
      { 
         geadata  gd
   
         gd.order |= 0x80
         gd.size = gf.size
         if gf.size
         { 
            if !this.put( &gd, sizeof( geadata )) : return 0 
         }
         store = 1
      }
      case $GEA_LZGE
      {
         lz.order = gc.order 
         lz.userfunc = this.userfunc
         lz.pgeaparam = &gp 
      }
      case $GEA_PPMD
      {
//         ppm.memory = this.head.memory
         ppm.order = gc.order + 1
         ppm.userfunc = this.userfunc
         ppm.pgeaparam = &gp 
         leadorder = ppm.order
      }
   }
   if gc.solid
   {
      // Сбрасываем если упаковали уже много с solid сжатием 
      if this.prevsolid + gf.size > solidsize || this.countsolid >= 60
      { 
         this.prevsolid = 0
         this.countsolid = 0     
      }
      else : this.countsolid++ 
      // Проверяем на совпадение предыдущих настроек
      if this.prevsolid && this.prevmethod == gc.compmethod && 
         this.prevorder == gc.order && gf.idpass == this.prevpass 
      {
         gf.flags |= $GEAF_SOLID
         this.prevsolid += gf.size     
      }
      else : this.prevsolid = gf.size  
      this.prevpass = gf.idpass
   } 
   else : this.prevsolid = 0; this.countsolid = 0
//   print("Prev=\(this.prevsolid) block=\( blocksize ) size=\( gf.size )\n")
   if !( gf.flags & $GEAF_SOLID ) : this.bsolid.clear()
                    
   while cursize < gf.size
   {
      geadata  gd
      uint issolid  pout psize pin
      uint iread = min( gf.size - cursize, blocksize )
    
      in.use = solidsize
      out.use = 0
      if read( handle, in, iread ) != iread
      {
         this.mess( $GEAERR_FILEREAD, %{ fullname })
         return 0         
      }
      pin = in.ptr() + solidsize
      gf.crc = crc( pin, iread, gf.crc )
      if gc.compmethod == $GEA_LZGE
      {
         lz.solidoff = 0//*this.bsolid
         
         if ( cursize || gf.flags & $GEAF_SOLID ) && !failpack         
         { 
            lz.solidoff = *this.bsolid
            issolid = 1
            pin -= lz.solidoff
            mcopy( pin, this.bsolid.ptr(), lz.solidoff ) 
         }
         out.use = lzge_encode( pin, iread + lz.solidoff, out.ptr(), lz )
//         out.write("c:\\aa\\encode\(lz.solidoff).bin")
         i = min( solidsize, iread + lz.solidoff )
         this.bsolid.copy( pin + iread + lz.solidoff - i, i )  
//         print("\ni= \( i ) iread=\( iread ) ss = \(solidsize) bs=\( *this.bsolid )\n")
      }
      elif gc.compmethod == $GEA_PPMD
      {
         if ( cursize || gf.flags & $GEAF_SOLID ) && !failpack
         { 
            ppm.order = 1
            issolid = 1
         }
         out.use = ppmd_encode( pin, iread, out.ptr(), out.size, ppm )
         ppm.order = leadorder
      }
      if gc.compmethod && out.use > ( in.use - solidsize ) * 98 / 100
      {
//         print("\n\(in.use) <= \(out.use)\n")
         if !cursize
         { 
            gd.order |= 0x80
            gf.flags &= ~$GEAF_SOLID
         }
         gd.size = iread 
         if !this.put( &gd, sizeof( geadata )) : return 0
         failpack = 1
         issolid = 0
         this.bsolid.clear()
         if gc.compmethod == $GEA_LZGE : pin += lz.solidoff 
      }
      else : failpack = 0
      if store || failpack
      {
         pout = pin
         psize = iread
         this.prevmethod = $GEA_STORE
         this.prevsolid = 0
         if store
         {
            this.mess( $GEAMESS_PROCESS, %{ fullname, gf, iread + gp.done })
         }
      }
      else
      {
         this.prevmethod = gc.compmethod
         this.prevorder = gc.order
         
         gd.order = ( gc.compmethod << 4 ) + ?( issolid, 0, gc.order )
//         print("Order = \(gd.order)\n")
         if !cursize : gd.order |= 0x80
         
         gd.size = *out
         if !this.put( &gd, sizeof( geadata )) : return 0
         pout = out.ptr()
         psize = *out
      } 
      if gf.idpass  // Шифруем 
      {
         gea_protect( pout, psize, this.passbufs[ gf.idpass - 1 ] )
      }
      if !this.put( pout, psize ) : return 0
      cursize += blocksize
      gp.done += iread
   }   
   close( handle )
   this.mess( $GEAMESS_ENEND, %{ fullname, gf })
   return 1
}

method  uint geae.adddir( str filename, geacomp gc )
{
   str  fullname fpath fname
   uint curid i gf 
      
/*   geaparam   gp
   uint cursize blocksize solidsize
   uint handle curid gf i
   buf  in out
*/   
   fullname.ffullname( filename )
   fname.fnameext( fullname )
   fpath.fgetdir( fullname )
   
   // Проверка на то, что уже добавлен
   if i = this.addedfiles.find( fullname )
   {
      this.mess( $GEAMESS_COPY, %{ fullname })
      if this.flags & $GEAI_IGNORECOPY : return 1
   } 
   else
   {  // Добавление в добавленные
      this.addedfiles[ fullname ] = 1 
   }

   curid = this.fileinfo.expand( 1 ) 
   gf as this.fileinfo[ curid ]
   gf.name = fname
   gf.crc = 0xFFFFFFFF
   gf.idgroup = gc.idgroup
   gf.subfolder = gc.subfolder
   // Получаем время, размер, атрибуты, версию 
   gf.attrib = getfileattrib( fullname ) 
   this.mess( $GEAMESS_ENBEGIN, %{ fullname, gf })
   
   this.prevmethod = $GEA_STORE
   this.prevsolid = 0
         
//   print("Prev=\(this.prevsolid) block=\( blocksize ) size=\( gf.size )\n")
   this.bsolid.clear()
                    
   this.mess( $GEAMESS_ENEND, %{ fullname, gf })
   return 1
}
