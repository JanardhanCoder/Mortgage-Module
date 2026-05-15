table 60038 "US Underwriting Risk Rules"
{
    Caption = 'US Underwriting Risk Rules';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Line No"; Integer) { }
        field(2; "Rule Type"; Enum "Risk Rule Type") { }
        field(3; "Product Type"; Code[20]) { }
        field(10; "From Value"; Decimal) { }
        field(11; "To Value"; Decimal) { }

        field(12; "Risk Level"; Enum "Risk Level") { }

        field(30; "Blocked"; Boolean) { }
    }

    keys
    {
        key(PK; "Line No") { Clustered = true; }
        key(RangeKey; "Rule Type", "Product Type", "From Value") { }
    }
}
