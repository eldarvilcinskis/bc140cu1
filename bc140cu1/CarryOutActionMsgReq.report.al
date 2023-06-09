report 493 "Carry Out Action Msg. - Req."
{
    Caption = 'Carry Out Action Msg. - Req.';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PrintOrders;PrintOrders)
                    {
                        ApplicationArea = Planning;
                        Caption = 'Print Orders';
                        ToolTip = 'Specifies whether to print the purchase orders after they are created.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            PurchOrderHeader."Order Date" := WorkDate;
            PurchOrderHeader."Posting Date" := WorkDate;
            PurchOrderHeader."Expected Receipt Date" := WorkDate;
            if ReqWkshTmpl.Recurring then
              EndOrderDate := WorkDate
            else
              EndOrderDate := 0D;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        UseOneJnl(ReqLine);
    end;

    var
        Text000: Label 'cannot be filtered when you create orders';
        Text001: Label 'There is nothing to create.';
        Text003: Label 'You are now in worksheet %1.';
        ReqWkshTmpl: Record "Req. Wksh. Template";
        ReqWkshName: Record "Requisition Wksh. Name";
        ReqLine: Record "Requisition Line";
        PurchOrderHeader: Record "Purchase Header";
        ReqWkshMakeOrders: Codeunit "Req. Wksh.-Make Order";
        EndOrderDate: Date;
        PrintOrders: Boolean;
        TempJnlBatchName: Code[10];
        HideDialog: Boolean;

    [Scope('Personalization')]
    procedure SetReqWkshLine(var NewReqLine: Record "Requisition Line")
    begin
        ReqLine.Copy(NewReqLine);
        ReqWkshTmpl.Get(NewReqLine."Worksheet Template Name");
    end;

    [Scope('Personalization')]
    procedure GetReqWkshLine(var NewReqLine: Record "Requisition Line")
    begin
        NewReqLine.Copy(ReqLine);
    end;

    [Scope('Personalization')]
    procedure SetReqWkshName(var NewReqWkshName: Record "Requisition Wksh. Name")
    begin
        ReqWkshName.Copy(NewReqWkshName);
        ReqWkshTmpl.Get(NewReqWkshName."Worksheet Template Name");
    end;

    local procedure UseOneJnl(var ReqLine: Record "Requisition Line")
    begin
        with ReqLine do begin
          ReqWkshTmpl.Get("Worksheet Template Name");
          if ReqWkshTmpl.Recurring and (GetFilter("Order Date") <> '') then
            FieldError("Order Date",Text000);
          TempJnlBatchName := "Journal Batch Name";
          ReqWkshMakeOrders.Set(PurchOrderHeader,EndOrderDate,PrintOrders);
          ReqWkshMakeOrders.CarryOutBatchAction(ReqLine);

          if "Line No." = 0 then
            Message(Text001)
          else
            if not HideDialog then
              if TempJnlBatchName <> "Journal Batch Name" then
                Message(
                  Text003,
                  "Journal Batch Name");

          if not Find('=><') or (TempJnlBatchName <> "Journal Batch Name") then begin
            Reset;
            FilterGroup := 2;
            SetRange("Worksheet Template Name","Worksheet Template Name");
            SetRange("Journal Batch Name","Journal Batch Name");
            FilterGroup := 0;
            "Line No." := 1;
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure InitializeRequest(ExpirationDate: Date;OrderDate: Date;PostingDate: Date;ExpectedReceiptDate: Date;YourRef: Text[50])
    begin
        EndOrderDate := ExpirationDate;
        PurchOrderHeader."Order Date" := OrderDate;
        PurchOrderHeader."Posting Date" := PostingDate;
        PurchOrderHeader."Expected Receipt Date" := ExpectedReceiptDate;
        PurchOrderHeader."Your Reference" := YourRef;
    end;

    [Scope('Personalization')]
    procedure SetHideDialog(NewHideDialog: Boolean)
    begin
        HideDialog := NewHideDialog;
    end;
}

