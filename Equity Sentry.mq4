

#property copyright "© equity sentry ea"
#property link      "https://www.equitysentryea.com"

#include <WinUser32.mqh>
#import "user32.dll"
   int GetAncestor(int a0, int a1);
   int PostMessageA(int a0, int a1, int a2, string a3);
#import

extern string _A = "Action on trigger";
extern bool DisableAllExpertAdvisors = TRUE;
extern bool CloseMetatraderCompletely = FALSE;
extern string _B = "Floating P/L settings";
extern double EquityLossPercent = 10.0;
extern double EquityLossMoney = 0.0;
extern double EquityLossPips = 0.0;
extern double EquityProfitPercent = 0.0;
extern double EquityProfitMoney = 0.0;
extern double EquityProfitPips = 0.0;
extern string _C = "Cumulative P/L settings";
extern double CumulativeLossMoney = 0.0;
extern double CumulativeLossPips = 0.0;
extern double CumulativeProfitMoney = 0.0;
extern double CumulativeProfitPips = 0.0;
extern string _D = "Stop Loss management settings";
extern double TrailStopStartPips = 0.0;
extern double TrailStopMovePips = 0.0;
extern double BreakEvenStartPips = 0.0;
extern double BreakEvenMovePips = 0.0;
extern string _E = "Other settings";
extern bool UninterruptibleMode = FALSE;
extern bool IncludeCommissionsAndSwap = TRUE;
extern int Slippage = 5;
extern int MagicNumber = -1;
extern int DashboardDisplay = 2;
extern color DashboardColor = C'0x46,0x91,0xEC';
double G_point_260;
int Gi_unused_268;
int Gi_272 = 5;
bool Gi_276 = TRUE;
double Gd_280 = 0.0;
double Gd_288 = 0.0;
double Gd_296 = 0.0;
double Gd_304 = 0.0;
double Gd_312 = 0.0;
int Gi_320;
string Gs_324;
int Gia_332[11];
double G_lotstep_336;
double G_minlot_344;
double G_maxlot_352;
double Gd_360;
double G_tickvalue_368;
double G_lotsize_376;
int Gi_384;
double Gda_388[][11];
double Gda_392[][11];

// E37F0136AA3FFAF149B351F6A4C948E9
void init() {
   Gi_276 = TRUE;
   string name_0 = "Equity Sentry" + "_comment_red";
   if (ObjectFind(name_0) > -1) ObjectDelete(name_0);
   if (!IsConnected()) Alert("Equity Sentry" + " v" + "1.4" + ": No connection with broker server! EA will start running once connection established");
   if (!IsExpertEnabled()) Alert("Equity Sentry" + " v" + "1.4" + ": Please enable \"Expert Advisors\" in the top toolbar of Metatrader to run this EA");
   if (!IsTradeAllowed()) {
      Alert("Equity Sentry" + " v" + "1.4" + ": Trade is not allowed. EA cannot run. Please check \"Allow live trading\" in the \"Common\" tab of the EA properties window",
         1, 1, 1);
   }
   if (DisableAllExpertAdvisors || CloseMetatraderCompletely) {
      if (!IsDllsAllowed()) {
         f0_5("Equity Sentry" + " v" + "1.4" + ": DLL call is not allowed. EA cannot run. Please check \"Allow DLL imports\" in the \"Common\" tab of the EA properties window",
            1, 1, 1);
         return;
      }
      Gi_320 = GetAncestor(WindowHandle(Symbol(), Period()), 3);
      if (Gi_320 <= 0) {
         DisableAllExpertAdvisors = FALSE;
         CloseMetatraderCompletely = FALSE;
         f0_5("Equity Sentry" + " v" + "1.4" + ": Can not find MT4 window handle. \"DisableAllExpertAdvisors\" and \"CloseMetatraderCompletely\" is disabled", 1, 1, 0);
      }
   }
   G_lotstep_336 = MarketInfo(Symbol(), MODE_LOTSTEP);
   G_minlot_344 = MarketInfo(Symbol(), MODE_MINLOT);
   G_maxlot_352 = MarketInfo(Symbol(), MODE_MAXLOT);
   G_tickvalue_368 = MarketInfo(Symbol(), MODE_TICKVALUE);
   Gi_384 = f0_14(G_lotstep_336);
   G_lotsize_376 = MarketInfo(Symbol(), MODE_LOTSIZE);
   if (Point == 0.00001) G_point_260 = 0.0001;
   else {
      if (Point == 0.001) G_point_260 = 0.01;
      else G_point_260 = Point;
   }
   if (Digits == 5) Gi_unused_268 = 4;
   else {
      if (Digits == 3) Gi_unused_268 = 2;
      else Gi_unused_268 = Digits;
   }
   if (Digits == 3 || Digits == 5) Slippage = 10 * Slippage;
   Print("Equity Sentry" + " v" + "1.4" + " started on account #" + AccountNumber() + "; Account Name: " + AccountName() + "; Broker: " + AccountCompany());
   Print("#", AccountNumber(), " Account Info: Leverage=", AccountLeverage(), "; Broker server=", AccountServer(), "; LOTSTEP=", G_lotstep_336, "; LOTDIGITS=", Gi_384,
      "; MINLOT=", G_minlot_344, "; MAXLOT=", G_maxlot_352, "; TICKVALUE=", G_tickvalue_368, "; LOTSIZE=", G_lotsize_376);
   Print("Broker time " + TimeToStr(TimeCurrent(), TIME_DATE) + " " + TimeToStr(TimeCurrent(), TIME_SECONDS) + "; Local time " + TimeToStr(TimeLocal(), TIME_DATE) + " " +
      TimeToStr(TimeLocal(), TIME_SECONDS));
   Gs_324 = "Equity Sentry" + "_" + MagicNumber;
   if (GlobalVariableCheck(Gs_324 + "_cumulative_money")) Gd_304 = GlobalVariableGet(Gs_324 + "_cumulative_money");
   if (GlobalVariableCheck(Gs_324 + "_cumulative_pips")) Gd_312 = GlobalVariableGet(Gs_324 + "_cumulative_pips");
   f0_4();
   if (Gia_332[10] == 0) f0_10();
   start();
}

