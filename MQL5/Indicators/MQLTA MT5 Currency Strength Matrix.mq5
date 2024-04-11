#property link          "https://www.earnforex.com/metatrader-indicators/currency-strength-matrix/"
#property version       "1.05"
#property strict
#property copyright     "EarnForex.com - 2019-2024"
#property description   "This indicator analyses the strength of a currency comparing values in several timeframes."
#property description   " "
#property description   "WARNING : You use this software at your own risk."
#property description   "The creator of these plugins cannot be held responsible for damage or loss."
#property description   " "
#property description   "Find More on www.EarnForex.com"
#property icon          "\\Files\\EF-Icon-64x64px.ico"

#include <MQLTA Utils.mqh>

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

enum Enum_CalculationMode
{
    Mode_CloseClose = 2,                // CLOSE DIFFERENCE
};

enum ENUM_CORNER
{
    TopLeft = CORNER_LEFT_UPPER,        // TOP LEFT
    TopRight = CORNER_RIGHT_UPPER,      // TOP RIGHT
    BottomLeft = CORNER_LEFT_LOWER,     // BOTTOM LEFT
    BottomRight = CORNER_RIGHT_LOWER,   // BOTTOM RIGHT
};

enum ENUM_SHOWTYPE
{
    SHOW_VALUES = 1,                    // SHOW VALUES
    SHOW_COLORS = 2,                    // SHOW COLORS
};

enum ENUM_SORTBY
{
    CURRENT = PERIOD_CURRENT,           // CURRENT PERIOD
    M1 = PERIOD_M1,                     // M1
    M5 = PERIOD_M5,                     // M5
    M15 = PERIOD_M15,                   // M15
    M30 = PERIOD_M30,                   // M30
    H1 = PERIOD_H1,                     // H1
    H4 = PERIOD_H4,                     // H4
    D1 = PERIOD_D1,                     // D1
    W1 = PERIOD_W1,                     // W1
    MN1 = PERIOD_MN1,                   // MN1
};

input string comment_0 = "==========";    // CSM Indicator
input string IndicatorName = "MQLTA-CSM"; // Indicator's Name


input string comment_2 = "==========";                  // Calculation Options
Enum_CalculationMode CalculationMode = Mode_CloseClose; // Calculation Mode
input int BarsDifference = 1;                           // Bars Of Difference Between Calculation Values

input string comment_4 = "==========";      // Matrix Values and Sorting
input ENUM_SHOWTYPE ShowType = SHOW_COLORS; // Show Values or just Colors
input ENUM_SORTBY SortByPeriod = CURRENT;   // Sort Strength By
input bool ShowAcceleration = false;        // Show The Acceleration Color
input int MinimumRefreshInterval = 5;       // Minimum Refresh Interval (Seconds)

input string comment_4b = "===================="; //Autofocus Option - If Enabled it Will Disable Notifications
input bool AutoFocus = false;                     // Change Chart to Ideal Pair Automatically
input string comment_5 = "===================="; // Notification Options
input bool EnableNotify = false;                 // Enable Notifications feature
input bool SendAlert = true;                     // Send Alert Notification
input bool SendApp = false;                      // Send Notification to Mobile
input bool SendEmail = false;                    // Send Notification via Email
input int WaitTimeNotify = 10;                   // Wait time between notifications (Minutes)
input string comment_3 = "===================="; // Notify Only If
input bool NotifyOnlyCurrentPair = false;        // Ideal Opportunity is for the Current Chart
input bool NotifyOnlyFirstAndLast = false;       // Ideal Opportunity is with First and Last Currency

input string comment_1 = "=========="; // Currencies to consider
input bool UseEUR = true;              // EUR
input bool UseUSD = true;              // USD
input bool UseGBP = true;              // GBP
input bool UseJPY = true;              // JPY
input bool UseAUD = true;              // AUD
input bool UseNZD = true;              // NZD
input bool UseCAD = true;              // CAD
input bool UseCHF = true;              // CHF

input string comment_6 = "=========="; // Timeframes to consider
input bool UseM1 = true;               // M1
input bool UseM5 = true;               // M5
input bool UseM15 = true;              // M15
input bool UseM30 = true;              // M30
input bool UseH1 = true;               // H1
input bool UseH4 = true;               // H4
input bool UseD1 = true;               // D1
input bool UseW1 = true;               // W1
input bool UseMN1 = true;              // MN1

input string comment_7 = "=========="; // Pairs Prefix and Suffix
input string CurrPrefix = "";          // Pairs Prefix
input string CurrSuffix = "";          // Pairs Suffix

input string comment_1b = "=========="; // Panel Starting Position
input int XOffset = 20;              // Horizontal offset (pixels)
input int YOffset = 20;              // Vertical offset (pixels)
input double Scale = 1.0;               // Scale for the panel's size

string Font = "Consolas";
double PreChecks = false;

string AllPairs[] =
{
    "AUDCAD",
    "AUDCHF",
    "AUDJPY",
    "AUDNZD",
    "AUDUSD",
    "CADCHF",
    "CADJPY",
    "CHFJPY",
    "EURAUD",
    "EURCAD",
    "EURCHF",
    "EURGBP",
    "EURJPY",
    "EURNZD",
    "EURUSD",
    "GBPAUD",
    "GBPCAD",
    "GBPCHF",
    "GBPJPY",
    "GBPNZD",
    "GBPUSD",
    "NZDCAD",
    "NZDCHF",
    "NZDJPY",
    "NZDUSD",
    "USDCAD",
    "USDCHF",
    "USDJPY"
};

// List all the currencies
string AllCurrencies[] =
{
    "EUR",
    "USD",
    "GBP",
    "JPY",
    "AUD",
    "NZD",
    "CAD",
    "CHF"
};

string CurrBase;
string CurrQuote;
double Base[];
double Quote[];
int CurrenciesUsed = 0;
string _CurrPrefix;
string _CurrSuffix;
int _XOffset, _YOffset;

