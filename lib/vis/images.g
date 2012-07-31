include 
{
   "grey.g"
   "..\\olecom\\olecom.g"
}
type ICONDIRENTRY
{
   byte   bWidth
   byte   bHeight
   byte   bColorCount
   byte   bReserved
   ushort wPlanes
   ushort wBitCount
   uint   dwBytesInRes
   uint   dwImageOffset
}

type RESICONDIRENTRY
{
   byte   bWidth
   byte   bHeight
   byte   bColorCount
   byte   bReserved
   ushort wPlanes
   ushort wBitCount
   uint   dwBytesInRes
   ushort nID
}

type ICONDIR
{
   ushort idReserved//0 всегда 
   ushort idType   //1 для иконки, 2 для курсора
   ushort idCount  
   ICONDIRENTRY idEntries
}

type icsize
{
   uint Width
   uint Height
}

type Image
{
   uint hImage   
   uint hDisImage
   uint Width
   uint Height
   int  NumIml  
   int  PosInIml
   int  DisPosInIml
}

type ImageListIml
{
   uint hIml
   uint Width
   uint Height  
   uint pImageList 
}

type ImageList <inherit=hash> //index=Image
{
   arr arrIml of ImageListIml  
}

type ImageManager <inherit=hash index=ImageList>
{
   str  pMainDir
   str  pCurName      
   hash FileIcons of uint 
   uint FileIconsIdx   
}


define {
//   MAX_PATH = 260
   
   SHGFI_ICON              = 0x00000100
   SHGFI_SYSICONINDEX      = 0x00004000
   SHGFI_LARGEICON         = 0x00000000
   SHGFI_SMALLICON         = 0x00000001
   SHGFI_USEFILEATTRIBUTES = 0x00000010
}

type SHFILEINFO { 
    uint     hIcon
    int      iIcon 
    uint     dwAttributes
    reserved szDisplayName[ $MAX_PATH ]
    reserved szTypeName[ 80 ]
}

import "shell32.dll" {
   uint  SHGetFileInfoA( uint, uint, SHFILEINFO, uint, uint ) -> SHGetFileInfo
}

//-------------------------------------------------

func uint shell_iconfile( str filename, uint large )
{
   uint       reticon flag
   SHFILEINFO shfi
   str        ext
      
   flag = ?( large, $SHGFI_LARGEICON, $SHGFI_SMALLICON )
   if SHGetFileInfo( filename.ptr(), 0 , shfi, sizeof( SHFILEINFO ),
                     /*$SHGFI_SYSICONINDEX |*/ $SHGFI_ICON | flag )
   {
      return shfi.hIcon
   } 
   reticon = SHGetFileInfo( filename.ptr(), $FILE_ATTRIBUTE_NORMAL, shfi, sizeof( SHFILEINFO ), $SHGFI_SYSICONINDEX | $SHGFI_USEFILEATTRIBUTES | $SHGFI_ICON | flag )
   return shfi.hIcon
}

extern {
   method str ImageManager.GetFileIcon<result>( str filename )
}

method ImageManager.init()
{
   this->hash.oftype( ImageList )
}


method ImageList ImageList.init
{   
   return this
}

method Image.ReadFromFile( str filename )
{
   /*uint hbmp 
   hbmp = LoadImage( 0, filename.ptr(), $IMAGE_BITMAP, 0, 0, $LR_LOADFROMFILE | $LR_LOADTRANSPARENT )
   if hbmp 
   {
      .hbmp = hbmp
   }  */
}

method Image.Clear()
{
 //  if .hbmp : DeleteObject( .hbmp )
}

method Image.delete()
{
   DestroyIcon( .hImage )
   DestroyIcon( .hDisImage )   
}



method ImageListIml.delete()
{  
   ImageList_Destroy( .hIml )
}

method ImageList.delete()
{
   //print( "ImageList \(&this) .Delete 1\n" )
   foreach arrim, this
   {      
     //arrim as arr of Image
     //print( "ImgList destroy \(arrim->uint)\n" )
     if arrim->uint : destroy( arrim->uint )     
     //getch() 
   }
   //print( "ImageList.Delete 2\n" )
}

method ImageManager.delete
{
   //print( "ImageManager.Delete \(&this)\n" )
  // destroy( ImageList
}

