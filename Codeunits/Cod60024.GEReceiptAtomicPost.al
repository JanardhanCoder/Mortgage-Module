namespace MortgageForUS.MortgageForUS;
using Mortgage.Mortgage;

codeunit 60024 "GE Receipt Atomic Post"
{
    procedure PostReceiptAtomic(LoanNo: Code[20]; PostingDate: Date; BankAccountNo: Code[20]; TotalAmount: Decimal; ExternalRef: Text[50]): Code[100]
    var
        H: Record "GE Receipt Txn Header";
        Planner: Codeunit "GE Allocation Planner";
        Applier: Codeunit "GE Allocation Applier";
        GLPost: Codeunit "US Loan GL Posting";
        TxnNo: Code[30];
        DocNo: Code[20];
    begin
        if ExternalRef = '' then
            Error('External Reference is required for bank-grade posting.');

        TxnNo := GetOrCreateTxn(H, LoanNo, PostingDate, BankAccountNo, TotalAmount, ExternalRef);

        // Prevent duplicate GL posting
        if H.Status = H.Status::Applied then
            exit(TxnNo);

        if H.Status in [H.Status::Draft, H.Status::Allocated, H.Status::Error] then begin
            // Phase 1: allocate (no schedule updates)
            Planner.BuildPlan(LoanNo, PostingDate, TxnNo, TotalAmount,
                              H."Penalty Portion", H."Interest Portion", H."Principal Portion", H."Escrow Portion");
            H.Status := H.Status::Allocated;
            H."Last Error" := '';
            H.Modify(true);
        end;

        if H.Status = H.Status::Allocated then begin
            // Phase 2: post GL
            // Use TxnNo as a stable id for docno uniqueness
            DocNo := CopyStr('R-' + DelChr(TxnNo, '=', '{}-'), 1, 20);

            // IMPORTANT: call your upgraded PostReceipt() that includes penalty
            GLPost.PostReceipt(LoanNo, PostingDate, BankAccountNo, TotalAmount,
                               H."Penalty Portion", H."Interest Portion", H."Principal Portion", H."Escrow Portion",
                               ExternalRef);

            H."GL Document No." := DocNo; // informational; your GL posting can also return it if you adjust it
            H.Status := H.Status::"GL Posted";
            H."GL Posted At" := CurrentDateTime();
            H.Modify(true);
        end;

        if H.Status = H.Status::"GL Posted" then begin
            // Phase 3: apply to schedule (replayable)
            if not TryApply(TxnNo, ExternalRef, PostingDate) then begin
                H.Get(TxnNo);
                H.Status := H.Status::Error;
                H."Last Error" := GetLastErrorText();
                H.Modify(true);
                exit(TxnNo);
            end;
        end;

        exit(TxnNo);
    end;

    [TryFunction]
    local procedure TryApply(TxnNo: Code[30]; ExternalRef: Text[50]; PostingDate: Date)
    var
        Applier: Codeunit "GE Allocation Applier";
    begin
        Applier.ApplyTxn(TxnNo, ExternalRef, PostingDate);
    end;

    local procedure GetOrCreateTxn(var H: Record "GE Receipt Txn Header"; LoanNo: Code[20]; PostingDate: Date; BankAccountNo: Code[20];
                               TotalAmount: Decimal; ExternalRef: Text[50]): Code[30]
    var
        GLPost: Codeunit "US Loan GL Posting";
        Sch: Record "US Mortgage Schedule Line";
    begin
        H.Reset();
        H.SetRange("Loan No.", LoanNo);
        H.SetRange("External Reference", ExternalRef);
        if H.FindFirst() then begin
            // STRICT: same external ref must match same economic details
            if (Round(H."Total Amount", 0.01) <> Round(TotalAmount, 0.01)) or
               (H."Posting Date" <> PostingDate) or
               (H."Bank Account No." <> BankAccountNo)
            then
                Error('Duplicate External Reference detected for this loan, but details differ. Existing Txn %1.', H."Txn No.");

            exit(H."Txn No.");
        end;

        H.Init();
        H."Txn No." := Format(CreateGuid(), 30);
        H."Loan No." := LoanNo;
        H."Posting Date" := PostingDate;
        H."Bank Account No." := BankAccountNo;
        H."External Reference" := ExternalRef;
        Sch.SetRange("Loan No.", LoanNo);
        Sch.SetRange(Status, Sch.Status::Pending);
        Sch.SetRange(closed, false);
        if Sch.FindFirst() then begin
            h."Interest Portion" := Sch."Interest Amount";
            h."Principal Portion" := Sch."Principal Amount";
            h."Escrow Portion" := Sch."Escrow Amount";
        end;
        H."Total Amount" := TotalAmount;
        H.Status := H.Status::Draft;
        H.Insert(true);

        exit(H."Txn No.");
    end;

}
