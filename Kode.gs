var sheet = SpreadsheetApp.openById("1dbvOzSa7iUKtwUJb4AwKFSNQQ7laK9PixcPo7WGjDJU").getSheetByName("Sheet1");
var firebaseUrl = "https://mobile-iot-c-default-rtdb.asia-southeast1.firebasedatabase.app/data/sensor/";


// Fungsi untuk mengambil data dari Firebase Realtime Database
function getAllData() {
  var base = FirebaseApp.getDatabaseByUrl(firebaseUrl);
  var dataSet = [base.getData()];
  var rows = [],data;
  for (i = 0; i < dataSet.length; i++) {
    data = dataSet[i];
    sheet.appendRow([data.kelembaban, data.suhu, String(data.updated_at)]);
  }
}


// Fungsi untuk mengirim data pada SpreadSheet ke Flutter
function sendToFlutter() {
  var values = sheet.getDataRange().getValues();
  var arr_data = [];

  for (var i = 1; i<values.length; i++)
  {
    var feedback = {};
    feedback['kelembaban'] = values[i][0];
    feedback['suhu'] = values[i][1];
    feedback['updated_at'] = values[i][2];
    arr_data.push(feedback);
  }

  return arr_data;
}


// Fungsi untuk mentrigger fungsi getAllData() di atas dengan
// menerima parameter 'trigger' dengan value 'true'
function doGet(e) {
  var params = e.parameter;
  var _fetchData = params.fetch;
  var trigger_value = params.trigger;
  if(trigger_value == "true"){
    getAllData();
    return ContentService.createTextOutput();
  }
  if(_fetchData == "true")
  {
    return ContentService.createTextOutput(JSON.stringify(sendToFlutter())).setMimeType(ContentService.MimeType.JSON);
  }
}