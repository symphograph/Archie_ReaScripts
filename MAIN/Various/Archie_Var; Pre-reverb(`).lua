--[[
   * Тест только на windows  /  Test only on windows.
   * Отчет об ошибке: Если обнаружите какие либо ошибки, то сообщите по одной из указанных ссылок ниже (*Website)
   * Bug Reports: If you find any errors, please report one of the links below (*Website)
   *
   * Category:    Various
   * Description: Var; Pre-reverb(`).lua
   * Author:      Archie
   * Version:     1.21
   * Описание:    Предварительная реверберация
   * GIF:         Пошаговое выполнение скрипта (как скрипт делает пре ревер)
   *              http://avatars.mds.yandex.net/get-pdb/2745165/83870370-824b-4932-a4c6-a4aa6fa4fc5e/orig
   * Website:     http://forum.cockos.com/showthread.php?t=212819
   *              http://rmmedia.ru/threads/134701/
   * DONATION:    http://money.yandex.ru/to/410018003906628
   * DONATION:    http://paypal.me/ReaArchie?locale.x=ru_RU
   * Customer:    Archie(---)
   * Gave idea:   Archie(---)
   * Extension:   Reaper 6.10+ http://www.reaper.fm/
   *              SWS v.2.12.0 http://www.sws-extension.org/index.php
   *              Arc_Function_lua v.2.8.2+  (Repository: Archie-ReaScripts) http://clck.ru/EjERc
   * Changelog:
   *              v.1.18 [180720]
   *                 !+ Error correction

   *              v.1.16/1.17 [180720]
   *                 + Water in bars / Ввод в тактах http://forum.cockos.com/showpost.php?p=2320799&postcount=9
   *              v.1.11 [110620]
   *                 !+ Fixed bugs signal offset when the 'Default tail length' value is not zero:'
   *                  + Add Trim right
   *                  + ----
   *                 !+ Исправить смещение сигнала при ненулевом значении 'Default tail length:'
   *                  + Добавить обрезку справа

   *              v.1.04 [110520]
   *                  + The script was converted to a template
   *                  + ----
   *                  + Скрипт переделан в шаблон
   *              v.1.03 [100520]
   *                  + Ability to save the track template in a subdirectory
   *                  + -----
   *                  + Возможность сохранения шаблона трека в подкаталоге
   *              v.1.02 [11.04.20]
   *                  + Possibility of arithmetic operations in the input field
   *                  + Cleaning up intermediate files in a directory
   *                  + Fixed bug when working with multiple items at the same time
   *                  + automatic channel detection
   *                  + -----
   *                  + Возможность арифметических действий в поле ввода
   *                  + Зачистка от промежуточных файлов в директории
   *                  + Исправлена ошибка при работе с несколькими элементами одновременно
   *                  + автоопределение каналов
   *              v.1.0 [11.12.19]
   *                  + initialе
