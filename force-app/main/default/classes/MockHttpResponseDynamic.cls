@isTest
global class MockHttpResponseDynamic implements HttpCalloutMock 
{
    public string jsonBody {get;set;}
    public integer statusCode {get;set;}
    global HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(this.jsonBody);
        res.setStatusCode(this.statusCode == null ? 200 : this.statusCode);
        res.setStatus('Created');
        return res;
    }
}