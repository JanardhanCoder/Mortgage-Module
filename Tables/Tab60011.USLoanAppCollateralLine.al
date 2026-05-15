table 60011 "US Loan App Collateral Line"
{
    DataClassification = CustomerContent;
    Caption = 'Application Collateral Line';

    fields
    {
        field(1; "Application No."; Code[20]) { TableRelation = "us Loan Application Header"."No."; }
        field(2; "Line No."; Integer) { }
        field(3; "Collateral No."; Code[20]) { TableRelation = "US Collateral Register"."Collateral No."; }

        field(10; "Purchase Price"; Decimal) { }
        field(11; "Down Payment"; Decimal) { }
        field(12; "Proposed Loan Amount"; Decimal) { }
        field(13; "Lien Position Requested"; Enum "GE Lien Position") { }
        field(14; "LTV %"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            Editable = false;

        }
        field(15; Notes; Text[250]) { }
    }

    keys
    {
        key(PK; "Application No.", "Line No.") { Clustered = true; }
    }

    // trigger OnValidate()
    // begin
    //     CalcLTV();
    // end;

    trigger OnModify()
    begin
        CalcLTV();
    end;

    procedure CalcLTV()
    var
        Coll: Record "US Collateral Register";
    begin
        // "LTV %" := 0;
        // if "Collateral No." = '' then
        //     exit;

        // Coll.Get("Collateral No.");
        // if Coll."Market Value" <> 0 then
        //     "LTV %" := Round(("Proposed Loan Amount" / Coll."Market Value") * 100, 0.00001);
        if ("Collateral No." <> '') and Coll.Get("Collateral No.") then
            if Coll."Market Value" > 0 then
                "LTV %" :=
                    Round(
                        ("Proposed Loan Amount" / Coll."Market Value") * 100,
                        0.00001
                    )
            else
                "LTV %" := 0;

    end;
}
