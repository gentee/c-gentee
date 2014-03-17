
type WNDCLASSEX { 
   uint    cbSize 
   uint    style 
   uint    lpfnWndProc 
   int     cbClsExtra 
   int     cbWndExtra 
   uint    hInstance 
   uint    hIcon 
   uint    hCursor 
   uint    hbrBackground 
   uint    lpszMenuName 
   uint    lpszClassName 
   uint    hIconSm 
} 

type POINT {
   int  x 
   int  y
}

type MSG {    
   uint  hwnd     
   uint  msg//message 
   uint  wpar//wParam 
   uint  lpar//lParam 
//   uint  time 
//   POINT pt 
} 

type RECT { 
  int  left
  int  top
  int  right
  int  bottom
}

type WINDOWPOS {   
    uint hwnd                     
    uint hwndInsertAfter          
    int  x                        
    int  y                        
    int  cx                       
    int  cy                       
    uint flags                    
} 


type PAINTSTRUCT {
   uint        hdc
   uint        fErase
   RECT        rcPaint
   uint        fRestore
   uint        fIncUpdate
   reserved    rgbReserved[32]
}

type DRAWITEMSTRUCT {
    uint        CtlType
    uint        CtlID
    uint        itemID
    uint        itemAction
    uint        itemState
    uint        hwndItem
    uint        hDC
    RECT        rcItem
    uint        itemData
} 

type MEASUREITEMSTRUCT {
    uint CtlType
    uint CtlID
    uint itemID
    uint itemWidth
    uint itemHeight
    uint itemData
} 

type NMHDR 
{ 
   uint   hwndFrom
   uint   idFrom 
   uint   code 
}

type SCROLLINFO { 
    uint cbSize 
    uint fMask 
    int  nMin 
    int  nMax 
    uint nPage 
    int  nPos 
    int  nTrackPos 
} 

type MENUITEMINFO {
    uint    cbSize 
    uint    fMask 
    uint    fType 
    uint    fState 
    uint    wID 
    uint    hSubMenu 
    uint    hbmpChecked 
    uint    hbmpUnchecked 
    uint    dwItemData 
    uint    dwTypeData 
    uint    cch 
    uint    hbmpItem
}

type TCITEM {
   uint mask
   uint dwState
   uint dwStateMask
   uint pszText
   int  cchTextMax
   int  iImage
   uint lParam
} 

type ACCEL {
   byte   fVirt 
   ushort key 
   ushort cmd
}
//ACCEL.fVirt
define {
FVIRTKEY  = 0x01
FNOINVERT = 0x02
FSHIFT    = 0x04
FCONTROL  = 0x08
FALT      = 0x10
}

type STYLESTRUCT {  
    uint styleOld 
    uint styleNew 
}

type TEXTMETRIC
{
    uint        tmHeight
    uint        tmAscent
    uint        tmDescent
    uint        tmInternalLeading
    uint        tmExternalLeading
    uint        tmAveCharWidth
    uint        tmMaxCharWidth
    uint        tmWeight
    uint        tmOverhang
    uint        tmDigitizedAspectX
    uint        tmDigitizedAspectY
    ushort      tmFirstChar
    ushort      tmLastChar
    ushort      tmDefaultChar
    ushort      tmBreakChar
    ubyte       tmItalic
    ubyte       tmUnderlined
    ubyte       tmStruckOut
    ubyte       tmPitchAndFamily
    ubyte       tmCharSet
}


type LOGFONT {  
   int lfHeight 
   int lfWidth 
   int lfEscapement 
   int lfOrientation 
   int lfWeight 
   byte lfItalic 
   byte lfUnderline 
   byte lfStrikeOut 
   byte lfCharSet 
   byte lfOutPrecision 
   byte lfClipPrecision 
   byte lfQuality 
   byte lfPitchAndFamily 
   reserved lfFaceName[64] 
}

type LOGBRUSH {
   uint lbStyle 
   uint lbColor 
   uint lbHatch
}

type SIZE {  
    int cx 
    int cy 
}  

type WINDOWPLACEMENT {     
    uint  length
    uint  flags
    uint  showCmd
    POINT ptMinPosition
    POINT ptMaxPosition
    RECT  rcNormalPosition
} 

type ICONINFO {  
   uint   fIcon 
   uint   xHotspot 
   uint   yHotspot 
   uint   hbmMask 
   uint   hbmColor 
}

type BITMAP
{
    uint        bmType
    uint        bmWidth
    uint        bmHeight
    uint        bmWidthBytes
    ushort      bmPlanes
    ushort      bmBitsPixel
    uint        bmBits
}


type TRACKMOUSEEVENT {
    uint cbSize
    uint dwFlags
    uint hwndTrack
    uint dwHoverTime
} 

define {
SRCCOPY             =0x00CC0020
SRCPAINT            =0x00EE0086
SRCAND              =0x008800C6
SRCINVERT           =0x00660046
SRCERASE            =0x00440328
NOTSRCCOPY          =0x00330008
NOTSRCERASE         =0x001100A6
MERGECOPY           =0x00C000CA
MERGEPAINT          =0x00BB0226
PATCOPY             =0x00F00021
PATPAINT            =0x00FB0A09
PATINVERT           =0x005A0049
DSTINVERT           =0x00550009
BLACKNESS           =0x00000042
WHITENESS           =0x00FF0062



}

import "gdi32"
{
   uint CreateBitmap( int, int, uint, uint, uint )
   uint CreateBitmapIndirect( BITMAP )
   uint CreateBrushIndirect( LOGBRUSH )
   uint CreateCompatibleBitmap( uint, uint, uint )
   uint CreateCompatibleDC( uint )
   uint CreateFontIndirectW( LOGFONT ) -> CreateFontIndirect
   uint CreatePatternBrush( uint )
   uint CreatePen( uint, uint, uint )
   uint CreateSolidBrush( uint )
   uint DeleteDC( uint )
   uint DeleteObject( uint )
   uint ExtTextOutW( uint, int, int, uint, RECT, uint, uint, uint ) -> ExtTextOut
   uint FillRgn( uint, uint, uint )
   //uint GetBitmapDimensionEx( uint, SIZE )
   int  GetClipRgn( uint, uint )   
   uint GetBrushOrgEx( uint, POINT )
   uint GetCurrentObject( uint, uint )
   int  GetDeviceCaps( uint, int )
   uint GetObjectW( uint, uint, uint ) -> GetObject
   uint GetPixel( uint, uint, uint )
   uint GetStockObject( uint )
   uint GetTextExtentPoint32W( uint, uint, uint, SIZE ) -> GetTextExtentPoint32
   uint GetTextMetricsW( uint, TEXTMETRIC ) -> GetTextMetrics
   uint LineTo( uint, int, int )
   uint MoveToEx( uint, int, int, POINT )
   uint PatBlt( uint, int, int, int, int, uint )
   uint RemoveFontResourceW( uint ) -> RemoveFontResource
   //uint ReleaseDC( uint, uint )
   uint SelectObject( uint, uint )
   uint SetBkMode( uint, uint )
   uint SetBkColor( uint, uint )
   uint SetBrushOrgEx( uint, int, int, POINT )
   uint SetTextColor( uint, uint )
   uint SetROP2( uint, uint )
   //uint SetStretchBltMode( uint, uint )
   uint StretchBlt( uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint )
   uint TextOutW( uint, uint, uint, uint, uint ) -> TextOut
   uint BitBlt( uint, uint, uint, uint, uint, uint, uint, uint, uint )
   uint CreateRectRgn( uint, uint, uint, uint )
   int CombineRgn( uint, uint, uint, uint )
   uint SetRectRgn( uint, int, int, int, int )
   int SelectClipRgn( uint, uint )   
   uint GetTextMetricsW( uint, TEXTMETRIC) -> GetTextMetrics
   int IntersectClipRect( uint, int, int, int, int )
   int ExcludeClipRect( uint, int, int, int, int )
   uint GetClipBox( uint, RECT )
}
define
{
   HWND_TOP        = 0
   HWND_BOTTOM     = 1
   HWND_TOPMOST    = -1
   HWND_NOTOPMOST  = -2

   DCX_WINDOW           = 0x00000001
   DCX_CACHE            = 0x00000002
   DCX_NORESETATTRS     = 0x00000004
   DCX_CLIPCHILDREN     = 0x00000008
   DCX_CLIPSIBLINGS     = 0x00000010
   DCX_PARENTCLIP       = 0x00000020
   
   DCX_EXCLUDERGN       = 0x00000040
   DCX_INTERSECTRGN     = 0x00000080
   
   DCX_EXCLUDEUPDATE    = 0x00000100
   DCX_INTERSECTUPDATE  = 0x00000200
   
   DCX_LOCKWINDOWUPDATE = 0x00000400
   
   DCX_VALIDATE         = 0x00200000

}

type COMBOBOXINFO {
    uint cbSize
    RECT rcItem
    RECT rcButton
    uint stateButton
    uint hwndCombo
    uint hwndItem
    uint hwndList
} 

