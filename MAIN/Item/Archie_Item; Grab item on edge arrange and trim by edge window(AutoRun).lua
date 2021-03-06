--[[      NEW INSTANCE
   * Тест только на windows  /  Test only on windows.
   * Отчет об ошибке: Если обнаружите какие либо ошибки, то сообщите по одной из указанных ссылок ниже (*Website)
   * Bug Reports: If you find any errors, please report one of the links below (*Website)
   *
   * Category:    Item
   * Features:    Startup
   * Description: Item; Grab item on edge arrange and trim by edge window(AutoRun).lua
   * Author:      Archie
   * Version:     1.14
   * AboutScript: ---
   * О скрипте:   Захватите элемент на краю аранжировке и обрезайте по краю окна
   * GIF:         http://avatars.mds.yandex.net/get-pdb/2883421/8cf1c573-4267-4458-acf8-21b0050c7edb/orig
   *              http://avatars.mds.yandex.net/get-pdb/2423768/3d18d682-49c3-4a64-a4cd-4df56377c0db/orig
   * Website:     http://forum.cockos.com/showthread.php?t=212819
   *              http://rmmedia.ru/threads/134701/
   *              http://vk.com/reaarchie
   * DONATION:    http://money.yandex.ru/to/410018003906628
   * DONATION:    http://paypal.me/ReaArchie?locale.x=ru_RU
   * Customer:    YuriOl(Rmm)
   * Gave idea:   YuriOl(Rmm)
   * Extension:   Reaper 6.10+ http://www.reaper.fm/
   *              SWS v.2.12.0 http://www.sws-extension.org/index.php
   *              reaper_js_ReaScriptAPI64 Repository - (ReaTeam Extensions) http://clck.ru/Eo5Nr or http://clck.ru/Eo5Lw
   *              Arc_Function_lua v.2.8.0+ (Repository: Archie-ReaScripts) http://clck.ru/EjERc
   * Changelog:
   *              v.1.12 [050720]
   *                  + fix bug mouse modifiers (http://forum.cockos.com/showthread.php?p=2314292#post2314292)

   *              v.1.07 [260520]
   *                  + No changeе
   *              v.1.06 [250520]
   *                  + refresh State Action List
   *              v.1.05 [250520]
   *                  + Fixed Bug
   *              v.1.04 [240520]
   *                  + Fixed Bug
   *              v.1.03 [240520]
   *                  + Cancel selection item
   *              v.1.02 [240520]
   *                  + No changeе
   *              v.1.0 [230520]
   *                  + initialе
--]]
    --======================================================================================
    --////////////  НАСТРОЙКИ  \\\\\\\\\\\\  SETTINGS  ////////////  НАСТРОЙКИ  \\\\\\\\\\\\
    --======================================================================================


    local PixelsToCapture = 10 -- Пикселей скраю для захвата (5)
    local offset = 2 -- pixel отступ (2)
    local ScrollBar = 19 -- pixel Полоса прокрутки справа (19)

    local DesSelItem = true  -- Отменить выделение элемента
                  -- = true  отменить
                  -- = false не отменять

    --======================================================================================
    --////////////// SCRIPT \\\\\\\\\\\\\\  SCRIPT  //////////////  SCRIPT  \\\\\\\\\\\\\\\\
    --======================================================================================


    local STARTUP = 1; -- (Not recommended change)
    --=========================================
    local function MODULE(file);
        local E,A=pcall(dofile,file);if not(E)then;reaper.ShowConsoleMsg("\n\nError - "..debug.getinfo(1,'S').source:match('.*[/\\](.+)')..'\nMISSING FILE / ОТСУТСТВУЕТ ФАЙЛ!\n'..file:gsub('\\','/'))return;end;
        if not A.VersArcFun("2.8.5",file,'')then A.no_undo()return;end;return A;
    end;local Arc=MODULE((reaper.GetResourcePath()..'/Scripts/Archie-ReaScripts/Functions/Arc_Function_lua.lua'):gsub('\\','/'));
    if not Arc then return end;
    local ArcFileIni = reaper.GetResourcePath():gsub('\\','/')..'/reaper-Archie.ini';
    --=========================================




    -------------------------------------------------------
    local function  checkUndoItem();
        if DesSelItem == true then;
            local buf = reaper.SNM_GetIntConfigVar('undomask',0);
            if buf&1 == 0 then;
                local MB =
                reaper.MB('Rus:\n\n'..
                          'Для корректной работы скрипта нужно включить отмену для элементов.\n'..
                          'Для того чтобы не выделялся элемент.\n\n'..
                          'Preferences > General > Include selection: > item (галка)\n\n'..
                          'Включить отмену для элементов ? - Ok\n\n'..
                          'Иначе внутри скрипта поменяйте значения у параметра DesSelItem на false\n\n\n'..
                          '----------------------------------\n\n\n'..
                          'Eng:\n\n'..
                          'For the script to work correctly, you need to enable undo for items.\n'..
                          'That the item not highlighted.\n\n'..
                          'Preferences> General> Include selection:> item (tick)\n\n'..
                          'Enable undo for items? - Ok\n\n'..
                          'Otherwise, inside the script, change the values ​​of the DesSelItem parameter to false\n'
                          ,'Warning',1);
                if MB == 1 then;
                    reaper.SNM_SetIntConfigVar('undomask',buf|(buf|1));
                end;
            end;
        end;
    end;
    -------------------------------------------------------


    --==v.1.12============================================================
    -- Ошибка модификатора мыши.
    -- http://forum.cockos.com/showthread.php?p=2314292#post2314292
    --[[-----------------------------------------------------
    local tMM = {};
    local function saveResetMM();
        if #tMM == 0 then;
            tMM[1] = reaper.GetMouseModifier('MM_CTX_ITEM'     ,0,'');--item--leftdrag
            tMM[2] = reaper.GetMouseModifier('MM_CTX_ITEMLOWER',0,'');--Media item bottom half--leftdrag
            reaper.SetMouseModifier('MM_CTX_ITEM',0,0);
            reaper.SetMouseModifier('MM_CTX_ITEMLOWER',0,0);
        end;
    end;

    local function restoryMM();
        if #tMM > 0 then;
            reaper.SetMouseModifier('MM_CTX_ITEM',0,tMM[1]);
            reaper.SetMouseModifier('MM_CTX_ITEMLOWER',0,tMM[2]);
            tMM = {};
        end;
    end;
    --]]-----------------------------------------------------
    -- Временное решение:
    -------------------------------------------------------
    local tMM = {};
    local function saveResetMM();
        if #tMM == 0 then;
            tMM[1] = reaper.GetMouseModifier('MM_CTX_ITEM',0,'');--item--leftdrag
            ---------
            local filePath = reaper.GetResourcePath()..'/reaper-mouse.ini';
            local retval, str = reaper.BR_Win32_GetPrivateProfileString('MM_CTX_ITEMLOWER','mm_0','',filePath);
            if retval > 0 and str ~= "" then;
                tMM[2] = reaper.GetMouseModifier('MM_CTX_ITEMLOWER',0,'');--Media item bottom half--leftdrag
            else;
                tMM[2] = 0;
            end;
            ---------
            reaper.SetMouseModifier('MM_CTX_ITEM',0,0);
            reaper.SetMouseModifier('MM_CTX_ITEMLOWER',0,0);
        end;
    end;

    local function restoryMM();
        if #tMM > 0 then;
            reaper.SetMouseModifier('MM_CTX_ITEM',0,tMM[1]);
            reaper.SetMouseModifier('MM_CTX_ITEMLOWER',0,tMM[2]);
            tMM = {};
        end;
    end;
    -------------------------------------------------------
    --==v.1.12============================================================


    -------------------------------------------------------
    local refActLst=0;
    local function refreshActionList(X,reset);
        if reset == true then refActLst=0 end;
        refActLst=refActLst+1;
        if refActLst == (X or 1) then;
            local actionList = reaper.GetToggleCommandStateEx(0,40605);
            if actionList == 1 then;
                Action(40605,40605);
            end;
        end;
    end;
    -------------------------------------------------------


    local section = 'Archie_GRAB_ITEM_ON_EDGE_ARRANGE';
    local scriptPath,scriptName = debug.getinfo(1,'S').source:match("^@(.+)[/\\](.+)");
    local extname = scriptName;


    ----------------------------------------------------------------
    local function main(FirstRn);

        --- / Счетчик для пропуска / ---
        local function Counter();
            local t={};return function(x,b)b=b or 1 t[b]=(t[b]or 0)+1 if t[b]>(x or math.huge)then t[b]=0 end return t[b]end;
        end;Counter = Counter(); -- Counter(x,buf); x=reset

        local function GetProjStateChangeCount(run);
            if run == true then;
                return reaper.GetProjectStateChangeCount(0);
            end;
        end;

        local itemX,_,ProjStateCount;

        local function loop();
            if Counter(0,1) == 0 then;
                ------------------
                --local ExtState = reaper.GetExtState(section,'TGL_SWITCH');
                local ExtState = Arc.iniFileReadLua(section,'TGL_SWITCH',ArcFileIni);
                --local ExtStTGL = tonumber(reaper.GetExtState(section,'TOGGLE_TRIM'))or 0;
                local ExtStTGL = tonumber(Arc.iniFileReadLua(section,'TOGGLE_TRIM',ArcFileIni))or 0;
                if ExtState ~= 'TRIM' or ExtStTGL == 0 then;
                    --reaper.SetExtState(section,'TOGGLE_TRIM',0,true);
                    Arc.iniFileWriteLua(section,'TOGGLE_TRIM',0,ArcFileIni);
                    Arc.GetSetToggleButtonOnOff(0,1);
                    return;
                end;
                ------------------
                local MouseState = reaper.JS_Mouse_GetState(127);
                local ScrollBarL = ScrollBar/reaper.GetHZoomLevel();
                local offsetL = offset/reaper.GetHZoomLevel();
                local edge = PixelsToCapture/reaper.GetHZoomLevel();--Пиксели в секунды
                local start_time,end_time = reaper.GetSet_ArrangeView2(0,0,0,0);
                local PosMCur = reaper.BR_PositionAtMouseCursor(false);
                local ms_x,ms_y = reaper.GetMousePosition();
                ----
                if MouseState == 0 then;
                    itemX,_ = reaper.GetItemFromPoint(ms_x,ms_y,false);
                    if itemX then;
                        local pos = reaper.GetMediaItemInfo_Value(itemX,'D_POSITION');
                        local len = reaper.GetMediaItemInfo_Value(itemX,'D_LENGTH');
                        local endPos = pos+len;
                        ----
                        if PosMCur <= start_time+edge and pos < start_time then;
                            saveResetMM();
                            reaper.JS_Mouse_SetCursor(reaper.JS_Mouse_LoadCursor(32649));
                            ProjStateCount = GetProjStateChangeCount(DesSelItem);
                        elseif PosMCur>=(end_time-ScrollBarL-edge)and endPos > end_time then;
                            saveResetMM();
                            reaper.JS_Mouse_SetCursor(reaper.JS_Mouse_LoadCursor(32649));
                            ProjStateCount = GetProjStateChangeCount(DesSelItem);
                        else;
                            restoryMM();
                        end;
                    else;
                        restoryMM();
                    end;
                end;
                ----
                if MouseState == 1 then;
                    local item,take = reaper.GetItemFromPoint(ms_x,ms_y,false);
                    if item and item == itemX then;
                        local pos = reaper.GetMediaItemInfo_Value(item,'D_POSITION');
                        local len = reaper.GetMediaItemInfo_Value(item,'D_LENGTH');
                        local endPos = pos+len;
                        ----
                        if PosMCur <= start_time+edge then;
                            ----
                            if (pos < start_time) and (endPos > (start_time+edge)) then;
                                if #tMM > 0 then;
                                    reaper.PreventUIRefresh(1);

                                    local ProjStateCount2 = GetProjStateChangeCount(DesSelItem);
                                    if ProjStateCount and ProjStateCount ~= ProjStateCount2 then;
                                        local LastAction = (reaper.Undo_CanUndo2(0)or''):upper();
                                        if LastAction:match('MEDIA%s-ITEM%s-SELECTION')then;
                                            reaper.Undo_DoUndo2(0);
                                        end;
                                    end;

                                    reaper.Undo_BeginBlock();
                                    local posNew = start_time + offsetL;
                                    Arc.SetMediaItemLeftTrim2(posNew,item);
                                    reaper.Undo_EndBlock('Trim Left',-1);
                                    reaper.PreventUIRefresh(-1);
                                    reaper.UpdateTimeline();
                                    itemX = nil;
                                end;
                            end;
                            ----
                        elseif PosMCur>=(end_time-ScrollBarL-edge)then;
                            ----
                            if #tMM > 0 then;
                                reaper.PreventUIRefresh(1);

                                local ProjStateCount2 = GetProjStateChangeCount(DesSelItem);
                                if ProjStateCount and ProjStateCount ~= ProjStateCount2 then;
                                    local LastAction = (reaper.Undo_CanUndo2(0)or''):upper();
                                    if LastAction:match('MEDIA%s-ITEM%s-SELECTION')then;
                                        reaper.Undo_DoUndo2(0);
                                    end;
                                end;

                                reaper.Undo_BeginBlock();
                                local lenNew = (end_time - pos)-ScrollBarL-offsetL;
                                reaper.SetMediaItemLength(item,lenNew,true);
                                reaper.Undo_EndBlock('Trim Right',-1);
                                reaper.PreventUIRefresh(-1);
                                reaper.UpdateTimeline();
                                itemX = nil;
                                ----
                            end;
                        end;
                        itemX = nil;
                    end;
                end;
            end;
            ------------------
            if not FirstRn then;
                refreshActionList(3);
            end;
            reaper.defer(loop);
        end;
        reaper.defer(loop);
    end;--End main
    ----------------------------------------------------------------



    ----------------------------------------------------------------
    local function run();
        --local ExtStTGL = tonumber(reaper.GetExtState(section,'TOGGLE_TRIM'))or 0;
        local ExtStTGL = tonumber(Arc.iniFileReadLua(section,'TOGGLE_TRIM',ArcFileIni))or 0;
        if ExtStTGL == 0 then;
            checkUndoItem();
            --reaper.SetExtState(section,'TGL_SWITCH','TRIM',true);
            Arc.iniFileWriteLua(section,'TGL_SWITCH','TRIM',ArcFileIni);
            --reaper.SetExtState(section,'TOGGLE_TRIM',1,true);
            Arc.iniFileWriteLua(section,'TOGGLE_TRIM',1,ArcFileIni);
            Arc.GetSetToggleButtonOnOff(1,1);
            reaper.defer(main);
        else;
            Arc.GetSetToggleButtonOnOff(0,1);
            --reaper.SetExtState(section,'TOGGLE_TRIM',0,true);
            Arc.iniFileWriteLua(section,'TOGGLE_TRIM',0,ArcFileIni);
            refreshActionList(1,true);
        end;
    end;


    local function runFirst();
        --local ExtState = reaper.GetExtState(section,'TGL_SWITCH');
        local ExtState = Arc.iniFileReadLua(section,'TGL_SWITCH',ArcFileIni);
        --local ExtStTGL = tonumber(reaper.GetExtState(section,'TOGGLE_TRIM'))or 0;
        local ExtStTGL = tonumber(Arc.iniFileReadLua(section,'TOGGLE_TRIM',ArcFileIni))or 0;
        if ExtState == 'TRIM' and ExtStTGL == 1 then;
            Arc.GetSetToggleButtonOnOff(1,1);
            reaper.defer(function()main(true)end);
        end;
    end;
    ----------------------------------------------------------------



    ---___-----------------------------------------------
    local FirstRun;
    if STARTUP == 1 then;
        --reaper.DeleteExtState(extname,"FirstRun",false);
        FirstRun = reaper.GetExtState(extname,"FirstRun")=="";
        if FirstRun then;
            reaper.SetExtState(extname,"FirstRun",1,false);
        end;
    end;
    -----------------------------------------------------


    ---------------------
    if not FirstRun then;
        run();
    elseif FirstRun then;
        runFirst();
    end;
    ---------------------


    ---___-----------------------------------------------
    local function SetStartupScriptWrite();
        local id = Arc.GetIDByScriptName(scriptName,scriptPath);
        if id == -1 or type(id) ~= "string" then Arc.no_undo()return end;
        local check_Id, check_Fun = Arc.GetStartupScript(id);
        if STARTUP == 1 then;
            if not check_Id then;
                Arc.SetStartupScript(scriptName,id);
            end;
        elseif STARTUP ~= 1 then;
            if check_Id then;
                Arc.SetStartupScript(scriptName,id,nil,"ONE");
            end;
        end;
        reaper.defer(function();
        Arc.GetSetTerminateAllInstancesOrStartNewOneKB_ini(1,516,scriptPath,scriptName)end);
    end;
    reaper.defer(SetStartupScriptWrite);
    -----------------------------------------------------





