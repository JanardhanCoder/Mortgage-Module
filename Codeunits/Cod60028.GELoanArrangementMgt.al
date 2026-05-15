namespace MortgageForUS.MortgageForUS;
using Mortgage.Mortgage;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 60028 "GE Loan Arrangement Mgt"
{

    procedure Execute(var ArrHdr: Record "GE Loan Arrangement Header")
    begin
        ArrHdr.TestField(Status, Enum::"GE Loan Arrangement Status"::Approved);

        case ArrHdr."Arrangement Type" of
            Enum::"GE Loan Arrangement Type"::PTP:
                ExecutePTP(ArrHdr);

            Enum::"GE Loan Arrangement Type"::Waiver:
                ExecuteWaiver(ArrHdr);

            Enum::"GE Loan Arrangement Type"::Restructure:
                ExecuteRestructure(ArrHdr);
        end;

        ArrHdr.Status := Enum::"GE Loan Arrangement Status"::InProcess;
        ArrHdr.Modify(true);
    end;

    local procedure ExecutePTP(var ArrHdr: Record "GE Loan Arrangement Header")
    begin
        ArrHdr.TestField("PTP Date");
        ArrHdr.TestField("PTP Amount");

        // Log PTP commitment (collection follow-up logic)
        // No GL posting here

        Message(
            'PTP recorded. Follow-up on %1.',
            ArrHdr."PTP Follow-up Date");
    end;


    local procedure ExecuteWaiver(var ArrHdr: Record "GE Loan Arrangement Header")
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        if ArrHdr."Waiver Posted" then
            Error('Waiver already executed.');

        if ArrHdr."Waive Penalty Amount" + ArrHdr."Waive Fee Amount" = 0 then
            Error('Nothing to waive.');

        // Create GL Journal (Penalty / Fee Write-off)
        // Debit: Penalty / Fee Expense
        // Credit: Loan Receivable / Accrued Penalty

        ArrHdr."Waiver Posted" := true;
        ArrHdr."Waiver Doc No." := 'WV-' + ArrHdr."No.";
    end;

    local procedure ExecuteRestructure(var ArrHdr: Record "GE Loan Arrangement Header")
    var
        LoanHdr: Record "US Mortgage Agreement Header";
    begin
        if ArrHdr."Restructure Applied" then
            Error('Restructure already applied.');

        LoanHdr.Get(ArrHdr."Loan No.");

        ArrHdr."Old Maturity Date" := LoanHdr."Maturity Date";

        case ArrHdr."Restructure Type" of

            Enum::"GE Restructure Type"::EMITenureChange:
                RecalcScheduleKeepEMI(LoanHdr, ArrHdr);

            Enum::"GE Restructure Type"::EMIReduction:
                RecalcScheduleKeepTenure(LoanHdr, ArrHdr);

            Enum::"GE Restructure Type"::TenureExtension:
                ExtendTenureOnly(LoanHdr, ArrHdr);

            Enum::"GE Restructure Type"::InterestRateChange:
                ApplyNewRate(LoanHdr, ArrHdr);

            Enum::"GE Restructure Type"::PrincipalMoratorium,
            Enum::"GE Restructure Type"::InterestMoratorium,
            Enum::"GE Restructure Type"::FullMoratorium:
                ApplyMoratorium(LoanHdr, ArrHdr);

        end;

        ArrHdr."New Maturity Date" := LoanHdr."Maturity Date";
        ArrHdr."Restructure Applied" := true;
        ArrHdr.Modify(true);
    end;


    local procedure RecalcScheduleKeepEMI(
        var LoanHdr: Record "US Mortgage Agreement Header";
        ArrHdr: Record "GE Loan Arrangement Header")
    begin
        // EMI remains same, tenure recalculated
        LoanHdr.TestField("EMI Amount");

        // Call your existing schedule engine
        // Remaining principal is recalculated internally
        RegenerateSchedule(
            LoanHdr,
            LoanHdr."EMI Amount",
            0, // tenure auto-calculated
            LoanHdr."Interest Rate %");

        LoanHdr.Modify(true);
    end;

    local procedure RecalcScheduleKeepTenure(
    var LoanHdr: Record "US Mortgage Agreement Header";
    ArrHdr: Record "GE Loan Arrangement Header")
    begin
        LoanHdr.TestField("Tenor (Months)");

        // EMI recalculated based on same tenure
        RegenerateSchedule(
            LoanHdr,
            0, // EMI auto-calculated
            LoanHdr."Tenor (Months)",
            LoanHdr."Interest Rate %");

        LoanHdr.Modify(true);
    end;

    local procedure ExtendTenureOnly(
        var LoanHdr: Record "US Mortgage Agreement Header";
        ArrHdr: Record "GE Loan Arrangement Header")
    begin
        ArrHdr.TestField("New Tenor (Months)");

        LoanHdr."Tenor (Months)" := ArrHdr."New Tenor (Months)";

        RegenerateSchedule(
            LoanHdr,
            0,
            LoanHdr."Tenor (Months)",
            LoanHdr."Interest Rate %");

        LoanHdr.Modify(true);
    end;

    local procedure ApplyNewRate(
        var LoanHdr: Record "US Mortgage Agreement Header";
        ArrHdr: Record "GE Loan Arrangement Header")
    begin
        ArrHdr.TestField("New Interest Rate Code");

        LoanHdr."Rate Code" := ArrHdr."New Interest Rate Code";

        RegenerateSchedule(
            LoanHdr,
            LoanHdr."EMI Amount",
            LoanHdr."Tenor (Months)",
            LoanHdr."Interest Rate %");

        LoanHdr.Modify(true);
    end;

    local procedure ApplyMoratorium(
        var LoanHdr: Record "US Mortgage Agreement Header";
        ArrHdr: Record "GE Loan Arrangement Header")
    begin
        ArrHdr.TestField("Effective Date");
        ArrHdr.TestField("New Tenor (Months)");

        // Extend tenure due to moratorium
        LoanHdr."Tenor (Months)" :=
            LoanHdr."Tenor (Months)" + ArrHdr."New Tenor (Months)";

        // Mark moratorium in schedule regeneration
        RegenerateMoratoriumSchedule(
            LoanHdr,
            ArrHdr."Restructure Type",
            ArrHdr."Effective Date",
            ArrHdr."New Tenor (Months)");

        LoanHdr.Modify(true);
    end;

    local procedure CapitaliseOverdues(
        var LoanHdr: Record "US Mortgage Agreement Header";
        ArrHdr: Record "GE Loan Arrangement Header")
    begin
        ArrHdr.TestField("Capitalise Amount");

        LoanHdr."Outstanding Principal" :=
            LoanHdr."Outstanding Principal" + ArrHdr."Capitalise Amount";

        RegenerateSchedule(
            LoanHdr,
            LoanHdr."EMI Amount",
            LoanHdr."Tenor (Months)",
            LoanHdr."Interest Rate %");

        LoanHdr.Modify(true);
    end;

    local procedure RegenerateSchedule(
        var LoanHdr: Record "US Mortgage Agreement Header";
        EMIAmount: Decimal;
        TenureMonths: Integer;
        InterestRate: Decimal)
    var
        SchLine: Record "US Mortgage Schedule Line";
    begin
        // ---------------- Cancel future schedule lines ----------------
        SchLine.Reset();
        SchLine.SetRange("Loan No.", LoanHdr."Loan No.");
        SchLine.SetRange(Status, SchLine.Status::Pending);
        SchLine.SetFilter("Due Date", '>%1', Today);

        if SchLine.FindSet() then
            repeat
                SchLine.Status := SchLine.Status::Cancelled;
                SchLine."Cancelled Date" := Today;
                SchLine."Cancelled By" := UserId;
                SchLine.Modify(true);
            until SchLine.Next() = 0;

        // ---------------- Regenerate fresh schedule ----------------
        BuildAmortisation(LoanHdr, EMIAmount, TenureMonths, InterestRate);
    end;

    local procedure RegenerateMoratoriumSchedule(
       var LoanHdr: Record "US Mortgage Agreement Header";
        RestructureType: Enum "GE Restructure Type";
        FromDate: Date;
        Months: Integer)
    var
        SchLine: Record "US Mortgage Schedule Line";
    begin
        // Create zero-EMI or interest-only schedule
        // depending on moratorium type
        // ---------------- Cancel future schedule lines ----------------
        SchLine.Reset();
        SchLine.SetRange("Loan No.", LoanHdr."Loan No.");
        SchLine.SetRange(Status, SchLine.Status::Pending);
        SchLine.SetFilter("Due Date", '>%1', Today);

        if SchLine.FindSet() then
            repeat
                SchLine.Status := SchLine.Status::Cancelled;
                SchLine."Cancelled Date" := Today;
                SchLine."Cancelled By" := UserId;
                SchLine.Modify(true);
            until SchLine.Next() = 0;

        BuildMoratoriumSchedule(
            LoanHdr,
            RestructureType,
            FromDate,
            Months);
    end;

    local procedure BuildAmortisation(
        var LoanHdr: Record "US Mortgage Agreement Header";
        EMIAmount: Decimal;
        TenureMonths: Integer;
        InterestRate: Decimal)
    var
        SchLine: Record "US Mortgage Schedule Line";
        LineNo: Integer;
        MonthCnt: Integer;
        OutstandingPrincipal: Decimal;
        MonthlyRate: Decimal;
        InterestAmt: Decimal;
        PrincipalAmt: Decimal;
        DueDate: Date;
    begin
        OutstandingPrincipal := LoanHdr."Outstanding Principal";
        MonthlyRate := InterestRate / 1200;
        DueDate := LoanHdr."Effective Date";
        LineNo := 10000;

        for MonthCnt := 1 to TenureMonths do begin
            InterestAmt := Round(OutstandingPrincipal * MonthlyRate, 0.01);
            PrincipalAmt := EMIAmount - InterestAmt;

            if PrincipalAmt > OutstandingPrincipal then begin
                PrincipalAmt := OutstandingPrincipal;
                EMIAmount := PrincipalAmt + InterestAmt;
            end;

            SchLine.Init();
            SchLine."Loan No." := LoanHdr."Loan No.";
            SchLine."Line No." := LineNo;
            SchLine."Due Date" := DueDate;
            SchLine."EMI Amount" := EMIAmount;
            SchLine."Principal Amount" := PrincipalAmt;
            SchLine."Interest Amount" := InterestAmt;
            SchLine."Schedule Type" := SchLine."Schedule Type"::Normal;
            SchLine.Status := SchLine.Status::Pending;
            SchLine.Insert();

            OutstandingPrincipal -= PrincipalAmt;
            DueDate := CalcDate('<1M>', DueDate);
            LineNo += 10000;

            if OutstandingPrincipal <= 0 then
                exit;
        end;

        LoanHdr."Maturity Date" := CalcDate(StrSubstNo('<%1M>', TenureMonths), LoanHdr."Effective Date");
        LoanHdr.Modify(true);
    end;

    local procedure BuildMoratoriumSchedule(
        var LoanHdr: Record "US Mortgage Agreement Header";
        RestructureType: Enum "GE Restructure Type";
        FromDate: Date;
        Months: Integer)
    var
        SchLine: Record "US Mortgage Schedule Line";
        LineNo: Integer;
        MonthCnt: Integer;
        MonthlyRate: Decimal;
        InterestAmt: Decimal;
        DueDate: Date;
    begin
        MonthlyRate := LoanHdr."Interest Rate %" / 1200;
        DueDate := FromDate;
        LineNo := 10000;

        for MonthCnt := 1 to Months do begin
            InterestAmt := Round(LoanHdr."Outstanding Principal" * MonthlyRate, 0.01);

            SchLine.Init();
            SchLine."Loan No." := LoanHdr."Loan No.";
            SchLine."Line No." := LineNo;
            SchLine."Due Date" := DueDate;
            SchLine.Status := SchLine.Status::Pending;

            case RestructureType of
                RestructureType::PrincipalMoratorium:
                    begin
                        SchLine."Principal Amount" := 0;
                        SchLine."Interest Amount" := InterestAmt;
                        SchLine."Schedule Type" := SchLine."Schedule Type"::PrincipalMoratorium;
                    end;

                RestructureType::InterestMoratorium:
                    begin
                        SchLine."Principal Amount" := LoanHdr."Outstanding Principal" / Months;
                        SchLine."Interest Amount" := 0;
                        SchLine."Schedule Type" := SchLine."Schedule Type"::InterestMoratorium;
                    end;

                RestructureType::FullMoratorium:
                    begin
                        SchLine."Principal Amount" := 0;
                        SchLine."Interest Amount" := 0;
                        SchLine."Schedule Type" := SchLine."Schedule Type"::FullMoratorium;
                    end;
            end;

            SchLine."EMI Amount" :=
                SchLine."Principal Amount" + SchLine."Interest Amount";

            SchLine.Insert();

            DueDate := CalcDate('<1M>', DueDate);
            LineNo += 10000;
        end;

        LoanHdr."Maturity Date" := CalcDate(StrSubstNo('<%1M>', Months), LoanHdr."Maturity Date");
        LoanHdr.Modify(true);
    end;

}