--]]
    --======================================================================================
    --////////////  НАСТРОЙКИ  \\\\\\\\\\\\  SETTINGS  ////////////  НАСТРОЙКИ  \\\\\\\\\\\\
    --======================================================================================



    local MEASURE = false;
           --  = true  | время ввода в тактах
           --  = false | время ввода в сек
           -------------------------------



    local Tail_Rever = true;
                 --  = true  | показать окно для ввода времени хвоста
                 --  = false | хвост по размеру выбора времени
                 --  = 1.50..| или введите время в сек
                 -------------------------------------



    local FADEIN  = true;
              --  = true  | on fade in
              --  = false | off fade in
              -------------------------



    local FADEOUT = true;
             --  = true  |  on fade out
             --  = false | off fade out
             --------------------------



    local IN_SHAPE  = 0; -- 0..6, 0=linear, -1 default
    local OUT_SHAPE = 2; -- 0..6, 0=linear, -1 default
                         -----------------------------



    local TRIM_RIGHT = true
                 --  = true  | Обрезка справа
                 --  = false | Нет обрезки справа
                 --------------------------------



    local snapToGrid = true;
                  -- = true  | Ровнять по ближайшей сетке
                  -- = false | Не ровнять по сетке, рендерить четко по времени (Tail_Rever)
                  -------------------------------------------------------------------------



    local Pre_Vol_Track = true;
                     -- = true  | Перед громкостью на треке
                     -- = false | После громкости на треке
                     -------------------------------------



    local Pre_Pan_Track = true;
                     -- = true  | Перед панорамой на треке
                     -- = false | После панорамой на треке
                     -------------------------------------



    local PreFxTrack = false;
                  -- = true  Перед эффектами на треке
                  -- = false После эффектов на треке
                  ----------------------------------



    local Remove_Time_Silection = true;
                             -- = true  | Удалить выбор времени
                             -- = false | Не удалять выбор времени
                             -------------------------------------



    local Channel = 4;
               -- = 1 mono         / Track: Render selected area of tracks to mono post-fader stem tracks (and mute originals)
               -- = 2 stereo       / Track: Render selected area of tracks to stereo post-fader stem tracks (and mute originals)
               -- = 3 multichannel / Track: Render selected area of tracks to multichannel post-fader stem tracks (and mute originals)
               -- = 4 Определить автоматически / Detect it automatically
               ---------------------------------------------------------



    local PathTemplates = [[]]; -- Путь шаблона, без файла (Необязятельно). Например: PathTemplates = [[c:\bla\bla\bla]];
                                -----------------------------------------------------------------------------------------


    -------------------------------------------------------------------
    -- В шаблоне (Archie_Var; Pre-reverb(`).lua) этот параметр не менять
    -- Do not change this parameter in the template (Archie_Var; Pre-reverb(`).lua)
    local NameTemplates = [[$ArchiePreVerb$]]; -- Имя шаблона(Необходимо при дублировании скрипта для другого ревера)
    -------------------------------------------------------------------



    local Name_Track = nil
                  -- = 'Имя трека'
                  -- По умолчанию Name_Track = nil
                  -- или введите имя, например:
                  -- Name_Track = 'мои трек';
                  or 'Pre Reverb '..'('..NameTemplates..')'..'$Track';
                  ----------------------------------------------------



    --======================================================================================
    --////////////// SCRIPT \\\\\\\\\\\\\\  SCRIPT  //////////////  SCRIPT  \\\\\\\\\\\\\\\\
    --======================================================================================




    --=========================================
    local function MODULE(file);
        local E,A=pcall(dofile,file);if not(E)then;reaper.ShowConsoleMsg("\n\nError - "..debug.getinfo(1,'S').source:match('.*[/\\](.+)')..'\nMISSING FILE / ОТСУТСТВУЕТ ФАЙЛ!\n'..file:gsub('\\','/'))return;end;
        if not A.VersArcFun("2.8.5",file,'')then A.no_undo()return;end;return A;
    end;local Arc=MODULE((reaper.GetResourcePath()..'/Scripts/Archie-ReaScripts/Functions/Arc_Function_lua.lua'):gsub('\\','/'));
    if not Arc then return end;
    local ArcFileIni = reaper.GetResourcePath():gsub('\\','/')..'/reaper-Archie.ini';
    --=========================================



    local function PreReverbRun();

        --=================================================================
        local function GetCountTactsForTimePeriod(startLoop,endLoop);
            -- Получить Подсчет Тактов За Период Времени;
            local Sbuf1 = reaper.format_timestr_pos(startLoop,'',2):match('%d+');--takt meas
            local Sbuf2 = reaper.parse_timestr_pos(Sbuf1+0,2);--start takt sec
            local Sbuf3 = reaper.parse_timestr_pos(Sbuf1+1,2);--end takt sec
            local SFF1 = Sbuf3 - Sbuf2;--takt in sec
            local SFF2 = startLoop - Sbuf2;--from start tact to time startLoop in sec
            local SFF3 = SFF2 / SFF1;
            local SBuf1 = Sbuf1;
            ------------------------------
            local Ebuf1 = reaper.format_timestr_pos(endLoop,'',2):match('%d+');
            local Ebuf2 = reaper.parse_timestr_pos(Ebuf1+0,2);
            local Ebuf3 = reaper.parse_timestr_pos(Ebuf1+1,2);
            local EFF1 = Ebuf3 - Ebuf2;
            local EFF2 = endLoop - Ebuf2;
            local EFF3 = EFF2 / EFF1;
            local EBuf1 = Ebuf1;
            local RET = (EBuf1 + EFF3)-(SBuf1 + SFF3);
            return RET;
        end;
        --====================================================
        local function GetOppositeTimeBySizeOfTact(time,tact);
            --Получите Противоположное Время По Размеру Такта
            local Sbuf1 = reaper.format_timestr_pos(time,'',2):match('%d+');--takt meas
            local Sbuf2 = reaper.parse_timestr_pos(Sbuf1+0,2);--start takt sec
            local Sbuf3 = reaper.parse_timestr_pos(Sbuf1+1,2);--end takt sec
            local SFF1 = Sbuf3 - Sbuf2;--takt in sec
            local SFF2 = time - Sbuf2;--from(от) start tact to time startLoop in sec
            local SFF3 = SFF2 / SFF1;
            local SBuf1 = Sbuf1;
            --------------
            local TCT = SBuf1 + tact + SFF3;
            --------------
            local X1,X2 = math.modf(TCT);
            local buf = reaper.parse_timestr_pos(X1,2);
            local buf2 = reaper.parse_timestr_pos(X1+1,2);
            local RET = ((buf2 - buf)* X2)+buf;
            return RET,TCT;
        end;
        --=================================================================



        --==================================================================================================================
        local function EnumerateAllDirectoriesAndSubdirectories(path);
            local T = {};
            path = path:gsub('\\','/');
            for i = 0,math.huge do;
                local Subdirectories = reaper.EnumerateSubdirectories(path,i);
                if Subdirectories then;
                    T[#T+1] = path..'/'..Subdirectories;
                else;
                    break;
                end;
            end;
            ::REPEAT::;
            local X = #T;
            for i = 1,#T do;
                for i2 = 0,math.huge do;
                    local Subdirectories = reaper.EnumerateSubdirectories(T[i],i2);
                    if Subdirectories then;
                        local SKIP = nil;
                        for i3 = 1,#T do;
                            if T[i3]==T[i]..'/'..Subdirectories then SKIP = true break end;
                        end;
                        if not SKIP then;
                            T[#T+1] = T[i]..'/'..Subdirectories;
                        end;
                    else;
                        break;
                    end;
                end;
            end;
            if #T ~= X then goto REPEAT end;
            table.insert(T,1,path);
            return T;
        end;
        ----------------
        PathTemplates = PathTemplates:gsub('\\','/');
        if type(NameTemplates)~="string" then NameTemplates = "ArchiePreVerb"end;
        local NmTemp = NameTemplates:upper():match('RTRACKTEMPLATE%s-$');
        if NmTemp then;
            NameTemplates = NameTemplates:gsub(('.'):rep(#NmTemp)..'$','');
        end;
        if #NameTemplates:gsub("%s","")==0 then NameTemplates = "ArchiePreVerb"end;
        ----
        local file = io.open(PathTemplates..'/'..NameTemplates..'.RTrackTemplate');
        if not file then;
            local ResPath1 = reaper.GetResourcePath():gsub('\\','/')..'/TrackTemplates';
            --local ResPath2 = reaper.GetExtState('ARCHIE_VAR_PRE-REVERB_LUA','Path-'..NameTemplates);
            local ResPath2 = Arc.iniFileReadLua('ARCHIE_VAR_PRE-REVERB_LUA','Path-'..NameTemplates,ArcFileIni,false);
            file = io.open(ResPath1..ResPath2..'/'..NameTemplates..'.RTrackTemplate');
            if not file then;
                file = io.open(ResPath1..'/'..NameTemplates..'.RTrackTemplate');
                if not file then;
                    local Subdir = EnumerateAllDirectoriesAndSubdirectories(ResPath1);
                    for i = 1,#Subdir do;
                        for i2 = 1, math.huge do;
                            local Files = reaper.EnumerateFiles(Subdir[i],i2-1);
                            if Files then;
                                local FilesX = Files:upper();
                                if FilesX == (NameTemplates..".RTrackTemplate"):upper()then;
                                    file = io.open(Subdir[i]..'/'..Files);
                                    if file then;
                                        dir = Subdir[i]:gsub('\\','/'):gsub(ResPath1:gsub('\\','/'),'');
                                        --reaper.SetExtState('ARCHIE_VAR_PRE-REVERB_LUA','Path-'..NameTemplates,dir,true);
                                        Arc.iniFileWriteLua('ARCHIE_VAR_PRE-REVERB_LUA','Path-'..NameTemplates,dir,ArcFileIni,false,true);
                                        break;
                                    end;
                                end;

                            else;
                                break;
                            end;
                        end;
                    end;
                end;
            end;
        end;
        ----
        local strTemplate;
        if not file then;
            local MB =
            reaper.MB("Eng:\n\nThe script did not find a track template named '"..NameTemplates.."' \n"..
                      "Save a track template with a customized reverb named '"..NameTemplates.."' - Cancel\nDelete this script - Ok\n\n\n"..
                      "Rus:\n\nСкрипт не нашел шаблон трека с именем '"..NameTemplates.."' \n"..
                      "Сохраните шаблон трека с настроенным ревербератором с именем '"..NameTemplates.."' - отмена\nУдалить данный скрипт - Ok"
                      ,"Woops - (Track Templates)",1);
            --[ v1.04
            if MB==1 then;
                local _,filename,_,_,_,_,_ = reaper.get_action_context();
                os.remove(filename);
                reaper.AddRemoveReaScript(false,0,filename,true);
                reaper.DeleteExtState('ARCHIE_VAR_PRE-REVERB_LUA','Path-'..NameTemplates,true);
                Arc.iniFileWriteLua('ARCHIE_VAR_PRE-REVERB_LUA','Path-'..NameTemplates,'',ArcFileIni,false,true);
            end;
            --]]
            Arc.no_undo()return;
        else;
            strTemplate = file:read("a");
            file:close();
        end;
        --==================================================================================================================




        --===================================
        local function compare(x,y);
            return math.abs(x-y)<0.0000001;
        end;
        --===================================




        --=====================================================
        local CountSelItem = reaper.CountSelectedMediaItems(0);
        if CountSelItem == 0 then;
            reaper.MB("No selected items !\n\nНет выбранных элементов !","Woops",0);
            no_undo()return;
        end;
        --=====================================================




        --=====================================================
        local startLoop, endLoop = reaper.GetSet_LoopTimeRange(0,0,0,0,0);
        if startLoop == endLoop then;
            reaper.MB("No time selection !\n\nНет выбора времени !","Woops",0);
            no_undo() return;
        end;
        --=====================================================




        --=====================================================
        local SelItemT = {};
        local selInTimeSel;
        for i = 1,CountSelItem do;
            local SelItem = reaper.GetSelectedMediaItem(0,i-1);
            local posIt = reaper.GetMediaItemInfo_Value(SelItem,"D_POSITION");
            local lenIt = reaper.GetMediaItemInfo_Value(SelItem,"D_LENGTH");
            if posIt < endLoop and posIt+lenIt > startLoop then;
                selInTimeSel = true;
                SelItemT[#SelItemT+1]=SelItem;
            end;
        end;

        if not selInTimeSel then;
            reaper.MB("No items in time selection !\n\nНет элементов в выборе времени !","Woops",0);
            no_undo() return;
        end;
        --=====================================================




        --=====================================================
        if not tonumber(Tail_Rever) and Tail_Rever ~= true then Tail_Rever = false end;
        local TktStart = math.huge;
        if Tail_Rever == true then;
            if MEASURE == true then;--<<--v.1.16
                --(v.1.16------------------
                local val = GetCountTactsForTimePeriod(startLoop,endLoop);
                val = tonumber(string.format("%.4f", val));
                local retval,retvals_csv = reaper.GetUserInputs("Pre Verb",1,"Value in Tact (0 = time selection),extrawidth=60",val);
                if not retval then no_undo()return end;
                if retvals_csv:match('^[%+%-%*%/]')then;
                    retvals_csv = val..retvals_csv;
                end;
                retvals_csv = retvals_csv:gsub('[,;]','.');
                local _,retvals_csv = pcall(load('return '..retvals_csv));
                retvals_csv = tonumber(retvals_csv);
                if not retvals_csv or retvals_csv <= 0 then;
                    retvals_csv = (endLoop-startLoop);
                else;
                    retvals_csv,TktStart = GetOppositeTimeBySizeOfTact(startLoop,invert_number(retvals_csv));
                    retvals_csv = startLoop - retvals_csv;
                end;
                Tail_Rever=retvals_csv;
                --v.1.16)------------------
            else;--<<--v.1.16
                local val = tonumber(string.format("%.4f", endLoop-startLoop));--v.1.02
                local retval,retvals_csv = reaper.GetUserInputs("Pre Verb",1,"Value in sec. (0 = time selection),extrawidth=60",val);
                if not retval then no_undo() return end;
                if retvals_csv:match('^[%+%-%*%/]')then;--v.1.02
                    retvals_csv = val..retvals_csv--v.1.02
                end;--v.1.02
                retvals_csv = retvals_csv:gsub('[,;]','.');--v.1.02
                local _,retvals_csv = pcall(load('return '..retvals_csv));--v.1.02
                retvals_csv = tonumber(retvals_csv);
                if not retvals_csv or retvals_csv <= 0 then;
                    retvals_csv = (endLoop-startLoop);
                end;
                Tail_Rever=retvals_csv;
            end;--<<--v.1.16
        elseif not Tail_Rever or Tail_Rever <= 0 then;
            Tail_Rever = (endLoop-startLoop);
        end;
        --=====================================================



        --=====================================================
        if (startLoop - Tail_Rever < 0) or (TktStart < 1) then;
            reaper.MB("The tail does not fit, there is too little space at the beginning !\n\nХвост не помещается, слишком мало место в начале !","Woops !!!",0);
            no_undo() return;
        end;
        --=====================================================





        --=========================




        --=========================
        reaper.Undo_BeginBlock();
        reaper.PreventUIRefresh(1);
        --=========================




        --=====================================================
        --Waveform media peak caching settings
        local ShowStatusWindow = reaper.SNM_GetIntConfigVar("showpeaksbuild",0);
        if ShowStatusWindow == 1 then;
            reaper.SNM_SetIntConfigVar("showpeaksbuild",0);
        end;
        --=====================================================




        --=====================================================
        --Rendering > Rendering settings > Default tail length:
        local rendertail_Var = reaper.SNM_GetIntConfigVar("rendertail",0);
        if rendertail_Var ~= 0 then;
            reaper.SNM_SetIntConfigVar("rendertail",0);
        end;
        --=====================================================




        --=====================================================
        ---(v.1.02
        if Channel == 4 then;
            local retChan = -1;
            local ChanSrc;
            for i = 1, #SelItemT do;
                local take = reaper.GetActiveTake(SelItemT[i]);
                local isMidi = reaper.TakeIsMIDI(take);
                if not isMidi then;
                    local source = reaper.GetMediaItemTake_Source(take);
                    source = reaper.GetMediaSourceParent(source)or source;
                    ChanSrc = reaper.GetMediaSourceNumChannels(source);
                    local chan = reaper.GetMediaItemTakeInfo_Value(take,"I_CHANMODE");
                    if chan == 1 then ChanSrc = 2 end;
                    if chan > 1 and chan < 5 then ChanSrc = 1 end;
                else;
                    ChanSrc = 2;
                end;
                if ChanSrc > retChan then retChan = ChanSrc end;
                if retChan > 2 then break end;
            end;
            if retChan <= 0 then retChan = 2 end;
            Channel = retChan;
            if Channel < 1 then Channel = 1 end;
            if Channel > 3 then Channel = 3 end;
        end;
        --- v.1.02)
        --=====================================================




        --=====================================================
        reaper.Main_OnCommand(40297,0);-- Unselect all tracks
        for i = 1,#SelItemT do;
            local Track = reaper.GetMediaItem_Track(SelItemT[i]);
            reaper.SetMediaTrackInfo_Value(Track,"I_SELECTED",1);
        end;
        --=====================================================




        --=====================================================
        -- / Save Mute Vol Pan Fx tr / --
        --local NAME_X;
        local CountSelTrack = reaper.CountSelectedTracks(0);
        local STrT = {};
        for i = 1,CountSelTrack do;
            STrT[i] = {};
            STrT[i].SelTrack = reaper.GetSelectedTrack(0,i-1);
            STrT[i].Mute = reaper.GetMediaTrackInfo_Value(STrT[i].SelTrack,"B_MUTE");
            STrT[i].Solo = reaper.GetMediaTrackInfo_Value(STrT[i].SelTrack,"I_SOLO");
            -----
            if Pre_Vol_Track == true then;
                STrT[i].vol = reaper.GetMediaTrackInfo_Value(STrT[i].SelTrack,"D_VOL");
                reaper.SetMediaTrackInfo_Value(STrT[i].SelTrack,"D_VOL",1);
            end;
            if Pre_Pan_Track == true then;
                STrT[i].pan = reaper.GetMediaTrackInfo_Value(STrT[i].SelTrack,"D_PAN");
                reaper.SetMediaTrackInfo_Value(STrT[i].SelTrack,"D_PAN",0);
            end;
            -----
            if PreFxTrack == true then;
                local CountFX = reaper.TrackFX_GetCount(STrT[i].SelTrack);
                local Instrument = reaper.TrackFX_GetInstrument(STrT[i].SelTrack);
                STrT[i].FxEnabled = {};

                for ifx = 1,CountFX do;
                    STrT[i].FxEnabled[ifx] = reaper.TrackFX_GetEnabled(STrT[i].SelTrack,ifx-1);
                    if ifx-1 ~= Instrument then;
                        reaper.TrackFX_SetEnabled(STrT[i].SelTrack,ifx-1,false);
                    end;
                end;
            end;
            -----
            local _,name = reaper.GetSetMediaTrackInfo_String(STrT[i].SelTrack,"P_NAME",'',0);
            if name ~= '' then name = name..'&'end;
            NAME_X = (NAME_X or '')..name;
            -----
        end;
        if NAME_X ~= '' then;
            NAME_X = '('..NAME_X:gsub('&$','')..')';
        end;
        --=====================================================




        --=====================================================
        if Channel~=1 and Channel~=2 and Channel~=3 then Channel=2 end;
        local ChanT = {41718,41716,41717};
        reaper.Main_OnCommand(ChanT[Channel],0);--render
        reaper.SelectAllMediaItems(0,0);
        --=====================================================




        --=====================================================
        local SelTrack = reaper.GetSelectedTrack(0,0);
        local numb = reaper.GetMediaTrackInfo_Value(SelTrack,"IP_TRACKNUMBER");
        reaper.InsertTrackAtIndex(numb-1,false);
        local TrackPreVerb = reaper.GetTrack(0,numb-1);
        reaper.SetTrackStateChunk(TrackPreVerb,strTemplate,false);
        reaper.SetMediaTrackInfo_Value(TrackPreVerb,"D_VOL",1);
        reaper.SetMediaTrackInfo_Value(TrackPreVerb,"D_PAN",0);
        --=====================================================




        --=====================================================
        local CountTrItems = reaper.CountTrackMediaItems(TrackPreVerb);
        for i = 1,CountTrItems do;
            local item = reaper.GetTrackMediaItem(TrackPreVerb,i-1);
            reaper.DeleteTrackMediaItem(TrackPreVerb,item);
        end;
        --=====================================================




        --=====================================================
        local CountTrackEnvelopes = reaper.CountTrackEnvelopes(TrackPreVerb);
        for ienv = 1, CountTrackEnvelopes do;
            local TrackEnv = reaper.GetTrackEnvelope(TrackPreVerb,ienv-1);
            local retval,str = reaper.GetEnvelopeStateChunk(TrackEnv,"",false);
            if str:match("ACT%s-(%d+)")~='0'then;
                 str = str:gsub("ACT%s-%d+","ACT 0");
                 reaper.SetEnvelopeStateChunk(TrackEnv,str,false);
            end;
        end;
        --=====================================================




        --=====================================================
        for i = reaper.CountSelectedTracks(0)-1,0,-1 do;
            local SelTrack = reaper.GetSelectedTrack(0,i);
            local CountTrItems = reaper.CountTrackMediaItems(SelTrack);
            for ii = CountTrItems-1,0,-1 do;
                local item = reaper.GetTrackMediaItem(SelTrack,ii);
                reaper.MoveMediaItemToTrack(item,TrackPreVerb);
            end;
        end;
        reaper.Main_OnCommand(40005,0);--Track: Remove tracks
        --=====================================================




        --=====================================================
        local Tail;
        if snapToGrid == true then;
            Tail = reaper.SnapToGrid(0,startLoop-Tail_Rever);
            if compare(Tail,startLoop)then;
                Tail = startLoop-Tail_Rever;
            end;
        else;
            Tail = startLoop - Tail_Rever
        end;
        reaper.GetSet_LoopTimeRange(1,0,Tail,endLoop,0);
        --=====================================================



        --=====================================================
        local strtLp, endLp = reaper.GetSet_LoopTimeRange(0,0,0,0,0);
        reaper.SelectAllMediaItems(0,0);
        local remfileT = {};
        local CountTrItems = reaper.CountTrackMediaItems(TrackPreVerb);
        for i = 1,CountTrItems do;
            local item = reaper.GetTrackMediaItem(TrackPreVerb,i-1);
            ---
            reaper.SetMediaItemInfo_Value(item,"D_POSITION",strtLp);
            ---
            reaper.SetMediaItemInfo_Value(item,"B_UISEL",1);
            ---(v.1.02
            local take = reaper.GetActiveTake(item);
            local source = reaper.GetMediaItemTake_Source(take);
            local source = reaper.GetMediaSourceParent(source)or source;
            local filenamebuf = reaper.GetMediaSourceFileName(source,'');
            if type(filenamebuf)=='string'and filenamebuf ~= '' then;
                remfileT[#remfileT+1] = filenamebuf;
            end;
            ---v.1.02)
        end;
        ---(v.1.02
        reaper.Main_OnCommand(40919,0); -- Set item mix behavior to always mix
        ---v.1.02)
        reaper.Main_OnCommand(41051,0); -- Toggle take reverse
        --=====================================================





        --=====================================================
        if type(Name_Track)~='string'or #Name_Track:gsub('[%s.,;"]','')==0 then Name_Track='Pre Reverb'end;
        reaper.SetOnlyTrackSelected(TrackPreVerb);
        ----
        ::TRK::
        local Name_Track2 = Name_Track:upper();
        local numF,numE = string.find(Name_Track2,"$TRACK");
        if numF and numE then;
            Name_Track = Name_Track:gsub((Name_Track:sub(numF,numE)),NAME_X);
            goto TRK;
        end;
        ----
        reaper.GetSetMediaTrackInfo_String(TrackPreVerb,"P_NAME",Name_Track,1);
        ----
        reaper.Main_OnCommand(ChanT[Channel],0);--render
        local TrackPreVerbReady = reaper.GetSelectedTrack(0,0);
        reaper.GetSetMediaTrackInfo_String(TrackPreVerbReady,"P_NAME",Name_Track,1);
        ----
        reaper.SetOnlyTrackSelected(TrackPreVerb);
        reaper.Main_OnCommand(40005,0);--Track: Remove tracks
        reaper.SetOnlyTrackSelected(TrackPreVerbReady);
        reaper.GetSet_LoopTimeRange(1,0,startLoop,endLoop,0);
        ----
        local CountTrItems = reaper.CountTrackMediaItems(TrackPreVerbReady);
        for i = 1,CountTrItems do;
            local item = reaper.GetTrackMediaItem(TrackPreVerbReady,i-1);
            reaper.SetMediaItemInfo_Value(item,"B_UISEL",1);
            ---(v.1.02
            local tk = reaper.GetActiveTake(item);
            reaper.GetSetMediaItemTakeInfo_String(tk,'P_NAME',Name_Track,1);
            ---v.1.02)
        end;
        reaper.Main_OnCommand(41051,0); -- Toggle take reverse
        --=====================================================




        --=====================================================
        for i = 1,#STrT do;
            reaper.SetMediaTrackInfo_Value(STrT[i].SelTrack,"B_MUTE",STrT[i].Mute);
            reaper.SetMediaTrackInfo_Value(STrT[i].SelTrack,"I_SOLO",STrT[i].Solo);
            ----
            if Pre_Vol_Track == true then;
                reaper.SetMediaTrackInfo_Value(STrT[i].SelTrack,"D_VOL",STrT[i].vol);
            end;
            if Pre_Pan_Track == true then;
                reaper.SetMediaTrackInfo_Value(STrT[i].SelTrack,"D_PAN",STrT[i].pan);
            end;
            ----
            if PreFxTrack == true then;
                for ifx = 1, #STrT[i].FxEnabled do;
                    reaper.TrackFX_SetEnabled(STrT[i].SelTrack,ifx-1,STrT[i].FxEnabled[ifx]);
                end;
            end;
        end;
        --=====================================================




        --=====================================================
        -- / fade in out / Trim / --
        if FADEIN == true or FADEOUT == true or TRIM_RIGHT then;
            local CountSelItem = reaper.CountSelectedMediaItems(0);
            for i = 1,CountSelItem do;
                local SelItem = reaper.GetSelectedMediaItem(0,i-1);
                if FADEIN == true then;
                    if tonumber(IN_SHAPE) and IN_SHAPE >= 0 and IN_SHAPE <= 6 then;
                        reaper.SetMediaItemInfo_Value(SelItem,"C_FADEINSHAPE",IN_SHAPE);
                    end;
                    reaper.SetMediaItemInfo_Value(SelItem,"D_FADEINLEN",startLoop-Tail);
                end;
                ----
                if (FADEOUT == true and TRIM_RIGHT ~= true)or
                   (FADEOUT == true and FADEIN == true) then;
                    if tonumber(OUT_SHAPE)and OUT_SHAPE >= 0 and OUT_SHAPE <= 6 then;
                        reaper.SetMediaItemInfo_Value(SelItem,"C_FADEOUTSHAPE",OUT_SHAPE);
                    end;
                    reaper.SetMediaItemInfo_Value(SelItem,"D_FADEOUTLEN",endLoop-startLoop);
                end;
                ----
                if TRIM_RIGHT == true then;
                    local pos = reaper.GetMediaItemInfo_Value(SelItem,"D_POSITION");
                    reaper.SetMediaItemInfo_Value(SelItem,"D_LENGTH",startLoop-pos);
                end;
            end;
        end;
        --=====================================================




        --=====================================================
        --Rendering > Rendering settings > Default tail length:
        if rendertail_Var ~= 0 then;
            reaper.defer(function()reaper.SNM_SetIntConfigVar("rendertail",rendertail_Var)end);
        end;
        --=====================================================


        --=====================================================
        --Waveform media peak caching settings
        if ShowStatusWindow == 1 then;
            reaper.defer(function()reaper.SNM_SetIntConfigVar("showpeaksbuild",1)end);
        end;
        --=====================================================


        --=====================================================
        if Remove_Time_Silection == true then;
            reaper.GetSet_LoopTimeRange(1,0,0,0,0);
        end;
        --=====================================================


        ---(v.1.02---------------------------
        reaper.defer(function();
                     for i = 1,#remfileT do;
                         os.remove(remfileT[i]);
                     end;end);
        ---v.1.02)---------------------------



        --=========================
        reaper.PreventUIRefresh(-1);
        reaper.Undo_EndBlock("Pre-reverb ("..NameTemplates..')',-1);
        reaper.UpdateArrange();
        --=========================
        --=========================
    end;
    --RUN = PreReverbRun();
    -----------------------------------------------------------------
    -----------------------------------------------------------------
    -----------------------------------------------------------------
    -----------------------------------------------------------------
    -----------------------------------------------------------------
    -----------------------------------------------------------------



    local function msgGui(msg);
        gfx.init("Help",580,350,0,50,50);
        local function def();
            gfx.x,gfx.y = 10,5;
            gfx.gradrect(0,0,gfx.w,gfx.h,.2,.2,.2,1);
            gfx.setfont(1,"Arial",20,0);
            gfx.drawstr(msg);
            if gfx.getchar()<0 then return end;
            reaper.defer(def);
        end;
        reaper.defer(def);
    end;


    local is_new_value,filename,sectionID,cmdID,mode,resolution,val = reaper.get_action_context();
    local filePath = filename:match('(.+)[/\\].+');
    local file = io.open(filename);
    if not file then return end;
    local strScr = file:read("a");
    file:close();


    ::rest::;
    local retval,retvals_csv = reaper.GetUserInputs("Archie Pre Verb",1,"Enter Tag (>= 3 symbol),extrawidth=100",'ArchiePreVerb');
    if not retval then no_undo() return end;
    retvals_csv = retvals_csv:gsub('[^%w%p]','');
    if #retvals_csv:gsub('%s','')<3 then goto rest end;


    local Var;
    local NmeTemp;
    local t = {};
    for S in string.gmatch(strScr..'\n',".-\n") do;

        if S:match('%s-local%s+NameTemplates%s-%=%s-%[%[%$.-%$%]%]')and not NmeTemp then;
            Var = S:gsub('NameTemplates%s-%=%s-%[%[%$.-%$%]%]','NameTemplates = [['..retvals_csv..']]');
            if Var ~= S then S = Var Var = true end;
            NmeTemp = true;
        end;

        if S:match('%s-%-%-%s-RUN%s-%=%s-PreReverbRun%s-%(.-%)')then;
            S = "    RUN = PreReverbRun();\n\n\n\n\n\n\n\n\n\n";
        end;

        table.insert(t,S);

        if S:match('%s-RUN%s-%=%s-PreReverbRun%s-%(.-%).-')then;
            break;
        end;
    end;

    if Var ~= true then no_undo() return end;


    local NewScript = filePath..'/Archie_Var; Pre-reverb('..retvals_csv..').lua';
    file = io.open(NewScript,'w');
    local wrt = file:write(table.concat(t));
    file:close();
    if type(wrt)~='userdata'then no_undo() return end;

    reaper.AddRemoveReaScript(true,0,NewScript,true);

    local scr = NewScript:match('.+[/\\](.+)');

    msgGui(
    'Скрипт успешно создан\nИщите в экшен листе\n'..scr..'\nСохраните трек темплейт с настроенным ревербератором с именем\n'..retvals_csv..'\n\nИмя скрипта скопировано в буфер обмена\n\n\n\n'..
    'Script was successfully created\nSearch in the action list\n'..scr..'\nSave the track template with the reverb set up with the name\n'..retvals_csv..'\n\nScript name is copied to the clipboard');
    reaper.CF_SetClipboard(scr);






