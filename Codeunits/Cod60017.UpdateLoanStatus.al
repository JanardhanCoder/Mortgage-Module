namespace MortgageForUS.MortgageForUS;
codeunit 60017 UpdateLoanStatus
{
    procedure AutoUpdateLoanStatus(
     var Loan: Record "US Loan Application Header";
     DocsCompleted: Boolean;
     DocsVerified: Boolean;
     CreditScore: Integer;
     FOIR: Decimal;
     ValuationDone: Boolean;
     ValuationAmount: Decimal;
     LegalClear: Boolean;
     ConditionsPending: Boolean;
     CommitmentAccepted: Boolean;
     AgreementCreated: Boolean)
    begin
        case Loan.Status of

            // ---------------- SUBMITTED ----------------
            Loan.Status::Submitted:
                if not DocsCompleted then
                    Loan.Status := Loan.Status::"Docs Pending"
                else
                    Loan.Status := Loan.Status::"Docs Verified";

            // ---------------- DOCS PENDING ----------------
            Loan.Status::"Docs Pending":
                if DocsCompleted then
                    Loan.Status := Loan.Status::"Docs Verified";

            // ---------------- DOCS VERIFIED ----------------
            // Loan.Status::"Docs Verified":
            //     Loan.Status := Loan.Status::"Credit Check";

            // ---------------- CREDIT CHECK ----------------
            // Loan.Status::"Credit Check":
            //     case true of
            //         CreditScore < 650:
            //             Loan.Status := Loan.Status::Rejected;
            //         else
            //             Loan.Status := Loan.Status::"Valuation Pending";
            //     end;

            // ---------------- VALUATION ----------------
            // Loan.Status::"Valuation Pending":
            //     if ValuationDone then
            //         Loan.Status := Loan.Status::Underwriting;

            // ---------------- UNDERWRITING ----------------
            Loan.Status::Underwriting:
                case true of

                    (FOIR > 50):
                        Loan.Status := Loan.Status::Rejected;

                    else
                        Loan.Status := Loan.Status::Approved;
                end;

            // ---------------- CONDITIONAL APPROVAL ----------------
            // Loan.Status::"Conditional Approval":
            //     if not ConditionsPending then
            //         Loan.Status := Loan.Status::Approved;

            // ---------------- APPROVED ----------------
            // Loan.Status::Approved:
            //     Loan.Status := Loan.Status::"Commitment Issued";

            // // ---------------- COMMITMENT ----------------
            // Loan.Status::"Commitment Issued":
            //     if CommitmentAccepted then
            //         Loan.Status := Loan.Status::"Commitment Accepted";

            // Loan.Status::"Commitment Accepted":
            //     Loan.Status := Loan.Status::"Ready for Agreement";

            // // ---------------- AGREEMENT ----------------
            // Loan.Status::"Ready for Agreement":
            //     if AgreementCreated then
            //         Loan.Status := Loan.Status::"Agreement Created";

            Loan.Status::"Agreement Created":
                Loan.Status := Loan.Status::Released;

            // ---------------- FINAL STATES ----------------
            Loan.Status::Rejected,
            Loan.Status::Cancelled,
            Loan.Status::Released:
                exit;

        end;

        Loan.Modify();
    end;
}
