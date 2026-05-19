//+------------------------------------------------------------------+
//|                                                     helpers.mq4   |
//|                          Helper Functions for LIGHTLAND EA         |
//|                                       LIGHTLAND Project            |
//+------------------------------------------------------------------+
#property copyright "LIGHTLAND"
#property link      "https://github.com/etbethait-jpg/lightland"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
// LOG FUNCTIONS
//+------------------------------------------------------------------+

/**
 * Print log message with timestamp
 */
void LogMessage(string sMessage)
{
    string sTimestamp = TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
    Print("[" + sTimestamp + "] " + sMessage);
}

/**
 * Print error message
 */
void LogError(string sFunction, int iError)
{
    LogMessage("ERROR in " + sFunction + ": " + IntegerToString(iError) + " - " + GetErrorDescription(iError));
}

/**
 * Get description of error code
 */
string GetErrorDescription(int iError)
{
    switch(iError)
    {
        case 0:
            return "No error";
        case 130:
            return "Wrong stops";
        case 131:
            return "Invalid trade volume";
        case 132:
            return "Market is closed";
        case 133:
            return "Trade is disabled";
        case 134:
            return "Not enough money";
        case 135:
            return "Price changed";
        case 136:
            return "Broker is busy";
        case 137:
            return "New prices";
        case 138:
            return "Order is locked";
        case 139:
            return "Only buy orders allowed";
        case 140:
            return "Only sell orders allowed";
        default:
            return "Unknown error";
    }
}

//+------------------------------------------------------------------+
// PRICE FUNCTIONS
//+------------------------------------------------------------------+

/**
 * Normalize price to proper digits
 */
double NormalizePrice(double dPrice, int iDigits)
{
    return NormalizeDouble(dPrice, iDigits);
}

/**
 * Convert pips to price
 */
double PipsToPrice(double dPips)
{
    double dPoint = (Digits % 2 == 1) ? 0.001 : 0.0001;
    return dPips * dPoint;
}

/**
 * Convert price difference to pips
 */
double PriceToPips(double dPrice)
{
    double dPoint = (Digits % 2 == 1) ? 0.001 : 0.0001;
    return dPrice / dPoint;
}

//+------------------------------------------------------------------+
// POSITION FUNCTIONS
//+------------------------------------------------------------------+

/**
 * Count open positions of specific magic number
 */
int CountPositions(int iMagic)
{
    int iCount = 0;
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
        if(OrderMagicNumber() == iMagic && OrderSymbol() == Symbol())
        {
            iCount++;
        }
    }
    return iCount;
}

/**
 * Get total profit of all positions with magic number
 */
double GetTotalProfit(int iMagic)
{
    double dProfit = 0.0;
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
        if(OrderMagicNumber() == iMagic && OrderSymbol() == Symbol())
        {
            dProfit += OrderProfit();
        }
    }
    return dProfit;
}

/**
 * Close all positions with specific magic number
 */
bool CloseAllPositions(int iMagic)
{
    bool bResult = true;
    for(int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
        if(OrderMagicNumber() != iMagic || OrderSymbol() != Symbol()) continue;
        
        if(OrderType() == OP_BUY)
        {
            if(!OrderClose(OrderTicket(), OrderOpenPrice(), Bid, 10, clrRed))
            {
                LogError("OrderClose", GetLastError());
                bResult = false;
            }
        }
        else if(OrderType() == OP_SELL)
        {
            if(!OrderClose(OrderTicket(), OrderOpenPrice(), Ask, 10, clrRed))
            {
                LogError("OrderClose", GetLastError());
                bResult = false;
            }
        }
    }
    return bResult;
}

//+------------------------------------------------------------------+
// TIME FUNCTIONS
//+------------------------------------------------------------------+

/**
 * Check if market hours
 */
bool IsMarketHours()
{
    int iHour = Hour();
    if(iHour < 1 || iHour > 22) return false;  // Markets closed outside 1-22 UTC
    return true;
}

/**
 * Check if new day
 */
bool IsNewDay()
{
    static int iLastDay = 0;
    int iToday = Day();
    
    if(iLastDay != iToday)
    {
        iLastDay = iToday;
        return true;
    }
    return false;
}

/**
 * Check if specific time passed
 */
bool IsTimePassed(datetime dtTime)
{
    return TimeCurrent() >= dtTime;
}

//+------------------------------------------------------------------+
// MATH FUNCTIONS
//+------------------------------------------------------------------+

/**
 * Calculate percentage change
 */
double PercentChange(double dOld, double dNew)
{
    if(dOld == 0) return 0;
    return ((dNew - dOld) / dOld) * 100;
}

/**
 * Calculate moving average manually
 */
double CalculateMA(int iPeriod, int iShift = 0)
{
    double dSum = 0;
    for(int i = iShift; i < iShift + iPeriod; i++)
    {
        dSum += Close[i];
    }
    return dSum / iPeriod;
}

/**
 * Find highest close in last N bars
 */
double GetHighestClose(int iBars)
{
    double dHighest = Close[0];
    for(int i = 1; i < iBars; i++)
    {
        if(Close[i] > dHighest) dHighest = Close[i];
    }
    return dHighest;
}

/**
 * Find lowest close in last N bars
 */
double GetLowestClose(int iBars)
{
    double dLowest = Close[0];
    for(int i = 1; i < iBars; i++)
    {
        if(Close[i] < dLowest) dLowest = Close[i];
    }
    return dLowest;
}

//+------------------------------------------------------------------+
// SIGNAL FUNCTIONS
//+------------------------------------------------------------------+

/**
 * Check if bullish signal
 */
bool IsBullish()
{
    return Close[0] > Close[1] && Close[1] > Close[2];
}

/**
 * Check if bearish signal
 */
bool IsBearish()
{
    return Close[0] < Close[1] && Close[1] < Close[2];
}

/**
 * Check if inside bar
 */
bool IsInsideBar()
{
    return High[0] < High[1] && Low[0] > Low[1];
}

/**
 * Check if outside bar (engulfing)
 */
bool IsOutsideBar()
{
    return High[0] > High[1] && Low[0] < Low[1];
}

//+------------------------------------------------------------------+
// END OF HELPERS
//+------------------------------------------------------------------+
