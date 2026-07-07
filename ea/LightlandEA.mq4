//+------------------------------------------------------------------+
//|                                                   LightlandEA.mq4 |
//|                                              Smart Money Concept |
//|                                        Automated Trading Solution |
//+------------------------------------------------------------------+
#property copyright "LIGHTLAND"
#property link      "https://github.com/etbethait-jpg/lightland"
#property version   "1.01"
#property strict
#property description "LIGHTLAND - Smart Money Expert Advisor (FIXED VERSION)"

//+------------------------------------------------------------------+
// INPUT PARAMETERS
//+------------------------------------------------------------------+
input double Risk = 2.0;                    // Risk percentage per trade
input int StopLossPips = 50;                // Stop Loss in pips
input int TakeProfitPips = 100;             // Take Profit in pips
input int MagicNumber = 123456;             // Magic Number
input bool UseSmartMoneyLevels = true;      // Use Smart Money Indicator
input int MaxTrades = 5;                    // Maximum open trades
input int RSIPeriod = 14;                   // RSI Period
input double VolumeThreshold = 1.0;         // Volume threshold multiplier (REDUCED from 1.5)
input bool AllowBuys = true;                // Allow BUY orders
input bool AllowSells = true;               // Allow SELL orders
input int MinProfitPips = 10;               // Minimum profit to consider
input int TrailingStopActivation = 30;      // Pips profit to activate trailing stop

//+------------------------------------------------------------------+
// GLOBAL VARIABLES
//+------------------------------------------------------------------+
double dPoint;
int iDigits;
bool bInitialized = false;
static int iLastTradeBar = -1;              // Prevent multiple trades per bar

