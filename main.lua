Bingo = RegisterMod("Bingo",1)
Bingo.version="2.0"
Bingo.player=Isaac.GetPlayer(0)
Bingo.game=Game()
Bingo.level=Bingo.game:GetLevel()
Bingo.lives=3
Bingo.newStart=true
Bingo.LIMITED_TIME=45
Bingo.timerNew=0
Bingo.timeStart=0
Bingo.gameTime=0
Bingo.gameTimeForShow={minute="00",second="00"}
Bingo.gameIsPaused=false
Bingo.puaseTime=0 --just for system time
Bingo.gameIsOver=0 --0 means not over,1 means you win,2 means other situations
---ui variable---
Bingo.selectArrow = Sprite()
Bingo.startMenu = Font()
Bingo.renderPosition=Isaac.WorldToRenderPosition(Vector(320,150)) --need to alter
Bingo.nameAndVersion="以撒宾果mod ver"..Bingo.version.."by Amiya9212(目前只能玩单人模式)"
Bingo.startMenuRootString={"单人模式","对战模式","DR模式"}
Bingo.startMenuStringOfSingle={"随便开把","种子生图"}
Bingo.startMenuStringOfBattle="输入房间号: "
Bingo.startMenuRootSelect=0
Bingo.startMenuSelectOfSingle=0
Bingo.startSignal=0
Bingo.meunIsChanged=false
Bingo.gameIsStarted=false
Bingo.FONT_OFFSET=9
---tasks variable---
Bingo.tasks=require("tasks")
Bingo.renderPositionOfTasks=Isaac.WorldToRenderPosition(Vector(100,420)) --needs to test--
Bingo.finishIcon=Sprite()
Bingo.taskSelection=Sprite()
Bingo.tasksBackground=Sprite()
Bingo.taskSelectionPosition={X=0,Y=0}
Bingo.taskSelectionEnable=false
Bingo.achieveSound=SFXManager()
Bingo.TASKS_COUNT=50
Bingo.randomTasksQueue={}
Bingo.finishTasksNum=0
Bingo.longestLineLength=0
Bingo.map={}
Bingo.seedForShow=""
---font path---
local MOD_FOLDER_NAME="bingo_3555711630"
local CUSTOM_FONT_FILE_PATH="font/eid9/eid9_9px.fnt"
---funtions---


