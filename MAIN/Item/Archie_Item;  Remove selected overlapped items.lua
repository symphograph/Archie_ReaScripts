--[[
   * Тест только на windows  /  Test only on windows.
   * Отчет об ошибке: Если обнаружите какие либо ошибки, то сообщите по одной из указанных ссылок ниже (*Website)
   * Bug Reports: If you find any errors, please report one of the links below (*Website)
   *
   * Category:    Item
   * Description: Item;  Remove selected overlapped items
   * Author:      Archie
   * Version:     1.0
   * Описание:    Удаление выбранных перекрывающихся элементов
   * Website:     http://forum.cockos.com/showthread.php?t=212819
   *              http://rmmedia.ru/threads/134701/
   * DONATION:    http://money.yandex.ru/to/410018003906628
   * Customer:    Maxim Kokarev(VK)
   * Gave idea:   Maxim Kokarev(VK)
   * Extension:   Reaper 6.03+ http://www.reaper.fm/
   *              SWS v.2.10.0 http://www.sws-extension.org/index.php
   * Changelog:   
   *              v.1.0 [03.03.20]
   *                  + initialе
--]] 
    --======================================================================================
    --////////////// SCRIPT \\\\\\\\\\\\\\  SCRIPT  //////////////  SCRIPT  \\\\\\\\\\\\\\\\
    --======================================================================================
    
    
    
    
    -------------------------------------------------------
    local function no_undo()reaper.defer(function()end)end;
    -------------------------------------------------------
    
    
    
    local CountSelItem = reaper.CountSelectedMediaItems(0);
    if CountSelItem == 0 then no_undo() return end;
    
    
    local tbl = {};
    local tblRemove = {};
    local UNDO;
    
    
    for i = 1, CountSelItem do;
        local item = reaper.GetSelectedMediaItem(0,i-1);
        local posIT = reaper.GetMediaItemInfo_Value(item,'D_POSITION');
        local guidIT = reaper.BR_GetMediaItemGUID(item);
        tbl[#tbl+1] = {};
        tbl[#tbl].pos = posIT;
        tbl[#tbl].guid = guidIT;
    end;
    
    
    
    for i = 1, #tbl do;
        
        local mainPos = tbl[i].pos;
        for i2 = 1, #tbl do;
            
            if tbl[i].guid ~= tbl[i2].guid and not tblRemove[tbl[i].guid] then;
                
                local checkPos = tbl[i2].pos;
                
                if math.abs(checkPos-mainPos) < 0.001 then;
                    
                    tblRemove[tbl[i2].guid] = tbl[i2].guid;
                end;
            end;
        end;
    end;
    
    
    for val in pairs(tblRemove)do;
        local item = reaper.BR_GetMediaItemByGUID(0,val);
        if item then;
            local tr = reaper.GetMediaItem_Track(item,item);
            if not UNDO then;
                reaper.Undo_BeginBlock();
                UNDO = true;
            end;
            reaper.DeleteTrackMediaItem(tr,item);
        end;
    end;
    
    
    if UNDO then;
        reaper.Undo_EndBlock("Remove selected overlapped items",-1);
    else;
        no_undo();
    end;
     
    reaper.UpdateArrange();
    
    
    