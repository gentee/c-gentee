
#ifndef _TYPES_
#define _TYPES_

   #ifdef __cplusplus
      extern "C" {
   #endif // __cplusplus

#define STDCALL   __stdcall 
#define FASTCALL  __fastcall
#define CDECLCALL __cdecl


typedef unsigned char     ubyte;
typedef unsigned long     uint;
typedef unsigned short    ushort;
typedef unsigned __int64  ulong64;
typedef          __int64  long64;

typedef  ubyte*    pubyte;
typedef  char *    pchar;
typedef  uint*     puint;
typedef  int*      pint;
typedef  void*     pvoid;
typedef  ushort*   pushort;
typedef  short*    pshort;
typedef  ulong64*  pulong64;
typedef  long64*   plong64;

#define  ABC_COUNT    256
#define  FALSE        0
#define  TRUE         1
#define  MAX_BYTE     0xFF
#define  MAX_USHORT   0xFFFF
#define  MAX_UINT     0xFFFFFFFF
#define  MAX_MSR      8                   // Max array dimension


// File operation flags os_fileopen
#define FOP_READONLY   0x0001   // open as readonly
#define FOP_EXCLUSIVE  0x0002   // open exclusively
#define FOP_CREATE     0x0004   // create file
#define FOP_IFCREATE   0x0008   // create file if it doesn't exist


typedef struct
{
    pubyte    data;      // Pointer to the allocated memory
    uint      use;       // Using size
    uint      size;      // All available size
    uint      step;      // The minimum step of the increasing
} buf, * pbuf;


typedef struct
{
    buf     data;   
    uint    isize;  // The size of the item
    ubyte   isobj;  // Each item is a memory block
} arr, * parr;


typedef struct
{
    buf     data;   
    uint    itype;  // The type of items
    uint    isize;  // The size of the item
    uint    dim[ MAX_MSR ];  // Dimensions
} garr, * pgarr;

typedef arr arrdata;
typedef arrdata * parrdata;

typedef buf str;
typedef str * pstr;

typedef struct
{
   uint    type;     // The type of the number  T****
   union {
      uint     vint;
      ulong64  vlong;
      float    vfloat;
      double   vdouble;
   };
} number, * pnumber;


typedef struct _heap
{
    pvoid   ptr;          // Pointer to the heap memory
    puint   chain;        // Array of ABC_COUNT free chains
    uint    size;         // The summary memory size
    uint    remain;       // The remain size of the heap
    uint    free;         // The size of free blocks
} heap, * pheap;

typedef struct memory
{
    pheap   heaps;        // Array of ABC_COUNT heaps
    uint    last;         // The number of the latest active heap
    puint   sid;          // Array of ABC_COUNT limits of block sizes
} memory;


// Описание имени
typedef struct 
{
    ushort len;       // длина имени
    uint   id;        // Identifier. The number in the array
    pvoid  next;      // The next hashitem 
} hashitem, * phashitem; 
// Additional size hash.isize
// name with zero at the end

// После этого идет строка имени
typedef struct
{
    arr     values;   // Hash-values hash table pointer to the first hashitem
    arr     names;    // Array of hash names = pointers to hashitem objects
    uint    isize;    // Additional size
    ubyte   ignore;   // If 1 then ignore case
} hash, * phash;


typedef struct
{
    buf       data;       
    uint      count;   // The number of items
    uint      flag;    // Флаги
} collect, * pcollect;


#include <windows.h>
#include <setjmp.h>

#define OS_CRL        CRITICAL_SECTION  // type


/*-----------------------------------------------------------------------------
* Summary: The structure type of the virtual machine.
-----------------------------------------------------------------------------*/

typedef struct
{
   pvoid   ptr;     // The memory pointer
   pubyte  top;     // The free pointer
   pubyte  end;     // The end pointer
   pvoid   next;    // The next vmmanager
} vmmanager, * pvmmanager;



typedef struct
{
    arr   objtbl;    // The table of the objects of the current VM.
    hash  objname;   // The table of the names of objects of the current VM.
    uint  count;     // The count of the objects
    pvmmanager   pmng;  // The current vmmanager
    collect  resource;  // Resources
    
    uint  ipack;      // 1 if the current loading object is packed
    uint  isize;      // The input size of the current loading object
    uint  icnv;       // converting shift;
    uint  loadmode;   // 0 - if loading from GE otherwise loading from G
    uint  countinit;  // The count of the initialized id
    uint  pos;        // Pos for run-time error compiling
    uint  irescnv;    // shift for converting resources CResload
} vm, * pvm;


/*-----------------------------------------------------------------------------
* Summary: The main structure of gentee engine
-----------------------------------------------------------------------------*/


typedef struct
{
    uint   flags;      // G_... flags
    pbuf  gesave;
    uint  gesaveoff;
    uint  _crctbl[ 256 ];
    vm     _vm;
    memory _memory;
    jmp_buf stack_state;
    BOOL isDelName;
    unsigned int popravka;
    OS_CRL _crlmem;               // Critical section for multi-thread calling
}vmEngine, *pvmEngine;

   #ifdef __cplusplus
      }
   #endif // __cplusplus

#endif // _TYPES_