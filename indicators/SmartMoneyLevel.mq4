//+------------------------------------------------------------------+
//|                                            SmartMoneyLevel.mq4   |
//|                         Identifies Smart Money Support/Resistance  |
//|                                       LIGHTLAND Project            |
//+------------------------------------------------------------------+
#property copyright "LIGHTLAND"
#property link      "https://github.com/etbethait-jpg/lightland"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrBlue     // Support levels
#property indicator_color2 clrRed      // Resistance levels

//+------------------------------------------------------------------+
// INPUT PARAMETERS
//+------------------------------------------------------------------+
input int LookbackPeriod = 20;          // Lookback bars for levels
input int MinimumTouches = 2;           // Minimum touches to confirm level
input double SensitivityPercent = 0.5;  // Sensitivity percentage
input bool ShowLabels = true;           // Show level labels
input bool ShowAlerts = true;           // Show alerts on new levels

//+------------------------------------------------------------------+
// INDICATOR BUFFERS
//+------------------------------------------------------------------+
double SupportBuffer[];
double ResistanceBuffer[];

//+------------------------------------------------------------------+
// GLOBAL VARIABLES
//+------------------------------------------------------------------+
double gd_146 = 0.0;
double gd_154 = 0.0;
bool gb_162 = false;
bool gb_170 = false;

//+------------------------------------------------------------------+
// OnInit - Initialization
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorBuffers(2);
    
    SetIndexBuffer(0, SupportBuffer);
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2, clrBlue);
    SetIndexLabel(0, "Smart Money Support");
    
    SetIndexBuffer(1, ResistanceBuffer);
    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2, clrRed);
    SetIndexLabel(1, "Smart Money Resistance");
    
    IndicatorShortName("Smart Money Levels");
    IndicatorDigits(Digits);
    
    Print("Smart Money Level Indicator - Initialized");
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
// OnCalculate - Main calculation
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
                const int &spread[])
{
    int iStart = (prev_calculated == 0) ? 0 : prev_calculated - 1;
    
    for(int i = iStart; i < rates_total - 1; i++)
    {
        // Calculate support and resistance
        double dSupport = CalculateSupportLevel(i);
        double dResistance = CalculateResistanceLevel(i);
        
        SupportBuffer[i] = dSupport;
        ResistanceBuffer[i] = dResistance;
    }
    
    return(rates_total);
}

//+------------------------------------------------------------------+
// CALCULATE SUPPORT LEVEL
//+------------------------------------------------------------------+
double CalculateSupportLevel(int iBar)
{
    double dSupport = 0.0;
    int iTouches = 0;
    double dTolerance = Close[iBar] * (SensitivityPercent / 100.0);
    
    // Find the lowest level in lookback period
    double dLowest = Low[iBar];
    int iLowestBar = iBar;
    
    for(int i = iBar; i < iBar + LookbackPeriod && i < Bars; i++)
    {
        if(Low[i] < dLowest)
        {
            dLowest = Low[i];
            iLowestBar = i;
        }
    }
    
    // Count touches of this level
    for(int i = iBar; i < iBar + LookbackPeriod && i < Bars; i++)
    {
        if(MathAbs(Low[i] - dLowest) < dTolerance)
        {
            iTouches++;
        }
    }
    
    if(iTouches >= MinimumTouches)
    {
        dSupport = dLowest;
    }
    
    return dSupport;
}

//+------------------------------------------------------------------+
// CALCULATE RESISTANCE LEVEL
//+------------------------------------------------------------------+
double CalculateResistanceLevel(int iBar)
{
    double dResistance = 0.0;
    int iTouches = 0;
    double dTolerance = Close[iBar] * (SensitivityPercent / 100.0);
    
    // Find the highest level in lookback period
    double dHighest = High[iBar];
    int iHighestBar = iBar;
    
    for(int i = iBar; i < iBar + LookbackPeriod && i < Bars; i++)
    {
        if(High[i] > dHighest)
        {
            dHighest = High[i];
            iHighestBar = i;
        }
    }
    
    // Count touches of this level
    for(int i = iBar; i < iBar + LookbackPeriod && i < Bars; i++)
    {
        if(MathAbs(High[i] - dHighest) < dTolerance)
        {
            iTouches++;
        }
    }
    
    if(iTouches >= MinimumTouches)
    {
        dResistance = dHighest;
    }
    
    return dResistance;
}

//+------------------------------------------------------------------+
// OnDeinit - Cleanup
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("Smart Money Level Indicator - Deinitialized");
}

//+------------------------------------------------------------------+
// END OF INDICATOR
//+------------------------------------------------------------------+
