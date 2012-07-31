/******************************************************************************
*
* Copyright (C) 2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: gentee 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov
*
* Summary: 
*
******************************************************************************/

#include "resource.h"
#include "windows.h"
#include "windowsx.h"
#include "commctrl.h"
#include "../../src/genteeapi/gentee.h"
#include "stdio.h"


#define DEF_STRING 256
#define MAX_STRING 1024

HINSTANCE hInst;
HINSTANCE gehandle = NULL;   // gentee.dll handle
HWND      hwTab;
HWND      hwCurItem;
HWND      hwItemTabs[2];
DWORD     threadid;
HANDLE    hthread;
char      szinitdir[_MAX_PATH];
char      szfilename[_MAX_PATH];
char      szmessage[MAX_STRING];
char      szprint[MAX_STRING];

DWORD     p_sztextcolor;
DWORD     p_bgcolor;
char      p_sztext[DEF_STRING];
BOOL      p_flg;

typedef int (__cdecl *CDECLPROC)();
FARPROC   ge_deinit;
FARPROC   ge_init; 
FARPROC   ge_compile;
FARPROC   ge_load;
FARPROC   ge_set;
CDECLPROC ge_call; 
CDECLPROC ge_getid;

void      shell_ge_deinit( void );
HINSTANCE shell_ge_init( PVOID messagef, PVOID printf, PVOID exportf );

void change_tab( DWORD n );

BOOL    CALLBACK main_dlgproc( HWND hDlg, UINT uMsg, WPARAM wParam, LPARAM lParam );
BOOL    CALLBACK tab_dlgproc ( HWND hDlg, UINT uMsg, WPARAM wParam, LPARAM lParam );
LRESULT CALLBACK panel_proc  ( HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam );

//--------------------------------------------------------------------------
 
int WINAPI WinMain( HINSTANCE hInstance,
                    HINSTANCE hPrevInstance,
                    LPSTR     lpCmdLine,
                    int       nCmdShow)
{ 	   
   WNDCLASS wc;
   hInst = hInstance;
   hwTab = 0;
   hwCurItem = 0;
   InitCommonControls();

   wc.style = wc.cbClsExtra = wc.cbWndExtra = 0;
   wc.lpfnWndProc = panel_proc;
   wc.hInstance = hInst;
   wc.hIcon = NULL;
   wc.hCursor = NULL;
   wc.hbrBackground = NULL;
   wc.lpszMenuName = NULL;
   wc.lpszClassName = "panelclass";
   RegisterClass( &wc );

   DialogBox(hInstance, MAKEINTRESOURCE( IDD_MAIN ), 0, main_dlgproc );   

	return 0;
}

//--------------------------------------------------------------------------
// You can call this function from the Gentee function
void CALLBACK c_func( DWORD textcolor, DWORD bgcolor, PCHAR text )
{     
   p_bgcolor = bgcolor;
   p_sztextcolor = textcolor;
   strcpy( p_sztext, text );
   p_flg = TRUE;
   InvalidateRect( GetDlgItem( hwItemTabs[1], IDC_PANEL ), NULL, FALSE );   
}

// Hook functions
//--------------------------------------------------------------------------
// Your function to sending address of c_func to Gentee virtual mashine
PVOID CALLBACK exporttogentee( PCHAR str )
{
   if ( !strcmp( str, "c_func" ) )
      return &c_func;
   return NULL;
}

//--------------------------------------------------------------------------

int CALLBACK message_f( pmsginfo minfo )
{
   char    out[DEF_STRING];
   pubyte  er;

   out[0] = 0;
   if ( minfo->flag & MSG_EXIT )
   {
      sprintf( out, "Error [ 0x%X %i ]: ", minfo->code, minfo->code ); 
      if ( minfo->line )
         sprintf( out + strlen( out ), "%s\r\n[ Line: %i Pos: %i ] ", 
                  minfo->filename, minfo->line, minfo->pos ); 
   }
   er = out + strlen( out );

   if ( minfo->flag & MSG_VALSTR )
      sprintf( er, minfo->pattern, minfo->uintpar, minfo->uintpar, minfo->namepar ); 
   else
      if ( minfo->flag & MSG_VALVAL )
         sprintf( er, minfo->pattern, minfo->uintpar, minfo->uintpar ); 
      else
         if ( minfo->flag & MSG_STR )
            sprintf( er, minfo->pattern, minfo->namepar ); 
         else
            if ( minfo->flag & MSG_VALUE )
               sprintf( er, minfo->pattern, minfo->uintpar ); 
            else
               sprintf( er, minfo->pattern );

   SetWindowText( GetDlgItem( hwItemTabs[0], IDC_EDITMESSAGE), out );
   return 0;
}

