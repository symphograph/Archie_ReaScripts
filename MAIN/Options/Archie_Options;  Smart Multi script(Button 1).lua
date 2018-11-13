--[[
   * Category:    Options
   * Description: Smart Multi script(Button 1)
   * Author:      Archie
   * Version:     1.2.2
   * AboutScript: Run the script with the keyboard shortcut Ctrl + Shift + Alt + Click
   *              To display help, enter the word in the first field 'help'
   * О скрипте:   Запустите скрипт сочетанием клавиш  Ctrl + Shift + Alt + Click
   *              Для отображения справки, введите в первое поле слово 'help'
   * GIF:         http://clck.ru/EhYZ9
   * Website:     http://forum.cockos.com/showthread.php?t=212819
   * Donation:    http://money.yandex.ru/to/410018003906628
   * Customer:    Supa75(Rmm/forum) 
   * Gave idea:   Supa75(Rmm/forum) 
   * Changelog:   +! Fixed error in displaying a window with a hint / v.1.02 [13.11.18]
   *              +! Исправлена ошибка отображения окна с подсказкой / v.1.02 [13.11.18]
   *              + initialе / v.1.0 [12.11.18]
--=====================================================================================
SYSTEM  REQUIREMENTS:   Reaper v.5.96  |   SWS v.2.9.7  |   ReaPack v1.2.2  (and above)
СИСТЕМНЫЕ ТРЕБОВАНИЯ:   Reaper v.5.96  |   SWS v.2.9.7  |   ReaPack v1.2.2  (и выше)
--================================================================================]]




    --======================================================================================
    --////////////// SCRIPT \\\\\\\\\\\\\\  SCRIPT  //////////////  SCRIPT  \\\\\\\\\\\\\\\\
    --======================================================================================




    ------------------------------------------------------------------------------
    local function No_Undo()end; local function no_undo()reaper.defer(No_Undo)end;
    ------------------------------------------------------------------------------



    local but = "Button 1"
    local scr_nam = select(2,select(2,reaper.get_action_context()):match("(.+)[\\](.+)")) 
    local Modifiers = reaper.JS_Mouse_GetState(28);

    if Modifiers ~= 28 then; 
        local TooltipWind = reaper.GetExtState(scr_nam.."ArchieMultiScript工具提示窗口"..but, scr_nam.."MultiScript工具提示窗口"..but);
        if TooltipWind == "" then;

            local MessageBox = reaper.ShowMessageBox(
            "Rus.\n"..
            "Запускайте множество действий с помощью одной кнопки и сочетаний клавиш Ctrl, Shift, Alt\n"..
            "Запустите скрипт сочетанием клавиш  Ctrl + Shift + Alt + Click в появившемся окне введите id любого экшена или скрипта"..
            " или часть имени экшена в скобках, а за тем id. \nПример: '[name] id','(name) id','{name} id'\n"..
            "Обратите внимания, что в имени недопустимы запятые, если запятые есть, то удалите их, иначе все порушится.\n"..
            "[name name] id - Правильно\n".. 
            "[name,name] id - Не Правильно\n".. 
            "Для повторного отображения справки, введите в первое поле слово 'help'\n"..
            "Для полного сброса введите в первое поле слово 'reset'\n"..
            "--------------------------------------------------------------------------------------------\n"..
            "Eng.\n"..
            "Launch multiple actions with a single button and keyboard shortcuts Ctrl, Shift, Alt\n"..
            "Run the script with the keyboard shortcut Ctrl + Shift + Alt + Click in the window that appears, enter the id of any action or script "..
            "or part of the name of the action in brackets, and then id. \nExample: '[name] id', '(name) id', '{name} id'\n"..
            "Please note that commas are not allowed in the name. If there are commas, delete them, otherwise it will crash.\n"..
            "[name name] id - Correctly\n".. 
            "[name,name] id - Not properly\n"..
            "To display the help again, enter the word 'help'\nin the first field.\n"..
            "For a complete reset, enter the word 'reset' in the first field\n"..
            "--------------------------------------------------------------------------------------------\n\n"..
            "НЕ ПОКАЗЫВАТЬ ПОЛЬШЕ ЭТО ОКНО  -  ОК\n\n"..
            "DO NOT SHOW THIS WINDOW - OK",
            "Archie_Smart Multi Script / help.", 1);

            if MessageBox == 1 then ;
                reaper.SetExtState(scr_nam.."ArchieMultiScript工具提示窗口"..but, scr_nam.."MultiScript工具提示窗口"..but,MessageBox, true);
            end;
        end;
    end;
    ------------------------------------------------------------------------------------------------




    local ExtState = reaper.GetExtState(scr_nam.."ArchieMultiScript複ス"..but, scr_nam.."MultiScript複ス"..but);
    if ExtState == "" or ExtState == ",,,,,," then; ExtState = "id,id,id,id,id,id,id" end;
    if Modifiers == 28 then; 

        local retval, retvals_csv = reaper.GetUserInputs("Archie_Smart Multi Script".." / "..but,7, 
                                                         "Only Click.....................action Id:,"..
                                                         "Ctrl + Click....................action Id:,"..
                                                         "Shift + Click..................action Id:,"..
                                                         "Alt + Click.....................action Id:,"..
                                                         "Ctrl + Shift + Click.........action Id:,"..
                                                         "Ctrl + Alt + Click............action Id:,"..
                                                         "Alt + Shift + Click..........action Id:,".. 
                                                         "extrawidth=150",
                                                          ExtState);
        if not retval then no_undo()return end;


        local insertId = "";
        for Val in string.gmatch(retvals_csv:gsub(" ","")..",",".-,") do;
            if Val == "," then Val = "id," end;
            insertId = insertId..Val;
        end;

        local InputField = string.reverse(insertId:reverse():gsub(",", "", 1));  
        ---

        local Reset = InputField:match(".-,"):gsub(",", "");
        if Reset == "Reset" or Reset == "reset" then;
            reaper.DeleteExtState(scr_nam.."ArchieMultiScript複ス"..but, scr_nam.."MultiScript複ス"..but, true);
            reaper.DeleteExtState(scr_nam.."ArchieMultiScript工具提示窗口"..but, scr_nam.."MultiScript工具提示窗口"..but, true);
            do no_undo()return end;
        elseif Reset == "help" or Reset == "Help" then;
            reaper.DeleteExtState(scr_nam.."ArchieMultiScript工具提示窗口"..but, scr_nam.."MultiScript工具提示窗口"..but, true);
            InputField = InputField:gsub(InputField:match(".-,"), "id,",1);
            reaper.SetExtState(scr_nam.."ArchieMultiScript複ス"..but, scr_nam.."MultiScript複ス"..but, InputField, true);
            do no_undo()return end;
        end;
        --- 

        reaper.SetExtState(scr_nam.."ArchieMultiScript複ス"..but, scr_nam.."MultiScript複ス"..but, InputField, true);
        do no_undo()return end;
        ----------------------- 
    end;
    ----------------------------------------------------------------------------------



    local removeName = ExtState:gsub("%[.-%]",""):gsub("%(.-%)",""):gsub("{.-}","");
    local Click,Ctrl,Shift,Alt,Ctrl_Shift,Ctrl_Alt,Alt_Shift = string.match
                          (removeName, "(.-,)(.-,)(.-,)(.-,)(.-,)(.-,)(.+)");


    if not Click      then Click      = "id" end;
    if not Ctrl       then Ctrl       = "id" end;
    if not Shift      then Shift      = "id" end;
    if not Alt        then Alt        = "id" end;
    if not Ctrl_Shift then Ctrl_Shift = "id" end;
    if not Ctrl_Alt   then Ctrl_Alt   = "id" end;
    if not Alt_Shift  then Alt_Shift  = "id" end;


    Click      = Click     :gsub(",","");
    Ctrl       = Ctrl      :gsub(",","");
    Shift      = Shift     :gsub(",","");
    Alt        = Alt       :gsub(",","");
    Ctrl_Shift = Ctrl_Shift:gsub(",","");
    Ctrl_Alt   = Ctrl_Alt  :gsub(",","");
    Alt_Shift  = Alt_Shift :gsub(",","");
    ------------------------------------



    if Modifiers == 12 then; 
        reaper.Main_OnCommand(reaper.NamedCommandLookup(Ctrl_Shift),0);
        do no_undo()return end;
    end;



    if Modifiers == 20 then; 
        reaper.Main_OnCommand(reaper.NamedCommandLookup(Ctrl_Alt),0);
        do no_undo()return end;
    end;


    if Modifiers == 24 then; 
        reaper.Main_OnCommand(reaper.NamedCommandLookup(Alt_Shift),0);
        do no_undo()return end;
    end;


    if Modifiers == 4 then; 
        reaper.Main_OnCommand(reaper.NamedCommandLookup(Ctrl),0);
        do no_undo()return end;
    end;


    if Modifiers == 8 then; 
        reaper.Main_OnCommand(reaper.NamedCommandLookup(Shift),0);
        do no_undo()return end;
    end;


    if Modifiers == 16 then; 
        reaper.Main_OnCommand(reaper.NamedCommandLookup(Alt),0);
        do no_undo()return end;
    end;


    if Modifiers == 0 then;
        reaper.Main_OnCommand(reaper.NamedCommandLookup(Click),0);
        do no_undo()return end;
    end;