/******************************************************************************
*
* Copyright (C) 2004-2007, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vis.dialogs 19.09.07 0.0.A.
*
* Author: Alexander Krivonogov ( gentee )
*
******************************************************************************/


/* Компонента vOpenDialog, порождена от vComp
*/

type vOpenSaveDialog <inherit = vComp> {
//Hidden Fields   
   ustr         pDefExt
   ustr         pInitialDir
   ustr         pFileName
   locustr      pTitleOpen
   locustr      pTitleSave      
   uint         pFilterIndex
   locustr      pFiltersText
   uint         pMultiSelect
   
//Public Fields   
   arrustr      Filters
   arrustr      Files
}

define 
{
   osfMultiSelect = 0x01
//   osfENABLESIZING
}

define
{
   OSD_BUFSIZE = 4096 //Размер буфера для получения имен файлов
}

method uint vComp.GetActiveHWND()
{ 
   uint hwnd
   if &.Owner 
   {    
      hwnd = .Owner->vCtrl.GetMainForm()->vCtrl.hwnd         
      if !IsWindowEnabled( hwnd )
      { 
         hwnd = 0     
      }         
   }
   if !hwnd : hwnd = GetActiveWindow()
   return hwnd
}

/*------------------------------------------------------------------------------
   Hidden Methods
*/
method vOpenSaveDialog.iUpdateFilters()
{
   /*uint filtertext = .pFiltersText.Text( this )
   if */
   .Filters.load( .pFiltersText.Text( this ), 0 )
}