double StrengthMatrixCurr[8][11];
double StrengthMatrixPrev[8][10];
int EUR_Index = 0;
int GBP_Index = 1;
int USD_Index = 2;
int JPY_Index = 3;
int AUD_Index = 4;
int NZD_Index = 5;
int CAD_Index = 6;
int CHF_Index = 7;

int M1_Index = 0;
int M5_Index = 1;
int M15_Index = 2;
int M30_Index = 3;
int H1_Index = 4;
int H4_Index = 5;
int D1_Index = 6;
int W1_Index = 7;
int MN1_Index = 8;

string CurrencyDesc[8] = {"EUR", "GBP", "USD", "JPY", "AUD", "NZD", "CAD", "CHF"};
bool CurrencyEnabled[8] = {true, true, true, true, true, true, true, true};
ENUM_TIMEFRAMES PeriodIndexes[9] =
{
    PERIOD_M1,
    PERIOD_M5,
    PERIOD_M15,
    PERIOD_M30,
    PERIOD_H1,
    PERIOD_H4,
    PERIOD_D1,
    PERIOD_W1,
    PERIOD_MN1
};
string PeriodDesc[9] =
{
    "M1",
    "M5",
    "M15",
    "M30",
    "H1",
    "H4",
    "D1",
    "W1",
    "MN1"
};
bool PeriodEnabled[9] =
{
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true
};

bool HistoricalOK = true;
bool MissingHistoricalNotified = false;
string MissingHistoricalPair = "";
int MissingHistoricalPeriod = 0;

datetime TimeInit = TimeCurrent();

int PanelMovX, PanelMovY, PanelLabX, PanelLabY, PanelRecX, MissingHistoricalLabelX, MissingHistoricalLabelY;

double DPIScale; // Scaling parameter for the panel based on the screen DPI.

string CalculationModeDesc()
{
    string Text = "";
    if (CalculationMode == Mode_CloseClose) Text = "CLOSE DIFFERENCE";
    return Text;
}

int OnInit(void)
{
    IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
    IndicatorSetInteger(INDICATOR_DIGITS, 4);
    ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);

    _XOffset = XOffset;
    _YOffset = YOffset;

    DPIScale = Scale * (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI) / 96.0;
    PanelMovX = (int)MathRound(26 * DPIScale);
    PanelMovY = (int)MathRound(26 * DPIScale);
    PanelLabX = (int)MathRound(160 * DPIScale);
    PanelLabY = PanelMovY;
    PanelRecX = PanelMovX * 1 + PanelLabX + 5;
    MissingHistoricalLabelX = (int)MathRound(187 * DPIScale);
    MissingHistoricalLabelY = (int)MathRound(26 * DPIScale);

    CleanChart();
    PopulatePairs();
    CheckAllPairs();
    InitializeVariables();
    CheckSorting();
    PopulateMatrix();
    DrawMatrix();
    int timeframe = ChartPeriod(0);

    EventSetTimer(MinimumRefreshInterval);
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
    EventKillTimer();
    CleanChart();
}

void OnTimer()
{
    CreateMiniPanel();
    HistoricalOK = true;
    PopulateMatrix();
    if (MatrixOpen) DrawMatrix();
    if ((!HistoricalOK) && (MatrixOpen))
    {
        DrawMissingHistorical();
    }
    else
    {
        RemoveMissingHistorical();
    }
}

int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
{
    CreateMiniPanel();
    HistoricalOK = true;
    PopulateMatrix();
    if (MatrixOpen) DrawMatrix();
    if (!HistoricalOK && MatrixOpen)
    {
        DrawMissingHistorical();
    }
    else
    {
        RemoveMissingHistorical();
    }
    return rates_total;
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (id == CHARTEVENT_OBJECT_CLICK)
    {
        ChartSetInteger(ChartID(), CHART_MOUSE_SCROLL, true); // Enable chart sideways scroll.
        if (StringFind(sparam, "R0") >= 0)
        {
            string ClickDesc = ObjectGetString(0, sparam, OBJPROP_TEXT);
            ChangeChartPeriod(ClickDesc);
        }
        if (StringFind(sparam, "-ACTION") >= 0)
        {
            string ClickDesc = ObjectGetString(0, sparam, OBJPROP_TEXT);
            ChangeChartSymbol(ClickDesc);
        }
        if (sparam == PanelExp)
        {
            DrawMatrix();
        }
        if (sparam == MissingHistoricalGoTo)
        {
            GoToMissing(MissingHistoricalPair, MissingHistoricalPeriod);
        }
    }
    else if (id == CHARTEVENT_MOUSE_MOVE)
    {
        if (StringToInteger(sparam) == 1)
        {
            if ((lparam > _XOffset + 2) && (lparam < _XOffset + 2 + PanelLabX) &&
                (dparam > _YOffset + 2) && (dparam < _YOffset + 2 + PanelLabY))
            {
                ChartSetInteger(ChartID(), CHART_MOUSE_SCROLL, false);  // Disable chart sideways scroll.
                RemoveMatrix();
                RemoveMissingHistorical();
                _XOffset = int(lparam - 2 - PanelLabX / 2);
                _YOffset = int(dparam - 2 - PanelLabY / 2);
                UpdatePanel();
            }
        }
    }
}

void ChangeChartPeriod(string Button)
{
    StringReplace(Button, "*", "");
    ENUM_TIMEFRAMES NewPeriod = 0;
    if (Button == "M1")  NewPeriod = PERIOD_M1;
    if (Button == "M5")  NewPeriod = PERIOD_M5;
    if (Button == "M15") NewPeriod = PERIOD_M15;
    if (Button == "M30") NewPeriod = PERIOD_M30;
    if (Button == "H1")  NewPeriod = PERIOD_H1;
    if (Button == "H4")  NewPeriod = PERIOD_H4;
    if (Button == "D1")  NewPeriod = PERIOD_D1;
    if (Button == "W1")  NewPeriod = PERIOD_W1;
    if (Button == "MN1") NewPeriod = PERIOD_MN1;
    ChartSetSymbolPeriod(0, Symbol(), NewPeriod);
}

