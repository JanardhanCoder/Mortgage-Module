codeunit 60032 "GE Loan Reclassification"
{
    procedure PostReclassification(LoanNo: Code[20]; Amount: Decimal; PostingDate: Date)
    var
        Setup: Record "US Mortgage Posting Setup";
        postinggroup: Record "US Mortgage Posting Group";
        Loan: Record "US Mortgage Agreement Header";
        Jnl: Record "Gen. Journal Line";
        LineNo: Integer;
    begin
        Setup.Get('SETUP');
        Setup.TestField("Gen. Jnl. Template");
        Setup.TestField("Gen. Jnl. Batch");


        Jnl.SetRange("Journal Template Name", Setup."Gen. Jnl. Template");
        Jnl.SetRange("Journal Batch Name", Setup."Gen. Jnl. Batch");
        if Jnl.FindLast() then
            LineNo := Jnl."Line No."
        else
            LineNo := 0;

        // DR LHFS
        CreateGenJournalLine(LineNo + 10000,
            Setup."LHFS Account",
            Amount,
            PostingDate,
            LoanNo,
            true);

        Loan.SetRange("Loan No.", LoanNo);
        if Loan.FindFirst() then begin
            postinggroup.SetRange(Code, Loan."Posting Group Code");
            if postinggroup.FindFirst() then begin
                // CR Loan Asset
                CreateGenJournalLine(LineNo + 20000,
                    postinggroup."Loan Principal Receivable",
                    Amount,
                    PostingDate,
                    LoanNo,
                    false);
            end;
        end;

        Page.Run(Page::"General Journal", Jnl);

        //CreateLoanLedgerEntry(LoanNo, PostingDate, Amount, 0, 0, Amount, 'Reclassification');
    end;

    procedure PostLoanSale(LoanNo: Code[20]; CarryingValue: Decimal; SaleAmount: Decimal; PostingDate: Date)
    var
        Setup: Record "US Mortgage Posting Setup";
        postinggroup: Record "US Mortgage Posting Group";
        Loan: Record "US Mortgage Agreement Header";
        Jnl: Record "Gen. Journal Line";
        LineNo: Integer;
        GainLoss: Decimal;
    begin
        Setup.Get('SETUP');
        Setup.TestField("Gen. Jnl. Template");
        Setup.TestField("Gen. Jnl. Batch");


        Jnl.SetRange("Journal Template Name", Setup."Gen. Jnl. Template");
        Jnl.SetRange("Journal Batch Name", Setup."Gen. Jnl. Batch");
        if Jnl.FindLast() then
            LineNo := Jnl."Line No."
        else
            LineNo := 0;

        GainLoss := SaleAmount - CarryingValue;

        // DR Bank
        CreateGenJournalLine(
            LineNo + 10000,
            Setup."Default Bank Account No.",
            SaleAmount,
            PostingDate,
            LoanNo,
            true);

        // CR LHFS
        CreateGenJournalLine(
            LineNo + 20000,
            Setup."LHFS Account",
            CarryingValue,
            PostingDate,
            LoanNo,
            false);

        // Gain / Loss
        if GainLoss > 0 then
            CreateGenJournalLine(
                LineNo + 30000,
                Setup."Gain/Loss Account",
                GainLoss,
                PostingDate,
                LoanNo,
                false)
        else
            CreateGenJournalLine(
                LineNo + 40000,
                Setup."Gain/Loss Account",
                Abs(GainLoss),
                PostingDate,
                LoanNo,
                true);
        Page.Run(Page::"General Journal", Jnl);
        //CreateLoanLedgerEntry(LoanNo, PostingDate, SaleAmount, 0, 0, 0, 'LoanSale');
    end;

    local procedure CreateGenJournalLine(LineNo: Integer; AccountNo: Code[20]; Amount: Decimal; PostingDate: Date; LoanNo: Code[20]; IsDebit: Boolean)
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := PostingDate;
        GenJnlLine."Account No." := AccountNo;
        GenJnlLine.Description := 'Loan ' + LoanNo;
        GenJnlLine."Line No." := LineNo;

        if IsDebit then
            GenJnlLine.Amount := Amount
        else
            GenJnlLine.Amount := -Amount;

        GenJnlLine.Insert();
    end;

    local procedure CreateLoanLedgerEntry(LoanNo: Code[20]; PostingDate: Date; Amount: Decimal; Principal: Decimal; Interest: Decimal; Balance: Decimal; EntryType: Text)
    var
        LoanEntry: Record "US Loan Ledger Entry";
    begin
        LoanEntry.Init();
        LoanEntry."Loan No." := LoanNo;
        LoanEntry."Posting Date" := PostingDate;
        LoanEntry.Amount := Amount;
        LoanEntry."Amount Principal" := Principal;
        LoanEntry."Amount Interest" := Interest;
        LoanEntry."Amount Escrow" := Balance;

        case EntryType of
            'Disbursement':
                LoanEntry."Entry Type" := LoanEntry."Entry Type"::Disbursement;
            'Receipt':
                LoanEntry."Entry Type" := LoanEntry."Entry Type"::Receipt;
            'Reclassification':
                LoanEntry."Entry Type" := LoanEntry."Entry Type"::Reclassification;
            'LoanSale':
                LoanEntry."Entry Type" := LoanEntry."Entry Type"::LoanSale;
        end;

        LoanEntry.Insert();
    end;
}
