namespace MortgageForUS.MortgageForUS;
using Mortgage.Mortgage;

codeunit 60030 "GE Loan Recast"
{
    procedure RecastFromNextPeriod(LoanNo: Code[20])
    var
        Loan: Record "US Mortgage Agreement Header";
        Post: Codeunit "US Loan GL Posting";
        SchMgt: Codeunit "Mortgage Schedule Generator";
        Outstanding: Decimal;
        NewStart: Date;
    begin
        Loan.Get(LoanNo);
        if Loan.Status <> Loan.Status::Active then
            Error('Loan must be Active.');

        Outstanding := Post.CalcOutstandingPrincipal(LoanNo);

        // Set principal to outstanding and regenerate schedule from next month
        Loan."Principal Amount" := Outstanding;
        Loan.Modify(true);

        NewStart := CalcDate('1M', Today);
        SchMgt.GenerateMonthlySchedule(LoanNo, NewStart);
    end;
}
