//+------------------------------------------------------------------+
//|                                                  morningScal.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <stdlib.mqh>
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.02"
#property strict

extern int tradeMinute = 30;
extern int tradeHour = 11;
extern int forceExitMinute = 0;
extern int forceExitHour = 15;
extern int timeLag = 6;
int ordeticket = 0;
extern double lots = 0.04;
extern int    MAGIC = 62634; //マジックナンバー
extern double BUY_TP_MARGIN = 0.0;
extern double BUY_SL_MARGIN = 0.2;
int day = 0;
bool tradeset = false;

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
      tradeset = false;
   }
   
   if(!tradeset)
   {
      if(Hour() == tradeHour - timeLag && Minute()== tradeMinute)
      {
         Print("###ccc");
         tradeset = true;

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
            double currentTP = 0;
            if(BUY_TP_MARGIN > 0)
            {
               currentTP = NormalizeDouble(openPrice + BUY_TP_MARGIN,Digits);
            }
            double currentSL = NormalizeDouble(openPrice - BUY_SL_MARGIN,Digits);
            if(!OrderModify(ordeticket,Bid,currentSL,currentTP,0,clrYellow))
            {
                Print("###Order Modify 002");
                Print(ErrorDescription(GetLastError()));
            }
         }
      }
   }
      
   if(Hour() == forceExitHour -timeLag && Minute()== 0)
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
