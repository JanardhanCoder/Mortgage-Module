namespace MortgageForUS.MortgageForUS;
using Mortgage.Mortgage;

page 60049 "Commitment Aggrement Card"
{
    ApplicationArea = All;
    Caption = 'Commitment Aggrement Card';
    PageType = Card;
    SourceTable = "US Commitment Header";
    PromotedActionCategories = 'New,Process,Navigate,Release,Request Approval,Approve,Commitment';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Commitment No."; Rec."Commitment No.")
                {
                    ToolTip = 'Specifies the value of the Commitment No. field.', Comment = '%';
                }
                field("Application No."; Rec."Application No.")
                {
                    ToolTip = 'Specifies the value of the Application No. field.', Comment = '%';
                }
                field("Agent Contact No."; Rec."Agent Contact No.")
                {
                    ToolTip = 'Specifies the value of the Agent Contact No. field.', Comment = '%';
                }
                field("Borrower Customer No."; Rec."Borrower Customer No.")
                {
                    ToolTip = 'Specifies the value of the Borrower Customer No. field.', Comment = '%';
                }
                field("Approved Rate %"; Rec."Approved Rate %")
                {
                    ToolTip = 'Specifies the value of the Approved Rate % field.', Comment = '%';
                }
                field("Approved Tenor (Months)"; Rec."Approved Tenor (Months)")
                {
                    ToolTip = 'Specifies the value of the Approved Tenor (Months) field.', Comment = '%';
                }
                field("Accepted Date"; Rec."Accepted Date")
                {
                    ToolTip = 'Specifies the value of the Accepted Date field.', Comment = '%';
                }
                field("Approved Amount"; Rec."Approved Amount")
                {
                    ToolTip = 'Specifies the value of the Approved Amount field.', Comment = '%';
                }
                field("Commitment Date"; Rec."Commitment Date")
                {
                    ToolTip = 'Specifies the value of the Commitment Date field.', Comment = '%';
                }
                field("Conditions Summary"; Rec."Conditions Summary")
                {
                    ToolTip = 'Specifies the value of the Conditions Summary field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {

            action(Issue)
            {
                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::Issued;
                    Rec.Modify();
                end;
            }
            action(Accept)
            {
                Caption = 'Accept';
                trigger OnAction()
                //var
                //mgnt: Codeunit "US Origination Mgt";
                begin
                    //mgnt.UpdateLoanApplicationApproved(Rec);
                    Rec.Status := Rec.Status::Accepted;
                    Rec.Modify();
                end;
            }
        }
    }
}
