//+------------------------------------------------------------------+
//|                                                   LightlandEA.mq4 |
//|                                              Smart Money Concept |
//|                                        Automated Trading Solution |
//+------------------------------------------------------------------+
#property copyright "LIGHTLAND"
#property link      "https://github.com/etbethait-jpg/lightland"
#property version   "1.00"
#property strict
#property description "LIGHTLAND - Smart Money Expert Advisor"

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
input double VolumeThreshold = 1.5;         // Volume threshold multiplier

//+------------------------------------------------------------------+
// GLOBAL VARIABLES
//+------------------------------------------------------------------+
double dPoint;
int iDigits;
bool bInitialized = false;

//+------------------------------------------------------------------+
// OnInit - Initialization function
//+------------------------------------------------------------------+
int OnInit()
{
    // Determine point value
    dPoint = (Digits % 2 == 1) ? 0.001 : 0.0001;
    iDigits = Digits;
    
    Print("═══════════════════════════════════════════════════════════");
    Print("  LIGHTLAND EA - Smart Money Concept Initialized");
    Print("═══════════════════════════════════════════════════════════");
    Print("Symbol: ", Symbol());
    Print("Period: ", Period(), " minutes");
    Print("Risk per trade: ", Risk, "%");
    Print("Stop Loss: ", StopLossPips, " pips");
    Print("Take Profit: ", TakeProfitPips, " pips");
    Print("Max Trades: ", MaxTrades);
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
    
    static datetime lastBarTime = 0;
    
    // Process only on new bar
    if(lastBarTime == Time[0]) return;
    lastBarTime = Time[0];
    
    // Check for new bar at specific hours
    if(!IsNewBar()) return;
    
    // Main trading logic
    int iOrdersOpen = CountOpenOrders();
    
    if(iOrdersOpen < MaxTrades)
    {
        // Check for BUY signal
        if(CheckBuySignal())
        {
            OpenBuyOrder();
        }
        
        // Check for SELL signal
        if(CheckSellSignal())
        {
            OpenSellOrder();
        }
    }
    
    // Manage existing positions
    ManagePositions();
}

//+------------------------------------------------------------------+
// BUY SIGNAL - Detection logic
//+------------------------------------------------------------------+
bool CheckBuySignal()
{
    // Condition 1: RSI confirmation
    if(iRSI(Symbol(), 0, RSIPeriod, PRICE_CLOSE, 1) < 50) return false;
    
    // Condition 2: Price action
    if(Close[1] <= Open[1]) return false;  // Previous candle must be bullish
    
    // Condition 3: Volume confirmation
    double dAvgVolume = iMA(Symbol(), 0, 20, 0, MODE_SMA, VOLUME, 1);
    if(Volume[1] < dAvgVolume * VolumeThreshold) return false;
    
    // Condition 4: Close above resistance
    double dResistance = GetResistanceLevel();
    if(Close[0] <= dResistance) return false;
    
    Print("═══════════════════════════════════════════════════════════");
    Print("BUY SIGNAL DETECTED - ", TimeToStr(Time[0], TIME_DATE|TIME_MINUTES));
    Print("Price: ", Close[0]);
    Print("RSI: ", iRSI(Symbol(), 0, RSIPeriod, PRICE_CLOSE, 1));
    Print("Volume Ratio: ", Volume[1] / dAvgVolume);
    Print("═══════════════════════════════════════════════════════════");
    
    return true;
}