function Bingo:gameStartMenu()
    if Bingo.gameIsStarted==false then
        Bingo.player:AddControlsCooldown(1) --stop the player--
        Bingo.game.TimeCounter=0 --stop time--
        Bingo.startMenu:DrawStringUTF8(Bingo.nameAndVersion,Bingo.renderPosition.X-Bingo.FONT_OFFSET*15,Bingo.renderPosition.Y-Bingo.FONT_OFFSET*2,KColor(1,1,1,1))
        for index, value in ipairs(Bingo.startMenuRootString) do
            --print start menu
            Bingo.startMenu:DrawStringUTF8(value,Bingo.renderPosition.X-Bingo.FONT_OFFSET*2,Bingo.renderPosition.Y+Bingo.FONT_OFFSET*index*3,KColor(1,1,1,1),0,false)
        end     
        if Bingo.meunIsChanged==false then
            --choose the mode via ↑ and ↓--
            Bingo.startMenu:DrawStringUTF8("按↑、↓键切换选择，按←键确认",Bingo.renderPosition.X-Bingo.FONT_OFFSET*8,Bingo.renderPosition.Y,KColor(1,1,1,1))
            if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN,Bingo.player.ControllerIndex) then
                if Bingo.startMenuRootSelect<3 then
                    Bingo.startMenuRootSelect=Bingo.startMenuRootSelect+1
                else
                    Bingo.startMenuRootSelect=1
                end
            elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP,Bingo.player.ControllerIndex) then
                if Bingo.startMenuRootSelect>1 then
                    Bingo.startMenuRootSelect=Bingo.startMenuRootSelect-1
                else
                    Bingo.startMenuRootSelect=3
                end
            end
        end
        --render the new selectArrow again--
        Bingo.selectArrow:Render(Vector(Bingo.renderPosition.X+Bingo.FONT_OFFSET*3,Bingo.renderPosition.Y+Bingo.FONT_OFFSET*3*Bingo.startMenuRootSelect+4))
        --choose detailed mode--
        if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT,Bingo.player.ControllerIndex) and Bingo.meunIsChanged==false then
            Bingo.meunIsChanged=true
        end
        --single mode's choose--
        if Bingo.meunIsChanged then
            Bingo.startMenu:DrawStringUTF8("按↑、↓键切换选择，按拍主动的键确认",Bingo.renderPosition.X-Bingo.FONT_OFFSET*22,Bingo.renderPosition.Y,KColor(1,1,1,1))
            Bingo.startMenu:DrawStringUTF8("按→键返回上一级菜单",Bingo.renderPosition.X-Bingo.FONT_OFFSET*18,Bingo.renderPosition.Y+Bingo.FONT_OFFSET+3,KColor(1,1,1,1))
            --print single mode's menu--
            if Bingo.startMenuRootSelect==1 then
                for index, value in ipairs(Bingo.startMenuStringOfSingle) do
                    Bingo.startMenu:DrawStringUTF8(value,Bingo.renderPosition.X-Bingo.FONT_OFFSET*15,Bingo.renderPosition.Y+Bingo.FONT_OFFSET*index*3,KColor(1,1,1,1),0,false)
                end
                if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN,Bingo.player.ControllerIndex) then
                    if Bingo.startMenuSelectOfSingle==1 then
                        Bingo.startMenuSelectOfSingle=2
                    else
                        Bingo.startMenuSelectOfSingle=1
                    end
                elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP,Bingo.player.ControllerIndex) then
                    if Bingo.startMenuSelectOfSingle==2 then
                        Bingo.startMenuSelectOfSingle=1
                    else
                        Bingo.startMenuSelectOfSingle=2
                    end
                end
                --render the new selectArrow again--
                if Bingo.startMenuSelectOfSingle~=0 then
                    Bingo.selectArrow:Render(Vector(Bingo.renderPosition.X-Bingo.FONT_OFFSET*10,Bingo.renderPosition.Y+Bingo.FONT_OFFSET*3*Bingo.startMenuSelectOfSingle+4))
                end
                --choose "随便开把" mode--
                if Input.IsActionTriggered(ButtonAction.ACTION_ITEM,Bingo.player.ControllerIndex) and Bingo.startMenuSelectOfSingle==1 then
                    math.randomseed(Random())                    
                    Bingo:createBingoMap()
                    Bingo.gameIsPaused=true
                    Bingo.player.ControlsEnabled=false
                    Bingo.startSignal=1
                    Bingo.game.TimeCounter=0
                    Bingo.gameIsStarted=true
                    Bingo.timeStart=Isaac.GetTime()
                    --#needs to refine--
                --choose "种子生图" mode--
                elseif Input.IsActionTriggered(ButtonAction.ACTION_ITEM,Bingo.player.ControllerIndex) and Bingo.startMenuSelectOfSingle==2 then
                    math.randomseed(Bingo.game:GetSeeds():GetStartSeed())
                    Bingo:createBingoMap()
                    Bingo.gameIsPaused=true
                    Bingo.player.ControlsEnabled=false
                    Bingo.startSignal=1
                    Bingo.game.TimeCounter=0
                    Bingo.gameIsStarted=true
                    Bingo.timeStart=Isaac.GetTime()
                    --#needs to refine
                end
            --print battle mode's menu--
            elseif Bingo.startMenuRootSelect==2 then
                Bingo.startMenu:DrawStringUTF8(Bingo.startMenuStringOfBattle,Bingo.renderPosition.X-Bingo.FONT_OFFSET*15,Bingo.renderPosition.Y+Bingo.FONT_OFFSET*3,KColor(1,1,1,1),0,false)
                --#needs to refine--
            --daily-run mode--
            else
                --daily-run mode--
                --#needs to refine--
            end
            --return to chooses of mode via →--
            if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT,Bingo.player.ControllerIndex) then
                Bingo.meunIsChanged=false
            end
        end
    end
