/******************************************************************************
*
* Copyright (C) 2004-2008, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexander Krivonogov ( algen )
*
******************************************************************************/

/*-----------------------------------------------------------------------------
* Id: comole L "COM/OLE"
* 
* Summary: Working with COM/OLE Object. The COM library is applied for working
           with the #b(COM/OLE objects), the #b(IDispatch) interface and
           maintains late binding operations. For using this library, it is
           required to specify the file olecom.g (from lib\olecom subfolder)
           with include command. #srcg[
|include : $"...\gentee\lib\olecom\olecom.g"]   
*
* List: *,olecom_desc,tvariant,
        *#lng/opers#,typevar_opeq,variant_opeq,type_opvar,
        *#lng/methods#,oleobj_createobj,oleobj_getres,oleobj_iserr,
         oleobj_release,
        *VARIANT Methods,variant_arrcreate,variant_arrfromg,variant_arrgetptr,
        variant_clear,variant_ismissing,variant_isnull,variant_setmissing
* 
-----------------------------------------------------------------------------*/

define <export> {
   FOLEOBJ_INT = 0x01 // Представлять целые числа uint как int
}
type oleobj 
{
   uint ppv   
   uint flgdotcreate
   uint pflgs
   uint err
   uint perrfunc
}

include {"variant.g"
}

import "Ole32.dll"
{
   uint CoInitializeEx( uint, uint )   
   //uint CoInitialize( uint ) 
   CoUninitialize()
   uint CoGetClassObject( uint, uint, uint, uint, uint )
   uint CoCreateInstance( uint, uint, uint, uint, uint )
   //uint CoCreateInstanceEx( uint, uint, uint, uint, uint, uint )
   uint CLSIDFromString( uint, uint )
   uint CLSIDFromProgID( uint, uint )
}

import "Oleaut32.dll"
{
   uint GetActiveObject( uint, uint, uint )
}

type olecom
{
   uint flginit
   uint lasterr   
}

global {
   uint oleinit 
   buf IDispatch = '\h00 04 02 00 00 00 00 00 c0 00 00 00 00 00 00 46'
   buf IClassFactory = '\h01 00 00 00 00 00 00 00 c0 00 00 00 00 00 00 46'
   buf INULL     = '\h00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00'
   olecom ole
}

define {
// COM initialization flags; passed to CoInitialize.
COINIT_APARTMENTTHREADED  = 0x2      // Apartment model
COINIT_MULTITHREADED      = 0x0      // OLE calls objects on any thread.
COINIT_DISABLE_OLE1DDE    = 0x4      // Don't use DDE for Ole1 support.
COINIT_SPEED_OVER_MEMORY  = 0x8      // Trade memory for speed.
  
CLSCTX_INPROC_SERVER	   = 0x1
CLSCTX_INPROC_HANDLER	= 0x2
CLSCTX_LOCAL_SERVER	   = 0x4
CLSCTX_INPROC_SERVER16	= 0x8
CLSCTX_REMOTE_SERVER	   = 0x10
CLSCTX_INPROC_HANDLER16	= 0x20
CLSCTX_INPROC_SERVERX86	= 0x40
CLSCTX_INPROC_HANDLERX86= 0x80
CLSCTX_ESERVER_HANDLER	= 0x100
  
DISPATCH_METHOD         =0x1
DISPATCH_PROPERTYGET    =0x2
DISPATCH_PROPERTYPUT    =0x4
DISPATCH_PROPERTYPUTREF =0x8
}

type COSERVERINFO
{
   uint dwReserved1
   uint pwszName
   uint pAuthInfo
   uint dwReserved2
}
 
method olecom.seterr( uint err )
{
   this.lasterr = err
}

func uint olecheck( uint errcode )
{
   uint ret = ? ( errcode & 0x80000000, 0, 1 )
   if !ret
   {  
      //print( hex2stru("Ole error [", errcode ) + "]\n" )
      ole.seterr( errcode )
   } 
   return ret
}

method olecom.init()
{
   if !this.flginit && olecheck( CoInitializeEx( 0, 
                                 $COINIT_APARTMENTTHREADED ) )
   {
      this.flginit = 1
   } 
}

method olecom.release
{
   if this.flginit
   {      
      CoUninitialize()      
      this.flginit = 0
   }  
}

method uint olecom.geterr()
{
   return this.lasterr
}

