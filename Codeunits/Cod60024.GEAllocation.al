namespace MortgageForUS.MortgageForUS;

codeunit 60025 "GE Allocation Planner"
{
    procedure BuildPlan(
       LoanNo: Code[20];
       PostingDate: Date;
       TxnNo: Code[30];
       TotalAmount: Decimal;
       var PenaltyPortion: Decimal;
       var InterestPortion: Decimal;
       var PrincipalPortion: Decimal;
       var EscrowPortion: Decimal)
    var
        Sch: Record "US Mortgage Schedule Line";
        Alloc: Record "GE Receipt Txn Alloc Line";
        Remaining: Decimal;
        LineNo: Integer;
        Take: Decimal;
    begin
        Clear(PenaltyPortion);
        Clear(InterestPortion);
        Clear(PrincipalPortion);
        Clear(EscrowPortion);

        if TotalAmount <= 0 then
            Error('Total amount must be > 0.');

        // ------------------------------
        // Reset old allocation plan
        // ------------------------------
        Alloc.SetRange("Txn No.", TxnNo);
        if Alloc.FindSet(true) then
            Alloc.DeleteAll();

        Remaining := TotalAmount;
        LineNo := 0;

        // ------------------------------
        // Allocate against schedule
        // ------------------------------
        Sch.SetRange("Loan No.", LoanNo);
        Sch.SetFilter(Status, '%1|%2',
                      Sch.Status::Pending,
                      Sch.Status::Overdue);
        Sch.SetCurrentKey("Due Date");

        if Sch.FindSet() then
            repeat
                if Remaining <= 0 then
                    break;

                LineNo += 10000;
                Alloc.Init();
                Alloc."Txn No." := TxnNo;
                Alloc."Line No." := LineNo;
                Alloc."Loan No." := LoanNo;
                Alloc."Schedule Line No." := Sch."Line No.";
                Alloc."Due Date" := Sch."Due Date";

                // 1️⃣ Penalty
                Take := Min(Remaining, Sch.RemainingPenalty());
                if Take > 0 then begin
                    Alloc."Penalty Amount" := Take;
                    PenaltyPortion += Take;
                    Remaining -= Take;
                end;

                // 2️⃣ Interest
                Take := Min(Remaining, Sch.RemainingInterest());
                if Take > 0 then begin
                    Alloc."Interest Amount" := Take;
                    InterestPortion += Take;
                    Remaining -= Take;
                end;

                // 3️⃣ Principal
                Take := Min(Remaining, Sch.RemainingPrincipal());
                if Take > 0 then begin
                    Alloc."Principal Amount" := Take;
                    PrincipalPortion += Take;
                    Remaining -= Take;
                end;

                // 4️⃣ Escrow
                Take := Min(Remaining, Sch.RemainingEscrow());
                if Take > 0 then begin
                    Alloc."Escrow Amount" := Take;
                    EscrowPortion += Take;
                    Remaining -= Take;
                end;

                if Alloc."Penalty Amount"
                 + Alloc."Interest Amount"
                 + Alloc."Principal Amount"
                 + Alloc."Escrow Amount" > 0 then
                    Alloc.Insert(true);

            until Sch.Next() = 0;

        // ------------------------------
        // HANDLE REMAINDER (PREPAYMENT)
        // ------------------------------
        if Remaining > 0 then begin
            LineNo += 10000;
            Alloc.Init();
            Alloc."Txn No." := TxnNo;
            Alloc."Line No." := LineNo;
            Alloc."Loan No." := LoanNo;
            Alloc."Due Date" := PostingDate;

            // 🔑 Entire remainder is PRINCIPAL PREPAYMENT
            Alloc."Principal Amount" := Remaining;
            Alloc."Is Prepayment" := true; // Boolean field (recommended)

            PrincipalPortion += Remaining;
            Remaining := 0;

            Alloc.Insert(true);
        end;
    end;

    // ------------------------------
    // Utility
    // ------------------------------
    local procedure Min(A: Decimal; B: Decimal): Decimal
    begin
        if A < B then
            exit(A);
        exit(B);
    end;
}

// namespace MortgageForUS.MortgageForUS;
// codeunit 60025 "GE Allocation Planner"
// {
//     procedure BuildPlan(LoanNo: Code[20]; PostingDate: Date; TxnNo: Code[30]; TotalAmount: Decimal;
//                         var PenaltyPortion: Decimal; var InterestPortion: Decimal; var PrincipalPortion: Decimal; var EscrowPortion: Decimal)
//     var
//         Sch: Record "US Mortgage Schedule Line";
//         Alloc: Record "GE Receipt Txn Alloc Line";
//         Remaining: Decimal;
//         LineNo: Integer;
//         Take: Decimal;
//     begin
//         Clear(PenaltyPortion);
//         Clear(InterestPortion);
//         Clear(PrincipalPortion);
//         Clear(EscrowPortion);

//         if TotalAmount <= 0 then
//             Error('Total amount must be > 0.');

//         // wipe prior plan lines for safety (rebuild)
//         Alloc.SetRange("Txn No.", TxnNo);
//         if Alloc.FindSet(true) then
//             Alloc.DeleteAll();

//         Remaining := TotalAmount;
//         LineNo := 0;

//         Sch.SetRange("Loan No.", LoanNo);
//         Sch.SetFilter(Status, '%1|%2', Sch.Status::Pending, Sch.Status::Overdue);
//         Sch.SetCurrentKey("Due Date");

//         if not Sch.FindSet() then
//             exit;

//         repeat
//             if Remaining <= 0 then
//                 break;

//             LineNo += 10000;
//             Alloc.Init();
//             Alloc."Txn No." := TxnNo;
//             Alloc."Line No." := LineNo;
//             Alloc."Loan No." := LoanNo;
//             Alloc."Schedule Line No." := Sch."Line No.";
//             Alloc."Due Date" := Sch."Due Date";

//             // 1) Penalty
//             Take := Min(Remaining, Sch.RemainingPenalty());
//             if Take > 0 then begin
//                 Alloc."Penalty Amount" := Take;
//                 PenaltyPortion += Take;
//                 Remaining -= Take;
//             end;

//             // 2) Interest
//             Take := Min(Remaining, Sch.RemainingInterest());
//             if Take > 0 then begin
//                 Alloc."Interest Amount" := Take;
//                 InterestPortion += Take;
//                 Remaining -= Take;
//             end;

//             // 3) Principal
//             Take := Min(Remaining, Sch.RemainingPrincipal());
//             if Take > 0 then begin
//                 Alloc."Principal Amount" := Take;
//                 PrincipalPortion += Take;
//                 Remaining -= Take;
//             end;

//             // 4) Escrow
//             Take := Min(Remaining, Sch.RemainingEscrow());
//             if Take > 0 then begin
//                 Alloc."Escrow Amount" := Take;
//                 EscrowPortion += Take;
//                 Remaining -= Take;
//             end;

//             if (Alloc."Penalty Amount" + Alloc."Interest Amount" + Alloc."Principal Amount" + Alloc."Escrow Amount") > 0 then
//                 Alloc.Insert(true);
//         until Sch.Next() = 0;

//         // if Remaining > 0 => unapplied remainder (prepayment) — you can decide policy.
//         // For now, we stop at schedule coverage; remainder can be treated as principal prepayment with a new rule if needed.
//     end;

//     local procedure Min(a: Decimal; b: Decimal): Decimal
//     begin
//         if a < b then exit(a);
//         exit(b);
//     end;
// }
