Config = {}
Config.Item = {
    {nameHash = "-53650680", price = "50", name = "3x A.M Beer"},
    {nameHash = "-259124142", price = "100", name = "12x Blarney Beer"},
    {nameHash = "1793329478", price = "50", name = "3x Dustche Beer"},
    {nameHash = "-1914723336", price = "50", name = "3x Pride Beer"},
    {nameHash = "-942878619", price = "50", name = "3x Barracho Beer"},
    {nameHash = "-1902841705", price = "50", name = "12x Logger Beer"},
    {nameHash = "898161667", price = "50", name = "12x Jakey's Beer"},
    {nameHash = "2085005315", price = "50", name = "12x Pibwasser Beer"},
    {nameHash = "-1699929937", price = "50", name = "12x Benedict Beer"},
    {nameHash = "1661171057", price = "50", name = "12x Pibwasser's Beer"},
}
Config.Ped = {
    {pedName = "a_m_y_business_03", posX = -1221.73, posY = -908.23, posZ =  11.32},
}

Config.blips = {
     {title="Shop", colour=30, id=108, x = -1221.73, y = -908.23, z = 11.32}
}

objectInCart = 0
priceCart = 0
itemsToBuy = {}
numberItemInCart =0
gotItemInHand = false
----------- BLIPS -----------
Citizen.CreateThread(function()

    for _, info in pairs(Config.blips) do
      info.blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, 1.0)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, true)
	  BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
    end
end)
---------------------------------
Citizen.CreateThread(function()
    local playerPed = PlayerPedId()
    for k, v in pairs (Config.Ped) do
        local pedNameHash = RequestModel(GetHashKey(v.pedName))
        while not HasModelLoaded(GetHashKey(v.pedName)) do
            Wait(1)
        end
        
        npc = CreatePed(4, pedNameHash, v.posX, v.posY, v.posZ, 20, false, false)

	    SetEntityHeading(npc, 20)
	    FreezeEntityPosition(npc, true)
	    SetEntityInvincible(npc, true)
	    SetBlockingOfNonTemporaryEvents(npc, true)
    end

    while true do 
        local playerCoords = GetEntityCoords(playerPed)
        distancePedPlayer = GetDistanceBetweenCoords(playerCoords, -1221.73, -908.23, 11.32, false)
        Citizen.Wait(5)
    end
end)


local menuPool = MenuPool()
menuPool.OnOpenMenu = function(screenPosition, hitSomething, worldPosition, hitEntity, normalDirection)
    CreateMenu(screenPosition, worldPosition, hitEntity)
end


function CreateMenu(screenPosition, worldPosition, hitEntity)
    menuPool:Reset()
    local contextMenu = menuPool:AddMenu()
    
    if (hitEntity ~= nil and DoesEntityExist(hitEntity)) then
        if tonumber(distancePedPlayer) <= tonumber(15) then
            ----------------MENU PED IN STORE ----------------
            if (IsEntityAPed(hitEntity)) then
                if hitEntity == npc then

                    --------MENU ITEM BUY --------
                    local buyItem = contextMenu:AddItem("Buy Item")
                    buyItem.OnClick = function()
                        itemBuyFunction(itemsToBuy, objectTake)
                    end

                    --------MENU ITEM CANCEL --------
                    local cancelItem = contextMenu:AddItem("Cancel")
                    cancelItem.OnClick = function()
                        itemCancelFunction(itemsToBuy)
                    end

                    --------MENU ITEM ROB --------
                    local robItem = contextMenu:AddItem("Rob")
                    robItem.OnClick = function()
                        itemRobFunction()
                    end

                    --------MENU ITEM PRICE --------
                    local priceItem = contextMenu:AddItem("Price : "..priceCart)
                    priceItem.OnClick = function()
                    end

                    --------MENU ITEM NUMBER --------
                    local numberItem = contextMenu:AddItem("Number item : "..numberItemInCart)
                    numberItem.OnClick = function()
                    end
                end
            --[[
                //////////////////////FIND WHAT CAN ITEM USE WHIS THIS BOUCLE//////////////////////
                Click on it and if just the object of you wath is delet you can use this script
                If the object and another object is delet you can use this system but all object is deleted (in test) are deleted always
                //////////////////////////////////////////////////////////////////
                elseif (IsEntityAnObject(hitEntity)) then
                -- object

                local object = hitEntity

                local itemDelete = contextMenu:AddItem("Delete object")
                itemDelete.OnClick = function()
                    if (object ~= nil and DoesEntityExist(object)) then
                        SetEntityAsMissionEntity(object)
                        DeleteEntity(object)
                    end
                end
                ]]--
            ----------------MENU ITEM IN STORE ----------------
            elseif (IsEntityAnObject(hitEntity)) then
                object = GetEntityModel(hitEntity)
                for k,v in pairs(Config.Item) do
                    if tostring(object) == tostring(v.nameHash) then

                        --------MENU ITEM TAKE --------
                        local menuTake = contextMenu:AddItem("Take "..v.name)
                        menuTake.OnClick = function()
                            itemTakeFunction(hitEntity, itemsToBuy)
                        end

                        --------MENU ITEM PUT --------
                        if tonumber(objectInCart) == tonumber("1") then
                            local itemPut = contextMenu:AddItem("Put in store last object")
                            itemPut.OnClick = function()
                                itemPutFunction(itemsToBuy)
                            end
                        end
                        
                    end
                end
            end
        end
    end
    contextMenu:SetPosition(screenPosition)
    contextMenu:Visible(true)