//+------------------------------------------------------------------+
// SELL SIGNAL - Detection logic
//+------------------------------------------------------------------+
bool CheckSellSignal()
{
    // Condition 1: RSI confirmation
    if(iRSI(Symbol(), 0, RSIPeriod, PRICE_CLOSE, 1) > 50) return false;
    
    // Condition 2: Price action
    if(Close[1] >= Open[1]) return false;  // Previous candle must be bearish
    
    // Condition 3: Volume confirmation
    double dAvgVolume = iMA(Symbol(), 0, 20, 0, MODE_SMA, VOLUME, 1);
    if(Volume[1] < dAvgVolume * VolumeThreshold) return false;
    
    // Condition 4: Close below support
    double dSupport = GetSupportLevel();
    if(Close[0] >= dSupport) return false;
    
    Print("═══════════════════════════════════════════════════════════");
    Print("SELL SIGNAL DETECTED - ", TimeToStr(Time[0], TIME_DATE|TIME_MINUTES));
    Print("Price: ", Close[0]);
    Print("RSI: ", iRSI(Symbol(), 0, RSIPeriod, PRICE_CLOSE, 1));
    Print("Volume Ratio: ", Volume[1] / dAvgVolume);
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
    double dLotSize = CalculateLotSize(dStopLoss);
    
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
        Print("✓ BUY Order opened: Ticket #", iTicket, " | Lot: ", dLotSize, " | SL: ", dStopLoss, " | TP: ", dTakeProfit);
    }
    else
    {
        Print("✗ BUY Order failed: Error ", GetLastError());
    }
}

//+------------------------------------------------------------------+
// OPEN SELL ORDER
//+------------------------------------------------------------------+
void OpenSellOrder()
{
    double dStopLoss = Close[0] + (StopLossPips * dPoint);
    double dTakeProfit = Close[0] - (TakeProfitPips * dPoint);
    double dLotSize = CalculateLotSize(dStopLoss);
    
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
        Print("✓ SELL Order opened: Ticket #", iTicket, " | Lot: ", dLotSize, " | SL: ", dStopLoss, " | TP: ", dTakeProfit);
    }
    else
    {
        Print("✗ SELL Order failed: Error ", GetLastError());
    }
}

//+------------------------------------------------------------------+
// CALCULATE LOT SIZE based on risk
//+------------------------------------------------------------------+
double CalculateLotSize(double dStopLoss)
{
    double dRiskAmount = AccountBalance() * (Risk / 100.0);
    double dPipValue = MarketInfo(Symbol(), MODE_TICKVALUE);
    double dTickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
    double dStopLossPips = MathAbs(Close[0] - dStopLoss) / dTickSize;
    
    double dLotSize = dRiskAmount / (dStopLossPips * dPipValue);
    
    // Validate lot size
    double dMinLot = MarketInfo(Symbol(), MODE_MINLOT);
    double dMaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
    
    dLotSize = MathMax(dMinLot, MathMin(dLotSize, dMaxLot));
    
    return NormalizeDouble(dLotSize, 2);
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
            if(dProfit > StopLossPips * dPoint * 5)  // 5× SL = Trail activation
            {
                double dNewSL = Close[0] - (StopLossPips * dPoint * 3);  // Trail by 3× SL
                if(dNewSL > OrderStopLoss())
                {
                    OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(dNewSL, Digits), OrderTakeProfit(), 0, clrGreen);
                }
            }
        }
        else if(OrderType() == OP_SELL)
        {
            double dProfit = OrderOpenPrice() - Close[0];
            if(dProfit > StopLossPips * dPoint * 5)
            {
                double dNewSL = Close[0] + (StopLossPips * dPoint * 3);
                if(dNewSL < OrderStopLoss())
                {
                    OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(dNewSL, Digits), OrderTakeProfit(), 0, clrRed);
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
// HELPER FUNCTIONS
//+------------------------------------------------------------------+

bool IsNewBar()
{
    static datetime lastTime = 0;
    if(lastTime != Time[0])
    {
        lastTime = Time[0];
        return true;
    }
    return false;
}

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
    for(int i = 1; i < 10; i++)
    {
        if(High[i] > dMax) dMax = High[i];
    }
    return dMax;
}

double GetSupportLevel()
{
    double dMin = Low[1];
    for(int i = 1; i < 10; i++)
    {
        if(Low[i] < dMin) dMin = Low[i];
    }
    return dMin;
}

//+------------------------------------------------------------------+
// END OF EA
//+------------------------------------------------------------------+
