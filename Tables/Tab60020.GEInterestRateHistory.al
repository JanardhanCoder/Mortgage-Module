table 60020 "GE Interest Rate History"
{
    DataClassification = CustomerContent;
    Caption = 'Interest Rate History';

    fields
    {
        field(1; "Rate Code"; Code[20])
        {
            TableRelation = "GE Interest Rate Setup"."Rate Code";
        }

        field(2; "Effective Date"; Date)
        {
            Caption = 'Effective Date';
        }
        field(4; "Expired Date"; date) { }

        field(3; "Interest Rate %"; Decimal)
        {
            Caption = 'Interest Rate %';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(PK; "Rate Code", "Effective Date")
        {
            Clustered = true;
        }
    }

}