// 52D46093050F38C27267BCE42543EF60
void deinit() {
   if (UninitializeReason() != REASON_CHARTCHANGE) {
      Comment("");
      f0_12();
      return;
   }
}

// 514D8A494F087C0D549B9536C2EF3BD9
void f0_4() {
   double order_stoploss_0;
   double Ld_8;
   double Ld_16;
   int Li_24;
   double point_28;
   double point_36;
   ArrayInitialize(Gia_332, 0);
   Gd_288 = 0;
   Gd_296 = 0;
   int index_44 = 0;
   if (ArraySize(Gda_388) > 0) ArrayCopy(Gda_392, Gda_388);
   else ArrayResize(Gda_392, 0);
   ArrayResize(Gda_388, 0);
   if (ArraySize(Gda_388) > 0) ArrayInitialize(Gda_388, 0);
   for (int pos_48 = 0; pos_48 < OrdersTotal(); pos_48++) {
      if (OrderSelect(pos_48, SELECT_BY_POS) == TRUE && MagicNumber == -1 || OrderMagicNumber() == MagicNumber) {
         index_44++;
         ArrayResize(Gda_388, 11 * index_44);
         Gda_388[index_44][1] = OrderOpenPrice();
         Gda_388[index_44][2] = OrderStopLoss();
         Gda_388[index_44][3] = OrderTakeProfit();
         Gda_388[index_44][4] = OrderTicket();
         Gda_388[index_44][5] = OrderLots();
         Gda_388[index_44][6] = OrderType();
         Gda_388[index_44][7] = OrderMagicNumber();
         if (StringSubstr(OrderComment(), 0, 6) == "from #") Gda_388[index_44][8] = 1;
         else Gda_388[index_44][8] = 0;
         Gda_388[index_44][9] = OrderClosePrice();
         Gda_388[index_44][10] = OrderProfit();
         Gia_332[OrderType()]++;
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) Gia_332[6]++;
         if (OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT) {
            Gia_332[7]++;
            Gia_332[9]++;
         }
         if (OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP) {
            Gia_332[8]++;
            Gia_332[9]++;
         }
         Gia_332[10]++;
         Li_24 = MarketInfo(OrderSymbol(), MODE_DIGITS);
         point_28 = MarketInfo(OrderSymbol(), MODE_POINT);
         if (point_28 == 0.00001) point_36 = 0.0001;
         else {
            if (point_28 == 0.001) point_36 = 0.01;
            else point_36 = point_28;
         }
         Gd_288 += OrderProfit();
         if (IncludeCommissionsAndSwap) Gd_288 += OrderSwap() + OrderCommission();
         if (OrderType() == OP_BUY) Gd_296 += (OrderClosePrice() - OrderOpenPrice()) / point_36;
         else
            if (OrderType() == OP_SELL) Gd_296 += (OrderOpenPrice() - OrderClosePrice()) / point_36;
         if (TrailStopStartPips > 0.0) {
            Ld_8 = OrderOpenPrice();
            order_stoploss_0 = OrderStopLoss();
            if (OrderType() == OP_BUY) {
               if (OrderStopLoss() > 0.0 && NormalizeDouble(OrderStopLoss(), Li_24) > NormalizeDouble(OrderOpenPrice(), Li_24)) Ld_8 = OrderStopLoss();
               Ld_16 = (OrderClosePrice() - Ld_8) / point_36;
               if (Ld_16 > 0.0 && Ld_16 >= TrailStopStartPips) order_stoploss_0 = NormalizeDouble(OrderClosePrice() - (TrailStopStartPips - TrailStopMovePips) * point_36, Li_24);
            } else {
               if (OrderType() == OP_SELL) {
                  if (OrderStopLoss() > 0.0 && NormalizeDouble(OrderStopLoss(), Li_24) < NormalizeDouble(OrderOpenPrice(), Li_24)) Ld_8 = OrderStopLoss();
                  Ld_16 = (Ld_8 - OrderClosePrice()) / point_36;
                  if (Ld_16 > 0.0 && Ld_16 >= TrailStopStartPips) order_stoploss_0 = NormalizeDouble(OrderClosePrice() + (TrailStopStartPips - TrailStopMovePips) * point_36, Li_24);
               }
            }
            if (NormalizeDouble(order_stoploss_0, Li_24) != NormalizeDouble(OrderStopLoss(), Li_24)) OrderModify(OrderTicket(), OrderOpenPrice(), order_stoploss_0, OrderTakeProfit(), 0, CLR_NONE);
         }
         if (BreakEvenStartPips > 0.0) {
            order_stoploss_0 = OrderStopLoss();
            if (OrderType() == OP_BUY) {
               if (OrderStopLoss() == 0.0 || NormalizeDouble(OrderStopLoss(), Li_24) < NormalizeDouble(OrderOpenPrice(), Li_24)) {
                  Ld_16 = (OrderClosePrice() - OrderOpenPrice()) / point_36;
                  if (Ld_16 > 0.0 && Ld_16 >= BreakEvenStartPips) order_stoploss_0 = OrderOpenPrice() + BreakEvenMovePips * point_36;
               }
            } else {
               if (OrderType() == OP_SELL) {
                  if (OrderStopLoss() == 0.0 || NormalizeDouble(OrderStopLoss(), Li_24) > NormalizeDouble(OrderOpenPrice(), Li_24)) {
                     Ld_16 = (OrderOpenPrice() - OrderClosePrice()) / point_36;
                     if (Ld_16 > 0.0 && Ld_16 >= BreakEvenStartPips) order_stoploss_0 = OrderOpenPrice() - BreakEvenMovePips * point_36;
                  }
               }
            }
            if (NormalizeDouble(order_stoploss_0, Li_24) != NormalizeDouble(OrderStopLoss(), Li_24)) OrderModify(OrderTicket(), OrderOpenPrice(), order_stoploss_0, OrderTakeProfit(), 0, CLR_NONE);
         }
      }
   }
   Gda_388[0][0] = index_44;
   Gd_280 = 100.0 * (Gd_288 / AccountBalance());
}

