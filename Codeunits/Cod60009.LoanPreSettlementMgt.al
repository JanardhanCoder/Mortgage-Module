namespace MortgageForUS.MortgageForUS;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 60009 "Loan Pre-Settlement Mgt"
{
    procedure CalcPreSettlementAmount(var LoanHeader: Record "US Mortgage Agreement Header"; PreSettlementDate: Date; PenaltyPercent: Decimal): Decimal
    var
        LoanSchedule: Record "US Mortgage Schedule Line";
        DailyInterestRate: Decimal;
        AccruedInterest: Decimal;
        PenaltyAmount: Decimal;
        TotalAmount: Decimal;
        LastInterestDate: Date;
        SettlementDate: Date; // or selected date
        AccrualDays: Integer;

    begin
        LoanSchedule.SetRange(Status, LoanSchedule.Status::Paid);
        LoanSchedule.FindLast();
        LastInterestDate := LoanSchedule."Paid Date";
        SettlementDate := WorkDate();
        AccrualDays := SettlementDate - LastInterestDate;




        LoanHeader.TestField("Loan End Date");
        if PreSettlementDate > LoanHeader."Loan End Date" then
            Error('Pre-settlement date cannot be after loan end date.');

        LoanHeader.CalcFields("Outstanding Principal", "Outstanding Interest");

        DailyInterestRate := LoanHeader."Interest Rate %" / 100 / 365;
        AccruedInterest := LoanHeader."Outstanding Interest";
        // / If you want to accrue extra days, calculate only on remaining principal
        // AccruedInterest += LoanHeader."Outstanding Principal" * DailyInterestRate * AccrualDays;

        // LoanSchedule.Reset();
        // LoanSchedule.SetRange("Loan No.", LoanHeader."Loan No.");
        // LoanSchedule.SetRange("Due Date", LoanHeader."Last Accrual Date" + 1, PreSettlementDate);
        // if LoanSchedule.FindSet() then
        //     repeat
        //         AccruedInterest += LoanSchedule." * DailyInterestRate * AccrualDays;
        //     until LoanSchedule.Next() = 0;


        PenaltyAmount := Round(LoanHeader."Outstanding Principal" * PenaltyPercent / 100, 0.01, '=');
        TotalAmount := LoanHeader."Outstanding Principal" + AccruedInterest + PenaltyAmount;


        exit(TotalAmount);
    end;

    procedure CloseFutureSchedules(var LoanHeader: Record "US Mortgage Agreement Header"; PreSettlementDate: Date)
    var
        LoanSchedule: Record "US Mortgage Schedule Line";
    begin
        LoanSchedule.Reset();
        LoanSchedule.SetRange("Loan No.", LoanHeader."Loan No.");
        LoanSchedule.SetFilter("Due Date", '>=%1', PreSettlementDate + 1);
        if LoanSchedule.FindSet(true) then
            repeat
                LoanSchedule.Status := LoanSchedule.Status::Settled;
                LoanSchedule."Paid Date" := PreSettlementDate;
                LoanSchedule.Modify(true);
            until LoanSchedule.Next() = 0;
    end;

    procedure CreatePreSettlementJnlLines(var LoanHeader: Record "US Mortgage Agreement Header"; PreSettlementDate: Date; PenaltyPercent: Decimal; JournalTemplateName: Code[20]; JournalBatchName: Code[30])
    var
        GenJnlLine: Record "Gen. Journal Line";
        Posting: Record "US Mortgage Posting Group";
        LineNo: Integer;
        TotalAmount: Decimal;
        AccruedInterest: Decimal;
        PenaltyAmount: Decimal;
    begin
        LoanHeader.CalcFields("Outstanding Principal", "Outstanding Interest");

        TotalAmount := CalcPreSettlementAmount(LoanHeader, PreSettlementDate, PenaltyPercent);
        PenaltyAmount := Round(LoanHeader."Outstanding Principal" * PenaltyPercent / 100, 0.01, '=');
        AccruedInterest := TotalAmount - LoanHeader."Outstanding Principal" - PenaltyAmount;

        GenJnlLine.SetRange("Journal Template Name", JournalTemplateName);
        GenJnlLine.SetRange("Journal Batch Name", JournalBatchName);
        if GenJnlLine.FindLast() then
            LineNo := GenJnlLine."Line No." + 10000
        else
            LineNo := 10000;

        InitJnlLine(GenJnlLine, JournalTemplateName, JournalBatchName, LineNo, PreSettlementDate);
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine."Account No." := LoanHeader."Borrower Customer No.";
        GenJnlLine.Amount := TotalAmount;
        GenJnlLine.Description := StrSubstNo('Loan pre-settlement %1', LoanHeader."Loan No.");
        GenJnlLine.Insert(true);

        LineNo += 10000;
        InitJnlLine(GenJnlLine, JournalTemplateName, JournalBatchName, LineNo, PreSettlementDate);
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := Posting."Loan Principal Receivable";
        GenJnlLine.Amount := -LoanHeader."Outstanding Principal";
        GenJnlLine.Description := StrSubstNo('Principal outstanding %1', LoanHeader."Loan No.");
        GenJnlLine.Insert(true);

        LineNo += 10000;
        InitJnlLine(GenJnlLine, JournalTemplateName, JournalBatchName, LineNo, PreSettlementDate);
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := Posting."Interest Income";
        GenJnlLine.Amount := -AccruedInterest;
        GenJnlLine.Description := StrSubstNo('Interest income %1', LoanHeader."Loan No.");
        GenJnlLine.Insert(true);

        LineNo += 10000;
        InitJnlLine(GenJnlLine, JournalTemplateName, JournalBatchName, LineNo, PreSettlementDate);
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";

        //  GenJnlLine."Account No." := LoanHeader."Pre-Settlement Penalty Account";
        GenJnlLine."Account No." := Posting."Penalty Income";
        GenJnlLine.Amount := -PenaltyAmount;
        GenJnlLine.Description := StrSubstNo('Pre-settlement penalty %1', LoanHeader."Loan No.");
        GenJnlLine.Insert(true);

        LoanHeader.Status := LoanHeader.Status::"Pre-Settled";
        LoanHeader."Pre-Settlement Date" := PreSettlementDate;
        LoanHeader."Pre-Settlement Posted" := true;
        LoanHeader.Modify(true);

        CloseFutureSchedules(LoanHeader, PreSettlementDate);
    end;

    local procedure InitJnlLine(var GenJnlLine: Record "Gen. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; LineNo: Integer; PostingDate: Date)
    begin
        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := JournalTemplateName;
        GenJnlLine."Journal Batch Name" := JournalBatchName;
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."Posting Date" := PostingDate;
        GenJnlLine."Document Date" := PostingDate;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
    end;
}