//--------------------------------------------------------------------------

void CALLBACK print_f( char* mes, uint len )
{
   strcat( szprint, mes );   
   SetWindowText( GetDlgItem( hwItemTabs[0], IDC_EDITPRINT), szprint );
}

uint CALLBACK getch_f( char* mes, uint len )
{
   if ( mes ) // scan
      return 0;   
   // getch
   MessageBox( hwTab, "Click on 'OK' button!", "getch", MB_OK | MB_ICONINFORMATION );
   return 13;
}

// Thread functions
//--------------------------------------------------------------------------

DWORD WINAPI thread_example( PVOID param )
{
   char nametext[DEF_STRING];
   char progtext[MAX_STRING];
   DWORD idfunc, res;
   
   GetWindowText( GetDlgItem( hwItemTabs[1], IDC_EDITSOURCE), progtext, MAX_STRING );
   if ( progtext[0] )
   {      
      szmessage[0] = 0;
      szprint[0] = 0;
      SetWindowText( GetDlgItem( hwItemTabs[0], IDC_EDITMESSAGE), szmessage );
      SetWindowText( GetDlgItem( hwItemTabs[0], IDC_EDITPRINT), szprint );
      FreeConsole();

      if ( shell_ge_init( NULL, NULL, &exporttogentee ))
      {                   
         compileinfo cmplinfo;

         cmplinfo.flag = CMPL_SRC;// | CMPL_NORUN;
         cmplinfo.input = progtext;
         cmplinfo.libdirs = "";
         cmplinfo.include = ""; 
         cmplinfo.defargs = ""; 
         cmplinfo.output = "";  
         ge_compile( &cmplinfo );

         idfunc = ge_getid( "gentee_func", GID_ANYOBJ );

         if ( idfunc )
         {
            GetWindowText( GetDlgItem( hwItemTabs[1], IDC_EDITNAME), nametext, DEF_STRING );
            ge_call( idfunc, &res, nametext );
         }
         else
            MessageBox( hwTab, 
                     "The function 'gentee_func' has not been found", "Error", MB_OK | MB_ICONHAND );
/*       {
            SendMessage( hwTab, TCM_SETCURSEL, 0, 0 );
            change_tab( 0 );
         }*/
         shell_ge_deinit();
      }
   }
   return TRUE;                      
}

//--------------------------------------------------------------------------

DWORD WINAPI thread_execute( PVOID param )
{
   char name[_MAX_PATH];
   PVOID message = NULL;
   PVOID print = NULL;   
   
   GetWindowText( GetDlgItem( hwItemTabs[0], IDC_EDITFILE), name, _MAX_PATH );
   if ( name[0] != (char)0 )
   {      
      szmessage[0] = 0;
      szprint[0] = 0;
      SetWindowText( GetDlgItem( hwItemTabs[0], IDC_EDITMESSAGE), szmessage );
      SetWindowText( GetDlgItem( hwItemTabs[0], IDC_EDITPRINT), szprint );
      if ( SendMessage( GetDlgItem( hwItemTabs[0], IDC_CHECKMESSAGE ), 
                        BM_GETCHECK, 0, 0 ) == BST_CHECKED )
         message = &message_f;
      else
         message = NULL;
      if ( SendMessage( GetDlgItem( hwItemTabs[0], IDC_CHECKPRINT ), 
                        BM_GETCHECK, 0, 0 ) == BST_CHECKED )
      {
         FreeConsole();
         print = &print_f;
      }
      else
         print = NULL;

      if ( shell_ge_init( message, print, NULL ) )
      {
         compileinfo cmplinfo;

         cmplinfo.flag = CMPL_LINE;
         cmplinfo.input = name;
         cmplinfo.libdirs = "";
         if ( SendMessage( GetDlgItem( hwItemTabs[0], IDC_CHECKSTDLIB ), 
                           BM_GETCHECK, 0, 0 ) == BST_CHECKED )
            cmplinfo.include = "..\\..\\exe\\lib\\stdlib.ge\0\0"; 
         else
            cmplinfo.include = ""; 
         cmplinfo.defargs = ""; 
         cmplinfo.output = "";  
         ge_compile( &cmplinfo );
         FreeConsole();
         shell_ge_deinit();
      }
   }
   return TRUE;                      
}

//Gentee shell functions
//--------------------------------------------------------------------------

