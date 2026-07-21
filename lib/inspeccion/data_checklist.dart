import 'models.dart';

final List<Seccion> checklistDatos = [
  Seccion(
    titulo: "5. DISPOSICIONES GENERALES",
    subsecciones: [
      SubSeccion(
        titulo: "5.2.1 DE LA UBICACIÓN Y ESTRUCTURA FÍSICA",
        preguntas: [
          Pregunta(id: "1", pe: 3, obsCumple: "El establecimiento es de uso exclusivo para actividades relacionadas con alimentos y no presenta conexión con ambientes que generen contaminación cruzada.", texto: "El establecimiento es de uso exclusivo para la actividad con alimentos y no tiene conexión con otros ambientes o locales que puedan implicar contaminación cruzada para los alimentos."),
          Pregunta(id: "2", pe: 3, obsCumple: "La ubicación del establecimiento no representa riesgo de contaminación para los alimentos elaborados.", texto: "El establecimiento asegura que su ubicación no represente un riesgo de contaminación cruzada para los alimentos que elaboran. Los terrenos que hayan sido rellenos sanitarios, basurales, cementerios, pantanos o que están expuestos a inundaciones frecuentes no pueden ser destinados a la construcción de establecimientos de alimentos."),
          Pregunta(id: "3", pe: 2, obsCumple: "El establecimiento cuenta con medidas efectivas de protección frente a fuentes externas de contaminación.", texto: "El establecimiento debe establecer medidas o barreras eficaces de protección contra fuentes de contaminación externa (plagas, generación de polvo, humos, gases, malos olores, aguas servidas, animales silvestres, entre otros factores de riesgo de contaminación), lo que debe ser demostrado objetivamente y verificado en la vigilancia sanitaria que realice la autoridad competente."),
          Pregunta(id: "4", pe: 2, obsCumple: "La infraestructura y materiales de construcción se mantienen en buen estado de conservación e higiene.", texto: "La estructura física en general es mantenida en buen estado de conservación e higiene; y, los materiales utilizados en la construcción de los ambientes donde se manipulan alimentos son resistentes a la corrosión, de superficies lisas, fáciles de limpiar y desinfectar de tal manera que no transmitan ninguna sustancia indeseable a los alimentos.	"),
          Pregunta(id: "5", pe: 2, obsCumple: "El establecimiento dispone de un sistema adecuado para la evacuación y limpieza de humos y gases.", texto: "El establecimiento cuenta con un procedimiento adecuado y efectivo de evacuación de humos y gases propios del proceso de elaboración de alimentos, que se limpia periódicamente de la grasa impregnada, a fin de no constituir riesgo de contaminación cruzada, ni de contaminación al ambiente."),
        ],
      ),
      SubSeccion(
        titulo: "5.2.2 DE LOS AMBIENTES",
        preguntas: [
          Pregunta(id: "6", pe: 2, obsCumple: "El establecimiento cuenta con espacio suficiente para el desarrollo seguro de sus operaciones.", texto: "El establecimiento dispone de espacio suficiente para realizar todas las operaciones con los alimentos, en concordancia con su carga de producción."),
          Pregunta(id: "7", pe: 1, obsCumple: "No se evidencian materiales, equipos u objetos en desuso en áreas de manipulación de alimentos.", texto: "No se mantiene en ningún ambiente del establecimiento donde se manipule alimentos, materiales, ni equipos u otros objetos en desuso o inservibles."),
          Pregunta(id: "8", pe: 2, obsCumple: "La distribución de ambientes permite un flujo ordenado de trabajo y previene la contaminación cruzada.", texto: "La distribución de los ambientes permite un flujo de trabajo ordenado y secuencial, evitando riesgos de contaminación cruzada."),
          Pregunta(id: "9", pe: 3, obsCumple: "Pisos, paredes, techos, ventanas y puertas se mantienen limpios y en buen estado de conservación.", texto: "Pisos, paredes, techos, ventanas y puertas de material de fácil limpieza y desinfección, se mantienen limpios y en buen estado de conservación. La unión entre piso y paredes de los ambientes de proceso y almacén es redondeada para facilitar la limpieza y evitar la acumulación de suciedad"),
          Pregunta(id: "10", pe: 2, obsCumple: "Los pasadizos permiten el tránsito seguro y fluido del personal y equipos.", texto: "Los pasadizos permiten el tránsito fluido del personal y de equipos."),
          Pregunta(id: "11", pe: 2, obsCumple: "La ventilación es adecuada y evita la acumulación de humedad en los ambientes.", texto: "La ventilación impide la acumulación de humedad en los ambientes de almacén y aquellos indicados en el PHS."),
          Pregunta(id: "12", pe: 2, obsCumple: "La iluminación es adecuada para las operaciones y las luminarias cuentan con protección.", texto: "El establecimiento cuenta con iluminación natural, artificial o ambas, que permite visualizar con claridad las áreas de trabajo y las operaciones que se realizan a fin de que sean ejecutadas de manera higiénica, evitando que se generen sombras, colores falseados, reflejos o encandilamientos. Tiene todas las luminarias protegidas de manera efectiva a fin de que los alimentos no se contaminen en caso de rotura. Las características específicas de iluminación que precisen los ambientes o áreas se indican en los documentos que sustenten los PGH."),
        ],
      ),
      SubSeccion(
        titulo: "5.2.3 DEL ABASTECIMIENTO DE AGUA",
        preguntas: [
          Pregunta(id: "13", pe: 3, obsCumple: "El establecimiento dispone de agua segura en cantidad suficiente y mantiene el nivel de cloro residual requerido.", texto: "El establecimiento garantiza que el agua que se utiliza es segura o inocua para el consumo humano y la provisión de agua debe ser suficiente para todas las actividades que realiza, mantiene un nivel de cloro residual mínimo de 0.5 ppm en el punto de consumo. Verificar cloro."),
          Pregunta(id: "14", pe: 3, obsCumple: "El sistema de distribución y almacenamiento de agua se encuentra en buen estado de conservación e higiene.", texto: "El sistema de distribución y almacenamiento de agua está en perfecto estado de conservación e higiene, protegido de tal manera que se impida la contaminación del agua."),
          Pregunta(id: "15", pe: 3, obsCumple: "La limpieza y desinfección de tanques, cisternas y reservorios se realiza de manera periódica y documentada.", texto: "La higiene (limpieza y desinfección) de tanques, cisternas y reservorios es periódica. Para el caso de red de distribución, la higiene debe ser realizada por un servicio autorizado por la autoridad competente. Las especificaciones, periodicidad y controles están asentados y documentados en el PHS del establecimiento."),
        ],
      ),
      SubSeccion(
        titulo: "5.2.4 DE LA DISPOSICIÓN DE AGUAS RESIDUALES Y DE RESIDUOS SÓLIDOS",
        preguntas: [
          Pregunta(id: "16", pe: 3, obsCumple: "Las aguas residuales son dispuestas sanitariamente y los puntos de evacuación se encuentran protegidos.", texto: "Las aguas residuales disponen de forma sanitaria, considerando instalar trampas de grasa y evitar la eliminación por el desagüe de aceites usados; asegurando mantener los puntos de evacuación protegidas contra vectores, reflujos y rebose"),
          Pregunta(id: "17", pe: 2, obsCumple: "Los aceites usados son gestionados mediante un sistema adecuado de disposición final.", texto: "El recojo de aceites usados se realiza por las municipalidades o empresas especializadas, de no contar con el servicio deben implementarlo"),
          Pregunta(id: "18", pe: 3, obsCumple: "Los residuos generados en áreas de proceso se disponen en recipientes adecuados y protegidos.", texto: "En los ambientes donde se procesan alimentos, la basura, incluida la vajilla desechada durante las operaciones diarias, se dispone en recipientes en buen estado de conservación e higiene, con capacidad suficiente para la actividad, que cuente con un procedimiento que ofrezca una barrera que evite la contaminación."),
          Pregunta(id: "19", pe: 2, obsCumple: "El almacenamiento temporal de residuos sólidos se realiza en contenedores exclusivos, higiénicos y correctamente ubicados.", texto: "El acopio de los residuos sólidos se realiza en contenedores destinados exclusivamente para tal fin, cuentan con tapa o con un método que garantiza su aislamiento, son en número o capacidad suficiente a la demanda y en perfectas condiciones de higiene y mantenimiento y están ubicados en un ambiente específico, totalmente independiente y separado de los ambientes donde se realizan operaciones con alimentos; se mantienen cerrados cuando no se utilizan."),
        ],
      ),
      SubSeccion(
        titulo: "5.2.5 DE LOS SERVICIOS HIGIÉNICOS Y VESTUARIOS",
        preguntas: [
          Pregunta(id: "20", pe: 3, obsCumple: "Los servicios higiénicos y vestuarios se mantienen operativos, limpios y separados de las áreas de alimentos.", texto: "Los servicios higiénicos y vestuarios se mantienen operativos, en buen estado de conservación e higiene, cuentan con iluminación y ventilación que facilita su uso. Esta área no tiene comunicación directa con las áreas relacionadas con alimentos."),
          Pregunta(id: "21", pe: 3, obsCumple: "Los servicios higiénicos están diseñados para evitar riesgos de contaminación hacia las áreas de alimentos.", texto: "Los servicios higiénicos tanto para el personal como para el público están diseñados de manera que se garantiza la eliminación de las aguas residuales y no tiene acceso directo al área de cocina o al comedor. El número de servicios higiénicos está en correspondencia a la demanda de los comensales."),
          Pregunta(id: "22", pe: 2, obsCumple: "Los aparatos sanitarios son de material adecuado y se mantienen limpios y en buen estado.", texto: "Los inodoros, lavatorios y urinarios son de material sanitario de fácil limpieza y desinfección; y, se mantienen en buen estado de conservación e higiene."),
          Pregunta(id: "23", pe: 1, obsCumple: "Los lavatorios cuentan con jabón y medios higiénicos para el secado de manos.", texto: "Los lavatorios están provistos de dispensadores de jabón, medios higiénicos individuales para el secado de las manos y se evita la presencia de residuos sanitarios en el piso.	"),
          Pregunta(id: "24", pe: 1, obsCumple: "El área de vestuario permite la separación adecuada de la ropa de trabajo y de uso personal.", texto: "El ambiente para fines de vestuario del personal cuenta con facilidades para disponer la ropa de trabajo y de diario de manera que unas y otras no entran en contacto. No se utilizan como vestuarios los ambientes o áreas donde se manipulan o almacenan alimentos"),
          Pregunta(id: "25", pe: 1, obsCumple: "Se exhiben mensajes instructivos para el uso correcto de los servicios higiénicos y el lavado de manos.", texto: "En estos ambientes se colocan mensajes instructivos para su uso correcto, incluyendo la práctica del lavado correcto de las manos, según indicaciones del MINSA."),
        ],
      ),
      SubSeccion(
        titulo: "5.2.6 DE LAS INSTALACIONES PARA EL LAVADO DE MANOS EN EL AMBIENTE DE ELABORACIÓN",
        preguntas: [
          Pregunta(id: "26", pe: 2, obsCumple: "Se dispone de facilidades adecuadas para el lavado higiénico de manos.", texto: "Se cuenta con un lavadero exclusivo para el lavado de manos provisto de agua potable, dispensadores de jabón, medios higiénicos individuales para el secado de manos, así como mensajes instructivos para el correcto lavado de manos. De no tener esta facilidad, se utiliza el lavadero de uso común, evitando la contaminación cruzada. No se utilizan los lavaderos de alimentos para higiene personal"),
        ],
      ),
    ],
  ),
  Seccion(
    titulo: "6. DISPOSICIONES ESPECÍFICAS",
    subsecciones: [
      SubSeccion(
        titulo: "6.2.1 BUENAS PRÁCTICAS DE MANIPULACIÓN DE ALIMENTOS",
        preguntas: [
          Pregunta(id: "27", pe: 2, obsCumple: "El establecimiento cuenta con un programa de BPM implementado y con evidencias de su aplicación.", texto: "Cuentan con programa (virtual o físico) de buenas prácticas de manipulación de alimentos (BPM). Cuenta con evidencias de la implementación y verificación del programa de BPM de alimentos. (Ver documentos)"),
          Pregunta(id: "28", pe: 3, obsCumple: "El establecimiento dispone de un Programa de Higiene y Saneamiento documentado y actualizado.", texto: "El establecimiento cuentan con un Programa de Higiene y Saneamiento (PHS) en forma documentada y detallada, de conformidad con las características propias de la actividad que realice, considerando como mínima los procedimientos de  limpieza y desinfección de ambientes, instalaciones, equipos, mobiliarios de cocina, utensilios, superficies de trabajo, prevención y control de plagas, entre otros, considerando los puntos de control a ser verificados por el servicio con los registros de dichas verificaciones"),
          Pregunta(id: "29", pe: 2, obsCumple: "La iluminación permite una adecuada manipulación e inspección de los alimentos.", texto: "La iluminación permite una adecuada manipulación e inspección de los productos."),
          Pregunta(id: "30", pe: 3, obsCumple: "Se verifica que los alimentos recibidos cumplen con los requisitos de calidad sanitaria.", texto: "Es responsabilidad del establecimiento que los alimentos que recibe (materias primas, ingredientes, productos industrializados, entre otros) cumplan con las características relacionadas a la calidad sanitaria cuyas generalidades se indican en la Norma Sanitaria. "),
          Pregunta(id: "31", pe: 3, obsCumple: "Las especificaciones sanitarias de los alimentos se encuentran definidas en el programa de BPM.", texto: "Las especificaciones detalladas para cada uno de los alimentos o grupos de alimentos se consignan en el programa de BPM"),
          Pregunta(id: "32", pe: 2, obsCumple: "Se mantienen registros actualizados de proveedores y trazabilidad de materias primas.", texto: "Se llevan registros de proveedores y de la procedencia de las materias primas e insumos en general que permite realizar la rastreabilidad con fines sanitarios. Verificar documentación"),
          Pregunta(id: "33", pe: 3, obsCumple: "Se realizan controles para garantizar la cadena de frío durante la recepción de alimentos.", texto: "Para los alimentos que requieren mantener cadena de frío, se realizan los controles para asegurar dicha condición sanitaria y se establecen los procedimientos de recepción en el programa de BPM. Verificar documentación"),
          Pregunta(id: "34", pe: 3, obsCumple: "Los alimentos se almacenan en ambientes limpios, higiénicos y separados de las áreas de preparación.", texto: "Se almacenan en ambientes en buen estado de conservación e higiene, los cuales están separados de las áreas de preparación.	"),
          Pregunta(id: "35", pe: 4, obsCumple: "Los alimentos se mantienen identificados y almacenados en envases adecuados.", texto: "Se almacenan en sus envases originales. Si se requiere o vienen fraccionados, se utilizan envases de uso exclusivo para tal fin, protegidos e identificados con rótulo que incluya el tipo de producto y la fecha de vencimiento"),
          Pregunta(id: "36", pe: 3, obsCumple: "Los productos almacenados cuentan con identificación visible y sistema de rotación PEPS/PVPS.", texto: "Mantienen una correcta identificación de los alimentos que ingresan al almacén con las con las fechas de ingreso y vencimiento visibles a fin de aplicar una correcta rotación del inventario PEPS o PVPS"),
          Pregunta(id: "37", pe: 3, obsCumple: "Los alimentos se almacenan ordenadamente y separados de pisos, paredes y techos.", texto: "Están dispuestos en orden y separados del piso, paredes y techo con espacios que permitan la circulación de aire, la higiene y la inspección sanitaria."),
          Pregunta(id: "38", pe: 2, obsCumple: "No se evidencian productos vencidos ni materiales ajenos a las actividades del establecimiento.", texto: "Se prohíbe la presencia de cualquier objeto o material que no estén relacionados y en uso con los alimentos. No se mantiene en el establecimiento, productos alimenticios con fechas de caducidad vencidas"),
          Pregunta(id: "39", pe: 4, obsCumple: "La cadena de frío se mantiene bajo control y cuenta con registros de verificación.", texto: "Mantienen la cadena de frio de los alimentos que lo requieren. Las temperaturas deben estar bajo control y los registros de su verificación consignados en el programa de BPM. Los equipos de frío tienen un programa de mantenimiento preventivo y limpieza. Verificar documentación"),
          Pregunta(id: "40", pe: 4, obsCumple: "Los alimentos refrigerados y congelados se mantienen dentro de los rangos de temperatura establecidos.", texto: "Los alimentos refrigerados se mantienen a temperaturas de 4ºC a 1ºC y los congelados se mantienen a una temperatura menor o igual a -18°C."),
          Pregunta(id: "41", pe: 4, obsCumple: "El procesamiento de alimentos crudos se realiza evitando riesgos de contaminación cruzada.", texto: "El procesamiento de alimentos crudos, que incluye: recorte, despiece, lavado de vísceras, descamado y eviscerado de pescado; así como, lavado y pelado de vegetales, descongelado, entre otros, no implica riesgo de contaminación cruzada para los alimentos de consumo final, sea directamente por los alimentos crudos o indirectamente por los manipuladores o utensilios y superficies en contacto con ellos"),
          Pregunta(id: "42", pe: 3, obsCumple: "El procesamiento de frutas y hortalizas se realiza de forma separada al de carnes y pescados, utilizando utensilios exclusivos.", texto: "El procesamiento de hortalizas y frutas, especialmente de consumo directo, se realiza en forma separada del procesamiento de carnes y pescados, usando utensilios exclusivos"),
          Pregunta(id: "43", pe: 3, obsCumple: "Las frutas y hortalizas de consumo directo son lavadas y desinfectadas adecuadamente.", texto: "Las hortalizas y frutas se someten a un proceso de lavado y desinfección cuando sean de consumo directo."),
          Pregunta(id: "44", pe: 3, obsCumple: "Los residuos orgánicos generados durante el procesamiento son manejados y retirados de manera higiénica.", texto: "En el área de preparación previa o de procesamiento de crudos se genera gran cantidad de residuos sólidos orgánicos que se disponen en recipientes acorde al volumen que se genera, se evita su presencia en el piso, siendo retirados debidamente tapados sin pasar por las áreas de preparación intermedia y final cuando se esté procesando alimentos"),
          Pregunta(id: "45", pe: 3, obsCumple: "Los alimentos congelados son descongelados mediante procedimientos que preservan su inocuidad.", texto: "Los alimentos crudos congelados que no necesitan de un procesamiento previo pasan directamente al área intermedia. Los trozos de carne, pescado o aves, entre otros, que son descongelados antes de pasar al área intermedia para su cocción, se descongelan completamente en refrigeración evitando la contaminación cruzada por goteo o por contacto hacia otros alimentos"),
          Pregunta(id: "46", pe: 3, obsCumple: "Los métodos de descongelación utilizados garantizan la seguridad sanitaria de los alimentos.", texto: "Los alimentos crudos congelados pueden ser descongelados en agua segura, protegidos, se evita el contacto con el agua o cualquier otro método que no comprometa la inocuidad del producto. Un alimento descongelado no se congela nuevamente, se descongela para su completa preparación"),
          Pregunta(id: "47", pe: 3, obsCumple: "La preparación de alimentos cocidos se realiza en áreas o etapas destinadas para tal fin.", texto: "El procesamiento de cocidos se realiza en un área o etapa de preparación intermedia o de cocción, pudiendo aplicar división en tiempo."),
          Pregunta(id: "48", pe: 3, obsCumple: "Las carnes de aves y cerdos alcanzan temperaturas adecuadas de cocción para garantizar su inocuidad.", texto: "Las carnes de aves y de cerdos están bien cocidas en el centro de las piezas. La temperatura mínima en el músculo profundo en contacto con el hueso (pechuga, muslo) es de por encima de los 80ºC. Los rellenos de carne cocidos también alcanzan está temperatura o mayores y servirse o refrigerarse de inmediato."),
          Pregunta(id: "49", pe: 3, obsCumple: "Las preparaciones con alimentos crudos o de cocción parcial se elaboran bajo condiciones sanitarias controladas.", texto: "Las preparaciones que contemplan carnes a media cocción, crudas o marinadas, entre otras, son preparadas para el consumo inmediato asegurando que proceden de establecimientos de producción y de procesamiento primario con control sanitario"),
          Pregunta(id: "50", pe: 3, obsCumple: "Las grasas y aceites utilizados en frituras son controlados y renovados cuando corresponde.", texto: "Las grasas y aceites utilizados para freír no se calientan a más de 180 °C y durante su reutilización se filtran para eliminar partículas de alimentos que hubieran quedado de las frituras anteriores. Cuando los cambios de color, olor, turbidez, sabor, entre otros, den indicios de un recalentamiento excesivo o quemado se desechan"),
          Pregunta(id: "51", pe: 3, obsCumple: "El área de preparación final se mantiene protegida de riesgos de contaminación cruzada.", texto: "El procesamiento final para servido se realiza en área o etapa seguida de la intermedia, evitando riesgos de contaminación cruzada procedente de cualquier otra área o ambiente. Los ambientes que correspondan a esta área se mantienen en buen estado de conservación e higiene, al igual que los materiales, equipos y utensilios."),
          Pregunta(id: "52", pe: 3, obsCumple: "Las tablas de picar y cuchillos son diferenciados según el tipo de alimento procesado.", texto: "Las tablas de picar y cuchillos son diferentes para alimentos crudos, alimentos cocidos y listos para el consumo."),
          Pregunta(id: "53", pe: 3, obsCumple: "Los alimentos crudos y cocidos se almacenan ordenadamente en los equipos de refrigeración.", texto: "En los equipos de frío ubicados en esta área, los alimentos crudos y cocidos o listos para el consumo se disponen en forma ordenada"),
          Pregunta(id: "54", pe: 3, obsCumple: "Se utilizan guantes de primer uso en manipulaciones directas de alimentos listos para el consumo.", texto: "Para aquellos alimentos que requieran una manipulación directa, previa al consumo inmediato (maki, pelado y cortado de frutas/verduras, entre otros), se utiliza guantes de primer uso."),
          Pregunta(id: "55", pe: 3, obsCumple: "Los equipos en contacto con alimentos permanecen protegidos cuando no están en uso.", texto: "Los equipos que tienen contacto con las comidas son cubiertos cuando no se van a utilizar inmediatamente."),
        ],
      ),
      SubSeccion(
        titulo: "6.2.2 DEL SERVIDO DE LOS ALIMENTOS",
        preguntas: [
          Pregunta(id: "56", pe: 3, obsCumple: "El hielo utilizado proviene de agua apta para consumo humano y se manipula higiénicamente.", texto: "El hielo debe ser de agua para consumo humano para el consumo humano, para ello debe mantenerse en recipientes cerrados en buen estado de conservación e higiene, y no manipularse directamente con las manos."),
          Pregunta(id: "57", pe: 3, obsCumple: "La vajilla, cubiertos y vasos se encuentran limpios y en buen estado de conservación.", texto: "La vajilla, cubiertos y vasos están en buen estado de conservación e higiene."),
          Pregunta(id: "58", pe: 3, obsCumple: "Los alimentos son servidos utilizando prácticas higiénicas que evitan el contacto directo con las manos.", texto: "Los alimentos sin envoltura no se sirven directamente con las manos."),
          Pregunta(id: "59", pe: 2, obsCumple: "Los productos complementarios se dispensan en condiciones higiénicas y seguras.", texto: "Los productos complementarios como azúcar, especias, salsas, productos en polvo, entre otros, se dispensan en recipientes higienizados, siendo preferible el uso de productos envasados comercialmente o dispensados en descartable.	"),
          Pregunta(id: "60", pe: 2, obsCumple: "Los alimentos preparados no permanecen expuestos al ambiente por periodos superiores a los establecidos.", texto: "Para cualquiera de las modalidades de servido o expendio, sean alimentos que se preparan de inmediato o con preparación parcial previa, no se quedan expuestos al ambiente por más de dos (2) horas."),
          Pregunta(id: "61", pe: 3, obsCumple: "Se dispone de una zona destinada a la preparación final, servido y armado de las porciones.", texto: "Se cuenta con una zona de preparación final donde se concluye la preparación, servido y armado de los platos o porciones para el consumo en comedor."),
          Pregunta(id: "62", pe: 2, obsCumple: "Los alimentos destinados al autoservicio se mantienen protegidos contra la contaminación.", texto: "Los alimentos destinados al autoservicio están protegidos de la contaminación por el comensal o personal que sirve."),
          Pregunta(id: "63", pe: 2, obsCumple: "Los alimentos para servicio a domicilio son transportados en condiciones que preservan su inocuidad.", texto: "Los alimentos destinados al servicio a domicilio se transportan protegidos de la contaminación del ambiente."),
          Pregunta(id: "64", pe: 3, obsCumple: "Las bebidas se sirven en envases o recipientes higiénicos y aptos para el consumo.", texto: "Las bebidas se sirven en sus envases originales, en vasos de primer uso (descartable) o de material no descartable limpio e íntegro. Los equipos surtidores o dispensadores se mantienen en buen estado de conservación e higiene"),
          Pregunta(id: "65", pe: 2, obsCumple: "Los complementos utilizados en bebidas son de primer uso y se desechan después de su utilización.", texto: "Los complementos que entran en contacto con las bebidas (adornos, incluidas frutas, sorbetes, otros) son de primer uso y desechados inmediatamente de ser utilizados."),
          Pregunta(id: "66", pe: 3, obsCumple: "Las bebidas industrializadas cumplen con la normativa sanitaria aplicable.", texto: "Las bebidas envasadas comercialmente que se sirvan o utilicen para la elaboración de mezclas y cocteles cumplen con la normativa sanitaria que les aplica como alimentos industrializados y el establecimiento cumple con las restricciones o advertencias para su consumo."),
          Pregunta(id: "67", pe: 3, obsCumple: "El área de bar dispone de facilidades adecuadas para la higiene de utensilios e insumos.", texto: "El área destinada al bar cuenta con un lavadero provisto de agua segura y está conectado a la red de desagüe, caso contrario la higiene de utensilios e insumos se realiza en el área de cocina o aquella acondicionada para tal fin."),
        ],
      ),
      SubSeccion(
        titulo: "6.2.3 SOBRE LA ATENCIÓN AL CONSUMIDOR",
        preguntas: [
          Pregunta(id: "68", pe: 2, obsCumple: "El área de atención al consumidor mantiene mobiliario y equipamiento en condiciones higiénicas adecuadas.", texto: "El área de atención al consumidor, según las modalidades del servicio, cuenta con su mobiliario y mantelería en buen estado de conservación e higiene."),
          Pregunta(id: "69", pe: 2, obsCumple: "Los recipientes para residuos en áreas de atención al público se mantienen limpios y en buen estado.", texto: "Si la modalidad del servicio lo requiere, se colocan recipientes para basura que se mantienen en buen estado de conservación e higiene"),
          Pregunta(id: "70", pe: 2, obsCumple: "Se promueve la higiene de manos de los consumidores mediante facilidades y mensajes informativos.", texto: "Se promueve la higiene de manos de los comensales como medida sanitaria, a través de mensajes educativos y medios para la higiene de manos, por lo menos en los servicios higiénicos. Se facilita el lavado de manos mediante módulos en las áreas de atención al público"),
          Pregunta(id: "71", pe: 2, obsCumple: "Se aplican medidas para prevenir la presencia de alérgenos cuando son comunicados por el consumidor.", texto: "Si un consumidor comunica ser hipersensible o alérgico a algún alimento, se informa al área de cocina para que se apliquen las prácticas que eviten su uso o transferencia a las preparaciones a servir"),
          Pregunta(id: "72", pe: 4, obsCumple: "La sal de mesa se proporciona únicamente a solicitud expresa del consumidor.", texto: "En el marco de minimizar los riesgos de hipertensión arterial en la población y a fin de fomentar las decisiones libres e informadas de los consumidores, sólo se sirve o dispensa sal en mesa en saleros, o en todo lo que haga sus veces, si el consumidor lo solicita en forma expresa."),
        ],
      ),
      SubSeccion(
        titulo: "6.3.1 SOBRE LA SALUD (MANIPULADORES)",
        preguntas: [
          Pregunta(id: "73", pe: 3, obsCumple: "Los manipuladores no presentan signos o condiciones que representen riesgo sanitario para los alimentos.", texto: "No presentan signos vinculados con ETA o tienen heridas infectadas o abiertas, infecciones cutáneas, en oídos, ojos o nariz."),
          Pregunta(id: "74", pe: 4, obsCumple: "Los manipuladores comunican oportunamente cualquier condición de salud que pueda afectar la inocuidad alimentaria.", texto: "Los manipuladores comunican oportunamente a su empleador cuando padezcan cualquiera de estas señales, a fin de no tener contacto con los alimentos y son sometidos a examen médico"),
          Pregunta(id: "75", pe: 4, obsCumple: "El personal manipulador cuenta con exámenes médicos vigentes y disponibles para verificación.", texto: "El empleador tendrá la responsabilidad de que sus manipuladores de alimentos sean sometidos a exámenes médicos vinculados a las ETAs, por lo menos cada seis (6) meses, estando estos documentos (certificados médicos) disponibles para la vigilancia sanitaria que realice la autoridad competente"),
        ],
      ),
      SubSeccion(
        titulo: "6.3.2 SOBRE LA HIGIENE",
        preguntas: [
          Pregunta(id: "76", pe: 3, obsCumple: "Los manipuladores mantienen una adecuada higiene personal durante sus labores.", texto: "Mantienen una rigurosa higiene personal, el cabello limpio y recogido, no llevan artículos de uso personal. Mantienen las manos limpias con uñas cortas y sin esmalte. No fuman ni comen durante las operaciones con alimentos"),
        ],
      ),
      SubSeccion(
        titulo: "6.3.3 SOBRE LA VESTIMENTA",
        preguntas: [
          Pregunta(id: "77", pe: 4, obsCumple: "La vestimenta del personal es exclusiva para el trabajo y se mantiene limpia y en buen estado.", texto: "La vestimenta debe ser de uso exclusivo para el área de trabajo y cubre la ropa de uso personal. La vestimenta se mantiene limpia y en buen estado de conservación, debiendo el personal del área de cocina utilizar preferentemente colores claros."),
        ],
      ),
      SubSeccion(
        titulo: "6.3.4 SOBRE LA CAPACITACIÓN SANITARIA",
        preguntas: [
          Pregunta(id: "78", pe: 3, obsCumple: "El personal manipulador recibe capacitación sanitaria conforme a los requisitos establecidos.", texto: "La capacitación sanitaria de los manipuladores de alimentos es obligatoria y responsabilidad del empleador, puede ser brindada por personal competente de las municipalidades, entidades privadas o personas naturales capacitadas en temas sanitarios de alimentos. Verificar documentación"),
          Pregunta(id: "79", pe: 3, obsCumple: "Los programas de capacitación responden a las necesidades sanitarias del establecimiento.", texto: "Los programas de capacitación son desarrollados en función de las necesidades de cada establecimiento, que permita la aplicación de los PGH. Verificar documentaciòn"),
        ],
      ),
      SubSeccion(
        titulo: "6.4.1 DE LAS PRÁCTICAS DE LIMPIEZA Y DESINFECCIÓN (PHS)",
        preguntas: [
          Pregunta(id: "80", pe: 3, obsCumple: "Los productos de limpieza y desinfección cuentan con la autorización sanitaria correspondiente.", texto: "Los productos de limpieza y desinfección a ser utilizados cuentan con registro sanitario de la autoridad competente."),
          Pregunta(id: "81", pe: 4, obsCumple: "Los equipos y utensilios se mantienen alejados de fuentes potenciales de contaminación.", texto: "No se colocan los equipos o utensilios cerca de drenajes de aguas residuales o cerca de recipientes de residuos."),
          Pregunta(id: "82", pe: 3, obsCumple: "Los individuales reutilizables son limpiados y desinfectados después de cada uso.", texto: "De aplicarse, los individuales de plástico son limpiados y desinfectarlos después de cada uso."),
          Pregunta(id: "83", pe: 1, obsCumple: "Las servilletas de tela son reemplazadas después de cada uso por el consumidor.", texto: "De aplicarse, las servilletas de tela son reemplazadas en cada uso dado por el comensal."),
          Pregunta(id: "84", pe: 1, obsCumple: "Las tablas de picar son de material adecuado y se mantienen en óptimas condiciones higiénicas.", texto: "Las tablas de picar son de material inabsorbente, de superficie lisa y mantenerse en buen estado de conservación e higiene."),
          Pregunta(id: "85", pe: 2, obsCumple: "Las superficies, equipos y utensilios en contacto con alimentos se mantienen limpios y en buen estado.", texto: "Las superficies de trabajo, los equipos y utensilios en contacto con alimentos están en buen estado de conservación e higiene."),
          Pregunta(id: "86", pe: 2, obsCumple: "El lavado y desinfección de vajilla, cubiertos y vasos se realiza conforme a la normativa vigente.", texto: "Para el lavado y desinfección de la vajilla, cubiertos y vasos se realizará siguiendo el procedimiento que indica la normativa vigente. Verificar in situ.	"),
          Pregunta(id: "87", pe: 3, obsCumple: "Los desperdicios generados durante la producción son retirados y eliminados de manera inmediata.", texto: "Durante las actividades en el área de producción, los alimentos, líquidos u otros desperdicios que caen al piso se recogen y desechan de inmediato"),
          Pregunta(id: "88", pe: 2, obsCumple: "La vajilla, cubiertos y vasos se almacenan protegidos de contaminación externa.", texto: "La vajilla, cubiertos y vasos son almacenados en un lugar cerrado, protegido del polvo e insectos. Los vasos, copas y tazas son almacenados colocándolos hacia abajo."),
          Pregunta(id: "89", pe: 3, obsCumple: "Los equipos y utensilios se almacenan adecuadamente después de su limpieza y desinfección.", texto: "Los equipos y utensilios se acondicionan en lugares específicos, debidamente protegidos, posterior al lavado y desinfección."),
          Pregunta(id: "90", pe: 3, obsCumple: "Los equipos y utensilios son aptos para uso alimentario y se mantienen en buen estado de conservación e higiene.", texto: "Los equipos y utensilios son de material de uso alimentario, diseñados de manera que permitan su fácil y completa limpieza, así como su desinfección, no transfieren olores ni contaminación a los alimentos, son resistentes a la corrosión y se mantienen en buen estado de conservación e higiene."),
          Pregunta(id: "91", pe: 3, obsCumple: "Las superficies de mesas, mostradores y estanterías se mantienen limpias y en buen estado.", texto: "La superficie de mesas, mostradores, estanterías, exhibidores y similares, son lisas y mantenerse en buen estado de conservación e higiene."),
          Pregunta(id: "92", pe: 3, obsCumple: "El PHS contempla el mantenimiento y renovación de equipos y utensilios.", texto: "El PHS considera un programa de renovación y mantenimiento de equipos y utensilios que asegure el buen funcionamiento y condición sanitaria de los mismos."),
          Pregunta(id: "93", pe: 3, obsCumple: "Los equipos desmontables son lavados y desinfectados según los procedimientos establecidos.", texto: "Los equipos son desmontables para su lavado y desinfección en la frecuencia y procedimiento indicada en el documento PHS."),
          Pregunta(id: "94", pe: 3, obsCumple: "Los utensilios y superficies en contacto con alimentos son limpiados y desinfectados diariamente.", texto: "Todo menaje de cocina, así como las superficies de parrillas, planchas, azafates, bandejas, recipientes de mesas con sistema de agua caliente (baño maría) y otros que hayan estado en contacto con los alimentos, se limpian, lavan y desinfectan por lo menos una vez al día"),
        ],
      ),
      SubSeccion(
        titulo: "6.4.2 DE LA PREVENCIÓN Y CONTROL DE VECTORES",
        preguntas: [
          Pregunta(id: "95", pe: 3, obsCumple: "El PHS incluye medidas para la prevención y control de vectores y plagas.", texto: "El PHS contempla medidas para la prevención y control de vectores (insectos, roedores y otras plagas), a fin de minimizar los riesgos para la inocuidad de los alimentos"),
          Pregunta(id: "96", pe: 3, obsCumple: "Las acciones de prevención y control de plagas se encuentran documentadas y supervisadas.", texto: "Las medidas preventivas y de control están descritas, documentadas y supervisadas en su cumplimiento dentro del PHS. Verificar documentación"),
          Pregunta(id: "97", pe: 4, obsCumple: "No se evidencia presencia de animales en áreas relacionadas con alimentos.", texto: "No se evidencia la presencia de cualquier animal en cualquier área donde se manipulan directa o indirectamente alimentos."),
          Pregunta(id: "98", pe: 3, obsCumple: "Se mantienen medidas efectivas para impedir el ingreso de plagas al establecimiento.", texto: "Las medidas preventivas están destinadas a evitar el ingreso de insectos, roedores u otras plagas al establecimiento, especialmente a los ambientes de procesamiento."),
          Pregunta(id: "99", pe: 3, obsCumple: "El personal encargado de limpieza utiliza los implementos de protección correspondientes.", texto: "Los operarios de limpieza y desinfección de los establecimientos usan delantales y calzados impermeables."),
          Pregunta(id: "100", pe: 4, obsCumple: "Las acciones de control de plagas son ejecutadas por personal competente utilizando productos autorizados.", texto: "Las medidas de control están destinadas a la erradicación de plagas. Los métodos de control se aplican de forma inmediata cuando exista evidencias de su presencia. La aplicación de rodenticidas e insecticidas para el control de vectores es realizada por personal técnico capacitado o servicios autorizados por el Ministerio de Salud. Los productos utilizados para el control son autorizados"),
          Pregunta(id: "101", pe: 4, obsCumple: "Los productos químicos y biológicos se almacenan de forma segura para evitar contaminación cruzada.", texto: "Los productos químicos y biológicos se guardan bajo estrictas medidas de seguridad, de tal modo de prevenir cualquier posibilidad de contaminación cruzada hacia los alimentos."),
        ],
      ),
      SubSeccion(
        titulo: "6.5. DEL BROTE DE ETA",
        preguntas: [
          Pregunta(id: "102", pe: 2, obsCumple: "El establecimiento conoce y aplica los procedimientos de actuación ante brotes de ETA.", texto: "El establecimiento tiene conocimiento ante la ocurrencia de un brote de ETAS (dar aviso inmediato al establecimiento de salud más cercano, etc.)"),
        ],
      ),
      SubSeccion(
        titulo: "6.6. DEL REGISTRO DE LA INFORMACIÓN",
        preguntas: [
          Pregunta(id: "103", pe: 2, obsCumple: "Los registros relacionados con la aplicación de los PGH se mantienen organizados y disponibles.", texto: "La información que genera el establecimiento con respecto a la aplicación de los PGH, debe estar registrada en forma ordenada y estar disponible."),
        ],
      ),
      SubSeccion(
        titulo: "MEDIDAS DE SEGURIDAD",
        preguntas: [
          Pregunta(id: "104", pe: 2, obsCumple: "El establecimiento cuenta con certificación sanitaria de PGH vigente.", texto: "El establecimiento cuenta con certificación sanitaria de PGH vigente."),
          Pregunta(id: "105", pe: 2, obsCumple: "Los equipos contra incendios se encuentran operativos, vigentes y correctamente ubicados.", texto: "El establecimiento cuenta con dispositivos contra incendios (extintores operativos y vigentes, de fácil acceso y próximos a los puntos de riesgos, debidamente rotulado)."),
          Pregunta(id: "106", pe: 2, obsCumple: "El establecimiento cuenta con señalización visible para actuación en caso de sismos.", texto: "El establecimiento cuenta con señalización contra sismos."),
          Pregunta(id: "107", pe: 2, obsCumple: "El sistema eléctrico se encuentra protegido y en correcto funcionamiento.", texto: "El establecimiento cuentacon un sistema eléctrico protegido y operativo."),
          Pregunta(id: "108", pe: 2, obsCumple: "El sistema de corte y suministro de combustible se encuentra adecuadamente aislado y protegido.", texto: "El establecimiento cuenta con un sistema de corte y suministro de combustible aislado."),
          Pregunta(id: "109", pe: 2, obsCumple: "El personal tiene conocimiento sobre procedimientos de emergencia y primeros auxilios.", texto: "El personal posee conocimiento de procedimientos de emergencia y primeros auxilios."),
          Pregunta(id: "110", pe: 2, obsCumple: "El establecimiento dispone de un botiquín de primeros auxilios operativo y completo.", texto: "El establecimiento cuenta con botiquín de primeros auxilios operativo (crema para quemaduras, vendas, venditas, gasa, alcohol, agua oxigenada, entre otros)."),
          Pregunta(id: "111", pe: 2, obsCumple: "Los balones de gas se encuentran instalados y asegurados de manera segura.", texto: "El establecimiento cuenta con medidas de seguridad de los balones con gas."),
        ],
      ),
    ],
  ),
];