// 87F9F735A1D36793CEAECD4E47124B63
void f0_9() {
   bool Li_0;
   for (int Li_4 = 1; Li_4 <= Gda_392[0][0]; Li_4++) {
      Li_0 = FALSE;
      for (int Li_8 = 1; Li_8 <= Gda_388[0][0]; Li_8++) {
         if (Gda_392[Li_4][4] == Gda_388[Li_8][4]) {
            Li_0 = TRUE;
            break;
         }
      }
      if (Li_0 == FALSE) f0_15(Li_4);
   }
   for (Li_8 = 1; Li_8 <= Gda_388[0][0]; Li_8++) {
      if (Gda_388[Li_8][8] <= 0.0) {
         Li_0 = FALSE;
         for (Li_4 = 1; Li_4 <= Gda_392[0][0]; Li_4++) {
            if (Gda_388[Li_8][4] == Gda_392[Li_4][4]) {
               Li_0 = TRUE;
               break;
            }
         }
         if (Li_0 == FALSE) {
         }
      }
   }
}

// F4E348AC7754502FED3CF8171FEA9144
void f0_15(int Ai_0) {
   int error_4;
   double Ld_8;
   string Ls_16;
   double point_24;
   double point_32;
   if (Gda_392[Ai_0][6] <= 1.0) {
      Ld_8 = 0;
      Ls_16 = "";
      if (OrderSelect(Gda_392[Ai_0][4], SELECT_BY_TICKET)) {
         point_24 = MarketInfo(OrderSymbol(), MODE_POINT);
         if (point_24 == 0.00001) point_32 = 0.0001;
         else {
            if (point_24 == 0.001) point_32 = 0.01;
            else point_32 = point_24;
         }
         if (OrderType() == OP_BUY) Ld_8 = (OrderClosePrice() - OrderOpenPrice()) / point_32;
         else
            if (OrderType() == OP_SELL) Ld_8 = (OrderOpenPrice() - OrderClosePrice()) / point_32;
         Gd_304 += OrderProfit();
         if (IncludeCommissionsAndSwap) Gd_304 += OrderSwap() + OrderCommission();
         Gd_312 += Ld_8;
         GlobalVariableSet(Gs_324 + "_cumulative_money", Gd_304);
         GlobalVariableSet(Gs_324 + "_cumulative_pips", Gd_312);
         Ls_16 = "; Cumulative P/L: " + DoubleToStr(Gd_304, 2) + " " + AccountCurrency() + " (" + DoubleToStr(Gd_312, 1) + " pips)";
         Print("Trade #" + OrderTicket() + " closed. Profit/Loss: " + DoubleToStr(OrderProfit(), 2) + " " + AccountCurrency() + " (" + DoubleToStr(Ld_8, 1) + " pips)" + Ls_16);
      } else {
         error_4 = GetLastError();
         Print("OrderSelect error: " + f0_13(error_4) + " (" + error_4 + ")");
      }
   }
}

// 8B7DE2AC27CCBD4DD8F37CFA8B0B9576
void f0_10() {
   Gd_304 = 0;
   Gd_312 = 0;
   GlobalVariableSet(Gs_324 + "_cumulative_money", Gd_304);
   GlobalVariableSet(Gs_324 + "_cumulative_pips", Gd_312);
}

// E5FA283BA5E9C4D2A6EAA0A5402B75F0
int f0_14(double Ad_0) {
   if (Ad_0 <= 0.0) return (0);
   double Ld_ret_8 = 0;
   while (Ad_0 < 1.0) {
      Ld_ret_8++;
      Ad_0 = 10.0 * Ad_0;
   }
   return (Ld_ret_8);
}

// C221A17B360C36A473B962FBBDF51DA3
void f0_12() {
   for (int Li_0 = ObjectsTotal() - 1; Li_0 >= 0; Li_0--)
      if (StringSubstr(ObjectName(Li_0), 0, StringLen("Equity Sentry")) == "Equity Sentry") ObjectDelete(ObjectName(Li_0));
}