import "user32"
{
   uint AdjustWindowRect( RECT, uint, uint )
   uint BeginPaint( uint, PAINTSTRUCT )
   uint BringWindowToTop( uint )
   uint CallWindowProcW( uint, uint, uint, uint, uint ) -> CallWindowProc
   uint CheckDlgButton( uint, uint, uint )
   uint CheckMenuItem( uint, uint, uint )
   uint CheckMenuRadioItem( uint, uint, uint, uint, uint )
   uint ClientToScreen( uint, POINT )
   uint CreateAcceleratorTableW( uint, uint ) -> CreateAcceleratorTable
   uint CreateIconIndirect( ICONINFO )      
   uint CreateMenu()
   uint CreatePopupMenu()
   uint CreateWindowExW( uint, uint, uint, uint, uint, uint, uint, 
       uint, uint, uint, uint, uint ) -> CreateWindowEx
   uint DefWindowProcW( uint, uint, uint, uint ) -> DefWindowProc   
   uint DestroyAcceleratorTable( uint )
   uint DestroyIcon( uint )
   uint DestroyMenu( uint )
   uint DestroyWindow( uint )
   uint DispatchMessageW( uint ) -> DispatchMessage
   uint DrawFocusRect( uint, RECT )
   uint DrawFrameControl( uint, RECT, uint, uint )
   uint DrawIcon( uint, int, int, uint )
   uint DrawIconEx( uint, int, int, uint, int, int, uint, uint, uint )
   uint DrawMenuBar( uint )   
   uint DrawTextW( uint, uint, int, RECT, uint ) -> DrawText
   uint EnumThreadWindows( uint, uint, uint )
   uint EnumWindows( uint, uint )
   uint EnableMenuItem( uint, uint, uint )
   uint EnableWindow( uint, uint )
   uint EndDialog( uint, uint )
   uint EndPaint( uint, PAINTSTRUCT )
   uint FillRect( uint, RECT, uint )   
   uint FindWindowExW( uint, uint, uint, uint ) -> FindWindowEx
   uint FrameRect( uint, RECT, uint )
   uint GetActiveWindow()
   uint GetCapture()
   uint GetClassInfoExW( uint, uint, WNDCLASSEX ) -> GetClassInfo
   uint GetClassNameW( uint, uint, uint ) -> GetClassName
   uint GetClientRect( uint, RECT )
   uint GetComboBoxInfo( uint, COMBOBOXINFO )
   uint GetCursorPos( POINT )
   uint GetIconInfo( uint, ICONINFO )
   uint GetDC( uint )
   uint GetDCEx( uint, uint, uint )
   uint GetDlgItem( uint, uint )
   uint GetDlgItemTextW( uint, uint, uint, uint ) -> GetDlgItemText
   uint GetFocus( )
   uint GetForegroundWindow( )
   uint GetKeyState( uint )
   uint GetMenuItemCount( uint )   
   uint GetMenuItemID( uint, uint )   
   uint GetMenuItemInfoW(  uint, uint, uint, 
                           MENUITEMINFO ) -> GetMenuItemInfo
   uint GetMenuItemRect( uint, uint, uint, RECT )
   uint GetMenuDefaultItem( uint, uint, uint )
   uint GetMenuPosFromID( uint, uint )
   uint GetMenuState(uint, uint, uint )
   uint GetMessageW( uint, uint, uint, uint ) -> GetMessage
   uint GetMessagePos()
   uint GetParent( uint )
   uint GetQueueStatus( uint )
   uint GetScrollInfo( uint, uint, SCROLLINFO )
   int GetScrollPos( uint, int ) 
   uint GetSysColor( uint )
   uint GetSysColorBrush( uint )
   uint GetSystemMetrics( uint )
   uint GetTopWindow( uint )
   uint GetWindow( uint, uint )   
   uint GetWindowDC( uint )
   uint GetWindowuintW( uint, uint ) -> GetWindowuint
   uint GetWindowLongW( uint, uint ) -> GetWindowLong
   uint GetWindowPlacement( uint, WINDOWPLACEMENT )
   uint GetWindowRect( uint, RECT )
   int  GetWindowRgn( uint, uint )
   uint GetWindowTextW( uint, uint, uint ) -> GetWindowText
   uint GetWindowTextLengthW( uint ) -> GetWindowTextLength        
   uint InsertMenuItemW( uint, uint, uint, MENUITEMINFO ) -> InsertMenuItem
   uint InvalidateRect( uint, RECT, uint )
   uint InvalidateRgn( uint, uint, uint )
   uint IsDlgButtonChecked( uint, uint )
   uint IsIconic( uint )
   uint IsWindow( uint )
   uint IsWindowEnabled( uint )
   uint IsWindowVisible( uint )
   uint IsZoomed( uint )    
   uint LoadBitmapW( uint, uint ) -> LoadBitmap
   uint LoadCursorW( uint, uint ) -> LoadCursor
   uint LoadIconW( uint, uint ) -> LoadIcon
   uint LoadImageW( uint, uint, uint, uint, uint, uint ) -> LoadImage
   int  MenuItemFromPoint( uint, uint, int, int )
   uint MessageBoxW( uint, uint, uint, uint ) -> MessageBox
   uint ModifyMenuW( uint, uint, uint, uint, uint ) -> ModifyMenu
   uint MoveWindow( uint, int, int, int, int, uint )
   uint PostMessageW( uint, uint, uint, uint ) -> PostMessage
        PostQuitMessage( uint )
   uint PtInRect( RECT, uint, uint )
   uint RegisterClassExW( uint ) -> RegisterClassEx
   uint ReleaseCapture()
   uint ReleaseDC( uint, uint )
   uint RemoveMenu( uint, uint, uint )
   uint ScreenToClient( uint, POINT )
   uint SendDlgItemMessageW( uint, uint, uint, uint, uint ) -> SendDlgItemMessage
   uint SendMessageW( uint, uint, uint, uint ) -> SendMessage
   uint SendNotifyMessageW( uint, uint, uint, uint ) -> SendNotifyMessage
   uint SetActiveWindow( uint )
   uint SetClassuintW( uint, int, uint ) -> SetClassuint
   uint SetCapture( uint )
   uint SetCursor( uint )
   uint SetDlgItemTextw( uint, uint, uint ) -> SetDlgItemText
   uint SetFocus( uint )
   uint SetForegroundWindow( uint )
   uint SetMenu( uint, uint )
   uint SetMenuItemInfoW( uint, uint, uint, MENUITEMINFO ) -> SetMenuItemInfo
   uint SetParent( uint, uint )
   int  SetScrollInfo( uint, uint, SCROLLINFO, uint )
   //int SetScrollPos( uint, int, int, uint )
   uint SetScrollRange( uint, int, int, int, uint )
   uint SetWindowuintW( uint, int, uint ) -> SetWindowuint
   uint SetWindowLongW( uint, uint, uint ) -> SetWindowLong
   uint SetWindowPlacement( uint, WINDOWPLACEMENT )
   uint SetWindowPos( uint, uint, int, int, int, int, uint )
   uint SetWindowTextW( uint, uint ) -> SetWindowText
   uint ShowScrollBar( uint, int, uint )
   uint ShowWindow( uint, uint )
   uint ShowCursor( uint )      
   uint TrackMouseEvent( TRACKMOUSEEVENT )
   uint TrackPopupMenuEx( uint, uint, int, int, uint, uint )   
   uint TranslateAcceleratorW( uint, uint, uint ) -> TranslateAccelerator
   uint TranslateMessage( uint )   
   uint UpdateWindow( uint )
	uint SetScrollPos( uint, uint, uint, uint )
	uint ScrollWindowEx( uint, uint, uint, uint, uint, uint, uint, uint )
	uint GetClientRect( uint, uint )   
   uint ChildWindowFromPointEx( uint, int, int, uint )
   uint WindowFromPoint( int, int )   
   uint GetDesktopWindow() 
   uint ClipCursor( RECT )       
   int  SetWindowRgn( uint, uint, uint )      
   uint RedrawWindow( uint, RECT, uint, uint )
   uint ReleaseCapture()
   uint DrawEdge( uint, RECT, uint, uint )
}

type INITCOMMONCONTROLSEX {
    uint dwSize
    uint dwICC
} 

import "comctl32" {
   uint ImageList_Create( uint, uint, uint, uint, uint )
   uint ImageList_Destroy( uint )
   uint ImageList_Duplicate( uint )
   uint ImageList_GetIcon( uint, int, uint )
   uint ImageList_GetIconSize( uint, uint, uint )
   int  ImageList_ReplaceIcon( uint, int, uint )

        InitCommonControls()
   uint InitCommonControlsEx( INITCOMMONCONTROLSEX )
}

/*import "shell32"
{
uint ExtractIconW( uint, uint, uint ) -> ExtractIcon
}*/

import "kernel32"
{
   Sleep( uint )
   FreeConsole()
   AllocConsole()
   uint GetCurrentThreadId()
   uint LoadLibraryExA( uint, uint, uint )->LoadLibraryEx
   uint EnumResourceNamesW( uint, uint, uint, uint )->EnumResourceNames
   uint LockResource( uint )
   uint LoadResource( uint, uint )
   uint FindResourceW( uint, uint, uint )->FindResource
   uint SizeofResource( uint, uint )   
}

define {

GWL_WNDPROC      = -4
GWL_HINSTANCE    = -6
GWL_HWNDPARENT   = -8
GWL_STYLE        = -16
GWL_EXSTYLE      = -20
GWL_USERDATA     = -21
GWL_ID           = -12

   
SW_HIDE            = 0
SW_SHOWNORMAL      = 1
SW_NORMAL          = 1
SW_SHOWMINIMIZED   = 2
SW_SHOWMAXIMIZED   = 3
SW_MAXIMIZE        = 3
SW_SHOWNOACTIVATE  = 4
SW_SHOW            = 5
SW_MINIMIZE        = 6
SW_SHOWMINNOACTIVE = 7
SW_SHOWNA          = 8
SW_RESTORE         = 9
SW_SHOWDEFAULT     = 10
SW_MAX             = 10

SIZE_RESTORED      = 0
SIZE_MINIMIZED     = 1
SIZE_MAXIMIZED     = 2
SIZE_MAXSHOW       = 3
SIZE_MAXHIDE       = 4

SWP_NOSIZE         = 0x0001
SWP_NOMOVE         = 0x0002
SWP_NOZORDER       = 0x0004
SWP_NOREDRAW       = 0x0008
SWP_NOACTIVATE     = 0x0010

SWP_FRAMECHANGED   = 0x0020
SWP_SHOWWINDOW     = 0x0040
SWP_HIDEWINDOW     = 0x0080
SWP_NOCOPYBITS     = 0x0100
SWP_NOOWNERZORDER  = 0x0200
SWP_NOSENDCHANGING = 0x0400


MK_LBUTTON =         0x0001
MK_RBUTTON =         0x0002
MK_SHIFT   =         0x0004
MK_CONTROL =         0x0008
MK_MBUTTON =         0x0010

VK_LBUTTON         = 0x01
VK_RBUTTON         = 0x02
VK_CANCEL          = 0x03
VK_MBUTTON         = 0x04
VK_BACK            = 0x08
VK_TAB             = 0x09
VK_RETURN          = 0x0D
VK_SHIFT           = 0x10
VK_CONTROL         = 0x11
VK_MENU            = 0x12
VK_ESCAPE          = 0x1B
VK_SPACE           = 0x20
VK_END             = 0x23
VK_HOME            = 0x24
VK_LEFT            = 0x25
VK_UP              = 0x26
VK_RIGHT           = 0x27
VK_DOWN            = 0x28
VK_INSERT          = 0x2D
VK_DELETE          = 0x2E

VK_LWIN            = 0x5B
VK_RWIN            = 0x5C
VK_APPS            = 0x5D

VK_F1              = 0x70
VK_F2              = 0x71
VK_F3              = 0x72
VK_F4              = 0x73
VK_F5              = 0x74
VK_F6              = 0x75
VK_F7              = 0x76
VK_F8              = 0x77
VK_F9              = 0x78
VK_F10             = 0x79
VK_F11             = 0x7A
VK_F12             = 0x7B


WS_EX_DLGMODALFRAME  = 0x00000001
WS_EX_NOPARENTNOTIFY = 0x00000004
WS_EX_TOPMOST        = 0x00000008
WS_EX_ACCEPTFILES    = 0x00000010
WS_EX_TRANSPARENT    = 0x00000020
WS_EX_MDICHILD       = 0x00000040
WS_EX_TOOLWINDOW     = 0x00000080
WS_EX_WINDOWEDGE     = 0x00000100
WS_EX_CLIENTEDGE     = 0x00000200
WS_EX_CONTEXTHELP    = 0x00000400
WS_EX_RIGHT          = 0x00001000
WS_EX_RTLREADING     = 0x00002000
WS_EX_LEFTSCROLLBAR  = 0x00004000
WS_EX_CONTROLPARENT  = 0x00010000
WS_EX_STATICEDGE     = 0x00020000
WS_EX_APPWINDOW      = 0x00040000

WS_OVERLAPPED  =     0x00000000
WS_POPUP       =     0x80000000
WS_CHILD       =     0x40000000
WS_MINIMIZE    =     0x20000000
WS_VISIBLE     =     0x10000000
WS_DISABLED    =     0x08000000
WS_CLIPSIBLINGS  =   0x04000000
WS_CLIPCHILDREN  =   0x02000000
WS_MAXIMIZE    =     0x01000000
WS_BORDER      =     0x00800000
WS_DLGFRAME    =     0x00400000
WS_CAPTION     =     $WS_BORDER | $WS_DLGFRAME  
WS_VSCROLL     =     0x00200000
WS_HSCROLL     =     0x00100000
WS_SYSMENU     =     0x00080000
WS_THICKFRAME  =     0x00040000
WS_GROUP       =     0x00020000
WS_TABSTOP     =     0x00010000

WS_MINIMIZEBOX  =    0x00020000
WS_MAXIMIZEBOX  =    0x00010000

WS_OVERLAPPEDWINDOW  = $WS_OVERLAPPED | $WS_CAPTION | $WS_SYSMENU | $WS_THICKFRAME | $WS_MINIMIZEBOX | $WS_MAXIMIZEBOX
WS_POPUPWINDOW = $WS_POPUP | $WS_BORDER | $WS_SYSMENU

DS_MODALFRAME   = 0x80 

CCS_TOP                 = 0x00000001
CCS_NOMOVEY             = 0x00000002
CCS_BOTTOM              = 0x00000003
CCS_NORESIZE            = 0x00000004
CCS_NOPARENTALIGN       = 0x00000008
CCS_ADJUSTABLE          = 0x00000020
CCS_NODIVIDER           = 0x00000040
CCS_VERT                = 0x00000080


MB_OK                       = 0x00000000
MB_OKCANCEL                 = 0x00000001
MB_ABORTRETRYIGNORE         = 0x00000002
MB_YESNOCANCEL              = 0x00000003
MB_YESNO                    = 0x00000004
MB_RETRYCANCEL              = 0x00000005
MB_CANCELTRYCONTINUE        = 0x00000006
MB_ICONHAND                 = 0x00000010
MB_ICONERROR                = $MB_ICONHAND
MB_ICONQUESTION             = 0x00000020
MB_ICONEXCLAMATION          = 0x00000030
MB_ICONASTERISK             = 0x00000040
MB_USERICON                 = 0x00000080
MB_DEFBUTTON1               = 0x00000000
MB_DEFBUTTON2               = 0x00000100
MB_DEFBUTTON3               = 0x00000200
MB_DEFBUTTON4               = 0x00000300
MB_APPLMODAL                = 0x00000000
MB_SYSTEMMODAL              = 0x00001000
MB_TASKMODAL                = 0x00002000
MB_HELP                     = 0x00004000
MB_NOFOCUS                  = 0x00008000
MB_SETFOREGROUND            = 0x00010000
MB_DEFAULT_DESKTOP_ONLY     = 0x00020000
MB_TOPMOST                  = 0x00040000
MB_RIGHT                    = 0x00080000
MB_RTLREADING               = 0x00100000

IDOK         = 1
IDCANCEL     = 2
IDABORT      = 3
IDRETRY      = 4
IDIGNORE     = 5
IDYES        = 6
IDNO         = 7
IDCLOSE      = 8
IDHELP       = 9
IDTRYAGAIN   = 10
IDCONTINUE   = 11

WA_INACTIVE    = 0
WA_ACTIVE      = 1
WA_CLICKACTIVE = 2

SM_CXMENUCHECK = 71

ETO_OPAQUE  = 0x0002
ETO_CLIPPED = 0x0004

}

