extern{ func f_endtagname }
//*****************************************************************************

//1-начало сущности & ;
func f_begent
{  
   if !X_curtext->xtext.txtype && 
      X_curtext->xtext.txaddr_code != X_ia 
   {  //Сохраняем текст
      X_curtext->xtext.txlen = X_ia - X_curtext->xtext.txaddr_code
      X_curtext->xtext.txtype = $TX_TEXT
   }
   if X_curtext->xtext.txtype 
   {      
      //Заготовка текста      
      if ++X_ncurtext == X_maxtext
      {         
         X_maxtext += (X_n = X_maxtext * 3 / 10)
         X_x->xml.texts.expand(X_n)
      }      
      X_curtext = &X_x->xml.texts[X_ncurtext]
   }      
   X_curnameoff = X_ia + 1       
}

//2-конец сущ
func f_endent
{
   //Сохраняем текст-сущность   
   X_sname.clear()
   X_curtext->xtext.txaddr_code = &X_x->xml.hentities[ X_sname.append( X_curnameoff, X_ia - X_curnameoff )]       
   X_curtext->xtext.txtype = $TX_ENTITY  
   //Заготовка текста    
   if ++X_ncurtext == X_maxtext
   {    
      X_maxtext += (X_n = X_maxtext * 3 / 10)
      X_x->xml.texts.expand(X_n)
   }  
   X_curtext = &X_x->xml.texts[X_ncurtext]
   X_curtext->xtext.txaddr_code = X_ia + 1
}

//3-конец числ сущ
func f_endentnum
{
   //Сохраняем текст-код   
   X_sname.clear()   
   X_curtext->xtext.txaddr_code = X_sname.append( ++X_curnameoff, X_ia - X_curnameoff ).int()
   X_curtext->xtext.txtype = $TX_SYMBOL
   //Заготовка текста
   if ++X_ncurtext == X_maxtext
   {      
      X_maxtext += (X_n = X_maxtext * 3 / 10)
      X_x->xml.texts.expand(X_n)
   }   
   X_curtext = &X_x->xml.texts[X_ncurtext]
   X_curtext->xtext.txaddr_code = X_ia + 1
} 

//4-конец шест сущ
func f_endenthex
{
   //Сохраняем текст-код
   X_sname.clear()
   X_sname.appendch( '0' )   
   X_curtext->xtext.txaddr_code =  X_sname.append( ++X_curnameoff, X_ia - X_curnameoff ).int()
   X_curtext->xtext.txtype = $TX_SYMBOL
   //Заготовка текста
   if ++X_ncurtext == X_maxtext
   {      
      X_maxtext += (X_n = X_maxtext * 3 / 10)
      X_x->xml.texts.expand(X_n)
   }   
   X_curtext = &X_x->xml.texts[X_ncurtext]
   X_curtext->xtext.txaddr_code = X_ia + 1
}

//*****************************************************************************

//5-начало значения атрибута
func f_begatrval
{
   //Запоминаем начало текста      
   X_curtext->xtext.txtype = 0
   X_curtext->xtext.txaddr_code = X_ia + 1   
}

//6-конец значения атрибута
func f_endatrval
{
   if !X_curtext->xtext.txtype && 
      X_curtext->xtext.txaddr_code != X_ia
   {  //Сохраняем текст
      X_curtext->xtext.txlen = X_ia - X_curtext->xtext.txaddr_code
      X_curtext->xtext.txtype = $TX_TEXT
   }
   if X_curtext->xtext.txtype 
   {
      //Заготовка текста
      if ++X_ncurtext == X_maxtext
      {         
         X_maxtext += (X_n = X_maxtext * 3 / 10)
         X_x->xml.texts.expand(X_n)
      }      
      X_curtext = &X_x->xml.texts[X_ncurtext]
   }
   
   X_x->xml.attribs[X_ncurattrib-1].attend = X_ncurtext   
}

//*****************************************************************************

