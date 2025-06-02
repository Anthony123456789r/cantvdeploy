function mensajeError(text){
  Swal.fire({
  icon: 'error',
  title: 'Oops...',
  text: text,
});
}

function mensajeExito(text){
  Swal.fire({
  position: 'top-end',
  icon: 'success',
  title: text,
  showConfirmButton: false,
  timer: 1500
})
}

function mensajeSospecha(){
  Swal.fire(
  "estas tratadnod e hacer algo indevido? Te estamos observando, cuidadito o_O"
)
}
