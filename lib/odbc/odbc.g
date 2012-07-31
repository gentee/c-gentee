/******************************************************************************
*
* Copyright (C) 2006-2008, The Gentee Group. All rights reserved. 
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
* Id: odbc L "ODBC (SQL)"
* 
* Summary: Data Access (SQL queries) Using ODBC. This library is applied for
           running SQL queries on a database using ODBC. The queries with
           parameters are not supported by the current version. Read
           #a(odbc_desc) for more details. For using this 
           library, it is required to specify the file odbc.g (from lib\odbc
           subfolder) with include command. #srcg[
|include : $"...\gentee\lib\odbc\odbc.g"]   
*
* List: *,odbc_desc,
        *#lng/methods#,odbc_connect,odbc_disconnect,odbc_geterror,
        odbc_newquery,
        *SQL query methods,odbcquery_active,odbcquery_close,
        odbcquery_fieldbyname,odbcquery_first,odbcquery_geterror,
        odbcquery_getrecordcount,odbcquery_last,odbcquery_moveby,
        odbcquery_next,odbcquery_prior,odbcquery_run,odbcquery_settimeout,
        *Field methods,odbcfield_getbuf,odbcfield_getdatetime,
        odbcfield_getdouble,odbcfield_getindex,odbcfield_getint,
        odbcfield_getlong,odbcfield_getname,odbcfield_getnumeric,
        odbcfield_getstr,odbcfield_gettype,odbcfield_isnull
* 
-----------------------------------------------------------------------------*/

import "odbc32.dll"
{
   uint SQLAllocHandle( uint, uint, uint )
   uint SQLBindCol( uint, uint, uint, uint, uint, uint )
   uint SQLCloseCursor( uint )   
   uint SQLConnect( uint, uint, uint, uint, uint, uint, uint )
   uint SQLDescribeCol( uint, uint, uint, uint, uint, uint, uint, uint, uint )
   uint SQLDisconnect( uint )   
   uint SQLDriverConnect( uint, uint, uint, uint, uint, uint, uint, uint )   
   uint SQLExecDirect( uint, uint, uint )
   uint SQLFetch( uint )
   uint SQLFetchScroll( uint, uint, uint )
   uint SQLFreeHandle( uint, uint )
   uint SQLFreeStmt( uint, uint )   
   uint SQLGetConnectAttr( uint, uint, uint, uint, uint )  
   uint SQLGetData( uint, uint, uint, uint, uint, uint )
   uint SQLGetDiagRec( uint, uint, uint, uint, uint, uint, uint, uint )
   uint SQLGetStmtAttr( uint, uint, uint, uint, uint )
   uint SQLGetInfo( uint, uint, uint, uint, uint )         
   uint SQLNumResultCols( uint, uint )   
   uint SQLRowCount( uint, uint )
   uint SQLSetEnvAttr( uint, uint, uint, uint )
   uint SQLSetStmtAttr( uint, uint, uint, uint )   
   uint SQLSetConnectAttr( uint, uint, uint, uint )
}

define
{
   ODBC_POCKET_SIZE = 65535//1500000//2097152
//Установка версии
   SQL_ATTR_ODBC_VERSION = 200
   SQL_OV_ODBC3 = 3  
   
//Типы дескрипторов   
   SQL_HANDLE_ENV  = 1
   SQL_HANDLE_DBC  = 2
   SQL_HANDLE_STMT = 3
   SQL_HANDLE_DESC = 4   
   
//Возвращаемые значения функций SQL*       
   SQL_SUCCESS           = 0   
   SQL_SUCCESS_WITH_INFO = 1
   SQL_NO_DATA           = 100
   SQL_ERROR             = 0xFFFF//-1
   SQL_INVALID_HANDLE    = 0xFFFE//-2
   SQL_STILL_EXECUTING   = 2
   SQL_NEED_DATA         = 99  
   
   SQL_DRIVER_COMPLETE=1
   SQL_DRIVER_NOPROMPT=0    
   
   SQL_CLOSE = 0
   SQL_UNBIND = 2   

//Установка статичного курсора      
   SQL_ATTR_CURSOR_TYPE = 6  
   SQL_ATTR_QUERY_TIMEOUT = 0
   SQL_CURSOR_STATIC    = 3   
       
//Типы данных
	SQL_UNKNOWN_TYPE	= 0
   SQL_CHAR          = 1
   SQL_NUMERIC       = 2
   SQL_DECIMAL       = 3
   SQL_INTEGER       = 4
   SQL_SMALLINT      = 5
   SQL_FLOAT         = 6
   SQL_REAL          = 7
   SQL_DOUBLE        = 8
   SQL_VARCHAR       = 12    
   SQL_LONGVARCHAR    = 0xFFFF//-1
   SQL_BINARY         = 0xFFFE//-2
   SQL_VARBINARY      = 0xFFFD//-3
   SQL_LONGVARBINARY  = 0xFFFC//-4
   SQL_BIGINT         = 0xFFFB//-5
   SQL_TINYINT        = 0xFFFA//-6
   SQL_BIT            = 0xFFF9//-7
   SQL_WCHAR		 	 = 0xFFF8//-8
   SQL_WVARCHAR	 	 = 0xFFF7//-9
   SQL_WLONGVARCHAR 	 = 0xFFF6//-10   
   SQL_TYPE_DATE      = 91
   SQL_TYPE_TIME      = 92
   SQL_TYPE_TIMESTAMP = 93 
 
 
   SQL_FETCH_NEXT       = 1       
   SQL_FETCH_FIRST      = 2 
   SQL_FETCH_LAST       = 3
   SQL_FETCH_PRIOR      = 4   
   SQL_FETCH_ABSOLUTE   = 5
   SQL_FETCH_RELATIVE   = 6
   SQL_FETCH_BOOKMARK   = 7
   
   //Передача значений
   SQL_ATTR_ROW_NUMBER		   = 14
   SQL_IS_POINTER					= -4
   SQL_IS_UINTEGER            = -5
   SQL_IS_INTEGER					= -6
   SQL_NTS                    = -3
 
   NUMERIC_SIZE = 19
   
   SQL_PACKET_SIZE  = 112
   SQL_ATTR_PACKET_SIZE = 112
   SQL_ATTR_ROW_ARRAY_SIZE	 = 27	
   
   MAXFIELDSIZE = 0x400000//255//1024
   //SQL_DIAG_CURSOR_ROW_COUNT =-1249
}