//+------------------------------------------------------------------+
// OnInit - Initialization function
//+------------------------------------------------------------------+
int OnInit()
{
    // Determine point value
    dPoint = (Digits % 2 == 1) ? 0.001 : 0.0001;
    iDigits = Digits;
    
    Print("═══════════════════════════════════════════════════════════");
    Print("  LIGHTLAND EA v1.01 - Smart Money Concept (FIXED)");
    Print("═══════════════════════════════════════════════════════════");
    Print("Symbol: ", Symbol());
    Print("Period: ", Period(), " minutes");
    Print("Risk per trade: ", Risk, "%");
    Print("Stop Loss: ", StopLossPips, " pips");
    Print("Take Profit: ", TakeProfitPips, " pips");
    Print("Max Trades: ", MaxTrades);
    Print("Volume Threshold: ", VolumeThreshold, "x");
    Print("Trailing Stop Activation: ", TrailingStopActivation, " pips");
    Print("═══════════════════════════════════════════════════════════");
    
    bInitialized = true;
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
// OnDeinit - Deinitialization function
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("LIGHTLAND EA - Deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
// OnTick - Main trading function
//+------------------------------------------------------------------+
void OnTick()
{
    if(!bInitialized) return;
    
    // Check if we have a new bar (SIMPLIFIED)
    if(iLastTradeBar == Bars) return;
    iLastTradeBar = Bars;
    
    // Main trading logic
    int iOrdersOpen = CountOpenOrders();
    
    if(iOrdersOpen < MaxTrades)
    {
        // Check for BUY signal
        if(AllowBuys && CheckBuySignal())
        {
            OpenBuyOrder();
        }
        
        // Check for SELL signal (only if no buy was just placed)
        if(AllowSells && CheckSellSignal())
        {
            OpenSellOrder();
        }
    }
    
    // Manage existing positions
    ManagePositions();
}

//+------------------------------------------------------------------+
// BUY SIGNAL - Detection logic (SIMPLIFIED & LESS RESTRICTIVE)
//+------------------------------------------------------------------+
bool CheckBuySignal()
{
    // Condition 1: RSI confirmation - Above 45 (was 50)
    double dRSI = iRSI(Symbol(), 0, RSIPeriod, PRICE_CLOSE, 1);
    if(dRSI < 45) return false;
    
    // Condition 2: Price action - Previous candle should be bullish
    if(Close[1] <= Open[1]) return false;
    
    // Condition 3: Volume - Volume above AVERAGE (was 1.5x)
    double dAvgVolume = CalculateAverageVolume(20);
    if(dAvgVolume > 0 && Volume[1] < dAvgVolume * VolumeThreshold) return false;
    
    // Condition 4: SIMPLIFIED - Close above recent support (not resistance!)
    double dSupport = GetSupportLevel();
    if(Close[0] <= dSupport) return false;  // Price should be above support
    
    Print("═══════════════════════════════════════════════════════════");
    Print("✓ BUY SIGNAL DETECTED - ", TimeToStr(Time[0], TIME_DATE|TIME_MINUTES));
    Print("  Price: ", Close[0], " | RSI: ", dRSI, " | Support: ", dSupport);
    Print("  Volume Ratio: ", (dAvgVolume > 0 ? (double)Volume[1] / dAvgVolume : 0));
    Print("═══════════════════════════════════════════════════════════");
    
    return true;
}

//+------------------------------------------------------------------+
// SELL SIGNAL - Detection logic (SIMPLIFIED & LESS RESTRICTIVE)
//+------------------------------------------------------------------+
bool CheckSellSignal()
{
    // Condition 1: RSI confirmation - Below 55 (was 50)
    double dRSI = iRSI(Symbol(), 0, RSIPeriod, PRICE_CLOSE, 1);
    if(dRSI > 55) return false;
    
    // Condition 2: Price action - Previous candle should be bearish
    if(Close[1] >= Open[1]) return false;
    
    // Condition 3: Volume - Volume above AVERAGE (was 1.5x)
    double dAvgVolume = CalculateAverageVolume(20);
    if(dAvgVolume > 0 && Volume[1] < dAvgVolume * VolumeThreshold) return false;
    
    // Condition 4: SIMPLIFIED - Close below recent resistance (not support!)
    double dResistance = GetResistanceLevel();
    if(Close[0] >= dResistance) return false;  // Price should be below resistance
    
    Print("═══════════════════════════════════════════════════════════");
    Print("✓ SELL SIGNAL DETECTED - ", TimeToStr(Time[0], TIME_DATE|TIME_MINUTES));
    Print("  Price: ", Close[0], " | RSI: ", dRSI, " | Resistance: ", dResistance);
    Print("  Volume Ratio: ", (dAvgVolume > 0 ? (double)Volume[1] / dAvgVolume : 0));
    Print("═══════════════════════════════════════════════════════════");
    
    return true;
}

//+------------------------------------------------------------------+
// OPEN BUY ORDER
//+------------------------------------------------------------------+
void OpenBuyOrder()
{
    double dStopLoss = Close[0] - (StopLossPips * dPoint);
    double dTakeProfit = Close[0] + (TakeProfitPips * dPoint);
    double dLotSize = CalculateLotSize(StopLossPips);
    
    if(dLotSize <= 0)
    {
        Print("✗ BUY Order SKIPPED: Invalid lot size calculated");
        return;
    }
    
    int iTicket = OrderSend(
        Symbol(),
        OP_BUY,
        dLotSize,
        Ask,
        3,
        NormalizeDouble(dStopLoss, Digits),
        NormalizeDouble(dTakeProfit, Digits),
        "LIGHTLAND BUY",
        MagicNumber,
        0,
        clrGreen
    );
    
    if(iTicket > 0)
    {
        Print("✓ BUY Order OPENED: Ticket #", iTicket, " | Lot: ", dLotSize);
        Print("  Entry: ", Ask, " | SL: ", dStopLoss, " | TP: ", dTakeProfit);
    }
    else
    {
        Print("✗ BUY Order FAILED: Error ", GetLastError());
    }
}

//+------------------------------------------------------------------+
// OPEN SELL ORDER
//+------------------------------------------------------------------+
void OpenSellOrder()
{
    double dStopLoss = Close[0] + (StopLossPips * dPoint);
    double dTakeProfit = Close[0] - (TakeProfitPips * dPoint);
    double dLotSize = CalculateLotSize(StopLossPips);
    
    if(dLotSize <= 0)
    {
        Print("✗ SELL Order SKIPPED: Invalid lot size calculated");
        return;
    }
    
    int iTicket = OrderSend(
        Symbol(),
        OP_SELL,
        dLotSize,
        Bid,
        3,
        NormalizeDouble(dStopLoss, Digits),
        NormalizeDouble(dTakeProfit, Digits),
        "LIGHTLAND SELL",
        MagicNumber,
        0,
        clrRed
    );
    
    if(iTicket > 0)
    {
        Print("✓ SELL Order OPENED: Ticket #", iTicket, " | Lot: ", dLotSize);
        Print("  Entry: ", Bid, " | SL: ", dStopLoss, " | TP: ", dTakeProfit);
    }
    else
    {
        Print("✗ SELL Order FAILED: Error ", GetLastError());
    }
}

//+------------------------------------------------------------------+
// CALCULATE LOT SIZE based on risk (IMPROVED)
//+------------------------------------------------------------------+
double CalculateLotSize(int iStopLossPips)
{
    double dMinLot = MarketInfo(Symbol(), MODE_MINLOT);
    double dMaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
    double dTickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
    double dTickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
    double dBalance = AccountBalance();
    
    // Validation
    if(dMinLot <= 0 || dTickValue <= 0 || dTickSize <= 0 || dBalance <= 0)
    {
        Print("⚠ Warning: Invalid MarketInfo values - Using minimum lot");
        return dMinLot;
    }
    
    double dRiskAmount = dBalance * (Risk / 100.0);
    double dStopLossPrice = iStopLossPips * dTickSize;
    
    double dLotSize = dRiskAmount / (dStopLossPrice * dTickValue);
    
    // Clamp to valid range
    if(dLotSize < dMinLot) dLotSize = dMinLot;
    if(dLotSize > dMaxLot) dLotSize = dMaxLot;
    
    dLotSize = NormalizeDouble(dLotSize, 2);
    
    Print("  Lot calculation: Risk=", Risk, "% | Balance=", dBalance, " | SL=", iStopLossPips, "pips | Lot=", dLotSize);
    
    return dLotSize;
}

//+------------------------------------------------------------------+
// MANAGE POSITIONS - Trailing stop and other management
//+------------------------------------------------------------------+
void ManagePositions()
{
    for(int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
        
        if(OrderMagicNumber() != MagicNumber) continue;
        if(OrderSymbol() != Symbol()) continue;
        
        // Trailing stop implementation
        if(OrderType() == OP_BUY)
        {
            double dProfit = Close[0] - OrderOpenPrice();
            if(dProfit > TrailingStopActivation * dPoint)
            {
                double dNewSL = Close[0] - (TrailingStopActivation * dPoint / 2);
                if(dNewSL > OrderStopLoss() + dPoint)
                {
                    if(!OrderModify(OrderTicket(), OrderOpenPrice(), 
                        NormalizeDouble(dNewSL, Digits), OrderTakeProfit(), 0, clrGreen))
                    {
                        Print("✗ Failed to update BUY trailing stop: Error ", GetLastError());
                    }
                }
            }
        }
        else if(OrderType() == OP_SELL)
        {
            double dProfit = OrderOpenPrice() - Close[0];
            if(dProfit > TrailingStopActivation * dPoint)
            {
                double dNewSL = Close[0] + (TrailingStopActivation * dPoint / 2);
                if(dNewSL < OrderStopLoss() - dPoint)
                {
                    if(!OrderModify(OrderTicket(), OrderOpenPrice(), 
                        NormalizeDouble(dNewSL, Digits), OrderTakeProfit(), 0, clrRed))
                    {
                        Print("✗ Failed to update SELL trailing stop: Error ", GetLastError());
                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
// HELPER FUNCTIONS
//+------------------------------------------------------------------+

int CountOpenOrders()
{
    int iCount = 0;
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
        if(OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol())
        {
            iCount++;
        }
    }
    return iCount;
}

double GetResistanceLevel()
{
    double dMax = High[1];
    for(int i = 1; i < 20; i++)  // Increased from 10 to 20 bars
    {
        if(High[i] > dMax) dMax = High[i];
    }
    return dMax;
}

double GetSupportLevel()
{
    double dMin = Low[1];
    for(int i = 1; i < 20; i++)  // Increased from 10 to 20 bars
    {
        if(Low[i] < dMin) dMin = Low[i];
    }
    return dMin;
}

//+------------------------------------------------------------------+
// CALCULATE AVERAGE VOLUME over N bars
//+------------------------------------------------------------------+
double CalculateAverageVolume(int iPeriod)
{
    if(iPeriod <= 0) return 0;
    
    double dSum = 0;
    for(int i = 1; i <= iPeriod && i < Bars; i++)
    {
        dSum += (double)Volume[i];
    }
    return dSum / iPeriod;
}

//+------------------------------------------------------------------+
// END OF EA
//+------------------------------------------------------------------+