// AC748519FF7D077815722BDA2AF36696
int f0_11(int A_cmd_0 = -1) {
   int error_4;
   int count_8;
   int digits_12;
   double price_24;
   double point_36;
   double point_44;
   if (f0_3() < 0) return (-1);
   int count_16 = 0;
   bool Li_20 = FALSE;
   for (int pos_32 = OrdersTotal() - 1; pos_32 >= 0; pos_32--) {
      if (OrderSelect(pos_32, SELECT_BY_POS, MODE_TRADES) != FALSE) {
         if (MagicNumber > -1)
            if (OrderMagicNumber() != MagicNumber) continue;
         if (A_cmd_0 > -1)
            if (OrderType() != A_cmd_0) continue;
         if (OrderType() <= OP_SELL) {
            count_8 = 0;
            digits_12 = MarketInfo(OrderSymbol(), MODE_DIGITS);
            RefreshRates();
            if (OrderType() == OP_BUY) price_24 = MarketInfo(OrderSymbol(), MODE_BID);
            else {
               if (OrderType() == OP_SELL) price_24 = MarketInfo(OrderSymbol(), MODE_ASK);
               else price_24 = OrderClosePrice();
            }
            for (Li_20 = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(price_24, digits_12), Slippage, Yellow); !Li_20 && count_8 <= Gi_272; Li_20 = OrderClose(OrderTicket(),
               OrderLots(), NormalizeDouble(price_24, digits_12), Slippage, Yellow)) {
               error_4 = GetLastError();
               Print("OrderClose error (" + error_4 + "): " + f0_13(error_4) + "; OrderTicket: " + OrderTicket() + ";");
               if (error_4 != 0/* NO_ERROR */ && error_4 != 4/* SERVER_BUSY */ && error_4 != 6/* NO_CONNECTION */ && error_4 != 128/* TRADE_TIMEOUT */ && error_4 != 129/* INVALID_PRICE */ &&
                  error_4 != 130/* INVALID_STOPS */ && error_4 != 135/* PRICE_CHANGED */ && error_4 != 136/* OFF_QUOTES */ && error_4 != 137/* BROKER_BUSY */ && error_4 != 138/* REQUOTE */ &&
                  error_4 != 145/* TRADE_MODIFY_DENIED */ && error_4 != 146/* TRADE_CONTEXT_BUSY */) break;
               if (count_8 >= Gi_272) break;
               Sleep(1000);
               if (error_4 == 128/* TRADE_TIMEOUT */ || error_4 == 129/* INVALID_PRICE */ || error_4 == 130/* INVALID_STOPS */ || error_4 == 136/* OFF_QUOTES */ || error_4 == 145/* TRADE_MODIFY_DENIED */ ||
                  error_4 == 146/* TRADE_CONTEXT_BUSY */) {
                  Print("EA must wait a few seconds before attempting to repeat the last trading action to obey MQL rules");
                  Sleep(5000);
               }
               count_8++;
               Print("OrderClose retry #" + count_8);
               RefreshRates();
               if (OrderType() == OP_BUY) price_24 = MarketInfo(OrderSymbol(), MODE_BID);
               else {
                  if (OrderType() == OP_SELL) price_24 = MarketInfo(OrderSymbol(), MODE_ASK);
                  else price_24 = OrderClosePrice();
               }
            }
         } else {
            count_8 = 0;
            for (Li_20 = OrderDelete(OrderTicket()); !Li_20 && count_8 <= Gi_272; Li_20 = OrderDelete(OrderTicket())) {
               error_4 = GetLastError();
               Print("OrderDelete error (" + error_4 + "): " + f0_13(error_4) + "; OrderTicket: " + OrderTicket() + ";");
               if (error_4 != 0/* NO_ERROR */ && error_4 != 4/* SERVER_BUSY */ && error_4 != 6/* NO_CONNECTION */ && error_4 != 128/* TRADE_TIMEOUT */ && error_4 != 129/* INVALID_PRICE */ &&
                  error_4 != 130/* INVALID_STOPS */ && error_4 != 135/* PRICE_CHANGED */ && error_4 != 136/* OFF_QUOTES */ && error_4 != 137/* BROKER_BUSY */ && error_4 != 138/* REQUOTE */ &&
                  error_4 != 145/* TRADE_MODIFY_DENIED */ && error_4 != 146/* TRADE_CONTEXT_BUSY */) break;
               if (count_8 >= Gi_272) break;
               Sleep(1000);
               if (error_4 == 128/* TRADE_TIMEOUT */ || error_4 == 129/* INVALID_PRICE */ || error_4 == 130/* INVALID_STOPS */ || error_4 == 136/* OFF_QUOTES */ || error_4 == 145/* TRADE_MODIFY_DENIED */ ||
                  error_4 == 146/* TRADE_CONTEXT_BUSY */) {
                  Print("EA must wait a few seconds before attempting to repeat the last trading action to obey MQL rules");
                  Sleep(5000);
               }
               count_8++;
               Print("OrderDelete retry #" + count_8);
               RefreshRates();
            }
         }
         if (error_4 > 1/* NO_RESULT */) {
            if (OrderSymbol() == Symbol()) {
               point_36 = MarketInfo(OrderSymbol(), MODE_POINT);
               if (point_36 == 0.00001) point_44 = 0.0001;
               else {
                  if (point_36 == 0.001) point_44 = 0.01;
                  else point_44 = point_36;
               }
               f0_7("error_close_trade_" + Time[0], "ce" + error_4, Yellow, Time[0], Low[0] - 2.0 * point_44);
            }
         }
         if (Li_20) count_16++;
      }
   }
   return (count_16);
}

// 6783C8B8BA8E952E63631D715B0FD499
void f0_7(string A_name_0, string A_text_8, color A_color_16, int A_datetime_20, double A_price_24) {
   if (ObjectFind(A_name_0) == -1) ObjectCreate(A_name_0, OBJ_TEXT, 0, A_datetime_20, A_price_24);
   ObjectSetText(A_name_0, A_text_8, 8, "Arial Bold", A_color_16);
}

// 4D6865C7D3DE42F8EA7B1F9F7D99B0E7
int f0_3(int Ai_0 = 30) {
   int Li_4;
   if (!IsTradeAllowed()) {
      Li_4 = GetTickCount();
      Print("Broker trade context is busy! EA will wait until it is free ...");
      while (true) {
         if (IsStopped()) {
            Print("The expert was terminated by the user!");
            return (-1);
         }
         if (GetTickCount() - Li_4 > 1000 * Ai_0) {
            Print("The waiting limit exceeded (" + Ai_0 + ")! EA may fail to perform trading actions because broker trade context is busy!");
            return (-2);
         }
         if (!(IsTradeAllowed())) continue;
         break;
      }
      Print("Broker trade context has become free! EA will continue to perform trading actions");
      return (0);
   }
   return (1);
}