void ChangeChartSymbol(string Button)
{
    string Pair = "";
    string NewSymbol = "";
    for(int i = 0; i < ArraySize(AllPairs); i++)
    {
        if (StringFind(Button, AllPairs[i]) >= 0)
        {
            Pair = AllPairs[i];
            break;
        }
    }
    ChartSetSymbolPeriod(0, Pair, Period());
}

void GoToMissing(string Pair, int Timeframe)
{
    ChartSetSymbolPeriod(0, Pair, (ENUM_TIMEFRAMES)PeriodIndexes[Timeframe]);
    ChartNavigate(0, CHART_END, -(BarsDifference + 2));
}

void PopulateMatrix()
{
    if (UseEUR) PopulateMatrixRow(EUR_Index, "EUR");
    if (UseGBP) PopulateMatrixRow(GBP_Index, "GBP");
    if (UseUSD) PopulateMatrixRow(USD_Index, "USD");
    if (UseJPY) PopulateMatrixRow(JPY_Index, "JPY");
    if (UseAUD) PopulateMatrixRow(AUD_Index, "AUD");
    if (UseNZD) PopulateMatrixRow(NZD_Index, "NZD");
    if (UseCAD) PopulateMatrixRow(CAD_Index, "CAD");
    if (UseCHF) PopulateMatrixRow(CHF_Index, "CHF");
    PossibleSetup();
}

void PopulateMatrixRow(int CurrencyIndex, string Currency)
{
    int CurrencyStrength = 0;
    int PeriodEnabledCount = 0;
    for(int i = 0; i < ArraySize(PeriodIndexes); i++)
    {
        double CellValue = PopulateMatrixCell(CurrencyIndex, Currency, i);
        if (PeriodEnabled[i])
        {
            PeriodEnabledCount++;
            if (CellValue > 0) CurrencyStrength++;
            if (CellValue < 0) CurrencyStrength--;
        }
    }
    if (CurrencyStrength == PeriodEnabledCount) StrengthMatrixCurr[CurrencyIndex][9] = 1;
    else if (CurrencyStrength == -PeriodEnabledCount) StrengthMatrixCurr[CurrencyIndex][9] = -1;
    else StrengthMatrixCurr[CurrencyIndex][9] = 0;
}

double PopulateMatrixCell(int CurrencyIndex, string Currency, int PeriodIndex)
{
    double Total = 0;
    double TotalPrev = 0;
    for(int j = 0; j < ArraySize(AllPairs); j++)
    {
        if (StringFind(AllPairs[j], Currency, 0) < 0) continue;
        double StartValue = 0;
        double EndValue = 0;
        double DiffValue = 0;
        double StartValuePrev = 0;
        double EndValuePrev = 0;
        double DiffValuePrev = 0;
        StartValue = iClose(AllPairs[j], PeriodIndexes[PeriodIndex], BarsDifference);
        EndValue = iClose(AllPairs[j], PeriodIndexes[PeriodIndex], 0);
        if (ShowAcceleration)
        {
            StartValuePrev = iClose(AllPairs[j], PeriodIndexes[PeriodIndex], BarsDifference + 1);
            EndValuePrev = iClose(AllPairs[j], PeriodIndexes[PeriodIndex], 1);
        }
        DiffValue = EndValue - StartValue;
        DiffValuePrev = EndValuePrev - StartValuePrev;
        if ((EndValue == 0) || (StartValue == 0) || (((EndValuePrev == 0) || (StartValuePrev == 0)) && (ShowAcceleration)))
        {
            HistoricalOK = false;
            MissingHistoricalPair = AllPairs[j];
            MissingHistoricalPeriod = PeriodIndex;
        }
        if (StartValue != 0) DiffValue = (DiffValue * 100 / StartValue);
        if (StartValuePrev != 0) DiffValuePrev = (DiffValuePrev * 100 / StartValuePrev);
        if (!IsBaseCurrency(Currency, AllPairs[j]))
        {
            DiffValue = -DiffValue;
            DiffValuePrev = -DiffValuePrev;
        }
        Total += DiffValue;
        TotalPrev += DiffValuePrev;
    }
    StrengthMatrixCurr[CurrencyIndex][PeriodIndex] = NormalizeDouble(Total, 4);
    StrengthMatrixPrev[CurrencyIndex][PeriodIndex] = NormalizeDouble(TotalPrev, 4);
    return Total;
}

bool IsBaseCurrency(string Currency, string Pair)
{
    string BaseCurr = "";
    string QuoteCurr = "";
    string Curr1 = "";
    string Curr2 = "";
    int Curr1Pos = -1, Curr2Pos = -1;
    for (int i = 0; i < ArraySize(AllCurrencies); i++)
    {
        int Curr1PosTmp = StringFind(Pair, AllCurrencies[i], 0);
        int Curr2PosTmp = StringFind(Pair, AllCurrencies[i], 0);
        if ((Curr1 == "") && (Curr1PosTmp != -1))
        {
            Curr1 = AllCurrencies[i];
            Curr1Pos = Curr1PosTmp;
        }
        if ((Curr1 != "") && (Curr2PosTmp != -1))
        {
            Curr2 = AllCurrencies[i];
            Curr2Pos = Curr2PosTmp;
        }
    }
    if (Curr1Pos < Curr2Pos)
    {
        BaseCurr = Curr1;
        QuoteCurr = Curr2;
    }
    else
    {
        BaseCurr = Curr2;
        QuoteCurr = Curr1;
    }
    if (Currency == BaseCurr) return true;
    else return false;
}