method olecom.noerr()
{
   this.lasterr = 0
}

method olecom.delete()
{
   this.release() 
}

/*-----------------------------------------------------------------------------
* Id: oleobj_release F3
* 
* Summary: Releasing the COM object. The method deletes the bond between the
           variable and the COM object and releases the COM object.
*
-----------------------------------------------------------------------------*/

method oleobj.release()
{  
   if this.ppv
   {  
      ((this.ppv->uint+8)->uint)->stdcall(this.ppv)      
      //this.flgcreate = 0
      this.ppv = 0
      //oleinit--
      //if !oleinit : CoUninitialize()
   }   
}

property oleobj.errfunc( uint val )
{
   this.perrfunc = val
}

method uint oleobj.check( uint rcode )
{
   this.err = rcode   
   if olecheck( rcode )
   {
      return 1
   }   
   if this.perrfunc
   {
      this.perrfunc->func( rcode )
   }   
   return 0
}

/*-----------------------------------------------------------------------------
* Id: oleobj_iserr F3
* 
* Summary: Enables to define whether or not an error occurs while working 
           with a COM object.
*           
* Return: Returns the HRESULT code of the last COM object operation.
*
-----------------------------------------------------------------------------*/

method uint oleobj.iserr()
{
   return olecheck( this.err )
}

/*-----------------------------------------------------------------------------
* Id: oleobj_getres F3
* 
* Summary: Result of the last operation. This method is applied for getting 
           an error code or a warning; the code is the C type of HRESULT. 
*
* Return: Returns the HRESULT code of the last COM object operation.
*
-----------------------------------------------------------------------------*/

method uint oleobj.getres()
{
   return this.err
}

/*-----------------------------------------------------------------------------
* Id: oleobj_createobj F2
* 
* Summary: The method creates a new COM object. Example: #srcg[
|oleobj excapp
|excapp.createobj( "Excel.Application", "" )
|//is equal to excapp.createobj( "{00024500-0000-0000-C000-000000000046}", "" ) |    
|excapp.flgs = $FOLEOBJ_INT
|excapp~Visible = 1] 
*
* Params: name - An object name, or the string representation of an object /
                 identifier - "{...}". 
          mashine - A computer name where the required object is created; /
                    if the current string is empty, the object is created /
                    in the current computer. 
*
* Return: #lng/retf#
*
-----------------------------------------------------------------------------*/

method uint oleobj.createobj( str name, str mashine )
{
   uint res
   uint pcf
   buf  iid
   buf  un
   COSERVERINFO csi     
   
   iid.expand(16)
   if ole.flginit 
   {  
      this.release()      
          
      res = this.check( CLSIDFromString( un.unicode( name ).ptr(), iid.ptr() ))
//         res = this.check( CLSIDFromString( un.unicode( name ).ptr(), iid.ptr() ))
                  	
      if res
      {	
         if &mashine
         {
            csi.pwszName = un.unicode( mashine ).ptr()
         }         
   	   res = this.check( CoGetClassObject( 
                     iid.ptr(), 
                     ?(&mashine && *mashine, $CLSCTX_REMOTE_SERVER,
                      $CLSCTX_LOCAL_SERVER | $CLSCTX_INPROC_SERVER ),
                     ?(&mashine,&csi,0), 
                     IClassFactory.ptr(), 
                     &pcf))
         if res 
         {        
//				print( "x \( ((pcf->uint + 12 )->uint )), \(pcf),
// \(IDispatch.ptr()), \( &this.ppv) \n " )        
            res = this.check( ((pcf->uint + 12 )->uint)->stdcall(
                                    pcf, 0, IDispatch.ptr(), &this.ppv ))
//				print( "9\n" )
         }
   	   if pcf : ((pcf->uint + 8)->uint)->stdcall( pcf );
         
         /*olecheck( CoCreateInstance( iid.ptr(), 0, 
                  $CLSCTX_LOCAL_SERVER | $CLSCTX_INPROC_SERVER, 
                  IDispatch.ptr(), &this.ppv ))*/     
         //if res : this.flgcreate = 1
      }
   }
   return res
}