HINSTANCE shell_ge_init( PVOID messagef,
                     PVOID printf, PVOID exportf )
{
   if ( !gehandle )
      gehandle = LoadLibrary("../../exe/gentee.dll");

   if ( gehandle )
   {
      ge_deinit     = GetProcAddress( gehandle, "gentee_deinit" );
      ge_init       = GetProcAddress( gehandle, "gentee_init" );
      ge_load       = GetProcAddress( gehandle, "gentee_load" );
      ge_compile    = GetProcAddress( gehandle, "gentee_compile" );
      ge_set        = GetProcAddress( gehandle, "gentee_set" );
      ge_getid      = ( CDECLPROC )GetProcAddress( gehandle, "gentee_getid" );
      ge_call       = ( CDECLPROC )GetProcAddress( gehandle, "gentee_call" );

      ge_init( G_CHARPRN | ( exportf || printf ? G_SILENT : 0 ));
      if ( messagef )
         ge_set( GSET_MESSAGE, messagef );
      if ( printf )
      {
         ge_set( GSET_PRINT, printf );
         ge_set( GSET_GETCH, getch_f );
      }
      if ( exportf )
         ge_set( GSET_EXPORT, exportf );
   }
   else
      MessageBox( hwTab, "Cannot find or load gentee.dll!", "Error", 
                  MB_OK | MB_ICONHAND );

   return gehandle;
}

//--------------------------------------------------------------------------

void shell_ge_deinit( void )
{
   ge_deinit();
   FreeLibrary( gehandle );
   gehandle = NULL;
}

//Interface functions
//--------------------------------------------------------------------------

void create_tabdialog( HWND hwOwner, PCHAR caption, DWORD id, DWORD num )
{
   TC_ITEM tci;
   RECT rt;

   tci.mask = TCIF_TEXT; 
   tci.iImage = -1; 
   tci.pszText = caption;    
   TabCtrl_InsertItem( hwOwner, num, &tci );
   GetClientRect( hwOwner, &rt );
   hwItemTabs[ num ] = CreateDialog( hInst, MAKEINTRESOURCE( id ), 
                             hwOwner, tab_dlgproc );   
   TabCtrl_AdjustRect( hwOwner, FALSE, &rt );
   MoveWindow( hwItemTabs[ num ], rt.left, rt.top, rt.right-rt.left, 
                  rt.bottom-rt.top, TRUE );
}

//--------------------------------------------------------------------------

void change_tab( DWORD n )
{
   if ( hwCurItem )
      ShowWindow( hwCurItem, SW_HIDE );
   ShowWindow( hwItemTabs[ n ], SW_SHOW );
   hwCurItem = hwItemTabs[ n ];
}

//--------------------------------------------------------------------------

void dlg_init( HWND hwnd )
{   
   RECT rt;
   char text[MAX_STRING];   


   GetModuleFileName( hInst, szinitdir, _MAX_PATH );
   szfilename[0] = 0;
   hthread = 0;
   p_flg = FALSE;
   SetClassLong( hwnd, GCL_HICON, (LONG)LoadIcon( hInst, MAKEINTRESOURCE( IDI_ICON )));   

   GetClientRect( hwnd, &rt );
   hwTab = CreateWindow( WC_TABCONTROL, "", 
        WS_TABSTOP | WS_CHILD | WS_VISIBLE | TCS_TOOLTIPS, 
        0, 0, rt.right, rt.bottom, 
        hwnd, NULL, hInst, NULL 
        );   
   
   SendMessage( hwTab, WM_SETFONT, (WPARAM)GetStockObject(DEFAULT_GUI_FONT), TRUE );
   create_tabdialog( hwTab, "Running g files", IDD_DLG1, 0 ); 
   create_tabdialog( hwTab, "C&&Gentee", IDD_DLG2, 1 );    
   LoadString(hInst, IDS_EXAMPLE, text, MAX_STRING );
   SetWindowText( GetDlgItem( hwItemTabs[ 0 ], IDC_EDITFILE ), "..\\test.g" );
   SendMessage( GetDlgItem( hwItemTabs[ 0 ], IDC_CHECKPRINT ), BM_SETCHECK, 1, 0 );
   SendMessage( GetDlgItem( hwItemTabs[ 0 ], IDC_CHECKSTDLIB ), BM_SETCHECK, 1, 0 );
   SetWindowText( GetDlgItem( hwItemTabs[ 1 ], IDC_EDITSOURCE), text);   
   SetWindowText( GetDlgItem( hwItemTabs[ 1 ], IDC_EDITNAME), "World");   
   SendMessage( hwTab, TCM_SETCURSEL, 1, 0 );
   change_tab( 1 );
}

//--------------------------------------------------------------------------

