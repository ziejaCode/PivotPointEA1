//+------------------------------------------------------------------+
//|                                                  PPtestShort.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Trade\Trade.mqh>
CTrade trade;
CPositionInfo pos; 

      
      int S1alreadyTraded=0;
      int R1alreadyTraded=0;
      input ulong MagicNumber = 101;

//    "============= ENUMS ==============="

      enum TF4PP {Daily=0, Weekly=1};
      enum PPTradingType {Bounce=1, Break=2};
      enum lotSizeType{Fixed_Lot=0, RiskPercentage=1};
      enum SLType{Inactive=0, Manual=1, PivotPoints=2, S1_R1=3, S2_R2=4};
      enum TPType{Inactive=0, Manual=1, PivotPoints=2, S1_R1=3, S2_R2=4};
      
input group "================== Inputs for Pivot Points ================"

      input ENUM_TIMEFRAMES TF4Chart = PERIOD_CURRENT; //Timeframes for EA to run on
      input TF4PP TF4PPChoice = 0; //Timeframe for Pivot Points
      ENUM_TIMEFRAMES PPTimeframe;
      input color TLColor = clrRed;
      input PPTradingType PPTrChoice = 1;
      //input ulong InpMagic = 8234;
 
input group "================== Risk and Money Management ================" 

      input lotSizeType lotType=0; //fixed lot or 1% of the account balance
      input double lotsize = 0.1;
      input double RiskPct = 1;


input group "==================  Trade Management ================" 

      input SLType SLChoice = 1; 
      input int ManualSL = 0; // this is in points 1pip is 10 points
      input TPType TPChoice = 1; 
      input int ManualTP = 0; // this is in points 1pip is 10 points

int OnInit()
  {
  
   if(TF4PPChoice==0){
      PPTimeframe = PERIOD_D1;
   }else
   if(TF4PPChoice==1){
      PPTimeframe = PERIOD_W1;
   }
   ChartSetInteger(0,CHART_SHOW_GRID,false);
  
   return(INIT_SUCCEEDED);
  }
  
  
 
void OnDeinit(const int reason)
  {
   
  }
 
void OnTick()
  {
   PivotPoints();
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
   
   Print("CheckPlacedPositions is now ",CheckPlacedPositions(MagicNumber));
   
   if(CheckPlacedPositions(MagicNumber) == false){
      
      OpenTrade(PivotPoint,S1,S2,R1,R2);
      Print("Entered OP is now ",CheckPlacedPositions(MagicNumber));
   }

}



void OpenTrade(double PP, double S1, double S2, double R1, double R2){

      Print("Open trade entered");

      double Lowx1 = iLow(_Symbol,TF4Chart,1);
      double Closex1 = iClose(_Symbol,TF4Chart,1);
      double Highx1 = iHigh(_Symbol,TF4Chart,1);
      
      double entry = Closex1;


      if(PPTrChoice==1){  // Bounce trade style is selected
      
      // Bounce back from S1
            Print("S1alreadyTraded is ",S1alreadyTraded);
            if(Lowx1<S1 && Closex1>S1 && S1alreadyTraded<1){
                  double sl = calcSL(POSITION_TYPE_BUY,PP,S1,S2,R1,R2);
                  double tp = calcTp(POSITION_TYPE_BUY,PP,S1,S2,R1,R2);
                  Print("sl is ",sl, " tp is ", tp);
                  Print("sl is ",sl);
                  Print("lotType is ",lotType);
                  double lots = lotsize;
                     if(lotType==1){
                        lots = calcLots(entry-sl);
                        Print("Lotsize is ",lotsize);
                     }
                  Print("Lots are ",lots);
                  trade.Buy(lots,_Symbol,0,sl,tp,NULL);
                  //R1alreadyTraded=0;
                  S1alreadyTraded++;
                  
            }
      // Bounce back from R1
            Print("R1alreadyTraded is ",R1alreadyTraded);
            if(Highx1>R1 && Closex1<R1 && R1alreadyTraded<1){
                  double sl = calcSL(POSITION_TYPE_SELL,PP,S1,S2,R1,R2);
                  double tp = calcTp(POSITION_TYPE_SELL,PP,S1,S2,R1,R2);
                  Print("sl is ",sl, " tp is ", tp);
                  Print("sl is ",sl);
                  Print("lotType is ",lotType);
                  double lots = lotsize;
                     if(lotType==1){
                        lots = calcLots(sl-entry);
                        Print("Lotsize is ",lotsize);
                     }
                  Print("Lots are ",lots);
                  trade.Sell(lots,_Symbol,0,sl,tp,NULL);
                  //S1alreadyTraded=0;
                  R1alreadyTraded++;
            }      
      }
}



bool CheckPlacedPositions(ulong pMagic)
{	
	bool placedPosition = false;
	for(int i = PositionsTotal() - 1; i >= 0; i--) // practice this loop
	{
	   Print("There is only "+PositionsTotal()+" Position");
	   ulong positionTicket = PositionGetTicket(i);
	   PositionSelectByTicket(positionTicket);
	   ulong posMagic = PositionGetInteger(POSITION_MAGIC);
	   Print("posMagic - "+posMagic+ " ~ pMagic - "+pMagic);
	   //if(posMagic == pMagic)
	   //{
	   placedPosition = true;
	   break;
	   //}
	}
	S1alreadyTraded=0;
	R1alreadyTraded=0;
	Print("R1alreadyTraded is ",R1alreadyTraded,"and S1alreadyTraded is ",S1alreadyTraded);
	return placedPosition;
}

//------------------------------------------------------------------------------------