/*method ImageManager.LoadDir( str dir, str listname, uint flgclear )
{
   uint il as this[listname]//->ImageList
   
      ffind fdi
      fdi.init( "\( dir )\\*.ico", $FIND_FILE )      
      foreach finfo ico, fdi
      {         
         uint arrim as ( il[ico.name]->arr of Image )
         if !&arrim 
         {
            str name
            ico.fullname.fgetparts( 0->str, name, 0->str )
            arrim as new( arr, Image, 0 )->arr of Image
            //print( "NEW ARRIM \(&il) \( &arrim ) )\n" )
            //arrim.itype = Image
            //arrim.isize = sizeof( Image )
            arr arrim2 of Image
            il[name] = &arrim
         }
         elif flgclear
         {            
            arrim.clear()
         }         
         buf bicon
         bicon.read( ico.fullname )
         uint header as bicon.data->ICONDIR
         if !header.idReserved && header.idType == 1 
         {
            uint count = header.idCount
            uint entry as header.idEntries
            uint i, j
            arr sizes of icsize                                    
            fornum i=0, count 
            {  //                
               fornum j=0, *sizes
               {
                  if sizes[j].Width > entry.bWidth &&
                     sizes[j].Height > entry.bHeight : break                     
               }
               sizes.insert( j )
               sizes[j].Width = entry.bWidth
               sizes[j].Height = entry.bHeight
               entry as uint
               entry += sizeof(ICONDIRENTRY)    
            }            
            
            if !*il.arrIml
            {
               il.arrIml.expand(*sizes)               
               fornum i=0, *sizes
               {
                  il.arrIml[i].hIml = ImageList_Create (
                     sizes[i].Width, sizes[i].Height, 0x000000FF, 10, 10 )
                  il.arrIml[i].Width = sizes[i].Width
                  il.arrIml[i].Height = sizes[i].Height
                  il.arrIml[i].pImageList = &il   
               }
            }
            if *sizes > *arrim
            {  
               arrim.expand( *sizes - *arrim )
            }            
            fornum i=0, *sizes
            {
               if arrim[i].hImage : DestroyIcon( arrim[i].hImage )
               
               arrim[i].Width = sizes[i].Width
               arrim[i].Height = sizes[i].Height                           
               arrim[i].hImage = LoadImage( 0, ico.fullname.ustr().ptr(), $IMAGE_ICON, 
                  sizes[i].Width, sizes[i].Height, $LR_LOADFROMFILE | $LR_DEFAULTCOLOR )
               
               ICONINFO II
               GetIconInfo( arrim[i].hImage, II )                  
               BitmapColorsToGrey( II.hbmColor, II.hbmMask, arrim[i].Width,arrim[i].Height)                  
               arrim[i].hDisImage = CreateIconIndirect( II )                    
               
//               print( "load image \(arrim.itype) \(arrim.isize) \(arrim[i].hImage) \( ico.fullname ) \(  arrim[i].Width ), \( arrim[i].Height)\n" )
               arrim[i].PosInIml = -1                  
               fornum j=0, *il.arrIml
               {
                  if il.arrIml[j].Width == sizes[i].Width &&
                     il.arrIml[j].Height == sizes[i].Height 
                  {                     
                     arrim[i].PosInIml = 
                        ImageList_ReplaceIcon( il.arrIml[j].hIml, -1, arrim[i].hImage )
                     arrim[i].DisPosInIml = 
                        ImageList_ReplaceIcon( il.arrIml[j].hIml, -1, arrim[i].hDisImage )                        
                     arrim[i].NumIml = j                      
                  }                       
               }                                                                                       
            }
         }
      }
}*/
method ImageList.SetIco( Image img, uint himage width height )
{
   if img.hImage 
   {      
      DestroyIcon( img.hImage )
      DestroyIcon( img.hDisImage )
   }
   img.Width = width
   img.Height = height                           
   img.hImage = himage
   ICONINFO II
   GetIconInfo( img.hImage, II )   
   //print( "gi \(img.hImage) \(II.hbmColor), \(II.hbmMask)\n")
   //if img.Width <= 100 || img.Height <= 100     
   BitmapColorsToGrey( II.hbmColor, II.hbmMask, img.Width,img.Height)   
   img.hDisImage = CreateIconIndirect( II )
   //print( "li \(img.hImage) \(img.hDisImage)\n" )
   //if !img.hDisImage : print( "Xerror \(GetLastError())\n" )                    
   //               print( "load image \(arrim.itype) \(arrim.isize) \(img.hImage) \( ico.fullname ) \(  img.Width ), \( img.Height)\n" )
   
   DeleteObject( II.hbmColor )
   DeleteObject( II.hbmMask )
   img.PosInIml = -1   
   uint j               
   fornum j=0, *this.arrIml
   {
      if this.arrIml[j].Width == width &&
         this.arrIml[j].Height == height 
      {                     
         img.PosInIml = 
            ImageList_ReplaceIcon( this.arrIml[j].hIml, -1, img.hImage )
         img.DisPosInIml = 
            ImageList_ReplaceIcon( this.arrIml[j].hIml, -1, img.hDisImage )                        
         img.NumIml = j
                 
      }                       
   }
}