// DA69CBAFF4D38B87377667EEC549DE5A
string f0_13(int Ai_0) {
   string Ls_ret_4;
   switch (Ai_0) {
   case 0:
   case 1:
      Ls_ret_4 = "no error";
      break;
   case 2:
      Ls_ret_4 = "common error";
      break;
   case 3:
      Ls_ret_4 = "invalid trade parameters";
      break;
   case 4:
      Ls_ret_4 = "trade server is busy";
      break;
   case 5:
      Ls_ret_4 = "old version of the client terminal";
      break;
   case 6:
      Ls_ret_4 = "no connection with trade server";
      break;
   case 7:
      Ls_ret_4 = "not enough rights";
      break;
   case 8:
      Ls_ret_4 = "too frequent requests";
      break;
   case 9:
      Ls_ret_4 = "malfunctional trade operation (never returned error)";
      break;
   case 64:
      Ls_ret_4 = "account disabled";
      break;
   case 65:
      Ls_ret_4 = "invalid account";
      break;
   case 128:
      Ls_ret_4 = "trade timeout";
      break;
   case 129:
      Ls_ret_4 = "invalid price";
      break;
   case 130:
      Ls_ret_4 = "invalid stops";
      break;
   case 131:
      Ls_ret_4 = "invalid trade volume";
      break;
   case 132:
      Ls_ret_4 = "market is closed";
      break;
   case 133:
      Ls_ret_4 = "trade is disabled";
      break;
   case 134:
      Ls_ret_4 = "not enough money";
      break;
   case 135:
      Ls_ret_4 = "price changed";
      break;
   case 136:
      Ls_ret_4 = "off quotes";
      break;
   case 137:
      Ls_ret_4 = "broker is busy (never returned error)";
      break;
   case 138:
      Ls_ret_4 = "requote";
      break;
   case 139:
      Ls_ret_4 = "order is locked";
      break;
   case 140:
      Ls_ret_4 = "long positions only allowed";
      break;
   case 141:
      Ls_ret_4 = "too many requests";
      break;
   case 145:
      Ls_ret_4 = "modification denied because order too close to market";
      break;
   case 146:
      Ls_ret_4 = "trade context is busy";
      break;
   case 147:
      Ls_ret_4 = "expirations are denied by broker";
      break;
   case 148:
      Ls_ret_4 = "amount of open and pending orders has reached the limit";
      break;
   case 149:
      Ls_ret_4 = "hedging is prohibited";
      break;
   case 150:
      Ls_ret_4 = "prohibited by FIFO rules";
      break;
   case 4000:
      Ls_ret_4 = "no error (never generated code)";
      break;
   case 4001:
      Ls_ret_4 = "wrong function pointer";
      break;
   case 4002:
      Ls_ret_4 = "array index is out of range";
      break;
   case 4003:
      Ls_ret_4 = "no memory for function call stack";
      break;
   case 4004:
      Ls_ret_4 = "recursive stack overflow";
      break;
   case 4005:
      Ls_ret_4 = "not enough stack for parameter";
      break;
   case 4006:
      Ls_ret_4 = "no memory for parameter string";
      break;
   case 4007:
      Ls_ret_4 = "no memory for temp string";
      break;
   case 4008:
      Ls_ret_4 = "not initialized string";
      break;
   case 4009:
      Ls_ret_4 = "not initialized string in array";
      break;
   case 4010:
      Ls_ret_4 = "no memory for array\' string";
      break;
   case 4011:
      Ls_ret_4 = "too long string";
      break;
   case 4012:
      Ls_ret_4 = "remainder from zero divide";
      break;
   case 4013:
      Ls_ret_4 = "zero divide";
      break;
   case 4014:
      Ls_ret_4 = "unknown command";
      break;
   case 4015:
      Ls_ret_4 = "wrong jump (never generated error)";
      break;
   case 4016:
      Ls_ret_4 = "not initialized array";
      break;
   case 4017:
      Ls_ret_4 = "dll calls are not allowed";
      break;
   case 4018:
      Ls_ret_4 = "cannot load library";
      break;
   case 4019:
      Ls_ret_4 = "cannot call function";
      break;
   case 4020:
      Ls_ret_4 = "expert function calls are not allowed";
      break;
   case 4021:
      Ls_ret_4 = "not enough memory for temp string returned from function";
      break;
   case 4022:
      Ls_ret_4 = "system is busy (never generated error)";
      break;
   case 4050:
      Ls_ret_4 = "invalid function parameters count";
      break;
   case 4051:
      Ls_ret_4 = "invalid function parameter value";
      break;
   case 4052:
      Ls_ret_4 = "string function internal error";
      break;
   case 4053:
      Ls_ret_4 = "some array error";
      break;
   case 4054:
      Ls_ret_4 = "incorrect series array using";
      break;
   case 4055:
      Ls_ret_4 = "custom indicator error";
      break;
   case 4056:
      Ls_ret_4 = "arrays are incompatible";
      break;
   case 4057:
      Ls_ret_4 = "global variables processing error";
      break;
   case 4058:
      Ls_ret_4 = "global variable not found";
      break;
   case 4059:
      Ls_ret_4 = "function is not allowed in testing mode";
      break;
   case 4060:
      Ls_ret_4 = "function is not confirmed";
      break;
   case 4061:
      Ls_ret_4 = "send mail error";
      break;
   case 4062:
      Ls_ret_4 = "string parameter expected";
      break;
   case 4063:
      Ls_ret_4 = "integer parameter expected";
      break;
   case 4064:
      Ls_ret_4 = "double parameter expected";
      break;
   case 4065:
      Ls_ret_4 = "array as parameter expected";
      break;
   case 4066:
      Ls_ret_4 = "requested history data in update state";
      break;
   case 4099:
      Ls_ret_4 = "end of file";
      break;
   case 4100:
      Ls_ret_4 = "some file error";
      break;
   case 4101:
      Ls_ret_4 = "wrong file name";
      break;
   case 4102:
      Ls_ret_4 = "too many opened files";
      break;
   case 4103:
      Ls_ret_4 = "cannot open file";
      break;
   case 4104:
      Ls_ret_4 = "incompatible access to a file";
      break;
   case 4105:
      Ls_ret_4 = "no order selected";
      break;
   case 4106:
      Ls_ret_4 = "unknown symbol";
      break;
   case 4107:
      Ls_ret_4 = "invalid price parameter for trade function";
      break;
   case 4108:
      Ls_ret_4 = "invalid ticket";
      break;
   case 4109:
      Ls_ret_4 = "trade is not allowed in the expert properties";
      break;
   case 4110:
      Ls_ret_4 = "longs are not allowed in the expert properties";
      break;
   case 4111:
      Ls_ret_4 = "shorts are not allowed in the expert properties";
      break;
   case 4200:
      Ls_ret_4 = "object is already exist";
      break;
   case 4201:
      Ls_ret_4 = "unknown object property";
      break;
   case 4202:
      Ls_ret_4 = "object is not exist";
      break;
   case 4203:
      Ls_ret_4 = "unknown object type";
      break;
   case 4204:
      Ls_ret_4 = "no object name";
      break;
   case 4205:
      Ls_ret_4 = "object coordinates error";
      break;
   case 4206:
      Ls_ret_4 = "no specified subwindow";
      break;
   default:
      Ls_ret_4 = "unknown error";
   }
   return (Ls_ret_4);
}

