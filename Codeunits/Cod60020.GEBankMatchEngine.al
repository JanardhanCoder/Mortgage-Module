namespace MortgageForUS.MortgageForUS;

codeunit 60020 "GE Bank Match Engine"
{
    procedure MatchBatch(BatchNo: Code[30])
    var
        L: Record "GE Bank Stmt Import Line";
    begin
        L.SetRange("Import Batch No.", BatchNo);
        L.SetRange(Status, L.Status::Imported);
        if not L.FindSet(true) then
            exit;

        repeat
            MatchOne(L);
        until L.Next() = 0;
    end;

    procedure MatchOne(var L: Record "GE Bank Stmt Import Line")
    var
        Setup: Record "GE Bank Import Setup";
        Loan: Record "US Mortgage Agreement Header";
        ByIBANLoan: Record "US Mortgage Agreement Header";
        LoanNo: Code[20];
        ExtRef: Text[50];
        Conf: Integer;
        Method: Option " ",ExternalRef,LoanNo,IBAN,FreeText;
    begin
        Setup.Get('SETUP');

        L."Matched Loan No." := '';
        L."Matched External Ref" := '';
        L."Match Confidence" := 0;
        L."Match Method" := L."Match Method"::" ";

        // Extract tokens
        LoanNo := Setup."Loan No Prefix" + TryExtractToken(L."Reference Text", Setup."Loan No Prefix", 20);
        ExtRef := TryExtractToken(L."Reference Text", Setup."External Ref Prefix", 50);
      
        // Priority matching
        TryMatchByPriority(Setup."Match Priority 1", L, LoanNo, ExtRef, Conf, Method);
        if Conf = 0 then TryMatchByPriority(Setup."Match Priority 2", L, LoanNo, ExtRef, Conf, Method);
        if Conf = 0 then TryMatchByPriority(Setup."Match Priority 3", L, LoanNo, ExtRef, Conf, Method);

        if Conf > 0 then begin
            L."Match Confidence" := Conf;
            L."Match Method" := Method;
            L.Status := L.Status::Matched;

            // If we have enough confidence, mark ready
            if Conf >= 80 then
                L.Status := L.Status::"Ready to Post";
        end else begin
            L.Status := L.Status::Error;
            L."Error Message" := 'No match found.';
        end;

        L.Modify(true);
    end;

    local procedure TryMatchByPriority(Priority: Option ExternalRef,LoanNo,IBAN,FreeText," "; var L: Record "GE Bank Stmt Import Line";
                                       ParsedLoanNo: Code[20]; ParsedExtRef: Text[50];
                                       var Confidence: Integer; var Method: Option " ",ExternalRef,LoanNo,IBAN,FreeText)
    var
        Loan: Record "US Mortgage Agreement Header";
    begin
        if Priority = Priority::" " then
            exit;

        case Priority of
            Priority::ExternalRef:
                begin
                    if ParsedExtRef = '' then exit;
                    // External ref is applied at Receipt Txn level; match by previous txns OR store on loan if you maintain such references
                    // We treat it as: external ref implies the loan must also be in text; else match to a unique loan whose borrower name appears.
                    if ParsedLoanNo <> '' then begin
                        if Loan.Get(ParsedLoanNo) then begin
                            L."Matched Loan No." := ParsedLoanNo;
                            L."Matched External Ref" := ParsedExtRef;
                            Confidence := 95;
                            Method := Method::ExternalRef;
                        end;
                    end;
                end;

            Priority::LoanNo:
                begin
                    if ParsedLoanNo = '' then exit;
                    if Loan.Get(ParsedLoanNo) then begin
                        L."Matched Loan No." := ParsedLoanNo;
                        if ParsedExtRef <> '' then L."Matched External Ref" := ParsedExtRef;
                        Confidence := 90;
                        Method := Method::LoanNo;
                    end;
                end;

            Priority::IBAN:
                begin
                    // If you store borrower bank/IBAN in your borrower/customer, match that way.
                    // Here we assume you added Borrower IBAN on Loan header (or borrower's customer).
                    // Implemented as: match loan where Loan."Borrower IBAN" = counterparty IBAN.
                    Confidence := MatchByIBAN(L, Method);
                end;

            Priority::FreeText:
                begin
                    Confidence := MatchByFreeText(L, Method);
                end;
        end;
    end;

    local procedure MatchByIBAN(var L: Record "GE Bank Stmt Import Line"; var Method: Option " ",ExternalRef,LoanNo,IBAN,FreeText): Integer
    var
        Loan: Record "US Mortgage Agreement Header";
        Cnt: Integer;
        FoundLoanNo: Code[20];
    begin
        if L."Counterparty IBAN" = '' then exit(0);

        // EXPECTATION: you have a field on Loan header or borrower customer. If not, add it.
        // Example uses Loan."Borrower IBAN" (tableextension you can add).
        Loan.Reset();
        Loan.SetRange("Borrower IBAN", L."Counterparty IBAN");
        if Loan.FindSet() then begin
            repeat
                Cnt += 1;
                FoundLoanNo := Loan."Loan No.";
            until Loan.Next() = 0;

            if Cnt = 1 then begin
                L."Matched Loan No." := FoundLoanNo;
                Method := Method::IBAN;
                exit(85);
            end;
        end;

        exit(0);
    end;

    local procedure MatchByFreeText(var L: Record "GE Bank Stmt Import Line"; var Method: Option " ",ExternalRef,LoanNo,IBAN,FreeText): Integer
    var
        Loan: Record "US Mortgage Agreement Header";
        Txt: Text;
    begin
        Txt := UpperCase(L."Reference Text");

        // Lightweight: if reference contains exact Loan No, match.
        Loan.Reset();
        Loan.SetFilter("Loan No.", '<>%1', '');
        if Loan.FindSet() then
            repeat
                if StrPos(Txt, UpperCase(Loan."Loan No.")) > 0 then begin
                    L."Matched Loan No." := Loan."Loan No.";
                    Method := Method::FreeText;
                    exit(80);
                end;
            until Loan.Next() = 0;

        exit(0);
    end;

    local procedure TryExtractToken(RefText: Text[250]; Prefix: Text[10]; MaxLen: Integer): Text
    var
        p: Integer;
        s: Text;
        i: Integer;
        ch: Char;
    begin
        if Prefix = '' then exit('');
        p := StrPos(UpperCase(RefText), UpperCase(Prefix));
        if p = 0 then exit('');

        // token begins right after prefix
        s := CopyStr(RefText, p + StrLen(Prefix), MaxLen);

        // trim leading spaces/colon
        while (StrLen(s) > 0) and ((CopyStr(s, 1, 1) = ' ') or (CopyStr(s, 1, 1) = ':')) do
            s := CopyStr(s, 2);

        // cut at first delimiter
        for i := 1 to StrLen(s) do begin
            ch := s[i];
            if (ch = ' ') or (ch = ',') or (ch = ';') or (ch = '|') then begin
                s := CopyStr(s, 1, i - 1);
                break;
            end;
        end;

        //Message('%1', s);
        exit(CopyStr(s, 1, MaxLen));
    end;
}
