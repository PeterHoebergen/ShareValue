xmlport 50000 ExportHoursToExact
{
    Format = Xml;
    Direction = Export;
    Encoding = UTF8;
    DefaultNamespace = 'http://www.w3.org/2001/XMLSchema-instance xsi:noNamespaceSchemaLocation=eExact-XML.xsd';
    UseDefaultNamespace = true;
    schema
    {
        textelement(eExact)
        {
            textelement(TimeTransactions)
            {
                tableelement(TimeTransaction; "Job Planning Line")
                {
                    SourceTableView = where("DateTime Exported to Exact" = filter(= 0DT), "line type" = filter(<> 0));
                    textattribute(Status)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            Status := '10';
                        end;
                    }
                    textelement(Account)
                    {
                        textattribute(code)
                        {                            
                           trigger OnBeforePassVariable()
                           begin
                               code := JobHeader."Bill-to Customer No.";
                           end;
                        }
                    }
                    textelement(Date)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            Date := Format(TimeTransaction."Document Date", 0, 9);
                        end;
                    }
                    textelement(Employee)
                    {
                        textattribute(EmployeeHID)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                if Evaluate(EmployeeDec,TimeTransaction."No.") then
                                    EmployeeHID := format(EmployeeDec)
                                else
                                  EmployeeHID := TimeTransaction."No.";
                            end;
                        }
                    }
                    textelement(Item)
                    {
                        fieldattribute(code; TimeTransaction."Gen. Prod. Posting Group")
                        {
                        }
                    }
                    textelement(Note)
                    {
                    }
                    textelement(Project)
                    {
                        fieldattribute(code; TimeTransaction.Description)
                        {
                        }
                    }
                    textelement(Quantity) 
                    {          
                        trigger OnBeforePassVariable()
                        begin
                            Quantity := Format(TimeTransaction.Quantity, 0, 9);
                        end;
                    }
                    trigger OnAfterGetRecord()
                    begin
                        TimeTransaction.Description := TimeTransaction."Job No." + '-' + TimeTransaction."Job Task No.";
                        JobPlanningLine.get(TimeTransaction."Job No.", TimeTransaction."Job Task No.", TimeTransaction."Line No.");
                        JobPlanningLine."DateTime Exported to Exact" := CurrentDateTime;
                        JobPlanningLine.Modify();
                        JobHeader.get(TimeTransaction."Job No.");
                        if TimeTransaction."Gen. Prod. Posting Group" <> '' then
                        begin
                            if GenProdPostGroup.get(TimeTransaction."Gen. Prod. Posting Group") then
                                TimeTransaction."Gen. Prod. Posting Group" := GenProdPostGroup."Exact Item Code";
                        end;
                    end;
                }
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                    field(Name; TimeTransaction."Document Date")
                    {

                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {

                }
            }
        }
    }
    var
        JobPlanningLine: Record "Job Planning Line";
        JobHeader: Record Job;
        EmployeeDec: Decimal;
        GenProdPostGroup: Record "Gen. Product Posting Group";

}