end
--initialize when a new game is started
--#need to finish
function Bingo:gameInitialize(isContinued)
    if isContinued then
        Bingo.newStart=true
    end
    if Bingo.newStart==true then
        Bingo.newStart=false
        Bingo.lives=3
        Bingo.timerNew=0
        Bingo.timeStart=0
        Bingo.gameTime=0
        Bingo.gameTimeForShow.minute="00"
        Bingo.gameTimeForShow.second="00"
        Bingo.gameIsPaused=false
        Bingo.puaseTime=0
        Bingo.gameIsOver=0
        Bingo.player=Isaac.GetPlayer(0)
        Bingo.game=Game()
        Bingo.game:GetSeeds():ClearSeedEffects()
        Isaac.ExecuteCommand("seed "..(Game():GetSeeds():GetStartSeedString()))
        -----startMenu-----
        Bingo.startMenu:Load("mods/" .. MOD_FOLDER_NAME .. "/resources/" .. CUSTOM_FONT_FILE_PATH)
        Bingo.selectArrow:Load("gfx/ui/select_arrow.anm2",true)
        Bingo.gameIsStarted=false
        Bingo.startMenuRootSelect=1
        Bingo.startMenuSelectOfSingle=1
        Bingo.startSignal=0
        Bingo.meunIsChanged=false
        Bingo.selectArrow:SetFrame("Select",0)
        Bingo.selectArrow:Render(Vector(Bingo.renderPosition.X+Bingo.FONT_OFFSET*3,Bingo.renderPosition.Y+Bingo.FONT_OFFSET*3+4))
        -----tasks-----
        Bingo.finishIcon:Load("gfx/ui/finish_icon.anm2",true)
        Bingo.taskSelection:Load("gfx/ui/task_select.anm2",true)
        Bingo.tasksBackground:Load("gfx/ui/tasks_background.anm2",true)
        Bingo.taskSelectionPosition.X=0
        Bingo.taskSelectionPosition.Y=0
        Bingo.taskSelectionEnable=false
        Bingo.randomTasksQueue={}
        itemPoolOfPickedUpActive={}
        Bingo.finishTasksNum=0
        Bingo.longestLineLength=0
        --释放资源
        if next(Bingo.map)~=nil then
            for i = 1, 5, 1 do
                for j = 1, 5, 1 do
                    if Bingo.map[i][j]~=nil and Bingo.map[i][j].callBackfunction~=nil then
                        Bingo:RemoveCallback(ModCallbacks.MC_POST_UPDATE,Bingo.map[i][j].callBackfunction)
                        Bingo:RemoveCallback(ModCallbacks.MC_POST_RENDER,Bingo.map[i][j].callBackfunction)
                        Bingo.map[i][j].callBackfunction=nil
                    end
                    -- 针对specialRoomsAtStage，释放回调占用的资源
                    if Bingo.map[i][j]~=nil and Bingo.map[i][j].callBackfunction1~=nil then
                        Bingo:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL,Bingo.map[i][j].callBackfunction1)
                        Bingo.map[i][j].callBackfunction1=nil
                    end
                end
            end
        end
        Bingo.map={}
        Bingo.seedForShow=Bingo.game:GetSeeds():GetStartSeedString()
        --loading task icons--
    end
end
--退出该局就会重置整局
function Bingo:resetWhenExit()
    Bingo.newStart=true
end
--set the time for show
function Bingo:setGameTimeForShow()
    local time=Bingo.gameTime//1000
    if time//60>=0 and time//60<=9 then
        Bingo.gameTimeForShow.minute="0"..time//60
    else
        Bingo.gameTimeForShow.minute=time//60
    end
    if time%60>=0 and time%60<=9 then
        Bingo.gameTimeForShow.second="0"..time%60
    else 
        Bingo.gameTimeForShow.second=time%60
    end
end
--rewrite the logic of pressing key-R to restart the game
function Bingo:keyrRestart()
    if Input.IsActionPressed(ButtonAction.ACTION_RESTART,Bingo.player.ControllerIndex) and Input.IsActionPressed(ButtonAction.ACTION_MAP,Bingo.player.ControllerIndex) then
        Bingo.newStart=true
    end
