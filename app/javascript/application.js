// // Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// import "controllers"
// import "@hotwired/turbo-rails"
// import "@popperjs/core"
// import "bootstrap"
// console.error("🌐 Controladores importados correctamente")

console.log("application.js se está cargando...")
import "@hotwired/turbo-rails"
console.log("turbo cargado")
import "controllers"
console.log("controllers importado")
import "bootstrap"
console.log("bootstrap importado")