method uint oleobj.getactiveobj( str name )
{
   uint res
   uint pcf
   buf  iid
   buf  un
   COSERVERINFO csi     
   
   iid.expand(16)
   if ole.flginit 
   {  
      this.release()      
          
      res = this.check( CLSIDFromString( un.unicode( name ).ptr(), iid.ptr() ))
//         res = this.check( CLSIDFromString( un.unicode( name ).ptr(), iid.ptr() ))
                  	
      if res
      {  
         res = this.check( GetActiveObject( iid.ptr(), 0, &pcf ) )
         if res
         {
            res = this.check( ((pcf->uint )->uint)->stdcall(
                                    pcf, IDispatch.ptr(), &this.ppv ))
         }               
      }
   }
   return res
}

/*-----------------------------------------------------------------------------
* Id: typevar_opeq_1 FC
* 
* Summary: Assign operation. #b[oleobj = VARIANT( VT_DISPATCH )].
*
* Return: The result #b(oleobj).
*
-----------------------------------------------------------------------------*/

operator oleobj = (oleobj left, VARIANT right )
{
   left.release()
   if (right.vt & $VT_TYPEMASK) == $VT_DISPATCH && uint(right.val)
   {        
      left.ppv = uint(right.val)
      ((uint(left.ppv)->uint+4)->uint)->stdcall(uint(left.ppv))
      //right.vt = 0
      uint parent = (&right.val + 4)->uint 
      if parent
      {
         left.perrfunc = parent->oleobj.perrfunc
         left.pflgs = parent->oleobj.pflgs
      }
   }
   return left
}

operator oleobj = (oleobj left, oleobj right )
{
   left.release()
   if right.ppv
   {        
      left.ppv = right.ppv
      ((uint(left.ppv)->uint+4)->uint)->stdcall(uint(left.ppv))
      left.perrfunc = right.perrfunc
      left.pflgs = right.pflgs      
   }
   return left
}


operator VARIANT = (VARIANT left, oleobj right )
{
   return left.fromg( oleobj, &right )   
}

method oleobj.delete()
{
   this.release()
}

property uint oleobj.flgs()
{
   return this.pflgs
} 

property oleobj.flgs( uint val )
{
   this.pflgs = val
}

method uint oleobj.dispatch ( str name, uint typeres, 
      uint addrres, collection pars)
{   
   buf  un
   int i, j
   uint pname = un.unicode(name).ptr()
   uint idmeth   
   uint typecall
   int  cargs
   uint dispidnamedargs = -3
   DISPPARAMS dp
   VARIANT    vres   
   arr        varg of VARIANT   
//Получаем код метода
   if !this.ppv || !this.check( ((this.ppv->uint+20)->uint)->stdcall( 
                        this.ppv, INULL.ptr(), &pname, 1, 0x00010000, &idmeth) )
   {   
      return 0
   }   
//Формируем параметры   
   if &pars : cargs = *pars
   varg.expand( cargs )
   if !typeres && addrres == -1
   {        
      dp.cNamedArgs = 1      
      typecall = $DISPATCH_PROPERTYPUT       
   }   
   else
   {
      typecall = $DISPATCH_METHOD
      if addrres : typecall |= $DISPATCH_PROPERTYGET       
   }
   for i = cargs-1, i >= 0, i--
   {  
      uint gtype = pars.gettype(i)
      if this.pflgs & $FOLEOBJ_INT
      {      
         if gtype == uint : gtype = int       
      } 
      //print( "gtype \(gtype) \(VARIANT) \(oleobj) \(pars.ptr(i)->uint)\n" )
      varg[j++].fromg( gtype, ?( gtype <= double, pars.ptr(i), 
                                 pars.ptr(i)->uint ))
   }     
   dp.rgvarg = varg.ptr()
   dp.rgdispidNamedArgs = &dispidnamedargs   
   dp.cArgs = cargs   
   //print( "idmeth = \(idmeth)\n" )
//Вызываем метод   
   if !this.check((this.ppv->uint+24)->uint->stdcall( this.ppv, idmeth, 
                   INULL.ptr(), 0, typecall, &dp, vres, 0, 0 ))
   {    
      return 0
   }
//Обрабатываем результаты
	if addrres && typeres == VARIANT 
	{  
		addrres->VARIANT.vt = vres.vt
		addrres->VARIANT.val = vres.val            
      if (vres.vt & $VT_TYPEMASK) == $VT_DISPATCH
      {  
         if uint(addrres->VARIANT.val)
         {            
            (&addrres->VARIANT.val + 4)->uint = &this
         }
         else
         {
            addrres->VARIANT.vt = 0
         }
      }      
	}
   vres.vt = 0
   if this.flgdotcreate 
   {  
      destroy( &this )
   }
   return 1
} 

