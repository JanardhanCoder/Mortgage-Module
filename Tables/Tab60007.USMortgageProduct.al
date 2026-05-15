table 60007 "US Mortgage Product"
{
    Caption = 'US Mortgage Product';
    DataClassification = ToBeClassified;
    fields
    {
        field(1; Code; Code[20]) { }
        field(2; Description; Text[100]) { }

        field(10; "Rate Type"; Option) { OptionMembers = Fixed,Variable; }
        field(11; "Default Rate %"; Decimal) { DecimalPlaces = 0 : 5; }
        field(12; "Min Tenor (Months)"; Integer) { }
        field(13; "Max Tenor (Months)"; Integer) { }
        field(14; "Min Amount"; Decimal) { }
        field(15; "Max Amount"; Decimal) { }
        field(16; "Payment Frequency"; Option) { OptionMembers = Monthly,Quarterly,HalfYearly,Yearly; }
        field(17; "Posting Group Code"; Code[20]) { TableRelation = "US Mortgage Posting Group".Code; }

        field(20; "Fee Recognition Method"; Enum "GE Fee Recognition Method") { }
        field(21; "Accrual Basis"; Enum "GE Accrual Basis") { }
        field(22; "Default Escrow Required"; Boolean) { }
    }

    keys { key(PK; Code) { Clustered = true; } }
}
