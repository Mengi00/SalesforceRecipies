global with sharing class CL_CalcularDigitoVerificacion {
    @InvocableMethod(label='Carlcular Digito Verificartor' description='Invocar al servicio para carlcular el digito verificador con base al número de RUT cargado' category='Identificacion')
    public static List<Results> digitoVerificacion(List<Account> ltsnRUT){
        List<Results> lstResults = new List<Results>();
        Results resultadoInvocacion = new Results();
        try {
            String rut = String.valueOf(ltsnRUT[0].RUT__pc);
            String rutReverso = rut.reverse();
            List<Integer> numeros = new List<Integer>();
            List<Integer> lstResultados = new List<Integer>();
            Integer multiplicador = 2;
            Integer acumulado = 0;
            Integer resultado = 0;
                
            for(Integer i = 1; i <= rutReverso.length(); i++){
                numeros.add(Integer.valueOf(rutReverso.left(i).right(1))); 
            
            }
            for(Integer num : numeros){
                acumulado = acumulado + (num * multiplicador);
                lstResultados.add(num * multiplicador);
                multiplicador = multiplicador + 1;
                
                if(multiplicador > 7){
                    multiplicador = 2;
                }
            }
            resultado = Double.valueOf(acumulado / 11).intValue();
            resultado = resultado * 11;
            resultado = Math.abs(acumulado - resultado);
            resultado = 11 - resultado;
            String digitoVerificacion;
            if(resultado == 10){
                digitoVerificacion = 'K';
            }
            else if(resultado == 11){
                digitoVerificacion = '0';
            }else{
                digitoVerificacion = String.valueOf(resultado);
            }
            if(!digitoVerificacion.equalsIgnoreCase(ltsnRUT[0].Rut_DV__pc)){
                resultadoInvocacion.error = 'El digito verificador no coincide, por favor verifique el valor del mismo, para continuar.';
            }
            lstResults.add(resultadoInvocacion);
        } catch (Exception e_Ios) {
            resultadoInvocacion.error = 'Error al generar el digito verificador, intente de nuevo o consulte con el administrador '+e_Ios.getMessage();
            lstResults.add(resultadoInvocacion);
        }
        return lstResults;
    }
    global class Results {
        @InvocableVariable(label='texto de error' description='Si el calculo no se proceso correctamente, se incluye mensaje de error' required=false)
        public String error;
    }
}