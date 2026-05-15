table 60021 "GE Mortgage Cue"
{
    Caption = 'Mortgage Cues';
    DataClassification = SystemMetadata;
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }

        // ───────── Loan Origination ─────────
        field(10; "Approved Applications"; Integer)
        {
            CalcFormula = Count("US Loan Application Header"
                where(Status = const(Approved)));
            FieldClass = FlowField;
        }

        field(11; "Pending Approval"; Integer)
        {
            CalcFormula = Count("US Loan Application Header"
                where(Status = const(Rejected)));
            FieldClass = FlowField;
        }


        // ───────── Active Loans ─────────
        field(20; "Active Loans"; Integer)
        {
            CalcFormula = Count("US Mortgage Agreement Header"
                where(Status = const(Active)));
            FieldClass = FlowField;
        }
        field(21; "Closed Loans"; Integer)
        {
            CalcFormula = Count("US Mortgage Agreement Header"
                where(Status = const(Closed)));
            FieldClass = FlowField;
        }
        field(22; "Draft Loans"; Integer)
        {
            CalcFormula = Count("US Mortgage Agreement Header"
                where(Status = const(Draft)));
            FieldClass = FlowField;
        }
        field(23; "Total Outstanding Principal"; Decimal)
        {
            CalcFormula = Sum("US Loan Ledger Entry"."Amount Principal"
                where(Posted = const(false)));
            FieldClass = FlowField;
        }

        // // ───────── Overdue ─────────
        // field(30; "Installments Due Today"; Integer)
        // {
        //     CalcFormula = Count("US Mortgage Schedule Line"
        //         where("Due Date" = const(today),
        //               Paid = const(false)));
        //     FieldClass = FlowField;
        // }

        // field(31; "Overdue Installments"; Integer)
        // {
        //     CalcFormula = Count("US Mortgage Schedule Line"
        //         where("Due Date" = filter(.. workdate() - 1),
        //               Paid = const(false)));
        //     FieldClass = FlowField;
        // }

        // field(32; "Overdue Amount"; Decimal)
        // {
        //     CalcFormula = Sum("US Mortgage Schedule Line"."Opening Principal"
        //         where("Due Date" = filter(.. today() - 1),
        //               Paid = const(false)));
        //     FieldClass = FlowField;
        // }

        // ───────── Accounting / Posting ─────────
        // field(40; "Interest to Be Posted"; Decimal)
        // {
        //     CalcFormula = Sum("GE Loan Interest Buffer"."Interest Amount"
        //         where(Posted = const(false)));
        //     FieldClass = FlowField;
        // }

        // field(41; "Unposted Journals"; Integer)
        // {
        //     CalcFormula = Count("Gen. Journal Line"
        //         where(Posted = const(false)));
        //     FieldClass = FlowField;
        // }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure TotalValueofLoans(): Decimal
    var
        Loan: Record "US Loan Application Header";
        total: Decimal;
    begin
        Clear(total);
        // Unit.SetRange(AreaStatus, Unit.AreaStatus);
        if Loan.FindSet() then begin
            repeat
                total := total + Loan."Approved Amount";
            until Loan.Next() = 0;
        end;
        exit(total);
    end;
}

