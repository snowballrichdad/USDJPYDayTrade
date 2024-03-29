//+------------------------------------------------------------------+
//|                                                  morningScal.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <stdlib.mqh>
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double firstHourAsk = 0.0;
double secondHourAsk = 0.0;
double firstHourBid = 0.0;
double secondHourBid = 0.0;
extern int firstMinute = 30;
extern int firstHour = 8;
extern int secondMinute = 30;
extern int secondHour = 11;
extern int forceExitHour = 15;
int ordeticket = 0;
extern double lots = 0.04;
extern int    MAGIC = 62634; //マジックナンバー
extern double BUY_DELTA = 0.05;
extern double SELL_DELTA = 0.06;
extern double BUY_TP_MARGIN = 0.5;
extern double BUY_SL_MARGIN = 0.2;
extern double SELL_TP_MARGIN = 0.5;
extern double SELL_SL_MARGIN = 0.2;
int day = 0;
bool firstset = false;
bool secondset = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
//   EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
//   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

//   double lots = MathFloor(AccountBalance() / 50000 * 100) / 100;

   if(day != Day())
   {
      Print("###aaa");
      day = Day();
      firstset = false;
      secondset = false;
   }
   
   if(!firstset)
   {
      if(Hour() == firstHour - 6 && Minute()== firstMinute)
      {
         firstset = true;
         firstHourAsk = Ask;
         firstHourBid = Bid;
         Print("###bbb");
      }
   }
   
   if(firstset && !secondset)
   {
   
      
      if(Hour() == secondHour - 6 && Minute()== secondMinute)
      {
         Print("###ccc");
         secondset = true;

         secondHourAsk = Ask;
         secondHourBid = Bid;
         
         //if(firstHourAsk < secondHourAsk - BUY_DELTA)
         //{
            Print("###ddd");
            // まずはSL/TPなしで発注
            ordeticket=OrderSend(Symbol(),OP_BUY,lots,Ask,100,0,0,"buy",MAGIC,0,clrPink);
            if(ordeticket == -1)
            {
               Print("###Order Buy 001");
               Print(ErrorDescription(GetLastError()));
               return;
            }
            
            // OrderPriceが確定してから、TP/SLを設定
            if(OrderSelect(ordeticket,SELECT_BY_TICKET)==true)
            {
      
               double openPrice = OrderOpenPrice();
               double currentTP = NormalizeDouble(openPrice + BUY_TP_MARGIN,Digits);
               double currentSL = NormalizeDouble(openPrice - BUY_SL_MARGIN,Digits);
               if(!OrderModify(ordeticket,Bid,currentSL,currentTP,0,clrYellow))
               {
                   Print("###Order Modify 002");
                   Print(ErrorDescription(GetLastError()));
               }
            }
            
//         }else if(firstHourBid > secondHourBid + SELL_DELTA){
//            Print("###eee");
//            // まずはSL/TPなしで発注
//            ordeticket=OrderSend(Symbol(),OP_SELL,lots,Ask,100,0,0,"sell",MAGIC,0,clrPink);
//            if(ordeticket == -1)
//            {
//               Print("###Order Buy 001");
//               Print(ErrorDescription(GetLastError()));
//               return;
//            }
//            
//            // OrderPriceが確定してから、TP/SLを設定
//            if(OrderSelect(ordeticket,SELECT_BY_TICKET)==true)
//            {
//      
//               double openPrice = OrderOpenPrice();
//               double currentTP = NormalizeDouble(openPrice - SELL_TP_MARGIN,Digits);
//               double currentSL = NormalizeDouble(openPrice + SELL_SL_MARGIN,Digits);
//               if(!OrderModify(ordeticket,Ask,currentSL,currentTP,0,clrYellow))
//               {
//                   Print("###Order Modify 002");
//                   Print(ErrorDescription(GetLastError()));
//               }
//            }
//               
//           }
         }
      }
      
      if(Hour() == forceExitHour -6 && Minute()== 0)
      {
         if(OrdersTotal() > 0)
         {
            if(!OrderClose(ordeticket,lots,Bid,1000,clrAliceBlue))
            {
               Print("###exit");
               Print(ErrorDescription(GetLastError()));
            };         
         }
      }
   
  }
////+------------------------------------------------------------------+
////| Timer function                                                   |
////+------------------------------------------------------------------+
//void OnTimer()
//  {
////---
//      if(Hour() == firstHour - 6 && Minute()== firstMinute)
//      {
//         firstHourPrice = Ask;
//      }
//
//      if(Hour() == secondHour - 6 && Minute()== secondMinute)
//      {
//         secondHourPrice = Ask;
//         
//         if(firstHourPrice < secondHourPrice)
//         {
//            // まずはSL/TPなしで発注
//            ordeticket=OrderSend(Symbol(),OP_BUY,LOTS,Ask,100,0,0,"buy",MAGIC,0,clrYellow);
//            if(ordeticket == -1)
//            {
//               Print("###Order Buy 001");
//               Print(ErrorDescription(GetLastError()));
//               return;
//            }
//            
//            // OrderPriceが確定してから、TP/SLを設定
//            if(OrderSelect(ordeticket,SELECT_BY_TICKET)==true)
//            {
//      
//               double openPrice = OrderOpenPrice();
//               double currentTP = NormalizeDouble(openPrice + TAKE_PROFIT_MARGIN,Digits);
//               double currentSL = NormalizeDouble(openPrice - STOP_LOSS_MARGIN,Digits);
//               if(!OrderModify(ordeticket,Bid,currentSL,currentTP,0,clrYellow))
//               {
//                   Print("###Order Modify 002");
//                   Print(ErrorDescription(GetLastError()));
//               }
//            }
//            
//         }else if(firstHourPrice > secondHourPrice){
//            // まずはSL/TPなしで発注
//            ordeticket=OrderSend(Symbol(),OP_SELL,LOTS,Ask,100,0,0,"sell",MAGIC,0,clrYellow);
//            if(ordeticket == -1)
//            {
//               Print("###Order Buy 001");
//               Print(ErrorDescription(GetLastError()));
//               return;
//            }
//            
//            // OrderPriceが確定してから、TP/SLを設定
//            if(OrderSelect(ordeticket,SELECT_BY_TICKET)==true)
//            {
//      
//               double openPrice = OrderOpenPrice();
//               double currentTP = NormalizeDouble(openPrice - TAKE_PROFIT_MARGIN,Digits);
//               double currentSL = NormalizeDouble(openPrice + STOP_LOSS_MARGIN,Digits);
//               if(!OrderModify(ordeticket,Ask,currentSL,currentTP,0,clrYellow))
//               {
//                   Print("###Order Modify 002");
//                   Print(ErrorDescription(GetLastError()));
//               }
//            }
//            
//          }
//      }
//
//      
//      if(Hour() == forceExitHour - 6 && Minute()== 0)
//      {
//         if(OrdersTotal() > 0)
//         {
//            if(!OrderClose(ordeticket,LOTS,Bid,1000,clrAliceBlue))
//            {
//               Print("###exit");
//               Print(ErrorDescription(GetLastError()));
//            };         
//         }
//      }
// 
//   
//  }
//+------------------------------------------------------------------+
