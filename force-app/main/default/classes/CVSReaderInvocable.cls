public class CVSReaderInvocable {
  public class InputParams {
    @InvocableVariable(label='IDs de ContentVersion' required=true)
    public List<Id> contentVersionIds;

    @InvocableVariable(label='Primera línea como encabezado' required=true)
    public Boolean firstLineAsHeader;

    @InvocableVariable(label='Índice de columna RUT' required=true)
    public Integer rutColumnIndex;

    @InvocableVariable(label='Índice de columna Tipo de Paciente' required=true)
    public Integer tpdColumnIndex;
  }

  public class OutputParams {
    @InvocableVariable(label='Contactos procesados')
    public List<Contact> contacts;
  }

  @InvocableMethod(label='Leer CSV desde ContentVersion')
  public static List<OutputParams> readCSV(List<InputParams> inputs) {
    List<OutputParams> results = new List<OutputParams>();

    for (InputParams input : inputs) {
      for (Id contentVersionId : input.contentVersionIds) {
        // Recuperar el archivo ContentVersion
        ContentVersion contentVersion = [
          SELECT VersionData
          FROM ContentVersion
          WHERE Id = :contentVersionId
          LIMIT 1
        ];
        String csvContent = contentVersion.VersionData.toString();

        // Debug para mostrar el contenido del archivo CSV
        System.debug('Contenido del archivo CSV: ' + csvContent);

        // Separar el archivo en líneas
        List<String> lines = csvContent.split('\n');
        List<String> headers = new List<String>();
        List<Contact> contacts = new List<Contact>();

        for (Integer i = 0; i < lines.size(); i++) {
          String line = lines[i].trim();
          List<String> columns = line.split(';'); // Cambiado a punto y coma (;)

          // Debug para mostrar el contenido de cada línea
          System.debug('Procesando línea ' + i + ': ' + line);

          // Saltar encabezado si es necesario
          if (i == 0 && input.firstLineAsHeader) {
            headers = columns;
            System.debug('Encabezado encontrado: ' + headers);
            continue;
          }

          System.debug('Columnas procesadas en la fila ' + i + ': ' + columns);

          Contact contactRecord = new Contact();

          try {
            contactRecord.RUT__c = Integer.valueOf(
              columns[input.rutColumnIndex].trim()
            );
            System.debug(
              'RUT asignado en la fila ' + i + ': ' + contactRecord.RUT__c
            );
          } catch (Exception e) {
            System.debug(
              'Error al convertir el RUT en la fila ' +
                i +
                ': ' +
                e.getMessage()
            );
            continue; // Saltar esta fila si ocurre un error
          }

          // Asignar el valor de la columna tpdColumnIndex al campo FirstName
          try {
            contactRecord.FirstName = columns[input.tpdColumnIndex].trim();
            System.debug(
              'FirstName asignado en la fila ' + i + ': ' + contactRecord.FirstName
            );
          } catch (Exception e) {
            System.debug(
              'Error al asignar FirstName en la fila ' +
                i +
                ': ' +
                e.getMessage()
            );
            continue; // Saltar esta fila si ocurre un error
          }

          // Añadir el contacto a la lista
          contacts.add(contactRecord);
        }

        System.debug('Número de contactos procesados: ' + contacts.size());

        OutputParams output = new OutputParams();
        output.contacts = contacts; // Devolver la lista de contactos
        results.add(output);
      }
    }

    // Debug para mostrar los resultados finales
    System.debug('Resultados procesados: ' + results);

    return results;
  }
}