--[[
   * Тест только на windows  /  Test only on windows.
   * Отчет об ошибке: Если обнаружите какие либо ошибки, то сообщите по одной из указанных ссылок ниже (*Website)
   * Bug Reports: If you find any errors, please report one of the links below (*Website)
   *
   * Category:    Item
   * Description: Item;  Solo selected item - Restore back.lua
   * Author:      Archie
   * Version:     1.0
   * Website:     http://forum.cockos.com/showthread.php?t=212819
   *              http://rmmedia.ru/threads/134701/
   *              http://vk.com/reaarchie
   * DONATION:    http://money.yandex.ru/to/410018003906628
   * Customer:    Archie(---)
   * Gave idea:   Archie(---)
   * Extension:   Reaper 6.10+ http://www.reaper.fm/
   *              SWS v.2.12.0 http://www.sws-extension.org/index.php
   *              Arc_Function_lua v.2.8.0+ (Repository: Archie-ReaScripts) http://clck.ru/EjERc
   *              reaper_js_ReaScriptAPI64 Repository - (ReaTeam Extensions) http://clck.ru/Eo5Nr or http://clck.ru/Eo5Lw
   * Changelog:   
   *              v.1.0 [180520]
   *                  + initialе
--]]
    --======================================================================================
    --////////////  НАСТРОЙКИ  \\\\\\\\\\\\  SETTINGS  ////////////  НАСТРОЙКИ  \\\\\\\\\\\\
    --======================================================================================
    
    
    local GUID_or_HandleAddress = 1 
                             -- = 0 GUID (Скрипт работает медленнее, и сохраняет состояние при перезапуске проекта)
                             -- = 1 HandleAddress (Скрипт работает быстрее и не сохраняет состояние при перезапуске проекта)
    
    
    --======================================================================================
    --////////////// SCRIPT \\\\\\\\\\\\\\  SCRIPT  //////////////  SCRIPT  \\\\\\\\\\\\\\\\
    --======================================================================================
    
    
    
    --==== FUNCTION MODULE FUNCTION ======================= FUNCTION MODULE FUNCTION ============== FUNCTION MODULE FUNCTION ======
    local P,F,L,A=reaper.GetResourcePath()..'/Scripts/Archie-ReaScripts/Functions','/Arc_Function_lua.lua'; L,A=pcall(dofile,P..F);
    if not L then reaper.RecursiveCreateDirectory(P,0);reaper.MB('Missing file / Отсутствует файл!\n\n'..P..F,"Error",0);return;end;
    if not A.VersionArc_Function_lua("2.8.0",P,"")then A.no_undo() return end;local Arc=A; -- =====================================
    --==== FUNCTION MODULE FUNCTION ====▲=▲=▲============== FUNCTION MODULE FUNCTION ============== FUNCTION MODULE FUNCTION ======
    
    
    
    ------------------------------------------
    local function cleanProjExtState(extname);
        for i = 1,math.huge do;
            local retval,key,value = reaper.EnumProjExtState(0,extname,0);
            if retval then;
                reaper.SetProjExtState(0,extname,key,'');
            else;
                break;
            end;
        end;
    end;
    ------------------------------------------
    local function anyItemMute();
        local CountItem = reaper.CountMediaItems(0);
        for i = 1,CountItem do;
            local item = reaper.GetMediaItem(0,i-1);
            local mute = reaper.GetMediaItemInfo_Value(item,'B_MUTE');
            if mute > 0 then return true end;
        end;
        return false;
    end;
    ------------------------------------------
    
    
    
    local is_new_value,filename,sectionID,cmdID,mode,resolution,val = reaper.get_action_context();
    local extname = filename:match('.*[\\/](.+)$');
    local title1 = 'Solo Item';
    local title2 = 'UnSolo Item';
    local UNDO = nil;
    
    Arc.HelpWindowWhenReRunning(2,'',false,extname);
    
    --------------------------------------------------
    local CountItem = reaper.CountMediaItems(0);
    if CountItem == 0 then;
        cleanProjExtState(extname);
        if Arc.GetSetToggleButtonOnOff(0,0)==1 then;
            Arc.GetSetToggleButtonOnOff(0,1);
        end;
        Arc.no_undo()return;
    end;
    --------------------------------------------------
    
    
    
    local retval,key,val = reaper.EnumProjExtState(0,extname,0);
    local anyItMute = anyItemMute();
    if retval and not anyItMute then;
        cleanProjExtState(extname);
        if Arc.GetSetToggleButtonOnOff(0,0)==1 then;
            Arc.GetSetToggleButtonOnOff(0,1);
        end;
        retval = nil;
    end;
    if retval then;
        -----
        for i = 1,math.huge do;
            local retval,key,value = reaper.EnumProjExtState(0,extname,0);
            if retval then;
                reaper.SetProjExtState(0,extname,key,'');
                local item;
                if GUID_or_HandleAddress == 0 then;
                    item = reaper.BR_GetMediaItemByGUID(0,key);
                else;
                    item = reaper.JS_Window_HandleFromAddress(key);
                end;
                if item then;
                    local mutePC,mute = pcall(reaper.GetMediaItemInfo_Value,item,'B_MUTE');
                    if mutePC and mute ~= value then;
                        if not UNDO then;
                            UNDO = title2;
                            reaper.Undo_BeginBlock();
                            reaper.PreventUIRefresh(1);
                        end;
                        reaper.SetMediaItemInfo_Value(item,'B_MUTE',value);
                    end;
                end;
            else
                break;
            end;
        end;
        --reaper.ShowConsoleMsg('msg')
        if Arc.GetSetToggleButtonOnOff(0,0)==1 then;
            Arc.GetSetToggleButtonOnOff(0,1);
        end;
        -----
    else;
        -----
        local CountSelItem = reaper.CountSelectedMediaItems(0);
        if CountSelItem == 0 then Arc.no_undo()return end;
        for i = 1,CountItem do;
            local item = reaper.GetMediaItem(0,i-1);
            local sel = reaper.GetMediaItemInfo_Value(item,'B_UISEL');
            local mute = reaper.GetMediaItemInfo_Value(item,'B_MUTE');
            if sel == 1 then
                if mute ~= 0 then;
                    if not UNDO then;
                        UNDO = title1;
                        reaper.Undo_BeginBlock();
                        reaper.PreventUIRefresh(1);
                    end;
                    reaper.SetMediaItemInfo_Value(item,'B_MUTE',0);
                    local GUID_it;
                    if GUID_or_HandleAddress == 0 then;
                         GUID_it = reaper.BR_GetMediaItemGUID(item);
                    else;
                        GUID_it = reaper.JS_Window_AddressFromHandle(item);
                    end;
                    reaper.SetProjExtState(0,extname,GUID_it,mute);
                end;
            else;
                if mute == 0 then;
                    if not UNDO then;
                        UNDO = title1;
                        reaper.Undo_BeginBlock();
                        reaper.PreventUIRefresh(1);
                    end;
                    reaper.SetMediaItemInfo_Value(item,'B_MUTE',1);
                    local GUID_it;
                    if GUID_or_HandleAddress == 0 then;
                        GUID_it = reaper.BR_GetMediaItemGUID(item);
                    else;
                        GUID_it = reaper.JS_Window_AddressFromHandle(item);
                    end;
                    reaper.SetProjExtState(0,extname,GUID_it,mute);
                end;
            end;
        end;
        if Arc.GetSetToggleButtonOnOff(0,0)~=1 then;
            Arc.GetSetToggleButtonOnOff(1,1);
        end;
        -----
    end;
    
    if UNDO then;
        reaper.PreventUIRefresh(-1);
        reaper.Undo_EndBlock(UNDO,-1);
    end;
    
    reaper.UpdateArrange();
    
    ---------------------------------------------------------------
    ---------------------------------------------------------------
    
    local ActiveDoubleScr,stopDoubleScr;
    local function loop();
        ----- stop Double Script -------
        if not ActiveDoubleScr then;
            stopDoubleScr = (tonumber(reaper.GetExtState(extname,"stopDoubleScr"))or 0)+1;
            reaper.SetExtState(extname,"stopDoubleScr",stopDoubleScr,false);
            ActiveDoubleScr = true;
        end;
        
        local stopDoubleScr2 = tonumber(reaper.GetExtState(extname,"stopDoubleScr"));
        if stopDoubleScr2 > stopDoubleScr then return end;
        --------------------------------
        if Arc.ChangesInProject()then;
            local anyItMute = anyItemMute();
            if not anyItMute then;
                cleanProjExtState(extname);
                if Arc.GetSetToggleButtonOnOff(0,0)==1 then;
                    Arc.GetSetToggleButtonOnOff(0,1);
                end;
                return;
            end;
        end;
        reaper.defer(loop);
    end;
    reaper.defer(loop);
    
    
    
    
    