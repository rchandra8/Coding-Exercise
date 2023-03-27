public without sharing class AddressInfoFromGMapsAPIController {
    
    public AddressInfoFromGMapsAPIController() {
    }
    
    @AuraEnabled
    public static string getAddressSuggestions(String input) {
        String url = System.Label.GoogleMapsPlacesAutoAPIURL + 'input=' + EncodingUtil.urlEncode(input, 'UTF-8')
        + getKey();    
        String response = getResponse(url);
        return response;
    }
        
    @AuraEnabled
    public static ApexResponseWrapper getDistanceTimeCost(String sAdd, String tAdd){        
        String url = System.Label.GoogleMapsDistanceMatrixAPIURL + 'origins=' + EncodingUtil.urlEncode(sAdd, 'UTF-8') + '&destinations='
        + EncodingUtil.urlEncode(tAdd, 'UTF-8') + '&units=imperial'
        + getKey();
        String response = getResponse(url);
        //system.debug('getDistanceTimeCost response '+response);        
        ResponseWrapper resWrapper = (ResponseWrapper) Json.deserialize(response, ResponseWrapper.class);
        
        String strDistance = resWrapper.rows[0].elements[0].distance.text;
        String strDistanceNew = strDistance.replace(',', '');
        Decimal duration = Decimal.valueOf( strDistanceNew.subString(0,strDistanceNew.indexOf(' ')));
        List<SF_GMaps_Rate_Setting__mdt> rList = [SELECT ID, Label, CostPerMile__c FROM SF_GMaps_Rate_Setting__mdt];
        Map<String, String> mToRate = new Map<String,String>();
        Decimal carPrice;
        Decimal flyPrice;
        Decimal transitPrice;
        for(SF_GMaps_Rate_Setting__mdt r : rList){
            if(r.Label == 'Driving'){
                carPrice =  duration * r.CostPerMile__c;
            } else if(r.Label == 'Flying'){
                flyPrice =  duration * r.CostPerMile__c;
            } else if(r.Label == 'BusTransit'){
                transitPrice =  duration * r.CostPerMile__c;
            }
        }
        ApexResponseWrapper awrapper = new ApexResponseWrapper();
        awrapper.duration= resWrapper.rows[0].elements[0].duration.text +'';
        awrapper.drivingCost= carPrice+'';
        awrapper.flightCost= flyPrice+'';
        awrapper.transitCost= transitPrice+'';
        awrapper.distance = strDistance;
        // system.debug('awrapper.distance ==> '+awrapper.distance);
        // system.debug('awrapper.duration ==> '+awrapper.duration);      
        return awrapper;
    }
    
    public static string getResponse(string strURL){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        res = h.send(req);
        String responseBody = res.getBody();
        System.debug('Google Maps responseBody ==> ' +responseBody);      
        return responseBody;
    }
    
    public static string getKey(){
        string key =  System.Label.GoogleMapsAPIKey;        
        //string key = 'AIzaSyDEdvn-qzepXWmCWJjOqBPbiLve8Rp5Lp0';
        string output = '&key=' + key;
        return output;
    }
    
    public class ResponseWrapper
    {
        public List<RowsWrapper> rows;
    }
    
    public class RowsWrapper
    {
        List<ElementsWrapper> elements;
    }
    public class ElementsWrapper
    {
        ChildWrapper distance;
        ChildWrapper duration;
    }
    public class ChildWrapper
    {
        public String text;
        public String value;
    }
    
    public class ApexResponseWrapper{
        @auraEnabled public String duration{get; set;}
        @auraEnabled public String drivingCost{get; set;}
        @auraEnabled public String flightCost{get; set;}
        @auraEnabled public String transitCost{get; set;}
        @auraEnabled public String distance{get; set;}
    }
}