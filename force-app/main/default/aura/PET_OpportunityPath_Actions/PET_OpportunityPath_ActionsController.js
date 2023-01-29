({
    handleStageChange : function(component, event, helper)
    {
      	let closedStage = component.get("v.closedStage");
        let evt = component.getEvent("stageEvent");
        evt.setParams({"StageName": closedStage});
        evt.fire();
    },
	handlePilotChanged : function(component, event, helper) 
    {
        let fieldName = event.getSource().get("v.fieldName"); 
        let newValue =  event.getSource().get("v.value");
        if(newValue == true)
        {
            component.set("v.pilotIncluded", true);
        }
        else
        {
            component.set("v.pilotIncluded", false);
        }
	}
})