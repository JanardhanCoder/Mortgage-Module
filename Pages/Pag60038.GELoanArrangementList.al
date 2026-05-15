namespace MortgageForUS.MortgageForUS;
page 60038 "GE Loan Arrangement List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GE Loan Arrangement Header";
    Caption = 'Loan Arrangements';
    CardPageId = "GE Loan Arrangement Card";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { }
                field("Loan No."; rec."Loan No.") { }
                field("Arrangement Type"; rec."Arrangement Type") { }
                field("Restructure Type"; rec."Restructure Type") { }
                field(Status; rec.Status) { }
                field("PTP Amount"; Rec."PTP Amount") { }
                field("PTP Date"; Rec."PTP Date") { }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ApplyArrangement)
            {
                Caption = 'Apply Arrangement';
                Image = Apply;

                trigger OnAction()
                var
                    ArrMgt: Codeunit "GE Loan Arrangement Mgt";
                begin
                    // UI only triggers execution
                    ArrMgt.Execute(Rec);
                end;
            }


        }
    }
}