int SortBy = 0;
void InitializeVariables()
{
    if (SortByPeriod == CURRENT) SortBy = Period();
    if (SortByPeriod == M1) SortBy = PERIOD_M1;
    if (SortByPeriod == M5) SortBy = PERIOD_M5;
    if (SortByPeriod == M15) SortBy = PERIOD_M15;
    if (SortByPeriod == M30) SortBy = PERIOD_M30;
    if (SortByPeriod == H1) SortBy = PERIOD_H1;
    if (SortByPeriod == H4) SortBy = PERIOD_H4;
    if (SortByPeriod == D1) SortBy = PERIOD_D1;
    if (SortByPeriod == W1) SortBy = PERIOD_W1;
    if (SortByPeriod == MN1) SortBy = PERIOD_MN1;
    PeriodEnabled[0] = UseM1;
    PeriodEnabled[1] = UseM5;
    PeriodEnabled[2] = UseM15;
    PeriodEnabled[3] = UseM30;
    PeriodEnabled[4] = UseH1;
    PeriodEnabled[5] = UseH4;
    PeriodEnabled[6] = UseD1;
    PeriodEnabled[7] = UseW1;
    PeriodEnabled[8] = UseMN1;
    CurrencyEnabled[0] = UseEUR;
    CurrencyEnabled[1] = UseGBP;
    CurrencyEnabled[2] = UseUSD;
    CurrencyEnabled[3] = UseJPY;
    CurrencyEnabled[4] = UseAUD;
    CurrencyEnabled[5] = UseNZD;
    CurrencyEnabled[6] = UseCAD;
    CurrencyEnabled[7] = UseCHF;
    if (ShowType == SHOW_COLORS)
    {
        CellX = (int)MathRound(35 * DPIScale);
        CellY = (int)MathRound(20 * DPIScale);
    }
    if (ShowType == SHOW_VALUES)
    {
        CellX = (int)MathRound(65 * DPIScale);
        CellY = (int)MathRound(20 * DPIScale);
    }
    IdealBuy = -1;
    IdealSell = -1;
    HistoricalOK = true;
    MissingHistoricalNotified = false;
    MissingHistoricalPair = "";
    MissingHistoricalPeriod = 0;
    TimeInit = TimeCurrent();
}

string PanelBase = IndicatorName + "-BAS";
string PanelMove = IndicatorName + "-MOV";
string PanelOptions = IndicatorName + "-OPT";
string PanelClose = IndicatorName + "-CLO";
string PanelLabel = IndicatorName + "-LAB";
string PanelExp = IndicatorName + "-EXP";
void CreateMiniPanel()
{
    ObjectCreate(0, PanelBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, PanelBase, OBJPROP_XDISTANCE, _XOffset);
    ObjectSetInteger(0, PanelBase, OBJPROP_YDISTANCE, _YOffset);
    ObjectSetInteger(0, PanelBase, OBJPROP_XSIZE, PanelRecX);
    ObjectSetInteger(0, PanelBase, OBJPROP_YSIZE, PanelMovY + 2 * 2);
    ObjectSetInteger(0, PanelBase, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, PanelBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelBase, OBJPROP_FONTSIZE, int(8 * Scale));
    ObjectSetInteger(0, PanelBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelBase, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, PanelExp, OBJ_EDIT, 0, 0, 0);
    ObjectSetInteger(0, PanelExp, OBJPROP_XDISTANCE, _XOffset + PanelLabX + 3);
    ObjectSetInteger(0, PanelExp, OBJPROP_YDISTANCE, _YOffset + 2);
    ObjectSetInteger(0, PanelExp, OBJPROP_XSIZE, PanelMovX);
    ObjectSetInteger(0, PanelExp, OBJPROP_YSIZE, PanelMovX);
    ObjectSetInteger(0, PanelExp, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelExp, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelExp, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelExp, OBJPROP_READONLY, true);
    ObjectSetInteger(0, PanelExp, OBJPROP_FONTSIZE, int(12 * Scale));
    ObjectSetString(0, PanelExp, OBJPROP_TOOLTIP, "Show Matrix");
    ObjectSetInteger(0, PanelExp, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, PanelExp, OBJPROP_FONT, Font);
    ObjectSetString(0, PanelExp, OBJPROP_TEXT, "#");
    ObjectSetInteger(0, PanelExp, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelExp, OBJPROP_COLOR, clrNavy);
    ObjectSetInteger(0, PanelExp, OBJPROP_BGCOLOR, clrKhaki);
    ObjectSetInteger(0, PanelExp, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, PanelLabel, OBJ_EDIT, 0, 0, 0);
    ObjectSetInteger(0, PanelLabel, OBJPROP_XDISTANCE, _XOffset + 2);
    ObjectSetInteger(0, PanelLabel, OBJPROP_YDISTANCE, _YOffset + 2);
    ObjectSetInteger(0, PanelLabel, OBJPROP_XSIZE, PanelLabX);
    ObjectSetInteger(0, PanelLabel, OBJPROP_YSIZE, PanelLabY);
    ObjectSetInteger(0, PanelLabel, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelLabel, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelLabel, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelLabel, OBJPROP_READONLY, true);
    ObjectSetString(0, PanelLabel, OBJPROP_TOOLTIP, "Drag to Move");
    ObjectSetInteger(0, PanelLabel, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, PanelLabel, OBJPROP_TEXT, "STRENGTH MATRIX");
    ObjectSetString(0, PanelLabel, OBJPROP_FONT, Font);
    ObjectSetInteger(0, PanelLabel, OBJPROP_FONTSIZE, int(12 * Scale));
    ObjectSetInteger(0, PanelLabel, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelLabel, OBJPROP_COLOR, clrNavy);
    ObjectSetInteger(0, PanelLabel, OBJPROP_BGCOLOR, clrKhaki);
    ObjectSetInteger(0, PanelLabel, OBJPROP_BORDER_COLOR, clrBlack);
}

void UpdatePanel()
{
    ObjectSetInteger(0, PanelBase, OBJPROP_XDISTANCE, _XOffset);
    ObjectSetInteger(0, PanelBase, OBJPROP_YDISTANCE, _YOffset);
    ObjectSetInteger(0, PanelExp, OBJPROP_XDISTANCE, _XOffset + PanelLabX + 3);
    ObjectSetInteger(0, PanelExp, OBJPROP_YDISTANCE, _YOffset + 2);
    ObjectSetInteger(0, PanelLabel, OBJPROP_XDISTANCE, _XOffset + 2);
    ObjectSetInteger(0, PanelLabel, OBJPROP_YDISTANCE, _YOffset + 2);
}

void CleanChart()
{
    ObjectsDeleteAll(ChartID(), IndicatorName);
}


