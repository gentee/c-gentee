#exe = 0
#norun = 0
#gefile = 0
#libdir = %EXEPATH%\lib
#libdir1 = %EXEPATH%\..\lib\vis
#include = %EXEPATH%\lib\stdlib.ge
#wait = 1
/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexander Antypenko ( santy )
*
******************************************************************************/

include
{
 $"sqlite3.g"
}

func sqlite3_demo <main>
{
  sqlite3 demo_data

  print("DEMO SQLITE3 DATABASE FUNCTIONS \n\n")
  print("--- open database --- \n\n")

  if (demo_data.open("demo_dat.db")) {
   print("database opened/created,  ... Ok \n")
  }
  else : print("problem opening/creating database \n")
  //getch()
  print("--- create table --- \n\n")

  if (demo_data.sql_execute("CREATE TABLE test_table (name TEXT, qty INT(3), price REAL(10), blobtext BLOB)"))
  {
    print("created table test_table,  ... Ok \n")
  }
  else : print("problem creating table < test_table > \n")

  if (demo_data.sql_execute("CREATE TABLE tst_tbl (name TEXT, qty INT(3), price REAL(10), blobtext BLOB, demo_text TEXT)"))
  {
    print("created table test_table,  ... Ok \n")
  }
  else : print("problem creating table < tst_tbl > \n")


  //getch()
  print("--- insert data into exist table --- \n\n")

  if (demo_data.sql_execute("insert into test_table values ('apples', 11, 1.234, X'41424300010101');"))
  {
    print("inserted, last row id: "+str(demo_data.rowid())+"  ... Ok \n")
  }
  else : print("problem inserting row \n")
  if (demo_data.sql_execute("insert into test_table values ('oranges', 22, 2.345, X'42434400020202');"))
  {
    print("inserted, last row id: "+str(demo_data.rowid())+"  ... Ok \n")
  }
  else : print("problem inserting row \n")

  if (demo_data.sql_execute("insert into test_table values ('bananas', 33, 3.456, X'44454600030303');"))
  {
    print("inserted, last row id: "+str(demo_data.rowid())+"  ... Ok \n")
  }
  else : print("problem inserting row \n")
  if (demo_data.sql_execute("insert into test_table values ('grapes', 123456789012345678, 7.89, X'47484900040404');"))
  {
    print("inserted, last row id: "+str(demo_data.rowid())+"  ... Ok \n")
  }
  else : print("problem inserting row \n")
  //getch()
  print("--- select data from table --- \n\n")

  if (demo_data.sql_execute("select * from test_table;"))
  {
    uint i,j

    print("selected rows: \n")
    fornum i=0,*demo_data.col_val
    {
      fornum j=0,*demo_data.col_val[i].values
      {
        print("("+ demo_data.col_val[i].values[j]+") \n") 
      }     
    }
   
    print("column names:  \n")
    fornum i=0,*demo_data.col_names
    {
      print("Field -> "+ demo_data.col_names[i]+" \n") 
    }
  }
  else : print("problem selecting rows \n")

  if (demo_data.sql_execute("delete from test_table where 1;"))
  {
    print("deleted, rows affected: "+str(demo_data.changes())+",  ... Ok \n")
  }
  else : print("problem deleting rows \n")
  
  arrstr asTables
  if (demo_data.tables(asTables))
  {
    uint i
    fornum i=0, *asTables {
      print("tables: "+asTables[i]+",  ... Ok \n")
    }
  }
  else : print("problem in tables method \n")

  arrstr asColumns
  if (demo_data.columns("test_table",asColumns))
  {
    uint i
    fornum i=0, *asColumns {
      print("Columns: "+asColumns[i]+",  ... Ok \n")
    }
  }
  else : print("problem in columns method \n")
  demo_data.beginTrans()
  if (demo_data.sql_execute("drop table test_table;")) {
    demo_data.commitTrans()
    print("table test_table dropped,  ... Ok \n")
  }
  else : print("problem dropping table test_table \n")


  demo_data.close()
  getch()
}
