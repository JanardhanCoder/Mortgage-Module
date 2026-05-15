table 60022 "Partial Pre-Settlement Input"
{
    DataClassification = ToBeClassified;
   

    fields
    {
        field(1; "Partial Amount"; Decimal) { }
        field(2; "Settlement Date"; Date) { }
        field(3; "Settlement Option"; Enum "Pre-Settlement Option") { }
    }
    keys
    {
        key(PK; "Partial Amount") { Clustered = true; }
    }
}
table 60023 "Partial Pre-Settlement Input1"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Partial Amount"; Decimal) { }
        field(3; "Settlement Date"; Date) { }
        field(4; "Settlement Option"; Enum "Pre-Settlement Option") { }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
