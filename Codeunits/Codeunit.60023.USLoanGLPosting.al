namespace Mortgage.Mortgage;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.NoSeries;
using Microsoft.Finance.GeneralLedger.Posting;
using MortgageForUS.MortgageForUS;
codeunit 60023 "US Loan GL Posting"
{
    procedure PostDisbursement(LoanNo: Code[20]; PostingDate: Date; BankAccountNo: Code[20]; Amount: Decimal; ExtRef: Text[50])
    var
        Loan: Record "US Mortgage Agreement Header";
        Setup: Record "US Mortgage Posting Setup";
        PG: Record "US Mortgage Posting Group";
        DocNo: Code[20];
        Jnl: Record "Gen. Journal Line";
        Noseries: Codeunit "No. Series";
        template: Record "Gen. Journal Template";
    begin
        EnsureSetup(Setup);
        Loan.SetRange("Loan No.", LoanNo);
        if Loan.FindFirst() then begin

            if Loan.Status <> Loan.Status::Active then
                Error('Loan must be Active to post disbursement.');

            if BankAccountNo = '' then
                BankAccountNo := Setup."Default Bank Account No.";
            if BankAccountNo = '' then
                Error('Bank Account No. is required (Loan or Setup).');

            PG.Get(Loan."Posting Group Code");
            //DocNo := StrSubstNo('DISB-%1', LoanNo);
            Jnl.Reset();
            Jnl.SetRange("Journal Template Name", Setup."Gen. Jnl. Template");
            Jnl.SetRange("Journal Batch Name", Setup."Gen. Jnl. Batch");
            Jnl.DeleteAll();

            template.Get(Setup."Gen. Jnl. Template");
            template.TestField("No. Series");
            DocNo := Noseries.PeekNextNo(template."No. Series");


            // Dr Loan Principal Receivable (GL)
            AddJnlLine(Setup."Gen. Jnl. Template", Setup."Gen. Jnl. Batch", PostingDate, DocNo,
                "Gen. Journal Account Type"::Customer, Loan."Borrower Customer No.", Amount,
                StrSubstNo('Loan %1 disbursement', Loan."Loan No."), "Gen. Journal Account Type"::"Bank Account", Loan."Bank Account No.", LoanNo, "GE Loan Entry Type"::Disbursement, Loan."Dimension Set Id");

            // // Cr Bank
            // AddJnlLine(Setup."Gen. Jnl. Template", Setup."Gen. Jnl. Batch", PostingDate, DocNo,
            //     "Gen. Journal Account Type"::"Bank Account", BankAccountNo, -Amount,
            //     StrSubstNo('Loan %1 disbursement', LoanNo), Setup);

            PostBatch(Setup."Gen. Jnl. Template", Setup."Gen. Jnl. Batch");

            // Loan."Disbursed Amount" += Amount;
            // Loan.Modify(true);

            //  InsertLedger(LoanNo, PostingDate, "GE Loan Entry Type"::Disbursement, Amount, 0, 0, 0, BankAccountNo, ExtRef, DocNo, Setup);
        end;
    end;

    procedure PostInterestAccrual(LoanNo: Code[20]; AccrualDate: Date; InterestAmount: Decimal)
    var
        Loan: Record "US Mortgage Agreement Header";
        Setup: Record "US Mortgage Posting Setup";
        PG: Record "US Mortgage Posting Group";
        DocNo: Code[20];
    begin
        EnsureSetup(Setup);
        Loan.SetRange("Loan No.", LoanNo);
        if Loan.FindFirst() then begin

            if Loan.Status <> Loan.Status::Active then
                Error('Loan must be Active to post accrual.');

            //Loan.Get('MG');
            PG.SetRange(Code, Loan."Posting Group Code");
            if pg.FindFirst() then begin
                //  DocNo := StrSubstNo('ACR-%1-%2', LoanNo, Format(AccrualDate, 0, 9));

                // Dr Interest Receivable
                // AddJnlLine(Setup."Accrual Jnl. Template", Setup."Accrual Jnl. Batch", AccrualDate, DocNo,
                //     "Gen. Journal Account Type"::"G/L Account", PG."Interest Receivable", InterestAmount,
                //     StrSubstNo('Interest accrual - Loan %1', LoanNo), Setup);

                AddJnlLine(Setup."Gen. Jnl. Template", Setup."Gen. Jnl. Batch", AccrualDate, DocNo,
                      "Gen. Journal Account Type"::"G/L Account", PG."Interest Receivable", InterestAmount,
                      StrSubstNo('Interest accrual - Loan %1', Loan."Loan No."), "Gen. Journal Account Type"::"G/L Account", PG."Interest Income", LoanNo, "GE Loan Entry Type"::" ", Loan."Dimension Set Id");

                // // Cr Interest Income
                // AddJnlLine(Setup."Accrual Jnl. Template", Setup."Accrual Jnl. Batch", AccrualDate, DocNo,
                //     "Gen. Journal Account Type"::"G/L Account", PG."Interest Income", -InterestAmount,
                //     StrSubstNo('Interest accrual - Loan %1', LoanNo), Setup);

                PostBatch(Setup."Accrual Jnl. Template", Setup."Accrual Jnl. Batch");

                Loan."Last Accrual Date" := AccrualDate;
                Loan.Modify(true);

                // InsertLedger(LoanNo, AccrualDate, "GE Loan Entry Type"::InterestAccrual, 0, InterestAmount, 0, 0, '', 'Interest accrual', DocNo, Setup);
            end;
        end;
    end;

    procedure PostReceipt(LoanNo: Code[20]; PostingDate: Date; BankAccountNo: Code[20];
                          TotalAmount: Decimal; PenaltyPortion: Decimal; InterestPortion: Decimal; PrincipalPortion: Decimal; EscrowPortion: Decimal; ExtRef: Text[50])
    var
        Setup: Record "US Mortgage Posting Setup";
        Loan: Record "US Mortgage Agreement Header";
        PG: Record "US Mortgage Posting Group";
        DocNo: Code[20];
        JNL: Record "Gen. Journal Line";
        Sch: Record "US Mortgage Schedule Line";
        Journals: Codeunit CreateJournals;
    begin
        EnsureSetup(Setup);
        if not Loan.Get(LoanNo) then
            Error('Loan not found');

        if BankAccountNo = '' then
            BankAccountNo := Loan."Bank Account No.";
        if BankAccountNo = '' then
            BankAccountNo := Setup."Default Bank Account No.";
        if BankAccountNo = '' then
            Error('Bank Account No. is required.');

        if Round(InterestPortion + PrincipalPortion + EscrowPortion, 0.01) <> Round(TotalAmount, 0.01) then
            Error('Receipt allocation must equal total amount.');

        PG.Get(Loan."Posting Group Code");


        Sch.SetRange("Loan No.", Loan."Loan No.");
        Sch.SetRange(Status, Sch.Status::Pending);
        Sch.SetRange(closed, false);
        if Sch.FindFirst() then begin
            if Sch."EMI Amount" = TotalAmount then
                Journals.CreateGenJournalFromSchedule(Sch)
            else begin
                Sch."Amount Paying" := TotalAmount;
                Sch.Modify();
                Journals.CreateGenJournalFromSchedule(Sch);
            end;
        end;
        PostBatch(Setup."Gen. Jnl. Template", Setup."Gen. Jnl. Batch");

        // InsertLedger(LoanNo, PostingDate, "GE Loan Entry Type"::Receipt, PrincipalPortion, InterestPortion, EscrowPortion, 0, BankAccountNo, ExtRef, DocNo, );
    end;

    procedure CalcMonthlyInterestEstimate(LoanNo: Code[20]; AsOfDate: Date): Decimal
    var
        Loan: Record "US Mortgage Agreement Header";
        OutstandingPrincipal: Decimal;
    begin
        Loan.Get(LoanNo);
        // Simple estimate: use principal amount - (sum paid principal)
        OutstandingPrincipal := CalcOutstandingPrincipal(LoanNo);
        exit(Round(OutstandingPrincipal * (Loan."Interest Rate %" / 100) / 12, 0.01));
    end;

    procedure CalcOutstandingPrincipal(LoanNo: Code[20]): Decimal
    var
        Loan: Record "US Mortgage Agreement Header";
        Sch: Record "US Mortgage Schedule Line";
        PaidPrincipal: Decimal;
    begin
        Loan.Get(LoanNo);
        PaidPrincipal := 0;

        Sch.SetRange("Loan No.", LoanNo);
        if Sch.FindSet() then
            repeat
                PaidPrincipal += Sch."Paid Principal";
            until Sch.Next() = 0;

        exit(Loan."Principal Amount" - PaidPrincipal);
    end;

    // ----------------- internals -----------------

    local procedure EnsureSetup(var Setup: Record "US Mortgage Posting Setup")
    begin
        if not Setup.Get('SETUP') then
            Error('Mortgage Setup is missing. Configure Mortgage Setup.');
        if Setup."Gen. Jnl. Template" = '' then
            Error('Gen. Journal Template is not configured in Mortgage Setup.');
        if Setup."Gen. Jnl. Batch" = '' then
            Error('Gen. Journal Batch is not configured in Mortgage Setup.');
        if Setup."Accrual Jnl. Template" = '' then
            Error('Accrual Journal Template is not configured in Mortgage Setup.');
        if Setup."Accrual Jnl. Batch" = '' then
            Error('Accrual Journal Batch is not configured in Mortgage Setup.');
    end;

    local procedure AddJnlLine(Template: Code[10]; Batch: Code[10]; PostingDate: Date; DocNo: Code[20];
                              AccType: Enum "Gen. Journal Account Type"; AccNo: Code[20]; Amount: Decimal; Desc: Text[100];
                              BalType: Enum "Gen. Journal Account Type"; BalNo: Code[20]; Loan: Code[20]; EntryType: Enum "GE Loan Entry Type"; DImID: integer)
    var
        GJL: Record "Gen. Journal Line";
    begin
        if Amount = 0 then
            exit;
        // GJL.Reset();
        // GJL.SetRange("Journal Template Name", 'GENERAL');
        // GJL.SetRange("Journal Batch Name", 'DEFAULT');
        //GJL.DeleteAll();

        GJL.Init();
        GJL.Validate("Journal Template Name", Template);
        GJL.Validate("Journal Batch Name", Batch);
        GJL."Line No." := GetNextLineNo(Template, Batch);
        GJL.Validate("Posting Date", PostingDate);
        GJL.Validate("Document No.", DocNo);
        GJL.Insert(true);
        GJL.Validate("Account Type", AccType);
        GJL.Validate("Account No.", AccNo);
        GJL.Validate(Amount, Amount);
        GJL.Validate("Bal. Account Type", BalType);
        GJL.Validate("Bal. Account No.", BalNo);
        GJL.Description := CopyStr(Desc, 1, MaxStrLen(GJL.Description));
        GJL.Validate("US Mortgage No.", Loan);
        GJL."Loan Entry Type" := EntryType;
        GJL.Validate("Dimension Set ID", DImID);
        GJL.Modify();
    end;

    local procedure GetNextLineNo(Template: Code[10]; Batch: Code[10]): Integer
    var
        GJL: Record "Gen. Journal Line";
    begin
        GJL.SetRange("Journal Template Name", Template);
        GJL.SetRange("Journal Batch Name", Batch);
        if GJL.FindLast() then
            exit(GJL."Line No." + 10000);
        exit(10000);
    end;

    // local procedure PostBatch(Template: Code[10]; Batch: Code[10])
    // var
    //     Post: Codeunit "Gen. Jnl.-Post Batch";
    //     GJB: Record "Gen. Journal Line";
    // begin
    //     GJB.Reset();
    //     GJB.SetRange("Journal Template Name", Template);
    //     GJB.SetRange("Journal Batch Name", Batch);
    //     Post.Run(GJB);
    // end;


    local procedure PostBatch(Template: Code[10]; Batch: Code[10])
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.Reset();
        GenJnlLine.SetRange("Journal Template Name", Template);
        GenJnlLine.SetRange("Journal Batch Name", Batch);

        Page.Run(Page::"General Journal", GenJnlLine);
    end;

    procedure InsertLedger(LoanNo: Code[20]; PostingDate: Date; EntryType: Enum "GE Loan Entry Type";
                                 Principal: Decimal; Interest: Decimal; Escrow: Decimal; Fee: Decimal; No: Code[20];
                                 ExtRef: Text[50]; DocNo: Code[20]; Dim1: Code[20]; Dim2: Code[20]; DimSetID: Integer)
    var
        LLE: Record "US Loan Ledger Entry";
    begin
        LLE.Init();
        LLE."Loan No." := LoanNo;
        LLE."Posting Date" := PostingDate;
        LLE."Entry Type" := EntryType;
        LLE."Amount Principal" := Principal;
        LLE."Amount Interest" := Interest;
        LLE."Amount Escrow" := Escrow;
        LLE."Amount Fee" := Fee;
        LLE."Bank Account No." := No;
        LLE."External Reference" := ExtRef;
        LLE."Document No." := DocNo;
        LLE.Posted := true;
        LLE."Posted By" := UserId;
        LLE."Posted At" := CurrentDateTime();
        LLE.Validate("Shortcut Dim. 1 Code", Dim1);
        LLE.Validate("Shortcut Dim. 2 Code", Dim2);
        LLE.Validate("Dimension Set ID", DimSetID);
        LLE.Insert(true);
    end;
}