method oleobj.call( collection pars, str name )
{
   //print( "CALL \(name) \(*pars)\n" )
   this.dispatch( name, 0, 0, pars )
}

method oleobj.setval( collection pars, str name )
{
//   print( "SETVAL \(name) \(&this)\n" )
   this.dispatch( name, 0, -1, pars )
}

method VARIANT oleobj.getval <result> ( collection pars, str name )
{
	//print( "GETVAL \(name) \(&result)\n" ) 
	this.dispatch( name, VARIANT, &result, pars )
}

method oleobj oleobj.getobj ( collection pars, str name )
{
   uint res
   VARIANT vres
   //print( "GETOBJ \n" ) 
   res as new( oleobj )->oleobj   
   this.dispatch( name, VARIANT, &vres, pars )   
   res = vres  
   res.flgdotcreate = 1
   res.pflgs = this.pflgs
   res.perrfunc = this.perrfunc 
     
   return res 
}

/* property oleboj.valset ()
{
}*/
func err( uint errcode )
{
   print( "Ole error ["+ hex2stru( errcode ) + "]\n" )
}


/*
 {$EXTERNALSYM IConnectionPointContainer}
  IConnectionPointContainer = interface
    ['{B196B284-BAB4-101A-B69C-00AA00341D07}']
    function EnumConnectionPoints(out Enum: IEnumConnectionPoints): HResult;
      stdcall;
    function FindConnectionPoint(const iid: TIID;
      out cp: IConnectionPoint): HResult; stdcall;
  end;

{ IEnumConnectionPoints interface }

  {$EXTERNALSYM IEnumConnectionPoints}
  IEnumConnectionPoints = interface
    ['{B196B285-BAB4-101A-B69C-00AA00341D07}']
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out Enum: IEnumConnectionPoints): HResult;
      stdcall;
  end;

{ IConnectionPoint interface }

  {$EXTERNALSYM IConnectionPoint}
  IConnectionPoint = interface
    ['{B196B286-BAB4-101A-B69C-00AA00341D07}']
    function GetConnectionInterface(out iid: TIID): HResult; stdcall;
    function GetConnectionPointContainer(out cpc: IConnectionPointContainer): HResult;
      stdcall;
    function Advise(const unkSink: IUnknown; out dwCookie: Longint): HResult; stdcall;
    function Unadvise(dwCookie: Longint): HResult; stdcall;
    function EnumConnections(out Enum: IEnumConnections): HResult; stdcall;
  end;
STDMETHODIMP CEventSink::Invoke(DISPID dispidMember,
    REFIID riid,
    LCID lcid,
    WORD wFlags,
    DISPPARAMS* pdispparams,
    VARIANT* pvarResult,
    EXCEPINFO* pexcepinfo,
    UINT* puArgErr)
{
    switch (dispidMember)
    {
        case DISPID_HTMLELEMENTEVENTS2_ONCLICK:
            OnClick();
            break;

        // Другие события
        ...

        default:
            break;
    }
    return S_OK;
}

STDMETHODIMP CEventSink::OnClick()
// Обрабатываем событие IHTMLElementEvetns2::OnClick
{
    ...
}
ПРИМЕЧАНИЕ
Идентификаторы, подобные DISPID_HTMLELEMENTEVENTS2_ONCLICK, определены в файле mshtmdid.h. Несмотря на то, что интерфейсы вида HTMLXXXEvents работают в Internet Explorer, начиная с версии 4.0, соответствующие заголовочные файлы появились только в Internet Client SDK (INetSDK) для IE 5.0 и выше. Поэтому, прежде чем компилировать примеры к этой статье, убедитесь, что у вас присутствуют свежие версии заголовочных файлов. Кстати, Platform SDK (содержащий InetSDK) за ноябрь 2001 можно найти на CD к этому номеру журнала.


Половина дела сделана, осталось подключиться к html-элементу, события которого нужно отслеживать.

Для этого необходимо:
Получить интерфейс IConnectionPointContainer требуемого элемента.
Через вызов метода IConnectionPointContainer::FindConnectionPoint получить точку соединения (интерфейс IConnectionPoint) элемента. В параметре REFIID riid этого метода следует передать идентификатор интересующего нас событийного интерфейса. Для событий html-элемента это, скорее всего, будет HTMLElementEvents2. 
Ну и, наконец, через вызов IConnectionPoint::Advise подключиться к событиям элемента. После того, как уведомления о событиях станут не нужны, отсоединиться от точки соединения, вызвав IConnectionPoint::Unadvise().

Сделать это можно, например, так:HRESULT hr;
IConnectionPointContainer* pCPC = NULL;
IConnectionPoint* pCP = NULL;
DWORD dwCookie;

// Объект поддерживает точки соединения?
hr = pElem->QueryInterface(IID_IConnectionPointContainer, (void**)&pCPC);

if (SUCCEEDED(hr))
{
    // Находим точку соединения для HTMLElementEvents2
    hr = pCPC->FindConnectionPoint(DIID_HTMLElementEvents2, &pCP);

    if (SUCCEEDED(hr))
    {
        // Подключаемся
        // pUnk указатель на IUnknown объекта - приемника событий
        hr = pCP->Advise(pUnk, &dwCookie);

        if (SUCCEEDED(hr))
        {
            // Подключились. Можно принимать события.
        }
        pCP->Release();
    }
    pCPC->Release();
}

*/

