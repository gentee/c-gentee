/******************************************************************************
*
* Copyright (C) 2006, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* ID: vm 18.10.06 0.0.A.
*
* Author: Alexey Krivonogov ( gentee )
*
* Summary: Functions, structures and defines of the Gentee virtual machine.
* 
******************************************************************************/

#ifndef _VM-A_
#define _VM-A_

   #ifdef __cplusplus               
      extern "C" {                 
   #endif // __cplusplus      

#include "../common/hash.h"
#include "../common/msg.h"
#include "../common/collection.h"
#include "../bytecode/cmdlist.h"

#define   KERNEL_COUNT  1024  // The count of the VM kernel commands
#define   VAR_SIZE      1024  // Stack limit size of variables

#ifdef GASM  || (defined (LINUX)) // Stack shifts
#ifdef GASM  // Stack shifts
   #define  SSI1 (-1)
   #define  SSI2 (-2)
   #define  SSI3 (-3)
   #define  SSI4 (-4)
   #define  SSL1 (-1)  // shift long
   #define  SSL2 (-3)
   #define  SSAE  -=
   #define  SSSE  +=
   #define  SSA   -
   #define  SSS   +
   #define  SSAA  --
   #define  SSSS  ++
#else
   #define  SSI1 1
   #define  SSI2 2
   #define  SSI3 3
   #define  SSI4 4
   #define  SSL1 2  // shift long
   #define  SSL2 4
   #define  SSAE  +=
   #define  SSSE  -=
   #define  SSA   +
   #define  SSS   -
   #define  SSAA  ++
   #define  SSSS  --
#endif

/*-----------------------------------------------------------------------------
*
* ID: gehead 19.10.06 0.0.A.
* 
* Summary: The structure type of the virtual machine.
*  
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
//   uint  stacksize; // The stack size
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
*
* ID: vmtype! 19.10.06 0.0.A.
* 
* Summary: The types of objects of the VM.
*  
-----------------------------------------------------------------------------*/

#define  OVM_NONE       0      // Not defined command
#define  OVM_STACKCMD   0x01   // System command
#define  OVM_PSEUDOCMD  0x02   // Pseudo System command
#define  OVM_BYTECODE   0x03   // Byte-code
#define  OVM_EXFUNC     0x04   // Executable function. It can be 'stdcall' or 
                               // 'cdecl' machine code function.
#define  OVM_TYPE       0x05   // Type
#define  OVM_GLOBAL     0x06   // Global variable
#define  OVM_DEFINE     0x07   // Macros definitions
#define  OVM_IMPORT     0x08   // Import functions from external files
#define  OVM_RESOURCE   0x09   // Resources !!! must be realized in GE!
#define  OVM_ALIAS      0x0A   // Alias (link) object

/*-----------------------------------------------------------------------------
*
* ID: vmflags 19.10.06 0.0.A.
* 
* Summary: The flags of objects of the VM.
*  
-----------------------------------------------------------------------------*/

// Common flags
#define GHCOM_NAME      0x0001    // Имеется имя - объект импортируем
//#define GHCOM_ALLOC     0x0002    // Указано количество отводимой памяти
#define GHCOM_PACK      0x0002     // Данные упакованы bwd

// OVM_BYTECODE
#define GHBC_ENTRY      0x000100    // Выполнить после загрузки всего байт-кода
#define GHBC_MAIN       0x000200    // Выполнить если он загрузился последним с таким флагом
#define GHBC_RESULT     0x000400    // Требуется дополнительный параметр тип - возвращаемое значение при вызове
#define GHBC_TEXT       0x000800    // Байт-код является text функцией
#define GHBC_METHOD     0x001000    // Байт-код является method
#define GHBC_OPERATOR   0x002000    // Байт-код является operator
#define GHBC_PROPERTY   0x004000    // Байт-код является property

// OVM_EXFUNC
#define GHEX_CDECL      0x010000    // Тип функции __cdecl
#define GHEX_FLOAT      0x020000    // Возвращаемое значение double или float
#define GHEX_SYSCALL    0x040000    // Вызов системной функции по номеру
#define GHEX_IMPORT     0x080000    // Импортируемая функция - 
                                    // есть оригинальное имя и id parent файла

// OVM_DEFINE
#define GHDF_EXPORT     0x000100    // Экспортировать макросы
#define GHDF_NAMEDEF    0x000200    // Макросы без $

// OVM_IMPORT 
#define GHIMP_LINK      0x000100    // Прилинкованная dll библиотека
#define GHIMP_CDECL     0x000200    // Импорт __cdecl функций 
#define GHIMP_EXE       0x000400    // Указан относительный путь по отношению к exe файлу

// OVM_GLOBAL
//#define GHGL_DATA       0x000100    // Есть данные инициализации

// OVM_TYPE
#define GHTY_INHERIT    0x000100    // Имеется наследование ( объект-родитель )
#define GHTY_INDEX      0x000200    // Имеется index 
#define GHTY_INITDEL    0x000400    // Имеется метод  init и deinit 
#define GHTY_EXTFUNC    0x000800    // Имеется метод  oftype =%
#define GHTY_ARRAY      0x001000    // Имеются методы array
#define GHTY_PROTECTED  0x002000    // Protected type
#define GHTY_STACK      0x010000    // Тип целиком размещается в стэке

// RUNTIME flags
#define GHRT_MAYCALL    0x01000000  // for OVM_STACKCMD OVM_BYTECODE OVM_EXFUNC
#define GHRT_INIT       0x02000000  // Тип требует инициализации (возможно в подтипе)
#define GHRT_DELETE     0x04000000  // Тип требует деинициализации ( возможно в подтипе)
#define GHRT_LOADED     0x08000000  // The object was initialized in vm_execute
#define GHRT_INCLUDED   0x10000000  // The object was proceed at the end of module compile
#define GHRT_PRIVATE    0x20000000  // The private object 
#define GHRT_ALIAS      0x40000000  // There is alias
#define GHRT_SKIP       0x80000000  // Skip object for GE 

/*-----------------------------------------------------------------------------
*
* ID: vmaddflags 19.10.06 0.0.A.
* 
* Summary: The flags for vm_addobj.
*  
-----------------------------------------------------------------------------*/

//#define VMADD_CRC       0x0001  // CRC control

/*-----------------------------------------------------------------------------
*
* ID: vmobj 19.10.06 0.0.A.
* 
* Summary: The structure type of the object of the virtual machine. Each item
  of the virtual machine must begin with this structure.
*  
-----------------------------------------------------------------------------*/
#pragma pack(push, 1)

typedef struct
{
   uint      size;       // The full size of this object
   ubyte     type;       // The type. [- vmtype -]
   uint      flag;       // The flags.
   pubyte    name;       // The object name.
   uint      id;         // Object Identifier in the VM. It equals the array 
                         // index.
   uint      nextname;   // The ID of the next object with the same name.
} vmobj, * pvmobj;

#pragma pack(pop)

/*-----------------------------------------------------------------------------
*
* ID: exttype 19.10.06 0.0.A.
* 
* Summary: The structure of subtypes.
*  
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
*
* ID: subtype 19.10.06 0.0.A.
* 
* Summary: The structure of subtypes or variables.
*  
-----------------------------------------------------------------------------*/
#pragma pack(push, 1)

typedef struct 
{
   uint       type;     // идентификатор типа
   uint       off;      // смещение данного поля или переменной
                        // для переменной смещение в uint с alignment sizeof( uint )
   pubyte     name;     // указатель на имя поля или переменной
   uint       oftype;   // OF type.
   ubyte      flag;     // VAR flags
   ubyte      dim;      // Dimension.
   ushort     data;     // Имееются данные инициализации
   puint      ptr;      // Dimensions + Initializing Data 
} vartype, * pvartype;

#pragma pack(pop)

#define  FTYPE_INIT    0   // @init()
#define  FTYPE_DELETE  1   // @delete()
#define  FTYPE_OFTYPE  2   // @oftype()
#define  FTYPE_COLLECTION  3   // = %{}
#define  FTYPE_ARRAY       4   // @array(), @array(,), @array(,,) и т.д.


/*-----------------------------------------------------------------------------
*
* ID: ovmtype 19.10.06 0.0.A.
* 
* Summary: The structure type of the OVM_TYPE object of the VM.
*  
-----------------------------------------------------------------------------*/

typedef struct 
{
   vmobj     vmo;      // vmobject
   uint      size;     // the size of the type
   uint      stsize;   // The count of uints in the stack.
                       // double, long, ulong - 2
   uint      inherit;  // Тип-родитель
   vartype   index;    // Тип по умолчанию для элементов возвращаемых 
                       // по методу index. По умолчанию это uint.
   
   uint      ftype[ MAX_MSR + 4 ];  // Type functions
   uint      count;    // количество подтипов// - для STRUCT.
   pvartype  children;   // Subtypes
} ovmtype, * povmtype;

/*-----------------------------------------------------------------------------
*
* ID: var 19.10.06 0.0.A.
* 
* Summary: The type for parameters and local variables
*  
-----------------------------------------------------------------------------*/

/*
   Parameters and variables

   При вызове функции
     Идут передаваемые параметры.
   
   puint  // The pointer to local variables. Локальные переменные могут 
          // располагаться в стэке, а могут в отдельном memory block.
          // if varsize > 1024 -> отдельный memory
   uint   [setcount]  // признаки инициализировано ли каждое из множеств 
          // локальных переменных
*/

/*-----------------------------------------------------------------------------
*
* ID: vmfunc 19.10.06 0.0.A.
* 
* Summary: The structure type of the OVM_STACKCMD and OVM_BYTECODE object of the VM. It is used 
  for embedded stack commands.
*  
-----------------------------------------------------------------------------*/
#pragma pack(push, 1)

typedef struct 
{
   vmobj     vmo;      // Object of VM
   pvartype  ret;
   ubyte     dwret;      // The count of return uints.
   ubyte     parcount;   // The count of parameters
   pvartype  params;     // The parameters
   ubyte     parsize;    // The summary size of parameters in uints.
   pvoid     func;       // Proceeding function or the pointer to the byte-code
} vmfunc, * pvmfunc;

#pragma pack(pop)

/*-----------------------------------------------------------------------------
*
* ID: ovmstack 19.10.06 0.0.A.
* 
* Summary: The structure type of the OVM_STACKCMD object of the VM. It is used 
  for embedded stack commands.
*  
-----------------------------------------------------------------------------*/

typedef struct 
{
   vmfunc    vmf;        // Parameters description 
   int       topshift;   // The shift (in uints) of the top of the stack
   int       cmdshift;   // The shift (in uints) of the byte-code pointer.
} ovmstack, * povmstack;

/*-----------------------------------------------------------------------------
*
* ID: varb 19.10.06 0.0.A.
* 
* Summary: The structure type of the block of variables. 
*  
-----------------------------------------------------------------------------*/

typedef struct 
{
   ushort    count;      // The number of variables of the block
   ushort    first;      // The number of the first variable
   uint      size;       // The summary size of varaiables in uints
   uint      off;        // The offset of the block
} varset, * pvarset;

/*-----------------------------------------------------------------------------
*
* ID: ovmbcode 19.10.06 0.0.A.
* 
* Summary: The structure type of the OVM_BYTECODE object of the VM. 
*  
-----------------------------------------------------------------------------*/

typedef struct 
{
   vmfunc    vmf;        // Parameters description 
//   ushort    varcount;   // The number of local variables
   pvartype  vars;       //
   uint      varsize;    // The summary size of all variables in uints
   ushort    setcount;   // Количество блоков локальных переменных
   pvarset   sets;       // Указатель на структуры varset
   uint      bcsize;     // Size of the byte-code
} ovmbcode, * povmbcode;

/*-----------------------------------------------------------------------------
*
* ID: ovmfunc 19.10.06 0.0.A.
* 
* Summary: The structure type of the OVM_EXFUNC object of the VM. 
*  
-----------------------------------------------------------------------------*/

typedef struct 
{
   vmfunc    vmf;        // Parameters description 
   pubyte    original;   // Original name of the function ( if GHEX_IMPORT )
   uint      import;     // import parent id ( if GHEX_IMPORT )
} ovmfunc, * povmfunc;

/*-----------------------------------------------------------------------------
*
* ID: ovmglobal 19.10.06 0.0.A.
* 
* Summary: The structure type of the OVM_GLOBAL object of the VM. 
*  
-----------------------------------------------------------------------------*/
typedef struct 
{
   vmobj      vmo;         // The object of VM
   pvartype   type;        // Type of global
   pubyte     pval;        // Pointer to the value
} ovmglobal, * povmglobal;

/*-----------------------------------------------------------------------------
*
* ID: ovmdefine 19.10.06 0.0.A.
* 
* Summary: The structure type of the OVM_DEFINE object of the VM. 
*  
-----------------------------------------------------------------------------*/
typedef struct 
{
   vmobj      vmo;      // The object of VM
   uint       count;    // Count of defines
   pvartype   macros;   // Macros
} ovmdefine, * povmdefine;

/*-----------------------------------------------------------------------------
*
* ID: ovmimport 19.10.06 0.0.A.
* 
* Summary: The structure type of the OVM_IMPORT object of the VM. 
*  
-----------------------------------------------------------------------------*/
typedef struct 
{
   vmobj      vmo;      // The object of VM
   pubyte     filename; // The name of the file
   uint       size;  // The size of DLL if GHIMP_LINK
   pubyte     data;  // The body of DLL if GHIMP_LINK
   pvoid      handle;   // The handle of the library
} ovmimport, * povmimport;

/*-----------------------------------------------------------------------------
*
* ID: ovmalias 06.07.07 0.0.A.
* 
* Summary: The structure type of the OVM_ALIAS object of the VM. 
*  
-----------------------------------------------------------------------------*/
typedef struct 
{
   vmobj      vmo;      // The object of VM
   uint       idlink;   // The id of linked object
} ovmalias, * povmalias;

// Flags for vm_getid
#define GETID_METHOD   0x01  // search method
#define GETID_OPERATOR 0x02  // search operator
#define GETID_OFTYPE   0x04  // params + oftype in collection

//--------------------------------------------------------------------------

extern vm    _vm;
extern pvm   _pvm;

#define  PCMD( y )  *(( puint )_vm.objtbl.data.data + (y))

void       STDCALL vm_deinit( void );
void       STDCALL vm_init( void );
pvmfunc    STDCALL vm_find( pubyte name, uint count, puint pars );
uint       STDCALL vm_execute( uint main );
void       STDCALL vm_clearname( uint id );
uint       STDCALL vm_getid( pstr name, uint flags, pcollect colpars );

   #ifdef __cplusplus              
      }                            
   #endif // __cplusplus

#endif // _VM_

