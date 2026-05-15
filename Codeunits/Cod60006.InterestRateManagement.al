namespace MortgageForUS.MortgageForUS;

codeunit 60006 "Interest Rate Management"
{
    procedure GetVariableRate(RateCode: Code[20]; AsOnDate: Date): Decimal
    var
        RateHistory: Record "GE Interest Rate History";
    begin
        RateHistory.SetRange("Rate Code", RateCode);
        RateHistory.SetFilter("Effective Date", '<=%1', AsOnDate);

        if RateHistory.FindLast() then
            exit(RateHistory."Interest Rate %");

        Error('No interest rate found for Rate Code %1', RateCode);
    end;

    procedure UpdateLoanInterest(var Loan: Record "US Loan Application Header")
    var
        RateMgmt: Codeunit "Interest Rate Management";
        BaseRate: Decimal;
    begin
        if Loan."Rate Preference" = Loan."Rate Preference"::Fixed then begin
            // Fixed → already stored
            exit;
        end;

        // Variable
        BaseRate := RateMgmt.GetVariableRate(Loan."Rate Code", WorkDate);
        Loan."Current Interest %" := BaseRate + Loan."Spread %";
        Loan.Modify();
    end;

    procedure GetCurrentInterestRate(
        RateCode: Code[20];
        SpreadPct: Decimal;
        AsOnDate: Date
    ): Decimal
    var
        RateHistory: Record "GE Interest Rate History";
        BaseRate: Decimal;
    begin
        // Find latest base rate <= AsOnDate
        RateHistory.SetRange("Rate Code", RateCode);
        RateHistory.SetFilter("Effective Date", '<=%1', AsOnDate);

        if not RateHistory.FindLast() then
            Error('No interest rate found for Rate Code %1 as of %2', RateCode, AsOnDate);

        BaseRate := RateHistory."Interest Rate %";

        exit(BaseRate + SpreadPct);
    end;


}
