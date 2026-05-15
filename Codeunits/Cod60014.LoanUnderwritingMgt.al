namespace MortgageForUS.MortgageForUS;

codeunit 60016 "Loan Underwriting Mgt"
{
    // procedure EvaluateApplication(AppNo: Code[20])
    // var
    //     LoanApp: Record "US Loan Application Header";
    //     Fin: Record "Loan Applicant Financials";
    //     Coll: Record "US Loan App Collateral Line";
    //     FOIR: Decimal;
    //     LTV: Decimal;
    // begin
    //     LoanApp.Get(AppNo);
    //     Fin.Get(AppNo);
    //     Coll.Get(AppNo);

    //     // FOIR calculation
    //     FOIR := (Fin."Existing EMI" / Fin."Monthly Income") * 100;

    //     // LTV calculation
    //     LTV := (LoanApp."Requested Amount" / Coll."Purchase Price") * 100;

    //     if (FOIR > 50) or (Fin."Credit Score" < 650) or (LTV > 80) then begin
    //         LoanApp.Status := LoanApp.Status::Rejected;
    //     end else begin
    //         LoanApp.Status := LoanApp.Status::Underwriting;
    //     end;

    //     LoanApp.Modify();
    // end;

    // procedure CreateAssessment(var LoanApp: Record "GE Loan Arrangement Header")
    // var
    //     UW: Record "Underwriting Assessment";
    // begin
    //     UW.Init();
    //     UW."Assessment No." := GenerateAssessmentNo();
    //     UW."Application No." := LoanApp."No.";
    //     UW."Assessment Date" := Today;
    //     UW."Assessment Time" := TimeNow;
    //     UW."Underwriter User ID" := GetCurrentUserID();
    //     // Set other fields as needed

    //     UW.Insert();
    // end;
}
