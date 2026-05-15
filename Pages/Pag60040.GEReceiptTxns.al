namespace MortgageForUS.MortgageForUS;

page 60040 "GE Receipt Txns"
{
    PageType = List;
    SourceTable = "GE Receipt Txn Header";
    ApplicationArea = All;
    Caption = 'Loan Receipt Transactions';
    CardPageId = "GE Receipt Txn Card";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Txn No."; Rec."Txn No.") { }
                field("Loan No."; Rec."Loan No.") { }
                field("Posting Date"; Rec."Posting Date") { }
                field("External Reference"; Rec."External Reference") { }
                field("Total Amount"; Rec."Total Amount") { }
                field("Penalty Portion"; Rec."Penalty Portion") { }
                field("Interest Portion"; Rec."Interest Portion") { }
                field("Principal Portion"; Rec."Principal Portion") { }
                field("Escrow Portion"; Rec."Escrow Portion") { }
                field(Status; Rec.Status) { }
                field("GL Document No."; Rec."GL Document No.") { }
                field("Last Error"; Rec."Last Error") { }
            }
        }
    }

    actions
    {
        // area(processing)
        // {
        //     action(OpenCard)
        //     {
        //         Caption = 'Open';
        //         ApplicationArea = All;
        //         Image = EditLines;
        //         trigger OnAction()
        //         var
        //             Card: Page "GE Receipt Txn Card";
        //         begin
        //             Card.SetRecord(Rec);
        //             Card.RunModal();
        //         end;
        //     }
        // }
    }
}