/*-----------------------------------------------------------------------------
* Id: olecom_desc F1
*
* Summary: A brief description of COM/OLE library. This library also contains
           the support of the #a(tvariant,VARIANT) type, used for data
           transmitting from/to COM objects.

           Variables of the #b(oleobj) type are used for working with the COM
           objects; furthermore, each variable of this type has one appropriate
           COM object. A COM objects method is called with the help of 
           the #a( lateoper, ~ late) binding operation. There are two ways of
           binding a COM object with a variable , as follows:
           #p[   
1. The #a(oleobj_createobj) method is used for creating a new COM object: 
#srcg[
|oleobj excapp
|excapp.createobj( "Excel.Application", "" )]]

#p[2. Binding a variable with the existing COM object (child) is returned by
 another COM object method call:#srcg[
|oleobj workbooks
|workbooks = excapp~WorkBooks]]

#p[The #b(oleobj) object can maintain the following kinds of late binding:] 
#ul[
|elementary method call #b(excapp~Quit), with/without parameters; 
|set value #b[excapp~Cells( 3, 2 ) = "Hello World!"]; 
|get value #b[vis = uint( excapp~Visible )]; 
call chain #b(excapp~WorkBooks~Add), equals the following expressions 
]
#srcg[
|oleobj workbooks
|workbooks = excapp~WorkBooks
|workbooks~Add]

#p[The method call can return only the #b(VARIANT) type, and the appropriate
 assignment operators and type cast operators are used to convert data to 
 basic Gentee types. Parameters of the COM objects methods call as well as 
 the assigned values are automatically converted to the appropriate VARIANT
 types. The following Gentee types can be used - #b('uint, int, ulong, long,
 float, double, str, VARIANT').]

#p[Use the #a(oleobj_release) method in order to release the COM object;
 otherwise, the COM object is released when the variable is deleted; also 
 the object is released when the variable is bound with another COM object.
Have a look at the example of using the COM object] 
#srcg[
|include : $"...\olecom.g"
|func ole_example 
|{
|   oleobj excapp   
|   excapp.createobj( "Excel.Application", "" )     
|   excapp.flgs = $FOLEOBJ_INT
|   excapp~Visible = 1   
|   excapp~WorkBooks~Add   
|   excapp~Cells( 3, 2 ) = "Hello World!"
}]
#p[The oleobj object has properties, as follows:] 
#ul[
uint #b(flgs) are flags. Flags value can be set or obtained; the property can
 contain the #b($FOLEOBJ_INT) flag, i.e. when transmitting data to the COM
 object the unsigned Gentee type of uint is automatically converted to the
| signed type of VARIANT( VT_I4 ) 
uint #b(errfunc) is an error handling function. A function address can be
 assigned to this property, so using the COM object this function will be 
 called as long as an error occurs; furthermore, this function must have 
 a parameter of the uint type, that contains an error code.
]
#p[All child objects automatically inherit the #b(flgs) property as well as 
the #b(errfunc) property.]
*
* Title: COM/OLE description
*
* Define:    
*
-----------------------------------------------------------------------------*/

//----------------------------------------------------------------------------

