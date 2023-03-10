({
    searchHandler : function (component, event, helper) 
    {
        const searchString = event.target.value;
        if (searchString.length >= 3) 
        {
            //Ensure that not many function execution happens if user keeps typing
            if (component.get("v.inputSearchFunction")) 
            {
                clearTimeout(component.get("v.inputSearchFunction"));
            }

            var inputTimer = setTimeout($A.getCallback(function() 
			{
                if(component.get("v.objectApiName") == 'Knowledge__kav')
                    helper.searchKnowledgeRecords(component, searchString);
                else
                    helper.searchRecords(component, searchString);
            }), 1000);
            component.set("v.inputSearchFunction", inputTimer);
        } 
        else
        {
            component.set("v.selectedOption", "");
            component.set("v.results", []);
            component.set("v.openDropDown", false);
        }
    },
    searchOnChange : function(component, event, helper)
    {
      	var e = event;
        debugger;
        console.log(e);
    },
    optionClickHandler : function (component, event, helper) {
        const selectedId = event.target.closest('li').dataset.id;
        const selectedValue = event.target.closest('li').dataset.value;
        component.set("v.inputValue", selectedValue);
        component.set("v.openDropDown", false);
        component.set("v.selectedOption", selectedId);
    },

    clearOption : function (component, event, helper) {
        component.set("v.results", []);
        component.set("v.openDropDown", false);
        component.set("v.inputValue", "");
        component.set("v.selectedOption", "");
    },
})