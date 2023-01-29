public class ReactiveWorkOrderList 
{
	//used by SMSAssist API
	public List<Items> items;
	public Integer totalItemsCount;

	public class Items 
    {
		public String id;
		public String wo_num;
		public String wo_type;
		public String wo_status;
		public String location_num;
		public String client_id;
		public Double wo_nte;
		public String call_time;
		public String caller_name;
		public String schedule_start_time;
		public String schedule_end_time;
		public String complete_time;
		public String priority_name;
		public Integer priority_id;
		public String tech_name;
		public String helper_tech_names;
		public String problem_description;
		public String additional_detail;
		public String service_category;
		public String service_type;
		public String problem_code;
        public string main_store_area;
        public string store_subarea;
        
	}
	public static ReactiveWorkOrderList parse(String json) 
    {
		return (ReactiveWorkOrderList) System.JSON.deserialize(json, ReactiveWorkOrderList.class);
	}
    public static Case convertWorkOrderToCase(Items wo, Map<string, Account> accountMap, string defaultAccountId)
    {        
        Case c = new Case();
        c.Customer_WO__c = wo.wo_num;
        c.X3rd_Party_WO_Id__c = wo.id;
        c.Origin = 'Third Party';
        c.AccountId = accountMap.isEmpty() || string.isBlank(wo.location_num) ? defaultAccountId : (accountMap.containsKey(wo.location_num) ? accountMap.get(wo.location_num).Id : defaultAccountId);
        //c.Integration_Message__c = m.Id; decide if we need to generate one of these or not..we could serialize the payload and create one, but then it runs the trigger
        c.X3rd_Party_Priority__c = wo.priority_name;
        c.X3rd_Party_Issue_Type__c = wo.service_type;
        c.X3rd_Party_Problem__c = wo.service_category;
        c.X3rd_Party_System__c = 'SMS Assist';
        c.Main_Store_Area__c = wo.main_store_area != null ? wo.main_store_area : null;
        c.Store_Sub_Area__c = wo.store_subarea != null ? wo.store_subarea : null;
        
        c.Subject = !string.isBlank(wo.problem_description) ? wo.problem_description : wo.wo_type;
        c.Description = wo.additional_detail;
        
        return c;
    }
}