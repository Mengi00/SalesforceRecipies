public class wsListPlusParser {

 	public class request{
        public String Usuario {set; get;}
        public String Clave {set; get;}
        public Integer Tipoiden {set; get;}
        public String Nroiden {set; get;}
        public String Nhc	 {set; get;}
        public String Nombre {set; get;}
        public String Apepat {set; get;}
        public String Apemat {set; get;}
        public String Fecnactex {set; get;}
        public Integer Edad {set; get;}
        public Integer Genero	 {set; get;}
        public String Direccion {set; get;}
        public String Pais {set; get;}
        public String Region	 {set; get;}
        public String Comuna {set; get;}
        public String Nacionalidad {set; get;}
        public String Telefono {set; get;}
        public String Email {set; get;}
        public String Tipoprevi {set; get;}
        public String Prevision {set; get;}
        public Integer Fonasa	 {set; get;}
        public Integer Segurocomple {set; get;}
        public Integer Requiereevaa {set; get;}
        public Integer Requiereevag {set; get;}
        public String Fai {set; get;}
        public String Derivado {set; get;}
        public String Contactoderi	 {set; get;}
        public String Casosalesforce {set; get;}
        public String Nomdocu {set; get;}
        public String Tipodoc	 {set; get;}
        public String Urldes {set; get;}
    }
    
 	public class requestDocument{
        public String Usuario {set; get;}
        public String Clave {set; get;}
        public Integer Casoid {set; get;}
        public String Casosalesforce {set; get;}
        public String Nomdocu	 {set; get;}
        public String Tipodoc {set; get;}
        public String Documento {set; get;}
    }
    
    
    public class requestPlan{
        public String sistema_origen {set; get;}
        public String usuario {set; get;}
        public String fecha_accion {set; get;}
        public String id_plan_tto {set; get;}
        public String opcion	 {set; get;}
    }
    
    public class responseBody{
        public Integer code {set; get;}
        public String desc1 {set; get;}
        public result result {set; get;}
    }
    
    public class result{
        public String document {set; get;}
    }

    public static Boolean isSandbox(){
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        return runningInASandbox;
    }
}