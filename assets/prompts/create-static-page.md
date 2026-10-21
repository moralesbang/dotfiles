# Static page application

Quiero construir una aplicación usand shadcn y Tailwind. La estética será Windos XP. Este proyecto va resultar en una página estática para mostrar algunas cosas que quiero vender. Vamos a tener categorias y los detalles del producto. Si alguien está interesado en un producto va a clickear a manera de comprar "Me interesa" y cuando le haga hover diga "Hablar con Milo" (Yo soy Milo).

Cómo no hay backoffice entonces vamos a tener una carpeta que se llame "data" allí vamos a tener dos cosas: un .json que especifica todos los metadatos de un producto y un carpeta "photos" dentro vamos a tener una carpeta para cada producto con las respectivas fotos. Dentro del .json que mencioné anteriormente va a haber algo como `{name: "Teclado", photos_path: '../photos/teclado". El archivo .json va a tener comentada la data de ejemplo.

Los datos que vamos a mostrar de un producto son:
- Nombre
- Descripción
- Precio (aprox.)
- Opinión de Milo (opcional). Sino está presente no se muestra este atributo.

*Requerimientos del producto*

- Va a haber una barra de búsqueda por nombre y un filtrado por categoría y ordenar por precio de mayor a menor y viceversa.
- El botón de "Me interesa" lleva a un link de whatsapp para escribirme al número +573505824901 con el link del producto.


Es un requerimiento MUY importante que se vea perfectamente primero en mobile.

*Notas*
- Preguntame por cualquier duda que tengas sobre el producto antes de continuar. Una pregunta a la vez.
- Si necesitas contexto adicional sobre un gap o alguna sugerencia de algo que me faltó implementar preguntamelo si es algo que llena un gap, si es un feature adicional ponlo en /docs/nice-to-have.md.
- Eres libre de instalar cualquier librería que necesites.
- Tú decides la arquitectura de archivos.
- No es necesario implementar ningún tipo de tests.
- Vas a escribir un AGENTS.md con la información extremedamente que necesites en cualquier otra sesión para modificar la base de código.
- El lenguaje en el que se muestra la aplicación es en español y los precios siempre van a estar dados en COP (Pesos colombianos).
- El proyecto lo vas a subir en mi cuenta personal en github con el user moralesbang, lo vas a hacer privado.
- Todo el código, ficheros y directorios va a estar en inglés, solamente el lenguaje para el usuario es en Español.
- Todo lo mandamos a `main` no crees ramas, ni PRs. Usa nombres que sigan una misma estructura y todo para los commits (Agrega esto en un CONTRIBUTING.md).


*Los valores que guían las decisiones*
- Disciplina
- Atención al detalle
- Funcionalidad primero