//7-начало <? ?>, начало наименования
func f_begquest
{   
   if !X_curtext->xtext.txtype && 
      X_curtext->xtext.txaddr_code != X_ia - 1
   {  //Сохраняем текст
      X_curtext->xtext.txlen = X_ia - X_curtext->xtext.txaddr_code - 1
      X_curtext->xtext.txtype = $TX_TEXT
   }
   if X_curtext->xtext.txtype 
   {  //Заготовка текста     
      if ++X_ncurtext == X_maxtext
      {         
         X_maxtext += (X_n = X_maxtext * 3 / 10)
         X_x->xml.texts.expand(X_n)
      }      
      X_curtext = &X_x->xml.texts[X_ncurtext]      
   }   
   if X_curtag->xmlitem.tgstart != X_ncurtext
   {  //Сохраняем элемент-текст      
      X_curtag->xmlitem.tgtype = $TG_TEXT
      X_curtag->xmlitem.tgend = X_ncurtext
      X_curtag->xmlitem.nnext = ++X_ncurtag
      X_curtag->xmlitem.nparent = X_nparenttag
      //Заготовка нового элемента      
      if X_ncurtag == X_maxtag
      {         
         X_maxtag += (X_n = X_maxtag * 3 / 10)
         X_x->xml.tags.expand(X_n)
      }
      X_curtag = &X_x->xml.tags[X_ncurtag]
      X_curtag->xmlitem.xml = X_x
   }
   //Предварительное описание элемента <?
   X_curtag->xmlitem.tgtype = $TG_QUEST
   X_curtag->xmlitem.tgstart = X_ncurattrib
   X_curtag->xmlitem.nchild = 0
   X_curtag->xmlitem.nparent = X_nparenttag   
   X_curnameoff = X_ia + 1  
}

extern {
method str xmlitem.getattrib( str name, str result )
}
//8-конец <? ?>
func f_endquest
{   
   if !X_curtag->xmlitem.tgid
   {
      f_endtagname()
   }
   //Сохранение элемента <? 
   X_curtag->xmlitem.tgend = X_ncurattrib 
   X_curtag->xmlitem.nnext = ++X_ncurtag
   
   uint qxml as X_curtag->xmlitem 
   if X_x->xml.names[qxml.tgid] %== "xml"
   {   
      qxml.xml = X_x   
      str res
      qxml.getattrib( "encoding", res )
      if res %== "utf-8"
      {
         X_x->xml.encoding = 1
      }
   }
   
   //Заготовка элемента
   if X_ncurtag == X_maxtag
   {      
      X_maxtag += (X_n = X_maxtag * 3 / 10)
      X_x->xml.tags.expand(X_n)
   }   
   //Предварительное описание элемента-текста
   X_curtag = &X_x->xml.tags[X_ncurtag]
   
   X_curtag->xmlitem.xml = X_x
   X_curtag->xmlitem.tgtype = 0   
   X_curtag->xmlitem.tgstart = X_ncurtext   
   X_curtag->xmlitem.nparent = X_nparenttag  
   X_curtext->xtext.txaddr_code = X_ia + 1 
   
}

//*****************************************************************************

//9-конец наименования
func f_endtagname
{  
   X_sname.clear()         
   //Сохранение имени
   X_n = &X_x->xml.hnames[ X_sname.append( X_curnameoff, X_ia - X_curnameoff ) ]
   if !X_n->uint 
   {
      X_n->uint = *X_x->xml.names      
      X_x->xml.names.expand(1) 
      X_x->xml.names[X_n->uint] = X_sname           
   }
   X_curtag->xmlitem.tgid = X_n->uint
}

//*****************************************************************************

//10-начало имени атрибута
func f_begatr
{     
   X_curnameoff = X_ia  
} 

//11-конец имени атрибута
func f_endatr
{     
   X_sname.clear()   
   //Сохранение имени    
   X_n = &X_x->xml.hnames[ X_sname.append( X_curnameoff, X_ia - X_curnameoff ) ]
   if !X_n->uint 
   {
      X_n->uint = *X_x->xml.names      
      X_x->xml.names.expand(1) 
      X_x->xml.names[X_n->uint] = X_sname           
   }
   //Сохранение атрибута
   X_curattrib->xattrib.attid = X_n->uint   
   X_curattrib->xattrib.attstart = X_ncurtext
   //Заготовка атрибута
   if ++X_ncurattrib == X_maxattrib
   {      
      X_maxattrib += (X_n = X_maxattrib * 3 / 10)
      X_x->xml.attribs.expand(X_n)
   }   
   X_curattrib = &X_x->xml.attribs[X_ncurattrib]   
}

//*****************************************************************************

