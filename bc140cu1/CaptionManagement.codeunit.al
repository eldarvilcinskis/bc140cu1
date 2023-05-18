codeunit 42 "CaptionManagement"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    local procedure ResolveCaptionClass(Language: Integer; CaptionClassExpr: Text) Caption: Text
    var
        CaptionArea: Text;
        CaptionExpr: Text;
        Resolved: Boolean;
    begin
        // <summary>
        // Resolves a given CaptionClass expression and a language id into a caption.
        // The function either resolves the CaptionClass expression or emits OnResolveCaptionClass event.
        // </summary>
        // <param name="Language">The current language id </param>
        // <param name="CaptionClassExpr">The CaptionClass expression to be resolved.
        // Usually in the following format: <Caption Area>,<Caption Expression></param>
        // <returns>The resolved caption or the original CaptionClass expression if the resolution was unsuccessful.</returns>

        if SplitCaptionClassExpr(CaptionClassExpr, CaptionArea, CaptionExpr) then
            if CaptionArea = '3' then begin
                Caption := CaptionExpr;
                Resolved := true;
            end else
                OnResolveCaptionClass(CaptionArea, CaptionExpr, Language, Caption, Resolved);

        // if Caption hasn't been resolved, fallback to CaptionClassExpr
        if not Resolved then
            Caption := CaptionClassExpr;
    end;

    local procedure SplitCaptionClassExpr(CaptionClassExpr: Text; var CaptionArea: Text; var CaptionExpr: Text): Boolean
    var
        CommaPosition: Integer;
    begin
        // <summary>
        // Splits given CaptionClass expression into caption area and caption expression (provided by var parameters)
        // </summary>
        // <param name="CaptionClassExpr">The CaptionClass expression to be split</param>
        // <param name="CaptionArea">The caption area extracted from the CaptionClass expression</param>
        // <param name="CaptionExpr">The caption expression extracted from the CaptionClass expression</param>
        // <returns>Returns whether the split succeeded or not</returns>

        CommaPosition := StrPos(CaptionClassExpr, ',');
        if CommaPosition > 0 then begin
            CaptionArea := CopyStr(CaptionClassExpr, 1, CommaPosition - 1);
            CaptionExpr := CopyStr(CaptionClassExpr, CommaPosition + 1);
            exit(true);
        end;
        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000004, 'CaptionClassTranslate', '', false, false)]
    local procedure DoResolveCaptionClass(Language: Integer; CaptionExpr: Text[1024]; var Translation: Text[1024])
    begin
        Translation := CopyStr(ResolveCaptionClass(Language, CaptionExpr), 1, MaxStrLen(Translation));
        OnAfterCaptionClassTranslate(Language, CaptionExpr, Translation);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer; var Caption: Text; var Resolved: Boolean)
    begin
        // <summary>
        // Integration event for resolving CaptionClass expression, split into CaptionArea and CaptionExpr.
        // Note there should be a single subscriber per caption area.
        // The event implements the "resolved" pattern - if a subscriber resolves the caption, it should set Resolved to TRUE.
        // </summary>
        // <param name="CaptionArea">The caption area used in the CaptionClass expression. Should be unique for every subscriber</param>
        // <param name="CaptionExpr">The caption expression used for resolving the CaptionClass expression</param>
        // <param name="Language">The current language id that can be used for resolving the CaptionClass expression</param>
        // <param name="Caption">Var parameter - the resolved caption</param>
        // <param name="Resolved">Boolean for marking whether the CaptionClass expression was resolved</param>
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCaptionClassTranslate(Language: Integer; CaptionExpression: Text; var Caption: Text[1024])
    begin
        // <summary>
        // Integration event for after resolving CaptionClass expression.
        // </summary>
        // <param name="Language">The current language id</param>
        // <param name="CaptionExpression">The original CaptionClass expression</param>
        // <param name="Caption">The resolved caption expression</param>
    end;
}

