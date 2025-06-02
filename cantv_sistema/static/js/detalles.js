
// Obtener elementos del DOM
    const categoriaSelect = document.getElementById("categoria");
    const lucesPonInput = document.getElementById("luces_pon_intermitente");
    const conexionDiv = document.getElementById("conexion");
    const hidaDiv = document.getElementById("hida");
    const fallaConexionSelect = document.getElementById("falla_conexion");
    const fallaHidaSelect = document.getElementById("falla_hida");
    const internetLentoDiv = document.getElementById("internet_lento");


    // Función para mostrar o ocultar el div correspondiente
    function mostrarOcultarDiv() {
            if (categoriaSelect.value === "Sin conexión a internet") {
                conexionDiv.style.display = "block";
                hidaDiv.style.display = "none";
                internetLentoDiv.style.display = "none";
                fallaHidaSelect.selectedIndex = 0;
                campo1Input.value = "";
                campo2Input.value = "";
            } else if (categoriaSelect.value === "Servicio Intermitente") {
                conexionDiv.style.display = "none";
                fallaConexionSelect.selectedIndex = 0;
                hidaDiv.style.display = "block";
                internetLentoDiv.style.display = "none";
                campo1Input.value = "";
                campo2Input.value = "";
            } else if (categoriaSelect.value === "lento") {
                conexionDiv.style.display = "none";
                fallaConexionSelect.selectedIndex = 0;
                hidaDiv.style.display = "none";
                fallaHidaSelect.selectedIndex = 0;
                internetLentoDiv.style.display = "block";
            } else {
                conexionDiv.style.display = "none";
                fallaConexionSelect.selectedIndex = 0;
                hidaDiv.style.display = "none";
                fallaHidaSelect.selectedIndex = 0;
                internetLentoDiv.style.display = "none";
                campo1Input.value = "";
                campo2Input.value = "";
            }
        }
        // Función para desactivar el input si la categoría es "Internet lento"
            function desactivarInput() {
                if (categoriaSelect.value === "lento") {
                    lucesPonInput.disabled = true;
                } else {
                    lucesPonInput.disabled = false;
                }
            }

    // Event listener para el cambio en el select de categoría
    categoriaSelect.addEventListener("change", desactivarInput);

    // Event listener para el cambio en el select de categoría
    categoriaSelect.addEventListener("change", mostrarOcultarDiv);
