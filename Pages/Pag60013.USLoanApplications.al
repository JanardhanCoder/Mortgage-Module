namespace Mortgage.Mortgage;
using MortgageForUS.MortgageForUS;
using System.Utilities;
using System.IO;

page 60013 "US Loan Applications"
{
    PageType = List;
    SourceTable = "US Loan Application Header";
    ApplicationArea = All;
    CardPageId = "GE Loan Application Card";
    Caption = 'Loan Applications';
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {

                }
                field("Application Date"; Rec."Application Date") { }
                field("Borrower Contact No."; Rec."Borrower Contact No.") { }
                field("Source Type"; Rec."Source Type") { }
                field("Agent Contact No."; Rec."Agent Contact No.") { }
                field("Product Code"; Rec."Product Code") { }
                field("Requested Amount"; Rec."Requested Amount") { }
                field(Status; Rec.Status) { }
                field(Decision; Rec.Decision) { }
                field("Created Commitment No."; Rec."Created Commitment No.") { }
                field("Created Loan No."; Rec."Created Loan No.") { }
            }
        }
    }
}

page 60014 "GE Loan Application Card"
{
    PageType = Card;
    SourceTable = "US Loan Application Header";
    ApplicationArea = All;
    Caption = 'Loan Application';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    trigger OnAssistEdit()
                    var
                        myInt: Integer;
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Application Date"; Rec."Application Date") { }
                field("Source Type"; Rec."Source Type") { }
                field("Borrower Contact No."; Rec."Borrower Contact No.") { }
                field("Agent Contact No."; Rec."Agent Contact No.") { }
                field("Relationship Manager"; Rec."Relationship Manager") { }
                field("Borrower Customer No."; Rec."Borrower Customer No.") { }
                field(Status; Rec.Status) { Editable = false; }
            }
            group("Requested Terms")
            {
                field("Product Code"; Rec."Product Code") { }
                field("Requested Amount"; Rec."Requested Amount") { }
                field("Requested Tenor (Months)"; Rec."Requested Tenor (Months)") { }
                field("Rate Preference"; Rec."Rate Preference") { }
                field("Rate Code"; Rec."Rate Code") { }
                field("Proposed Rate %"; Rec."Proposed Rate %") { }
                field(Purpose; Rec.Purpose) { }
                field(Propety; Rec.Propety) { }
                field(Type; Rec.Type) { }
                field("Purpose Description"; Rec."Purpose Description") { }
                field("Purchase Price"; Rec."Purchase Price")
                { }
                field("Down Payment"; Rec."Down Payment")
                { }
            }
            group(Decision)
            {
                field(Decisions; Rec.Decision) { Editable = false; }
                field("Approved Amount"; Rec."Approved Amount") { }
                field("Approved Tenor (Months)"; Rec."Approved Tenor (Months)") { }
                field("Approved Rate Preference"; Rec."Rate Preference") { }
                field("Approved Rate Code"; Rec."Rate Code")
                {
                    trigger OnValidate()
                    var
                        RateMgmt: Codeunit "Interest Rate Management";
                    begin
                        Rec."Current Interest %" := RateMgmt.GetCurrentInterestRate(Rec."Rate Code", Rec."Spread %", WorkDate);
                    end;
                }
                field("Approved Current Interest %"; Rec."Current Interest %") { }
                // field("Approved Rate %"; Rec."Approved Rate %") { }
                field("Offer Expiry Date"; Rec."Offer Expiry Date") { }
                field("Created Commitment No."; Rec."Created Commitment No.") { Editable = false; }
                field("Created Loan No."; Rec."Created Loan No.") { Editable = false; }
            }

            // part(Collaterals; "US App Collateral Subpage")
            // {
            //     SubPageLink = "Application No." = field("No.");
            // }

            part(Documents; "US App Document Subpage")
            {
                SubPageLink = "Application No." = field("No.");
            }
        }
    }

    actions
    {
        area(processing)
        {

            action(SubmitApplication)
            {
                Caption = 'Submit';
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Visible = Rec.Status = Rec.Status::Open;

                trigger OnAction()
                begin
                    // ---------------- VALIDATIONS ----------------
                    Rec.TestField("Borrower Customer No.");
                    Rec.TestField("Requested Amount");
                    Rec.TestField("Requested Tenor (Months)");
                    // Rec.TestField("Rate Preference");

                    if Rec.Status <> Rec.Status::Open then
                        Error('Only Open applications can be submitted.');

                    if not Confirm('Do you want to submit this loan application?', false) then
                        exit;


                    // ---------------- STATUS UPDATE ----------------
                    Rec.Status := Rec.Status::Submitted;
                    Rec."Application Date" := Today;

                    Rec.Modify(true);

                    Message('Loan Application %1 has been submitted successfully.', Rec."No.");
                end;
            }
            action(CheckDocuments)
            {
                Caption = 'Check Documents';
                Image = Check;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                Enabled = Rec.Status = Rec.Status::Submitted;
                Visible = Rec.Status = Rec.Status::Submitted;

                trigger OnAction()
                var
                    DocLine: Record "US Loan App Document Line";
                    MissingDocs: Boolean;
                begin
                    if Rec.Status <> Rec.Status::Submitted then
                        Error('Documents can be checked only after submission.');

                    // ---------------- CHECK DOCUMENTS ----------------
                    MissingDocs := false;

                    DocLine.SetRange("Application No.", Rec."No.");

                    if DocLine.FindSet() then begin
                        repeat
                            if not DocLine.Received then begin
                                MissingDocs := true;
                                break;
                            end;
                        until DocLine.Next() = 0;
                    end else
                        MissingDocs := true; // No document lines at all

                    // ---------------- STATUS UPDATE ----------------
                    if MissingDocs then
                        Rec.Status := Rec.Status::"Docs Pending"
                    else begin
                        Rec.Status := Rec.Status::"Docs Verified";
                        // Rec."Docs Verified Date" := Today;
                    end;

                    Rec.Modify(true);

                    Message('Document verification completed for Application %1.', Rec."No.");
                end;
            }
            action(VerifyDocuments)
            {
                Caption = 'Verify Documents';
                Image = Approval;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                Enabled = Rec.Status = Rec.Status::"Docs Pending";
                Visible = Rec.Status = Rec.Status::"Docs Pending";

                trigger OnAction()
                var
                    DocLine: Record "US Loan App Document Line";
                    MissingDocs: Boolean;
                begin
                    if Rec.Status <> Rec.Status::"Docs Pending" then
                        Error('Document verification allowed only in Docs Pending status.');

                    MissingDocs := false;

                    DocLine.SetRange("Application No.", Rec."No.");

                    if DocLine.FindSet() then begin
                        repeat
                            if not DocLine.Received then begin
                                MissingDocs := true;
                                break;
                            end;
                        until DocLine.Next() = 0;
                    end else
                        MissingDocs := true;

                    if MissingDocs then
                        Error('Some mandatory documents are still missing.');

                    // ---------------- STATUS UPDATE ----------------
                    Rec.Status := Rec.Status::"Docs Verified";
                    // Rec."Docs Verified Date" := Today;

                    Rec.Modify(true);

                    Message('All documents verified. Application moved to Docs Verified.');
                end;
            }

            action(CreateUnderWriting)
            {
                Caption = 'Create UnderWriting Assessment';
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                Enabled = Rec.Status = Rec.Status::"Docs Verified";
                Visible = Rec.Status = Rec.Status::"Docs Verified";
                trigger OnAction()
                var
                    AssessmentMgnt: Codeunit "Underwriting Risk Engine";
                begin
                    AssessmentMgnt.CreateUnderWritingAssmt(Rec);
                end;
            }

            // action(CreditCheck)
            // {
            //     Caption = 'Credit Check';
            //     Image = CreditCard;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     ApplicationArea = All;

            //     Enabled = Rec.Status = Rec.Status::"Docs Verified";
            //     Visible = Rec.Status = Rec.Status::"Docs Verified";

            //     trigger OnAction()
            //     var
            //         CreditScore: Integer;
            //         LoanAppFinancial: Record "Loan Applicant Financials";
            //         "Rejection Reason": Text[100];
            //     begin
            //         if Rec.Status <> Rec.Status::"Docs Verified" then
            //             Error('Credit check can be performed only after document verification.');

            //         LoanAppFinancial.SetRange("Application No.", Rec."No.");

            //         if LoanAppFinancial.FindFirst() then begin


            //             // ---------------- CREDIT LOGIC ----------------
            //             CreditScore := LoanAppFinancial."Credit Score"; // assume field exists

            //             if CreditScore = 0 then
            //                 Error('Credit score is not available.');

            //             if CreditScore < 650 then begin
            //                 Rec.Status := Rec.Status::Rejected;
            //                 "Rejection Reason" := 'Credit score below eligibility criteria';
            //             end else begin
            //                 Rec.Status := Rec.Status::"Credit Check";
            //                 //Rec."Credit Checked Date" := Today;
            //             end;
            //         end;
            //         Rec.Modify(true);

            //         Message('Credit check completed for Application %1.', Rec."No.");
            //     end;
            // }
            // action(RecordValuation)
            // {
            //     Caption = 'Record Valuation';
            //     Image = Calculate;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     ApplicationArea = All;
            //     Enabled = Rec.Status = Rec.Status::"Credit Check";
            //     Visible = Rec.Status = Rec.Status::"Credit Check";

            //     trigger OnAction()
            //     var
            //         Collateral: Record "US Loan App Collateral Line";
            //     begin
            //         if Rec.Status <> Rec.Status::"Credit Check" then
            //             Error('Valuation can be recorded only after credit check.');

            //         Collateral.SetRange("Application No.", Rec."No.");
            //         if Collateral.FindSet() then begin
            //             // ---------------- VALIDATIONS ----------------
            //             Collateral.TestField("Purchase Price");
            //             Collateral.TestField("Proposed Loan Amount");


            //             // ---------------- STATUS UPDATE ----------------
            //             Rec.Status := Rec.Status::"Valuation Pending";
            //             //Rec."Valuation Completed Date" := Today;

            //         end;

            //         Rec.Modify(true);
            //         Message('Valuation recorded successfully for Application %1.', Rec."No.");
            //     end;
            // }

            // action(UnderwritingDecision)
            // {
            //     Caption = 'Underwriting Decision';
            //     Image = Approvals;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     ApplicationArea = All;

            //     Enabled = Rec.Status = Rec.Status::"Docs Verified";
            //     Visible = Rec.Status = Rec.Status::"Docs Verified";
            //     trigger OnAction()
            //     var
            //         FOIR: Decimal;
            //         LTV: Decimal;
            //         UnderWriting: Codeunit "Loan Underwriting Mgt";
            //     begin
            //         // if Rec.Status <> Rec.Status::Underwriting then
            //         //     Error('Underwriting can be performed only in Underwriting status.');
            //         //UnderWriting.EvaluateApplication(Rec."No.");

            //         // Rec."Underwriting Date" := Today;
            //         Rec.Modify(true);

            //         Message('Underwriting decision completed for Application %1.', Rec."No.");
            //     end;
            // }


            action(IssueCommitment)
            {
                Caption = 'Issue Commitment';
                ApplicationArea = All;
                Image = Approve;

                trigger OnAction()
                var
                    Mgt: Codeunit "US Origination Mgt";
                    No: Code[20];
                    Aggrement: Record "US Commitment Header";
                begin
                    No := Mgt.IssueCommitmentFromApplication(Rec."No.");
                    Aggrement.SetRange("Commitment No.", No);
                    if Aggrement.FindFirst() then
                        if Dialog.Confirm('Commitment issued.Do you want to open?', true) then
                            Page.Run(Page::"Commitment Aggrement Card", Aggrement);

                    CurrPage.Update();
                end;
            }
            action(Commitments)
            {
                Image = List;
                RunObject = page "US Commitments";
                RunPageLink = "Application No." = field("No.");
            }
            action(CreateLoan)
            {
                Caption = 'Create Loan (Agreement)';
                ApplicationArea = All;
                Image = Create;

                trigger OnAction()
                var
                    Mgt: Codeunit "US Origination Mgt";
                    LoanNo: Code[20];
                begin
                    LoanNo := Mgt.CreateLoanFromCommitment(Rec."Created Commitment No.");
                    Message('Loan %1 created.', LoanNo);
                    CurrPage.Update();
                end;
            }
            action(CancelApplication)
            {
                Caption = 'Cancel Application';
                Image = Cancel;
                Promoted = true;

                //Enabled = Rec.Status(Rec.Status::"Docs Pending", Rec.Status::Submitted);
                //Enabled = (Rec.Status = Rec.Status::"Docs Pending") or (Rec.Status = Rec.Status::Submitted);
                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::Cancelled;
                    Rec.Modify(true);
                end;
            }
            action("Loan Applicant Financials")
            {
                Caption = 'Loan Applicant Financials';
                ApplicationArea = All;
                Image = Ledger;
                RunObject = page "Loan Applicant Financials";
                RunPageLink = "Application No." = field("No.");
            }
            action("US Collateral List")
            {
                Caption = 'Collaterals';
                ApplicationArea = All;
                Image = Ledger;
                RunObject = page "US Collateral List";
                RunPageLink = "Loan Application No." = field("No.");
            }
        }
    }
}