//12-начало <
func f_begtag
{  
   if !X_curtext->xtext.txtype && 
      X_curtext->xtext.txaddr_code != X_ia - 1
   {  //Сохраняем текст      
      X_curtext->xtext.txlen = X_ia - X_curtext->xtext.txaddr_code - 1
      X_curtext->xtext.txtype = $TX_TEXT
   }
   if X_curtext->xtext.txtype 
   {  
      //Заготовка текста
      if ++X_ncurtext == X_maxtext
      {         
         X_maxtext += (X_n = X_maxtext * 3 / 10)
         X_x->xml.texts.expand(X_n)
      }      
      X_curtext = &X_x->xml.texts[X_ncurtext]      
   }
   if X_curtag->xmlitem.tgstart != X_ncurtext
   {  //Сохраняем элемент текст
      X_curtag->xmlitem.tgtype = $TG_TEXT
      X_curtag->xmlitem.tgend = X_ncurtext
      X_curtag->xmlitem.nnext = ++X_ncurtag
      //Заготовка элемента
      if X_ncurtag == X_maxtag
      {         
         X_maxtag += (X_n = X_maxtag * 3 / 10)
         X_x->xml.tags.expand(X_n)
      }
      X_curtag = &X_x->xml.tags[X_ncurtag]
      X_curtag->xmlitem.xml = X_x
   }     
   //Предварительное описание элемента-тэга
   X_curtag->xmlitem.tgtype = $TG_TAG
   X_curtag->xmlitem.tgstart = X_ncurattrib
   X_curtag->xmlitem.nparent = X_nparenttag   
   X_curnameoff = X_ia
   //print( "< 2\n" ) 
}

//13-конец >, конец наименования если не было
func f_endtag
{  
   if !X_curtag->xmlitem.tgid : f_endtagname()
      
   //Запоминаем текущий тэг в стэке     
   if X_nstack == X_maxstack
   {
      X_stacktags.expand( 100 )
   } 
   X_stacktags[X_nstack++] = X_ncurtag
   X_stacktags[X_nstack++] = X_nparenttag   
   X_stacktags[X_nstack++] = X_ncurtext - X_ncurattrib + X_curtag->xmlitem.tgstart
      
   X_curtag->xmlitem.tgend = X_ncurattrib
   
   X_nparenttag = X_ncurtag++
   
   //Заготовка элемента  
   if X_ncurtag == X_maxtag
   {      
      X_maxtag += (X_n = X_maxtag * 3 / 10)
      X_x->xml.tags.expand(X_n)
   }   
   X_curtag = &X_x->xml.tags[X_ncurtag]
   X_curtag->xmlitem.xml = X_x
   //Предварительное описание элемента текста
   X_curtag->xmlitem.tgtype = 0   
   X_curtag->xmlitem.tgstart = X_ncurtext   
   X_curtag->xmlitem.nparent = X_nparenttag   
   X_curtext->xtext.txaddr_code = X_ia + 1      
}

//14-конец /> конец наименования если не было)
func f_endtagend
{   
   if !X_curtag->xmlitem.tgid: f_endtagname()
   
   //Сохранение элемента тэга
   X_curtag->xmlitem.tgtype = $TG_NOCHILD
   X_curtag->xmlitem.tgend = X_ncurattrib   
   X_curtag->xmlitem.nnext = ++X_ncurtag
   
   //Заготовка элемента   
   if X_ncurtag == X_maxtag
   {  
      X_maxtag += (X_n = X_maxtag * 3 / 10)
      X_x->xml.tags.expand(X_n)
   }
   X_curtag = &X_x->xml.tags[X_ncurtag]
   X_curtag->xmlitem.xml = X_x
   //Предвариельное описание элемента текста
   X_curtag->xmlitem.tgtype = 0
   X_curtag->xmlitem.tgstart = X_ncurtext
   X_curtag->xmlitem.nparent = X_nparenttag
   X_curtext->xtext.txaddr_code = X_ia + 1   
}