double calcSL(ENUM_POSITION_TYPE type, double PP, double S1, double S2, double R1, double R2){

   double entry=iClose(_Symbol,TF4Chart,1);
   double sl=0, lots=lotsize;

   if(PPTrChoice==1){ // Bounce style selected
   
      if(type==POSITION_TYPE_BUY){
         if(SLChoice == 0 || (SLChoice == 1 && ManualSL== 0)){sl = 0;}
         if(SLChoice==1 && ManualSL!=0){sl=entry-(ManualSL*_Point);}             
      }
      if(type==POSITION_TYPE_SELL){
         if(SLChoice==0 || (SLChoice==1 && ManualSL==0)){sl=0;}
         if(SLChoice==1 && ManualSL!=0){sl=entry+(ManualSL*_Point);}
        
      }
   }
    return sl;
 }
 
 
 
double calcTp(ENUM_POSITION_TYPE type, double PP, double S1, double S2, double R1, double R2){

   double entry=iClose(_Symbol,TF4Chart,1);
   double tp=0, tp1=0, tp2=0, lots=lotsize;

   if(PPTrChoice==1){ // Bounce style selected
   
      if(type==POSITION_TYPE_BUY){
         if(TPChoice==0 || (TPChoice==1 && ManualTP==0)){tp=0;}
         if(TPChoice==1 && ManualTP!=0){tp=entry+(ManualTP*_Point);}
      }
      if(type==POSITION_TYPE_SELL){
         if(TPChoice==0 || (TPChoice==1 && ManualTP==0)){tp=0;}
         if(TPChoice==1 && ManualTP!=0){tp=entry-(ManualTP*_Point);}        
      }
   }

return tp;
   
}
 
  

double calcLots(double slPoints){

   double risk = AccountInfoDouble(ACCOUNT_BALANCE) * RiskPct/100;

   double ticksize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickvalue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double lotstep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
   double moneyPerLotStep = slPoints / ticksize * tickvalue * lotstep;
   double lots = MathFloor(risk / moneyPerLotStep) * lotstep;
   
   double minvolume = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   double maxvolume = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   
   if(maxvolume!=0) lots = MathMin(lots,maxvolume);
   if(minvolume!=0) lots = MathMax(lots,minvolume);
   
   lots = NormalizeDouble(lots,2);
   
   return lots;
}



void DrawPivotPoints(double PP, double S1, double S2, double R1, double R2){

   //Print("Draw pivot Points entered");

   ObjectCreate(0,"PP",OBJ_TREND,0,iTime(_Symbol,PPTimeframe,0),PP,iTime(_Symbol,PPTimeframe,0)+PeriodSeconds(PPTimeframe),PP);
   ObjectSetInteger(0,"PP",OBJPROP_COLOR,clrBlue);
   ObjectSetInteger(0,"PP",OBJPROP_WIDTH,3);
   
   ObjectCreate(0,"S1",OBJ_TREND,0,iTime(_Symbol,PPTimeframe,0),S1,iTime(_Symbol,PPTimeframe,0)+PeriodSeconds(PPTimeframe),S1);
   ObjectSetInteger(0,"S1",OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,"S1",OBJPROP_WIDTH,3);
   ObjectCreate(0,"S1text",OBJ_TEXT,0,iTime(_Symbol,PPTimeframe,0),S1);
   ObjectSetString(0,"S1text",OBJPROP_TEXT,"S1");
   ObjectSetInteger(0,"S1text",OBJPROP_COLOR,clrRed);
   
   ObjectCreate(0,"S2",OBJ_TREND,0,iTime(_Symbol,PPTimeframe,0),S2,iTime(_Symbol,PPTimeframe,0)+PeriodSeconds(PPTimeframe),S2);
   ObjectSetInteger(0,"S2",OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,"S2",OBJPROP_WIDTH,2);
   ObjectCreate(0,"S2text",OBJ_TEXT,0,iTime(_Symbol,PPTimeframe,0),S2);
   ObjectSetString(0,"S2text",OBJPROP_TEXT,"S2");
   ObjectSetInteger(0,"S2text",OBJPROP_COLOR,clrRed);
   
   ObjectCreate(0,"R1",OBJ_TREND,0,iTime(_Symbol,PPTimeframe,0),R1,iTime(_Symbol,PPTimeframe,0)+PeriodSeconds(PPTimeframe),R1);
   ObjectSetInteger(0,"R1",OBJPROP_COLOR,clrGreen);
   ObjectSetInteger(0,"R1",OBJPROP_WIDTH,3);
   ObjectCreate(0,"R1text",OBJ_TEXT,0,iTime(_Symbol,PPTimeframe,0),R1);
   ObjectSetString(0,"R1text",OBJPROP_TEXT,"R1");
   ObjectSetInteger(0,"R1text",OBJPROP_COLOR,clrGreen);
   
   ObjectCreate(0,"R2",OBJ_TREND,0,iTime(_Symbol,PPTimeframe,0),R2,iTime(_Symbol,PPTimeframe,0)+PeriodSeconds(PPTimeframe),R2);
   ObjectSetInteger(0,"R2",OBJPROP_COLOR,clrGreen);
   ObjectSetInteger(0,"R2",OBJPROP_WIDTH,2);
   ObjectCreate(0,"R2text",OBJ_TEXT,0,iTime(_Symbol,PPTimeframe,0),R2);
   ObjectSetString(0,"R2text",OBJPROP_TEXT,"R2");
   ObjectSetInteger(0,"R2text",OBJPROP_COLOR,clrGreen);
   
}
