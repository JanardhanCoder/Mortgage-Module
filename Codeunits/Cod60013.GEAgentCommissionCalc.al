// codeunit 60013 "GE Agent Commission Calc"
// {
//     procedure CalculateCommission(LoanNo: Code[20]; var AgentCode: Code[20]; var AgreementNo: Code[20];
//                                   var BaseAmount: Decimal; var CommAmount: Decimal)
//     var
//         Loan: Record "US Mortgage Agreement Header";
//         AgrH: Record "GE Agent Agreement Header";
//         AgrL: Record "GE Agent Agreement Line";
//         RuleFound: Boolean;
//     begin
//         Loan.Get(LoanNo);
//         //Resolve agent from Loan.Agent Contact No. -> Agent master
//         AgentCode := ResolveAgentCode(Loan."Agent Contact No.");
//         if AgentCode = '' then
//             Error('No Mortgage Agent found for Contact %1.', Loan."Agent Contact No.");

//        // Agent.Get(AgentCode);

//         AgreementNo := FindActiveAgreement(AgentCode, Today);
//         AgrH.Get(AgreementNo);

//         BaseAmount := GetBaseAmount(Loan, AgrH."Commission Basis");

//         RuleFound := false;
//         AgrL.SetRange("Agreement No.", AgreementNo);
//         AgrL.SetFilter("From Loan Amount", '..%1', BaseAmount);
//         AgrL.SetFilter("To Loan Amount", '%1..', BaseAmount);
//         // AgrL.SetCurrentKey(Priority);
//         if AgrL.FindSet() then
//             repeat
//                 //Optional filters (Product/Channel/PropertyType) can be applied here
//                 CommAmount := ComputeFromLine(AgrL, BaseAmount);
//                 RuleFound := true;
//                 exit;
//             until AgrL.Next() = 0;

//         if not RuleFound then
//             Error('No commission rule found for amount %1 under Agreement %2.', BaseAmount, AgreementNo);
//     end;

//     local procedure GetBaseAmount(Loan: Record "US Mortgage Agreement Header"; Base: Enum "GE Commission Basis"): Decimal
//     begin
//         case Base of
//             Base::"Loan Amount":
//                 exit(Loan."Principal Amount");
//             Base::"Disbursed Amount":
//                 exit(Loan."Disbursed Amount");
//         end;
//     end;

//     local procedure ComputeFromLine(L: Record "GE Agent Agreement Line"; BaseAmount: Decimal): Decimal
//     var
//         Amt: Decimal;
//     begin
//         case L."Commission Type" of
//             L."Commission Type"::Percentage:
//                 Amt := Round(BaseAmount * (L."Commission %" / 100), 0.01);
//             L."Commission Type"::"Fixed Amount":
//                 Amt := Round(L."Commission Amount", 0.01);
//             L."Commission Type"::Tiered:
//                 begin
//                     // Tiered = stored as range lines anyway; treat as percent or fixed per line
//                     if L."Commission %" <> 0 then
//                         Amt := Round(BaseAmount * (L."Commission %" / 100), 0.01)
//                     else
//                         Amt := Round(L."Commission Amount", 0.01);
//                 end;
//         end;

//         if (L."Minimum Commission" > 0) and (Amt < L."Minimum Commission") then
//             Amt := L."Minimum Commission";
//         if (L."Maximum Commission" > 0) and (Amt > L."Maximum Commission") then
//             Amt := L."Maximum Commission";

//         exit(Amt);
//     end;

//     local procedure ResolveAgentCode(ContactNo: Code[20]): Code[20]
//     var
//         Agent: Record "GE Mortgage Agent";
//     begin
//         Agent.SetRange("CRM Agent Contact No.", ContactNo);
//         if Agent.FindFirst() then
//             exit(Agent."Agent Code");
//         exit('');
//     end;

//     local procedure FindActiveAgreement(AgentCode: Code[20]; AsOfDate: Date): Code[20]
//     var
//         AgrH: Record "GE Agent Agreement Header";
//     begin
//         AgrH.SetRange("Agent Contact No.", AgentCode);
//         AgrH.SetRange(Status, AgrH.Status::Active);
//         AgrH.SetFilter("Effective From Date", '..%1', AsOfDate);
//         AgrH.SetFilter("Effective To Date", '%1..', AsOfDate);
//         if AgrH.FindFirst() then
//             exit(AgrH."No.");
//         Error('No active agreement found for Agent %1 on %2.', AgentCode, AsOfDate);
//     end;
// }