/*Вывод диалогового окна для открытия сохранения и открытия файла*/
method uint vOpenSaveDialog.Show( uint flgsave )
{
   OPENFILENAME pOFN
   ustr files   
   buf  bfilters
   files.reserve( $OSD_BUFSIZE )
   if flgsave 
   {
      files =  .pFileName
   } 
   files.use = $OSD_BUFSIZE
   with pOFN
   {      
      .lStructSize = sizeof( OPENFILENAME )
      .lpstrDefExt = this.pDefExt.ptr()
      .lpstrInitialDir = this.pInitialDir.ptr()   
      .lpstrFile = files.ptr()
      
      ustr title
      if flgsave : title = .pTitleSave.Text( this )
      else : title = .pTitleOpen.Text( this )
      if *title : .lpstrTitle = title.ptr()
      
      .nMaxFile = $OSD_BUFSIZE      
      .hwndOwner = .GetActiveHWND()
      .Flags = $OFN_EXPLORER | $OFN_HIDEREADONLY | ?( flgsave, $OFN_OVERWRITEPROMPT, $OFN_FILEMUSTEXIST | $OFN_PATHMUSTEXIST ) | ?( this.pMultiSelect, $OFN_ALLOWMULTISELECT, 0 )
      if *.Filters
      {         
         arrustr arpair         
         foreach pair, .Filters
         {
            pair.split( arpair, '\', 0 )
            if *arpair == 1
            {
               bfilters@arpair[0]
               bfilters@'\h2 0'      
            }
            elif *arpair > 1
            {          
               bfilters@arpair[0]@arpair[1]                  
            }                         
         }
         bfilters@'\h2 0'                  
         .lpstrFilter = bfilters.ptr()
         .nFilterIndex = .pFilterIndex
      }
   }
   uint res = ?( flgsave, GetSaveFileName( pOFN ), GetOpenFileName( pOFN ) )   
   if res
   {
      .Files.clear()  
      if !flgsave & this.pMultiSelect 
      {
         uint start = 0
         while ( files.ptr() + ( start << 1) )->ushort
         {            
               start = files.findsh( start, 0 ) + 1
         }
         files.use = start << 1
         files.getmultiustr( .Files )         
         if *.Files > 1
         {
            ustr dir = .Files[0]            
            
            if dir[*dir-1] != '\'
            {
               dir = dir + "\\".ustr()
            }            
            .Files.del( 0 )                        
            foreach x, .Files
            {
               x = dir + x 
            }   
         }         
      }
      else
      {
         files.setlenptr()         
         .Files.expand(1)
         .Files[0] = files
      }
      
      .pInitialDir = files.str().fgetdir("").ustr()
      .pFileName = .Files[0]  
   }
   return res
}

/*------------------------------------------------------------------------------
   Public Methods
*/
/*Вывод диалогового окна для открытия файла*/
method uint vOpenSaveDialog.ShowOpenFile()
{  
   return this.Show( 0 )
}

/*Вывод диалогового окна для сохранения файла*/
method uint vOpenSaveDialog.ShowSaveFile()
{
   return this.Show( 1 )
}

/*------------------------------------------------------------------------------
   Properties
*/

/* Свойство uint DefExt - Get Set
Усотанавливает или определяет расширение по умолчанию
*/
property ustr vOpenSaveDialog.DefExt<result>() 
{
   result = .pDefExt  
}

property vOpenSaveDialog.DefExt( ustr val )
{
   if .pDefExt != val
   {
      .pDefExt = val
   }
}

/* Свойство uint InitialDir - Get Set
Усотанавливает или определяет начальную директорию
*/
property ustr vOpenSaveDialog.InitialDir<result>()
{
   result = .pInitialDir  
}

property vOpenSaveDialog.InitialDir( ustr val )
{
   if .pInitialDir != val
   {
      .pInitialDir = val
   }
}


/* Свойство uint InitialDir - Get Set
Усотанавливает или определяет имя выбранного файла
*/
property ustr vOpenSaveDialog.FileName<result>()
{
   result = .pFileName  
}

property vOpenSaveDialog.FileName( ustr val )
{
   if .pFileName != val
   {
      .pFileName = val
   }
}

/* Свойство uint Options - Get Set
Усотанавливает или определяет настройки
*/
property uint vOpenSaveDialog.MultiSelect()
{
   return .pMultiSelect
}

property vOpenSaveDialog.MultiSelect( uint val )
{
   if .pMultiSelect != val
   {
      .pMultiSelect = val
   }
}

/* Свойство uint FilterIndex - Get Set
Усотанавливает или определяет текущий индекс фильтра
*/
property uint vOpenSaveDialog.FilterIndex()
{
   return .pFilterIndex
}

property vOpenSaveDialog.FilterIndex( uint val )
{
   if .pFilterIndex != val
   {
      .pFilterIndex = min( val, *.Filters  )
   }
}

/* Свойство uint TitleOpen - Get Set
Усотанавливает или определяет заголовок окна открытия файла
*/
property ustr vOpenSaveDialog.TitleOpen <result>
{
   result = this.pTitleOpen.Value
}

property vOpenSaveDialog.TitleOpen( ustr val )
{   
   this.pTitleOpen.Value = val       
}

/* Свойство uint TitleSave - Get Set
Усотанавливает или определяет заголовок окна сохранения файла
*/
property ustr vOpenSaveDialog.TitleSave <result>
{
   result = this.pTitleSave.Value
}

property vOpenSaveDialog.TitleSave( ustr val )
{   
   this.pTitleSave.Value = val       
}

/* Свойство uint FiltersText - Get Set
Усотанавливает или определяет заголовок окна сохранения файла
*/
property ustr vOpenSaveDialog.FiltersText <result>
{
   result = this.pFiltersText.Value
}

property vOpenSaveDialog.FiltersText( ustr val )
{   
   if this.pFiltersText.Value != val
   { 
      this.pFiltersText.Value = val
      .iUpdateFilters()      
   }       
}


/*Виртуальный метод uint vOpenSaveDialog.mLangChanged - Изменение текущего языка
*/
method vOpenSaveDialog.mLangChanged <alias=vOpenSaveDialog_mLangChanged>()
{
   if *this.pFiltersText.Value : .iUpdateFilters()
   this->vComp.mLangChanged() 
}


/* Компонента vOpenDialog, порождена от vComp
*/

type vSelectDir <inherit = vComp> {
//Hidden Fields   
/*   ustr         pDefExt
   ustr         pInitialDir
   ustr         pFileName*/
   ustr         pDir
   locustr      pTitle   
   uint         pCanCreate
   uint         pShowEdit   
}


//--------------------------------------------------------------------------



type BROWSEINFO {
    uint hwndOwner
    uint pidlRoot
    uint pszDisplayName
    uint lpszTitle
    uint ulFlags
    uint lpfn
    uint lParam
    int iImage
} 

import "ole32.dll" {
uint CoTaskMemAlloc( uint )
CoTaskMemFree( uint )
uint CoInitializeEx( uint, uint )
uint CoInitialize(uint)
}

import "shell32.dll" {
uint SHGetSpecialFolderLocationW( uint, int, uint ) -> SHGetSpecialFolderLocationW   
uint SHGetPathFromIDListW( uint, uint ) -> SHGetPathFromIDList
uint SHBrowseForFolderW( BROWSEINFO ) -> SHBrowseForFolder
}

define {
   BIF_RETURNONLYFSDIRS  = 0x0001
   BIF_EDITBOX           = 0x0010   
   BIF_NEWDIALOGSTYLE    = 0x0040
   BIF_NONEWFOLDERBUTTON = 0x0200 
   
   BFFM_INITIALIZED     = 1
   
   BFFM_SETSELECTION    = $WM_USER + 103 //BFFM_SETSELECTIONW
}

global {
   uint AddrBrowseCallbackProc
}


/*------------------------------------------------------------------------------
   Properties
*/

/* Свойство ustr Title - Get Set
Усотанавливает или определяет заголовок над списком директорий
*/
property ustr vSelectDir.Title<result>() 
{
   result = .pTitle  
}

property vSelectDir.Title( ustr val )
{
   if .pTitle != val
   {
      .pTitle = val
   }
}

/* Свойство ustr Dir - Get Set
Усотанавливает или определяет текущую выбранную директорию
*/
property ustr vSelectDir.Dir<result>() 
{
   result = .pDir  
}

property vSelectDir.Dir( ustr val )
{
   if .pDir != val
   {
      .pDir = val
   }
}

/* Свойство ustr C - Get Set
Усотанавливает или определяет возможность создания директорий
*/
property uint vSelectDir.CanCreate() 
{
   return .pCanCreate   
}

property vSelectDir.CanCreate( uint val )
{
   if .pCanCreate != val
   {
      .pCanCreate = val
   }
}

/* Свойство ustr C - Get Set
Усотанавливает или определяет показ Edit с текущей директорией
*/
property uint vSelectDir.ShowEdit() 
{
   return .pShowEdit 
}

property vSelectDir.ShowEdit( uint val )
{
   if .pShowEdit != val
   {
      .pShowEdit = val
   }
}


func int BrowseCallbackProc( uint hwnd uMsg lParam lpData ) 
{ 
   if uMsg == $BFFM_INITIALIZED && lpData 
   { 
       SendMessage( hwnd, $BFFM_SETSELECTION, 1, lpData->ustr.ptr() ) 
   } 
   return 0
}

method uint vSelectDir.Show( )
{
 //  int   nidl
   uint  result   
   BROWSEINFO    bi
   uint  lpidl
   uint  pidlRoot = 0

   /*if( nidl )
   {
      SHGetSpecialFolderLocation( owner, nidl, &pidlRoot)
   }*/   
   
   if ( *.pDir )
   {
      bi.lpfn = AddrBrowseCallbackProc 
      bi.lParam = &.pDir
   }
      
   bi.hwndOwner = .GetActiveHWND()
   
   bi.pidlRoot = pidlRoot
   bi.pszDisplayName = 0//"dir".ptr()
   bi.lpszTitle = this.pTitle.Text( this ).ptr()
   bi.ulFlags = $BIF_RETURNONLYFSDIRS | $BIF_NEWDIALOGSTYLE 
   if .pShowEdit : bi.ulFlags |= $BIF_EDITBOX
   if !.pCanCreate : bi.ulFlags |= $BIF_NONEWFOLDERBUTTON 
   //CoInitialize(0)  
   lpidl = SHBrowseForFolder( bi )
   if ( lpidl )
   {
      .pDir.reserve( 260 )
      SHGetPathFromIDList( lpidl, .pDir.ptr() )                
      .pDir.setlenptr()      
      CoTaskMemFree( lpidl )
      result = 1
   }
   else
   {
      .pDir.clear()
   }
   /*
   if(pidlRoot)
   {      
      CoTaskMemFree( pidlRoot )
   }
*/
   return result
}



/* Компонента vColorDialog, порождена от vComp
*/

type vColorDialog <inherit = vComp> {
//Hidden Fields
   uint         pColor     
   arr          CustColors[16] of uint
   uint         pFullOpen
   uint         pPreventFullOpen
   uint         pSolidColor
   uint         pAnyColor
}

/*------------------------------------------------------------------------------
   Properties
*/

/* Свойство uint Color - Get Set
Устанавливает или определяет выбранный цвет
*/
property uint vColorDialog.Color() 
{
   return .pColor
}

property vColorDialog.Color( uint val )
{
   if .pColor != val
   {
      .pColor = val
   }
}

/* Свойство uint AnyColor - Get Set
Устанавливает или определяет выбор любого цвета
*/
property uint vColorDialog.AnyColor() 
{
   return .pAnyColor
}

property vColorDialog.AnyColor( uint val )
{
   if .pAnyColor != val
   {
      .pAnyColor = val
   }
}

/* Свойство uint SolidColor - Get Set
Устанавливает или определяет выбор заполненого цвета
*/
property uint vColorDialog.SolidColor() 
{
   return .pSolidColor
}

property vColorDialog.SolidColor( uint val )
{
   if .pSolidColor != val
   {
      .pSolidColor = val
   }
}

/* Свойство ustr FullOpen - Get Set
Устанавливает или определяет режим полного просмотра
*/
property uint vColorDialog.FullOpen() 
{
   return .pFullOpen
}

property vColorDialog.FullOpen( uint val )
{
   if .pFullOpen != val
   {
      .pFullOpen = val
   }
}

/* Свойство ustr PreventFullOpen - Get Set
Устанавливает или определяет режим полного просмотра
*/
property uint vColorDialog.PreventFullOpen() 
{
   return .pPreventFullOpen
}

property vColorDialog.PreventFullOpen( uint val )
{
   if .pPreventFullOpen != val
   {
      .pPreventFullOpen = val
   }
}

func uint rgb_bgr( uint src )
{
   return ( (src & 0xFF ) << 16 ) | ( src & 0xFF00 ) | ( ( src & 0xFF0000 ) >> 16 )
}
/*Вывод диалогового окна для выбора цвета*/
method uint vColorDialog.Show( )
{   
   CHOOSECOLOR chc
   arr         tmpcolors[16] of uint
   tmpcolors = .CustColors
   
   chc.lStructSize = sizeof( CHOOSECOLOR )
   /*if &.Owner
   {         
      chc.hwndOwner = .Owner->vCtrl.GetMainForm()->vCtrl.hwnd         
   }*/
   chc.hwndOwner = .GetActiveHWND()
   chc.rgbResult = rgb_bgr( .pColor ) 
   chc.lpCustColors = tmpcolors.ptr()
   chc.Flags = $CC_RGBINIT
   if .pAnyColor : chc.Flags |= $CC_ANYCOLOR
   if .pSolidColor : chc.Flags |= $CC_SOLIDCOLOR
   if .pFullOpen : chc.Flags |= $CC_FULLOPEN
   if .pPreventFullOpen : chc.Flags |= $CC_PREVENTFULLOPEN
   if ChooseColor( chc )
   {  
      .CustColors = tmpcolors
      .pColor = rgb_bgr( chc.rgbResult )
      return 1
   }
   return 0
}


/* Компонента vFontDialog, порождена от vComp
*/

type vFontDialog <inherit = vComp> {
//Hidden Fields
   LOGFONT  LogFont
   uint     pDevice
   uint     pSizeMin
   uint     pSizeMax   
   uint     pEffects
   uint     pColor     
   
}

define {
   fddScreen = $CF_SCREENFONTS
   fddPrinter = $CF_PRINTERFONTS
   fddBoth = $CF_BOTH
}

operator LOGFONT =( LOGFONT left right )
{
   mcopy( &left, &right, sizeof( LOGFONT ))
   return left
}
/*------------------------------------------------------------------------------
   Properties
*/

/* Свойство uint SizeMin - Get Set
Устанавливает или определяет минимальный возможный размер
*/
property uint vFontDialog.SizeMin() 
{
   return .pSizeMin
}

property vFontDialog.SizeMin( uint val )
{
   if .pSizeMin != val
   {
      .pSizeMin = val
   }
}

/* Свойство uint SizeMax - Get Set
Устанавливает или определяет максимальный возможный размер
*/
property uint vFontDialog.SizeMax() 
{
   return .pSizeMax
}

property vFontDialog.SizeMax( uint val )
{
   if .pSizeMax != val
   {
      .pSizeMax = val
   }
}

/* Свойство uint Device - Get Set
Устанавливает или определяет максимальный возможный размер
*/
property uint vFontDialog.Device() 
{
   return .pDevice
}

property vFontDialog.Device( uint val )
{
   if .pDevice != val
   {
      .pDevice = val
   }
}

/* Свойство uint Effects - Get Set
Устанавливает или определяет возможность эффектов
*/
property uint vFontDialog.Effects() 
{
   return .pEffects
}

property vFontDialog.Effects( uint val )
{
   if .pEffects != val
   {
      .pEffects = val
   }
}


/* Свойство uint Color - Get Set
Устанавливает или определяет цвет шрифта
*/
property uint vFontDialog.Color() 
{
   return .pColor
}

property vFontDialog.Color( uint val )
{
   if .pColor != val
   {
      .pColor = val
   }
}

/*Вывод диалогового окна для выбора цвета*/
method uint vFontDialog.Show( )
{   
   CHOOSEFONT chf
   LOGFONT    tmplogfont
   
   tmplogfont = .LogFont
   
   chf.lStructSize = sizeof( CHOOSEFONT )
   chf.Flags = .pDevice | $CF_INITTOLOGFONTSTRUCT
   if .pEffects : chf.Flags |= $CF_EFFECTS
   chf.nSizeMin = .pSizeMin
   chf.nSizeMax = .pSizeMax
   chf.lpLogFont = &tmplogfont   
   chf.hwndOwner = .GetActiveHWND()
   chf.rgbColors = .pColor
   if ChooseFont( chf )
   {  
      .LogFont = tmplogfont
      .pColor = chf.rgbColors
      return 1
   }   
   return 0
}
 
/* Компонента vCalendar, порождена от vComp
*/

type vCalendar <inherit = vCtrl> {
//Hidden Fields
   uint     pPopupCtrl   
   datetime dt
   uint     flgClickIn
//Events       
   evEvent OnChange   
}


define {
MCS_DAYSTATE       = 0x0001

MCM_FIRST          = 0x1000
MCM_GETCURSEL      = ($MCM_FIRST + 1)
MCM_SETCURSEL      = ($MCM_FIRST + 2)
MCM_GETMAXSELCOUNT = ($MCM_FIRST + 3)
MCM_SETMAXSELCOUNT = ($MCM_FIRST + 4)
MCM_GETSELRANGE    = ($MCM_FIRST + 5)
MCM_SETSELRANGE    = ($MCM_FIRST + 6)
MCM_GETMONTHRANGE  = ($MCM_FIRST + 7)
MCM_SETDAYSTATE    = ($MCM_FIRST + 8)
MCM_GETMINREQRECT  = ($MCM_FIRST + 9)
MCM_SETCOLOR       = ($MCM_FIRST + 10)
MCM_GETCOLOR       = ($MCM_FIRST + 11)
 
MCN_FIRST          = 0-750
MCN_SELCHANGE      = ($MCN_FIRST + 1)
MCN_GETDAYSTATE    = ($MCN_FIRST + 3)
MCN_SELECT         = ($MCN_FIRST + 4)
  
}

type NMSELCHANGE <inherit=NMHDR>{
    datetime      stSelStart
    datetime      stSelEnd
}


/*------------------------------------------------------------------------------
   Properties
*/

property vCalendar.Date( datetime dt )
{
   if dt != .dt
   {
      .dt = dt
      .WinMsg( $MCM_SETCURSEL, 0, &dt )
   }     
}

property datetime vCalendar.Date <result>
{   
   result = .dt     
}


/* Свойство uint PopupCtrl - Get
*/
property vCtrl vCalendar.PopupCtrl()
{
   return this.pPopupCtrl->vCtrl
}


/*------------------------------------------------------------------------------
   Virtual methods
*/
method vCalendar vCalendar.mCreateWin <alias=vCalendar_mCreateWin>()
{
   uint style = $WS_BORDER | $WS_POPUP //| $WS_CHILD | $WS_VISIBLE | $MCS_DAYSTATE
   .CreateWin( "SysMonthCal32".ustr(), 0, style )   
   this->vCtrl.mCreateWin()
   RECT r
   .WinMsg( $MCM_GETMINREQRECT, 0, &r )
   .Width = r.right
   .Height = r.bottom
   return this
}

method vCalendar vCalendar.mOwnerCreateWin <alias=vCalendar_mOwnerCreateWin>()
{
   .Virtual( $mReCreateWin )
   return this
}

method vCalendar vCalendar.mSetOwner <alias=vCalendar_mSetOwner>( vComp newowner )
{
   .Virtual( $mReCreateWin )
   return this
}

method uint vCalendar.mWinNtf <alias=vCalendar_mWinNtf>( winmsg wmsg )
{
   uint nmtv as wmsg.lpar->NMHDR
   switch nmtv.code
   {
      case $MCN_SELCHANGE
      {
         .dt = wmsg.lpar->NMSELCHANGE.stSelStart
      }
      case $MCN_SELECT
      {
         .dt = wmsg.lpar->NMSELCHANGE.stSelStart
         .Visible = 0
         .flgClickIn = 0
         ReleaseCapture()
         .OnChange.Run( this )
         
      }
      case $NM_RELEASEDCAPTURE
      {  
//         print( "RELEASECAPTURE \(nmtv.hwndFrom) \(nmtv.idFrom)\n")
         if .flgClickIn
         {
            .flgClickIn = 0
            SetCapture(.hwnd)
         }   
      }       
   }
   return 0
}

method uint vCalendar.mKey <alias=vCalendar_mKey>( evparKey evk )
{  
   if evk.evktype == $evkDown 
   {
      if evk.key == $VK_RETURN
      {
         .Visible = 0
         .flgClickIn = 0
         ReleaseCapture()
         .OnChange.Run( this )
      }
      else
      {
         .Visible = 0
         .flgClickIn = 0
         ReleaseCapture()  
      }
   }
   return 0  
}  

/*
method uint vCalendar.wmcapturechange <alias=vCalendar_wmcapturechanged>( winmsg wmsg )
{   
   if wmsg.lpar != .hwnd  
   {
      print( "calcapt \(wmsg.wpar) \(wmsg.lpar)\n")
      
      //.Visible = 0  
   } 
   return 0
}*/


method uint vCalendar.wmMouse <alias=vCalendar_wmMouse>( winmsg wmsg )
{  
   POINT pt
   pt.x = int( ( &wmsg.lpar )->short )
   pt.y = int( ( &wmsg.lpar + 2 )->short )
   RECT r
   GetClientRect( .hwnd, r )
   if !PtInRect( r, pt.x, pt.y ) 
   {
      ReleaseCapture()
      .Visible = 0
      .flgClickIn = 0
   }
   else
   {
      .flgClickIn = 1         
   }
   return 0
}

/*
method vCalendar.SetDate( datetime dt )
{
   print( "setcur \(.WinMsg( $MCM_SETCURSEL, 0, &dt ))\n" )     
}*/

method vCalendar.Show( vCtrl ctrl, datetime dt )
{
   .pPopupCtrl = &ctrl
   //.FormStyle = $fsPopup
   .Owner = ctrl.GetForm()->vCtrl    
   RECT r, r1   
   GetWindowRect( ctrl.hwnd, r )
   .Date = dt
   //.Left = min( GetSystemMetrics(0) - .Width, r.right )
   //.Top =  min( GetSystemMetrics(1) - .Height, r.top )
   eventpos ep
   this.loc.left = min( GetSystemMetrics(0) - .Width, r.right )
   this.loc.top = min( GetSystemMetrics(1) - .Height, r.top )
   ep.loc = this.loc   
   ep.move = 1
   ep.code = $e_poschanging      
   .Virtual( $mPosChanging, ep )
   
   .Visible = 1
   .SetFocus()
   SetCapture(.hwnd)
}


/*------------------------------------------------------------------------------
   Registration
*/
method vOpenSaveDialog vOpenSaveDialog.init( )
{
   this.pTypeId = vOpenSaveDialog   
   return this 
}

method vSelectDir vSelectDir.init( )
{
   this.pTypeId = vSelectDir 
   this.pCanCreate = 1  
   return this 
}

method vColorDialog vColorDialog.init( )
{ 
   this.pTypeId = vColorDialog     
   return this 
}

method vFontDialog vFontDialog.init( )
{ 
   this.pTypeId = vFontDialog  
   .pDevice = $fddScreen  
   .pEffects = 1
   return this 
}

method vCalendar vCalendar.init( )
{  
   this.pTypeId = vCalendar
   this.pTabStop = 1
   this.pCanFocus = 1   
   this.pVisible = 0
   return this 
}  

func init_vOpenSaveDialog <entry>()
{
   regcomp( vOpenSaveDialog, "vOpenSaveDialog", vComp, $vComp_last,      
      %{ %{$mLangChanged,  vOpenSaveDialog_mLangChanged } },
      0->collection )

   regcomp( vSelectDir, "vSelectDir", vComp, $vComp_last,      
      0->collection,
      0->collection )
      
   regcomp( vColorDialog, "vColorDialog", vComp, $vComp_last,      
      0->collection,
      0->collection )
                                    
   regcomp( vFontDialog, "vFontDialog", vComp, $vComp_last,      
      0->collection,
      0->collection )                                    
   
   //CoInitializeEx(0,0) 
   AddrBrowseCallbackProc = callback( &BrowseCallbackProc, 4 )
   
    regcomp( vCalendar, "vCalendar", vCtrl, $vCtrl_last, 
      %{ %{ $mCreateWin,    vCalendar_mCreateWin },
         %{ $mWinNtf,       vCalendar_mWinNtf },
         %{ $mSetOwner,     vCalendar_mSetOwner },
         %{$mOwnerCreateWin, vCalendar_mOwnerCreateWin },
         %{$mKey, vCalendar_mKey}
       },
      %{ 
         %{ $WM_LBUTTONDOWN, vCalendar_wmMouse },
         %{ $WM_RBUTTONDOWN, vCalendar_wmMouse }} )
            
             
ifdef $DESIGNING {
   
   cm.AddComp( vOpenSaveDialog, 1, "Windows", "dialogs" )   
   
   cm.AddProps( vOpenSaveDialog, %{
"DefExt",      ustr, 0,
"FileName",    ustr, 0,
"InitialDir",  ustr, 0,
"FilterIndex", uint, 0,
"FiltersText", ustr, 0,
"TitleOpen"  , ustr, 0,
"TitleSave"  , ustr, 0,
"MultiSelect", uint, 0
   })
   
    cm.AddComp( vSelectDir, 1, "Windows", "dialogs" )   
   
   cm.AddProps( vSelectDir, %{
"Title",     ustr, 0,
"Dir",       ustr, 0,
"CanCreate", uint, 0,
"ShowEdit",  uint, 0
   })
   
   cm.AddComp( vColorDialog, 1, "Windows", "dialogs" )
   cm.AddProps( vColorDialog, %{
"Color",     uint, 0,
"AnyColor",  uint, 0,
"SolidColor",uint, 0,
"FullOpen",  uint, 0,
"PreventFullOpen", uint, 0
   })
   
   cm.AddComp( vFontDialog, 1, "Windows", "dialogs" )
   cm.AddProps( vFontDialog, %{
"SizeMin",     uint, 0,
"SizeMax",  uint, 0,
"Effects",uint, 0,
"Color",  uint, 0
   })
   cm.AddComp( vCalendar, 1, "Windows", "dialogs" )
   cm.AddEvents( vCalendar, %{
"OnChange", "evparEvent"
   })            
}

         
                                                                                                  
}