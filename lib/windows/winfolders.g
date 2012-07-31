/*<winfolders>   
   <copyright year = 2006>
      <company = 'Gentee, Inc.'  url = 'http://www.gentee.com'  email = info@gentee.com >
      <author = 'Alexey Krivonogov'> 
      <file>
      </>
   </>
   <desc>
   </>
</>*/

import "kernel32.dll"
{
//   uint GetDiskFreeSpaceExA( uint, uint, uint, uint ) -> GetDiskFreeSpaceEx 
   uint GetSystemDirectoryA( uint, uint ) -> GetSystemDirectory
   uint GetTempPathA( uint, uint ) -> GetTempPath
   uint GetWindowsDirectoryA( uint, uint ) -> GetWindowsDirectory
}

import "shell32.dll"
{
   uint SHGetSpecialFolderLocation( uint, uint, uint ) 
   uint SHGetPathFromIDListW( uint, uint ) -> SHGetPathFromIDList
}

import "ole32.dll" {
uint CoTaskMemAlloc( uint )
     CoTaskMemFree( uint )
}

define <export> 
{  
   WINFLD_SIZE = 512  // Reserved size for folders
   // values for idfolder parameter of the function winfolder
   WINFLD_WIN = 0xFF00    // Windows directory
   WINFLD_SYS             // System directory
   WINFLD_TEMP            // Temporary directory
   WINFLD_QLAUNCH         // Quick Launch folder          
   WINFLD_SENDTO     = 0x0009  // "Sendto" folder
   WINFLD_MYMUSIC    = 0x000D  // "My Music" folder
   WINFLD_MYVIDEO    = 0x000E  // "My Videos" folder
   WINFLD_APPDATA    = 0x001a   // Application Data
   WINFLD_LOCALAPPDATA = 0x001c   // Application Data
   WINFLD_COMAPPDATA = 0x0023
   WINFLD_DESKTOP    = 0x0010   // Desktop folder
   WINFLD_COMDESKTOP = 0x0019   // Desktop folder
   WINFLD_PROGFILES  = 0x0026   // Program Files directory
   WINFLD_MYPICTURES = 0x0027   // "My Pictures" folder   
   WINFLD_COMPROGFILES = 0x002b // Common Program Files directory
   WINFLD_PROGGROUP    = 0x0002 // Start -> Programs folder
   WINFLD_COMPROGGROUP = 0x0017
   WINFLD_START        = 0x000b // Start menu folde
   WINFLD_COMSTART     = 0x0016
   WINFLD_STARTUP      = 0x0007 // StartUp folder
   WINFLD_COMSTARTUP   = 0x0018
   WINFLD_FONT         = 0x0014 // Fonts folder
   WINFLD_DOCS       = 0x0005  // My Documents folder
   WINFLD_COMDOCS    = 0x002e
   WINFLD_COMMUSIC   = 0x0035  // All Users\My Music
   WINFLD_COMPICTURES = 0x0036 // All Users\My Pictures
   WINFLD_COMVIDEO    = 0x0037 // All Users\My Video
   WINFLD_IEFAV      = 0x0006  // Internet Explorer Favorite folder
   WINFLD_COMIEFAV   = 0x001f
   WINFLD_COOKIES    = 0x0021
   WINFLD_HISTORY    = 0x0022
   WINFLD_DRIVES     =  0x0011 // My Computer
   WINFLD_NETWORK    =  0x0012 // Network Neighborhood (My Network Places)
}

func str winfolder( uint idfolder, str result )
{
   uint ptr
   uint qlaunch 
   
   result.clear()
   result.reserve( $WINFLD_SIZE )
   ptr = result.ptr()
   
   if idfolder == $WINFLD_WIN : GetWindowsDirectory( ptr, $WINFLD_SIZE )
   elif idfolder == $WINFLD_SYS : GetSystemDirectory( ptr, $WINFLD_SIZE )
   elif idfolder == $WINFLD_TEMP : GetTempPath( $WINFLD_SIZE, ptr )
   else 
   {
      uint  ids 
      
      if idfolder == $WINFLD_QLAUNCH
      {
         idfolder = $WINFLD_APPDATA
         qlaunch = 1 
      }  
      if !SHGetSpecialFolderLocation( 0, idfolder, &ids )
      {
         ustr uptr
         
         uptr.reserve( 1024 )
//         ptr = uptr.ptr()
         SHGetPathFromIDList( ids, uptr.ptr() )
         uptr.setlenptr()
         result = uptr
         CoTaskMemFree( ids )//imalloc_free( ids )      
      } 
   }
   result.setlenptr().fdelslash()
   if qlaunch : result.faddname( $"Microsoft\Internet Explorer\Quick Launch" )
   return result   
}
/*
func long getdisksize( str path, uint ptotal )
{
   long result
   
   if !GetProcAddress( GetModuleHandle( "kernel32.dll".ptr() ),
                         "GetDiskFreeSpaceExA".ptr())
   {
      return 0L
   }
   GetDiskFreeSpaceEx( path.ptr(), &result, ptotal, 0 )
   
   return result   
}
*/