define <export> {
   WM_CREATE          = 0x0001
   WM_DESTROY         = 0x0002
   WM_MOVE            = 0x0003
   WM_SIZE            = 0x0005
   WM_ACTIVATE        = 0x0006
   WM_SETFOCUS        = 0x0007
   WM_KILLFOCUS       = 0x0008
   WM_ENABLE          = 0x000A
   WM_SETREDRAW       = 0x000B
   WM_SETTEXT         = 0x000C
   WM_GETTEXT         = 0x000D
   WM_GETTEXTLENGTH   = 0x000E
   WM_PAINT           = 0x000F
   WM_CLOSE           = 0x0010
   WM_QUERYENDSESSION = 0x0011
   WM_QUIT            = 0x0012
   WM_ERASEBKGND      = 0x0014
   WM_SYSCOLORCHANGE  = 0x0015

   WM_SHOWWINDOW      = 0x0018
   WM_SETTINGCHANGE   = 0x001A
   WM_ACTIVATEAPP     = 0x001C
   WM_FONTCHANGE      = 0x001D

   WM_SETCURSOR       = 0x0020
   WM_GETMINMAXINFO   = 0x0024
   WM_DRAWITEM        = 0x002B
   WM_MEASUREITEM     = 0x002C
   WM_VKEYTOITEM      = 0x002E
   WM_CHARTOITEM      = 0x002F
   WM_SETFONT         = 0x0030
   WM_GETFONT         = 0x0031

   WM_WINDOWPOSCHANGING = 0x0046
   WM_WINDOWPOSCHANGED  = 0x0047

   WM_NOTIFY          = 0x004E
   WM_GETICON         = 0x007F
   WM_CONTEXTMENU     = 0x007B
   WM_SETICON         = 0x0080
   WM_NCCREATE        = 0x0081
   WM_NCDESTROY       = 0x0082
   WM_NCCALCSIZE      = 0x0083
   WM_NCHITTEST       = 0x0084
   WM_NCPAINT         = 0x0085
   WM_NCACTIVATE      = 0x0086
   WM_GETDLGCODE      = 0x0087
   WM_SYNCPAINT       = 0x0088
   WM_NCMOUSEMOVE     = 0x00A0
   WM_NCLBUTTONDOWN   = 0x00A1
   WM_NCLBUTTONUP     = 0x00A2
   WM_NCLBUTTONDBLCLK = 0x00A3
   WM_NCRBUTTONDOWN   = 0x00A4
   WM_NCRBUTTONUP     = 0x00A5
   WM_NCRBUTTONDBLCLK = 0x00A6
   WM_NCMBUTTONDOWN   = 0x00A7
   WM_NCMBUTTONUP     = 0x00A8
   WM_NCMBUTTONDBLCLK = 0x00A9

   WM_GETDLGCODE      = 0x0087

   WM_KEYDOWN         = 0x0100
   WM_KEYUP           = 0x0101
   WM_CHAR            = 0x0102
   WM_SYSKEYDOWN      = 0x0104
   WM_SYSKEYUP        = 0x0105
   WM_SYSCHAR         = 0x0106
   WM_COMMAND         = 0x0111
   WM_HSCROLL         = 0x0114
   WM_VSCROLL         = 0x0115
   WM_INITMENU        = 0x0116
   WM_INITMENUPOPUP   = 0x0117
   WM_MENUSELECT      = 0x011F
   WM_ENTERIDLE       = 0x0121
   
   WM_CTLCOLORMSGBOX    = 0x0132
   WM_CTLCOLOREDIT      = 0x0133
   WM_CTLCOLORLISTBOX   = 0x0134
   WM_CTLCOLORBTN       = 0x0135
   WM_CTLCOLORDLG       = 0x0136
   WM_CTLCOLORSCROLLBAR = 0x0137
   WM_CTLCOLORSTATIC    = 0x0138   
   
   WM_MOUSEACTIVATE   = 0x021
   WM_MOUSEMOVE       = 0x0200
   WM_LBUTTONDOWN     = 0x0201
   WM_LBUTTONUP       = 0x0202
   WM_LBUTTONDBLCLK   = 0x0203
   WM_RBUTTONDOWN     = 0x0204
   WM_RBUTTONUP       = 0x0205   
   WM_RBUTTONDBLCLK   = 0x0206
   WM_MBUTTONDOWN     = 0x0207
   WM_MBUTTONUP       = 0x0208
   WM_MBUTTONDBLCLK   = 0x0209
   WM_MOUSEWHEEL      = 0x020A
   WM_MOUSELEAVE      = 0x02A3
   
   WM_SIZING          = 0x0214
   WM_CAPTURECHANGED  = 0x0215
   WM_MOVING          = 0x0216
   
   WM_USER            = 0x0400
}


define {
DEFAULT_GUI_FONT = 17
}

define {
   CS_VREDRAW         = 0x0001
   CS_HREDRAW         = 0x0002
   CS_DBLCLKS         = 0x0008
   WS_OVERLAPPEDWINDOW  = 0x00CF0000
   
   CWP_SKIPTRANSPARENT =0x0004
   CWP_SKIPINVISIBLE = 0x0001
   //WM_DESTROY         = 0x0002
}

define {
BLACK_BRUSH       =  4

   OEM_FIXED_FONT    =  10
   ANSI_FIXED_FONT   =  11

   DEFAULT_GUI_FONT  =  17
   DEFAULT_CHARSET = 1

   FW_BOLD         = 700

   LF_FACESIZE   = 32
   LOGPIXELSY    = 90
   
   DEFAULT_PITCH         = 0
   FIXED_PITCH           = 1
   VARIABLE_PITCH        = 2
   MONO_FONT             = 8
   FF_SCRIPT             =0x40
   
   PATINVERT = 0x005A0049 
   
   TRANSPARENT   = 1
   OPAQUE        = 2
   
   PROOF_QUALITY         = 2

   PS_SOLID      = 0
   PS_DASH       = 1       /* -------  */
   PS_DOT        = 2       /* .......  */
   PS_INSIDEFRAME	 = 6
   R2_NOT  =    6
   RGN_OR=2
   RGN_DIFF=4


}

operator RECT =( RECT left right )
{
   left.left = right.left
   left.top = right.top
   left.right = right.right
   left.bottom = right.bottom
   return left
}
operator POINT =( POINT left right )
{
   left.x = right.x 
   left.y = right.y
   return left
}

define {
IMAGE_BITMAP       = 0
IMAGE_ICON         = 1
IMAGE_CURSOR       = 2


BM_GETCHECK        = 0x00F0
BM_SETCHECK        = 0x00F1
BM_GETSTATE        = 0x00F2
BM_SETSTATE        = 0x00F3
BM_SETSTYLE        = 0x00F4
BM_CLICK           = 0x00F5
BM_GETIMAGE        = 0x00F6
BM_SETIMAGE        = 0x00F7


BN_CLICKED   = 0


BS_TEXT            = 0x00000000
BS_DEFPUSHBUTTON   = 0x00000001
BS_CHECKBOX        = 0x00000002
BS_AUTOCHECKBOX    = 0x00000003
BS_RADIOBUTTON     = 0x00000004
BS_3STATE          = 0x00000005
BS_AUTO3STATE      = 0x00000006
BS_GROUPBOX        = 0x00000007
BS_USERBUTTON      = 0x00000008
BS_AUTORADIOBUTTON = 0x00000009
BS_OWNERDRAW       = 0x0000000B
BS_ICON            = 0x00000040
BS_BITMAP          = 0x00000080
BS_LEFT            = 0x00000100
BS_RIGHT           = 0x00000200
BS_CENTER          = 0x00000300
BS_TOP             = 0x00000400
BS_BOTTOM          = 0x00000800
BS_VCENTER         = 0x00000C00
BS_PUSHLIKE        = 0x00001000
BS_MULTILINE       = 0x00002000
BS_NOTIFY          = 0x00004000
BS_FLAT            = 0x00008000
BS_PUSHLIKE        = 0x00001000



BST_UNCHECKED      = 0x0000
BST_CHECKED        = 0x0001
BST_INDETERMINATE  = 0x0002
BST_PUSHED         = 0x0004
BST_FOCUS          = 0x0008
}

define {

ES_MULTILINE   = 0x0004
ES_PASSWORD    = 0x0020
ES_AUTOVSCROLL = 0x0040
ES_AUTOHSCROLL = 0x0080
ES_READONLY    = 0x0800
ES_WANTRETURN  = 0x1000

EN_CHANGE      = 0x0300
EN_UPDATE      = 0x0400

EM_GETLIMITTEXT     = 0x00D5
EM_LIMITTEXT        = 0x00C5
EM_SETSEL           = 0x00B1
EM_GETSEL           = 0x00B0
EM_SETPASSWORDCHAR  = 0x00CC
EM_GETPASSWORDCHAR  = 0x00D2
EM_SETREADONLY      = 0x00CF
EM_SETMODIFY        = 0x00B9
}


//Menu
define {
 MF_INSERT           = 0x00000000
 MF_CHANGE           = 0x00000080
 MF_APPEND           = 0x00000100
 MF_DELETE           = 0x00000200
 MF_REMOVE           = 0x00001000

 MF_BYCOMMAND        = 0x00000000
 MF_BYPOSITION       = 0x00000400

 MF_SEPARATOR        = 0x00000800

 MF_ENABLED          = 0x00000000
 MF_GRAYED           = 0x00000001
 MF_DISABLED         = 0x00000002

 MF_UNCHECKED        = 0x00000000
 MF_CHECKED          = 0x00000008
 MF_USECHECKBITMAPS  = 0x00000200

 MF_STRING           = 0x00000000
 MF_BITMAP           = 0x00000004
 MF_OWNERDRAW        = 0x00000100

 MF_POPUP            = 0x00000010
 MF_MENUBARBREAK     = 0x00000020
 MF_MENUBREAK        = 0x00000040

 MF_UNHILITE         = 0x00000000
 MF_HILITE           = 0x00000080


 MF_DEFAULT          = 0x00001000

 MF_SYSMENU          = 0x00002000
 MF_HELP             = 0x00004000

 MF_RIGHTJUSTIFY     = 0x00004000


 MF_MOUSESELECT      = 0x00008000
 MF_END              = 0x00000080

 MFT_STRING          =$MF_STRING
 MFT_BITMAP          =$MF_BITMAP
 MFT_MENUBARBREAK    =$MF_MENUBARBREAK
 MFT_MENUBREAK       =$MF_MENUBREAK
 MFT_OWNERDRAW       =$MF_OWNERDRAW
 MFT_RADIOCHECK      =0x00000200
 MFT_SEPARATOR       =$MF_SEPARATOR
 MFT_RIGHTORDER      =0x00002000
 MFT_RIGHTJUSTIFY    =$MF_RIGHTJUSTIFY
 
 
MIIM_STATE       = 0x00000001
MIIM_ID          = 0x00000002
MIIM_SUBMENU     = 0x00000004
MIIM_CHECKMARKS  = 0x00000008
MIIM_TYPE        = 0x00000010
MIIM_DATA        = 0x00000020
MIIM_BITMAP      = 0x00000080

MFS_GRAYED        = 0x00000003
MFS_DISABLED      =  $MFS_GRAYED
MFS_CHECKED       =  $MF_CHECKED
MFS_HILITE        =  $MF_HILITE
MFS_ENABLED       =  $MF_ENABLED
MFS_UNCHECKED     =  $MF_UNCHECKED
MFS_UNHILITE      =  $MF_UNHILITE
MFS_DEFAULT       =  $MF_DEFAULT

TPM_LEFTBUTTON  = 0x0000
TPM_RIGHTBUTTON = 0x0002
TPM_LEFTALIGN   = 0x0000
TPM_CENTERALIGN = 0x0004
TPM_RIGHTALIGN  = 0x0008

TPM_TOPALIGN        = 0x0000
TPM_VCENTERALIGN    = 0x0010
TPM_BOTTOMALIGN     = 0x0020

TPM_HORIZONTAL      = 0x0000
TPM_VERTICAL        = 0x0040
TPM_NONOTIFY        = 0x0080
TPM_RETURNCMD       = 0x0100


}