void DetectPrefixSuffix()
{
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        if (StringFind(Symbol(), AllPairs[i], 0) >= 0)
        {
            string SymbTemp = Symbol();
            int res = StringReplace(SymbTemp, AllPairs[i], " ");
            string PrSuTemp[];
            res = StringSplit(SymbTemp, StringGetCharacter(" ", 0), PrSuTemp);
            _CurrPrefix = PrSuTemp[0];
            _CurrSuffix = PrSuTemp[1];
        }
    }
}

void PopulatePairs()
{
    if ((StringLen(CurrPrefix) == 0) && (StringLen(CurrSuffix) == 0))
    {
        DetectPrefixSuffix();
    }
    else
    {
      _CurrPrefix = CurrPrefix;
      _CurrSuffix = CurrSuffix;
    }
    CurrenciesUsed = 0;
    if (UseEUR) CurrenciesUsed++;
    if (UseUSD) CurrenciesUsed++;
    if (UseGBP) CurrenciesUsed++;
    if (UseJPY) CurrenciesUsed++;
    if (UseCAD) CurrenciesUsed++;
    if (UseCHF) CurrenciesUsed++;
    if (UseAUD) CurrenciesUsed++;
    if (UseNZD) CurrenciesUsed++;
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        AllPairs[i] = _CurrPrefix + AllPairs[i] + _CurrSuffix;
    }
}

// Checks if all required pairs are in the Market Watch, selecting it in the process. If cannot be found at all, return false to signal a critical error.
bool CheckAllPairs()
{
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        if (!SymbolSelect(AllPairs[i], true)) // Failed to select a necessary currency pair.
        {
            Alert("Error: " + AllPairs[i] + " not found. Cannot proceed.");
            return false;
        }
    }
    return true;
}

string MissingHistoricalBase = IndicatorName + "-MISSHISTORY-BAS";
string MissingHistoricalLabel = IndicatorName + "-MISSHISTORY-LAB";
string MissingHistoricalGoTo = IndicatorName + "-MISSHISTORY-GOTO";
void DrawMissingHistorical()
{
    RemoveMissingHistorical();
    int MissingHistoricalRecX = MissingHistoricalLabelX + 4;

    int MissingHistoricalXStart = _XOffset;
    int MissingHistoricalYStart = _YOffset + PanelLabY + MatrixY + 6;

    ObjectCreate(0, MissingHistoricalBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_XDISTANCE, MissingHistoricalXStart);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_YDISTANCE, MissingHistoricalYStart + 2);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_XSIZE, MissingHistoricalRecX);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_YSIZE, (MissingHistoricalLabelY + 2) * 2 + 1);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_FONTSIZE, int(8 * Scale));
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, MissingHistoricalLabel, OBJ_EDIT, 0, 0, 0);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_XDISTANCE, MissingHistoricalXStart + 2);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_YDISTANCE, MissingHistoricalYStart + 4);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_XSIZE, MissingHistoricalLabelX);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_YSIZE, MissingHistoricalLabelY);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_STATE, false);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_READONLY, true);
    ObjectSetString(0, MissingHistoricalLabel, OBJPROP_TOOLTIP, "PLEASE DOWNLOAD HISTORICAL DATA FOR ALL PAIRS AND ALL TIMEFRAMES");
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, MissingHistoricalLabel, OBJPROP_TEXT, "HISTORICAL DATA NEEDED");
    ObjectSetString(0, MissingHistoricalLabel, OBJPROP_FONT, Font);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_FONTSIZE, int(10 * Scale));
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_BGCOLOR, clrRed);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, MissingHistoricalGoTo, OBJ_EDIT, 0, 0, 0);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_XDISTANCE, MissingHistoricalXStart + 2);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_YDISTANCE, MissingHistoricalYStart + MissingHistoricalLabelY + 5);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_XSIZE, MissingHistoricalLabelX);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_YSIZE, MissingHistoricalLabelY);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_STATE, false);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_READONLY, true);
    ObjectSetString(0, MissingHistoricalGoTo, OBJPROP_TOOLTIP, "CLICK TO GO TO THE MISSING HISTORICAL DATA");
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, MissingHistoricalGoTo, OBJPROP_TEXT, "GO TO - " + MissingHistoricalPair + " - " + PeriodDesc[MissingHistoricalPeriod]);
    ObjectSetString(0, MissingHistoricalGoTo, OBJPROP_FONT, Font);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_FONTSIZE, int(10 * Scale));
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_BGCOLOR, clrGreen);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_BORDER_COLOR, clrBlack);
}

void RemoveMissingHistorical()
{
    ObjectsDeleteAll(ChartID(), IndicatorName + "-MISSHISTORY-");
}

int CellX;
int CellY;
void DrawCell(int Row, int Column, string Value, string Tooltip, color Color, color ColorText = clrBlack)
{
    string CellName = IndicatorName + "-M-CELL-R" + IntegerToString(Row) + "-C" + IntegerToString(Column);

    ObjectCreate(0, CellName, OBJ_EDIT, 0, 0, 0);
    ObjectSetInteger(0, CellName, OBJPROP_XDISTANCE, MatrixXStart + (CellX + 1) * Column + 2);
    ObjectSetInteger(0, CellName, OBJPROP_YDISTANCE, MatrixYStart + (CellY + 1) * Row + 2);
    ObjectSetInteger(0, CellName, OBJPROP_XSIZE, CellX);
    ObjectSetInteger(0, CellName, OBJPROP_YSIZE, CellY);
    ObjectSetInteger(0, CellName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, CellName, OBJPROP_STATE, false);
    ObjectSetInteger(0, CellName, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, CellName, OBJPROP_READONLY, true);
    ObjectSetInteger(0, CellName, OBJPROP_FONTSIZE, int(9 * Scale));
    ObjectSetString(0, CellName, OBJPROP_TOOLTIP, Tooltip);
    ObjectSetInteger(0, CellName, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, CellName, OBJPROP_FONT, Font);
    ObjectSetInteger(0, CellName, OBJPROP_SELECTABLE, false);
    ObjectSetString(0, CellName, OBJPROP_TEXT, Value);
    ObjectSetInteger(0, CellName, OBJPROP_COLOR, ColorText);
    ObjectSetInteger(0, CellName, OBJPROP_BGCOLOR, Color);
    ObjectSetInteger(0, CellName, OBJPROP_BORDER_COLOR, clrBlack);

}


