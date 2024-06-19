//+------------------------------------------------------------------+
//|                                                     LarryRsi.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
// Indicator settings
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_minimum 0
#property indicator_maximum 4
#property indicator_plots 1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue

// Indicator buffers
double signalBuffer[];

// Input parameters
input int InpMaPeriod = 200;     // MA period
input int InpRsiPeriod = 2;      // RSI period
input double InpRsiLower = 25.0; // RSI Lower
input double InpRsiUpper = 75.0; // RSI Upper

int maHandle;
int rsiHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
   SetIndexBuffer(0, signalBuffer, INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS, 1);
   IndicatorSetString(INDICATOR_SHORTNAME, "Larry RSI");
   string sym = Symbol();
   maHandle = iMA(sym, PERIOD_CURRENT, InpMaPeriod, 0, MODE_SMA, PRICE_CLOSE);
   rsiHandle = iRSI(sym, PERIOD_CURRENT, InpRsiPeriod, PRICE_CLOSE);
   if (maHandle == INVALID_HANDLE || rsiHandle == INVALID_HANDLE) {
      Print("Error creating indicators");
      return(INIT_FAILED);
   }
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
//---

   if (rates_total < InpMaPeriod || rates_total < InpRsiPeriod)
      return(0);
   string sym = Symbol();
// Calculate signals
   double rsiArr[], maArr[];
   for (int i = MathMax(InpMaPeriod, InpRsiPeriod) + 1; i < rates_total; i++) {

      int rsiNum = CopyBuffer(rsiHandle, 0, rates_total - i - 1, 1, rsiArr);
      int maNum = CopyBuffer(maHandle, 0, rates_total - i - 1, 1, maArr);
      if(rsiNum != 1)
         continue;

      if(maNum != 1)
         continue;

      double rsiValue = rsiArr[0];
      double maValue = maArr[0];

      if (close[i] > maValue && rsiValue < 25)
         signalBuffer[i] = 1;     // Buy
      else if (close[i] < maValue && rsiValue > 75)
         signalBuffer[i] = 2;     // Sell
      else if (rsiValue > 75)
         signalBuffer[i] = 3;     // Close Buy
      else if (rsiValue < 25)
         signalBuffer[i] = 4;     // Close Sell
      else
         signalBuffer[i] = 0;     // Nothing
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
