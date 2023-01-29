@IsTest
public class ReactiveWorkOrderListTest 
{
    public static String json = '{'+
		'    \"items\": ['+
		'        {'+
		'            \"id\": \"123123\",'+
		'            \"wo_num\": \"B123123\",'+
		'            \"wo_type\": \"Work Order\",'+
		'            \"wo_status\": \"Resolved Without Invoice\",'+
		'            \"location_num\": \"PET111\",'+
		'            \"client_id\": \"1\",'+
		'            \"wo_nte\": 750.00,'+
		'            \"call_time\": \"2021-11-14T22:11:18Z\",'+
		'            \"caller_name\": \"Store PET111\",'+
		'            \"schedule_start_time\": \"2021-11-14T14:54:04Z\",'+
		'            \"schedule_end_time\": \"2021-11-15T14:54:04Z\",'+
		'            \"complete_time\": \"2021-11-14T22:15:00Z\",'+
		'            \"priority_name\": \"4 h response\",'+
		'            \"priority_id\": 2,'+
		'            \"tech_name\": \"Phoenix Energy Technologies, Inc. (DE) 1021313\",'+
		'            \"helper_tech_names\": null,'+
		'            \"problem_description\": \"Air Conditioning/Heating->Unit->Not Heating\",'+
		'            \"additional_detail\": \"The unit is blowing cool air. Appears to be working as the ac unit is on not the heat. \",'+
		'            \"service_category\": \"Air Conditioning/Heating\",'+
		'            \"service_type\": \"Unit\",'+
        '            \"main_store_area\": \"Test\",'+
        '            \"store_subarea\": \"Unit\",'+
		'            \"problem_code\": \"Not Heating\"'+
		'        }'+
		'    ],'+
		'    \"totalItemsCount\": 1'+
		'}';
    
	public static testMethod void runTest() 
    {
		
		ReactiveWorkOrderList obj = ReactiveWorkOrderList.parse(json);
		System.assert(obj != null);
	}
}