// 4A136C54CF68AD54C4048BE9F713D489
void f0_2(color A_color_0, int A_fontsize_4, int Ai_8, int Ai_12) {
   string name_16;
   for (int count_24 = 0; count_24 < Ai_8; count_24++) {
      name_16 = "Equity Sentry" + "block99-" + ((count_24 + 1));
      if (ObjectFind(name_16) == -1) ObjectCreate(name_16, OBJ_LABEL, 0, 0, 0);
      ObjectSetText(name_16, "g", A_fontsize_4, "Webdings", A_color_0);
      ObjectSet(name_16, OBJPROP_XDISTANCE, 85);
      ObjectSet(name_16, OBJPROP_YDISTANCE, Ai_12 * count_24 + 72);
      ObjectSet(name_16, OBJPROP_COLOR, A_color_0);
      ObjectSet(name_16, OBJPROP_FONTSIZE, A_fontsize_4);
   }
}

// 24A03A1794A3A42992CBCCD1976C93C9
void f0_1() {
   string name_0 = "Equity Sentry" + "block98-1";
   color color_8 = C'0x3E,0xA7,0xF5';
   if (ObjectFind(name_0) == -1) ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name_0, "g", 32, "Webdings", color_8);
   ObjectSet(name_0, OBJPROP_CORNER, 3);
   ObjectSet(name_0, OBJPROP_XDISTANCE, 1);
   ObjectSet(name_0, OBJPROP_YDISTANCE, 1);
   ObjectSet(name_0, OBJPROP_COLOR, color_8);
   ObjectSet(name_0, OBJPROP_FONTSIZE, 32);
   name_0 = "Equity Sentry" + "block98-2";
   color_8 = C'0x3E,0xA7,0xF5';
   if (ObjectFind(name_0) == -1) ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name_0, "g", 32, "Webdings", color_8);
   ObjectSet(name_0, OBJPROP_CORNER, 3);
   ObjectSet(name_0, OBJPROP_XDISTANCE, 43);
   ObjectSet(name_0, OBJPROP_YDISTANCE, 1);
   ObjectSet(name_0, OBJPROP_COLOR, color_8);
   ObjectSet(name_0, OBJPROP_FONTSIZE, 32);
   name_0 = "Equity Sentry" + "block98-3";
   color_8 = C'0x3E,0xA7,0xF5';
   if (ObjectFind(name_0) == -1) ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name_0, "g", 32, "Webdings", color_8);
   ObjectSet(name_0, OBJPROP_CORNER, 3);
   ObjectSet(name_0, OBJPROP_XDISTANCE, 75);
   ObjectSet(name_0, OBJPROP_YDISTANCE, 1);
   ObjectSet(name_0, OBJPROP_COLOR, color_8);
   ObjectSet(name_0, OBJPROP_FONTSIZE, 32);
   name_0 = "Equity Sentry" + "block98text1";
   color_8 = White;
   if (ObjectFind(name_0) == -1) ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name_0, "EA CODER", 19, "Trebuchet MS", color_8);
   ObjectSet(name_0, OBJPROP_CORNER, 3);
   ObjectSet(name_0, OBJPROP_XDISTANCE, 3);
   ObjectSet(name_0, OBJPROP_YDISTANCE, 12);
   ObjectSet(name_0, OBJPROP_COLOR, color_8);
   ObjectSet(name_0, OBJPROP_FONTSIZE, 19);
   name_0 = "Equity Sentry" + "block98text2";
   color_8 = White;
   if (ObjectFind(name_0) == -1) ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name_0, "www.ea-coder.com", 9, "Trebuchet MS", color_8);
   ObjectSet(name_0, OBJPROP_CORNER, 3);
   ObjectSet(name_0, OBJPROP_XDISTANCE, 3);
   ObjectSet(name_0, OBJPROP_YDISTANCE, 3);
   ObjectSet(name_0, OBJPROP_COLOR, color_8);
   ObjectSet(name_0, OBJPROP_FONTSIZE, 9);
}

// 5E25EA0C0E9E9932E78C6A3BFC8B3B71
void f0_5(string As_0, bool Ai_8, bool Ai_12, bool Ai_16) {
   if (Ai_8) f0_0(As_0);
   if (Ai_12) Alert(As_0);
   if (Ai_16) Gi_276 = FALSE;
}

// 08CCF560D4FF43848F1E7E2A8DBB9612
void f0_0(string A_text_0) {
   string name_8 = "Equity Sentry" + "_comment_red";
   color color_16 = Red;
   if (ObjectFind(name_8) == -1) ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name_8, A_text_0, 16, "Trebuchet MS", color_16);
   ObjectSet(name_8, OBJPROP_CORNER, 0);
   ObjectSet(name_8, OBJPROP_XDISTANCE, 3);
   ObjectSet(name_8, OBJPROP_YDISTANCE, 24);
   ObjectSet(name_8, OBJPROP_COLOR, color_16);
   ObjectSet(name_8, OBJPROP_FONTSIZE, 16);
}

// 7AA8F96D3E2488382E773F227695F918
string f0_8(int Ai_0 = 0) {
   string Ls_ret_4 = "";
   for (int count_12 = 0; count_12 < Ai_0; count_12++) Ls_ret_4 = Ls_ret_4 + " ";
   return (Ls_ret_4);
}

// 622B36C42D21ABA1EC5276008A040175
string f0_6(bool Ai_0, string As_4 = "Yes", string As_12 = "No") {
   if (Ai_0) return (As_4);
   return (As_12);
}