method ImageList.LoadIco( str path, uint flgres, uint hmod, uint flgclear, str setname )
{
   str name
   if flgres : name = path
   else 
   {
      if &setname : name = setname
      else :  path.fgetparts( 0->str, name, 0->str )
   }
   uint arrim as ( this[name]->arr of Image )
   if !&arrim 
   {  
      arrim as new( arr, Image, 0 )->arr of Image
      arr arrim2 of Image
      this[name] = &arrim
   }
   elif flgclear
   {            
      arrim.clear()
   }         
   buf bicon
   if flgres 
   {
      uint handle = FindResource( hmod, path.ustr().ptr(), 14 )      
      uint mem = LockResource( LoadResource( hmod, handle ))      
      bicon.copy( mem, SizeofResource( hmod, handle ))
   }
   else : bicon.read( path )
   if !*bicon: return 
   uint header as bicon.data->ICONDIR
   //print( "zzzzzzzz \(header.idReserved) \( header.idType ) \(header.idCount) \((&header.idCount+2)->uint)\n" )
   if !header.idReserved && header.idType == 1 
   {      
      uint count = header.idCount
      uint entry as header.idEntries
      uint i, j
      arr sizes of icsize                                    
      fornum i=0, count 
      {  //                
         fornum j=0, *sizes
         {
            if sizes[j].Width > entry.bWidth &&
               sizes[j].Height > entry.bHeight : break                     
         }
         sizes.insert( j )
         sizes[j].Width = entry.bWidth
         sizes[j].Height = entry.bHeight         
         entry as uint          
         if flgres : entry += sizeof(RESICONDIRENTRY)
         else : entry += sizeof(ICONDIRENTRY)  
      }            
      if !*this.arrIml
      {
         this.arrIml.expand(*sizes)               
         fornum i=0, *sizes
         {
            this.arrIml[i].hIml = ImageList_Create (
               sizes[i].Width, sizes[i].Height, 0x000000FF, 10, 10 )
            this.arrIml[i].Width = sizes[i].Width
            this.arrIml[i].Height = sizes[i].Height
            this.arrIml[i].pImageList = &this  
         }
      }
      if *sizes > *arrim
      {  
         arrim.expand( *sizes - *arrim )
      }
      fornum i=0, *sizes
      {
         .SetIco( arrim[i], LoadImage( ?( hmod, hmod, GetModuleHandle( 0 )), path.ustr().ptr(), $IMAGE_ICON, 
            sizes[i].Width, sizes[i].Height, ?( flgres, 0, $LR_LOADFROMFILE ) | $LR_DEFAULTCOLOR ), sizes[i].Width, sizes[i].Height )
      }
   }     
}

method ImageManager.LoadDir( str dir, str listname, uint flgclear )
{
   uint il as this[listname]//->ImageList
   
   ffind fdi
   fdi.init( "\( dir )\\*.ico", $FIND_FILE )      
   foreach finfo ico, fdi
   {         
      il.LoadIco( ico.fullname, 0, 0, flgclear, 0->str )
   }
}

import "Oleaut32.dll"
{   
   uint OleLoadPicturePath( uint, uint, uint, uint, uint, uint )
}
global {
buf IID_IPicture = '\h4 7BF80980 \h2 BF32 101A \h 8B BB 00 AA 00 30 0C AB'
}

