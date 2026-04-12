# Events
  ## Server Events
  - ### Housing:s:OnPropertyCreation
    Triggers on property creation  

    ```lua
    AddEventHandler('Housing:s:OnPropertyCreation', function(propertyId) end)
    ```  
    - propertyId: int  

  - ### Housing:s:OnPropertyDeletion
    Triggers on property deletion  
    
    ```lua
    AddEventHandler('Housing:s:OnPropertyDeletion', function(propertyId) end)
    ```  
    - propertyId: int  

# Exports
  ## Server Exports
  - ### getProperty  
    returns the property data
    ```lua
    exports['BDN-housing']:getProperty(propertyId)
    ```  
    - propertyId: int  

    Return:
    - propertyData: table?

    Example:
    ```lua
    exports['BDN-housing']:getProperty(1)
    --[[
      {
        id = 1, -- int
        shell = 'k4_michael_shell', -- string
        enter_coords = vec3(0,0,0), -- vec3?
        storage_coords = vec3(0,0,0), -- vec3?
        key_code = 3850618598, -- int
        stack = nil -- int?
      }
    ]]
    ```

  - ### getStack  
    returns the stack data
    ```lua
    exports['BDN-housing']:getStack(stackId)
    ```  
    - stackId: int  

    Return:
    - stackData: table?

    Example:
    ```lua
    exports['BDN-housing']:getStack(1)
    --[[
      {
        id = 1, -- int
        enter_coords = vec3(0,0,0) -- vec3
      }
    ]]
    ```
