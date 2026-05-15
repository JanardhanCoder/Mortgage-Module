namespace MortgageForUS.MortgageForUS;
using Mortgage.Mortgage;

page 60045 "Underwriting Assessment Card"
{
    ApplicationArea = All;
    Caption = 'Underwriting Assessment Card';
    PageType = Card;
    SourceTable = "Underwriting Assessment";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Assessment No."; Rec."Assessment No.")
                {
                    ToolTip = 'Specifies the value of the Assessment No. field.', Comment = '%';
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Application No."; Rec."Application No.")
                {
                    ToolTip = 'Specifies the value of the Application No. field.', Comment = '%';
                    Editable = Rec."Is Final Assessment" = false;
                }
                field("Assessment Date"; Rec."Assessment Date")
                {
                    Editable = Rec."Is Final Assessment" = false;
                    ToolTip = 'Specifies the value of the Assessment Date field.', Comment = '%';
                }
                field("Assessment Type"; Rec."Assessment Type")
                {
                    Editable = Rec."Is Final Assessment" = false;
                    ToolTip = 'Specifies the value of the Assessment Type field.', Comment = '%';
                }
                field("Property Price"; Rec."Property Price")
                {
                    ToolTip = 'Specifies the value of the Property Price field.', Comment = '%';
                    Editable = false;
                }
                field("Market Value"; Rec."Market Value")
                {
                    Editable = Rec."Is Final Assessment" = false;
                    ToolTip = 'Specifies the value of the Market Value field.', Comment = '%';
                }
                field("Down Payment"; Rec."Down Payment")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Down Payment field.', Comment = '%';
                }
                field("Requested Loan Amount"; Rec."Requested Loan Amount")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Requested Loan Amount field.', Comment = '%';
                }
                field("Proposed EMI"; Rec."Proposed EMI")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Proposed EMI field.', Comment = '%';
                }

                field("Overall Risk"; Rec."Overall Risk")
                {
                    ToolTip = 'Specifies the value of the Overall Risk field.', Comment = '%';
                    Editable = false;
                    StyleExpr = OverallRisk;
                }

                field("Underwriter User ID"; Rec."Underwriter User ID")
                {
                    Editable = Rec."Is Final Assessment" = false;
                    ToolTip = 'Specifies the value of the Underwriter User ID field.', Comment = '%';
                }
                field("Assessment Version"; Rec."Assessment Version")
                {
                    ToolTip = 'Specifies the value of the Assessment Version field.', Comment = '%';
                    Editable = false;
                }

                field("Is Final Assessment"; Rec."Is Final Assessment")
                {
                    ToolTip = 'Specifies the value of the Is Final Assessment field.', Comment = '%';
                    Editable = false;
                }
                field(Decision; Rec.Decision)
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Decision field.', Comment = '%';
                }
                field("Decision Comment"; Rec."Decision Comment")
                {
                    ToolTip = 'Specifies the value of the Decision Comment field.', Comment = '%';
                    MultiLine = true;
                }
            }
            group(IncomeAnalysis)
            {
                Caption = 'Income Analysis';
                field("Monthly Income"; Rec."Monthly Income")
                {
                    ToolTip = 'Specifies the value of the Monthly Income field.', Comment = '%';
                    Editable = false;
                }
                field("DTI %"; Rec."DTI %")
                {
                    ToolTip = 'Specifies the value of the DTI % field.', Comment = '%';
                    Editable = false;
                    Importance = Promoted;
                }
                field("Income Risk"; Rec."Income Risk")
                {
                    ToolTip = 'Specifies the value of the Income Risk field.', Comment = '%';
                    StyleExpr = IncomeRisk;
                    Editable = false;
                    Importance = Promoted;
                }
            }
            group(creditAnalysis)
            {
                Caption = 'Credit Analysis';
                field("Credit Score"; Rec."Credit Score")
                {
                    Editable = Rec."Is Final Assessment" = false;
                    ToolTip = 'Specifies the value of the Credit Score field.', Comment = '%';
                    Importance = Promoted;
                }
                field("Credit Risk"; Rec."Credit Risk")
                {
                    ToolTip = 'Specifies the value of the Credit Risk field.', Comment = '%';
                    StyleExpr = CreditRisk;
                    Editable = false;
                    Importance = Promoted;
                }
            }
            group(FOIRAnalysis)
            {
                Caption = 'FOIR Analysis';
                field("Total Monthly EMIs"; Rec."Total Monthly EMIs")
                {
                    Editable = false;
                }
                field("FOIR %"; Rec."FOIR %")
                {
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the FOIR % field.', Comment = '%';
                }
                field("FOIR Risk"; Rec."FOIR Risk")
                {
                    Editable = false;
                    Importance = Promoted;
                    StyleExpr = FOIRRisk;
                    ToolTip = 'Specifies the value of the FOIR Risk field.', Comment = '%';
                }
            }
            group(CollateralAnalysis)
            {
                Caption = 'Collateral Analysis';
                field("LTV %"; Rec."LTV %")
                {
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the LTV % field.', Comment = '%';
                }
                field("Collateral Risk"; Rec."Collateral Risk")
                {
                    Editable = false;
                    Importance = Promoted;
                    StyleExpr = CollateralRisk;
                    ToolTip = 'Specifies the value of the Collateral Risk field.', Comment = '%';
                }
            }
            part(Income; IncomeLines)
            {
                SubPageLink = "Assessment No." = field("Assessment No.");
                Editable = Rec."Is Final Assessment" = false;
            }
            part(Lines; "EMI LINES")
            {
                SubPageLink = "Application No." = field("Assessment No.");
                Editable = Rec."Is Final Assessment" = false;
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(CalculateRisk)
            {
                Caption = 'Calculate Risk';
                Image = Calculate;
                trigger OnAction()
                var
                    Risk: Codeunit "Underwriting Risk Engine";
                begin
                    Risk.CalculateRisk(Rec);
                    Rec."Assessment Type" := Rec."Assessment Type"::Final;
                    Rec."Is Final Assessment" := true;
                end;
            }
            action(Approve)
            {
                Caption = 'Approve';
                Image = Approve;
                trigger OnAction()
                var
                    App: Record "US Loan Application Header";
                begin
                    Rec.Decision := Rec.Decision::Approved;
                    App.SetRange("No.", Rec."Application No.");
                    if App.FindFirst() then begin
                        App.Status := App.Status::Approved;
                        App.Decision := App.Decision::Approved;
                        App."Approved Amount" := App."Requested Amount";
                        App."Current Interest %" := App."Proposed Rate %";
                        App."Approved Tenor (Months)" := App."Requested Tenor (Months)";
                        App.Modify();
                        Message('Loan Application approved sucessfully');
                    end;
                end;
            }
        }
    }

    // trigger OnModifyRecord(): Boolean
    // var
    //     UnderwritingMgt: Codeunit "Underwriting Risk Engine";
    // begin
    //     Rec."Monthly Income" := UnderwritingMgt.MonthlyIncome(Rec);
    //     //Message('Income Updated-%1', Rec."Monthly Income");
    // end;
    var
        IncomeRisk: Text;
        CreditRisk: Text;
        FOIRRisk: Text;
        CollateralRisk: Text;
        OverallRisk: Text;

    trigger OnAfterGetRecord()
    var
        myInt: Integer;
        workflow: Codeunit "Workflow Events";
    begin
        case Rec."Income Risk" of
            "Risk Level"::Low:
                IncomeRisk := 'Favorable';
            "Risk Level"::Medium:
                IncomeRisk := 'Ambiguous';
            "Risk Level"::High:
                IncomeRisk := 'Unfavorable';
        end;
        case Rec."Credit Risk" of
            "Risk Level"::Low:
                CreditRisk := 'Favorable';
            "Risk Level"::Medium:
                CreditRisk := 'Ambiguous';
            "Risk Level"::High:
                CreditRisk := 'Unfavorable';
        end;
        case Rec."FOIR Risk" of
            "Risk Level"::Low:
                FOIRRisk := 'Favorable';
            "Risk Level"::Medium:
                FOIRRisk := 'Ambiguous';
            "Risk Level"::High:
                FOIRRisk := 'Unfavorable';
        end;
        case Rec."Collateral Risk" of
            "Risk Level"::Low:
                CollateralRisk := 'Favorable';
            "Risk Level"::Medium:
                CollateralRisk := 'Ambiguous';
            "Risk Level"::High:
                CollateralRisk := 'Unfavorable';
        end;
        case Rec."Overall Risk" of
            "Risk Level"::Low:
                OverallRisk := 'Favorable';
            "Risk Level"::Medium:
                OverallRisk := 'Ambiguous';
            "Risk Level"::High:
                OverallRisk := 'Unfavorable';
        end;
    end;
}

