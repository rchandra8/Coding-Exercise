import { LightningElement, api, wire, track } from 'lwc';
import getAddressSuggestions from '@salesforce/apex/AddressInfoFromGMapsAPIController.getAddressSuggestions';
import getDistanceTimeCost  from '@salesforce/apex/AddressInfoFromGMapsAPIController.getDistanceTimeCost';

export default class AddressInfoFromGMapsAPI extends LightningElement {
    @track location;
    @track error;
    showPred = false;
    @track predictions={};
    @track selectedSourcedesc ;
    @track selectedSourcId ;
    @track souceSelected = false;
    @track targetlocation;
    @track targetpredictions;
    @track showPredTarget = false;
    @track selectedTargetdesc ;
    @track selectedTargetId ;
    @track targetSelected = false;
    @track distance;
    @track duration;                
    
    getSourceCities(event){
        this.isError = false;
        this.location = event.target.value;
        if(this.location.length >1 ){
            getAddressSuggestions({ input: this.location })
            .then(result => {
                result = JSON.parse(result);
                this.predictions =  result.predictions;
                this.predictions =  result.predictions;
                this.showPred = true;
            })
            .catch(error => {
                this.error = error;
            });
        }
    }
    
    
    
    CityDetails (event){
        var key = event.currentTarget.dataset.id;       
        
        var foundElement = this.predictions.find(function(element){
            return element.place_id === key;
        });        
        this.location = foundElement.description;
        this.selectedSourcedesc = foundElement.description;
        this.selectedSourcId =key;
        this.showPred = false;
        this.souceSelected = true;
        
    }
    
    
    gettargetCities(event){
        this.isError = false;
        this.targetlocation = event.target.value;
        if(this.targetlocation.length >1 ){
            getAddressSuggestions({ input: this.targetlocation })
            .then(result => {
                result = JSON.parse(result);
                this.targetpredictions =  result.predictions;
                this.showPredTarget = true;              
            })
            .catch(error => {
                this.error = error;
            });
        }
    }
    
    setTargetCityDetails (event){
        var key = event.currentTarget.dataset.id;
        
        var foundElement = this.targetpredictions.find(function(element){
            return element.place_id === key;
        });        
        this.selectedTargetdesc = foundElement.description;
        this.targetlocation = foundElement.description;
        this.selectedTargetId =key;
        this.showPredTarget = false;
        this.targetSelected = true;

    }
    
    duration;
    flightCost;
    drivingCost;
    transitCost;
    distances;
    isError = false;
    response = false;
    getDistanceTimeCost(event){
        if(!this.selectedSourcedesc && !this.selectedTargetdesc){
            console.log('error');
            this.isError = true

        } else{
            this.isError = false;
            
            getDistanceTimeCost({sAdd:this.selectedSourcedesc, tAdd:this.selectedTargetdesc})
            .then(result =>{
                
                console.table(result);
                this.response = true;
                console.log('Distance Check '+result.distance);
                this.duration = result.duration;                
                this.flightCost = result.flightCost;
                this.drivingCost = result.drivingCost;
                this.transitCost = result.transitCost;
                this.distances = result.distance;
                
            })
            .catch(error=>{
            })
        }
    }  
}