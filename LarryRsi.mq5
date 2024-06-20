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
#property indicator_maximum 2
#property indicator_plots 1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue

// Indicator buffers
double signalBuffer[];

// Input parameters
input int InpMaPeriod_Larry = 200;     // MA period
input int InpRsiPeriod_Larry = 2;      // RSI period
input double InpRsiLower_Larry = 25.0; // RSI Lower
input double InpRsiUpper_Larry = 75.0; // RSI Upper

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
   maHandle = iMA(sym, PERIOD_CURRENT, InpMaPeriod_Larry, 0, MODE_SMA, PRICE_CLOSE);
   rsiHandle = iRSI(sym, PERIOD_CURRENT, InpRsiPeriod_Larry, PRICE_CLOSE);
   if (maHandle == INVALID_HANDLE || rsiHandle == INVALID_HANDLE) {
      Print("Error creating indicators");
      return(INIT_FAILED);
   }
//---
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  OnDeinit(
   const int  reason         // deinitialization reason code
) {
   IndicatorRelease(maHandle);
   IndicatorRelease(rsiHandle);
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

   if (rates_total < InpMaPeriod_Larry || rates_total < InpRsiPeriod_Larry)
      return(0);
   string sym = Symbol();
// Calculate signals
   double rsiArr[], maArr[];
   for (int i = MathMax(InpMaPeriod_Larry, InpRsiPeriod_Larry) + 1; i < rates_total; i++) {

      int rsiNum = CopyBuffer(rsiHandle, 0, rates_total - i - 1, 1, rsiArr);
      int maNum = CopyBuffer(maHandle, 0, rates_total - i - 1, 1, maArr);
      if(rsiNum != 1)
         continue;

      if(maNum != 1)
         continue;

      double rsiValue = rsiArr[0];
      double maValue = maArr[0];

      if (close[i] > maValue && rsiValue < InpRsiLower_Larry)
         signalBuffer[i] = 1;     // Buy
      else if (rsiValue > InpRsiUpper_Larry)
         signalBuffer[i] = 2;     // Close Buy
      else
         signalBuffer[i] = 0;     // Nothing
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