/*-----------------------------------------------------------------------------
* Id: tvariant F1
*
* Summary: VARIANT type. #b(VARIANT) is a universal type that is used for 
storing various data and it enables different programs to exchange data
 properly. This type represents a structure consisted of two main fields: 
 the first field is a type of the stored value, the second field is the 
 stored value or the pointer to a storage area. The #b(VARIANT) type is 
 defined as follows: 
#srcg[
|type VARIANT {
|   ushort vt          
|   ushort wReserved1     
|   ushort wReserved2     
|   ushort wReserved3 
|   ulong  val
}]
#p[
#b(vt) is a type code of the contained value ( type constants VT_*: $VT_UI4, $VT_I4, $VT_BSTR ... );#br#
#b(val) is a field used for storing values]
#p[
The library provides only some of the operations of the VARIANT type, however, you can use the fields of the given structure.
The example illustrates creation of the VARIANT( VT_BOOL ) variable:] 
#srcg[
|VARIANT bool
|....
|bool.clear()
|bool.vt = $VT_BOOL
|(&bool.val)->uint = 0xffff// 0xffff - VARIANT_TRUE]

#p[This example shows VARIANT operations] 
#srcg[
|uint val
|str  res
|oleobj ActWorkSheet
|VARIANT vval
|
|....
|vval = int( 100 )        //VARIANT( VT_I4 ) is being created
|excapp~Cells(1,1) = vval //equals excapp~Cells(1,1) = 100
|                        
|vval = "Test string"     //VARIANT( VT_BSTR ) is being created
|excapp~Cells(2,1) = vval //equals excapp~Cells(1,1) = "Test string"
|
|val = uint( excapp~Cells(1,1)~Value ) //VARIANT( VT_I4 ) is converted to uint 
|res = excapp~Cells(2,1)~Value         //VARIANT( VT_BSTR ) is converted to str
|ActWorkSheet = excapp~ActiveWorkSheet //VARIANT( VT_DISPATCH ) is converted 
to oleobj]
*
* Title: VARIANT
*
* Define:    
*
-----------------------------------------------------------------------------*/

//----------------------------------------------------------------------------

/*v1.arrcreate( $VT_VARIANT, %{3,0,2,0} )
   
   v1.arrfromg( %{0,0, 0.0001f} )
   b++
   v1.arrfromg( %{0,1, b++} )
   v1.arrfromg( %{1,0, b++} )
   v1.arrfromg( %{1,1, b++} )   
   v1.arrfromg( %{2,0, b++} )
   v1.arrfromg( %{2,1, b} )    
   exc_app.errfunc = &err*/
/*   
func a <main>
{
   oleobj exc
   
   


   exc.createobj( "Excel.Application", "" )
//   if ( !exc.createobj( "{00024500-0000-0000-C000-000000000046}", "" ) )
   {
   print("error\n" )
   }     
   exc.flgs = $FOLEOBJ_INT
   exc~Visible = 1   
   exc~WorkBooks~Add   
   VARIANT v 
   v.arrcreate( %{3,0,2,0} )//Создается массив с 3-мя строками и 2-мя столбцами
   
   v.arrfromg( %{0,0, 0.1234f} )    
   v.arrfromg( %{0,1, int(100)} )   
   v.arrfromg( %{2,1, "Testsssssssss" } )
   VARIANT x1,x2
   
   
 
   exc~Range( exc~Cells( 1, 1), exc~Cells( 3, 2 ) ) = v //Передача массива в COM объект
   
   collection x = %{0,%{1,2,%{3,4},5,6},7,8}
   uint i
   print("Coll\n")
   fornum i, *x
   {
      uint t
      print( "\(t=x.gettype(i))\n" )
      if t == collection
      {
         uint c as x[i]->collection
         uint j
         fornum j, *c
         {
            uint t
            print( "   \(t=c.gettype(j))\n" )
            if t == collection
            {
               uint d as c[j]->collection
               uint k
               fornum k, *d
               {
                  uint t
                  print( "      \(t=d.gettype(k))\n" )
                  print ( "      val = \(d[k])\n" )
               }   
            } 
            else
            {
               print ( "   val = \(c[j])\n" )
            }
            
         }   
      } 
      else
      {
         print ( "val = \(x[i])\n" )
      }
   }   
   getch()
   //exc~Quit   
}*/
