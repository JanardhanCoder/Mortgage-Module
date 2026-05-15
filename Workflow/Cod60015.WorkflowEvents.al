namespace MortgageForUS.MortgageForUS;
using System.Automation;
using Microsoft.Utilities;
using Mortgage.Mortgage;

codeunit 60015 "Workflow Events"
{
    [IntegrationEvent(false, false)]
    procedure OnSendPurchReqForApproval(Req: Record "US Loan Application Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelPurchReqApprovalRequest(Req: Record "US Loan Application Header")
    begin
    end;


    procedure CheckPurchaseReqApprovalPossible(var req: Record "US Loan Application Header"): Boolean
    begin
        if not IsPurchReqApprovalsWorkflowEnabled(req) then
            Error('No workflow Enabled for Purchase requisition');

        exit(true);
    end;

    procedure IsPurchReqApprovalsWorkflowEnabled(var req: Record "US Loan Application Header"): Boolean
    begin
        exit(workflowmanagement.CanExecuteWorkflow(req, RunWorkflowOnSendPurchaseReqForApprovalCode));
    end;


    procedure RunWorkflowOnSendPurchaseReqForApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnSendPurchaseReqForApprovalCode'));
    end;

    procedure RunWorkflowOnCancelPurchaseReqForApprovalRequestCode(): code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelPurchaseReqForApprovalRequestCode'));
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    procedure SubOnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    begin
        case RecRef.Number of
            DATABASE::"US Loan Application Header":
                begin
                    RecRef.SetTable(Loan);
                    ApprovalEntryArgument."Document No." := Loan."No.";
                    ApprovalEntryArgument.Amount := Loan."Requested Amount";
                    ApprovalEntryArgument."Amount (LCY)" := Loan."Requested Amount";
                    ApprovalEntryArgument."Table ID" := Database::"US Loan Application Header";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', true, true)]
    local procedure OnOpenDocument(RecRef: RecordRef; Var Handled: Boolean)
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"US Loan Application Header":
                begin
                    RecRef.setTable(Loan);
                    Loan."Status" := Loan."Status"::Open;
                    Loan.Modify;
                    Handled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', true, true)]
    local procedure OnReleaseDocument(RecRef: RecordRef; Var Handled: Boolean)
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"US Loan Application Header":
                begin
                    RecRef.setTable(Loan);
                    Loan.Status := Loan.Status::Approved;
                    Loan.Modify;
                    Handled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure OnSetStatusToPendingApproval(RecRef: RecordRef; Var Variant: Variant; Var IsHandled: Boolean)
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"US Loan Application Header":
                begin
                    RecRef.SetTable(Loan);
                    Loan."Status" := Loan."Status"::Rejected;
                    Loan.Modify;
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnRejectApprovalRequest', '', false, false)]
    local procedure OnRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        recref: RecordRef;
        approvalmgnt: Codeunit "Approvals Mgmt.";
    begin
        recref.Get(ApprovalEntry."Record ID to Approve");
        CASE RecRef.NUMBER OF
            DATABASE::"US Loan Application Header":
                begin
                    RecRef.SetTable(Loan);
                    Loan."Status" := Loan."Status"::Open;
                    Loan.Modify;
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnConditionalCardPageIDNotFound', '', true, true)]
    local procedure OnConditionalCardPageIDNotFound(RecordRef: RecordRef; var CardPageID: Integer)
    begin
        case RecordRef.Number of
            DATABASE::"US Loan Application Header":
                CardPageID := Page::"US Loan Card";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAddWorkflowCategoriesToLibrary', '', true, true)]
    local procedure OnAddWorkflowCategoriesToLibrary()
    begin
        setup.InsertWorkflowCategory('Loan', 'Loan');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInsertApprovalsTableRelations', '', true, true)]
    local procedure OnAfterInsertApprovalsTableRelations()
    begin

        setup.InsertTableRelation(Database::"US Loan Application Header", 0, Database::"Approval Entry", entry.FieldNo("Record ID to Approve"));
        setup.InsertTableRelation(Database::"US Loan Application Header", loan.FieldNo(SystemId), Database::"Workflow Webhook Entry", webEntry.FieldNo("Data ID"));

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnInsertWorkflowTemplates', '', true, true)]
    local procedure OnInsertWorkflowTemplates()
    begin

        InsertLoanApprovalWorkflowTemplate();

    end;
    procedure InsertLoanApprovalWorkflowTemplate()
    var
        workflow: Record Workflow;
    begin
        setup.InsertWorkflowCategory('UnitRec', 'UnitRecs');
        setup.InsertTableRelation(Database::"US Loan Application Header", 0, Database::"Approval Entry", entry.FieldNo("Record ID to Approve"));
        setup.InsertTableRelation(Database::"US Loan Application Header", loan.FieldNo(SystemId), Database::"Workflow Webhook Entry", webEntry.FieldNo("Data ID"));
        setup.InsertWorkflowTemplate(workflow, UnitAppWorkflowCodeTxt, UnitAppWorkflowDescTxt, 'UnitRec');
        InsertSoldApprovalWorkflowDetails(workflow);
        setup.MarkWorkflowAsTemplate(Workflow);
    end;

    local procedure InsertSoldApprovalWorkflowDetails(var Workflow: Record Workflow)
    var
        blankDateFormula: DateFormula;

    begin
        setup.InitWorkflowStepArgument(
            WorkflowStepArgument, WorkflowStepArgument."Approver Type"::Approver,
            WorkflowStepArgument."Approver Limit Type"::"Approver Chain", 0, '', BlankDateFormula, true);

        Loan.Init();
        setup.InsertDocApprovalWorkflowSteps(
            Workflow,
            BuildLoanTypeConditionsText("US Application Status"::Open),
            RunWorkflowOnSendPurchaseReqForApprovalCode(),
            BuildLoanTypeConditionsText("US Application Status"::"Pending Approval"),
            RunWorkflowOnCancelPurchaseReqForApprovalRequestCode(),
            WorkflowStepArgument, true);
    end;

    procedure BuildLoanTypeConditionsText(Status: Enum "US Application Status"): Text
    begin
        Loan.SetRange(Status, Status);
        exit(StrSubstNo(LoanCondnTxt, setup.Encode(Loan.GetView(false))));
    end;

    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        LoanCondnTxt: Label '<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="Loan">%1</DataItem></DataItems></ReportParameters>', Locked = true;
        setup: Codeunit "Workflow Setup";
        WorkflowStepArgument: Record "Workflow Step Argument";
        PurchReqApprWorkflowCodeTxt: Label 'PRAPW', Locked = true;
        SCAppWorkflowCodeTxt: Label 'SCAPW', Locked = true;
        PurchReqApprWorkflowDescTxt: Label 'Purchase Requisition Approval Workflow';
        SCAppWorkflowDescTxt: Label 'Subcontract Approval Workflow';
        PPAppWorkflowCodeTxt: Label 'PPAPW', Locked = true;
        PPAppWorkflowDescTxt: Label 'Payment Plan Approval Workflow';
        MainPPAppWorkflowCodeTxt: Label 'MAINPPAPW', Locked = true;
        MainPPAppWorkflowDescTxt: Label 'Main Payment Plan Approval Workflow';
        UnitAppWorkflowCodeTxt: Label 'UAPW1', Locked = true;
        UnitAppWorkflowDescTxt: Label 'Unit Sold Approval Workflow';
        PurchDocCategoryTxt: Label 'INDENT', Locked = true;
        EstAppWorkflowCodeTxt: Label 'EST', Locked = true;
        EstAppworkflowDescTxt: Label 'Estimation Approval Workflow';
        BlankDateFormula: DateFormula;
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        PurchReqSendForApprovalEventDescTxt: Label 'Approval of a purchase Requisition is requested.';
        PurchReqApprReqCancelledEventDescTxt: Label 'An approval request for a purchase Requisition is canceled.';
        workflowmanagement: Codeunit "Workflow Management";
        workflowResponseHandling: Codeunit "Workflow Response Handling";
        entry: Record "Approval Entry";
        webEntry: Record "Workflow Webhook Entry";
        Loan: Record "US Loan Application Header";
        work: page "Workflow Templates";
        approvalentries: Page 658;
        flow: Page 1501;
}
