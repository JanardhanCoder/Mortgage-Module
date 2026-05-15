namespace MortgageForUS.MortgageForUS;

page 60041 "GE Receipt Txn Card"
{
    PageType = Card;
    SourceTable = "GE Receipt Txn Header";
    ApplicationArea = All;
    Caption = 'Receipt Transaction';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Txn No."; Rec."Txn No.") { Editable = false; }
                field("Loan No."; Rec."Loan No.") { Editable = false; }
                field("Posting Date"; Rec."Posting Date") { }
                field("Bank Account No."; Rec."Bank Account No.") { }
                field("External Reference"; Rec."External Reference") { Editable = false; }
                field("Total Amount"; Rec."Total Amount") { }
                field(Status; Rec.Status) { Editable = true; }
            }

            group(Allocation)
            {
                field("Penalty Portion"; Rec."Penalty Portion") { Editable = false; }
                field("Interest Portion"; Rec."Interest Portion") { Editable = false; }
                field("Principal Portion"; Rec."Principal Portion") { Editable = false; }
                field("Escrow Portion"; Rec."Escrow Portion") { Editable = false; }
            }

            group(Posting)
            {
                field("GL Document No."; Rec."GL Document No.") { Editable = false; }
                field("GL Posted At"; Rec."GL Posted At") { Editable = false; }
                field("Applied At"; Rec."Applied At") { Editable = false; }
                field("Last Error"; Rec."Last Error") { Editable = false; MultiLine = true; }
            }

            part(Lines; "GE Receipt Txn Alloc Lines")
            {
                SubPageLink = "Txn No." = field("Txn No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RebuildPlan)
            {
                Caption = 'Rebuild Allocation Plan';
                ApplicationArea = All;
                Image = SuggestLines;

                trigger OnAction()
                var
                    Planner: Codeunit "GE Allocation Planner";
                begin
                    if Rec.Status in [Rec.Status::"GL Posted", Rec.Status::Applied] then
                        Error('Cannot rebuild plan after GL is posted.');

                    Planner.BuildPlan(Rec."Loan No.", Rec."Posting Date", Rec."Txn No.", Rec."Total Amount",
                                      Rec."Penalty Portion", Rec."Interest Portion", Rec."Principal Portion", Rec."Escrow Portion");

                    Rec.Status := Rec.Status::Allocated;
                    Rec."Last Error" := '';
                    Rec.Modify(true);
                    CurrPage.Update();
                end;
            }

            action(Reapply)
            {
                Caption = 'Reapply Allocations';
                ApplicationArea = All;
                Image = ApplyEntries;

                trigger OnAction()
                var
                    Applier: Codeunit "GE Allocation Applier";
                begin
                    if Rec.Status <> Rec.Status::"GL Posted" then
                        Error('Reapply is only allowed when Status = GL Posted.');

                    Applier.ApplyTxn(Rec."Txn No.", Rec."External Reference", Rec."Posting Date");
                    CurrPage.Update();
                end;
            }

            action(SetToError)
            {
                Caption = 'Mark Error';
                ApplicationArea = All;
                Image = Cancel;
                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::Error;
                    Rec.Modify(true);
                    CurrPage.Update();
                end;
            }
        }
    }
}

