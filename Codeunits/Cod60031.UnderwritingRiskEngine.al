namespace MortgageForUS.MortgageForUS;

codeunit 60031 "Underwriting Risk Engine"
{
    var
        Rules: Record "US Underwriting Risk Rules";


    procedure CreateUnderWritingAssmt(var App: Record "US Loan Application Header")
    var
        UW: Record "Underwriting Assessment";
    begin
        UW.InitNo();
        UW.Insert();
        UW.Validate("Application No.", App."No.");
        UW.Modify();
        // /Message('Underwriting Assessment Created sucessfully: %1', UW."Assessment No.");
        if Dialog.Confirm('Underwriting Assessment Created sucessfully. Do you want open?', true) then
            Page.Run(Page::"Underwriting Assessment Card", UW);
    end;

    procedure CalculateRisk(var UW: Record "Underwriting Assessment")
    begin
        CalculateValues(UW);
        EvaluateIncomeRisk(UW);
        EvaluateCreditRisk(UW);
        EvaluateFOIRRisk(UW);
        EvaluateCollateralRisk(UW);
        CalculateOverallRisk(UW);
    end;

    local procedure CalculateValues(var UW: Record "Underwriting Assessment")
    var
        myInt: Integer;
        setup: Record "US Mortgage Posting Setup";
    begin
        setup.Get('SETUP');
        UW."DTI %" := ((UW."Total Monthly EMIs" + UW."Proposed EMI") / UW."Monthly Income") * 100;
        if setup."LTV Calulation by" = setup."LTV Calulation by"::"By Market Value" then
            UW."LTV %" := (UW."Requested Loan Amount" / UW."Market Value") * 100
        else
            UW."LTV %" := (UW."Requested Loan Amount" / uw."Property Price") * 100;
        UW."FOIR %" := (UW."Total Monthly EMIs" / UW."Monthly Income") * 100;
        UW.Modify();
    end;

    local procedure EvaluateIncomeRisk(var UW: Record "Underwriting Assessment")
    begin
        Rules.SetRange("Rule Type", Rules."Rule Type"::DTI);
        Rules.SetRange(Blocked, false);
        if Rules.FindSet() then begin
            repeat
                if (Rules."From Value" <= UW."DTI %") and (Rules."To Value" >= UW."DTI %") then begin
                    UW."Income Risk" := Rules."Risk Level";
                    UW.Modify();
                end;
            until Rules.Next() = 0;
        end;
        // if UW."DTI %" <= 40 then
        //     UW."Income Risk" := UW."Income Risk"::Low
        // else if UW."DTI %" <= 55 then
        //     UW."Income Risk" := UW."Income Risk"::Medium
        // else
        //     UW."Income Risk" := UW."Income Risk"::High;
    end;

    local procedure EvaluateCreditRisk(var UW: Record "Underwriting Assessment")
    begin
        Rules.SetRange("Rule Type", Rules."Rule Type"::"Credit Score");
        Rules.SetRange(Blocked, false);
        if Rules.FindSet() then begin
            repeat
                if (Rules."From Value" <= UW."Credit Score") and (Rules."To Value" >= UW."Credit Score") then begin
                    UW."Credit Risk" := Rules."Risk Level";
                    UW.Modify();
                end;
            until Rules.Next() = 0;
        end;
        // if UW."Credit Score" >= 750 then
        //     UW."Credit Risk" := UW."Credit Risk"::Low
        // else if UW."Credit Score" >= 650 then
        //     UW."Credit Risk" := UW."Credit Risk"::Medium
        // else
        //     UW."Credit Risk" := UW."Credit Risk"::High;
    end;

    local procedure EvaluateFOIRRisk(var UW: Record "Underwriting Assessment")
    begin
        Rules.SetRange("Rule Type", Rules."Rule Type"::FOIR);
        Rules.SetRange(Blocked, false);
        if Rules.FindSet() then begin
            repeat
                if (Rules."From Value" <= UW."FOIR %") and (Rules."To Value" >= UW."FOIR %") then begin
                    UW."FOIR Risk" := Rules."Risk Level";
                    UW.Modify();
                end;
            until Rules.Next() = 0;
        end;
        // if UW."FOIR %" <= 40 then
        //     UW."FOIR Risk" := UW."FOIR Risk"::Low
        // else if UW."FOIR %" <= 55 then
        //     UW."FOIR Risk" := UW."FOIR Risk"::Medium
        // else
        //     UW."FOIR Risk" := UW."FOIR Risk"::High;
    end;

    local procedure EvaluateCollateralRisk(var UW: Record "Underwriting Assessment")
    begin
        Rules.SetRange("Rule Type", Rules."Rule Type"::LTV);
        Rules.SetRange(Blocked, false);
        if Rules.FindSet() then begin
            repeat
                if (Rules."From Value" <= UW."LTV %") and (Rules."To Value" >= UW."LTV %") then begin
                    UW."Collateral Risk" := Rules."Risk Level";
                    UW.Modify();
                end;
            until Rules.Next() = 0;
        end;
        // if UW."LTV %" <= 70 then
        //     UW."Collateral Risk" := UW."Collateral Risk"::Low
        // else if UW."LTV %" <= 85 then
        //     UW."Collateral Risk" := UW."Collateral Risk"::Medium
        // else
        //     UW."Collateral Risk" := UW."Collateral Risk"::High;
    end;

    local procedure CalculateOverallRisk(var UW: Record "Underwriting Assessment")
    begin
        if (UW."Income Risk" = UW."Income Risk"::High) or
           (UW."Credit Risk" = UW."Credit Risk"::High) then
            UW."Overall Risk" := UW."Overall Risk"::High
        else if (UW."FOIR Risk" = UW."FOIR Risk"::Medium) or
                (UW."Collateral Risk" = UW."Collateral Risk"::Medium) then
            UW."Overall Risk" := UW."Overall Risk"::Medium
        else
            UW."Overall Risk" := UW."Overall Risk"::Low;
        UW.Modify();
    end;

    procedure TotalMonthlyIncome(var Income: Record IncomeLines)
    var
        Header: Record "Underwriting Assessment";
        TotalAmt: Decimal;
    begin
        // Update header
        Header.SetRange("Assessment No.", Income."Assessment No.");
        if Header.FindFirst() then begin
            Header."Monthly Income" := MonthlyIncome(Header) + Income.Amount;
            Header.Modify();
        end;
    end;

    procedure UpdateIncome(var Income: Record IncomeLines)
    var
        Header: Record "Underwriting Assessment";
        TotalAmt: Decimal;
    begin
        // Update header
        Header.SetRange("Assessment No.", Income."Assessment No.");
        if Header.FindFirst() then begin
            Header."Monthly Income" := MonthlyIncome(Header) - Income.Amount;
            Header.Modify();
        end;
    end;

    procedure MonthlyIncome(var UW: Record "Underwriting Assessment"): Decimal
    var
        Lines: Record IncomeLines;
        Amount: Decimal;
    begin
        Clear(Amount);
        Lines.Reset();
        Lines.SetRange("Assessment No.", UW."Assessment No.");
        if Lines.FindSet() then
            repeat
                Amount := Amount + Lines.Amount;
            until Lines.Next() = 0;
        exit(Amount);
    end;

    procedure CalculateTotalEMI(var UW: Record "Underwriting Assessment"): Decimal
    var
        Amount: Decimal;
        lines: Record "EMI Line Table";
    begin
        Clear(Amount);
        lines.Reset();
        lines.SetRange("Application No.", UW."Assessment No.");
        if lines.FindSet() then begin
            repeat
                Amount := Amount + lines."Loan Amount";
            until lines.Next() = 0;
        end;

        exit(Amount);
    end;

    procedure UpdateTotalEMI(var lines: Record "EMI Line Table")
    var
        UW: Record "Underwriting Assessment";
    begin
        UW.SetRange("Assessment No.", lines."Application No.");
        if UW.FindFirst() then begin
            UW."Total Monthly EMIs" := CalculateTotalEMI(UW) + lines."Loan Amount";
            UW.Modify();
        end;
    end;

    procedure DeleteLines(var lines: Record "EMI Line Table")
    var
        UW: Record "Underwriting Assessment";
    begin
        UW.SetRange("Assessment No.", lines."Application No.");
        if UW.FindFirst() then begin
            UW."Total Monthly EMIs" := CalculateTotalEMI(UW) - lines."Loan Amount";
            UW.Modify();
        end;
    end;
}
