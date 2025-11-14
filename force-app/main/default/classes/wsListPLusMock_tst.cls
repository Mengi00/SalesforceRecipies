@istest
global class wsListPLusMock_tst implements HttpCalloutMock {
    
   	static string jsonbody = '{body:<wsingresobeneficencia.ExecuteResponse xmlns="Listplus"><Wsrespuesta>&lt;?xml version="1.0" encoding="UTF-8"?>&lt;sdtwsrespuestaout xmlns="Listplus">	&lt;IdRespuesta>0&lt;/IdRespuesta>	&lt;Glosa>Ok, Registro guardado&lt;/Glosa>	&lt;Fecha>02/07/24&lt;/Fecha>	&lt;Hora>12:39:26&lt;/Hora>	&lt;IdCaso>2020002371&lt;/IdCaso>&lt;/sdtwsrespuestaout></Wsrespuesta>		</wsingresobeneficencia.ExecuteResponse>,headers: [],attachments: []}';
       
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        // setting response based on endpoint
            String json_token = jsonbody;
            res.setHeader('Content-Type', 'application/json');
            res.setBody( json_token ); 
            res.setStatusCode(200);
        return res;
    }
}