method uint ImageList.SetBitmap( uint handle, str name, uint flgclear, uint flgaddimagelist )
{
   BITMAP bmpinfo
   GetObject(handle,sizeof(BITMAP),&bmpinfo)
   
   uint width = bmpinfo.bmWidth
   uint height = bmpinfo.bmHeight         
   uint arrim as ( this[name]->arr of Image )
   if !&arrim 
   {  
      arrim as new( arr, Image, 0 )->arr of Image            
      this[name] = &arrim
   }
   elif flgclear
   {            
      arrim.clear()
   }
   if !*this.arrIml
   {         
      this.arrIml.expand(1)
      this.arrIml[0].hIml = ImageList_Create (
            width, height, 0x000000FF, 10, 10 )
      this.arrIml[0].Width = width
      this.arrIml[0].Height = height
      this.arrIml[0].pImageList = &this
   }
   /*fornum i = 0, *arrim
   {
      if arrim[i].Width == width &&
         arrim[i].Height == height
      {
         break
      }
      if arrim[i].Width >= width &&
         arrim[i].Height > height
   }*/
   /*if *sizes > *arrim
   {  
      arrim.expand( *sizes - *arrim )
   }*/
   if !*arrim : arrim.expand(1) 
   ICONINFO II
   II.fIcon = 1
   II.hbmColor = handle
   
   buf bits
   uint w
   bits.reserve( w = (( width +15 / 16 ) * height * 2))//*( width / 8 + ?(( width % 8 ),1,0 )) * height * 2*/ )
   mzero( bits.data, w )
   /*uint i
   fornum i = 0, w
   {
      //bits[i] = 0//0xAA
      if bits[i] : print("\(i) XXX\n" )
   }*/
   II.hbmMask = CreateBitmap( width, height, 1, 1, bits.ptr() )         
   handle=CreateIconIndirect( II )
   DeleteObject( II.hbmMask )
   DeleteObject( II.hbmColor )
   //((ppv->uint + 8)->uint)->stdcall(ppv)         
   //arrim[0].hImage = handle
   .SetIco( arrim[0], handle , width, height )
   return handle
}


//global { uint ppv }
method uint ImageList.LoadPicture( str path, str name, uint flgclear, uint flgaddimagelist )
{
   uint ppv
   uint res
   buf  un
      
   if ole.flginit 
   {           
      res = OleLoadPicturePath( un.unicode( path ).ptr(), 0, 0, 0, IID_IPicture.ptr(), &ppv )
      if !(res & 0x80000000) && ppv
      {
         uint handle
         BITMAP bmpinfo         
         handle = 0
         ((ppv->uint + 12)->uint)->stdcall(ppv, &handle)
         .SetBitmap( handle, name, flgclear, flgaddimagelist )
/*         
         GetObject(handle,sizeof(BITMAP),&bmpinfo)
         
         uint width = bmpinfo.bmWidth
         uint height = bmpinfo.bmHeight         
         uint arrim as ( this[name]->arr of Image )
         if !&arrim 
         {  
            arrim as new( arr, Image, 0 )->arr of Image            
            this[name] = &arrim
         }
         elif flgclear
         {            
            arrim.clear()
         }
         if !*this.arrIml
         {         
            this.arrIml.expand(1)
            this.arrIml[0].hIml = ImageList_Create (
                  width, height, 0x000000FF, 10, 10 )
            this.arrIml[0].Width = width
            this.arrIml[0].Height = height
            this.arrIml[0].pImageList = &this
         }
         
         if !*arrim : arrim.expand(1) 
         ICONINFO II
         II.fIcon = 1
         II.hbmColor = handle
         
         buf bits
         uint w
         bits.reserve( w = (( width +15 / 16 ) * height * 2))/ )
         mzero( bits.data, w )

         II.hbmMask = CreateBitmap( width, height, 1, 1, bits.ptr() )         
         handle=CreateIconIndirect( II )
         DeleteObject( II.hbmMask )
         DeleteObject( II.hbmColor )
         //arrim[0].hImage = handle
         .SetIco( arrim[0], handle , width, height )
         */
         ((ppv->uint + 8)->uint)->stdcall(ppv)                  
         
         return handle                                                   
      }
   }
   return 0
}


method uint ImageManager.LoadImg( str filename, str listname, str imgname )
{
   uint il as this[listname]
   
   str ext
   filename.fgetparts( 0->str, 0->str, ext )
   if ext == "ico"
   {      
      il.LoadIco( filename, 0, 0, 1, imgname )
      return 1
   }
   else
   {
      return il.LoadPicture( filename, imgname, 1, 0 )
   }      
}

func uint GetDibColorTableSize( BITMAPINFOHEADER bmih )
{
	switch (bmih.bmiBitCount) 
	{
		case 2, 4, 8: return ?( bmih.bmiClrUsed, bmih.bmiClrUsed, 1 << bmih.bmiBitCount )
		//case 24: 
		case 16, 32: return ?( bmih.bmiCompression == $BI_BITFIELDS, 3, 0 )
		//default:	ATLASSERT(FALSE);   // should never come here
	}
	return 0;
}

