@IsTest
public with sharing class CL_CalcularDigitoVerificacion_Test {
    @IsTest
    public static void test() {
        List<Account> ltsnRUT = new List<Account>();
        Account acc = new Account();
        acc.RUT__pc = 66412345;
        acc.Rut_DV__pc = '7';
        ltsnRUT.add(acc);
        Test.startTest();
        List<CL_CalcularDigitoVerificacion.Results> lstResults = CL_CalcularDigitoVerificacion.digitoVerificacion(ltsnRUT);
        System.Assert.areEqual(acc.Rut_DV__pc, '7');
        Test.stopTest();
    }
}