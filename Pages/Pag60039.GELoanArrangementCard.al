// page 60039 "GE Loan Arrangement Card"
// {
//     PageType = Card;
//     ApplicationArea = All;
//     SourceTable = "GE Loan Arrangement Header";
//     Caption = 'Loan Arrangement';

//     layout
//     {
//         area(content)
//         {
//             group(General)
//             {
//                 field("No."; Rec."No.")
//                 {
//                     Editable = false;
//                 }

//                 field("Loan No."; Rec."Loan No.") { }
//                 field("Arrangement Type"; Rec."Arrangement Type") { }
//                 field(Status; Rec.Status)
//                 {
//                     Editable = false;
//                 }

//                 field("Effective Date"; Rec."Effective Date") { }
//                 field("Reason Code"; Rec."Reason Code") { }
//                 field(Notes; Rec.Notes) { }
//             }

//             group("Promise to Pay")
//             {
//                 Visible = Rec."Arrangement Type" =
//                     Enum::"GE Loan Arrangement Type"::PTP;

//                 field("PTP Date"; Rec."PTP Date") { }
//                 field("PTP Amount"; Rec."PTP Amount") { }
//                 field("PTP Follow-up Date"; Rec."PTP Follow-up Date") { }
//                 field("PTP Outcome"; Rec."PTP Outcome") { }
//             }

//             group(Waiver)
//             {
//                 Visible = Rec."Arrangement Type" =
//                     Enum::"GE Loan Arrangement Type"::Waiver;

//                 field("Waive Penalty Amount"; Rec."Waive Penalty Amount") { }
//                 field("Waive Fee Amount"; Rec."Waive Fee Amount") { }
//                 field("Waiver Posted"; Rec."Waiver Posted")
//                 {
//                     Editable = false;
//                 }
//                 field("Waiver Doc No."; Rec."Waiver Doc No.")
//                 {
//                     Editable = false;
//                 }
//             }

//             group(Restructure)
//             {
//                 Visible = Rec."Arrangement Type" =
//                     Enum::"GE Loan Arrangement Type"::Restructure;

//                 field("Restructure Type"; Rec."Restructure Type") { }
//                 field("New Interest Rate %"; Rec."New Interest Rate %") { }
//                 field("New Tenor (Months)"; Rec."New Tenor (Months)") { }
//                 field("Capitalise Amount"; Rec."Capitalise Amount") { }

//                 field("Old Maturity Date"; Rec."Old Maturity Date")
//                 {
//                     Editable = false;
//                 }
//                 field("New Maturity Date"; Rec."New Maturity Date")
//                 {
//                     Editable = false;
//                 }
//                 field("Restructure Applied"; Rec."Restructure Applied")
//                 {
//                     Editable = false;
//                 }
//             }
//         }
//     }

//     actions
//     {
//         area(processing)
//         {
//             action(Submit)
//             {
//                 Caption = 'Submit';
//                 Image = SendApprovalRequest;

//                 trigger OnAction()
//                 begin
//                     if Rec.Status <> Enum::"GE Loan Arrangement Status"::Open then
//                         Error('Only Open arrangements can be submitted.');

//                     Rec.Status := Enum::"GE Loan Arrangement Status"::Submitted;
//                     Rec.Modify(true);
//                 end;
//             }

//             action(Approve)
//             {
//                 Caption = 'Approve';
//                 Image = Approve;

//                 trigger OnAction()
//                 begin
//                     if Rec.Status <> Enum::"GE Loan Arrangement Status"::Submitted then
//                         Error('Only Submitted arrangements can be approved.');

//                     Rec.Status := Enum::"GE Loan Arrangement Status"::Approved;
//                     Rec.Modify(true);
//                 end;
//             }

//             action(Execute)
//             {
//                 Caption = 'Execute';
//                 Image = Post;

//                 trigger OnAction()
//                 begin
//                     if Rec.Status <> Enum::"GE Loan Arrangement Status"::Approved then
//                         Error('Only Approved arrangements can be executed.');

//                     // Call execution logic here
//                     // ArrangementMgt.Execute(Rec);

//                     Rec.Status := Enum::"GE Loan Arrangement Status"::Executed;
//                     Rec.Modify(true);
//                 end;
//             }
//         }
//     }
// }