page 60015 "US App Collateral Subpage"
{
    PageType = ListPart;
    SourceTable = "US Loan App Collateral Line";
    ApplicationArea = All;
    Caption = 'Collaterals';

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Collateral No."; Rec."Collateral No.") { }
                field("Purchase Price"; Rec."Purchase Price") { }
                field("Down Payment"; Rec."Down Payment") { }
                field("Proposed Loan Amount"; Rec."Proposed Loan Amount") { }
                field("Lien Position Requested"; Rec."Lien Position Requested") { }
                field("LTV %"; Rec."LTV %") { }
                field(Notes; Rec.Notes) { }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        AppLine: Record "US Loan App Collateral Line";
    begin
        if Rec."Line No." = 0 then begin
            AppLine.SetRange("Application No.", Rec."Application No.");
            if AppLine.FindLast() then
                Rec."Line No." := AppLine."Line No." + 10000
            else
                Rec."Line No." := 10000;
        end;
    end;
}

page 60016 "US App Document Subpage"
{
    PageType = ListPart;
    SourceTable = "US Loan App Document Line";
    ApplicationArea = All;
    Caption = 'Documents';
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                Caption = 'Lines';
                field("Doc Type Code"; Rec."Doc Type Code") { }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the filename of the attachment.';

                    trigger OnDrillDown()
                    var
                        TempBlob: Codeunit "Temp Blob";
                        FileName: Text;
                    begin
                        if Rec."Document Reference ID".HasValue then
                            Rec.Export(true)
                        else begin
                            ImportWithFilter(TempBlob, FileName);
                            if FileName <> '' then
                                Rec.SaveAttachment(FromRecRef, FileName, TempBlob);
                            CurrPage.Update(false);
                            //Rec.Received := true;
                        end;
                    end;
                }
                field(Received; Rec.Received) { }
                field(Verified; Rec.Verified) { }
                field("Document Date"; Rec."Document Date") { }
                field("Expiry Date"; Rec."Expiry Date") { }
                field("File Link"; Rec."File Link") { }
                field(Remarks; Rec.Remarks) { }
            }
        }
    }
    local procedure ImportWithFilter(var TempBlob: Codeunit "Temp Blob"; var FileName: Text)
    var
        FileManagement: Codeunit "File Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;

        if IsHandled then
            exit;

        FileName := FileManagement.BLOBImportWithFilter(
            TempBlob, ImportTxt, FileName, StrSubstNo(FileDialogTxt, FilterTxt), FilterTxt);
    end;

    var
        FromRecRef: RecordRef;
        FileDialogTxt: Label 'Attachments (%1)|%1', Comment = '%1=file types, such as *.txt or *.docx';
        FilterTxt: Label '*.jpg;*.jpeg;*.bmp;*.png;*.gif;*.tiff;*.tif;*.pdf;*.docx;*.doc;*.xlsx;*.xls;*.pptx;*.ppt;*.msg;*.xml;*.*', Locked = true;
        ImportTxt: Label 'Attach a document.';
}

