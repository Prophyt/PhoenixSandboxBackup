({
	setStage : function(component, event, helper) 
    {
        var ct = event.currentTarget;
        var val = ct.dataset.value;
        if(component.get("v.showStage") == val)
            component.set("v.showStage", '');
        else
            component.set("v.showStage", val);
	}
})