namespace Mortgage.Mortgage;

page 60004 "US Mortgage Setup"
{
    PageType = Card;
    SourceTable = "US Mortgage Posting Setup";
    ApplicationArea = All;
    Caption = 'US Mortgage Setup';
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Primary Key"; Rec."Primary Key") { }
                field("Gen. Jnl. Template"; Rec."Gen. Jnl. Template") { }
                field("Gen. Jnl. Batch"; Rec."Gen. Jnl. Batch") { }

                field("Accrual Jnl. Template"; Rec."Accrual Jnl. Template") { }
                field("Accrual Jnl. Batch"; Rec."Accrual Jnl. Batch") { }

                field("Default Bank Account No."; Rec."Default Bank Account No.") { }
                field("Shortcut Dim. 1 Code"; Rec."Shortcut Dim. 1 Code") { }
                field("Shortcut Dim. 2 Code"; Rec."Shortcut Dim. 2 Code") { }
            }
            // group("Posting Groups")
            // {
            //     field("Loan Principal Receivable"; Rec."Loan Principal Receivable") { ApplicationArea = all; }
            //     field("Interest Income"; Rec."Interest Income") { ApplicationArea = all; }
            //     field("Interest Receivable"; Rec."Interest Receivable") { ApplicationArea = all; }
            //     field("Penalty Income"; Rec."Penalty Income") { ApplicationArea = all; }
            // }
            group(SetUp)
            {
                //field("Mortgage Type"; Rec."Mortgage Type") { }
                field("LTV Calulation by"; Rec."LTV Calulation by")
                {

                }
                field("Penalty Method"; Rec."Penalty Method")
                {

                }
                field("Penalty Percent/Amount"; Rec."Penalty Percent/Amount") { }
            }
            group("No. Series")
            {
                field("Application No. Series"; Rec."Application No. Series") { }
                field("Commitment No. Series"; Rec."Commitment No. Series") { }
                field("Loan No. Series"; Rec."Loan No. Series") { }
                field("Assessment No."; Rec."Assessment No.")
                {

                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('SETUP') then begin
            Rec.Init();
            Rec."Primary Key" := 'SETUP';
            Rec.Insert(true);
        end;
        // if not Rec.Get() then begin
        //     Rec.Init();
        //     Rec.Insert(true);
        // end;
    end;
}

