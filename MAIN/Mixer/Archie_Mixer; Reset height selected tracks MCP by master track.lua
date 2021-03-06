--[[
   * Тест только на windows  /  Test only on windows.
   * Отчет об ошибке: Если обнаружите какие либо ошибки, то сообщите по одной из указанных ссылок ниже (*Website)
   * Bug Reports: If you find any errors, please report one of the links below (*Website)
   *
   * Description: Mixer; Reset height  selected tracks MCP by master track
   * Author:      Archie
   * Version:     1.03
   * Описание:    Микшер; Сбросить высоту выбранных дорожек MCP по главной дорожке
   * Website:     http://forum.cockos.com/showthread.php?t=212819
   *              http://rmmedia.ru/threads/134701/
   * DONATION:    http://money.yandex.ru/to/410018003906628
   * DONATION:    http://paypal.me/ReaArchie?locale.x=ru_RU
   * Customer:    YuriOl(RMM)
   * Gave idea:   YuriOl(RMM)
   * Extension:   Reaper 6.03+ http://www.reaper.fm/
   * Changelog:
   *              v.1.0 [18.02.20]
   *                  + initialе
--]]
    --======================================================================================
    --////////////// SCRIPT \\\\\\\\\\\\\\  SCRIPT  //////////////  SCRIPT  \\\\\\\\\\\\\\\\
    --======================================================================================



    -------------------------------------------------------
    local function no_undo()reaper.defer(function()end)end;
    -------------------------------------------------------


    local CountSelTrack = reaper.CountSelectedTracks(0);
    if CountSelTrack == 0 then no_undo() return end;


    local MasterTrack = reaper.GetMasterTrack(0);
    local retval, strM = reaper.GetTrackStateChunk(MasterTrack,'',false);

    local strM2 = strM:match('SHOWINMIX.-\n');

    local trHeight,Fxparam,trInsertFx = strM2:match('SHOWINMIX%s+%S+%s+(%S+)%s+(%S+)%s+%S+%s+(%S+)');

    if trHeight and Fxparam and trInsertFx then;

        reaper.Undo_BeginBlock();
        reaper.PreventUIRefresh(1);

        for i = 1,CountSelTrack do;
            local track = reaper.GetSelectedTrack(0,i-1);
            ----
            local retval, str = reaper.GetTrackStateChunk(track,'',false);
            local str2 = str:match('SHOWINMIX.-\n');

            local x = -1;
            local STR = '';
            for val in string.gmatch(str2,"%S+") do;
               x = x + 1;
               if x == 2 then val = trHeight end;
               if x == 3 then val = Fxparam end;
               if x == 5 then val = trInsertFx end;
               STR = STR..val..' ';
            end;

            STR = str:gsub('SHOWINMIX.-\n',STR..'\n');

            reaper.SetTrackStateChunk(track,STR,false);
            ------
        end;

        reaper.PreventUIRefresh(-1);
        reaper.Undo_EndBlock('Reset height  selected tracks MCP by master track',-1);
    end;