define {
   IDC_ARROW    =32512
   IDC_IBEAM    =32513
   IDC_WAIT     =32514
   IDC_CROSS    =32515
   IDC_UPARROW  =32516
   IDC_SIZE     =32640
   IDC_ICON     =32641
   IDC_SIZENWSE =32642
   IDC_SIZENESW =32643
   IDC_SIZEWE   =32644
   IDC_SIZENS   =32645
   IDC_SIZEALL  =32646
   IDC_NO       =32648
   IDC_HAND        =32649
   IDC_APPSTARTING =32650
   IDC_HELP        =32651
}

 

define {
TCS_FLATBUTTONS  = 0x0008
TCS_BUTTONS      = 0x0100
TCS_TOOLTIPS     = 0x4000
TCS_FIXEDWIDTH   = 0x0400

TCM_FIRST        =      0x1300
//TCM_INSERTITEMA  =  ($TCM_FIRST + 7)
TCM_SETIMAGELIST =  ($TCM_FIRST + 3)
TCM_INSERTITEMW  =  ($TCM_FIRST + 62)
TCM_DELETEITEM   =  ($TCM_FIRST + 8)
//TCM_GETITEMA     =  ($TCM_FIRST + 5)
TCM_GETITEMW     =  ($TCM_FIRST + 60)
//TCM_SETITEMA     =  ($TCM_FIRST + 6)
TCM_SETITEMW     =  ($TCM_FIRST + 61)
TCM_ADJUSTRECT   =  ($TCM_FIRST + 40)
TCM_GETCURSEL    =  ($TCM_FIRST + 11)
TCM_SETCURSEL    =  ($TCM_FIRST + 12)
TCM_GETTOOLTIPS  =  ($TCM_FIRST + 45)
TCM_SETTOOLTIPS  =  ($TCM_FIRST + 46)
TCM_SETMINTABWIDTH = ($TCM_FIRST + 49)
TCM_GETITEMW     =  ($TCM_FIRST + 60)
TCM_SETITEMSIZE  =  ($TCM_FIRST + 41)

TCIF_TEXT        =       0x0001
TCIF_IMAGE       =       0x0002
TCIF_RTLREADING  =       0x0004
TCIF_PARAM       =       0x0008
TCIF_STATE       =       0x0010

//TCN_FIRST -550 0xFFFFFDD9//
TCN_SELCHANGE    = -551//(TCN_FIRST - 1)


}

//vListBox
define {
LB_ADDSTRING            = 0x0180
LB_INSERTSTRING         = 0x0181
LB_DELETESTRING         = 0x0182
LB_SELITEMRANGEEX       = 0x0183
LB_RESETCONTENT         = 0x0184
LB_SETSEL               = 0x0185
LB_SETCURSEL            = 0x0186
LB_GETSEL               = 0x0187
LB_GETCURSEL            = 0x0188
LB_GETTEXT              = 0x0189
LB_GETTEXTLEN           = 0x018A
LB_GETCOUNT             = 0x018B
LB_SELECTSTRING         = 0x018C
LB_DIR                  = 0x018D
LB_GETTOPINDEX          = 0x018E
LB_FINDSTRING           = 0x018F
LB_GETSELCOUNT          = 0x0190
LB_GETSELITEMS          = 0x0191
LB_SETTABSTOPS          = 0x0192
LB_GETHORIZONTALEXTENT  = 0x0193
LB_SETHORIZONTALEXTENT  = 0x0194
LB_SETCOLUMNWIDTH       = 0x0195
LB_ADDFILE              = 0x0196
LB_SETTOPINDEX          = 0x0197
LB_GETITEMRECT          = 0x0198
LB_GETITEMDATA          = 0x0199
LB_SETITEMDATA          = 0x019A
LB_SELITEMRANGE         = 0x019B
LB_SETANCHORINDEX       = 0x019C
LB_GETANCHORINDEX       = 0x019D
LB_SETCARETINDEX        = 0x019E
LB_GETCARETINDEX        = 0x019F
LB_SETITEMHEIGHT        = 0x01A0
LB_GETITEMHEIGHT        = 0x01A1
LB_FINDSTRINGEXACT      = 0x01A2
LB_SETLOCALE            = 0x01A5
LB_GETLOCALE            = 0x01A6
LB_SETCOUNT             = 0x01A7
LB_INITSTORAGE          = 0x01A8
LB_ITEMFROMPOINT        = 0x01A9


LBS_NOTIFY            = 0x0001L
LBS_SORT              = 0x0002L
LBS_NOREDRAW          = 0x0004L
LBS_MULTIPLESEL       = 0x0008L
LBS_OWNERDRAWFIXED    = 0x0010L
LBS_OWNERDRAWVARIABLE = 0x0020L
LBS_HASSTRINGS        = 0x0040L
LBS_USETABSTOPS       = 0x0080L
LBS_NOINTEGRALHEIGHT  = 0x0100L
LBS_MULTICOLUMN       = 0x0200L
LBS_WANTKEYBOARDINPUT = 0x0400L
LBS_EXTENDEDSEL       = 0x0800L
LBS_DISABLENOSCROLL   = 0x1000L
LBS_NODATA            = 0x2000L   
}

//vComboBox
define {
CB_GETEDITSEL               = 0x0140
CB_LIMITTEXT                = 0x0141
CB_SETEDITSEL               = 0x0142
CB_ADDSTRING                = 0x0143
CB_DELETESTRING             = 0x0144
CB_DIR                      = 0x0145
CB_GETCOUNT                 = 0x0146
CB_GETCURSEL                = 0x0147
CB_GETLBTEXT                = 0x0148
CB_GETLBTEXTLEN             = 0x0149
CB_INSERTSTRING             = 0x014A
CB_RESETCONTENT             = 0x014B
CB_FINDSTRING               = 0x014C
CB_SELECTSTRING             = 0x014D
CB_SETCURSEL                = 0x014E
CB_SHOWDROPDOWN             = 0x014F
CB_GETITEMDATA              = 0x0150
CB_SETITEMDATA              = 0x0151
CB_GETDROPPEDCONTROLRECT    = 0x0152
CB_SETITEMHEIGHT            = 0x0153
CB_GETITEMHEIGHT            = 0x0154
CB_SETEXTENDEDUI            = 0x0155
CB_GETEXTENDEDUI            = 0x0156
CB_GETDROPPEDSTATE          = 0x0157
CB_FINDSTRINGEXACT          = 0x0158
CB_SETLOCALE                = 0x0159
CB_GETLOCALE                = 0x015A
CB_GETTOPINDEX              = 0x015b
CB_SETTOPINDEX              = 0x015c
CB_GETHORIZONTALEXTENT      = 0x015d
CB_SETHORIZONTALEXTENT      = 0x015e
CB_GETDROPPEDWIDTH          = 0x015f
CB_SETDROPPEDWIDTH          = 0x0160
CB_INITSTORAGE              = 0x0161
CB_MSGMAX                   = 0x0162
CB_MSGMAX                   = 0x015B

CBS_SIMPLE            = 0x0001
CBS_DROPDOWN          = 0x0002
CBS_DROPDOWNLIST      = 0x0003
CBS_OWNERDRAWFIXED    = 0x0010
CBS_OWNERDRAWVARIABLE = 0x0020
CBS_AUTOHSCROLL       = 0x0040
CBS_OEMCONVERT        = 0x0080
CBS_SORT              = 0x0100
CBS_HASSTRINGS        = 0x0200
CBS_NOINTEGRALHEIGHT  = 0x0400
CBS_DISABLENOSCROLL   = 0x0800
CBS_UPPERCASE         = 0x2000
CBS_LOWERCASE         = 0x4000

CBN_ERRSPACE        =-1
CBN_SELCHANGE       =1
CBN_DBLCLK          =2
CBN_SETFOCUS        =3
CBN_KILLFOCUS       =4
CBN_EDITCHANGE      =5
CBN_EDITUPDATE      =6
CBN_DROPDOWN        =7
CBN_CLOSEUP         =8
CBN_SELENDOK        =9
CBN_SELENDCANCEL    =10

}

//Border
define {
BDR_RAISEDOUTER =0x0001
BDR_SUNKENOUTER =0x0002
BDR_RAISEDINNER =0x0004
BDR_SUNKENINNER =0x0008

BDR_OUTER       =0x0003
BDR_INNER       =0x000c

EDGE_RAISED     =($BDR_RAISEDOUTER | $BDR_RAISEDINNER)
EDGE_SUNKEN     =($BDR_SUNKENOUTER | $BDR_SUNKENINNER)
EDGE_ETCHED     =($BDR_SUNKENOUTER | $BDR_RAISEDINNER)
EDGE_BUMP       =($BDR_RAISEDOUTER | $BDR_SUNKENINNER)

BF_LEFT         =0x0001
BF_TOP          =0x0002
BF_RIGHT        =0x0004
BF_BOTTOM       =0x0008

BF_TOPLEFT      =($BF_TOP | $BF_LEFT)
BF_TOPRIGHT     =($BF_TOP | $BF_RIGHT)
BF_BOTTOMLEFT   =($BF_BOTTOM | $BF_LEFT)
BF_BOTTOMRIGHT  =($BF_BOTTOM | $BF_RIGHT)
BF_RECT         =($BF_LEFT | $BF_TOP | $BF_RIGHT | $BF_BOTTOM)

BF_DIAGONAL     =0x0010

BF_DIAGONAL_ENDTOPRIGHT     =($BF_DIAGONAL | $BF_TOP | $BF_RIGHT)
BF_DIAGONAL_ENDTOPLEFT      =($BF_DIAGONAL | $BF_TOP | $BF_LEFT)
BF_DIAGONAL_ENDBOTTOMLEFT   =($BF_DIAGONAL | $BF_BOTTOM | $BF_LEFT)
BF_DIAGONAL_ENDBOTTOMRIGHT  =($BF_DIAGONAL | $BF_BOTTOM | $BF_RIGHT)


BF_MIDDLE       =0x0800  /* Fill in the middle */
BF_SOFT         =0x1000  /* For softer buttons */
BF_ADJUST       =0x2000  /* Calculate the space left over */
BF_FLAT         =0x4000  /* For flat rather than 3D borders */
BF_MONO         =0x8000  /* For monochrome borders */
}

//DrawText() Format Flags
define {
DT_TOP              = 0x00000000
DT_LEFT             = 0x00000000
DT_CENTER           = 0x00000001
DT_RIGHT            = 0x00000002
DT_VCENTER          = 0x00000004
DT_BOTTOM           = 0x00000008
DT_WORDBREAK        = 0x00000010
DT_SINGLELINE       = 0x00000020
DT_EXPANDTABS       = 0x00000040
DT_TABSTOP          = 0x00000080
DT_NOCLIP           = 0x00000100
DT_EXTERNALLEADING  = 0x00000200
DT_CALCRECT         = 0x00000400
DT_NOPREFIX         = 0x00000800
DT_INTERNAL         = 0x00001000


DT_EDITCONTROL      = 0x00002000
DT_PATH_ELLIPSIS    = 0x00004000
DT_END_ELLIPSIS     = 0x00008000
DT_MODIFYSTRING     = 0x00010000
DT_RTLREADING       = 0x00020000
DT_WORD_ELLIPSIS    = 0x0004000
}

