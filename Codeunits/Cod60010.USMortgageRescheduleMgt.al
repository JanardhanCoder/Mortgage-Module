codeunit 60110 "US Mortgage Reschedule Mgt"
{
    procedure RegenerateFromNextEMI(
        var Loan: Record "US Mortgage Agreement Header";
        PartialAmount: Decimal;
        PaymentDate: Date)
    var
        RemainingPrincipal: Decimal;
        InterestRate: Decimal;
        EMIAmount: Decimal;
        DueDate: Date;
        NextLineNo: Integer;
    begin
        // 1️⃣ Validate
        if PartialAmount <= 0 then
            Error('Partial amount must be greater than zero.');

        // 2️⃣ Read financial parameters BEFORE mutation
        RemainingPrincipal := GetOutstandingPrincipal(Loan."Loan No.");
        RemainingPrincipal -= PartialAmount;

        if RemainingPrincipal <= 0 then
            Error('Partial amount exceeds outstanding principal.');

        InterestRate := GetInterestRateByDate(Loan."Loan No.", PaymentDate);
        EMIAmount := GetEMIAmount(Loan."Loan No.");

        // 3️⃣ Cancel future EMI lines
        CancelFutureEMILines(Loan."Loan No.", PaymentDate);

        // 4️⃣ Generate new schedule
        DueDate := CalcDate('1M', PaymentDate);
        NextLineNo := GetNextLineNo(Loan."Loan No.");

        GenerateEMILines(
            Loan."Loan No.",
            RemainingPrincipal,
            EMIAmount,
            InterestRate,
            DueDate,
            NextLineNo);
    end;


    local procedure GenerateEMILines(
    LoanNo: Code[20];
    RemainingPrincipal: Decimal;
    EMIAmount: Decimal;
    InterestRate: Decimal;
    StartDate: Date;
    var LineNo: Integer)
    var
        EMILine: Record "US Mortgage Schedule Line";
        InterestAmt: Decimal;
        PrincipalAmt: Decimal;
    begin
        while RemainingPrincipal > 0 do begin
            InterestAmt :=
                Round(RemainingPrincipal * InterestRate / 100 / 12, 0.01);

            PrincipalAmt := EMIAmount - InterestAmt;

            if PrincipalAmt > RemainingPrincipal then
                PrincipalAmt := RemainingPrincipal;

            EMILine.Init();
            EMILine."Loan No." := LoanNo;
            EMILine."Line No." := LineNo;
            EMILine."Due Date" := StartDate;
            EMILine."Interest Rate %" := InterestRate;
            EMILine."Interest Amount" := InterestAmt;
            EMILine."Principal Amount" := PrincipalAmt;
            EMILine."EMI Amount" := InterestAmt + PrincipalAmt;
            EMILine.Status := EMILine.Status::Pending;
            EMILine.Insert(true);

            RemainingPrincipal -= PrincipalAmt;
            StartDate := CalcDate('1M', StartDate);
            LineNo += 10000;
        end;
    end;

    local procedure GetOutstandingPrincipal(LoanNo: Code[20]): Decimal
    var
        EMILine: Record "US Mortgage Schedule Line";
    begin
        EMILine.Reset();
        EMILine.SetRange("Loan No.", LoanNo);
        EMILine.SetFilter(Status, '<>%1', EMILine.Status::Cancelled);
        EMILine.CalcSums("Principal Amount");
        exit(EMILine."Principal Amount");
    end;

    local procedure GetInterestRateByDate(
        LoanNo: Code[20];
        AsOnDate: Date): Decimal
    var
        EMILine: Record "US Mortgage Schedule Line";
    begin
        EMILine.Reset();
        EMILine.SetRange("Loan No.", LoanNo);
        EMILine.SetFilter("Due Date", '>=%1', AsOnDate);
        EMILine.SetCurrentKey("Due Date");

        if EMILine.FindFirst() then
            exit(EMILine."Interest Rate %");

        Error('No future EMI found to determine interest rate.');
    end;

    local procedure GetEMIAmount(LoanNo: Code[20]): Decimal
    var
        EMILine: Record "US Mortgage Schedule Line";
    begin
        EMILine.SetRange("Loan No.", LoanNo);
        EMILine.SetRange(Status, EMILine.Status::Paid);

        if EMILine.FindLast() then
            exit(EMILine."EMI Amount");

        EMILine.Reset();
        EMILine.SetRange("Loan No.", LoanNo);
        EMILine.SetCurrentKey("Due Date");

        if EMILine.FindFirst() then
            exit(EMILine."EMI Amount");

        Error('Unable to determine EMI Amount.');
    end;

    local procedure CancelFutureEMILines(LoanNo: Code[20]; AsOnDate: Date)
    var
        EMILine: Record "US Mortgage Schedule Line";
    begin
        EMILine.Reset();
        EMILine.SetRange("Loan No.", LoanNo);
        EMILine.SetFilter("Due Date", '>%1', AsOnDate);
        EMILine.SetFilter(Status, '<>%1', EMILine.Status::Paid);

        if EMILine.FindSet(true) then
            repeat
                EMILine.Status := EMILine.Status::Cancelled;
                EMILine.Modify(true);
            until EMILine.Next() = 0;
    end;
    local procedure GetNextLineNo(LoanNo: Code[20]): Integer
    var
        EMILine: Record "US Mortgage Schedule Line";
    begin
        EMILine.SetRange("Loan No.", LoanNo);
        if EMILine.FindLast() then
            exit(EMILine."Line No." + 10000);
        exit(10000);
    end;

}