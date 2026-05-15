namespace MortgageForUS.MortgageForUS;

page 60037 "GE Bank Import Setup"
{
    PageType = Card;
    SourceTable = "GE Bank Import Setup";
    ApplicationArea = All;
    Caption = 'Bank Import Setup';
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Default Bank Account No."; Rec."Default Bank Account No.") { }
                field("Default Posting Date Rule"; Rec."Default Posting Date Rule") { }
                field("Auto-Post After Import"; Rec."Auto-Post After Import") { }
                field("Skip Non-Receipts"; Rec."Skip Non-Receipts") { }
                field("Min Amount"; Rec."Min Amount") { }
                field("Max Amount"; Rec."Max Amount") { }
            }
            group(Matching)
            {
                field("Match Priority 1"; Rec."Match Priority 1") { }
                field("Match Priority 2"; Rec."Match Priority 2") { }
                field("Match Priority 3"; Rec."Match Priority 3") { }
                field("Loan No Prefix"; Rec."Loan No Prefix") { }
                field("External Ref Prefix"; Rec."External Ref Prefix") { }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('SETUP') then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}