func uint GetDibBitmap( BITMAPINFO bmi )
{
	uint hbm
	//CDC dc(NULL);
   uint dc =GetDC(0)
   uint pBits
	//void * pBits = NULL;

   uint pDibBits = &bmi + sizeof(BITMAPINFOHEADER) + GetDibColorTableSize(bmi.bmiHeader) * sizeof(RGBQUAD)
   
	if hbm = CreateDIBSection(dc, bmi, $DIB_RGB_COLORS, &pBits, 0, 0)
   { 
      if !bmi.bmiHeader.bmiSizeImage
      { 
         bmi.bmiHeader.bmiSizeImage = BytesPerScanLine( bmi.bmiHeader.bmiWidth, bmi.bmiHeader.bmiBitCount, 32 ) *
          ?( bmi.bmiHeader.bmiHeight < 0, -bmi.bmiHeader.bmiHeight,  bmi.bmiHeader.bmiHeight )
      }
      //bmi.bmiHeader.bmiSizeImage = 5000
		mcopy( pBits, pDibBits, bmi.bmiHeader.bmiSizeImage )
   }
   ReleaseDC( 0, dc )
	return hbm
}

method uint ImageManager.AddBitmap( uint handle, str listname, str imgname )
{
   uint il as this[listname]   
   return il.SetBitmap( handle, imgname, 1, 0 )
         
}


type EnumResInfo
{
   uint imagelist
   uint flgclear
}

func uint EnumResNameProc( uint hModule, uint lpszType, uint lpszName, uint lParam )
{
   uint il as lParam->EnumResInfo.imagelist->ImageList
   ustr  s   
   if lpszName > 0xFFFF 
   {
      s.copy( lpszName )
   }
   else : s = "#" + str( lpszName ) 
   il.LoadIco( s.str(), 1, hModule, lParam->EnumResInfo.flgclear, 0->str )      
   return 1
}


method ImageManager.LoadRes( str filename, str listname, uint flgclear )
{
   uint hres
   EnumResInfo eri
   eri.imagelist = &this[listname]
   eri.flgclear = flgclear 
   
   if *filename 
   {       
      hres = LoadLibraryEx( filename.ptr(), 0, 0x00000002/*$LOAD_LIBRARY_AS_DATAFILE*/ )
      if !hres : return	
   }   
   EnumResourceNames( hres, 14, callback(&EnumResNameProc,4), &eri )      
   if hres : FreeLibrary( hres )
}


method ImageManager.LoadFileIcons( str listname )
{
   uint imagelist as this[listname]
   .FileIcons.ignorecase()
   .FileIcons[ "exe" ]   = 0xFFFFFFFF
   .FileIcons[ "pif" ]   = 0xFFFFFFFF
   .FileIcons[ "lnk" ]   = 0xFFFFFFFF
   .FileIcons[ "ico" ]   = 0xFFFFFFFF
   .FileIcons[ "drive" ] = 0xFFFFFFFE
      
   if !*imagelist.arrIml
   {
      imagelist.arrIml.expand(2)
      uint size = 16     
      uint i          
      fornum i=0, 2
      {         
         imagelist.arrIml[i].hIml = ImageList_Create (
            size, size, 0x000000FF, 10, 10 )
         imagelist.arrIml[i].Width = size 
         imagelist.arrIml[i].Height = size
         imagelist.arrIml[i].pImageList = &this
         size *= 2  
      }
   }
}

method ImageManager.Load( str name, uint flgclear )
{
   ffind fd
   fd.init( "\(.pMainDir)\\\(name)\\*", $FIND_DIR )
   foreach finfo cur, fd
   {
      .LoadDir( cur.fullname, cur.name, flgclear )
      /*if !&il 
      {         
         il as new( ImageList )->ImageList    
         this[cur.name] = &il
      }
      el*/      
      /*if flgclear
      {      
         
         il.arrIml.clear()
      }  */    
      
      /*foreach arrim, il
      {         
        //arrim as arr of Image
        uint x = arrim->uint
        print( "ImgList Check \(arrim->uint) \(x)\n" )
        //destroy( &arrim )     
        getch() 
      }*/
   }   
   //.LoadRes( $"C:\Delphi7\Bin\delphi32.exe", "resources", flgclear )
   //.LoadRes( $"K:\Gentee\Open Source\gentee\exe\gentee2.exe", "resources", flgclear )
   //.LoadRes( $"K:\main.exe", "resources", flgclear )
   .LoadRes( "", "resources", flgclear )
   .LoadFileIcons( "files" )
   //.LoadRes( $"C:\Program Files\7-Zip\7zFM.exe", "resouces", flgclear )
   
}

