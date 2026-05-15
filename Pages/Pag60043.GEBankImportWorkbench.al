page 60043 "GE Bank Import Workbench"
{
    PageType = List;
    SourceTable = "GE Bank Stmt Import Line";
    ApplicationArea = All;
    Caption = 'Bank Statement Import Workbench';
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Import Batch No."; Rec."Import Batch No.") { }
                field("Bank Account No."; Rec."Bank Account No.") { }
                field("Booking Date"; Rec."Booking Date") { }
                field("Value Date"; Rec."Value Date") { }
                field(Amount; Rec.Amount) { }
                field("Unique Transaction ID"; Rec."Unique Transaction ID") { }
                field("Reference Text"; Rec."Reference Text") { }
                field(Status; Rec.Status) { }
                field("Matched Loan No."; Rec."Matched Loan No.") { }
                field("Matched External Ref"; Rec."Matched External Ref") { }
                field("Match Confidence"; Rec."Match Confidence") { }
                field("Match Method"; Rec."Match Method") { }
                field("Receipt Txn No."; Rec."Receipt Txn No.") { }
                field("Error Message"; Rec."Error Message") { }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ImportCSV)
            {
                Caption = 'Import CSV';
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                var
                    X: XmlPort "GE Bank Stmt CSV Import";
                    BatchNo: Code[30];
                begin
                    BatchNo := CreateBatchNo();
                    X.SetBatchNo(BatchNo);
                    X.Run();
                    Message('Import completed. Batch %1.', BatchNo);
                end;
            }

            action(MatchBatch)
            {
                Caption = 'Match Batch';
                ApplicationArea = All;
                Image = Calculate;

                trigger OnAction()
                var
                    M: Codeunit "GE Bank Match Engine";
                begin
                    M.MatchBatch(GetCurrentBatch());
                    CurrPage.Update(false);
                end;
            }

            action(MarkReady)
            {
                Caption = 'Mark Ready to Post';
                ApplicationArea = All;
                Image = Approve;

                trigger OnAction()
                begin
                    if Rec."Matched Loan No." = '' then
                        Error('Matched Loan No. is required.');
                    Rec.Status := Rec.Status::"Ready to Post";
                    Rec.Modify(true);
                    CurrPage.Update(false);
                end;
            }

            action(PostBatch)
            {
                Caption = 'Post Batch';
                ApplicationArea = All;
                Image = PostBatch;

                trigger OnAction()
                var
                    P: Codeunit "GE Bank Batch Poster";
                begin

                    P.PostBatch(GetCurrentBatch(), 0);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    local procedure GetCurrentBatch(): Code[100]
    begin
        if Rec."Import Batch No." = '' then
            Error('Select a line with Import Batch No.');
        exit(Rec."Import Batch No.");
    end;

    local procedure CreateBatchNo(): Code[100]
    begin
        exit(CopyStr('BATCH-' + Format(CurrentDateTime(), 0, 9), 1, 30));
    end;
}
