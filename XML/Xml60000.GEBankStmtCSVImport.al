xmlport 60000 "GE Bank Stmt CSV Import"
{
    Caption = 'Bank Statement CSV Import';
    Direction = Import;
    Format = VariableText;
    TextEncoding = UTF8;

    schema
    {
        textelement(Root)
        {
            tableelement(Line; "GE Bank Stmt Import Line")
            {
                AutoSave = false;

                // Read full CSV row as text
                textelement(LineTxt) { }

                trigger OnBeforeInsertRecord()
                var
                    Setup: Record "GE Bank Import Setup";
                    Cols: List of [Text];
                    CleanLine: Text;
                begin

                    if StrPos(UpperCase(LineTxt), 'CREDIT') > 0 then
                        if StrPos(UpperCase(LineTxt), 'AMOUNT') > 0 then
                            CurrXMLport.Skip();

                    // 1️⃣ Clean and skip empty lines
                    CleanLine := DelChr(LineTxt, '=', ' ');
                    if CleanLine = '' then
                        CurrXMLport.Skip();

                    // 2️⃣ Skip header row EARLY (CRITICAL)
                    if UpperCase(CopyStr(CleanLine, 1, 25)) in
                       ['TRANSACTIONDATE', 'TRANSACTION DATE', 'DATE'] then
                        CurrXMLport.Skip();

                    // 3️⃣ Split CSV safely
                    Cols := CleanLine.Split(',');

                    Setup.Get('SETUP');

                    // 4️⃣ Initialize record
                    Line.Init();
                    Line."Import Batch No." := CurrentBatchNo;
                    Line."Bank Account No." := Setup."Default Bank Account No.";
                    Line.Status := Line.Status::Imported;
                    Line."Processed By" := UserId();

                    // 5️⃣ Parse dates (SAFE)
                    Line."Booking Date" := ParseDate(GetCol(Cols, 1));
                    Line."Value Date" := ParseDate(GetCol(Cols, 2));

                    if Line."Value Date" = 0D then
                        Line."Value Date" := Line."Booking Date";

                    // 6️⃣ Amount (Credit preferred)
                    // if GetCol(Cols, 7) <> '' then
                    //     Evaluate(Line.Amount, GetCol(Cols, 7))
                    // else
                    //     if GetCol(Cols, 6) <> '' then
                    //         Evaluate(Line.Amount, GetCol(Cols, 6))
                    //     else
                    //         Line.Amount := 0;

                    Line.Amount := ParseDecimal(GetCol(Cols, 7)); // Credit

                    if Line.Amount = 0 then
                        Line.Amount := ParseDecimal(GetCol(Cols, 6)); // Debit


                    // 7️⃣ Text fields
                    Line."Reference Text" := GetCol(Cols, 4);
                    Line."Unique Transaction ID" := GetCol(Cols, 5);

                    // 8️⃣ Hash (for duplicate detection)
                    Line."Raw Line Hash" := CalcHash(Line);
                end;

                trigger OnAfterInsertRecord()
                begin
                    Line.Insert(true);
                end;
            }
        }
    }

    var
        CurrentBatchNo: Code[30];

    procedure SetBatchNo(BatchNo: Code[30])
    begin
        CurrentBatchNo := BatchNo;
    end;

    // ---------------- HELPER FUNCTIONS ----------------

    local procedure GetCol(Cols: List of [Text]; Pos: Integer): Text
    begin
        if Cols.Count >= Pos then
            exit(DelChr(Cols.Get(Pos), '=', ' '));
        exit('');
    end;

    local procedure ParseDate(DateTxt: Text): Date
    var
        ParsedDate: Date;
        Day: Integer;
        Month: Integer;
        Year: Integer;
        Txt: Text;
    begin
        Txt := DelChr(DateTxt, '=', ' ');

        if Txt = '' then
            exit(0D);

        // yyyy-mm-dd (ISO)
        if (StrLen(Txt) = 10) and (Txt[5] = '-') then begin
            Evaluate(ParsedDate, Txt);
            exit(ParsedDate);
        end;

        // dd/mm/yyyy
        if (StrLen(Txt) = 10) and (Txt[3] = '/') then begin
            Evaluate(Day, CopyStr(Txt, 1, 2));
            Evaluate(Month, CopyStr(Txt, 4, 2));
            Evaluate(Year, CopyStr(Txt, 7, 4));
            exit(DMY2Date(Day, Month, Year));
        end;

        // dd-mm-yyyy
        if (StrLen(Txt) = 10) and (Txt[3] = '-') then begin
            Evaluate(Day, CopyStr(Txt, 1, 2));
            Evaluate(Month, CopyStr(Txt, 4, 2));
            Evaluate(Year, CopyStr(Txt, 7, 4));
            exit(DMY2Date(Day, Month, Year));
        end;

        // Unknown format → return blank date
        exit(0D);
    end;

    local procedure CalcHash(Line: Record "GE Bank Stmt Import Line"): Text[64]
    begin
        exit(
            CopyStr(
                Format(
                    Line."Bank Account No." + '|' +
                    Format(Line."Booking Date") + '|' +
                    Format(Line.Amount) + '|' +
                    Line."Unique Transaction ID"
                ),
                1, 64
            )
        );
    end;

    local procedure ParseDecimal(AmountTxt: Text): Decimal
    var
        D: Decimal;
        Txt: Text;
    begin
        Txt := DelChr(AmountTxt, '=', ' ');

        // Empty or header text
        if Txt = '' then
            exit(0);

        if UpperCase(Txt) in ['CREDITAMOUNT', 'CREDIT AMOUNT', 'DEBITAMOUNT', 'DEBIT AMOUNT', 'AMOUNT'] then
            exit(0);

        // Remove thousand separators (optional)
        Txt := DelChr(Txt, '=', ',');

        Evaluate(D, Txt);
        exit(D);
    end;

}




