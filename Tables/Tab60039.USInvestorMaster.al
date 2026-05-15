table 60039 "US Investor Master"
{
    Caption = 'US Investor Master';
    DataClassification = CustomerContent;
    //DrillDownPageId = "US Investor Master List";
    //LookupPageId = "US Investor Master List";

    fields
    {
        field(1; "Investor No."; Code[20])
        {
            Caption = 'Investor No.';
            DataClassification = CustomerContent;
        }

        field(2; "Legal Name"; Text[100])
        {
            Caption = 'Legal Name';
            DataClassification = CustomerContent;
        }

        field(3; "Settlement Method"; Enum "US Investor Settlement Method")
        {
            Caption = 'Settlement Method';
            DataClassification = CustomerContent;
        }

        field(4; "Purchase Advice Format"; Enum "US Purchase Advice Format")
        {
            Caption = 'Standard Purchase Advice Format';
            DataClassification = CustomerContent;
        }

        field(5; "Price Method / Fee Model"; Enum "US Price Method")
        {
            Caption = 'Price Method / Fee Model';
            DataClassification = CustomerContent;
        }

        field(6; "Warehouse Required"; Boolean)
        {
            Caption = 'Warehouse Requirement';
            DataClassification = CustomerContent;
        }

        field(7; "Custodian Required"; Boolean)
        {
            Caption = 'Custodian Requirement';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Investor No.")
        {
            Clustered = true;
        }
    }
}