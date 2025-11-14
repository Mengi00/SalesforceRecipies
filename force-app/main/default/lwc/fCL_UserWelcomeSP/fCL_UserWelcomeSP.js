import { LightningElement, track, wire } from "lwc";
import USER_ID from "@salesforce/user/Id";
import getUserInfo from "@salesforce/apex/UserInfoController.getUserInfo";

export default class MyFirstLWC extends LightningElement {
  // Propiedades reactivas para almacenar la información del usuario
  @track user = {
    name: "",
    department: "",
    subunitNames: [],
    unitNames: []
  };

  // Decorador @wire para llamar automáticamente al método Apex `getUserInfo`
  // Se pasa el ID del usuario actual como parámetro
  @wire(getUserInfo, { userId: USER_ID })
  wiredUserInfo({ error, data }) {
    console.log("Id de usuario actual:", USER_ID);
    // Si se obtienen datos, se asignan a las propiedades del usuario
    if (data) {
      this.user.name = data.name;
      this.user.department = data.department;
      this.user.subunitNames = data.subunitNames;
      this.user.unitNames = data.unitNames;
    } else if (error) {
      //si ocurre un error, se asigna a la propiedad error
      this.error = error;
      this.user.name = undefined;
      this.user.department = undefined;
      this.user.subunitNames = [];
      this.user.unitNames = [];
    }
  }

  get userDepartmentOrUnits() {
    // Primero, verificamos que tengamos datos del usuario para evitar errores.
    if (!this.user) {
      return "Cargando...";
    }

    // Regla 1: Si hay MÁS de una subunidad, mostramos las UNIDADES padre.
    if (this.user.subunitNames && this.user.subunitNames.length > 1) {
      // Se unen los nombres de las unidades en un solo texto.
      return this.user.unitNames.join(", ");
    }

    // Regla 2: Si hay EXACTAMENTE una subunidad, se le da prioridad y la mostramos.
    if (this.user.subunitNames && this.user.subunitNames.length === 1) {
      return this.user.subunitNames[0]; // Se muestra el nombre de esa única subunidad.
    }

    // Regla 3: Si no hay subunidades, revisamos si existe un departamento.
    if (this.user.department) {
      return this.user.department;
    }
  }
}