page 60039 "GE Loan Arrangement Card"
{
    PageType = Card;
    SourceTable = "GE Loan Arrangement Header";
    ApplicationArea = All;
    Caption = 'Loan Arrangement';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.") { }
                field("Loan No."; Rec."Loan No.") { }
                field("Arrangement Type"; Rec."Arrangement Type") { }
                field(Status; Rec.Status) { }
                field("Effective Date"; Rec."Effective Date") { }
                field("Reason Code"; Rec."Reason Code") { }
                field(Notes; Rec.Notes) { }
            }

            group(PTP)
            {
                Visible = (Rec."Arrangement Type" = Rec."Arrangement Type"::PTP);
                field("PTP Date"; Rec."PTP Date") { }
                field("PTP Amount"; Rec."PTP Amount") { }
                field("PTP Follow-up Date"; Rec."PTP Follow-up Date") { }
                field("PTP Outcome"; Rec."PTP Outcome") { }
            }

            group(Waiver)
            {
                Visible = (Rec."Arrangement Type" = Rec."Arrangement Type"::Waiver);
                field("Waive Penalty Amount"; Rec."Waive Penalty Amount") { }
                field("Waive Fee Amount"; Rec."Waive Fee Amount") { }
                field("Waiver Posted"; Rec."Waiver Posted") { Editable = false; }
                field("Waiver Doc No."; Rec."Waiver Doc No.") { Editable = false; }
            }

            group(Restructure)
            {
                Visible = (Rec."Arrangement Type" = Rec."Arrangement Type"::Restructure);
                field("Restructure Type"; Rec."Restructure Type") { }
                field("New Interest Rate %"; Rec."New Interest Rate Code") { }
                field("New Tenor (Months)"; Rec."New Tenor (Months)") { }
                field("Capitalise Amount"; Rec."Capitalise Amount") { }
                field("Restructure Applied"; Rec."Restructure Applied") { Editable = true; }
                field("Old Maturity Date"; Rec."Old Maturity Date") { Editable = false; }
                field("New Maturity Date"; Rec."New Maturity Date") { Editable = false; }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Submit)
            {
                Caption = 'Submit';
                ApplicationArea = All;
                Image = SendTo;
                trigger OnAction()
                var CU: Codeunit "GE Collections Mgt";
                begin
                    CU.SubmitArrangement(Rec."No.");
                    CurrPage.Update();
                end;
            }

            action(Approve)
            {
                Caption = 'Approve';
                ApplicationArea = All;
                Image = Approve;
                trigger OnAction()
                var CU: Codeunit "GE Collections Mgt";
                begin
                    CU.ApproveArrangement(Rec."No.");
                    CurrPage.Update();
                end;
            }

            action(ActivatePTP)
            {
                Caption = 'Activate PTP';
                ApplicationArea = All;
                Image = Start;
                Visible = true;
                trigger OnAction()
                var CU: Codeunit "GE Collections Mgt";
                begin
                    CU.ActivatePTP(Rec."No.");
                    CurrPage.Update();
                end;
            }

            action(ApplyWaiver)
            {
                Caption = 'Apply Waiver (Post)';
                ApplicationArea = All;
                Image = Post;
                trigger OnAction()
                var CU: Codeunit "GE Collections Mgt";
                begin
                    CU.ApplyWaiver(Rec."No.", Today);
                    CurrPage.Update();
                end;
            }

            action(ApplyRestructure)
            {
                Caption = 'Apply Restructure';
                ApplicationArea = All;
                Image = Calculate;
                trigger OnAction()
                var CU: Codeunit "GE Collections Mgt";
                begin
                    CU.ApplyRestructure(Rec."No.");
                    CurrPage.Update();
                end;
            }
        }
    }

    procedure CreateForLoan(LoanNo: Code[20]; ArrType: Enum "GE Loan Arrangement Type")
    begin
        Rec.Init();
        Rec."No." := Format(CreateGuid());
        Rec."Loan No." := LoanNo;
        Rec."Arrangement Type" := ArrType;
        Rec.Status := Rec.Status::Open;
        Rec."Effective Date" := Today;
        Rec.Insert(true);
    end;
}
