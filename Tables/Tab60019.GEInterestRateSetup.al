table 60019 "GE Interest Rate Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Interest Rate Setup';

    fields
    {
        field(1; "Rate Code"; Code[20])
        {
            Caption = 'Rate Code';
            DataClassification = CustomerContent;
        }

        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }

        field(3; "Rate Type"; Option)
        {
            Caption = 'Rate Type';
            OptionMembers = Fixed,Variable;
        }

        field(4; "Revision Frequency"; Option)
        {
            Caption = 'Revision Frequency';
            OptionMembers = Monthly,Quarterly,HalfYearly,Yearly;
        }
    }

    keys
    {
        key(PK; "Rate Code")
        {
            Clustered = true;
        }
    }
}
