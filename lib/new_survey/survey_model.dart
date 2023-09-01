class SurveyInfoModel {
  String siteName = "";
  String address = "";
  String date  = DateTime(1946,1,1).toString();
  String occupancyType = "";
  bool carbonDioxideReadings = false;
  bool carbonMonoxideReadings = false;
  bool vocs = false;
  bool pm25 = false;
  bool pm10 = false;
  
  SurveyInfoModel({this.siteName = "", this.address = "", this.date = "", 
              this.occupancyType = "", this.carbonDioxideReadings = false,this.carbonMonoxideReadings = false,this.vocs = false,
               this.pm25 = false, this.pm10 = false});
}