//Scroll Bar 
define { 
SB_HORZ           =  0
SB_VERT           =  1
SB_CTL            =  2
SB_BOTH           =  3

SB_LINEUP         =  0
SB_LINELEFT       =  0
SB_LINEDOWN       =  1
SB_LINERIGHT      =  1
SB_PAGEUP         =  2
SB_PAGELEFT       =  2
SB_PAGEDOWN       =  3
SB_PAGERIGHT      =  3
SB_THUMBPOSITION  =  4
SB_THUMBTRACK     =  5
SB_TOP            =  6
SB_LEFT           =  6
SB_BOTTOM         =  7
SB_RIGHT          =  7
SB_ENDSCROLL      =  8


SBM_SETPOS                  = 0x00E0 
SBM_GETPOS                  = 0x00E1 
SBM_SETRANGE                = 0x00E2 
SBM_SETRANGEREDRAW          = 0x00E6 
SBM_GETRANGE                = 0x00E3 
SBM_ENABLE_ARROWS           = 0x00E4 

SBM_SETSCROLLINFO           = 0x00E9
SBM_GETSCROLLINFO           = 0x00EA

SIF_RANGE           = 0x0001
SIF_PAGE            = 0x0002
SIF_POS             = 0x0004
SIF_DISABLENOSCROLL = 0x0008
SIF_TRACKPOS        = 0x0010
SIF_ALL             =($SIF_RANGE | $SIF_PAGE | $SIF_POS | $SIF_TRACKPOS)
}

//syscolors
define {
COLOR_SCROLLBAR         =0
COLOR_BACKGROUND        =1
COLOR_ACTIVECAPTION     =2
COLOR_INACTIVECAPTION   =3
COLOR_MENU              =4
COLOR_WINDOW            =5
COLOR_WINDOWFRAME       =6
COLOR_MENUTEXT          =7
COLOR_WINDOWTEXT        =8
COLOR_CAPTIONTEXT       =9
COLOR_ACTIVEBORDER      =10
COLOR_INACTIVEBORDER    =11
COLOR_APPWORKSPACE      =12
COLOR_HIGHLIGHT         =13
COLOR_HIGHLIGHTTEXT     =14
COLOR_BTNFACE           =15
COLOR_BTNSHADOW         =16
COLOR_GRAYTEXT          =17
COLOR_BTNTEXT           =18
COLOR_INACTIVECAPTIONTEXT =19
COLOR_BTNHIGHLIGHT      =20


COLOR_3DDKSHADOW        =21
COLOR_3DLIGHT           =22
COLOR_INFOTEXT          =23
COLOR_INFOBK            =24
}



define {
OFN_READONLY                 = 0x00000001
OFN_OVERWRITEPROMPT          = 0x00000002
OFN_HIDEREADONLY             = 0x00000004
OFN_NOCHANGEDIR              = 0x00000008
OFN_SHOWHELP                 = 0x00000010
OFN_ENABLEHOOK               = 0x00000020
OFN_ENABLETEMPLATE           = 0x00000040
OFN_ENABLETEMPLATEHANDLE     = 0x00000080
OFN_NOVALIDATE               = 0x00000100
OFN_ALLOWMULTISELECT         = 0x00000200
OFN_EXTENSIONDIFFERENT       = 0x00000400
OFN_PATHMUSTEXIST            = 0x00000800
OFN_FILEMUSTEXIST            = 0x00001000
OFN_CREATEPROMPT             = 0x00002000
OFN_SHAREAWARE               = 0x00004000
OFN_NOREADONLYRETURN         = 0x00008000
OFN_NOTESTFILECREATE         = 0x00010000
OFN_NONETWORKBUTTON          = 0x00020000
OFN_NOLONGNAMES              = 0x00040000
OFN_EXPLORER                 = 0x00080000
OFN_NODEREFERENCELINKS       = 0x00100000
OFN_LONGNAMES                = 0x00200000
OFN_ENABLEINCLUDENOTIFY      = 0x00400000
OFN_ENABLESIZING             = 0x00800000

CC_RGBINIT              = 0x00000001
CC_FULLOPEN             = 0x00000002
CC_PREVENTFULLOPEN      = 0x00000004
CC_SHOWHELP             = 0x00000008
CC_ENABLEHOOK           = 0x00000010
CC_ENABLETEMPLATE       = 0x00000020
CC_ENABLETEMPLATEHANDLE = 0x00000040
CC_SOLIDCOLOR           = 0x00000080
CC_ANYCOLOR             = 0x00000100
}


type OPENFILENAME{  
    uint       lStructSize 
    uint       hwndOwner 
    uint       hInstance 
    uint       lpstrFilter 
    uint       lpstrCustomFilter 
    uint       nMaxCustFilter 
    uint       nFilterIndex 
    uint       lpstrFile 
    uint       nMaxFile 
    uint       lpstrFileTitle 
    uint       nMaxFileTitle 
    uint       lpstrInitialDir 
    uint       lpstrTitle 
    uint       Flags 
    ushort     nFileOffset 
    ushort     nFileExtension 
    uint       lpstrDefExt 
    uint       lCustData 
    uint       lpfnHook 
    uint       lpTemplateName 
} 

type CHOOSECOLOR {
    uint lStructSize
    uint hwndOwner
    uint hInstance
    uint rgbResult
    uint lpCustColors
    uint Flags
    uint lCustData
    uint lpfnHook
    uint lpTemplateName
} 

type CHOOSEFONT {
    uint lStructSize
    uint hwndOwner
    uint hDC
    uint lpLogFont
    int iPointSize
    uint Flags
    uint rgbColors
    uint lCustData
    uint lpfnHook
    uint lpTemplateName
    uint hInstance
    uint lpszStyle
    ushort nFontType
    ushort miss
    int nSizeMin
    int nSizeMax
}

define {
CF_SCREENFONTS             = 0x00000001
CF_PRINTERFONTS            = 0x00000002
CF_BOTH                    = ($CF_SCREENFONTS | $CF_PRINTERFONTS)
/*CF_SHOWHELP                = 0x00000004
CF_ENABLEHOOK              = 0x00000008
CF_ENABLETEMPLATE          = 0x00000010
CF_ENABLETEMPLATEHANDLE    = 0x00000020*/
CF_INITTOLOGFONTSTRUCT     = 0x00000040
/*CF_USESTYLE                = 0x00000080*/
CF_EFFECTS                 = 0x00000100
/*CF_APPLY                   = 0x00000200
CF_ANSIONLY                = 0x00000400
CF_NOVECTORFONTS           = 0x00000800
CF_NOSIMULATIONS           = 0x00001000
CF_LIMITSIZE               = 0x00002000
CF_FIXEDPITCHONLY          = 0x00004000
CF_WYSIWYG                 = 0x00008000 // must also have CF_SCREENFONTS & CF_PRINTERFONTS
CF_FORCEFONTEXIST          = 0x00010000
CF_SCALABLEONLY            = 0x00020000
CF_TTONLY                  = 0x00040000
CF_NOFACESEL               = 0x00080000
CF_NOSTYLESEL              = 0x00100000
CF_NOSIZESEL               = 0x00200000
CF_SELECTSCRIPT            = 0x00400000
CF_NOSCRIPTSEL             = 0x00800000
CF_NOVERTFONTS             = 0x01000000*/
}

import "comdlg32"{
   uint GetOpenFileNameW( OPENFILENAME ) -> GetOpenFileName
   uint GetSaveFileNameW( OPENFILENAME ) -> GetSaveFileName
   uint ChooseColorW( CHOOSECOLOR ) -> ChooseColor
   uint ChooseFontW( CHOOSEFONT ) -> ChooseFont
}


import "comctl32"{   
   uint ImageList_Add( uint, uint, uint )
   uint ImageList_AddMasked( uint, uint, uint )
   uint ImageList_BeginDrag( uint, uint, uint, uint )
   uint ImageList_EndDrag()
   uint ImageList_DragShowNolock( uint )
   uint ImageList_DragEnter( uint, uint, uint )
   uint ImageList_DragLeave( uint )
   uint ImageList_DragMove( uint, uint )
   uint ImageList_SetOverlayImage( uint, uint, uint )
   
}

//--------------------------------------------------
//Static
define {
SS_LEFT             = 0x00000000
SS_CENTER           = 0x00000001
SS_RIGHT            = 0x00000002
SS_ICON             = 0x00000003
SS_BLACKRECT        = 0x00000004
SS_GRAYRECT         = 0x00000005
SS_WHITERECT        = 0x00000006
SS_BLACKFRAME       = 0x00000007
SS_GRAYFRAME        = 0x00000008
SS_WHITEFRAME       = 0x00000009
SS_USERITEM         = 0x0000000A
SS_SIMPLE           = 0x0000000B
SS_LEFTNOWORDWRAP   = 0x0000000C
SS_OWNERDRAW        = 0x0000000D
SS_BITMAP           = 0x0000000E
SS_ENHMETAFILE      = 0x0000000F
SS_ETCHEDHORZ       = 0x00000010
SS_ETCHEDVERT       = 0x00000011
SS_ETCHEDFRAME      = 0x00000012
SS_TYPEMASK         = 0x0000001F
SS_REALSIZECONTROL  = 0x00000040
SS_NOPREFIX         = 0x00000080
SS_NOTIFY           = 0x00000100
SS_CENTERIMAGE      = 0x00000200
SS_RIGHTJUST        = 0x00000400
SS_REALSIZEIMAGE    = 0x00000800
SS_SUNKEN           = 0x00001000
SS_EDITCONTROL      = 0x00002000
SS_ENDELLIPSIS      = 0x00004000
SS_PATHELLIPSIS     = 0x00008000
SS_WORDELLIPSIS     = 0x0000C000
SS_ELLIPSISMASK     = 0x0000C000
}


//--------------------------------------------------
//TreeView

type TVITEM {
    uint    mask
    uint    hItem
    uint    state
    uint    stateMask
    uint    pszText
    int     cchTextMax
    int     iImage
    int     iSelectedImage
    int     cChildren
    uint    lParam
}

type TVITEMEX {
    uint mask
    uint hItem
    uint state
    uint stateMask
    uint pszText
    int cchTextMax
    int iImage
    int iSelectedImage
    int cChildren
    uint lParam
    int iIntegral
} 

type TVINSERTSTRUCT {
   uint hParent
   uint hInsertAfter
   TVITEMEX item
}

type NMTREEVIEWW {
    NMHDR     hdr
    uint      action
    TVITEM    itemOld
    TVITEM    itemNew
    POINT     ptDrag
} 

type NMTVDISPINFO {
    NMHDR hdr 
    TVITEM item 
}

type TVHITTESTINFO {
    POINT pt
    uint flags
    uint hItem
}