// F612229D97FF4ADDD803EC82458A44D2
string f0_16() {
   string Ls_0;
   string Ls_8;
   if (DashboardDisplay > 0) {
      if (DashboardDisplay > 1) {
         f0_2(DashboardColor, 170, 2, 190);
         f0_1();
      }
      Ls_0 = f0_8(30);
      Ls_8 = "\n\n\n\n\n\n";
      Ls_8 = Ls_8 + Ls_0 + "Equity Sentry" + " v" + "1.4" 
      + "\n\n";
      Ls_8 = Ls_8 + Ls_0 + "Spread: " + DoubleToStr(Gd_360 * Point / G_point_260, 1) + " pips\n";
      Ls_8 = Ls_8 
      + "\n";
      Ls_8 = Ls_8 + Ls_0 + "Commissions and Swap: " + f0_6(IncludeCommissionsAndSwap, "Included", "Not included") 
      + "\n";
      if (DisableAllExpertAdvisors) {
         Ls_8 = Ls_8 + Ls_0 + "EA is set to disable all Expert Advisors after\n" + Ls_0 + "equity trigger including " + "Equity Sentry" + ".\n" + Ls_0 + "This means that other EAs should stop\n" +
            Ls_0 + "opening trades.\n";
      } else Ls_8 = Ls_8 + Ls_0 + "EA will continue to run after equity trigger\n" + Ls_0 + "This means that other EAs can keep\n" + Ls_0 + "opening new trade.\n";
      if (CloseMetatraderCompletely) Ls_8 = Ls_8 + Ls_0 + "EA is set to close MT4 completely after\n" + Ls_0 + "equity trigger\n";
      else Ls_8 = Ls_8 + Ls_0 + "EA will not close MT4 completely\n";
      Ls_8 = Ls_8 
      + "\n";
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "Equity Loss Level (%): ");
      if (EquityLossPercent > 0.0) Ls_8 = StringConcatenate(Ls_8, EquityLossPercent, "%\n");
      else Ls_8 = StringConcatenate(Ls_8, "Disabled\n");
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "Equity Profit Level (%): ");
      if (EquityProfitPercent > 0.0) Ls_8 = StringConcatenate(Ls_8, EquityProfitPercent, "%\n");
      else Ls_8 = StringConcatenate(Ls_8, "Disabled\n");
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "     Current Equity (%): ", Gd_280, "%\n");
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "Equity Loss Level (" + AccountCurrency() + "): ");
      if (EquityLossMoney > 0.0) {
         Ls_8 = StringConcatenate(Ls_8, EquityLossMoney, " " + AccountCurrency() 
         + "\n");
      } else Ls_8 = StringConcatenate(Ls_8, "Disabled\n");
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "Equity Profit Level (" + AccountCurrency() + "): ");
      if (EquityProfitMoney > 0.0) {
         Ls_8 = StringConcatenate(Ls_8, EquityProfitMoney, " " + AccountCurrency() 
         + "\n");
      } else Ls_8 = StringConcatenate(Ls_8, "Disabled\n");
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "     Current Equity (" + AccountCurrency() + "): ", Gd_288, " " + AccountCurrency() 
      + "\n");
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "Equity Loss Level (pips): ");
      if (EquityLossPips > 0.0) Ls_8 = StringConcatenate(Ls_8, EquityLossPips, " pips\n");
      else Ls_8 = StringConcatenate(Ls_8, "Disabled\n");
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "Equity Profit Level (pips): ");
      if (EquityProfitPips > 0.0) Ls_8 = StringConcatenate(Ls_8, EquityProfitPips, " pips\n");
      else Ls_8 = StringConcatenate(Ls_8, "Disabled\n");
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "     Current Equity (pips): ", Gd_296, " pips\n");
      Ls_8 = Ls_8 
      + "\n";
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "Cumulative Loss Level (" + AccountCurrency() + "): ");
      if (CumulativeLossMoney > 0.0) {
         Ls_8 = StringConcatenate(Ls_8, CumulativeLossMoney, " " + AccountCurrency() 
         + "\n");
      } else Ls_8 = StringConcatenate(Ls_8, "Disabled\n");
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "Cumulative Profit Level (" + AccountCurrency() + "): ");
      if (CumulativeProfitMoney > 0.0) {
         Ls_8 = StringConcatenate(Ls_8, CumulativeProfitMoney, " " + AccountCurrency() 
         + "\n");
      } else Ls_8 = StringConcatenate(Ls_8, "Disabled\n");
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "     Current Cumulative P/L (" + AccountCurrency() + "): ", Gd_304, " " + AccountCurrency() 
      + "\n");
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "Cumulative Loss Level (pips): ");
      if (CumulativeLossPips > 0.0) Ls_8 = StringConcatenate(Ls_8, CumulativeLossPips, " pips\n");
      else Ls_8 = StringConcatenate(Ls_8, "Disabled\n");
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "Cumulative Profit Level (pips): ");
      if (CumulativeProfitPips > 0.0) Ls_8 = StringConcatenate(Ls_8, CumulativeProfitPips, " pips\n");
      else Ls_8 = StringConcatenate(Ls_8, "Disabled\n");
      Ls_8 = StringConcatenate(Ls_8, Ls_0, "     Current Cumulative P/L (pips): ", Gd_312, " pips\n");
      Ls_8 = Ls_8 
      + "\n";
      Ls_8 = Ls_8 + Ls_0 + "Buy/Sell/Pending/Total: " + Gia_332[0] + "/" + Gia_332[1] + "/" + Gia_332[9] + "/" + Gia_332[10] 
      + "\n";
      Ls_8 = Ls_8 
      + "\n";
      if (MagicNumber <= -1) Ls_8 = Ls_8 + Ls_0 + "All trades counted (any Magic Number)\n";
      else {
         if (MagicNumber == 0) Ls_8 = Ls_8 + Ls_0 + "Only the trades with no Magic Number counter\n" + Ls_0 + "(eg. manual trades). EA will ignore other trades\n";
         else
            if (MagicNumber > 0) Ls_8 = Ls_8 + Ls_0 + "Only trades with " + MagicNumber + " Magic Number\n" + Ls_0 + "counted. EA will ignore other trades\n";
      }
      Comment(Ls_8);
   }
   return ("");
}

