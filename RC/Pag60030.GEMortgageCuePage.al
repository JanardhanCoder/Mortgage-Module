namespace MortgageForUS.MortgageForUS;
using Mortgage.Mortgage;

page 60030 "GE Mortgage Cue Page"
{
    PageType = CardPart;
    SourceTable = "GE Mortgage Cue";
    Caption = 'Mortgage KPIs';

    layout
    {
        area(content)
        {
            cuegroup("Loan Origination")
            {
                Caption = 'Loan Applications';
                field("Approved Applications"; Rec."Approved Applications")
                {
                    ApplicationArea = all;
                    DrillDownPageId = "US Loan Applications";
                }
                field("Pending Approval"; Rec."Pending Approval")
                {
                    ApplicationArea = all;
                    DrillDownPageId = "US Loan Applications";
                }

            }

            cuegroup("Active & Loans")
            {
                Caption = 'Loans';
                field("Active Loans"; Rec."Active Loans")
                {
                    ApplicationArea = all;
                    DrillDownPageId = "GE Loans";
                }
                field("Closed Loans"; Rec."Closed Loans")
                {
                    ApplicationArea = all;
                    DrillDownPageId = "GE Loans";
                }
                field("Draft Loans"; Rec."Draft Loans")
                {
                    ApplicationArea = all;
                    DrillDownPageId = "GE Loans";
                }
                field("Total Outstanding Principal"; Rec."Total Outstanding Principal")
                {
                    ApplicationArea = all;
                }
            }

        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('CUES') then begin
            Rec.Init();
            Rec."Primary Key" := 'CUES';
            Rec.Insert();
        end;
    end;

    trigger OnAfterGetRecord()
    var
        myInt: Integer;
    begin
        Rec."Total Outstanding Principal" := Rec.TotalValueofLoans();
    end;
}