define {
//Styles
TVS_HASBUTTONS          = 0x0001
TVS_HASLINES            = 0x0002
TVS_LINESATROOT         = 0x0004
TVS_EDITLABELS          = 0x0008
TVS_DISABLEDRAGDROP     = 0x0010
TVS_SHOWSELALWAYS       = 0x0020
TVS_RTLREADING          = 0x0040
TVS_NOTOOLTIPS          = 0x0080
TVS_CHECKBOXES          = 0x0100
TVS_TRACKSELECT         = 0x0200
TVS_SINGLEEXPAND        = 0x0400
TVS_INFOTIP             = 0x0800
TVS_FULLROWSELECT       = 0x1000
TVS_NOSCROLL            = 0x2000
TVS_NONEVENHEIGHT       = 0x4000

//Messages
TV_FIRST             = 0x1100
TVM_INSERTITEMW         = $TV_FIRST + 50
TVM_DELETEITEM          = $TV_FIRST + 1
TVM_EXPAND              = $TV_FIRST + 2      
TVM_GETITEMRECT         = $TV_FIRST + 4
TVM_GETCOUNT            = $TV_FIRST + 5
TVM_GETINDENT           = $TV_FIRST + 6
TVM_SETINDENT           = $TV_FIRST + 7
TVM_GETIMAGELIST        = $TV_FIRST + 8
TVM_SETIMAGELIST        = $TV_FIRST + 9
TVM_GETNEXTITEM         = $TV_FIRST + 10
TVM_SELECTITEM          = $TV_FIRST + 11
TVM_GETITEMW            = $TV_FIRST + 62
TVM_SETITEMW            = $TV_FIRST + 63
TVM_EDITLABELW          = $TV_FIRST + 65
TVM_GETEDITCONTROL      = $TV_FIRST + 15
TVM_GETVISIBLECOUNT     = $TV_FIRST + 16
TVM_HITTEST             = $TV_FIRST + 17
TVM_CREATEDRAGIMAGE     = $TV_FIRST + 18 
TVM_SORTCHILDREN        = $TV_FIRST + 19
TVM_ENSUREVISIBLE       = $TV_FIRST + 20
TVM_SORTCHILDRENCB      = $TV_FIRST + 21
TVM_ENDEDITLABELNOW     = $TV_FIRST + 22
TVM_GETISEARCHSTRINGW   = $TV_FIRST + 64
TVM_SETTOOLTIPS         = $TV_FIRST + 24
TVM_GETTOOLTIPS         = $TV_FIRST + 25
TVM_SETINSERTMARK       = $TV_FIRST + 26
TVM_SETITEMHEIGHT       = $TV_FIRST + 27
TVM_GETITEMHEIGHT       = $TV_FIRST + 28
TVM_SETBKCOLOR          = $TV_FIRST + 29
TVM_SETTEXTCOLOR        = $TV_FIRST + 30
TVM_GETBKCOLOR          = $TV_FIRST + 31
TVM_GETTEXTCOLOR        = $TV_FIRST + 32
TVM_SETSCROLLTIME       = $TV_FIRST + 33
TVM_GETSCROLLTIME       = $TV_FIRST + 34
TVM_SETINSERTMARKCOLOR  = $TV_FIRST + 37
TVM_GETINSERTMARKCOLOR  = $TV_FIRST + 38

//

NM_FIRST = 0
NM_OUTOFMEMORY          = $NM_FIRST - 1
NM_CLICK                = $NM_FIRST - 2 
NM_DBLCLK               = $NM_FIRST - 3
NM_RETURN               = $NM_FIRST - 4
NM_RCLICK               = $NM_FIRST - 5 
NM_RDBLCLK              = $NM_FIRST - 6
NM_SETFOCUS             = $NM_FIRST - 7
NM_KILLFOCUS            = $NM_FIRST - 8
NM_CUSTOMDRAW           = $NM_FIRST - 12
NM_HOVER                = $NM_FIRST - 13
NM_NCHITTEST            = $NM_FIRST - 14
NM_KEYDOWN              = $NM_FIRST - 15
NM_RELEASEDCAPTURE      = $NM_FIRST - 16
NM_SETCURSOR            = $NM_FIRST - 17
NM_CHAR                 = $NM_FIRST - 18

//Notification messages
TVN_FIRST               = - 400
TVN_SELCHANGINGW        = $TVN_FIRST - 50 
TVN_SELCHANGEDW         = $TVN_FIRST - 51
TVN_GETDISPINFOW        = $TVN_FIRST - 52
TVN_SETDISPINFOW        = $TVN_FIRST - 53
TVN_ITEMEXPANDINGW      = $TVN_FIRST - 54
TVN_ITEMEXPANDEDW       = $TVN_FIRST - 55
TVN_BEGINDRAGW          = $TVN_FIRST - 56
TVN_BEGINRDRAGW         = $TVN_FIRST - 57
TVN_DELETEITEMW         = $TVN_FIRST - 58
TVN_BEGINLABELEDITW     = $TVN_FIRST - 59
TVN_ENDLABELEDITW       = $TVN_FIRST - 60
TVN_KEYDOWN             = $TVN_FIRST - 12
TVN_GETINFOTIPA         = $TVN_FIRST - 13
TVN_GETINFOTIPW         = $TVN_FIRST - 14
TVN_SINGLEEXPAND        = $TVN_FIRST - 15

TVI_ROOT                =0xFFFF0000
TVI_FIRST               =0xFFFF0001
TVI_LAST                =0xFFFF0002
TVI_SORT                =0xFFFF0003

//Item mask
TVIF_TEXT               = 0x0001
TVIF_IMAGE              = 0x0002
TVIF_PARAM              = 0x0004
TVIF_STATE              = 0x0008
TVIF_HANDLE             = 0x0010
TVIF_SELECTEDIMAGE      = 0x0020
TVIF_CHILDREN           = 0x0040
TVIF_INTEGRAL           = 0x0080

TVIS_SELECTED           = 0x0002
TVIS_CUT                = 0x0004
TVIS_DROPHILITED        = 0x0008
TVIS_BOLD               = 0x0010
TVIS_EXPANDED           = 0x0020
TVIS_EXPANDEDONCE       = 0x0040
TVIS_EXPANDPARTIAL      = 0x0080
TVIS_OVERLAYMASK        = 0x0F00
TVIS_STATEIMAGEMASK     = 0xF000
TVIS_USERMASK           = 0xF000

TVGN_ROOT               = 0x0000
TVGN_NEXT               = 0x0001
TVGN_PREVIOUS           = 0x0002
TVGN_PARENT             = 0x0003
TVGN_CHILD              = 0x0004
TVGN_FIRSTVISIBLE       = 0x0005
TVGN_NEXTVISIBLE        = 0x0006
TVGN_PREVIOUSVISIBLE    = 0x0007
TVGN_DROPHILITE         = 0x0008
TVGN_CARET              = 0x0009
TVGN_LASTVISIBLE        = 0x000A

TVE_COLLAPSE            = 0x0001
TVE_EXPAND              = 0x0002
TVE_TOGGLE              = 0x0003
TVE_EXPANDPARTIAL       = 0x4000
TVE_COLLAPSERESET       = 0x8000

TVSIL_NORMAL            = 0
TVSIL_STATE             = 2

TVHT_NOWHERE            = 0x0001
TVHT_ONITEMICON         = 0x0002
TVHT_ONITEMLABEL        = 0x0004
TVHT_ONITEMINDENT       = 0x0008
TVHT_ONITEMBUTTON       = 0x0010
TVHT_ONITEMRIGHT        = 0x0020
TVHT_ONITEMSTATEICON    = 0x0040

TVHT_ABOVE              = 0x0100
TVHT_BELOW              = 0x0200
TVHT_TORIGHT            = 0x0400
TVHT_TOLEFT             = 0x0800

}


//--------------------------------------------------
//ListView

type LVITEM
{
    uint mask
    int  iItem
    int  iSubItem
    uint state
    uint stateMask
    uint pszText
    int  cchTextMax
    int  iImage
    uint lParam
    int  iIndent
}

type LVCOLUMN
{
    uint mask 
    int fmt 
    int cx 
    uint pszText 
    int cchTextMax 
    int iSubItem
    int iImage
    int iOrder
}

type LVFINDINFO {
    uint flags
    uint psz
    uint lParam
    POINT pt
    uint vkDirection
} 

type NMLISTVIEW
{
    NMHDR   hdr
    int     iItem
    int     iSubItem
    uint    uNewState
    uint    uOldState
    uint    uChanged
    POINT   ptAction
    uint    lParam
}

type NMITEMACTIVATE
{
    NMHDR   hdr
    int     iItem
    int     iSubItem
    uint    uNewState
    uint    uOldState
    uint    uChanged
    POINT   ptAction
    uint    lParam
    uint    uKeyFlags
}

type NMLVDISPINFO {
    NMHDR hdr
    LVITEM item
}

type NMLVODSTATECHANGE {
    NMHDR hdr
    int iFrom
    int iTo
    uint uNewState
    uint uOldState
}

define
{
//Styles
LVS_ICON                = 0x0000
LVS_REPORT              = 0x0001
LVS_SMALLICON           = 0x0002
LVS_LIST                = 0x0003
LVS_TYPEMASK            = 0x0003
LVS_SINGLESEL           = 0x0004
LVS_SHOWSELALWAYS       = 0x0008
LVS_SORTASCENDING       = 0x0010
LVS_SORTDESCENDING      = 0x0020
LVS_SHAREIMAGELISTS     = 0x0040
LVS_NOLABELWRAP         = 0x0080
LVS_AUTOARRANGE         = 0x0100
LVS_EDITLABELS          = 0x0200
LVS_OWNERDATA           = 0x1000
LVS_NOSCROLL            = 0x2000
LVS_TYPESTYLEMASK       = 0xfc00
LVS_ALIGNTOP            = 0x0000
LVS_ALIGNLEFT           = 0x0800
LVS_ALIGNMASK           = 0x0c00
LVS_OWNERDRAWFIXED      = 0x0400
LVS_NOCOLUMNHEADER      = 0x4000
LVS_NOSORTHEADER        = 0x8000

LVS_EX_GRIDLINES        = 0x00000001
LVS_EX_SUBITEMIMAGES    = 0x00000002
LVS_EX_CHECKBOXES       = 0x00000004
LVS_EX_TRACKSELECT      = 0x00000008
LVS_EX_HEADERDRAGDROP   = 0x00000010
LVS_EX_FULLROWSELECT    = 0x00000020
LVS_EX_ONECLICKACTIVATE = 0x00000040
LVS_EX_TWOCLICKACTIVATE = 0x00000080
LVS_EX_FLATSB           = 0x00000100
LVS_EX_REGIONAL         = 0x00000200
LVS_EX_INFOTIP          = 0x00000400
LVS_EX_UNDERLINEHOT     = 0x00000800
LVS_EX_UNDERLINECOLD    = 0x00001000
LVS_EX_MULTIWORKAREAS   = 0x00002000


//Messages
LVM_FIRST               = 0x1000
LVM_GETBKCOLOR          = $LVM_FIRST + 0
LVM_SETBKCOLOR          = $LVM_FIRST + 1
LVM_GETIMAGELIST        = $LVM_FIRST + 2
LVM_SETIMAGELIST        = $LVM_FIRST + 3
LVM_GETITEMCOUNT        = $LVM_FIRST + 4

LVM_DELETEITEM          = $LVM_FIRST + 8
LVM_DELETEALLITEMS      = $LVM_FIRST + 9
LVM_GETCALLBACKMASK     = $LVM_FIRST + 10
LVM_SETCALLBACKMASK     = $LVM_FIRST + 11
LVM_GETNEXTITEM         = $LVM_FIRST + 12

LVM_GETITEMRECT         = $LVM_FIRST + 14
LVM_SETITEMPOSITION     = $LVM_FIRST + 15
LVM_GETITEMPOSITION     = $LVM_FIRST + 16

LVM_HITTEST             = $LVM_FIRST + 18
LVM_ENSUREVISIBLE       = $LVM_FIRST + 19
LVM_SCROLL              = $LVM_FIRST + 20
LVM_REDRAWITEMS         = $LVM_FIRST + 21
LVM_ARRANGE             = $LVM_FIRST + 22
LVM_GETEDITCONTROL      = $LVM_FIRST + 24
LVM_GETCOLUMNW          = $LVM_FIRST + 95
LVM_INSERTCOLUMNW       = $LVM_FIRST + 97
LVM_DELETECOLUMN        = $LVM_FIRST + 28
LVM_GETCOLUMNWIDTH      = $LVM_FIRST + 29
LVM_SETCOLUMNWIDTH      = $LVM_FIRST + 30
LVM_GETHEADER           = $LVM_FIRST + 31
LVM_CREATEDRAGIMAGE     = $LVM_FIRST + 33
LVM_GETVIEWRECT         = $LVM_FIRST + 34
LVM_GETTEXTCOLOR        = $LVM_FIRST + 35
LVM_SETTEXTCOLOR        = $LVM_FIRST + 36
LVM_GETTEXTBKCOLOR      = $LVM_FIRST + 37
LVM_SETTEXTBKCOLOR      = $LVM_FIRST + 38
LVM_GETTOPINDEX         = $LVM_FIRST + 39
LVM_GETCOUNTPERPAGE     = $LVM_FIRST + 40
LVM_GETORIGIN           = $LVM_FIRST + 41
LVM_UPDATE              = $LVM_FIRST + 42
LVM_SETITEMSTATE        = $LVM_FIRST + 43
LVM_GETITEMSTATE        = $LVM_FIRST + 44
LVM_SETITEMCOUNT        = $LVM_FIRST + 47
LVM_GETSELECTEDCOUNT    = $LVM_FIRST + 50
LVM_GETITEMSPACING      = $LVM_FIRST + 51
LVM_GETISEARCHSTRINGA   = $LVM_FIRST + 52
LVM_SETICONSPACING      = $LVM_FIRST + 53
LVM_SETEXTENDEDLISTVIEWSTYLE = $LVM_FIRST + 54
LVM_GETEXTENDEDLISTVIEWSTYLE = $LVM_FIRST + 55
LVM_GETSUBITEMRECT      = $LVM_FIRST + 56
LVM_SUBITEMHITTEST      = $LVM_FIRST + 57
LVM_SETCOLUMNORDERARRAY = $LVM_FIRST + 58
LVM_GETCOLUMNORDERARRAY = $LVM_FIRST + 59
LVM_SETHOTITEM          = $LVM_FIRST + 60
LVM_GETHOTITEM          = $LVM_FIRST + 61
LVM_SETHOTCURSOR        = $LVM_FIRST + 62
LVM_GETHOTCURSOR        = $LVM_FIRST + 63
LVM_APPROXIMATEVIEWRECT = $LVM_FIRST + 64
LVM_SETWORKAREAS        = $LVM_FIRST + 65
LVM_GETSELECTIONMARK    = $LVM_FIRST + 66
LVM_SETSELECTIONMARK    = $LVM_FIRST + 67
LVM_GETWORKAREAS        = $LVM_FIRST + 70
LVM_SETHOVERTIME        = $LVM_FIRST + 71
LVM_GETHOVERTIME        = $LVM_FIRST + 72
LVM_GETNUMBEROFWORKAREAS  = $LVM_FIRST + 73
LVM_SETTOOLTIPS         = $LVM_FIRST + 74
LVM_GETTOOLTIPS         = $LVM_FIRST + 78

LVM_GETITEMW            = $LVM_FIRST + 75
LVM_SETITEMW            = $LVM_FIRST + 76
LVM_INSERTITEMW         = $LVM_FIRST + 77

LVM_SORTITEMSEX         = $LVM_FIRST + 81
LVM_FINDITEMW           = $LVM_FIRST + 83
LVM_GETSTRINGWIDTHW     = $LVM_FIRST + 87

LVM_SETCOLUMNW          = $LVM_FIRST + 96

LVM_GETITEMTEXTW        = $LVM_FIRST + 115
LVM_SETITEMTEXTW        = $LVM_FIRST + 116

LVM_EDITLABELW          = $LVM_FIRST + 118

LVM_SETBKIMAGEW         = $LVM_FIRST + 138
LVM_GETBKIMAGEW         = $LVM_FIRST + 139

//Notification messages
LVN_FIRST               = -100
LVN_ITEMCHANGING        = $LVN_FIRST - 0
LVN_ITEMCHANGED         = $LVN_FIRST - 1
LVN_INSERTITEM          = $LVN_FIRST - 2
LVN_DELETEITEM          = $LVN_FIRST - 3
LVN_DELETEALLITEMS      = $LVN_FIRST - 4
LVN_BEGINLABELEDITW     = $LVN_FIRST - 75
LVN_ENDLABELEDITW       = $LVN_FIRST - 76
LVN_COLUMNCLICK         = $LVN_FIRST - 8
LVN_BEGINDRAG           = $LVN_FIRST - 9
LVN_BEGINRDRAG          = $LVN_FIRST - 11
LVN_ODCACHEHINT         = $LVN_FIRST - 13
LVN_ODFINDITEMW         = $LVN_FIRST - 79
LVN_ITEMACTIVATE        = $LVN_FIRST - 14
LVN_ODSTATECHANGED      = $LVN_FIRST - 15
LVN_HOTTRACK            = $LVN_FIRST - 21
LVN_GETDISPINFOW        = $LVN_FIRST - 77
LVN_SETDISPINFOW        = $LVN_FIRST - 78


//Item mask
LVIF_TEXT               = 0x0001
LVIF_IMAGE              = 0x0002
LVIF_PARAM              = 0x0004
LVIF_STATE              = 0x0008
LVIF_INDENT             = 0x0010
LVIF_NORECOMPUTE        = 0x0800

//Item state
LVIS_FOCUSED            = 0x0001
LVIS_SELECTED           = 0x0002
LVIS_CUT                = 0x0004
LVIS_DROPHILITED        = 0x0008
LVIS_ACTIVATING         = 0x0020
LVIS_OVERLAYMASK        = 0x0F00
LVIS_STATEIMAGEMASK     = 0xF000


//LVM_GETNEXTITEM flags
LVNI_ALL                = 0x0000
LVNI_FOCUSED            = 0x0001
LVNI_SELECTED           = 0x0002
LVNI_CUT                = 0x0004
LVNI_DROPHILITED        = 0x0008
LVNI_ABOVE              = 0x0100
LVNI_BELOW              = 0x0200
LVNI_TOLEFT             = 0x0400
LVNI_TORIGHT            = 0x0800

//LVCOLUMN mask
LVCF_FMT                = 0x0001
LVCF_WIDTH              = 0x0002
LVCF_TEXT               = 0x0004
LVCF_SUBITEM            = 0x0008
LVCF_IMAGE              = 0x0010
LVCF_ORDER              = 0x0020

LVCFMT_IMAGE            = 0x0800
LVCFMT_BITMAP_ON_RIGHT  = 0x1000
LVCFMT_COL_HAS_IMAGES   = 0x8000


LVSIL_NORMAL            = 0
LVSIL_SMALL             = 1
LVSIL_STATE             = 2

LVFI_PARAM              = 0x0001

LVSICF_NOINVALIDATEALL  = 0x00000001
LVSICF_NOSCROLL         = 0x00000002
}