// xmlport 60000 "GE Bank Stmt CSV Import"
// {
//     Caption = 'Bank Statement CSV Import';
//     Direction = Import;
//     Format = VariableText;
//     FieldSeparator = ',';
//     TextEncoding = UTF8;

//     schema
//     {
//         textelement(Root)
//         {
//             tableelement(Line; "GE Bank Stmt Import Line")
//             {
//                 AutoSave = true;
//                 AutoUpdate = true;

//                 fieldelement(BankAccountNo; Line."Bank Account No.") { }
//                 fieldelement(BookingDate; Line."Booking Date") { }
//                 fieldelement(ValueDate; Line."Value Date") { }
//                 fieldelement(Amount; Line.Amount) { }
//                 fieldelement(Currency; Line.Currency) { }
//                 fieldelement(CounterpartyName; Line."Counterparty Name") { }
//                 fieldelement(CounterpartyIBAN; Line."Counterparty IBAN") { }
//                 fieldelement(ReferenceText; Line."Reference Text") { }
//                 fieldelement(UniqueTransactionID; Line."Unique Transaction ID") { }

//                 trigger OnBeforeInsertRecord()
//                 var
//                     Setup: Record "GE Bank Import Setup";
//                 begin
//                     Setup.Get('SETUP');

//                     if Line."Import Batch No." = '' then
//                         Line."Import Batch No." := CurrentBatchNo;

//                     if Line."Bank Account No." = '' then
//                         Line."Bank Account No." := Setup."Default Bank Account No.";

//                     Line.Status := Line.Status::Imported;
//                     Line."Raw Line Hash" := CalcHash(Line);

//                     // Optional skip rules
//                     if Setup."Skip Non-Receipts" and (Line.Amount <= 0) then begin
//                         Line.Status := Line.Status::Skipped;
//                         Line."Error Message" := 'Skipped: amount <= 0';
//                     end;

//                     if (Setup."Min Amount" <> 0) and (Line.Amount < Setup."Min Amount") then begin
//                         Line.Status := Line.Status::Skipped;
//                         Line."Error Message" := 'Skipped: below min amount';
//                     end;

//                     if (Setup."Max Amount" <> 0) and (Line.Amount > Setup."Max Amount") then begin
//                         Line.Status := Line.Status::Skipped;
//                         Line."Error Message" := 'Skipped: above max amount';
//                     end;
//                 end;
//             }
//         }
//     }

//     var
//         CurrentBatchNo: Code[30];

//     procedure SetBatchNo(BatchNo: Code[30])
//     begin
//         CurrentBatchNo := BatchNo;
//     end;

//     local procedure CalcHash(Line: Record "GE Bank Stmt Import Line"): Text[64]
//     begin
//         // Lightweight deterministic “hash-like” string (true crypto hash would require .NET interop; keep simple)
//         exit(CopyStr(
//             DelChr(Format(Line."Bank Account No." + '|' + Format(Line."Booking Date") + '|' + Format(Line."Value Date") + '|' +
//                           Format(Line.Amount) + '|' + Line.Currency + '|' + Line."Counterparty IBAN" + '|' +
//                           Line."Unique Transaction ID" + '|' + Line."Reference Text"), '=', ' '), 1, 64));
//     end;
// }