property str ImageManager.CurName <result>
{
   result = .pCurName
}

property ImageManager.CurName( str value )
{
   if value != .pCurName
   {
      //this.Clear()
      .Load( "default", 1 )
      //.Load( value, 0 )
   }
}

property str ImageManager.MainDir <result>
{
   result = .pMainDir
}

property ImageManager.MainDir( str value )
{
   if value != .pMainDir
   {
      //this.Clear()
      .pMainDir = value
   }
}

method Image ImageManager.GetImage( ustr name )
{
   arrstr path 
   str sname = name
   if name.str().findch( '.' ) != *name
   {
      sname = ("files\\"+.GetFileIcon( name.str() ))      
   }
   sname.split( path, '\', 0 )
   //print( "GetImage \(*path) \(name.str())\n" )   
   if *path == 2
   {  
      uint il as this.find(path[0])->ImageList      
      if &il
      {  
         sname = path[1]
         sname.split( path, '[', 0 ) 
         uint im as il[path[0]]->arr of Image
         if &im
         {     
            uint idx  
            if *path == 2
            {                 
               idx = min( max( 0, int( path[1] ) ), *im )
            }  
            return im[idx]
         }
      }      
   }
   return 0->Image
}

method uint ImageManager.GetImageNum( ustr name, uint width, uint height )
{
   arrstr path 
   str sname = name
   sname.split( path, '\', 0 )   
   if *path == 2
   {
      uint il as this.find(path[0])->ImageList
      if &il
      { 
         uint im as il[path[1]]->arr of Image
         if &im
         {
            uint i
            fornum i, *im
            {            
               if im[i].Width == width && im[i].Height == height
               {
                  return i
               } 
            }         
         }
      }      
   }
   return -1
}

method int ImageList.GetImageIdx( uint numiml, ustr name, uint disabled )
{
//print( "GetImageIdx\n" )
   if &this && *name
   {        
      uint arrim as this[name.str()]->arr of Image      
      if &arrim 
      {  
         if numiml < *arrim
         { 
            uint i
            fornum i = 0, *arrim
            {
               if arrim[i].NumIml == numiml
               {           
                  if disabled : return arrim[i].DisPosInIml
                  else : return arrim[i].PosInIml
               }
            }
         }         
      }
   }
   return -1
}

method ImageList ImageManager.GetImageList( ustr name, uint pnumiml )
{
//print( "GetImageList\n" )
   arrstr path
   str sname = name   
   sname.split( path, '\', 0 )
   if *path == 1
   {      
      sname = path[0]
      sname.split( path, '[', 0 )      
      uint il as this.find(path[0])->ImageList      
      if &il
      {   
         uint num 
         if *path > 1 : num= min( uint( path[1] ), *il.arrIml - 1 )
         if pnumiml: pnumiml->uint = num
         return il
      }
   }
   return 0->ImageList
}


method str ImageManager.GetFileIcon<result>( str filename )
{
   uint  hicon 
   str   ext fname
   uint  ret i// x y
      
   filename.fgetparts( 0->str, 0->str, ext )
   
   ret = .FileIcons[ ext ]

   if ret && ret < 0xFFFFFFF0 : goto end

   if ret == 0xFFFFFFFF
   {
      if .FileIcons.find( filename ) 
      {
         ret = .FileIcons[ filename ]
         goto end
      }
   }
   elif ret == 0xFFFFFFFE
   {
      filename = filename.fsetext( filename, 0->str )
      if .FileIcons.find( filename ) 
      {
         ret = .FileIcons[ filename ]
         goto end
      }
   }
   result = .FileIconsIdx.str()
   uint imagelist as this[ "files"]
   uint arrim as ( imagelist[.FileIconsIdx.str()]->arr of Image )
   if !&arrim 
   {  
      arrim as new( arr, Image, 0 )->arr of Image
      imagelist[result] = &arrim
   }
   /*elif flgclear
   {            
      arrim.clear()
   }*/
   uint size = 16
   if 2 > *arrim
   {  
      arrim.expand( 2 - *arrim )
   }
   fornum i=0, 2
   {
      uint hicon
      imagelist.SetIco( arrim[i], hicon = shell_iconfile( filename, i ), size, size )
      //DestroyIcon( hicon )
      size *= 2      
   }
   
   if !ret : .FileIcons[ ext ] = .FileIconsIdx
   else : .FileIcons[ filename ] = .FileIconsIdx
   .FileIconsIdx++

   return 
label end    
   result = ret.str()  
}