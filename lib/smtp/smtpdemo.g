/******************************************************************************
*
* Copyright (C) 2009, The Gentee Group. All rights reserved. 
* This file is part of the Gentee open source project - http://www.gentee.com. 
* 
* THIS FILE IS PROVIDED UNDER THE TERMS OF THE GENTEE LICENSE ("AGREEMENT"). 
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS FILE CONSTITUTES RECIPIENTS 
* ACCEPTANCE OF THE AGREEMENT.
*
* Author: Alexey Krivonogov ( gentee )
*
******************************************************************************/

include : "smtp.g"

func uint smtpnotify( uint code, inetnotify ni )
{
   switch code
   {
      case $NFYINET_ERROR
      {
         print("Error [\(code)]: \(ni.head)\l")
      }
      case $NFYINET_CONNECT : print("Connecting \(ni.url)...\n")
      case $NFYSMTP_SENDCMD : print("TO: \(ni.head)\n")
      case $NFYSMTP_RESPONSE : print("FROM: \(ni.head)\n")
/*      default
      {
         print("NFY \(code ): \(ni.url) H=\(ni.head) \( ni.param) \(ni.sparam)\l")
      }*/
   }
   return 1
}

func smtptest<main>
{
   smtp test
   
   inet_init()
   test.open( "mail.domain.com", 25, "my@domain.com", "password", &smtpnotify )
   test.send( "John Smith <my@domain.com>",
       "john@domain.com, John Smith JR <jr@domain.com>", "Subject", 
              "Body of the email message", "" )
   test.close()
   inet_close()
   congetch("Press any key...")
}