end
--count the time
function Bingo:countTime()
    if (not Bingo.gameIsPaused) and Bingo.gameIsStarted==true and Bingo.gameIsOver==0 then
        Bingo.timerNew=Isaac.GetTime()
        Bingo.gameTime=Bingo.gameTime+Bingo.timerNew-Bingo.timeStart
        Bingo.timeStart=Isaac.GetTime()
    elseif Bingo.gameIsPaused and Bingo.gameIsStarted and Bingo.gameIsOver==0 then
        Bingo.timeStart=Isaac.GetTime()
        Bingo.timerNew=Isaac.GetTime()
    end
end
--pause the game
function Bingo:pauseGame()
    if Input.IsActionTriggered(ButtonAction.ACTION_DROP,Bingo.player.ControllerIndex) and Input.IsActionPressed(ButtonAction.ACTION_MAP,Bingo.player.ControllerIndex) and Bingo.gameIsPaused== false then
        Bingo.puaseTime=Bingo.game.TimeCounter
        Bingo.gameIsPaused=true
        Bingo.player.ControlsEnabled=false
        return
    elseif Input.IsActionTriggered(ButtonAction.ACTION_DROP,Bingo.player.ControllerIndex) and Input.IsActionPressed(ButtonAction.ACTION_MAP,Bingo.player.ControllerIndex) and Bingo.gameIsPaused==true then
        Bingo.gameIsPaused=false
        Bingo.player.ControlsEnabled=true
        return
    end
end
--set the paused time
function Bingo:setPauseTime()
    if Bingo.gameIsPaused then
        Bingo.game.TimeCounter=Bingo.puaseTime
    end
end
--游戏内置的暂停生效时保证游戏内置时间继续（保证凹凸和bossrush的时间和gameTime一致）
function Bingo:setTimeCounterContinued()
    if Bingo.game:IsPaused() then
        Bingo.game.TimeCounter=math.floor(Bingo.gameTime*0.03)
    end
end
--show information during the game
function Bingo:showGameInfo()
    Bingo.startMenu:DrawStringUTF8("总用时: "..Bingo.gameTimeForShow.minute..":"..Bingo.gameTimeForShow.second,10,200,KColor(1,1,1,1))
    Bingo.startMenu:DrawStringUTF8("已完成任务数: "..Bingo.finishTasksNum,10,212,KColor(1,1,1,1))
    Bingo.startMenu:DrawStringUTF8("最长连线: "..Bingo.longestLineLength,10,224,KColor(1,1,1,1))
    Bingo.startMenu:DrawStringUTF8("种子: "..Bingo.seedForShow,10,236,KColor(1,1,1,1))
    if Bingo.gameIsPaused then
        Bingo.startMenu:DrawStringUTF8("游戏已暂停，长按地图键+丢弃卡牌键继续",70,200,KColor(1,0,0,0.8))
    end
end
--one of the game-over situations:when 3 lives are spent
function Bingo:playerDeath(IsGameOver)
    if Bingo.lives>0 and IsGameOver then
        Bingo.lives=Bingo.lives-1
    end
    if Bingo.lives<=0 and IsGameOver then
        Bingo.gameIsOver=2
    end
end
--another situation of game-over:time is over
function Bingo:timeIsOver()
    if Bingo.gameTime>=Bingo.LIMITED_TIME*60*1000 then
        Bingo.player.ControlsEnabled=false
        Bingo.gameIsOver=2
    end
end
--get won
function Bingo:winAct()
    if Bingo.longestLineLength==5 then
        Bingo.gameIsOver=1
    end
