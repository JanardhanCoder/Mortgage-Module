// codeunit 60033 "GE LHFS Sale Post"
// {
//     procedure PostSettlement(SaleNo: Code[20])
//     var
//         SaleH: Record "GE LHFS Sale Header";
//         SaleL: Record "GE LHFS Sale Line";
//         Loan: Record "US Mortgage Agreement Header";
//         PG: Record "US Mortgage Posting Group";
//         Setup: Record "US Mortgage Posting Setup";
//         PostBatch: Codeunit "Gen. Jnl.-Post Batch";
//         GJL: Record "Gen. Journal Line";
//         DocNo: Code[20];
//         LineNo: Integer;
//         AssetAmt: Decimal;
//         Proceeds: Decimal;
//         GainLoss: Decimal;
//     begin
//         SaleH.Get(SaleNo);
//         if SaleH.Status <> SaleH.Status::Committed then
//             Error('Sale must be Committed before settlement.');

//         if SaleH."Settlement Date" = 0D then
//             Error('Settlement Date is required.');

//         if SaleH."Proceeds Bank Account" = '' then
//             Error('Proceeds Bank Account is required.');

//         Setup.Get('SETUP');

//         DocNo := CopyStr('LHFS-' + SaleH."No.", 1, 20);

//         // clear old staged journal lines for same doc no
//         GJL.Reset();
//         GJL.SetRange("Journal Template Name", Setup."Gen. Jnl. Template");
//         GJL.SetRange("Journal Batch Name", Setup."Gen. Jnl. Batch");
//         GJL.SetRange("Document No.", DocNo);
//         if GJL.FindSet(true) then
//             GJL.DeleteAll(true);

//         LineNo := 10000;

//         SaleL.SetRange("Sale No.", SaleH."No.");
//         if not SaleL.FindSet() then
//             Error('Sale must have at least one line.');

//         repeat
//             Loan.Get(SaleL."Loan No.");
//             PG.Get(Loan."Posting Group Code");

//             if PG."Loan Principal Receivable" = '' then
//                 Error('Loan Principal Receivable Account missing in Posting Group %1.', PG.Code);

//             AssetAmt := SaleL."Principal Outstanding" + SaleL."Accrued Interest Sold";
//             Proceeds := SaleL."Net Proceeds";
//             GainLoss := SaleL."Gain/Loss";

//             // Dr Bank
//             InsertJnlLine(
//                 Setup."Gen. Jnl. Template", Setup."Gen. Jnl. Batch", LineNo, SaleH."Settlement Date", DocNo,
//                 GJL."Account Type"::"Bank Account", SaleH."Proceeds Bank Account", Proceeds,
//                 StrSubstNo('LHFS Sale Proceeds Loan %1', SaleL."Loan No."));
//             LineNo += 10000;

//             // Remove LHFS asset
//             InsertJnlLine(
//                 Setup."Gen. Jnl. Template", Setup."Gen. Jnl. Batch", LineNo, SaleH."Settlement Date", DocNo,
//                 GJL."Account Type"::"G/L Account", Setup."LHFS Account", -AssetAmt,
//                 StrSubstNo('Remove LHFS Asset Loan %1', SaleL."Loan No."));
//             LineNo += 10000;

//             // Gain / Loss
//             if GainLoss > 0 then begin
//                 if Setup."Gain/Loss Account" = '' then
//                     Error('LHFS Gain Account missing in Posting Group %1.', PG.Code);

//                 InsertJnlLine(
//                     Setup."Gen. Jnl. Template", Setup."Gen. Jnl. Batch", LineNo, SaleH."Settlement Date", DocNo,
//                     GJL."Account Type"::"G/L Account", Setup."Gain/Loss Account", -GainLoss,
//                     StrSubstNo('LHFS Gain Loan %1', SaleL."Loan No."));
//                 LineNo += 10000;
//             end else
//                 if GainLoss < 0 then begin
//                     if Setup."Gain/Loss Account" = '' then
//                         Error('LHFS Loss Account missing in Posting Group %1.', PG.Code);

//                     InsertJnlLine(
//                         Setup."Gen. Jnl. Template", Setup."Gen. Jnl. Batch", LineNo, SaleH."Settlement Date", DocNo,
//                         GJL."Account Type"::"G/L Account", Setup."Gain/Loss Account", Abs(GainLoss),
//                         StrSubstNo('LHFS Loss Loan %1', SaleL."Loan No."));
//                     LineNo += 10000;
//                 end;

//             // mark loan as sold / closed or investor-assigned
//             Loan."Current Investor Sale No." := SaleH."No.";
//             Loan.Status := Loan.Status::Closed; // or custom status "Sold"
//             Loan.Modify(true);

//         until SaleL.Next() = 0;

//         Page.Run(Page::"General Journal", GJL);

//         SaleH.Status := SaleH.Status::Settled;
//         SaleH."GL Document No." := DocNo;
//         SaleH.Modify(true);
//     end;

//     local procedure InsertJnlLine(Template: Code[10]; Batch: Code[10]; LineNo: Integer; PDate: Date; DocNo: Code[20];
//                                   AccType: Enum "Gen. Journal Account Type"; AccNo: Code[20]; Amount: Decimal; DescTxt: Text[100])
//     var
//         GJL: Record "Gen. Journal Line";
//     begin
//         GJL.Init();
//         GJL."Journal Template Name" := Template;
//         GJL."Journal Batch Name" := Batch;
//         GJL."Line No." := LineNo;
//         GJL."Posting Date" := PDate;
//         GJL."Document No." := DocNo;
//         GJL."Account Type" := AccType;
//         GJL."Account No." := AccNo;
//         GJL.Amount := Amount;
//         GJL.Description := DescTxt;
//         GJL.Insert(true);
//     end;
// }