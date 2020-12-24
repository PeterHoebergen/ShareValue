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
                                code := '1659';
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
                        fieldattribute(EmployeeHID; TimeTransaction."No.")
                        {
                        }
                    }
                    textelement(Item)
                    {
                        fieldattribute("code"; TimeTransaction."Gen. Prod. Posting Group")
                        {
                        }
                    }
                    textelement(Note)
                    {
                    }
                    textelement(Project)
                    {
                        fieldattribute("code"; TimeTransaction."Job No.")
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
                        JobPlanningLine.get(TimeTransaction."Job No.", TimeTransaction."Job Task No.", TimeTransaction."Line No.");
                        JobPlanningLine."DateTime Exported to Exact" := CurrentDateTime;
                        JobPlanningLine.Modify();
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

}