//+------------------------------------------------------------------+
//|                                                      Kalvion.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// Основные параметры
extern double Lots = 0.01;
extern int MagicNumber = 12345;
extern int Slippage = 3;
extern double StopLoss = 50;
extern double TakeProfit = 100;

// Переменные для управления торговлей
bool TradeAllowed = true;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("Kalvion EA initialized");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("Kalvion EA deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!TradeAllowed) return;
   
   // Основная торговая логика
   CheckForTrade();
}

//+------------------------------------------------------------------+
//| Проверка условий для торговли                                    |
//+------------------------------------------------------------------+
void CheckForTrade()
{
   // Проверяем, есть ли уже открытые позиции
   if(CountOrders() > 0) return;
   
   // Простая стратегия на основе пересечения MA
   double ma_fast = iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, 0);
   double ma_slow = iMA(NULL, 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
   
   // Сигнал на покупку
   if(ma_fast > ma_slow)
   {
      OpenBuy();
   }
   // Сигнал на продажу
   else if(ma_fast < ma_slow)
   {
      OpenSell();
   }
}

//+------------------------------------------------------------------+
//| Открытие позиции на покупку                                      |
//+------------------------------------------------------------------+
void OpenBuy()
{
   double sl = (StopLoss > 0) ? Ask - StopLoss * Point : 0;
   double tp = (TakeProfit > 0) ? Ask + TakeProfit * Point : 0;
   
   int ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, sl, tp, "Kalvion Buy", MagicNumber, 0, clrGreen);
   
   if(ticket > 0)
   {
      Print("Buy order opened: ", ticket);
   }
   else
   {
      Print("Error opening buy order: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Открытие позиции на продажу                                      |
//+------------------------------------------------------------------+
void OpenSell()
{
   double sl = (StopLoss > 0) ? Bid + StopLoss * Point : 0;
   double tp = (TakeProfit > 0) ? Bid - TakeProfit * Point : 0;
   
   int ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, sl, tp, "Kalvion Sell", MagicNumber, 0, clrRed);
   
   if(ticket > 0)
   {
      Print("Sell order opened: ", ticket);
   }
   else
   {
      Print("Error opening sell order: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Подсчет открытых ордеров                                         |
//+------------------------------------------------------------------+
int CountOrders()
{
   int count = 0;
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            count++;
         }
      }
   }
   return count;
}