end
--show game-over information
function Bingo:showGameOverInfo()
    if Bingo.gameIsOver~=0 then
        Bingo.player.ControlsEnabled=false
        Bingo.game.TimeCounter=0
        if Bingo.gameIsOver == 1 then
            Bingo.startMenu:DrawStringScaledUTF8("Bingo! 用时"..Bingo.gameTimeForShow.minute..":"..Bingo.gameTimeForShow.second,Bingo.renderPosition.X-Bingo.FONT_OFFSET*2*3,Bingo.renderPosition.Y,2,2,KColor(1,1,1,1))
        else
            Bingo.startMenu:DrawStringScaledUTF8("游戏结束!",Bingo.renderPosition.X-Bingo.FONT_OFFSET*2*2+7,Bingo.renderPosition.Y,2,2,KColor(1,1,1,1))
        end
        Bingo.startMenu:DrawStringUTF8("最大连线长度: "..Bingo.longestLineLength,Bingo.renderPosition.X-Bingo.FONT_OFFSET*3+5,Bingo.renderPosition.Y+Bingo.FONT_OFFSET*3+2,KColor(1,1,1,1))
        Bingo.startMenu:DrawStringUTF8("完成任务数: "..Bingo.finishTasksNum,Bingo.renderPosition.X-Bingo.FONT_OFFSET*3+5,Bingo.renderPosition.Y+Bingo.FONT_OFFSET*4+6,KColor(1,1,1,1))
        Bingo.startMenu:DrawStringUTF8("按使用主动键重玩这局",Bingo.renderPosition.X-Bingo.FONT_OFFSET*4-2,Bingo.renderPosition.Y+Bingo.FONT_OFFSET*7,KColor(1,1,1,1))
        if Input.IsActionTriggered(ButtonAction.ACTION_ITEM,Bingo.player.ControllerIndex) and not Bingo.game:IsPaused() then
            Isaac.ExecuteCommand("restart")
            Bingo.newStart=true
        end
    end
end
--检索节点之间是否矛盾
local function isTasksConflicted(taskRandomIndex,taskExistIndex)
    if taskExistIndex.conflictTasks==nil then
        return false
    end
    for _, value in ipairs(taskExistIndex.conflictTasks) do
        if taskRandomIndex==value then
            return true
        end
    end
    return false
end
--检索节点和角色之间是否矛盾
local function isTaskConflictWithCharacter(taskRandomIndex,playerType)
    local playerNum=tonumber(Bingo.player:GetPlayerType())
    if playerType["c"..playerNum]==nil then
        return false
    else
        for _, value in ipairs(playerType["c"..playerNum]) do
            if taskRandomIndex==value then
                return true
            end
        end
    end
    return false
end
--检查该节点是否与bingo图中已有节点重复或有矛盾
--待完善
local function isTaskNoProblem(row,col,taskIndex,mode)
    -- 检查这一行是否有与角色冲突的任务
    for i = 1, col-1, 1 do
        if isTaskConflictWithCharacter(taskIndex,Bingo.tasks[1]) then
            return false
        end
    end
    -- 检查这一列是否有与角色冲突的任务
    for i = 1, row-1, 1 do
        if isTaskConflictWithCharacter(taskIndex,Bingo.tasks[1]) then
            return false
        end
    end

    -- 检查是否与地图上已有节点重复
    -- 检查完整生成的行
    for i = 1, row-1, 1 do
        for j = 1, 5, 1 do
            if taskIndex==Bingo.map[i][j].taskIndex then
                return false
            end
        end
    end
    -- 检查残缺的行
    for i = 1, col-1, 1 do
        if taskIndex==Bingo.map[row][i].taskIndex then
            return false
        end
    end
    -- 检查该节点是否与其他节点矛盾
    if mode==1 then
        -- 检查这一行是否有矛盾的元素
        for i = 1, col-1, 1 do
            if isTasksConflicted(taskIndex,Bingo.map[row][i]) then
                return false
            end
        end
        -- 检索这一列有没有矛盾的元素
        for i = 1, row-1, 1 do
            if isTasksConflicted(taskIndex,Bingo.map[i][col]) then
                return false
            end
        end
    end
    return true
end
-- 生成bingo图
function Bingo:createBingoMap()
    local taskIndex=0
    for row = 1, 5, 1 do
        Bingo.map[row]={}
        for col = 1, 5, 1 do
            local searchTime=0
            local mode=1
            --for debug
            local debugtime=0
            taskIndex=math.random(1,Bingo.TASKS_COUNT)
            while not isTaskNoProblem(row,col,taskIndex,mode) do
                taskIndex=math.random(1,Bingo.TASKS_COUNT)
                searchTime=searchTime+1
                debugtime=debugtime+1
                if searchTime>=Bingo.TASKS_COUNT then
                    mode=0
                end
                if debugtime>=200 then
                    print("break")
                    break
                end
            end
            Bingo.map[row][col]=Bingo.tasks["task"..taskIndex]:new()
            Bingo.map[row][col].taskIcon:Load("gfx/tasks/task"..taskIndex..".anm2",true)
            Bingo.map[row][col].renderXOffset=col-1
            Bingo.map[row][col].renderYOffset=row-1
        end
    end
    --如果当前生成节点所在的位置在主对角线上，检索有无矛盾元素
