table 60008 "US Mortgage Doc Type"
{
    Caption = 'US Mortgage Doc Type';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[20]) { }
        field(2; Description; Text[100]) { }
        field(10; "Mandatory Stage"; Enum "US Application Status") { }
        field(11; "Expiry Required"; Boolean) { }
    }

    keys { key(PK; Code) { Clustered = true; } }
}