type odbc {
//private
   uint henv      //Дескриптор ODBC
   uint hconn     //Дескриптор соединения 
   uint connected //Флаг есть соединение     
//public
   str  connectstr   //Отформатированная строка для соединения
   str  dsn          //Название источника данных созданного в ODBC
   str  user         //Пользователь для dsn
   str  psw          //Пароль для dsn
   uint hwnd         //Дескриптор окна для запроса дополнительных данных
   uint fprompt      //Флаг возможности запроса дополнительных данных
   uint packetsize   
   arr  arrqueries of uint
}

method uint odbc.err ( uint type_handle  handle, str state msg )
{  
   uint err       
   uint ret, res
      
   state.reserve( 11 )   
   msg.reserve( 1025 )
   SQLGetDiagRec( type_handle, handle, 1, state.ptr(), &err, msg.ptr(), 1024, &ret ) &0xFFFF
   state.setlenptr( )
   msg.setlen( ret & 0xFFFF )
   //s = "Message: ErrCode=\(err), State=\( state ), Msg=\"\( msg )\" " 
   return err      
}

/*-----------------------------------------------------------------------------
* Id: odbc_geterror F2
*
* Summary: Get the last error message. Gets the message if the last error
           occured while connecting to the database.
*
* Params: state - This string will contain the current state. 
          message - This string will contain an error message. 
*  
* Return: Returns the last error code.   
*
-----------------------------------------------------------------------------*/

method uint odbc.geterror( str state, str message )
{
   return this.err( $SQL_HANDLE_DBC, this.hconn, state, message ) 
}

func uint chsql( uint res )
{
   res &= 0xFFFF
   if res == $SQL_SUCCESS || res == $SQL_SUCCESS_WITH_INFO : return 1   
   return 0
}

include 
{
"odbcfield.g"
"odbcquery.g" 
}

/*-----------------------------------------------------------------------------
* Id: odbc_disconnect F3
*
* Summary: Disconnect from a database.
*
-----------------------------------------------------------------------------*/

method odbc.disconnect()
{
   if this.connected : SQLDisconnect( this.hconn )
   if this.hconn : SQLFreeHandle( $SQL_HANDLE_DBC, this.hconn )
   if this.henv : SQLFreeHandle( $SQL_HANDLE_ENV, this.henv )   
   this.connected = this.henv = this.hconn = 0      
}

method uint odbc.connect()
{
   uint res
   
   this.henv = 0
   this.hconn = 0
   if (  chsql( 
      SQLAllocHandle( $SQL_HANDLE_ENV, this.henv , &this.henv )) && 
         chsql( 
      SQLSetEnvAttr( this.henv, $SQL_ATTR_ODBC_VERSION, $SQL_OV_ODBC3, 0 )) && 
         chsql( SQLAllocHandle( $SQL_HANDLE_DBC, this.henv, &this.hconn )))
   {
      SQLSetConnectAttr(  this.hconn, $SQL_ATTR_PACKET_SIZE, $ODBC_POCKET_SIZE, $SQL_IS_UINTEGER )
       
      if *this.connectstr
      {
         str out
         uint outsize
         out.reserve( 1024 )         
         res = SQLDriverConnect( this.hconn, ?( this.fprompt, this.hwnd, 0 ), 
               this.connectstr.ptr(), *this.connectstr, out.ptr(), 
               out->buf.size, &out->buf.use, 
               ?( this.fprompt, $SQL_DRIVER_COMPLETE , $SQL_DRIVER_NOPROMPT))
      } 
      else 
      {
         res = SQLConnect( this.hconn, this.dsn.ptr(), *this.dsn, 
               this.user.ptr(), *this.user, this.psw.ptr(), *this.psw )          
      }
      /*res = SQLGetConnectAttr(  this.hconn, $SQL_ATTR_PACKET_SIZE, &this.packetsize, $SQL_IS_POINTER, &res )
      print( "packetsize=\(this.packetsize) \(res&0xFFFF)\n" )
      str s
      this.err( $SQL_HANDLE_DBC, this.hconn, s )
      print( "res =\(res&0xffff)   "+s +"\n") */  
      if chsql( res )
      {
         this.connected = 1
         return 1
      }
   } 
   this.disconnect()
   return 0   
}