type LVHITTESTINFO {
    POINT pt
    uint flags
    int iItem
    int iSubItem
}

define {
   theme_button = 0
   theme_toolbar = 1
   //theme_menu = 2
   theme_max = 20
   
}

define {
   BP_PUSHBUTTON = 1  
   BP_RADIOBUTTON = 2  
   BP_CHECKBOX = 3  
   BP_GROUPBOX = 4  
   BP_USERBUTTON = 5
   
   PBS_NORMAL = 1  
   PBS_HOT = 2  
   PBS_PRESSED = 3  
   PBS_DISABLED = 4  
   PBS_DEFAULTED = 5
   

   TP_BUTTON         =  1
   TS_NORMAL         =  1
   TS_HOT            =  2
   TS_PRESSED        =  3
   TS_DISABLED       =  4
   TS_CHECKED        =  5
   TS_HOTCHECKED     =  6
   CBS_UNCHECKEDNORMAL = 1
   CBS_UNCHECKEDHOT   = 2
   CBS_CHECKEDNORMAL  = 5
   CBS_CHECKEDHOT     = 6
}

  
//DRAWITEMSTRUCT.itemState
define {
   ODS_SELECTED    = 0x0001
   ODS_GRAYED      = 0x0002
   ODS_DISABLED    = 0x0004
   ODS_CHECKED     = 0x0008
   ODS_FOCUS       = 0x0010
   ODS_DEFAULT         = 0x0020
   ODS_COMBOBOXEDIT    = 0x1000
   ODS_HOTLIGHT        = 0x0040
   ODS_INACTIVE        = 0x0080
   ODS_NOACCEL         = 0x0100
   ODS_NOFOCUSRECT     = 0x0200
}

//Image STATIC.PICTURE
define 
{
STM_SETICON       =  0x0170
STM_GETICON       =  0x0171
STM_SETIMAGE      =  0x0172
STM_GETIMAGE      =  0x0173
STN_CLICKED       =  0
STN_DBLCLK        =  1
STN_ENABLE        =  2
STN_DISABLE       =  3
}

//LoadImage
define 
{
LR_DEFAULTCOLOR     = 0x0000
LR_MONOCHROME       = 0x0001
LR_COLOR            = 0x0002
LR_COPYRETURNORG    = 0x0004
LR_COPYDELETEORG    = 0x0008
LR_LOADFROMFILE     = 0x0010
LR_LOADTRANSPARENT  = 0x0020
LR_DEFAULTSIZE      = 0x0040
LR_VGACOLOR         = 0x0080
LR_LOADMAP3DCOLORS  = 0x1000
LR_CREATEDIBSECTION = 0x2000
LR_COPYFROMRESOURCE = 0x4000
LR_SHARED           = 0x8000
}

//DrawImageEx
define {
DI_MASK         = 0x0001
DI_IMAGE        = 0x0002
DI_NORMAL       = 0x0003
DI_COMPAT       = 0x0004
DI_DEFAULTSIZE  = 0x0008
DI_NOMIRROR     = 0x0010
}

//GetCurrentObject
define {
OBJ_PEN             = 1
OBJ_BRUSH           = 2
OBJ_DC              = 3
OBJ_METADC          = 4
OBJ_PAL             = 5
OBJ_FONT            = 6
OBJ_BITMAP          = 7
OBJ_REGION          = 8
OBJ_METAFILE        = 9
OBJ_MEMDC           = 10
OBJ_EXTPEN          = 11
OBJ_ENHMETADC       = 12
OBJ_ENHMETAFILE     = 13
OBJ_COLORSPACE      = 14
}

//TrackMouseEvent, TRACKMOUSEEVENT
define {
TME_HOVER       = 0x00000001
TME_LEAVE       = 0x00000002
TME_NONCLIENT   = 0x00000010
TME_QUERY       = 0x40000000
TME_CANCEL      = 0x80000000
HOVER_DEFAULT   = 0xFFFFFFFF
}

//ToolbarWindow32
type TBBUTTON {
    int      iBitmap 
    int      idCommand 
    byte     fsState 
    byte     fsStyle
    reserved bReserved[2]     // padding for alignment
    uint     dwData 
    uint     iString 
} 

type TBBUTTONINFO {
    uint cbSize
    uint dwMask
    int idCommand
    int iImage
    byte fsState
    byte fsStyle
    short cx
    uint lParam
    uint pszText
    int cchText
}

type NMTOOLBAR {
    NMHDR hdr
    int iItem
    TBBUTTON tbButton
    int cchText
    uint pszText
    RECT rcButton
}

