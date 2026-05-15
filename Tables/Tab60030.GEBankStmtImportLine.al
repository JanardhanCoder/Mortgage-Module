table 60030 "GE Bank Stmt Import Line"
{
    DataClassification = CustomerContent;
    Caption = 'Bank Statement Import Line';

    fields
    {
        field(1; "Entry No."; Integer) { AutoIncrement = true; }
        field(2; "Import Batch No."; Code[100]) { }
        field(3; "Bank Account No."; Code[20]) { TableRelation = "Bank Account"."No."; }

        field(10; "Booking Date"; Date) { }
        field(11; "Value Date"; Date) { }
        field(12; Amount; Decimal) { }
        field(13; Currency; Code[10]) { }
        field(14; "Counterparty Name"; Text[100]) { }
        field(15; "Counterparty IBAN"; Code[50]) { }
        field(16; "Reference Text"; Text[250]) { }
        field(17; "Unique Transaction ID"; Text[70]) { } // UTR/E2E/TxnID
        field(18; "Raw Line Hash"; Text[64]) { Editable = false; }

        // Matching outputs
        field(30; "Matched Loan No."; Code[20]) { TableRelation = "US Mortgage Agreement Header"."Loan No."; }
        field(31; "Matched External Ref"; Text[250]) { }
        field(32; "Matched Borrower No."; Code[20]) { TableRelation = Customer."No."; }
        field(33; "Match Confidence"; Integer) { Editable = false; } // 0-100
        field(34; "Match Method"; Option) { OptionMembers = " ",ExternalRef,LoanNo,IBAN,FreeText; Editable = false; }

        // Posting queue
        field(40; Status; Option)
        {
            OptionMembers = Imported,Matched,"Ready to Post",Posted,Skipped,Error;
        }
        field(41; "Receipt Txn No."; Code[100]) { Editable = false; }
        field(42; "Error Message"; Text[250]) { Editable = false; }
        field(43; "Processed At"; DateTime) { Editable = false; }
        field(44; "Processed By"; Code[50]) { Editable = false; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Batch; "Import Batch No.", Status) { }
        key(Dedup; "Bank Account No.", "Unique Transaction ID") { } // used by logic; not enforced as unique
    }
}