/*-----------------------------------------------------------------------------
* Id: odbc_connect F2
*
* Summary: Create a database connection. You can connect to a database using 
           a string connection or a DSN name. #p[ The method is called in 
           order to connect to the database with the help of the string
           connection. Use The ODBC connection string for this purpose, that
           contains a driver type, a database name and some additional
           parameters. The example below shows a type of the string connected 
           to the SQL server: #b( '"Driver={SQL Server};Server=MSSQLSERVER;
           Database=mydatabase;Trusted_Connection=yes;"') ]  
*
* Params: connectstr - Connection string.  
*  
* Return: Returns 1 if the connection is successful; otherwise, returns 0. 
*
-----------------------------------------------------------------------------*/

method uint odbc.connect( str connectstr )
{
   this.connectstr = connectstr
   return this.connect()
}

/*-----------------------------------------------------------------------------
* Id: odbc_connect_1 FA
*
* Summary: This method is used to connect to the database through the 
           previously defined connection (the DSN name).   
*
* Params: dsn - Name of a previously defined connection - DSN. 
          user - User name. 
          psw - User password. 
*  
* Return: Returns 1 if the connection is successful; otherwise, returns 0. 
*
-----------------------------------------------------------------------------*/

method uint odbc.connect( str dsn, str user, str psw )
{
   this.dsn = dsn
   this.user = user
   this.psw = psw  
   return this.connect()
}

/*-----------------------------------------------------------------------------
* Id: odbc_newquery F3
*
* Summary: Create a new ODBC query. Creates a new ODBC query for the 
           particular ODBC connection. Several queries are likely to be 
           created for one connection. Queries are created inside the ODBC
           object and deleted in case of its deletion. 
*
* Return: A new ODBC query.  
*
-----------------------------------------------------------------------------*/

method odbcquery odbc.newquery()
{
   uint nq = *this.arrqueries
   this.arrqueries.expand(1)
   this.arrqueries[nq] = new( odbcquery )
   this.arrqueries[nq]->odbcquery.setodbc( this ) 
   return this.arrqueries[nq]->odbcquery 
}

method odbc.delete()
{
   foreach q, this.arrqueries
   {
      destroy( q )
   }
}

/*-----------------------------------------------------------------------------
* Id: odbc_desc F1
*
* Summary: A brief description of ODBC library. The object of the #b(odbc)
type provides connection to a database. The objects of the #b(odbcquery) type
are used to run SQL queries and move the cursor through a result set. This
object has got the #b(arr fields[] of odbcfield) array that contains result 
set fields #b(odbcfield); furthermore, the number of elements of the array
equals the number of the fields.

#p[The objects of the #b(odbcfield) type make it possible to get the required
information of the field as well as the field's value (depending on the 
current position of the cursor in the result set).]

#p[The sequence of operations for working with the database:] 
#ul[
|create an ODBC connection to the database using the #a(odbc_connect) method; 
create a new ODBC query using the #a(odbc_newquery) method. Note that several
|queries are likely to be created for one connection; 
run a SQL query using the #a(odbcquery_run) method; the query may retrieve the
result set (the #b(SELECT) command) or no data (the #b(INSERT) command, the
| #b(UPDATE) command etc.); 
move the cursor through the result set using the following methods:
#a(odbcquery_first), #a(odbcquery_next) etc. if necessary. The access is 
gained to the fields through the fields array #b(odbcquery.fields[i]), 
where i - a field number begining from 0, or with the 
| #a(odbcquery_fieldbyname) method; 
use the #a(odbcfield_getstr) method, the #a(odbcfield_getint) method etc. 
|in order to get field values; 
|run the next SQL query after processing if necessary; 
|disconnect from the database using the ODBC method #a(odbc_disconnect).
]
#p[There are some peculiarities to keep in mind when working with ODBC 
drivers:#br#
while running a SQL query with the help of multiple sequential
statements of the "INSERT ..." type, only some of the query statements are 
being executed (there can be from 300 to 1000 statements used for the "SQL
server" driver) and no error message is displayed. In this case, you had 
better divide such queries into several parts;#br#
some types of drivers do not make it possible to calculate the total number
of messages received by the SQL query.]
*
* Title: ODBC description
*
* Define:    
*
-----------------------------------------------------------------------------*/

//----------------------------------------------------------------------------