define {
TB_CHECKBUTTON          = $WM_USER + 2
TB_INSERTBUTTON         = $WM_USER + 67
TB_ADDBUTTONS           = $WM_USER + 68
TB_HITTEST              = $WM_USER + 69
TB_DELETEBUTTON         = $WM_USER + 22
TB_GETBUTTON            = $WM_USER + 23
TB_BUTTONCOUNT          = $WM_USER + 24
TB_COMMANDTOINDEX       = $WM_USER + 25
TB_SAVERESTORE          = $WM_USER + 76
TB_CUSTOMIZE            = $WM_USER + 27
TB_ADDSTRING            = $WM_USER + 77
TB_GETITEMRECT          = $WM_USER + 29
TB_BUTTONSTRUCTSIZE     = $WM_USER + 30
TB_SETBUTTONSIZE        = $WM_USER + 31
TB_SETBITMAPSIZE        = $WM_USER + 32
TB_AUTOSIZE             = $WM_USER + 33
TB_GETTOOLTIPS          = $WM_USER + 35
TB_SETTOOLTIPS          = $WM_USER + 36
TB_SETPARENT            = $WM_USER + 37
TB_SETROWS              = $WM_USER + 39
TB_GETROWS              = $WM_USER + 40
TB_SETCMDID             = $WM_USER + 42
TB_CHANGEBITMAP         = $WM_USER + 43
TB_GETBITMAP            = $WM_USER + 44
TB_GETBUTTONTEXTW       = $WM_USER + 75
TB_REPLACEBITMAP        = $WM_USER + 46
TB_SETINDENT            = $WM_USER + 47
TB_SETIMAGELIST         = $WM_USER + 48
TB_GETIMAGELIST         = $WM_USER + 49
TB_LOADIMAGES           = $WM_USER + 50
TB_GETRECT              = $WM_USER + 51
TB_SETHOTIMAGELIST      = $WM_USER + 52
TB_GETHOTIMAGELIST      = $WM_USER + 53
TB_SETDISABLEDIMAGELIST = $WM_USER + 54
TB_GETDISABLEDIMAGELIST = $WM_USER + 55
TB_SETSTYLE             = $WM_USER + 56
TB_GETSTYLE             = $WM_USER + 57
TB_GETBUTTONSIZE        = $WM_USER + 58
TB_SETBUTTONWIDTH       = $WM_USER + 59
TB_SETMAXTEXTROWS       = $WM_USER + 60
TB_GETTEXTROWS          = $WM_USER + 61
TB_GETOBJECT            = $WM_USER + 62
TB_SETBUTTONINFO        = $WM_USER + 64
TB_GETHOTITEM           = $WM_USER + 71
TB_SETHOTITEM           = $WM_USER + 72
TB_SETANCHORHIGHLIGHT   = $WM_USER + 73
TB_GETANCHORHIGHLIGHT   = $WM_USER + 74
TB_MAPACCELERATOR       = $WM_USER + 90
TB_GETINSERTMARK        = $WM_USER + 79
TB_SETINSERTMARK        = $WM_USER + 80
TB_INSERTMARKHITTEST    = $WM_USER + 81
TB_MOVEBUTTON           = $WM_USER + 82
TB_GETMAXSIZE           = $WM_USER + 83
TB_SETEXTENDEDSTYLE     = $WM_USER + 84
TB_GETEXTENDEDSTYLE     = $WM_USER + 85
TB_GETPADDING           = $WM_USER + 86
TB_SETPADDING           = $WM_USER + 87
TB_SETINSERTMARKCOLOR   = $WM_USER + 88
TB_GETINSERTMARKCOLOR   = $WM_USER + 89

TBSTATE_CHECKED         = 0x01
TBSTATE_PRESSED         = 0x02
TBSTATE_ENABLED         = 0x04
TBSTATE_HIDDEN          = 0x08
TBSTATE_INDETERMINATE   = 0x10
TBSTATE_WRAP            = 0x20
TBSTATE_ELLIPSES        = 0x40
TBSTATE_MARKED          = 0x80

TBSTYLE_BUTTON          = 0x0000  // obsolete use BTN
TBSTYLE_SEP             = 0x0001  // obsolete use BTN
TBSTYLE_CHECK           = 0x0002  // obsolete use BTN
TBSTYLE_GROUP           = 0x0004  // obsolete use BTN
//TBSTYLE_CHECKGROUP      (TBSTYLE_GROUP | TBSTYLE_CHE
TBSTYLE_DROPDOWN        = 0x0008  // obsolete use BTN
TBSTYLE_AUTOSIZE        = 0x0010  // obsolete use BTN
TBSTYLE_NOPREFIX        = 0x0020  // obsolete use BTN


TBSTYLE_TOOLTIPS        = 0x0100
TBSTYLE_WRAPABLE        = 0x0200
TBSTYLE_ALTDRAG         = 0x0400
TBSTYLE_FLAT            = 0x0800
TBSTYLE_LIST            = 0x1000
TBSTYLE_CUSTOMERASE     = 0x2000

TBSTYLE_REGISTERDROP    = 0x4000
TBSTYLE_TRANSPARENT     = 0x8000
TBSTYLE_EX_DRAWDDARROWS = 0x00000001


BTNS_SHOWTEXT   = 0x0040              // ignored unles
BTNS_WHOLEDROPDOWN  = 0x0080          // draw drop-dow
TBSTYLE_EX_MIXEDBUTTONS             = 0x00000008
TBSTYLE_EX_HIDECLIPPEDBUTTONS       = 0x00000010  // d

TBSTYLE_EX_DOUBLEBUFFER             = 0x00000080 // Do

TBIF_IMAGE              = 0x00000001
TBIF_TEXT               = 0x00000002
TBIF_STATE              = 0x00000004
TBIF_STYLE              = 0x00000008
TBIF_LPARAM             = 0x00000010
TBIF_COMMAND            = 0x00000020
TBIF_SIZE               = 0x00000040
TBIF_BYINDEX            = 0x80000000


NM_OUTOFMEMORY          = -1
NM_CLICK                = -2 
NM_DBLCLK               = -3
NM_RETURN               = -4
NM_RCLICK               = -5 
NM_RDBLCLK              = -6
NM_SETFOCUS             = -7
NM_KILLFOCUS            = -8
NM_CUSTOMDRAW           = -12
NM_HOVER                = -13
NM_NCHITTEST            = -14
NM_KEYDOWN              = -15
NM_RELEASEDCAPTURE      = -16
NM_SETCURSOR            = -17
NM_CHAR                 = -18
NM_LDOWN                = -20
NM_RDOWN                = -21
NM_THEMECHANGED         = -22



TBN_FIRST               = -700
TBN_GETBUTTONINFOW      = $TBN_FIRST - 20
TBN_BEGINDRAG           = $TBN_FIRST - 1 
TBN_ENDDRAG             = $TBN_FIRST - 2
TBN_BEGINADJUST         = $TBN_FIRST - 3
TBN_ENDADJUST           = $TBN_FIRST - 4
TBN_RESET               = $TBN_FIRST - 5
TBN_QUERYINSERT         = $TBN_FIRST - 6
TBN_QUERYDELETE         = $TBN_FIRST - 7
TBN_TOOLBARCHANGE       = $TBN_FIRST - 8
TBN_CUSTHELP            = $TBN_FIRST - 9
TBN_DROPDOWN            = $TBN_FIRST - 10
TBN_GETOBJECT           = $TBN_FIRST - 12
TBN_HOTITEMCHANGE       = $TBN_FIRST - 13
TBN_DRAGOUT             = $TBN_FIRST - 14
TBN_DELETINGBUTTON      = $TBN_FIRST - 15
TBN_GETDISPINFOW        = $TBN_FIRST - 17
TBN_GETINFOTIPW         = $TBN_FIRST - 19
}

//ToolTip
type TOOLINFO{
    uint      cbSize 
    uint      uFlags 
    uint      hwnd 
    uint      uId 
    RECT      rect 
    uint      hinst 
    uint      lpszText
    uint      lParam
} 

type NMTTDISPINFO {
    NMHDR      hdr
    uint       lpszText
    reserved   szText[ 80 * 2 ]
    uint       hinst
    uint       uFlags
    uint       lParam
}

define {
TTM_ACTIVATE            = $WM_USER + 1
TTM_SETDELAYTIME        = $WM_USER + 3
TTM_ADDTOOL             = $WM_USER + 50
TTM_DELTOOL             = $WM_USER + 51
TTM_NEWTOOLRECT         = $WM_USER + 52
TTM_RELAYEVENT          = $WM_USER + 7
TTM_GETTOOLINFO         = $WM_USER + 53
TTM_SETTOOLINFO         = $WM_USER + 54
TTM_HITTEST             = $WM_USER +55
TTM_GETTEXT             = $WM_USER +56
TTM_UPDATETIPTEXT       = $WM_USER +57
TTM_GETTOOLCOUNT        = $WM_USER +13
TTM_ENUMTOOLS           = $WM_USER +58
TTM_GETCURRENTTOOL      = $WM_USER + 59
TTM_WINDOWFROMPOINT     = $WM_USER + 16
TTM_TRACKACTIVATE       = $WM_USER + 17
TTM_TRACKPOSITION       = $WM_USER + 18
TTM_SETTIPBKCOLOR       = $WM_USER + 19
TTM_SETTIPTEXTCOLOR     = $WM_USER + 20
TTM_GETDELAYTIME        = $WM_USER + 21
TTM_GETTIPBKCOLOR       = $WM_USER + 22
TTM_GETTIPTEXTCOLOR     = $WM_USER + 23
TTM_SETMAXTIPWIDTH      = $WM_USER + 24
TTM_GETMAXTIPWIDTH      = $WM_USER + 25
TTM_SETMARGIN           = $WM_USER + 26
TTM_GETMARGIN           = $WM_USER + 27
TTM_POP                 = $WM_USER + 28
TTM_UPDATE              = $WM_USER + 29
TTM_GETBUBBLESIZE       = $WM_USER + 30
TTM_ADJUSTRECT          = $WM_USER + 31
TTM_SETTITLE            = $WM_USER + 33
TTM_POPUP               = $WM_USER + 34
TTM_GETTITLE            = $WM_USER + 35

TTF_IDISHWND            = 0x0001
TTF_CENTERTIP           = 0x0002
TTF_RTLREADING          = 0x0004
TTF_SUBCLASS            = 0x0010
TTF_TRACK               = 0x0020
TTF_ABSOLUTE            = 0x0080
TTF_TRANSPARENT         = 0x0100
TTF_PARSELINKS          = 0x1000
TTF_DI_SETITEM          = 0x8000


TTN_FIRST               =-520
TTN_GETDISPINFO         = $TTN_FIRST - 10
TTN_SHOW                = $TTN_FIRST - 1
TTN_POP                 = $TTN_FIRST - 2
TTN_LINKCLICK           = $TTN_FIRST - 3
}

type NMHEADER {
    NMHDR hdr
    int iItem
    int iButton
    uint pitem
}

type HD_HITTESTINFO {
    POINT pt
    uint flags
    int iItem
}

type HDITEM {
    uint    mask 
    int     cxy 
    uint    pszText 
    uint    hbm 
    int     cchTextMax 
    int     fmt 
    uint    lParam 
    int     iImage
    int     iOrder    
} 

define {
HDN_FIRST               = -300
HDN_ITEMCHANGINGW       = $HDN_FIRST - 20 
HDN_ITEMCHANGEDW        = $HDN_FIRST - 21 
HDN_ITEMCLICKW          = $HDN_FIRST - 22 
HDN_ITEMDBLCLICKW       = $HDN_FIRST - 23 
HDN_DIVIDERDBLCLICKW    = $HDN_FIRST - 25 
HDN_BEGINTRACKW         = $HDN_FIRST - 26 
HDN_ENDTRACKW           = $HDN_FIRST - 27 
HDN_TRACKW              = $HDN_FIRST - 28 
HDN_GETDISPINFOW        = $HDN_FIRST - 29
HDN_BEGINDRAG           = $HDN_FIRST - 10
HDN_ENDDRAG             = $HDN_FIRST - 11
HDN_FILTERCHANGE        = $HDN_FIRST - 12
HDN_FILTERBTNCLICK      = $HDN_FIRST - 13

HDM_FIRST    = 0x1200
HDM_HITTEST  = $HDM_FIRST + 6 
HDM_GETITEMW = $HDM_FIRST + 11

HDF_SORTUP    =   0x0400
HDF_SORTDOWN  =   0x0200

}

define {
CDRF_DODEFAULT        =  0x00000000
CDRF_NEWFONT          =  0x00000002
CDRF_SKIPDEFAULT      =  0x00000004
CDRF_NOTIFYPOSTPAINT  =  0x00000010
CDRF_NOTIFYITEMDRAW   =  0x00000020
CDRF_NOTIFYPOSTERASE  =  0x00000040

CDRF_NOTIFYSUBITEMDRAW  = 0x00000020

CDDS_PREPAINT        = 0x00000001
CDDS_POSTPAINT       = 0x00000002
CDDS_PREERASE        = 0x00000003
CDDS_POSTERASE       = 0x00000004
CDDS_ITEM            = 0x00010000
CDDS_ITEMPREPAINT    = ($CDDS_ITEM | $CDDS_PREPAINT)
CDDS_ITEMPOSTPAINT   = ($CDDS_ITEM | $CDDS_POSTPAINT)
CDDS_ITEMPREERASE    = ($CDDS_ITEM | $CDDS_PREERASE)
CDDS_ITEMPOSTERASE   = ($CDDS_ITEM | $CDDS_POSTERASE)
CDDS_SUBITEM         = 0x00020000

CDIS_SELECTED       = 0x0001
CDIS_GRAYED         = 0x0002
CDIS_DISABLED       = 0x0004
CDIS_CHECKED        = 0x0008
CDIS_FOCUS          = 0x0010

}

type NMCUSTOMDRAW {
    NMHDR hdr
    uint dwDrawStage
    uint hdc
    RECT rc
    uint dwItemSpec
    uint uItemState
    uint lItemlParam
} 

type NMTVCUSTOMDRAW {
    NMCUSTOMDRAW nmcd
    uint clrText
    uint clrTextBk
} 

type NMLVCUSTOMDRAW {
    NMCUSTOMDRAW nmcd
    uint clrText
    uint clrTextBk
    int iSubItem
}



//DateTimePicker
define {
DTS_UPDOWN          = 0x0001 
DTS_SHOWNONE        = 0x0002 
DTS_SHORTDATEFORMAT = 0x0000 
DTS_LONGDATEFORMAT  = 0x0004 
DTS_SHORTDATECENTURYFORMAT = 0x000C
DTS_TIMEFORMAT      = 0x0009 
DTS_APPCANPARSE     = 0x0010 
DTS_RIGHTALIGN      = 0x0020

DTN_FIRST           = -760
DTN_DATETIMECHANGE  = $DTN_FIRST + 1  

DTM_FIRST           = 0x1000
DTM_GETSYSTEMTIME   = $DTM_FIRST + 1
DTM_SETSYSTEMTIME   = $DTM_FIRST + 2
DTM_GETRANGE        = $DTM_FIRST + 3
DTM_SETRANGE        = $DTM_FIRST + 4
DTM_SETFORMATW      = $DTM_FIRST + 50


}

//ProgressBar
define {
PBS_SMOOTH          = 0x01
PBS_VERTICAL        = 0x04

PBM_SETRANGE     =  ($WM_USER+1)
PBM_SETPOS       =  ($WM_USER+2)
PBM_DELTAPOS     =  ($WM_USER+3)
PBM_SETSTEP      =  ($WM_USER+4)
PBM_STEPIT       =  ($WM_USER+5)
PBM_SETRANGE32   =  ($WM_USER+6)
}