end 
function Bingo:setRenderPositionOfTasks()
    Bingo.renderPositionOfTasks=Isaac.WorldToRenderPosition(Vector(100,420))
end
--get bingo map config
function Bingo:getMapConfig(taskX,taskY)
    local length=0
    local maxLength=0
    --row
    for i = 1, 5, 1 do
        if Bingo.map[i][taskX+1].isAchieved then
            length=length+1
        else 
            length=0
        end
        if length>maxLength then
            maxLength=length
        end
    end
    Bingo.longestLineLength=(maxLength>Bingo.longestLineLength) and maxLength or Bingo.longestLineLength
    maxLength=0
    length=0
    --col
    for i = 1, 5, 1 do
        if Bingo.map[taskY+1][i].isAchieved then
            length=length+1
        else 
            length=0
        end
        if length>maxLength then
            maxLength=length
        end
    end
    Bingo.longestLineLength=(maxLength>Bingo.longestLineLength) and maxLength or Bingo.longestLineLength
    maxLength=0
    length=0
    --diag
    if taskX==taskY then
        for i = 1, 5, 1 do
            if Bingo.map[i][i].isAchieved then
                length=length+1
            else 
                length=0
            end
            if length>maxLength then
                maxLength=length
            end
        end
        Bingo.longestLineLength=(maxLength>Bingo.longestLineLength) and maxLength or Bingo.longestLineLength
        maxLength=0
        length=0
    elseif taskX+taskY==4 then
        for i = 1, 5, 1 do
            if Bingo.map[6-i][i].isAchieved then
                length=length+1
            else 
                length=0
            end
            if length>maxLength then
                maxLength=length
            end
        end
        Bingo.longestLineLength=(maxLength>Bingo.longestLineLength) and maxLength or Bingo.longestLineLength
        maxLength=0
        length=0
    end