end

function itemBuyFunction(itemsToBuy, objectTake)
    TriggerServerEvent('shop:moneyPlayer')

    RegisterNetEvent('shop:resultMoneyPlayer')
    AddEventHandler('shop:resultMoneyPlayer', function(moneyPlayer)
        if tonumber(moneyPlayer) >= tonumber(priceCart) then
            TriggerServerEvent('shop:buyItem', priceCart, moneyPlayer)
            for k, v in pairs (itemsToBuy) do
                CreateObject(v.itemHashName, v.itemCoords.x, v.itemCoords.y, v.itemCoords.z - 0.15, true, true, true)
                DeleteEntity(v.itemInHand)
                itemsToBuy = nil
            end
            Citizen.Wait(10)
            priceCart = 0
            objectInCart = 0
            itemsToBuy = {}
            numberItemInCart = 0
            gotItemInHand = false
            print("Assez d'argent") -- pas de system de give d'item
        else
            print("pas assez d'argent")
        end
    end)
end

function itemCancelFunction(itemsToBuy)
    for k, v in pairs (itemsToBuy) do
        DeleteEntity(v.itemInHand)
        CreateObject(v.itemHashName, v.itemCoords.x, v.itemCoords.y, v.itemCoords.z - 0.15, true, true, true)
        DeleteEntity(v.itemInHand)
    end
    priceCart = 0
    objectInCart = 0
    itemsToBuy = {}
    numberItemInCart = 0
    gotItemInHand = false
end

function itemTakeFunction(hitEntity, itemsToBuy)
    if (hitEntity ~= nil and DoesEntityExist(hitEntity)) then
        local playerId = PlayerPedId()
        local playerCoords = GetEntityCoords(playerId)
        objectCoords = GetEntityCoords(hitEntity)
        local bag = GetHashKey("p_poly_bag_01_s")
        SetEntityAsMissionEntity(hitEntity)
        DeleteEntity(hitEntity)
        if gotItemInHand == false then
            objectTake = CreateObject(bag, playerCoords, true, true, true)
            AttachEntityToEntity(objectTake, playerId, GetPedBoneIndex(playerId, 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)

            gotItemInHand = true
        end
        objectInCart = 1 
        numberItemInCart = numberItemInCart + 1

        for k,v in pairs(Config.Item) do
            priceCart = priceCart + v.price
            table.insert(itemsToBuy, {itemHashName = object, itemName = v.name, itemPrice = v.price, itemCoords = objectCoords, itemInHand = objectTake})
        end
    end
end

function itemPutFunction(itemsToBuy)
    CreateObject(object, objectCoords.x, objectCoords.y, objectCoords.z -0.15, true, true, true)

    if tonumber(numberItemInCart) == 1 then
        DeleteEntity(objectTake)
    end

    count = 0
    Citizen.Wait(5)
    for k, v in pairs(itemsToBuy) do   
        count = count + 1
    end  

    objectInTable = json.encode(itemsToBuy[count])
    table.remove(itemsToBuy, objectInTable.itemHashName, objectInTable.itemName, objectInTable.itemPrice, objectInTable.itemCoords, objectInTable.itemInHand)

    for k,v in pairs(Config.Item) do
        priceCart = priceCart - v.price
    end

    numberItemInCart = numberItemInCart - 1
    objectInCart = 0
    gotItemInHand = false
end

function itemRobFunction()
end