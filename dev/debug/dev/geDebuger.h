#ifndef _GEDEBUGER_H_
#define _GEDEBUGER_H_

#ifdef __cplusplus
    extern "C" {
#endif // __cplusplus



typedef unsigned long  (__stdcall* _gentee_init)   (unsigned long);
typedef unsigned long  (__stdcall* _gentee_compile)(void*);
typedef unsigned long  (__stdcall* _gentee_set)    (unsigned long, void*);
typedef void*          (__stdcall* _gentee_ptr)    (unsigned long);
typedef unsigned long  (__cdecl*   _gentee_call)   ( unsigned long, unsigned long*, ... );

#define DEBUG_CHILD_WINDOWS (1<<0)
//#define DEBUG_SHOW_WINDOWS  (1<<1)

#define DEBUG_HIGE_FILELIST (1<<8)
#define DEBUG_HIGE_DEBUGLOG (1<<9)



typedef struct _setupDebuger
{
    HWND            mainWND;
    unsigned long   flag; 
    _gentee_init    ge_init;
    _gentee_compile ge_compile;
    _gentee_set     ge_set;
    _gentee_ptr     ge_ptr;
    _gentee_call    ge_call;
}setupDebuger;


#ifdef BUILD_DLL
#define _DLL_EXPORT __declspec(dllexport)
#else
#define _DLL_EXPORT
#endif


BOOL _DLL_EXPORT __stdcall geDebuger_Init(setupDebuger *st);
void _DLL_EXPORT __stdcall geDebuger_Destroy();
void _DLL_EXPORT __stdcall geDebager_Show(BOOL isView);
void _DLL_EXPORT __stdcall geDebuger_Move(int x, int y, int w, int h);

#ifdef __cplusplus
    }
#endif // __cplusplus
    
#endif  //_GEDEBUGER_H_
