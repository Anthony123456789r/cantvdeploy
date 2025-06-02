// static/js/solicitudForm.js

document.addEventListener('DOMContentLoaded', function () {
    const form = document.getElementById('clientForm');
    const solicitudSelect = document.getElementById('solicitud');
    const hiddenRequestFieldsDiv = document.getElementById('hiddenRequestFields');
    const cambioServicioFields = document.getElementById('cambioServicioFields');
    const MudanzaFields = document.getElementById('MudanzaFields');
    const retiroServicioFields = document.getElementById('retiroServicioFields');
    const planSelect = document.getElementById('plan'); // Although not directly used for required, useful for reference
    const direccionNuevaTextarea = document.getElementById('direccionNueva');
    const motivoRetiroTextarea = document.getElementById('motivoRetiro');

    // NOTE: cuadrillaInput, odnSelect, fatSelect were in your original script.
    // They are included here for completeness but are NOT present in the provided HTML.
    // Ensure these elements exist in your template if you intend to use them.
    const cuadrillaInput = document.getElementById('cuadrilla'); 
    const odnSelect = document.getElementById('odnSelect');     
    const fatSelect = document.getElementById('fatSelect');     


    /**
     * Adjusts the height of a textarea to fit its content.
     * @param {HTMLTextAreaElement} element - The textarea element to adjust.
     */
    function adjustTextareaHeight(element) {
        if (element) {
            element.style.height = 'auto'; // Reset height to recalculate
            element.style.height = (element.scrollHeight) + 'px'; // Set height based on scrollHeight
        }
    }

    // Adjust the height of the cuadrilla textarea on input and initially (if it exists)
    if (cuadrillaInput) {
        cuadrillaInput.addEventListener('input', function() {
            adjustTextareaHeight(this);
        });
        adjustTextareaHeight(cuadrillaInput); // Initial adjustment
    }
    
    // Adjust height for textareas for Mudanza and Retiro fields
    if (direccionNuevaTextarea) {
        direccionNuevaTextarea.addEventListener('input', function () {
            adjustTextareaHeight(this);
        });
        adjustTextareaHeight(direccionNuevaTextarea); // Initial adjustment
    }
    if (motivoRetiroTextarea) {
        motivoRetiroTextarea.addEventListener('input', function () {
            adjustTextareaHeight(this);
        });
        adjustTextareaHeight(motivoRetiroTextarea); // Initial adjustment
    }

    // Form submission event listener for Bootstrap validation
    form.addEventListener('submit', function (event) {
        if (!form.checkValidity()) {
            event.preventDefault();
            event.stopPropagation();
        }
        form.classList.add('was-validated'); // Add class to show validation feedback
    }, false);

    // Add Bootstrap validation styles on input change and blur for all relevant form elements
    Array.from(form.elements).forEach(input => {
        if (input.tagName === 'SELECT' || input.tagName === 'INPUT' || input.tagName === 'TEXTAREA') {
            input.addEventListener('input', validateInput);
            input.addEventListener('blur', validateInput);
        }
    });

    /**
     * Reusable validation function for form inputs.
     */
    function validateInput() {
        const input = this;

        // Custom validity for number inputs
        if (input.type === 'number') {
            if (isNaN(input.value) && input.value !== '') {
                input.setCustomValidity('Por favor, introduzca un número válido.');
            } else {
                input.setCustomValidity('');
            }
        }

        // Special handling for email input
        if (input.type === 'email') {
            if (input.value.trim() === '') {
                input.setCustomValidity('El correo electrónico es obligatorio.');
            } else if (input.validity.typeMismatch) {
                input.setCustomValidity('Por favor, introduzca un correo electrónico válido.');
            } else {
                input.setCustomValidity('');
            }
        }

        // Custom validation for textareas (direccionNueva and motivoRetiro)
        if (input.id === 'direccionNueva' || input.id === 'motivoRetiro') {
            // Only set custom validity if required and empty, otherwise rely on browser
            if (input.required && input.value.trim() === '') {
                input.setCustomValidity(input.placeholder + ' es obligatorio.');
            } else {
                input.setCustomValidity('');
            }
        }

        // Set Bootstrap validation classes
        if (input.checkValidity()) {
            input.classList.remove('is-invalid');
            input.classList.add('is-valid');
        } else {
            input.classList.remove('is-valid');
            input.classList.add('is-invalid');
        }
    }

    // Logic to show/hide fields based on selected request type
    solicitudSelect.addEventListener("change", function () {
        // Hide all hidden fields first and clean their state
        const hiddenFields = hiddenRequestFieldsDiv.querySelectorAll("div.col-12");
        hiddenFields.forEach(function (field) {
            field.classList.add('d-none'); // Hide the field using d-none
            field.classList.remove('d-flex'); // Ensure d-flex is removed if it was present
            Array.from(field.querySelectorAll('input, select, textarea')).forEach(el => {
                el.removeAttribute('required'); // Remove required attribute
                el.classList.remove('is-valid', 'is-invalid'); // Clear validation styles
                // Clear values of hidden fields to prevent submitting old data
                if (el.tagName === 'SELECT') {
                    el.value = ''; // Reset select to default option
                } else {
                    el.value = ''; // Clear text/number inputs
                }
            });
        });

        // Show the relevant field and add back the required attribute
        const selectedOption = solicitudSelect.value;
        let fieldToShow;
        if (selectedOption === "cambioServicio") {
            fieldToShow = cambioServicioFields;
        } else if (selectedOption === "Mudanza") {
            fieldToShow = MudanzaFields;
        } else if (selectedOption === "retiroServicio") {
            fieldToShow = retiroServicioFields;
        }

        if (fieldToShow) {
            fieldToShow.classList.remove('d-none'); // Show the field
            fieldToShow.classList.add('d-flex'); // Apply flex display for column layout (or block, depending on your desired layout)
            Array.from(fieldToShow.querySelectorAll('input, select, textarea')).forEach(el => {
                el.setAttribute('required', 'required'); // Add required attribute
                // Immediately adjust height for any textareas that become visible
                if (el.tagName === 'TEXTAREA') {
                    adjustTextareaHeight(el);
                }
                // Re-validate if it has a value (e.g., if user re-selects an option with pre-filled data)
                if (el.value && el.value.trim() !== '') {
                    validateInput.call(el);
                }
            });
        }
        // Trigger validation for the main select itself (Tipo de Solicitud)
        validateInput.call(solicitudSelect);
    });


    // jQuery for dynamic FAT selection (only if odnSelect and fatSelect elements exist in the template)
    if (odnSelect && fatSelect) {
        $(odnSelect).on("change", function () {
            var selectedOdn = $(this).val();

            // Clear existing options in the FAT selection, keeping the default disabled option
            $(fatSelect).find('option:gt(0)').remove();

            if (selectedOdn) {
                $.ajax({
                    url: "/obtener_fats/", // Ensure this URL is configured in your urls.py
                    data: {
                        'odn_id': selectedOdn
                    },
                    dataType: 'json',
                    success: function (data) {
                        const numberOfFats = parseInt(data.number_of_fats);

                        for (let i = 1; i <= numberOfFats; i++) {
                            $(fatSelect).append($('<option></option>')
                                .attr('value', i) // The value should be the ID of the FAT
                                .text('FAT' + i)
                            );
                        }

                        // Try to select the FAT that was previously selected (e.g., after a form submission)
                        // The value `{{ request_post.fat }}` needs to be passed from Django context.
                        // You might need to set it as a data attribute on the #fatSelect element,
                        // or declare a global JS variable in your Django template.
                        // For example: <script>window.django_request_post_fat = "{{ request_post.fat }}";</script>
                        const storedFat = typeof window.django_request_post_fat !== 'undefined' ? window.django_request_post_fat : null;
                        if (storedFat) {
                            $(fatSelect).val(storedFat);
                        }
                        fatSelect.dispatchEvent(new Event('change')); // Trigger change for validation
                    },
                    error: function (xhr, status, error) {
                        console.error("Error al obtener los FATs:", error);
                    }
                });
            } else {
                // If no ODN is selected, reset FAT validation
                fatSelect.dispatchEvent(new Event('change'));
            }
        });

        // Activate the change on load if an ODN was already selected (e.g., after a POST request)
        // Similar to storedFat, `{{ request_post.odn }}` needs to be passed.
        const initialOdn = typeof window.django_request_post_odn !== 'undefined' ? window.django_request_post_odn : null;
        if (initialOdn) { // Only if initialOdn is not empty
            $(odnSelect).val(initialOdn);
            $(odnSelect).trigger('change');
        }
    }


    // Trigger change event on solicitudSelect to show relevant fields if form was pre-filled
    // The value `{{ request_post.solicitud }}` needs to be passed from Django context.
    const initialSolicitud = typeof window.django_request_post_solicitud !== 'undefined' ? window.django_request_post_solicitud : null;
    if (initialSolicitud) {
        solicitudSelect.value = initialSolicitud;
        solicitudSelect.dispatchEvent(new Event('change'));
    } else {
        // Initial validation for the select on load if no initial solicitud is set
        validateInput.call(solicitudSelect);
    }

}); 