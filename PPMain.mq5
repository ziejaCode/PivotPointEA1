//+------------------------------------------------------------------+
//|                                                       PPMain.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//    "============= ENUMS ==============="

      enum TF4PP {Daily=0, Weekly=1};
      
input group "================== Inputs for Pivot Points ================"

      input ENUM_TIMEFRAMES TF4Charts = PERIOD_CURRENT; //Timeframes for EA to run on
      input TF4PP TF4PPChoice = 0; //Timeframe for Pivot Points
      ENUM_TIMEFRAMES PPTimeframe;
      input color TLColor = clrChartreuse;
      

int OnInit()
  {
  
   if(TF4PPChoice==0){
      PPTimeframe = PERIOD_D1;
   }else
   if(TF4PPChoice==1){
      PPTimeframe = PERIOD_W1;
   }
  
   return(INIT_SUCCEEDED);
  }
  
  
 
void OnDeinit(const int reason)
  {
   
  }
  
  
  
void OnTick()
  {
   
  }
  
void PivotPoints(){
   
   double PPClosex1 = iClose(_Symbol,PPTimeframe,1);
   double PPHighx1 = iHigh(_Symbol,PPTimeframe,1);
   double PPLowx1 = iLow(_Symbol,PPTimeframe,1);
   
   double PivotPoint = (PPHighx1+PPLowx1+PPClosex1)/3;
   double S1 = (PivotPoint*2)-PPHighx1;
   double R1 = (PivotPoint*2)-PPLowx1;
   double S2 = PivotPoint - (PPHighx1 - PPLowx1);
   double R2 = PivotPoint + (PPHighx1 - PPLowx1);
   
   DrawPivotPoints(PivotPoint,S1,S2,R1,R2);
   //DrawPivotPoints(PivotPoint,S1,S2,R1,R2);

}

void DrawPivotPoints(double PP, double S1, double S2, double R1, double R2){

   ObjectCreate(0, "PP", OBJ_TREND, 0,iTime(_Symbol, PPTimeframe,0),PP,iTime(_Symbol,PPTimeframe,0)+PeriodSeconds(PPTimeframe),PP);
   ObjectSetInteger(0,"PP",OBJPROP_COLOR,TLColor);
   
   ObjectCreate(0, "S1", OBJ_TREND, 0,iTime(_Symbol, PPTimeframe,0),S1,iTime(_Symbol,PPTimeframe,0)+PeriodSeconds(PPTimeframe),S1);
   ObjectSetInteger(0,"S1",OBJPROP_COLOR,TLColor);
}