import 'package:gsheets/gsheets.dart';
import 'package:proyek_akhir_miot_c/models/dataSensor.dart';

class SheetsAPI {
  static const _credentials = r'''
{
  "type": "service_account",
  "project_id": "mobile-iot-c",
  "private_key_id": "46500f0e4a06eeed0cd7dfbe222292346124cc3e",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDPbS/g7JvkPQjK\ndK80elX4hVwgec8jBjyaYXI7UV3Us0WaiN8Q1PAm2qozDg29DBnMLZYrG0mRh9Sm\nC6DnQyt7sYl6PGwfb2gWtqQS9scotpYWvNm4nkQ5tyP3o7eEUm2Zl01rQMA5tC0V\nC/EHcbRdYt/LHjtTH/gZ4ukSORoQtQsKpxL4PcgX4OUCEqUCOMoUW1Nbh6sp/gcK\nrwhL75sBHU9jZEo2ipv6w+t6uWlyuA030ITeT6kzXwVGGKI+gEZYzPf98HEAnJzy\n58FrGxU8uL5rAb4ucSKtEyle2C6/+cnD+uSCkwwQcRVVBIviYUwNGAplxMnywvBQ\n8nihKC4bAgMBAAECggEAUH3O2AoJHoL+v82S1ZrpdJSPoPyTwEQhzUimMtWKw0jD\n6ElXwmjXPkSZSlGYTDV/Z0eDX/vpSwN6JesaR9O9cnT848XBsVsiebnrJn7D3w0n\nZfBnzmgAEqN6XhUWWE9CP5lCji2kyl+cJPAq2pgphRmivWfgXovn02fFyPAGqNdd\ndMlwfvDNA0lvHwpF42MrnrETkvkXHAhw0aoOTCIvEofFMaBHq9pC8lDG/sFjd3Ey\n0jdZQw5Wfh6Wv0JgP3a/htMPqXFBS9/7mj39oTGXjc+Onf+LFHpptyWqgopnPBGP\nsAYuHGfhtfmuWldh3VDr1DhtbGi7B6mikJmsBtgrOQKBgQDotRkXvKuM66hAUqoe\n5XPL2umI4LfHODVfix9yUtOmzTWXdY0eAiqlr2+vOuwwsXpr6EYYJIys0A9KhArA\nrY82Sfh0vdz5M3SPtAgRWhsP44eTbEgP19gp2Rhv7w522WLi8XLPSEvX2mo42HZR\nnMwJbhkEfpZ10FYD/YgC+2JkQwKBgQDkMEpWnD/lCO89t7vxk/+qBs3hINkpHQ7i\nDXnp35ixYXtRVwDCJ74MYkXXrpT7/I89WT4tlgPwG4c0vMc8bkx1mwg1RaIqMbxV\nPLlEIleN9/dMOmvwQxBlZu7N6MuZFUs9t+7NfA0XHGYyC2IhXGFXkUnUOQINhppr\nmzNzg2odSQKBgQDMLxr1WPatj5jx15atxWb1V//RuluG0isCym+tQD+1/Bkp7FsG\nGaCSAH1eo7TahN+GDyhxxqAogebo2zMUHTWrzPvUc0OQ5TVBYhYyI33bUymCkWAp\nhpqFHZfzny5x2gyKVJEIj8b8fwj1F/m5YnslSxVofCpI9aSDm9Hby/dpQQKBgBB4\n9/TWpLoo8fRXniarU2p3wUb+Mw8HvPpOlL1wWbp8WgWeLTzW155XPcl7HeAu9Dwu\nhBGQYcpkglcpRYy0ParDvUzzMOiw3HKexpUHkaB7BQwor4ARp05apuSQaJotclgL\nPh7xVJSVhT8ZmUTlQVWr9FNwphhJ3j3kX0t4ciGZAoGBAOIVQn0xb1OWYLfGj9/u\nsJX3NwHypbRmNPr7NvOmzntFFlWeCXds7tGcp+aN4XCd4eeUp4Nazk3A9VVqFqMU\nJde1cacjTzP1iaf/aVrTbswuPek29XIK0OX17HXFwLaFbSzyql3fBO5AMdoH9xll\nXqzCOQxoHuX4j0dW6Z8Yf6Kb\n-----END PRIVATE KEY-----\n",
  "client_email": "miot-c-k2@mobile-iot-c.iam.gserviceaccount.com",
  "client_id": "110693219238869315306",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/miot-c-k2%40mobile-iot-c.iam.gserviceaccount.com"
}

''';

  static final _spreadsheetId = '1dbvOzSa7iUKtwUJb4AwKFSNQQ7laK9PixcPo7WGjDJU';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _dataSheet;

  static Future init() async {
    final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
    _dataSheet = await _getWorkSheet(spreadsheet, title:'Sheet1');

  }

  static Future<Worksheet> _getWorkSheet(
    Spreadsheet spreadsheet, {
      required String title,
    }
  ) async {
    try {
      return await spreadsheet.addWorksheet(title);
      
    } catch (e) {
      return spreadsheet.worksheetByTitle(title)!;
      
    }
  }

  static Future<List<dataSensor>> getAll() async {

    if (_dataSheet == null) return <dataSensor>[];

    final datas = await _dataSheet!.values.map.allRows();
    return datas == null? <dataSensor>[] : datas.map(dataSensor.fromJson).toList();

  }
}