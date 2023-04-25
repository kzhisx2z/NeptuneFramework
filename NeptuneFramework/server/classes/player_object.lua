function CreatePlayerObject(source, identifier, group, accounts, inventory, weight, job, faction, loadout, name, identity, coords, metadata)
    local self = {}

    self.accounts = accounts
    self.coords = coords
    self.group = group
    self.identifier = identifier
    self.inventory = inventory
    self.job = job
    self.faction = faction
    self.loadout = loadout
    self.name = name
    self.identity = identity
    self.source = source
    self.ped = GetPlayerPed(source)
    self.variables = {}
    self.weight = weight
    self.maxWeight = Config.MaxWeight
    self.metadata = metadata
    self.license = ('license:%s'):format(identifier)

    ExecuteCommand(('add_principal identifier.%s group.%s'):format(self.license, self.group))

    local stateBag = Player(self.source).state

    stateBag:set('identifier', self.identifier, true)
    stateBag:set('license', self.license, true)
    stateBag:set('job', self.job, true)
    stateBag:set('faction', self.faction, true)
    stateBag:set('group', self.group, true)
    stateBag:set('name', self.name, true)
    stateBag:set('metadata', self.metadata, true)

    function self.triggerEvent(eventName, ...)
        TriggerClientEvent(eventName, self.source, ...)
    end

    function self.setCoords(newCoords)
        newCoords = type(newCoords) == 'vector4' and newCoords or (type(newCoords) == 'vector3' and vector4(newCoords, 0.0) or
        vector4(newCoords.x, newCoords.y, newCoords.z, newCoords.heading or 0.0))

        SetEntityCoords(self.ped, newCoords.xyz, false, false, false, false)
        SetEntityHeading(self.ped, newCoords.a)
    end

    function self.getCoords()
        return self.coords
    end

    function self.getIdentifier()
        return self.identifier
    end

    function self.getGroup()
        return self.group
    end

    function self.getMeta()
        return self.metadata
    end

    function self.getIdentity()
        return self.identity
    end

    function self.getAccounts()
        return self.accounts
    end

    function self.getJob()
        return self.job
    end

    function self.getFaction()
        return self.faction
    end

    function self.getLoadout()
        return self.loadout
    end

    function self.getAccountMoney(accountName)
        return self.accounts[accountName]
    end

    function self.getInventory()
        return self.inventory
    end

    function self.getMaxWeight()
        return self.maxWeight
    end

    function self.getPed()
        return self.ped
    end

    function self.kick(reason)
        DropPlayer(self.source, reason)
    end

    function self.setAccountMoney(accountName, money)
        if money >= 0 then
            if self.accounts[accountName] then
                self.accounts[accountName] = money
            end
        end
    end

    return self
end