bool MatrixOpen = false;
int MatrixXStart;
int MatrixYStart;
int MatrixY = 0;
void DrawMatrix()
{
    MatrixXStart = _XOffset;
    MatrixYStart = _YOffset + PanelLabY + 2 + 4;
    RemoveMatrix();
    SortByStrength();
    string MatrixBase = IndicatorName + "-M-BASE";
    ObjectCreate(0, MatrixBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, MatrixBase, OBJPROP_XDISTANCE, MatrixXStart);
    ObjectSetInteger(0, MatrixBase, OBJPROP_YDISTANCE, MatrixYStart);
    ObjectSetInteger(0, MatrixBase, OBJPROP_XSIZE, CellX);
    ObjectSetInteger(0, MatrixBase, OBJPROP_YSIZE, CellY + 2 * 2);
    ObjectSetInteger(0, MatrixBase, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, MatrixBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, MatrixBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, MatrixBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, MatrixBase, OBJPROP_FONTSIZE, int(8 * Scale));
    ObjectSetInteger(0, MatrixBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, MatrixBase, OBJPROP_COLOR, clrBlack);
    int r = 0;
    int c = 0;
    int col = 0;
    for (int i = 0; i < 9; i++)
    {
        c = 0;
        color HeaderColor = clrLightCyan;
        if (i == 0)
        {
            for (int j = 0; j <= 10; j++)
            {
                if (j == 0)
                {
                    int HoldRankTime = int(TimeCurrent() - TimeInit);
                    DrawCell(i, 0, "", "Indicator initialized " + IntegerToString(HoldRankTime) + " seconds ago", HeaderColor);
                    c++;
                }
                else if ((j > 0) && (j < 10))
                {
                    if (PeriodEnabled[j - 1])
                    {
                        string Tooltip = "PERIOD " + PeriodDesc[j - 1] + " - CLICK TO CHANGE";
                        string Value = PeriodDesc[j - 1];
                        if (SortBy == PeriodIndexes[j - 1])
                        {
                            Tooltip = "SORTED BY - " + Tooltip;
                            Value = Value + "*";
                        }
                        DrawCell(r, c, Value, Tooltip, HeaderColor);
                        c++;
                    }
                }
                if (j == 10)
                {
                    string Value = "A";
                    string Tooltip = "IDEAL ACTION - B=BUY / S=SELL / W=WAIT";
                    DrawCell(r, c, Value, Tooltip, HeaderColor);
                    c++;
                }
            }
            r++;
            continue;
        }
        int k = ArraySorted[i - 1];
        if (!CurrencyEnabled[k]) continue;
        for (int j = 0; j <= 10; j++)
        {
            if (j == 0)
            {
                color Color = HeaderColor;
                if (StringFind(Symbol(), CurrencyDesc[k]) >= 0) Color = clrLightSkyBlue;
                int HoldRankTime = 0;
                if (StrengthMatrixCurr[k][10] == 0) HoldRankTime = int(TimeCurrent() - TimeInit);
                else HoldRankTime = int(TimeCurrent() - StrengthMatrixCurr[k][10]);
                DrawCell(r, c, CurrencyDesc[k], CurrencyDesc[k] + " - holding this position for already " + IntegerToString(HoldRankTime) + " seconds", Color);
                c++;
            }
            else if ((j > 0) && (j < 10))
            {
                if (!PeriodEnabled[j - 1]) continue;
                double DoubleValue = StrengthMatrixCurr[k][j - 1];
                string Value = DoubleToString(DoubleValue, 4);
                string Tooltip = "% of change";
                color Color = clrLightCyan;
                color ColorText = clrWhite;
                if (DoubleValue == 0)
                {
                    Color = clrWhite;
                    ColorText = clrBlack;
                }
                if (DoubleValue > 0)
                {
                    Color = clrGreen;
                    ColorText = clrWhite;
                    Value = "+" + Value;
                }
                if (DoubleValue < 0)
                {
                    Color = clrRed;
                    ColorText = clrWhite;
                }
                if (ShowType == SHOW_COLORS)
                {
                    Tooltip = Value;
                    if (DoubleValue > 0) Value = "";
                    if (DoubleValue < 0) Value = "";
                    if (DoubleValue == 0) Value = "";
                }
                if (ShowAcceleration)
                {
                    double DoubleValuePrev = StrengthMatrixPrev[k][j - 1];
                    if ((DoubleValue <= DoubleValuePrev) && (DoubleValue < 0))
                    {
                        Color = clrRed;
                        ColorText = clrWhite;
                    }
                    if ((DoubleValue > DoubleValuePrev) && (DoubleValue < 0))
                    {
                        ColorText = clrBlack;
                        Color = clrGold;
                    }
                    if ((DoubleValue < DoubleValuePrev) && (DoubleValue > 0))
                    {
                        Color = clrPaleGreen;
                        ColorText = clrBlack;
                    }
                    if ((DoubleValue >= DoubleValuePrev) && (DoubleValue > 0))
                    {
                        Color = clrGreen;
                        ColorText = clrWhite;
                    }
                }
                DrawCell(r, c, Value, Tooltip, Color, ColorText);
                c++;
            }
            if (j == 10)
            {
                double DoubleValue = StrengthMatrixCurr[k][j - 1];
                string Value = DoubleToString(DoubleValue, 4);
                string Tooltip = "";
                color Color = clrLightCyan;
                color ColorText = clrBlack;
                if (DoubleValue > 0)
                {
                    Color = clrGreen;
                    ColorText = clrWhite;
                    Value = "B";
                    Tooltip = "POSSIBLE BUY";
                }
                if (DoubleValue < 0)
                {
                    Color = clrRed;
                    ColorText = clrWhite;
                    Value = "S";
                    Tooltip = "POSSIBLE SELL";
                }
                if (DoubleValue == 0)
                {
                    Color = clrLightCyan;
                    ColorText = clrBlack;
                    Value = "W";
                    Tooltip = "WAIT";
                }
                DrawCell(r, c, Value, Tooltip, Color, ColorText);
                c++;
            }
        }
        r++;
        if (c > col) col = c;
    }
    string ActionName = IndicatorName + "-M-ACTION";
    string Tooltip = "POSSIBLE SETUP OR ACTION - CLICK TO GO TO THE PAIR";
    string Value = "";
    string ValuesTmp[];
    color Color = clrWhite;
    color ColorText = clrBlack;
    StringSplit(IdealAction, StringGetCharacter("-", 0), ValuesTmp);
    if (StringFind(IdealAction, "LONG") >= 0)
    {
        Value += "POSSIBLE BUY " + ValuesTmp[1];
        Color = clrGreen;
        ColorText = clrWhite;
        Tooltip = "POSSIBLE SETUP OR ACTION - CLICK TO GO OPEN THE PAIR";
    }
    else if (StringFind(IdealAction, "SHORT") >= 0)
    {
        Value += "POSSIBLE SELL " + ValuesTmp[1];
        Color = clrRed;
        ColorText = clrWhite;
        Tooltip = "POSSIBLE SETUP OR ACTION - CLICK TO GO OPEN THE PAIR";
    }
    else
    {
        Value += "WAIT A BETTER SETUP";
        Color = clrLightCyan;
        ColorText = clrBlack;
        Tooltip = "POSSIBLE SETUP OR ACTION";
    }

    ObjectCreate(0, ActionName, OBJ_EDIT, 0, 0, 0);
    ObjectSetInteger(0, ActionName, OBJPROP_XDISTANCE, MatrixXStart + (CellX + 1) * 0 + 2);
    ObjectSetInteger(0, ActionName, OBJPROP_YDISTANCE, MatrixYStart + (CellY + 1) * r + 2);
    ObjectSetInteger(0, ActionName, OBJPROP_XSIZE, (CellX + 1) * col - 1);
    ObjectSetInteger(0, ActionName, OBJPROP_YSIZE, CellY);
    ObjectSetInteger(0, ActionName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, ActionName, OBJPROP_STATE, false);
    ObjectSetInteger(0, ActionName, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, ActionName, OBJPROP_READONLY, true);
    ObjectSetInteger(0, ActionName, OBJPROP_FONTSIZE, int(9 * Scale));
    ObjectSetString(0, ActionName, OBJPROP_TOOLTIP, Tooltip);
    ObjectSetInteger(0, ActionName, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, ActionName, OBJPROP_FONT, Font);
    ObjectSetInteger(0, ActionName, OBJPROP_SELECTABLE, false);
    ObjectSetString(0, ActionName, OBJPROP_TEXT, Value);
    ObjectSetInteger(0, ActionName, OBJPROP_COLOR, ColorText);
    ObjectSetInteger(0, ActionName, OBJPROP_BGCOLOR, Color);
    ObjectSetInteger(0, ActionName, OBJPROP_BORDER_COLOR, clrBlack);
    r++;
    MatrixY = (CellY + 1) * r + 3;
    ObjectSetInteger(0, MatrixBase, OBJPROP_XSIZE, (CellX + 1) * col + 3);
    ObjectSetInteger(0, MatrixBase, OBJPROP_YSIZE, MatrixY);
    MatrixOpen = true;
}

