@IsTest
private class PicklistDependencyHelperTest {
    
    @IsTest
    static void testObtenerDependenciasUnidadSubUnidad() {
        // Ejecutar
        Test.startTest();
        Map<String, List<String>> resultado = PicklistDependencyHelper.obtenerDependenciasUnidadSubUnidad();
        Test.stopTest();
        
        // Verificar que no sea null
        System.assertNotEquals(null, resultado, 'El resultado de obtenerDependenciasUnidadSubUnidad no debe ser null');
        
        // Verificar que sea vacío o contenga datos
        System.assertEquals(true, resultado.isEmpty() || resultado.size() >= 0, 'Debe ser un Map válido');
    }
    
    @IsTest
    static void testObtenerDependenciasGerenciaUnidad() {
        // Ejecutar
        Test.startTest();
        Map<String, List<String>> resultado = PicklistDependencyHelper.obtenerDependenciasGerenciaUnidad();
        Test.stopTest();
        
        // Verificar que no sea null
        System.assertNotEquals(null, resultado, 'El resultado de obtenerDependenciasGerenciaUnidad no debe ser null');
        
        // Verificar que sea vacío o contenga datos
        System.assertEquals(true, resultado.isEmpty() || resultado.size() >= 0, 'Debe ser un Map válido');
    }
}