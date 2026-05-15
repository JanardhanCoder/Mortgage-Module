table 60034 "EMI Line Table"
{
    Caption = 'EMI Line Table';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Application No."; Code[20])
        {
            TableRelation = "Underwriting Assessment";
            Caption = 'Assessment No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Loan Type"; Option)
        {
            Caption = 'Loan Type';
            OptionMembers = " ",Personal,Home,Auto,Education;
        }
        field(4; "Loan Amount"; Decimal)
        {
            Caption = 'Loan Amount';
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                UnderwritingMgt.UpdateTotalEMI(Rec);
            end;
        }
    }
    keys
    {
        key(PK; "Application No.", "Line No.")
        {
            Clustered = true;
        }
    }
    var
        UnderwritingMgt: Codeunit "Underwriting Risk Engine";

    trigger OnModify()
    var
        myInt: Integer;
    begin

    end;

    trigger OnDelete()
    var
        myInt: Integer;
    begin
        UnderwritingMgt.DeleteLines(Rec);
    end;
}
