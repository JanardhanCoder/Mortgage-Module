table 60035 Income
{
    Caption = 'Income';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Assessment No."; Code[20])
        {
            Caption = 'Assesement No.';
        }
        field(2; "Application No."; Code[20])
        {
            Caption = 'Application No.';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Type"; Option)
        {
            Caption = 'Type';
            OptionMembers = " ",Salary,Business,Other;
        }
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
        }
    }
    keys
    {
        key(PK; "Assessment No.")
        {
            Clustered = true;
        }
        key(PK2; "Line No.") { }
    }
    trigger OnInsert()
    var
        myInt: Integer;
    begin
        if "Line No." = 0 then begin
            "Line No." := "Line No." + 100000;
        end;
    end;
}