void RemoveMatrix()
{
    ObjectsDeleteAll(ChartID(), IndicatorName + "-M-");
    MatrixOpen = false;
}


int ArraySorted[] = {0, 0, 0, 0, 0, 0, 0, 0};
void SortByStrength()
{
    int SortingIndex = -1;
    if ((SortBy == PERIOD_M1) &&  (UseM1))  SortingIndex = M1_Index;
    if ((SortBy == PERIOD_M5) &&  (UseM5))  SortingIndex = M5_Index;
    if ((SortBy == PERIOD_M15) && (UseM15)) SortingIndex = M15_Index;
    if ((SortBy == PERIOD_M30) && (UseM30)) SortingIndex = M30_Index;
    if ((SortBy == PERIOD_H1) &&  (UseH1))  SortingIndex = H1_Index;
    if ((SortBy == PERIOD_H4) &&  (UseH4))  SortingIndex = H4_Index;
    if ((SortBy == PERIOD_D1) &&  (UseD1))  SortingIndex = D1_Index;
    if ((SortBy == PERIOD_W1) &&  (UseW1))  SortingIndex = W1_Index;
    if ((SortBy == PERIOD_MN1) && (UseMN1)) SortingIndex = MN1_Index;
    if (SortingIndex == -1)
    {
        return;
    }
    double ArrayTmp[8] = {0, 0, 0, 0, 0, 0, 0, 0};
    for (int i = 0; i < ArraySize(CurrencyDesc); i++)
    {
        ArrayTmp[i] = StrengthMatrixCurr[i][SortingIndex];
    }
    double Minimum = ArrayTmp[ArrayMinimum(ArrayTmp)] - 1;
    for (int i = 0; i < ArraySize(ArraySorted); i++)
    {
        int PrevIndex = ArraySorted[i];
        ArraySorted[i] = ArrayMaximum(ArrayTmp);
        ArrayTmp[ArrayMaximum(ArrayTmp)] = Minimum;
        if (ArraySorted[i] != PrevIndex)
        {
            StrengthMatrixCurr[ArraySorted[i]][10] = (double)TimeCurrent();
        }
    }
}

