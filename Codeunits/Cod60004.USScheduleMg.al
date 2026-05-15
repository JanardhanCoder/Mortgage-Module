namespace Mortgage.Mortgage;
codeunit 60010 "Mortgage Schedule Generator"
{
    procedure GenerateMonthlySchedule(LoanNo: Code[20]; StartDate: Date)
    var
        Loan: Record "US Mortgage Agreement Header";
        Sch: Record "US Mortgage Schedule Line";
        RateHist: Record "GE Interest Rate History";
        LineNo: Integer;
        i: Integer;
        Opening: Decimal;
        Interest: Decimal;
        Principal: Decimal;
        EMI: Decimal;
        AnnualRate: Decimal;
        MonthlyRate: Decimal;
        DueDate: Date;
        RemainingMonths: Integer;
    begin
        Loan.Get(LoanNo);

        // Delete existing schedule
        Sch.Reset();
        Sch.SetRange("Loan No.", LoanNo);
        Sch.SetRange(Status, Sch.Status::Pending);
        Sch.SetRange(Closed, false);
        Sch.SetFilter("Due Date", '>%1', Today);

        if Sch.FindSet(true) then
            repeat
                Sch.Status := Sch.Status::Cancelled;
                Sch."Cancelled Date" := Today;
                Sch."Cancelled By" := UserId;
                Sch.Modify(true);
            until Sch.Next() = 0;



        if Loan."Tenor (Months)" <= 0 then
            Error('Tenor must be greater than zero.');

        Opening := Loan."Principal Amount";
        LineNo := 0;

        for i := 1 to Loan."Tenor (Months)" do begin
            DueDate := CalcDate(StrSubstNo('%1M', i), StartDate);
            RemainingMonths := Loan."Tenor (Months)" - i + 1;


            AnnualRate :=
                InterestRate(
                    Loan."Rate Code",
                    Loan."Interest Rate %",
                    DueDate
                );

            MonthlyRate := AnnualRate / 100 / 12;

            EMI := CalcEMI(Opening, MonthlyRate, RemainingMonths);

            Interest := Round(Opening * MonthlyRate, 0.01);
            Principal := EMI - Interest;
            if Principal < 0 then
                Principal := 0;

            //  LineNo += 10000;
            LineNo := GetNextScheduleLineNo(Loan."Loan No.");

            Sch.Init();
            Sch."Loan No." := LoanNo;
            Sch."Line No." := LineNo;
            // Sch.Description := 'EMI ' + Format(i);
            Sch."Due Date" := DueDate;

            Sch."Opening Principal" := Opening;
            Sch."Interest Rate %" := AnnualRate;
            Sch."EMI Amount" := EMI;
            Sch."Amount Paying" := Sch."EMI Amount";
            Sch."Interest Amount" := Interest;
            Sch."Principal Amount" := Principal;
            Sch."Closing Principal" := Opening - Principal;
            Sch.Status := Sch.Status::Pending;

            Sch.Insert(true);
            Sch.Description := 'EMI - ' + Format(Sch."Due Date", 0, '<Month Text> <Year>');
            Opening := Sch."Closing Principal";
            Sch.Modify();
        end;
    end;

    // -------------------------------------------------------------

    procedure InterestRate(
        RateCode: Code[20];
        FixedRate: Decimal;
        AsOnDate: Date
    ): Decimal
    var
        RateLine: Record "GE Interest Rate History";
    begin
        RateLine.Reset();
        RateLine.SetRange("Rate Code", RateCode);
        RateLine.SetFilter("Effective Date", '<=%1', AsOnDate);
        RateLine.SetFilter("Expired Date", '>=%1|=%2', AsOnDate, 0D);

        if RateLine.FindLast() then
            exit(RateLine."Interest Rate %");

        // Fallback to Fixed Rate
        exit(FixedRate);
    end;

    // -------------------------------------------------------------

    procedure CalcEMI(P: Decimal; r: Decimal; n: Integer): Decimal
    var
        Pow: Decimal;
    begin
        if n <= 0 then
            exit(0);

        if r = 0 then
            exit(Round(P / n, 0.01));

        Pow := Power(1 + r, n);
        exit(Round(P * r * Pow / (Pow - 1), 0.01));
    end;

    // -------------------------------------------------------------

    procedure Power(Base: Decimal; Exp: Integer): Decimal
    var
        i: Integer;
        Result: Decimal;
    begin
        Result := 1;
        for i := 1 to Exp do
            Result := Result * Base;
        exit(Result);
    end;

    local procedure GetNextScheduleLineNo(LoanNo: Code[20]): Integer
    var
        Sch: Record "US Mortgage Schedule Line";
    begin
        Sch.SetRange("Loan No.", LoanNo);
        if Sch.FindLast() then
            exit(Sch."Line No." + 10000);
        exit(10000);
    end;


    // ==================================================================================================
    procedure RegenerateFromNextEMI(
           var Loan: Record "US Mortgage Agreement Header";
           PartialAmount: Decimal;
           PaymentDate: Date)
    var
        EMILine: Record "US Mortgage Schedule Line";
        NewEMILine: Record "US Mortgage Schedule Line";
        LastPaidEMINo: Integer;
        NextEMINo: Integer;
        RemainingPrincipal: Decimal;
        InterestRate: Decimal;
        EMIAmount: Decimal;
        DueDate: Date;
        MonthsRemaining: Integer;
    begin
        // 1️⃣ Find last PAID EMI
        EMILine.Reset();
        EMILine.SetRange("Loan No.", Loan."Loan No.");
        EMILine.SetRange(Status, EMILine.Status::Paid);

        if EMILine.FindLast() then
            LastPaidEMINo := EMILine."Line No."
        else
            LastPaidEMINo := 0;

        NextEMINo := LastPaidEMINo + 1;

        // 2️⃣ Calculate remaining principal after last paid EMI
        RemainingPrincipal := GetOutstandingPrincipal(Loan."Loan No.");

        // 3️⃣ Apply partial payment
        RemainingPrincipal := RemainingPrincipal - PartialAmount;
        if RemainingPrincipal <= 0 then
            Error('Partial amount exceeds outstanding principal.');

        // 4️⃣ Cancel all FUTURE EMI lines
        EMILine.Reset();
        EMILine.SetRange("Loan No.", Loan."Loan No.");
        EMILine.SetFilter("Line No.", '>%1', LastPaidEMINo);
        EMILine.SetRange(Status, EMILine.Status::Pending);

        if EMILine.FindSet() then
            repeat
                EMILine.Status := EMILine.Status::Cancelled;
                EMILine.Modify();
            until EMILine.Next() = 0;

        // 5️⃣ Get parameters from loan
        // EMIAmount := Loan."EMI Amount";
        // InterestRate := Loan."Interest Rate %";
        // MonthsRemaining := Loan."Tenor (Months)" - LastPaidEMINo;
        EMIAmount := GetCurrentEMIAmount(Loan."Loan No.");
        InterestRate := GetCurrentInterestRate(Loan."Loan No.");
        MonthsRemaining := GetRemainingMonths(Loan."Loan No.");


        // Start from next EMI due date
        DueDate := CalcDate('1M', PaymentDate);

        // 6️⃣ Generate NEW EMI lines
        while RemainingPrincipal > 0 do begin
            NewEMILine.Init();
            NewEMILine."Loan No." := Loan."Loan No.";
            NewEMILine."Line No." := NextEMINo;
            NewEMILine."Due Date" := DueDate;
            NewEMILine."Interest Rate %" := InterestRate;

            NewEMILine."Interest Amount" :=
                Round(RemainingPrincipal * InterestRate / 100 / 12, 0.01);

            NewEMILine."Principal Amount" :=
                EMIAmount - NewEMILine."Interest Amount";

            if NewEMILine."Principal Amount" > RemainingPrincipal then begin
                NewEMILine."Principal Amount" := RemainingPrincipal;
                NewEMILine."EMI Amount" :=
                    NewEMILine."Principal Amount" + NewEMILine."Interest Amount";
            end else
                NewEMILine."EMI Amount" := EMIAmount;

            NewEMILine.Status := NewEMILine.Status::Pending;
            NewEMILine.Insert();

            RemainingPrincipal -= NewEMILine."Principal Amount";
            DueDate := CalcDate('1M', DueDate);
            NextEMINo += 1;
        end;
    end;

    // 🔧 Helper
    local procedure GetOutstandingPrincipal(LoanNo: Code[20]): Decimal
    var
        EMILine: Record "US Mortgage Schedule Line";
        Principal: Decimal;
    begin
        EMILine.SetRange("Loan No.", LoanNo);
        EMILine.SetRange(Status, EMILine.Status::Pending);
        EMILine.CalcSums("Principal Amount");
        exit(EMILine."Principal Amount");
    end;

    local procedure GetCurrentEMIAmount(LoanNo: Code[20]): Decimal
    var
        EMILine: Record "US Mortgage Schedule Line";
    begin
        EMILine.Reset();
        EMILine.SetRange("Loan No.", LoanNo);
        EMILine.SetRange(Status, EMILine.Status::Paid);

        if EMILine.FindLast() then
            exit(EMILine."EMI Amount");

        // fallback – first open EMI
        EMILine.Reset();
        EMILine.SetRange("Loan No.", LoanNo);
        EMILine.SetRange(Status, EMILine.Status::Pending);
        if EMILine.FindFirst() then
            exit(EMILine."EMI Amount");

        Error('Unable to determine EMI Amount.');
    end;

    local procedure GetCurrentInterestRate(LoanNo: Code[20]): Decimal
    var
        EMILine: Record "US Mortgage Schedule Line";
    begin
        EMILine.SetRange("Loan No.", LoanNo);
        EMILine.SetRange(Status, EMILine.Status::Pending);

        if EMILine.FindFirst() then
            exit(EMILine."Interest Rate %");

        Error('No Pending EMI line found to determine interest rate.');
    end;

    local procedure GetRemainingMonths(LoanNo: Code[20]): Integer
    var
        EMILine: Record "US Mortgage Schedule Line";
    begin
        EMILine.SetRange("Loan No.", LoanNo);
        EMILine.SetRange(Status, EMILine.Status::Pending);
        exit(EMILine.Count());
    end;
    //    // ====================================================================================
    //    procedure GenerateScheduleFromArrangement(
    //     A: Record "GE Loan Arrangement Header")
    // var
    //     Sch: Record "US Mortgage Schedule Line";
    //     EMI: Decimal;
    //     DueDate: Date;
    //     i: Integer;
    // begin
    //     EMI := CalcEMI(
    //         GetOutstandingPrincipal(A."Loan No."),
    //         A."New Interest Rate %",
    //         A."New Tenor (Months)");

    //     DueDate := A."Effective Date";

    //     for i := 1 to A."New Tenor (Months)" do begin
    //         Sch.Init();
    //         Sch."Loan No." := A."Loan No.";
    //         Sch."Line No." := i * 10000;
    //         Sch."Due Date" := DueDate;
    //         Sch."EMI Amount" := EMI;
    //         Sch."Interest Rate %" := A."New Interest Rate %";
    //         Sch.Status := Sch.Status::Pending;
    //         Sch.Insert(true);

    //         DueDate := CalcDate('1M', DueDate);
    //     end;
    // end;

    // }
}