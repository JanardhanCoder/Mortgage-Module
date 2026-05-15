namespace MortgageForUS.MortgageForUS;

codeunit 60026 "GE Allocation Applier"
{
    procedure ApplyTxn(TxnNo: Code[30]; ExternalRef: Text[50]; PostingDate: Date)
    var
        H: Record "GE Receipt Txn Header";
        L: Record "GE Receipt Txn Alloc Line";
        Sch: Record "US Mortgage Schedule Line";
        LoanNo: Code[20];
        NeedRecast: Boolean;
    begin
        H.Get(TxnNo);

        if H.Status <> H.Status::"GL Posted" then
            Error('Transaction must be GL Posted before applying allocations.');

        L.SetRange("Txn No.", TxnNo);
        L.SetRange(Applied, false);

        if not L.FindSet(true) then begin
            H.Status := H.Status::Applied;
            H."Applied At" := CurrentDateTime();
            H.Modify(true);
            exit;
        end;

        repeat
            LoanNo := L."Loan No.";

            // -------------------------
            // Prepayment (no schedule)
            // -------------------------
            if L."Is Prepayment" then begin
                L.Applied := true;
                L."Applied At" := CurrentDateTime();
                L.Modify(true);
                NeedRecast := true;
                continue;
            end;

            // -------------------------
            // Normal allocation
            // -------------------------
            if L."Schedule Line No." = 0 then
                Error(
                  'Allocation line %1 has no Schedule Line No.',
                  L."Line No.");

            Sch.Get(L."Loan No.", L."Schedule Line No.");

            if L."Penalty Amount" <> 0 then Sch."Paid Penalty" += L."Penalty Amount";
            if L."Interest Amount" <> 0 then Sch."Paid Interest" += L."Interest Amount";
            if L."Principal Amount" <> 0 then Sch."Paid Principal" += L."Principal Amount";
            if L."Escrow Amount" <> 0 then Sch."Paid Escrow" += L."Escrow Amount";

            Sch."Paid Total Amount" :=
                Sch."Paid Principal" + Sch."Paid Interest" +
                Sch."Paid Escrow" + Sch."Paid Penalty";

            Sch."Paid Date" := PostingDate;
            Sch."External Ref." := ExternalRef;

            if (Sch.RemainingPrincipal() <= 0) and
               (Sch.RemainingInterest() <= 0) and
               (Sch.RemainingEscrow() <= 0) and
               (Sch.RemainingPenalty() <= 0) then
                Sch.Status := Sch.Status::Paid;

            Sch.Modify(true);

            L.Applied := true;
            L."Applied At" := CurrentDateTime();
            L.Modify(true);

            NeedRecast := true;
        until L.Next() = 0;

        // -------------------------
        // Recast if needed
        // -------------------------
        if NeedRecast then
            RecastLoan(LoanNo, PostingDate);

        H.Status := H.Status::Applied;
        H."Applied At" := CurrentDateTime();
        H.Modify(true);
    end;

    local procedure RecastLoan(LoanNo: Code[20]; AsOfDate: Date)
    var
        Recast: Codeunit "GE Loan Recast";
    begin
        Recast.RecastFromNextPeriod(LoanNo);
    end;
}

// namespace MortgageForUS.MortgageForUS;

// codeunit 60026 "GE Allocation Applier"
// {
//     procedure ApplyTxn(TxnNo: Code[30]; ExternalRef: Text[50]; PostingDate: Date)
//     var
//         H: Record "GE Receipt Txn Header";
//         L: Record "GE Receipt Txn Alloc Line";
//         Sch: Record "US Mortgage Schedule Line";
//         AnyApplied: Boolean;
//     begin
//         H.Get(TxnNo);

//         if H.Status <> H.Status::"GL Posted" then
//             Error('Transaction must be GL Posted before applying allocations.');

//         L.SetRange("Txn No.", TxnNo);
//         L.SetRange(Applied, false);

//         if not L.FindSet(true) then begin
//             // already applied
//             H.Status := H.Status::Applied;
//             H."Applied At" := CurrentDateTime();
//             H.Modify(true);
//             exit;
//         end;

//         repeat
//             if L."Is Prepayment" then begin
//                 // No schedule update required; mark applied for replay safety
//                 L.Applied := true;
//                 L."Applied At" := CurrentDateTime();
//                 L.Modify(true);
//                 continue;
//             end;

//             Sch.Get(L."Loan No.", L."Schedule Line No.");

//             // Apply amounts
//             if L."Penalty Amount" <> 0 then Sch."Paid Penalty" += L."Penalty Amount";
//             if L."Interest Amount" <> 0 then Sch."Paid Interest" += L."Interest Amount";
//             if L."Principal Amount" <> 0 then Sch."Paid Principal" += L."Principal Amount";
//             if L."Escrow Amount" <> 0 then Sch."Paid Escrow" += L."Escrow Amount";

//             Sch."Paid Total Amount" := Sch."Paid Principal" + Sch."Paid Interest" + Sch."Paid Escrow" + Sch."Paid Penalty";
//             Sch."Paid Date" := PostingDate;
//             Sch."External Ref." := ExternalRef;

//             if (Sch.RemainingPrincipal() <= 0) and (Sch.RemainingInterest() <= 0) and (Sch.RemainingEscrow() <= 0) and (Sch.RemainingPenalty() <= 0) then
//                 Sch.Status := Sch.Status::Paid;

//             Sch.Modify(true);

//             L.Applied := true;
//             L."Applied At" := CurrentDateTime();
//             L.Modify(true);

//             AnyApplied := true;
//         until L.Next() = 0;

//         H.Status := H.Status::Applied;
//         H."Applied At" := CurrentDateTime();
//         H.Modify(true);
//     end;
// }

