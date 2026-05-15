namespace MortgageForUS.MortgageForUS;
using Mortgage.Mortgage;

codeunit 60027 "GE Loan Accrual Runner"
{
    trigger OnRun()
    var
        Loan: Record "US Mortgage Agreement Header";
        Post: Codeunit "US Loan GL Posting";
        Amt: Decimal;
        AccrualDate: Date;
    begin
        AccrualDate := Today;

        Loan.SetRange(Status, Loan.Status::Active);
        if Loan.FindSet() then
            repeat
                // Avoid double-posting same day
                if Loan."Last Accrual Date" = AccrualDate then
                    continue;

                Amt := Post.CalcMonthlyInterestEstimate(Loan."Loan No.", AccrualDate);
                if Amt > 0 then
                    Post.PostInterestAccrual(Loan."Loan No.", AccrualDate, Amt);
            until Loan.Next() = 0;
    end;
}