//*****************************************************************************
extern { method str xmlitem.getname( str res ) }
//15-начало </ начало наименования
func f_begendtag
{
   if !X_curtext->xtext.txtype && 
      X_curtext->xtext.txaddr_code != X_ia - 1
   {  //Сохраняем текст      
      X_curtext->xtext.txlen = X_ia - X_curtext->xtext.txaddr_code - 1
      X_curtext->xtext.txtype = $TX_TEXT       
   }
   if X_curtext->xtext.txtype 
   {  //Заготовка текста
      if ++X_ncurtext == X_maxtext
      {         
         X_maxtext += (X_n = X_maxtext * 3 / 10)
         X_x->xml.texts.expand(X_n)
      }      
      X_curtext = &X_x->xml.texts[X_ncurtext]               
   }
   uint flgaddtext
   if X_curtag->xmlitem.tgstart != X_ncurtext
   {  //Сохраняем элемент текст
      X_curtag->xmlitem.tgtype = $TG_TEXT
      X_curtag->xmlitem.tgend = X_ncurtext   
      X_curtag->xmlitem.nnext = ++X_ncurtag
      //Заготовка элемента
      if X_ncurtag == X_maxtag
      {         
         X_maxtag += (X_n = X_maxtag * 3 / 10)
         X_x->xml.tags.expand(X_n)
      }
      X_curtag = &X_x->xml.tags[X_ncurtag]
      X_curtag->xmlitem.xml = X_x     
      flgaddtext = 1     
   }   
   if X_nstack 
   {  //Вытаскиваем последний элемент из стэка
      uint ntext = X_stacktags[--X_nstack]
      X_nparenttag = X_stacktags[--X_nstack]      
      X_tparenttag = &X_x->xml.tags[X_n = X_stacktags[--X_nstack]]
      if X_n != X_ncurtag - 1      
      {
         X_tparenttag->xmlitem.nchild = X_n + 1
         X_x->xml.tags[X_ncurtag-1].nnext = 0
         if X_n != X_curtag - 2 && flgaddtext
         {
            X_x->xml.tags[X_ncurtag-2].nnext = 0
         }
                                             
         //print( "next4=\(0) \(X_ncurtag-1) \(X_n)\n" )         
      }
      X_tparenttag->xmlitem.nnext = X_ncurtag
      
      //print( "zzz \(X_x->xml.names[X_tparenttag->xmlitem.tgid])\n" )
      uint addr = hrealtime->hash[X_x->xml.names[X_tparenttag->xmlitem.tgid]]
      if addr && addr->func( X_tparenttag )
      {
         uint n
         
         n = X_curattrib
         X_ncurattrib = X_tparenttag->xmlitem.tgstart
         X_curattrib = &X_x->xml.attribs[X_ncurattrib]
         mzero( X_curattrib, n - X_curattrib ) 
         
         n = X_curtext
         X_ncurtext = ntext
         X_curtext = &X_x->xml.texts[X_ncurtext]
         mzero( X_curtext, n - X_curtext )
         X_curtext->xtext.txaddr_code = X_ia + 1         
         
         n = X_curtag
         X_ncurtag = X_n 
         X_curtag = &X_x->xml.tags[X_ncurtag]
         mzero( X_curtag, n - X_curtag )        
         X_curtag->xmlitem.xml = X_x      
         return  
      }
   } 
   else
   {
      X_x->xml.err = 2
   }   
}

//16-конец </ > 
func f_begendtagend
{  
   //Предварительное описание элемента текста
   X_curtag->xmlitem.tgtype = 0
   X_curtag->xmlitem.tgstart = X_ncurtext
   X_curtag->xmlitem.nparent = X_nparenttag   
   X_curtext->xtext.txaddr_code = X_ia + 1   
}

//*****************************************************************************

//17-начало <![CDATA[ ]]>
func f_begcdata
{     
   if !X_curtext->xtext.txtype && 
      X_curtext->xtext.txaddr_code != X_ia - 8
   {  //Заканчиваем текст
      X_curtext->xtext.txlen = X_ia - X_curtext->xtext.txaddr_code - 8
      X_curtext->xtext.txtype = $TX_TEXT
   }
   if X_curtext->xtext.txtype 
   {      
      //Добавляем заготовку элемента  
      if ++X_ncurtext == X_maxtext
      {         
         X_maxtext += (X_n = X_maxtext * 3 / 10)
         X_x->xml.texts.expand(X_n)
      }    
      X_curtext = &X_x->xml.texts[X_ncurtext]
   }   
   X_curtext->xtext.txaddr_code = X_ia + 1 
}

//18-конец <![CDATA[ ]]>
func f_endcdata
{
   //Заканчиваем текущий текст  
   X_curtext->xtext.txlen = X_ia - 2 - X_curtext->xtext.txaddr_code
   X_curtext->xtext.txtype = $TX_TEXT   
   //Добавляем заготовку текста   
   if ++X_ncurtext == X_maxtext
   {      
      X_maxtext += (X_n = X_maxtext * 3 / 10)
      X_x->xml.texts.expand(X_n)
   }   
   X_curtext = &X_x->xml.texts[X_ncurtext]   
   X_curtext->xtext.txaddr_code = X_ia + 1
}

//*****************************************************************************

func f_error
{
   X_x->xml.err = 1
   //print( "ERROR \X_n" )
}
