namespace MortgageForUS.MortgageForUS;
codeunit 60021 "GE Bank Batch Poster"
{
    procedure PostBatch(BatchNo: Code[100]; MaxLines: Integer)
    var
        L: Record "GE Bank Stmt Import Line";
        Atomic: Codeunit "GE Receipt Atomic Post";
        Setup: Record "GE Bank Import Setup";
        PostingDate: Date;
        ExtRef: Text[50];
        TxnNo: Code[100];
        Count: Integer;
    begin
        Setup.Get('SETUP');

        L.SetRange("Import Batch No.", BatchNo);
        L.SetRange(Status, L.Status::"Ready to Post");
        if not L.FindSet(true) then
            exit;

        repeat
            if (MaxLines > 0) and (Count >= MaxLines) then
                break;

            // Posting date rule
            PostingDate := ResolvePostingDate(Setup, L);

            // External reference
            ExtRef := L."Unique Transaction ID";
            if ExtRef = '' then
                ExtRef := CopyStr(L."Raw Line Hash", 1, 50);

            // Require a matched loan
            if L."Matched Loan No." = '' then begin
                MarkError(L, 'Ready to Post but Matched Loan No. is empty.');
                continue;
            end;

            // Call atomic receipt posting
            if not TryPostOne(Atomic, L."Matched Loan No.", PostingDate, L."Bank Account No.", L.Amount, ExtRef, TxnNo) then begin
                MarkError(L, GetLastErrorText());
                continue;
            end;

            L."Receipt Txn No." := TxnNo;
            L.Status := L.Status::Posted;
            L."Processed At" := CurrentDateTime();
            L."Processed By" := UserId;
            L."Error Message" := '';
            L.Modify(true);

            Count += 1;
        until L.Next() = 0;
    end;

    [TryFunction]
    local procedure TryPostOne(var Atomic: Codeunit "GE Receipt Atomic Post"; LoanNo: Code[20]; PostingDate: Date; BankNo: Code[20]; Amount: Decimal; ExtRef: Text[50];
                              var TxnNo: Code[100])
    begin
        TxnNo := Atomic.PostReceiptAtomic(LoanNo, PostingDate, BankNo, Amount, ExtRef);
        // TxnNo:=Atomic.PostReceiptAtomic(LoanNo)
    end;

    local procedure ResolvePostingDate(Setup: Record "GE Bank Import Setup"; L: Record "GE Bank Stmt Import Line"): Date
    begin
        case Setup."Default Posting Date Rule" of
            Setup."Default Posting Date Rule"::ValueDate:
                if L."Value Date" <> 0D then
                    exit(L."Value Date");
            Setup."Default Posting Date Rule"::BookingDate:
                if L."Booking Date" <> 0D then
                    exit(L."Booking Date");
        end;
        exit(Today);
    end;

    local procedure MarkError(var L: Record "GE Bank Stmt Import Line"; Msg: Text[250])
    begin
        L.Status := L.Status::Error;
        L."Error Message" := CopyStr(Msg, 1, 250);
        L."Processed At" := CurrentDateTime();
        L."Processed By" := UserId;
        L.Modify(true);
    end;
}
