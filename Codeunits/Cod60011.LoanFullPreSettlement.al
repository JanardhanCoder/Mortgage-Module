codeunit 60011 "Loan Full Pre-Settlement"
{
    procedure CreateJnlLines(
        var Loan: Record "US Mortgage Agreement Header";
        SettlementDate: Date;
        WaiverAmount: Decimal;
        Template: Code[10];
        Batch: Code[10])
    var
        GenJnlLine: Record "Gen. Journal Line";
        PageJnl: Page "General Journal";
        Setup: Record "US Mortgage Posting Setup";
        Posting: Record "US Mortgage Posting Group";
        LineNo: Integer;
        Principal: Decimal;
        Interest: Decimal;
        Penalty: Decimal;
        NetAmount: Decimal;
        Days: Integer;
        FromDate:Date;
    begin
        // Validation
        if Loan.Status = Loan.Status::Closed then
            Error('Loan already closed.');
        Posting.Get('MG');

        // Amounts
        Principal := Loan."Outstanding Principal";
        // Days := SettlementDate - Loan."Last Accrual Date";

        if Loan."Last Accrual Date" <> 0D then
            FromDate := Loan."Last Accrual Date"
        else
            FromDate := Loan."Effective Date";

        Days := SettlementDate - FromDate;
        if Days < 0 then
            Days := 0;

        Interest :=
            Round(Principal * Loan."Interest Rate %" / 100 / 365 * Days, 0.01);

        Penalty :=
            Round(Principal * Loan."Pre-Settlement Penalty %" / 100, 0.01);

        if WaiverAmount > Penalty then
            Error('Waiver cannot exceed penalty.');

        NetAmount := Principal + Interest + Penalty - WaiverAmount;

        // Get next line no
        GenJnlLine.SetRange("Journal Template Name", Template);
        GenJnlLine.SetRange("Journal Batch Name", Batch);
        if GenJnlLine.FindLast() then
            LineNo := GenJnlLine."Line No." + 10000
        else
            LineNo := 10000;

        // Customer (Debit)
        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := Template;
        GenJnlLine."Journal Batch Name" := Batch;
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."Posting Date" := SettlementDate;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine."Account No." := Loan."Borrower Customer No.";

        GenJnlLine.Amount := NetAmount;
        GenJnlLine."US Mortgage No." := Loan."Loan No.";
        GenJnlLine.Insert();

        // Principal (Credit)
        LineNo += 10000;
        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := Template;
        GenJnlLine."Journal Batch Name" := Batch;
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."US Mortgage No." := Loan."Loan No.";
        GenJnlLine."Posting Date" := SettlementDate;
        //  GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine."Account No." := Loan."Borrower Customer No.";
        //   GenJnlLine."Account No." := Posting."Loan Principal Receivable";
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        GenJnlLine."Bal. Account No." := Posting."Loan Principal Receivable";
        GenJnlLine.Amount := -Principal;
        GenJnlLine.Insert();

        // Interest (Credit)
        LineNo += 10000;
        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := Template;
        GenJnlLine."Journal Batch Name" := Batch;
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."US Mortgage No." := Loan."Loan No.";
        GenJnlLine."Posting Date" := SettlementDate;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine."Account No." := Loan."Borrower Customer No.";
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        GenJnlLine."Bal. Account No." := Posting."Interest Income";
        GenJnlLine.Amount := -Interest;
        GenJnlLine.Insert();

        // Penalty (Credit)
        LineNo += 10000;
        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := Template;
        GenJnlLine."Journal Batch Name" := Batch;
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."US Mortgage No." := Loan."Loan No.";
        GenJnlLine."Posting Date" := SettlementDate;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine."Account No." := Loan."Borrower Customer No.";
        GenJnlLine."Bal. Account No." := posting."Penalty Income";
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        //GenJnlLine."Account No." := Posting."Penalty Income";
        GenJnlLine.Amount := -Penalty;
        GenJnlLine.Insert();

        // Waiver (Debit)
        if WaiverAmount > 0 then begin
            LineNo += 10000;
            GenJnlLine.Init();
            GenJnlLine."Journal Template Name" := Template;
            GenJnlLine."Journal Batch Name" := Batch;
            GenJnlLine."Line No." := LineNo;
            GenJnlLine."US Mortgage No." := Loan."Loan No.";
            GenJnlLine."Posting Date" := SettlementDate;
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
            GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
            GenJnlLine."Account No." := Loan."Borrower Customer No.";
            GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
            GenJnlLine."Bal. Account No." := Posting."Penalty Waiver GL";
            GenJnlLine.Amount := WaiverAmount;
            GenJnlLine.Insert();
        end;

        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
        GenJnlLine.SetRange("Journal Batch Name", 'DEFAULT');
        PageJnl.SetTableView(GenJnlLine);
        //  PageJnl.Run();
        Page.Run(Page::"General Journal", GenJnlLine);
        // Mark loan (posting will close it later)
        Loan.Status := Loan.Status::"Pre-Settlement Pending";
        Loan.Modify();
    end;
}
