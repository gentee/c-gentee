{******************************************************************************}
{                  Header for Gentee's scripting abilities                     }
{     Allows to use Gentee Programming Language as embedded script engine      }
{           This source in most is just a port of Gentee API header            }
{                                                                              }
{               Tested for version of Gentee 3.6.0.0, Delphi 10                }
{                                                                              }
{                        Copyright © 2009, Kvanter                             }
{                                                                              }
{                        Contact: kvanter@inbox.ru                             }
{                                                                              }
{                  Feel free to distribute and/or modify                       }
{                                                                              }
{        Gentee Programming Language is property of The Gentee Group           }
{                                                                              }
{******************************************************************************}

unit gentee;

interface

uses Classes, Windows;

const
  { States for gentee_set function }
  
  GSET_TEMPDIR = $0001;  // Specify the custom temporary directory
  GSET_PRINT   = $0002;  // Specify the custom print function
  GSET_MESSAGE = $0003;  // Specify the custom message function
  GSET_EXPORT  = $0004;  // Specify the custom export function
  GSET_ARGS    = $0005;  // Specify the command-line arguments
  GSET_FLAG    = $0006;  // Specify flags
  GSET_DEBUG   = $0007;  // Specify the custom debug function
  GSET_GETCH   = $0008;  // Specify the custom getch function

  GPTR_GENTEE  = $0001;  // return _gentee
  GPTR_VM      = $0002;  // return _vm
  GPTR_COMPILE = $0003;  // return _compile

  GLOAD_ARGS   = $0001;  // Get command line arguments
  GLOAD_FILE   = $0002;  // Read file to load the byte-code
  GLOAD_RUN    = $0004;  // Run main function

  { Flags for gentee_init and gentee.flags structure }

  G_CONSOLE = $0001;   // Console application
  G_SILENT  = $0002;   // Don't display any service messages
  G_CHARPRN = $0004;   // Print Windows characters


  { Flags for gentee_getid }

  GID_ANYOBJ = $01000000;   // Find any obj

  TYPE_Int    = $01; // 1 int type
  TYPE_Uint   = $02; // 2 uint type
  TYPE_Byte   = $03; // 3 byte type
  TYPE_Ubyte  = $04; // 4 ubyte type
  TYPE_Short  = $05; // 5 short type
  TYPE_Ushort = $06; // 6 ushort type
  TYPE_Float  = $07; // 7 float type
  TYPE_Double = $08; // 8 double type
  TYPE_Long   = $09; // 9 long type
  TYPE_Ulong  = $0A; // 10 ulong type

  { compileinfo flags }

  CMPL_SRC      = $0001;   // If compileinfo.input is Gentee source
  CMPL_NORUN    = $0002;   // Don't run after compiling
  CMPL_GE       = $0004;   // Create GE file
  CMPL_DEFARG   = $0008;   // Define arguments
  CMPL_LINE     = $0010;   // Proceed #! at the first string
  CMPL_DEBUG    = $0020;   // Compilation with the debug info
  CMPL_THREAD   = $0040;   // Compilation in the thread
  CMPL_NOWAIT   = $0080;   // Do not wait for the end of the compilation (thread)
  CMPL_OPTIMIZE = $0100;   // Optimize the output GE file


  MSG_STR     = $00010000;   // The parameter is a string
  MSG_EXIT    = $00020000;   // Exit the thread
  MSG_POS     = $00200000;   // The parameter is a position
  MSG_LEXEM   = $00400000;   // The parameter is a lexem
  MSG_LEXNAME = $00800000;   // Output the name of the lexem
  MSG_VALUE   = $01000000;   // The parameter is a value
  MSG_VALSTR  = $02000000;   // double value + name
  MSG_VALVAL  = $04000000;   // double value

  MSG_VALSTRERR = MSG_VALUE or MSG_VALSTR or MSG_EXIT;
  MSG_DVAL = MSG_VALUE or MSG_VALVAL or MSG_EXIT;
  MSG_LEXERR = MSG_EXIT or MSG_LEXEM;
  MSG_LEXNAMEERR = MSG_EXIT or MSG_LEXEM or MSG_LEXNAME;





  OPTI_DEFINE = $0001;   // Delete 'define' objects.
  OPTI_NAME   = $0002;   // Delete names of objects.
  OPTI_AVOID  = $0004;   // Delete not used objects.
  OPTI_MAIN   = $0008;   // Leave only one main function with OPTI_AVOID.


type
  TGeMsgInfo = record
    code: cardinal;        // Message code
    flag: cardinal;        // Message flags
    filename: PAnsiChar;
    line: cardinal;
    pos: cardinal;
    namepar: PAnsiChar;
    uintpar: cardinal;
    pattern: PAnsiChar;
  end;
  PGeMsgInfo = ^TGeMsgInfo;


  TGeMessageFunc = function(msg: PGeMsgInfo): cardinal; stdcall;
  TGePrintFunc   = procedure(str: PAnsiChar; num: cardinal); stdcall;
  TGeGetchFunc   = function(char: PAnsiChar; num: cardinal): cardinal; stdcall;
  TGeExportFunc  = function(Name: PAnsiChar): Pointer; stdcall;


  { The structure for the using in TGeCompileInfo structure }
  
  TGeOptimize = record
    flag: cardinal;        // Flags of the optimization.
    nameson: PAnsiChar;    // Don't delete names with the following wildcards divided by 0 if OPTI_NAME specified
    avoidon: PAnsiChar;    // Don't delete objects with the following wildcards divided by 0 if OPTI_AVOID specified
  end;
  PGeOptimize = ^TGeOptimize;

  { The structure for the using in gentee_compile function }
  
  TGeCompileInfo = record
    input: PAnsiChar;      // The Gentee filename. You can specify the Gentee source if the flag CMPL_SRC is defined
    flag: cardinal;        // Compile flags
    libdirs: PAnsiChar;    // fFolders for searching files: name1 0 name2 0 ... 00. It may be NULL
    include: PAnsiChar;    // Include files: name1 0 name2 0 ... 00. These files will be compiled at the beginning of the compilation process.
                           // It may be NULL
    defargs: PAnsiChar;    // Define arguments: name1 0 name2 0 ... 00. You can specify additional macro definitions.
                           // For example, #b( MYMODE = 10 ). In this case, you can use #b( $MYMODE ) in the Gentee program. It may be NULL
    output: PAnsiChar;     // Ouput filename for GE. In default, .ge file is created in the same folder as .g main file. You can specify
                           // any path and name for the output bytecode file. You must specify CMPL_GE flag to create the bytecode file
    hthread: Pointer;      // The result handle of the thread if you specified CMPL_THREAD | CMPL_NOWAIT.
    result: cardinal;      // Result of the program if it was executed
    opti: TGeOptimize;     // Optimize structure. It is used if flag CMPL_OPTIMIZE is defined
  end;
  PGeCompileInfo = ^TGeCompileInfo;


  { Parameter array for geCallFunc function }

  TGeCallParams = array of Pointer;
  PGeCallParams = ^TGeCallParams;



  { Gentee API functions' prototypes }

  gentee_deinit_function  = function: cardinal; stdcall;
  gentee_init_function    = function(flags: cardinal): cardinal; stdcall;
  gentee_set_function     = function(state: cardinal; val: Pointer): cardinal; stdcall;
  gentee_ptr_functon      = function(par: cardinal): Pointer; stdcall;
  gentee_load_function    = function(bytecode: PAnsiChar; flag: cardinal): cardinal; stdcall;
  gentee_call_function    = function(id: cardinal; result: Pointer): cardinal; cdecl;
  gentee_getid_function   = function(name: PAnsiChar; count: cardinal): cardinal; cdecl;
  gentee_compile_function = function (compinit: PGeCompileInfo): cardinal; stdcall;



var
  gentee_deinit: gentee_deinit_function = nil;
  gentee_init: gentee_init_function = nil;
  gentee_set: gentee_set_function = nil;
  gentee_ptr: gentee_ptr_functon = nil;
  gentee_load: gentee_load_function = nil;
  gentee_call: gentee_call_function = nil;
  gentee_getid: gentee_getid_function = nil;
  gentee_compile: gentee_compile_function = nil;


// Well, I can provide the comments in English, but.. What the Hell? Can I sometimes take care of my Lazyness?
// Ancient Romans said "Sapienti sat" ;)

// Устанавливает обработчики специальных вызовов, если что не нужно, типа PRINT-функции, подойдет NIL
procedure geSetHandlerFuncs(msgf: TGeMessageFunc; prnf: TGePrintFunc; getchf: TGeGetchFunc; expf: TGeExportFunc);

// Производит компиляцию исходника, по флагу RunAfter запускает на выполнение, если параметр GeFileName не пустой,
// то в файл с таким именем сохраняется .ge код
function geCompileSource(Source: TStrings; RunAfter: boolean; const GeFileName: string = ''; const LibDir: string = ''; const Include: string = ''; const DefArgs: string = ''; Flags: cardinal = 0): cardinal;
// То же самое, только исходник берется из файла
function geCompileFile(const FileName: string; RunAfter: boolean; const GeFileName: string = ''; const LibDir: string = ''; const Include: string = ''; const DefArgs: string = ''; Flags: cardinal = 0): cardinal;

// Грузит .ge код из файла, по флагу RunAfter запускает на выполнение
function geLoadFromFile(const FileName: string; RunAfter: boolean; Flags: cardinal): cardinal;
// То же самое, только код грузится из потока
function geLoadFromStream(Stream: TStream; RunAfter: boolean; Flags: cardinal): cardinal;
// То же самое, только код грузится из буфера в памяти
function geLoadFromBuffer(buf: Pointer; RunAfter: boolean; Flags: cardinal): cardinal;

// Вызов скриптовой функции
// id - числовой идентификатор функции в виртуальной машине,
// res - указатель на переменную, в которую будет возвращено значение функции
// count - количество параметров, передаваемых функции
// params - собсно сам массив переметров (каждый параметр в массиве - просто нетипизированный указатель на данные некоторого типа)
function geCallFunc(id: cardinal; res: Pointer; count: integer; const params: TGeCallParams): cardinal; overload;
// Аналогично, только вместо id'а передается имя функции
function geCallFunc(const Name: string; res: Pointer; count: integer; const params: TGeCallParams): cardinal; overload;
// Аналогично, только параметры передаются в виде OpenArray, что иногда немного упрощает код 
function geCallFunc(const Name: string; res: Pointer; params: array of Pointer): cardinal; overload;






implementation

uses SysUtils;

var hGenteedll: THandle = 0;


var
  geMessageFunc: TGeMessageFunc = nil;
  gePrintFunc: TGePrintFunc = nil;
  geGetchFunc: TGeGetchFunc = nil;
  geExportFunc: TGeExportFunc = nil;


// Финализирует движок и отвязывает библиотеку. Вызывается как минимум один раз
// автоматически из finalization-секции при завершении программы
  

function final_gentee: LongBool;
begin
  Result := TRUE;
  if hGenteedll <> 0 then
    begin
      Result := LongBool(gentee_deinit);

      gentee_deinit := nil;
      gentee_init := nil;
      gentee_set := nil;
      gentee_ptr := nil;
      gentee_load := nil;
      gentee_call := nil;
      gentee_getid := nil;
      gentee_compile := nil;

      FreeLibrary(hGenteedll);
      hGenteedll := 0;
    end;
end;


const genteedll = 'gentee.dll';

// Инициализирует движок. Вызывается автоматически при компиляции или загрузке уже
// откомпиленного кода (т.е. ge-файла). Дело в том, что без полной реинициализации
// при перезагрузке скрипт-кода возникали странные глюки его выполнения. Ежели
// в дальнейшем ситуация поправится, можно будет оптимизировать управление

function reinit_gentee: LongBool;
begin
  final_gentee;

  hGenteedll := LoadLibrary(genteedll);
  if hGenteedll = 0 then
    raise Exception.Create('Cannot load library gentee.dll');

  @gentee_deinit  := GetProcAddress(hGenteedll, 'gentee_deinit');
  @gentee_init    := GetProcAddress(hGenteedll, 'gentee_init');
  @gentee_set     := GetProcAddress(hGenteedll, 'gentee_set');
  @gentee_ptr     := GetProcAddress(hGenteedll, 'gentee_ptr');
  @gentee_load    := GetProcAddress(hGenteedll, 'gentee_load');
  @gentee_call    := GetProcAddress(hGenteedll, 'gentee_call');
  @gentee_getid   := GetProcAddress(hGenteedll, 'gentee_getid');
  @gentee_compile := GetProcAddress(hGenteedll, 'gentee_compile');

  Result := LongBool(gentee_init(G_CHARPRN));
  if Result then
    begin
      if @geMessageFunc <> nil then
        gentee_set(GSET_MESSAGE, @geMessageFunc);
      if @gePrintFunc <> nil then
        gentee_set(GSET_PRINT, @gePrintFunc);
      if @geGetchFunc <> nil then
        gentee_set(GSET_GETCH, @geGetchFunc);
      if @geExportFunc <> nil then
        gentee_set(GSET_EXPORT, @geExportFunc);
    end;
end;





procedure geSetHandlerFuncs(msgf: TGeMessageFunc; prnf: TGePrintFunc; getchf: TGeGetchFunc; expf: TGeExportFunc);
begin
  geMessageFunc := msgf;
  gePrintFunc := prnf;
  geGetchFunc := getchf;
  geExportFunc := expf;
end;

function geCompileSource(Source: TStrings; RunAfter: boolean; const GeFileName: string = ''; const LibDir: string = ''; const Include: string = ''; const DefArgs: string = ''; Flags: cardinal = 0): cardinal;
begin
  Result := geCompileFile(Source.Text + #0, RunAfter, GeFileName, LibDir, Include, DefArgs, CMPL_SRC or Flags)
end;

function geCompileFile(const FileName: string; RunAfter: boolean; const GeFileName: string = ''; const LibDir: string = ''; const Include: string = ''; const DefArgs: string = ''; Flags: cardinal = 0): cardinal;
var
  cinf: TGeCompileInfo;
begin
  Result := 0;
  if reinit_gentee then
    begin
      FillMemory(@cinf, sizeof(TGeCompileInfo), 0);
      cinf.input := PChar(FileName);
      cinf.flag := Flags;
      if not RunAfter then
        cinf.flag := cinf.flag or CMPL_NORUN;
      if GeFileName <> '' then
        cinf.flag := cinf.flag or CMPL_GE;
      if DefArgs <> '' then
        cinf.flag := cinf.flag or CMPL_DEFARG;
      cinf.libdirs := PChar(LibDir + #0#0);
      cinf.include := PChar(Include + #0#0);
      cinf.output := PChar(GeFileName);
      cinf.defargs := PChar(DefArgs + #0#0);
      Result := gentee_compile(@cinf);
    end
end;


function geLoadFromFile(const FileName: string; RunAfter: boolean; Flags: cardinal): cardinal;
begin
  Result := 0;
  if reinit_gentee then
    begin
      Flags := Flags or GLOAD_FILE;
      if RunAfter then
        Flags := Flags or GLOAD_RUN;
      Result := gentee_load(PChar(FileName), Flags);
    end
end;

function geLoadFromStream(Stream: TStream; RunAfter: boolean; Flags: cardinal): cardinal;
var
  buf: PAnsiChar;
  sz: cardinal;
begin
  Result := 0;
  if reinit_gentee then
    begin
      if RunAfter then
        Flags := Flags or GLOAD_RUN;
      sz := Stream.Size;
      GetMem(buf, sz);
      try
        Stream.Read(buf^, sz);
        Result := gentee_load(buf, Flags);
      finally
        FreeMem(buf, sz);
      end;
    end
end;

function geLoadFromBuffer(buf: Pointer; RunAfter: boolean; Flags: cardinal): cardinal;
begin
  Result := 0;
  if reinit_gentee then
    begin
      if RunAfter then
        Flags := Flags or GLOAD_RUN;
      Result := gentee_load(PAnsiChar(buf), Flags);
    end
end;

// Иногда бывает нужно передать вызываемой скрипт-функции динамический набор
// параметров в виде массива, списка или чего подобного.
// Библиотечная функция gentee_call описана с использованием возможности языка С
// в виде передачи неопределенного числа параметров (varargs), что, к сожалению,
// задачу особо не облегчает. Поэтому пришлось идти на некоторые трюки, хоть это
// и минус портабельности кода. 

function geCallFunc(id: cardinal; res: Pointer; count: integer; const params: TGeCallParams): cardinal;
asm
   // IN      -->  EAX id
   //              EDX res
   //              ECX count
   // RETURN  <--  EAX Result

    push edi          // Save registers into stack
    push ebp
    push ebx
    push esi

    mov ebx, eax      // Set value of id paramter
    mov esi, edx      // Set value of res parameter
    mov eax, ecx      // Calculate necessary block size for stack frame
    mov edi, 4
    mul edi
    mov edx, 8
    add eax, edx

    mov edi, params

    mov ebp, esp      // Reserve stack frame
    sub esp, eax      // esp contains a pointer to stack top

    mov [esp], ebx    // Put id parameter into stack
    mov [esp+4], esi  // Put res parameter into stack

    test ecx, ecx     // Is there additional parameters
    jz @@02           // if no jump

  @@01:               // Put additional parameters into stack
    mov eax, dword ptr [edi]
    mov [esp+edx], eax
    dec ecx
    jz @@02
    add edx, 4
    add edi, 4
    jmp @@01

  @@02:
    call gentee_call  // Call a function

    mov esp, ebp      // Free the reserved stack frame

    pop esi           // Restore registers
    pop ebx
    pop ebp
    pop edi
end;

function geCallFunc(const Name: string; res: Pointer; count: integer; const params: TGeCallParams): cardinal;
var id: cardinal;
begin
  Result := 0;
  id := gentee_getid(PAnsiChar(Name), GID_ANYOBJ);
  if id > 0 then
    Result := geCallFunc(id, res, count, params)
end;

function geCallFunc(const Name: string; res: Pointer; params: array of Pointer): cardinal;
var
  id: cardinal;
  prms: TGeCallParams;
  i: integer;
  cnt: integer;
begin
  Result := 0;
  id := gentee_getid(PAnsiChar(Name), GID_ANYOBJ);
  if id > 0 then
    begin
      cnt := High(params) + 1;
      if cnt > 0 then
        begin
          SetLength(prms, cnt);
          for i := 0 to cnt - 1 do
            prms[i] := params[i];
        end;
      Result := geCallFunc(id, res, cnt, prms)
    end;
end;




initialization

finalization
  final_gentee;




end.