void CheckSorting()
{
    for (int i = 0; i < ArraySize(ArraySorted); i++) ArraySorted[i] = i;
    int SortingIndex = -1;
    if ((SortBy == PERIOD_M1)  && (UseM1))  SortingIndex = M1_Index;
    if ((SortBy == PERIOD_M5)  && (UseM5))  SortingIndex = M5_Index;
    if ((SortBy == PERIOD_M15) && (UseM15)) SortingIndex = M15_Index;
    if ((SortBy == PERIOD_M30) && (UseM30)) SortingIndex = M30_Index;
    if ((SortBy == PERIOD_H1)  && (UseH1))  SortingIndex = H1_Index;
    if ((SortBy == PERIOD_H4)  && (UseH4))  SortingIndex = H4_Index;
    if ((SortBy == PERIOD_D1)  && (UseD1))  SortingIndex = D1_Index;
    if ((SortBy == PERIOD_W1)  && (UseW1))  SortingIndex = W1_Index;
    if ((SortBy == PERIOD_MN1) && (UseMN1)) SortingIndex = MN1_Index;
    if (SortingIndex == -1)
    {
        Print("Impossible to sort because the timeframe is not enabled.");
        return;
    }
}


int IdealBuy = -1;
int IdealSell = -1;
string IdealAction = "";
string IdealPair = "";
void PossibleSetup()
{
    IdealBuy = -1;
    IdealSell = -1;
    IdealAction = "";
    IdealPair = "";
    string Pair = "";
    for (int i = 0; i < ArraySize(ArraySorted); i++)
    {
        if (StrengthMatrixCurr[ArraySorted[i]][9] == 1)
        {
            IdealBuy = ArraySorted[i];
            break;
        }
    }
    for (int i = ArraySize(ArraySorted) - 1; i >= 0; i--)
    {
        if (StrengthMatrixCurr[ArraySorted[i]][9] == -1)
        {
            IdealSell = ArraySorted[i];
            break;
        }
    }
    if (IdealSell == -1 || IdealBuy == -1)
    {
        IdealAction = "WAIT A BETTER SETUP";
        return;
    }
    if (IdealSell >= 0 && IdealBuy >= 0)
    {
        for (int i = 0; i < ArraySize(AllPairs); i++)
        {
            if ((StringFind(AllPairs[i], CurrencyDesc[IdealBuy]) >= 0) && (StringFind(AllPairs[i], CurrencyDesc[IdealSell]) >= 0))
            {
                Pair = AllPairs[i];
                break;
            }
        }
        string BaseCurr = "";
        string QuoteCurr = "";
        string Curr1 = "";
        string Curr2 = "";
        int Curr1Pos = -1, Curr2Pos = -1;
        for (int i = 0; i < ArraySize(AllCurrencies); i++)
        {
            int Curr1PosTmp = StringFind(Pair, AllCurrencies[i], 0);
            int Curr2PosTmp = StringFind(Pair, AllCurrencies[i], 0);
            if ((Curr1 == "") && (Curr1PosTmp != -1))
            {
                Curr1 = AllCurrencies[i];
                Curr1Pos = Curr1PosTmp;
            }
            if ((Curr1) != "" && (Curr2PosTmp != -1))
            {
                Curr2 = AllCurrencies[i];
                Curr2Pos = Curr2PosTmp;
            }
        }
        if (Curr1Pos < Curr2Pos)
        {
            BaseCurr = Curr1;
            QuoteCurr = Curr2;
        }
        else
        {
            BaseCurr = Curr2;
            QuoteCurr = Curr1;
        }
        if ((BaseCurr == CurrencyDesc[IdealBuy]) && (QuoteCurr == CurrencyDesc[IdealSell]))
        {
            IdealAction = "LONG-" + Pair;
        }
        if ((BaseCurr == CurrencyDesc[IdealSell]) && (QuoteCurr == CurrencyDesc[IdealBuy]))
        {
            IdealAction = "SHORT-" + Pair;
        }
    }
    IdealPair = Pair;
    if (StringLen(Pair) > 0)
    {
        NotifyPossibleTrade();
        if ((AutoFocus) && (StringFind(Symbol(), Pair) == -1)) ChangeChartSymbol(Pair);
    }
}

bool IdealActionIsCurrChart()
{
    if (StringFind(Symbol(), IdealPair) >= 0) return true;
    else return false;
}

bool IdealActionIsFirstAndLast()
{
    string IdealCurr1 = CurrencyDesc[ArraySorted[0]];
    string IdealCurr2 = CurrencyDesc[ArraySorted[CurrenciesUsed - 1]];
    if ((StringFind(IdealPair, IdealCurr1) >= 0) && (StringFind(IdealPair, IdealCurr2) >= 0)) return true;
    else return false;
}

string LastAlertDirection = "";
void NotifyPossibleTrade()
{
    if (!EnableNotify) return;
    if ((!SendAlert) && (!SendApp) && (!SendEmail)) return;
    if ((NotifyOnlyCurrentPair) && (!IdealActionIsCurrChart())) return;
    if ((NotifyOnlyFirstAndLast) && (!IdealActionIsFirstAndLast())) return;
    string Setup = "";
    string ValuesTmp[];
    StringSplit(IdealAction, StringGetCharacter("-", 0), ValuesTmp);
    if (LastAlertDirection == IdealAction) return; // Same arrow, don't alert again.
    if (StringFind(IdealAction, "LONG") >= 0)
    {
        Setup += "POSSIBLE BUY " + ValuesTmp[1];
    }
    else if (StringFind(IdealAction, "SHORT") >= 0)
    {
        Setup += "POSSIBLE SELL " + ValuesTmp[1];
    }
    else
    {
        return;
    }
    string EmailSubject = IndicatorName + " " + Setup;
    string EmailBody = AccountCompany() + " - " + AccountName() + " - " + IntegerToString(AccountNumber()) + "\r\n" + IndicatorName + " Notification:\r\n";
    EmailBody += Setup;
    string AppText = AccountCompany() + " - " + AccountName() + " - " + IntegerToString(AccountNumber()) + " - " + IndicatorName + " - ";
    AppText += Setup;
    if (SendAlert) Alert(Setup);
    if (SendEmail)
    {
        if (!SendMail(EmailSubject, EmailBody)) Print("Error sending email " + IntegerToString(GetLastError()));
    }
    if (SendApp)
    {
        if (!SendNotification(AppText)) Print("Error sending notification " + IntegerToString(GetLastError()));
    }
    LastAlertDirection = IdealAction;
}
//+------------------------------------------------------------------+