BOOL dlg_open( HWND hDlg )
{
   OPENFILENAME  ofn;
   char filter[] = "Gentee file (*.g)\0*.g\0\0";

   ofn.lStructSize       = sizeof (OPENFILENAME);
   ofn.hwndOwner         = hDlg;
   ofn.hInstance         = hInst;
   ofn.lpstrFilter       = filter;   
   ofn.lpstrCustomFilter = NULL;
   ofn.nMaxCustFilter    = 0;
   ofn.nFilterIndex      = 0;
   ofn.lpstrFile         = szfilename;
   ofn.nMaxFile          = _MAX_PATH; 
   ofn.lpstrFileTitle    = NULL;         
   ofn.nMaxFileTitle     = 0;
   ofn.lpstrInitialDir   = szinitdir;
   ofn.lpstrTitle        = NULL;
   ofn.Flags             = OFN_HIDEREADONLY | OFN_CREATEPROMPT | OFN_EXPLORER
                             | OFN_OVERWRITEPROMPT;
   ofn.nFileOffset       = 0;
   ofn.nFileExtension    = 0;
   ofn.lpstrDefExt       = TEXT("g");
   ofn.lCustData         = 0L;
   ofn.lpfnHook          = NULL;
   ofn.lpTemplateName    = NULL;
   return GetOpenFileName (&ofn);
}

//Proc function
//--------------------------------------------------------------------------

BOOL CALLBACK main_dlgproc( HWND hDlg, UINT uMsg, WPARAM wParam, LPARAM lParam )
{
   BOOL fProcessed = TRUE;
   DWORD exitthread;
   
   switch ( uMsg )  
   {      
      case WM_INITDIALOG:
         dlg_init( hDlg );
         break;
      case WM_COMMAND:
         if ( !GetExitCodeThread( hthread, &exitthread ) || !(exitthread==STILL_ACTIVE) )
         switch ( LOWORD(wParam) ) 
         {
            case IDCANCEL:
               EndDialog( hDlg, FALSE );
               break;
            case IDOK:
               EndDialog( hDlg, TRUE );
               break;
         }
         break;
      case WM_NOTIFY:
         if ( ((LPNMHDR)lParam)->code == TCN_SELCHANGE )
               change_tab( TabCtrl_GetCurSel((HWND)((LPNMHDR)lParam)->hwndFrom ));         
         break;
      default:
         fProcessed = FALSE;
   }
   return (fProcessed);
}

//--------------------------------------------------------------------------

BOOL CALLBACK tab_dlgproc( HWND hDlg, UINT uMsg, WPARAM wParam, LPARAM lParam )
{
   BOOL fProcessed = TRUE;   
   DWORD exitthread;
   
   switch ( uMsg ) 
   {   
      case WM_COMMAND:         
         if ( !GetExitCodeThread( hthread, &exitthread ) || !(exitthread==STILL_ACTIVE) )
         switch ( LOWORD(wParam) ) 
         { 
            case IDC_BUTRUN:
                  hthread = CreateThread( NULL, 0, thread_execute, 0, 0, &threadid );
               break;
            case IDC_BUTEXAMPLE:         
                  hthread = CreateThread( NULL, 0, thread_example, 0, 0, &threadid );
               break;
            case IDC_BUTOPEN:   
               if ( dlg_open( hDlg ) )
               {
                  SetWindowText( GetDlgItem( hDlg, IDC_EDITFILE ), szfilename );
               }
               break;
         } 
      return 1;   
   }
   return 0;
}

//--------------------------------------------------------------------------

LRESULT CALLBACK panel_proc( HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam )
{
   HDC hdc;
   PAINTSTRUCT ps;
   RECT rt;
   HBRUSH hbr;
   TEXTMETRIC tm;

   if ( msg == WM_PAINT && p_flg )
   {
      hdc = BeginPaint( hwnd, &ps );            
      hbr = CreateSolidBrush( p_bgcolor );
      GetClientRect( hwnd, &rt );      
      FillRect( hdc, &rt, hbr );
      DeleteObject( hbr );
      SetTextAlign( hdc, TA_CENTER | TA_TOP );
      SetBkColor( hdc, p_bgcolor );
      SetTextColor( hdc, p_sztextcolor );
      GetTextMetrics( hdc, &tm );
      TextOut( hdc, rt.right >> 1, (rt.bottom - tm.tmHeight )>> 1, 
                  p_sztext, strlen(p_sztext));
      EndPaint( hwnd, &ps );
      return 0;
   }
   else
      return DefWindowProc( hwnd, msg, wParam, lParam );
}