codeunit 60029 "GE Collections Mgt"
{
    procedure SubmitArrangement(No: Code[20])
    var
        A: Record "GE Loan Arrangement Header";
    begin
        A.Get(No);
        if A.Status <> A.Status::Open then
            Error('Only Draft arrangements can be submitted.');
        A.Status := A.Status::Submitted;
        A.Modify(true);
    end;

    procedure ApproveArrangement(No: Code[20])
    var
        A: Record "GE Loan Arrangement Header";
    begin
        A.Get(No);
        if A.Status <> A.Status::Submitted then
            Error('Only Submitted arrangements can be approved.');
        A.Status := A.Status::Approved;
        A.Modify(true);
    end;

    procedure ActivatePTP(No: Code[20])
    var
        A: Record "GE Loan Arrangement Header";
        Loan: Record "US Mortgage Agreement Header";
    begin
        A.Get(No);
        if A."Arrangement Type" <> A."Arrangement Type"::PTP then
            Error('Not a PTP arrangement.');
        if A.Status <> A.Status::Approved then
            Error('PTP must be Approved.');

        Loan.Get(A."Loan No.");
        if Loan.Status <> Loan.Status::Active then
            Error('Loan must be Active.');

        if A."PTP Date" = 0D then
            Error('PTP Date is required.');
        if A."PTP Amount" <= 0 then
            Error('PTP Amount must be > 0.');

        A.Status := A.Status::InProcess;
        if A."PTP Follow-up Date" = 0D then
            A."PTP Follow-up Date" := A."PTP Date";
        A.Modify(true);
    end;

    procedure CompletePTP(No: Code[20]; Outcome: Option " ",Kept,Broken,Partial)
    var
        A: Record "GE Loan Arrangement Header";
    begin
        A.Get(No);
        if A."Arrangement Type" <> A."Arrangement Type"::PTP then
            Error('Not a PTP arrangement.');
        if A.Status <> A.Status::InProcess then
            Error('PTP must be Active to complete.');
        A."PTP Outcome" := Outcome;
        A.Status := A.Status::Completed;
        A.Modify(true);
    end;

    procedure ApplyWaiver(No: Code[20]; PostingDate: Date)
    var
        A: Record "GE Loan Arrangement Header";
        Loan: Record "US Mortgage Agreement Header";
        Post: Codeunit "US Loan GL Posting";
        AmtPenaltyToWaive: Decimal;
    begin
        A.Get(No);
        if A."Arrangement Type" <> A."Arrangement Type"::Waiver then
            Error('Not a waiver arrangement.');
        if A.Status <> A.Status::Approved then
            Error('Waiver must be Approved.');
        if A."Waiver Posted" then
            Error('Waiver already posted.');

        Loan.Get(A."Loan No.");
        if Loan.Status <> Loan.Status::Active then
            Error('Loan must be Active.');

        AmtPenaltyToWaive := A."Waive Penalty Amount";
        if AmtPenaltyToWaive <= 0 then
            Error('Waive Penalty Amount must be > 0.');

        // Post GL: Dr Penalty Waiver Account / Cr Penalty Receivable
        //Post.PostPenaltyWaiver(Loan."Loan No.", PostingDate, AmtPenaltyToWaive, StrSubstNo('Penalty waiver - %1', A."No."));

        // Apply waiver to schedule penalty buckets (oldest overdue first)
        ApplyPenaltyWaiverToSchedule(Loan."Loan No.", AmtPenaltyToWaive, A."No.");

        A."Waiver Posted" := true;
        A.Status := A.Status::Completed;
        A.Modify(true);
    end;

    procedure ApplyRestructure(No: Code[20])
    var
        A: Record "GE Loan Arrangement Header";
        Loan: Record "US Mortgage Agreement Header";
        SchMgt: Codeunit "US Mortgage Reschedule Mgt";
        schmgt2: Codeunit "Mortgage Schedule Generator";
    begin
        A.Get(No);
        if A."Arrangement Type" <> A."Arrangement Type"::Restructure then
            Error('Not a restructure arrangement.');
        if A.Status <> A.Status::Approved then
            Error('Restructure must be Approved.');
        if A."Restructure Applied" then
            Error('Restructure already applied.');

        Loan.Get(A."Loan No.");
        if Loan.Status <> Loan.Status::Active then
            Error('Loan must be Active.');

        A."Old Maturity Date" := Loan."Maturity Date";

        case A."Restructure Type" of
            A."Restructure Type"::InterestRateChange:
                begin
                    if A."New Interest Rate Code" <> '' then begin
                        Loan."Rate Code" := A."New Interest Rate Code";
                    end
                    else
                        Error('New Interest Rate must be value.');
                end;

            A."Restructure Type"::TenureExtension:
                begin
                    if A."New Tenor (Months)" <= Loan."Tenor (Months)" then
                        Error('New tenor must be greater than current tenor.');
                    Loan."Tenor (Months)" := A."New Tenor (Months)";
                    Loan."Maturity Date" := CalcDate(StrSubstNo('%1M', Loan."Tenor (Months)"), Loan."Effective Date");
                end;

        // A."Restructure Type"::"Capitalise Arrears":
        //     begin
        //         // Capitalise unpaid principal/interest/penalty (simplified: add to principal)
        //         if A."Capitalise Amount" <= 0 then
        //             Error('Capitalise Amount must be > 0.');
        //         Loan."Principal Amount" += A."Capitalise Amount";
        //     end;

        // A."Restructure Type"::"New Schedule":
        //     begin
        //         // Allows combination via fields; apply if present
        //         if A."New Interest Rate %" > 0 then
        //             Loan."Interest Rate %" := A."New Interest Rate %";
        //         if A."New Tenor (Months)" > 0 then begin
        //             Loan."Tenor (Months)" := A."New Tenor (Months)";
        //             Loan."Maturity Date" := CalcDate(StrSubstNo('%1M', Loan."Tenor (Months)"), Loan."Effective Date");
        //         end;
        //     end;
        end;

        Loan.Status := Loan.Status::Restructured;

        Loan."Rate Code" := A."New Interest Rate Code";
        Loan."Tenor (Months)" := A."New Tenor (Months)";
        Loan."Maturity Date" := A."New Maturity Date";

        Loan.Modify(true);

        // Recast schedule from today (business choice)
        SchMgt2.GenerateMonthlySchedule(Loan."Loan No.", Today);

        A."New Maturity Date" := Loan."Maturity Date";
        A."Restructure Applied" := true;
        A.Status := A.Status::InProcess;
        A.Modify(true);
    end;

    // ---------------- internals ----------------

    local procedure ApplyPenaltyWaiverToSchedule(LoanNo: Code[20]; AmountToWaive: Decimal; RefNo: Code[20])
    var
        Sch: Record "US Mortgage Schedule Line";
        Remaining: Decimal;
        Take: Decimal;
    begin
        Remaining := AmountToWaive;

        Sch.SetRange("Loan No.", LoanNo);
        Sch.SetFilter(Status, '%1|%2', Sch.Status::Overdue, Sch.Status::Pending);
        Sch.SetCurrentKey("Due Date");
        if not Sch.FindSet(true) then
            exit;

        repeat
            if Remaining <= 0 then
                break;

            Take := Min(Remaining, Sch.RemainingPenalty());
            if Take > 0 then begin
                // reduce penalty assessed
                Sch."Penalty Amount" := Sch."Penalty Amount" - Take;
                Sch."Penalty Calculated Date" := Today;
                Sch.Modify(true);
                Remaining -= Take;
            end;
        until Sch.Next() = 0;

        if Remaining > 0 then
            Message('Waiver exceeds current penalty balance by %1. Residual ignored.', Remaining);
    end;

    local procedure Min(a: Decimal; b: Decimal): Decimal
    begin
        if a < b then exit(a);
        exit(b);
    end;
}