end 
function Bingo:tasksIconRender()
    if Bingo.gameIsStarted==true then
        Bingo.tasksBackground:SetFrame("background",0)
        Bingo.tasksBackground:Render(Vector(Bingo.renderPositionOfTasks.X-3,Bingo.renderPositionOfTasks.Y-3))
        for indexRow, valueRow in ipairs(Bingo.map) do
            for indexCol, valueCol in ipairs(valueRow) do
                valueCol.taskIcon:SetFrame("task",0)
                valueCol.taskIcon:Render(Vector(Bingo.renderPositionOfTasks.X+10*valueCol.renderXOffset+1,Bingo.renderPositionOfTasks.Y+10*valueCol.renderYOffset+1))
                if valueCol.isAchieved then
                    Bingo.finishIcon:SetFrame("Finish1",0)
                    Bingo.finishIcon:Render(Vector(Bingo.renderPositionOfTasks.X+10*valueCol.renderXOffset,Bingo.renderPositionOfTasks.Y+10*valueCol.renderYOffset))
                end
            end
        end
        if Bingo.taskSelectionEnable then
            Bingo.taskSelection:SetFrame("taskselect",0)
            Bingo.taskSelection:Render(Vector(Bingo.renderPositionOfTasks.X+Bingo.taskSelectionPosition.X*10+1,Bingo.renderPositionOfTasks.Y+Bingo.taskSelectionPosition.Y*10+1))
        else if not Bingo.taskSelectionEnable then
            Bingo.taskSelection:SetFrame("taskselect1",0)
            Bingo.taskSelection:Render(Vector(Bingo.renderPositionOfTasks.X+Bingo.taskSelectionPosition.X*10+1,Bingo.renderPositionOfTasks.Y+Bingo.taskSelectionPosition.Y*10+1))
        end
        end
        
        if Input.IsActionTriggered(ButtonAction.ACTION_MAP,Bingo.player.ControllerIndex) and Bingo.taskSelectionEnable==false then
            Bingo.taskSelectionEnable=true
        elseif Input.IsActionTriggered(ButtonAction.ACTION_MAP,Bingo.player.ControllerIndex) and Bingo.taskSelectionEnable==true then
            Bingo.taskSelectionEnable=false
        end
        if Bingo.taskSelectionEnable then
            if Bingo.taskSelectionPosition.X<=3 and Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT,Bingo.player.ControllerIndex) then
                Bingo.taskSelectionPosition.X=Bingo.taskSelectionPosition.X+1
            end
            if Bingo.taskSelectionPosition.X>=1 and Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT,Bingo.player.ControllerIndex) then
                Bingo.taskSelectionPosition.X=Bingo.taskSelectionPosition.X-1
            end
            if Bingo.taskSelectionPosition.Y<=3 and Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN,Bingo.player.ControllerIndex) then
                Bingo.taskSelectionPosition.Y=Bingo.taskSelectionPosition.Y+1
            end
            if Bingo.taskSelectionPosition.Y>=1 and Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP,Bingo.player.ControllerIndex) then
                Bingo.taskSelectionPosition.Y=Bingo.taskSelectionPosition.Y-1
            end
        end
        local taskSelected=Bingo.map[Bingo.taskSelectionPosition.Y+1][Bingo.taskSelectionPosition.X+1]
        if taskSelected.achieveCount~=nil and taskSelected.TARGET_NUM~=nil then
            Bingo.startMenu:DrawStringUTF8(taskSelected.description.." "..taskSelected.achieveCount.."/"..taskSelected.TARGET_NUM,Bingo.renderPositionOfTasks.X+80,Bingo.renderPositionOfTasks.Y,KColor(1,1,1,1))
        else
            Bingo.startMenu:DrawStringUTF8(taskSelected.description,Bingo.renderPositionOfTasks.X+80,Bingo.renderPositionOfTasks.Y,KColor(1,1,1,1))
        end
    end
    
    --Bingo.tasks[25].taskIcon:SetFrame("task",0)
    --Bingo.tasks[25].taskIcon:Render(Vector(Bingo.renderPositionOfTasks.X+1,Bingo.renderPositionOfTasks.Y+1))
    --if Bingo.tasks[25].isAchieved==false then
        --Bingo.finishIcon:SetFrame("FinishOriginal",0)
        --Bingo.finishIcon:Render(Vector(Bingo.renderPositionOfTasks.X,Bingo.renderPositionOfTasks.Y))
    --else
        --Bingo.finishIcon:SetFrame("Finish1",0)
        --Bingo.finishIcon:Render(Vector(Bingo.renderPositionOfTasks.X,Bingo.renderPositionOfTasks.Y))
    --end
end 

--just for test


--[[ function Bingo:test()
    if test~=nil then
        test.taskIcon:SetFrame("task",0)
        test.taskIcon:Render(Vector(100,100))
        if test.isAchieved then
            Bingo.finishIcon:SetFrame("Finish1",0)
            Bingo.finishIcon:Render(Vector(100,100))
        end    
    end
end ]]

--Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,Bingo.test)
function Bingo:testtele()
    if Bingo.player:GetSprite():IsPlaying("TeleportUp") then
        print("yes")
    end
end
Bingo:AddCallback(ModCallbacks.MC_POST_UPDATE,Bingo.testtele)

Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,Bingo.setGameTimeForShow)
Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,Bingo.keyrRestart)
Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,Bingo.countTime)
Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,Bingo.pauseGame)
Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,Bingo.setPauseTime)
Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,Bingo.setTimeCounterContinued)
Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,Bingo.showGameInfo)
Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,Bingo.timeIsOver)
Bingo:AddCallback(ModCallbacks.MC_POST_GAME_END,Bingo.playerDeath)
Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,Bingo.winAct)
Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,Bingo.showGameOverInfo)
---add callbacks---
Bingo:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,Bingo.gameInitialize)
Bingo:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT,Bingo.resetWhenExit)
Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,Bingo.gameStartMenu)
Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,Bingo.setRenderPositionOfTasks)
Bingo:AddCallback(ModCallbacks.MC_POST_RENDER,Bingo.tasksIconRender)

Bingo:AddCallback(ModCallbacks.MC_USE_ITEM,Bingo.isUseVoid,CollectibleType.COLLECTIBLE_VOID)
Bingo:AddCallback(ModCallbacks.MC_USE_CARD,Bingo.isUseBlackRune,Card.RUNE_BLACK)




