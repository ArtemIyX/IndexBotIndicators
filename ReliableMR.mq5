//+------------------------------------------------------------------+
//|                                                   ReliableMR.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Buy:Close < (0.2*(high - low) +low)\nSell::Close > (high - 0.2*(high - low))"

// Indicator settings
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_minimum 0
#property indicator_maximum 4
#property indicator_plots 1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue

// Input parameters
input int InpMaFilterPeriod = 200;     // Filter MA period
input int InpMaPeriod = 20; // Fast MA Period
input double InpPercent = 0.2; // Calc Percent



// Indicator buffers
double signalBuffer[];

// Indicator handles
int maFilterHandle;
int maHandle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
   SetIndexBuffer(0, signalBuffer, INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS, 1);
   IndicatorSetString(INDICATOR_SHORTNAME, "Reliable MR");
   string sym = Symbol();
   maFilterHandle = iMA(sym, PERIOD_CURRENT, InpMaFilterPeriod, 0, MODE_SMA, PRICE_CLOSE);
   maHandle = iMA(sym, PERIOD_CURRENT, InpMaPeriod, 0, MODE_SMA, PRICE_CLOSE);
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   IndicatorRelease(maFilterHandle);
   IndicatorRelease(maHandle);
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
   if (rates_total < InpMaPeriod || rates_total < InpMaFilterPeriod)
      return(0);

   double maArr[];
   double maFilterArr[];
   string sym = Symbol();
   for (int i = MathMax(InpMaPeriod, InpMaFilterPeriod) + 1; i < rates_total; i++) {

      int maNum = CopyBuffer(maHandle, 0, rates_total - i - 1, 1, maArr);
      if(maNum != 1)
         continue;

      int maFilterNum = CopyBuffer(maFilterHandle, 0, rates_total - i - 1, 1, maFilterArr);
      if(maFilterNum != 1)
         continue;

      double maFilterValue = maFilterArr[0];
      double maValue = maArr[0];

      double ibsUp = (InpPercent *(high[i]-low[i]) + low[i]);
      double    = (high[i] - InpPercent *(high[i] - low[i]));
      if(close[i] > maFilterValue      // SMA(200) Filter UP_TREND
            && close[i] < maValue      // Close < SMA (Mean Reversion)
            && close[i] < ibsUp) {     // Close < (0.2x(high - low) + low)
         signalBuffer[i] = 1;          // Buy
      } else if(close[i] > maValue) {  // Close > SMA (Mean Reversion)
         signalBuffer[i] = 2;          // Close Buy
      } else if(close[i] < maFilterValue     // SMA(200) Filter DOWN_TREND
                && close[i] > maValue        // Close > SMA (Mean Reversion)
                && close[i] > ibsDown) {     // Close > (high - 0.2x(high - low))
         signalBuffer[i] = 3;                // Sell
      } else if(close[i] < maValue) {
         signalBuffer[i] = 4;                // Close sell
      } else {
         signalBuffer[i] = 0;          // Nothing
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
