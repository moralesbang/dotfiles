1. Evalua: Code quality, Project vision, Behaviour.
2. Create the PR: Report with link.
3. Generate reviewer message using the above report.

## Code quality

*Objetivo*:
El código que estamos enviando sigue los estándares de Humand y personales, además sigue los criterios base de "/code-review" propuestos por Matt.

## Project vision (Enhance initiative)


*Context*
El proyecto de PX ha pasado por varios procesos de transformación, aspectos o areas que fueron cambiando a través del tiempo: Arquitectura, Organización de archivos, Migración a un Design system consolidado, migración entre versiones del DS, Integración de testing e iteración de features.

Actualmente algunas partes se han ido arreglando de a poco y plan de acción para el resto es progresivamente en cada nuevo feature de manera proactiva proponer introducir cambios que ayude a acercarse a la visión en cada uno de de los aspectos mencionados anteriormente.

*Problemas identificados*
1. Algunos componentes, utils, constantes, tipos, etc. necesita re-colocarse para seguir el standar de Humand.
2. Algunos imports de @material-hu no se hacen de manera correcta o apuntan directamente a material-hu. (Detallar).
3. Aún existen types que son redundantes y/o existen en material-hu/people-experience. (Detallar).
4. El usar material-hu como punto para centralizar lógica común (types, utils y constants) es una práctica deprecated. Esta lógica debe vivir en cada repo. 
5. Centralizar UI dentro de material-hu sigue siendo un práctica válida. Aunque se debe definir una nueva organización de directorios/archivos. 
6. Vamos a agregar un check para el agente que le ayuda a válidar que el comportamiendo y UI son iguales para Twin features (Definir este concepto para el agente).

*Objetivo*:
El proyecto se alinea con una base de código qué queremos contruir.

*¿Qué es espera a medida que se van haciendo entregas?*