// EA2B2676C28C0DB26D39331A336C6B92
void start() {
   bool Li_0;
   string Ls_4;
   if (Gi_276) {
      while (!IsStopped()) {
         Gd_360 = MarketInfo(Symbol(), MODE_SPREAD);
         f0_4();
         f0_9();
         f0_16();
         Li_0 = FALSE;
         Ls_4 = "";
         if (MagicNumber > 0) Ls_4 = "with the magic number of " + MagicNumber + " ";
         else Ls_4 = "";
         if (EquityLossPercent > 0.0) {
            if (Gd_280 < 0.0 && MathAbs(Gd_280) >= EquityLossPercent) {
               Print("Account #", AccountNumber(), " equity has reached stop loss level of ", Gd_280, "%. All trades " + Ls_4 + "will be closed. EquityLossPercent=", EquityLossPercent,
                  "%");
               f0_11();
               Li_0 = TRUE;
            }
         }
         if (EquityProfitPercent > 0.0) {
            if (Gd_280 > 0.0 && Gd_280 >= EquityProfitPercent) {
               Print("Account #", AccountNumber(), " equity has reached profit level of ", Gd_280, "%. All trades " + Ls_4 + "will be closed. EquityProfitPercent=", EquityProfitPercent,
                  "%");
               f0_11();
               Li_0 = TRUE;
            }
         }
         if (EquityLossMoney > 0.0) {
            if (Gd_288 < 0.0 && MathAbs(Gd_288) >= EquityLossMoney) {
               Print("Account #", AccountNumber(), " equity has reached stop loss level of ", Gd_288, " " + AccountCurrency() + ". All trades " + Ls_4 + "will be closed. EquityLossMoney=",
                  EquityLossMoney, " " + AccountCurrency());
               f0_11();
               Li_0 = TRUE;
            }
         }
         if (EquityProfitMoney > 0.0) {
            if (Gd_288 > 0.0 && Gd_288 >= EquityProfitMoney) {
               Print("Account #", AccountNumber(), " equity has reached profit level of ", Gd_288, " " + AccountCurrency() + ". All trades " + Ls_4 + "will be closed. EquityProfitMoney=",
                  EquityProfitMoney, " " + AccountCurrency());
               f0_11();
               Li_0 = TRUE;
            }
         }
         if (EquityLossPips > 0.0) {
            if (Gd_296 < 0.0 && MathAbs(Gd_296) >= EquityLossPips) {
               Print("Account #", AccountNumber(), " equity has reached stop loss level of ", Gd_296, " pips. All trades " + Ls_4 + "will be closed. EquityLossPips=", EquityLossPips,
                  " pips");
               f0_11();
               Li_0 = TRUE;
            }
         }
         if (EquityProfitPips > 0.0) {
            if (Gd_296 > 0.0 && Gd_296 >= EquityProfitPips) {
               Print("Account #", AccountNumber(), " equity has reached profit level of ", Gd_296, " pips. All trades " + Ls_4 + "will be closed. EquityProfitPips=", EquityProfitPips,
                  " pips");
               f0_11();
               Li_0 = TRUE;
            }
         }
         if (CumulativeLossMoney > 0.0) {
            if (Gd_304 < 0.0 && MathAbs(Gd_304) >= CumulativeLossMoney) {
               Print("Account #", AccountNumber(), " cumulative loss has reached stop loss level of ", Gd_304, " " + AccountCurrency() + ". All trades " + Ls_4 + "will be closed. CumulativeLossMoney=",
                  CumulativeLossMoney, " " + AccountCurrency());
               f0_11();
               Li_0 = TRUE;
               f0_4();
               f0_10();
            }
         }
         if (CumulativeProfitMoney > 0.0) {
            if (Gd_304 > 0.0 && Gd_304 >= CumulativeProfitMoney) {
               Print("Account #", AccountNumber(), " cumulative profit has reached profit level of ", Gd_304, " " + AccountCurrency() + ". All trades " + Ls_4 + "will be closed. CumulativeProfitMoney=",
                  CumulativeProfitMoney, " " + AccountCurrency());
               f0_11();
               Li_0 = TRUE;
               f0_4();
               f0_10();
            }
         }
         if (CumulativeLossPips > 0.0) {
            if (Gd_312 < 0.0 && MathAbs(Gd_312) >= CumulativeLossPips) {
               Print("Account #", AccountNumber(), " cumulative loss has reached stop loss level of ", Gd_312, " pips. All trades " + Ls_4 + "will be closed. CumulativeLossPips=",
                  CumulativeLossPips, " pips");
               f0_11();
               Li_0 = TRUE;
               f0_4();
               f0_10();
            }
         }
         if (CumulativeProfitPips > 0.0) {
            if (Gd_312 > 0.0 && Gd_312 >= CumulativeProfitPips) {
               Print("Account #", AccountNumber(), " cumulative profit has reached profit level of ", Gd_312, " pips. All trades " + Ls_4 + "will be closed. CumulativeProfitPips=",
                  CumulativeProfitPips, " pips");
               f0_11();
               Li_0 = TRUE;
               f0_4();
               f0_10();
            }
         }
         if (CloseMetatraderCompletely && Li_0) {
            PlaySound("alert2.wav");
            f0_5("Equity Sentry" + " v" + "1.4" + ": Metatrader window will be closed " + TimeToStr(TimeCurrent()), 1, 1, 0);
            Sleep(2000);
            if (Gi_320 <= 0) break;
            PostMessageA(Gi_320, WM_CLOSE, 0, 0);
            return;
         }
         if (DisableAllExpertAdvisors && Li_0) {
            if (IsExpertEnabled())
               if (Gi_320 > 0) PostMessageA(Gi_320, WM_COMMAND, 33020, 0);
            Sleep(2000);
            if (!IsExpertEnabled()) {
               PlaySound("alert2.wav");
               f0_5("Equity Sentry" + " v" + "1.4" + ": All EAs were disabled at " + TimeToStr(TimeCurrent()), 1, 1, 0);
            } else {
               PlaySound("timeout.wav");
               f0_5("Equity Sentry" + " v" + "1.4" + " was unable to disable all EAs at " + TimeToStr(TimeCurrent()), 1, 1, 0);
            }
         }
         if (!(UninterruptibleMode)) break;
         Sleep(1000);
      }
   }
}
