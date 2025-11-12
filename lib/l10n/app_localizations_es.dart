// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get trackYourCycle => 'Monitorea tu ciclo';

  @override
  String lastPeriod(Object date) {
    return 'Último período: $date';
  }

  @override
  String get noData => 'Aún no hay datos. ¡Registra tu primer ciclo!';

  @override
  String get avatarStateResting => 'Descansando...';

  @override
  String get avatarStateActive => '¡Activa!';

  @override
  String get calendarTitle => 'Calendario del Ciclo';

  @override
  String get save => 'Guardar';

  @override
  String get tapToLogPeriod => 'Toca un día para registrarlo o anularlo';

  @override
  String get logSymptomsButton => '¿Cómo te sientes hoy?';

  @override
  String get symptomsTitle => 'Síntomas de Hoy';

  @override
  String get symptomCramps => 'Cólicos';

  @override
  String get symptomHeadache => 'Dolor de cabeza';

  @override
  String get symptomNausea => 'Náuseas';

  @override
  String get moodHappy => 'Feliz';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodIrritable => 'Irritable';

  @override
  String get noSymptomsLogged => 'No hay síntomas registrados para hoy.';

  @override
  String get predictionsTitle => 'Predicciones';

  @override
  String nextPeriodPrediction(Object days) {
    return 'Próximo período en ~$days días';
  }

  @override
  String nextPeriodDate(Object date) {
    return 'Alrededor del $date';
  }

  @override
  String get fertileWindow => 'Ventana Fértil';

  @override
  String get ovulation => 'Ovulación Est.';

  @override
  String cycleLength(Object days) {
    return 'Ciclo Prom: $days días';
  }

  @override
  String periodLength(Object days) {
    return 'Período Prom: $days días';
  }

  @override
  String get notEnoughData =>
      'Registra al menos 2 ciclos para ver predicciones.';

  @override
  String get calendarLegendPeriod => 'Tu Período';

  @override
  String get calendarLegendPredicted => 'Período Previsto';

  @override
  String get calendarLegendFertile => 'Ventana Fértil';

  @override
  String get welcomeTitle => '¡Bienvenida a Bloom!';

  @override
  String get welcomeDesc =>
      'Tu compañero personal de ciclo. Vamos a configurarlo.';

  @override
  String get questionPeriodTitle => '¿Cuándo comenzó tu último período?';

  @override
  String get questionPeriodDesc =>
      'Puedes registrarlo en el calendario. ¡Si no te acuerdas, no pasa nada!';

  @override
  String get questionLengthTitle =>
      '¿Cuál es la duración promedio de tu ciclo?';

  @override
  String get questionLengthDesc =>
      'Es el tiempo desde el inicio de un período hasta el siguiente. (Por defecto 28 días)';

  @override
  String get skip => 'Omitir';

  @override
  String get done => 'Hecho';

  @override
  String get pickADate => 'Elige una fecha';

  @override
  String get days => 'días';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotificationsDesc => 'Mostrar alertas de predicciones';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSupport => 'Soporte';

  @override
  String get settingsSupportDesc => 'Reportar un error o hacer una pregunta';

  @override
  String get notificationPeriodTitle => '¡Aviso de Bloom!';

  @override
  String notificationPeriodBody(Object days) {
    return 'Se predice que tu período comenzará en $days días.';
  }

  @override
  String get notificationFertileTitle => '¡Aviso de Bloom!';

  @override
  String get notificationFertileBody =>
      'Se predice que tu ventana fértil comenzará mañana.';

  @override
  String get logPeriodStartButton => 'Período Inició Hoy';

  @override
  String get logPeriodEndButton => 'Período Terminó Hoy';

  @override
  String periodIsActive(Object day) {
    return 'Estás en el día $day de tu período';
  }

  @override
  String periodDelayed(Object days) {
    return 'Período retrasado $days días';
  }

  @override
  String get avatarStateDelayed => 'Esperando...';

  @override
  String get avatarStateFollicular => '¡La energía regresa!';

  @override
  String get avatarStateOvulation => '¡Pico de energía!';

  @override
  String get avatarStateLuteal => 'Tiempo de descansar';

  @override
  String get insightNone =>
      '¡Registra tu primer ciclo en el calendario para empezar a ver ideas!';

  @override
  String get insightMenstruation_1 =>
      '¡Hora de acurrucarse! Tu energía está en su punto más bajo, y está bien. Recuerda descansar, ver tu programa favorito, y quizás comer esa barra de chocolate. 🍫';

  @override
  String get insightMenstruation_2 =>
      'Tu cuerpo está trabajando duro. ¡Escúchalo! Un estiramiento suave o un baño caliente pueden hacer maravillas por los cólicos.';

  @override
  String get insightMenstruation_3 =>
      'Es normal sentirse cansada. Tus hormonas están en su nivel más bajo. Prioriza el sueño y la hidratación hoy.';

  @override
  String get insightFollicular_1 =>
      '¡La energía está volviendo! El estrógeno está aumentando. Un gran día para hacer planes o hacer esa rutina de ejercicio que has estado posponiendo.';

  @override
  String get insightFollicular_2 =>
      'Tu mente se está aclarando. Este es un buen momento para aprender algo nuevo o abordar un problema complicado.';

  @override
  String get insightFollicular_3 =>
      '¡Mejora de ánimo! A medida que termina tu período, podrías sentirte más positiva y sociable. ¡Disfrútalo!';

  @override
  String get insightOvulation_1 =>
      '¡Estás en tu apogeo! 🌟 Hoy es tu día para brillar. La confianza y la energía están al máximo. Momento perfecto para tareas desafiantes o socializar.';

  @override
  String get insightOvulation_2 =>
      'Puede que te sientas extra confiada hoy. ¡Es el pico de estrógeno! Un gran día para expresar tu opinión o liderar un proyecto.';

  @override
  String get insightOvulation_3 =>
      '¡Pico de energía! Tu cuerpo está listo para ejercicio más intenso si te apetece. También podrías sentirte más conectada con los demás.';

  @override
  String get insightLuteal_1 =>
      'Podrías sentirte un poco irritable o cansada, culpa a la progesterona. Esto se llama SPM. Sé más amable contigo misma, ahora es el momento de cuidarte.';

  @override
  String get insightLuteal_2 =>
      '¿Antojos de comida? Es normal. Tu cuerpo está quemando más calorías. Opta por carbohidratos complejos o chocolate negro para mantener el equilibrio.';

  @override
  String get insightLuteal_3 =>
      '¿Te sientes un poco hinchada o sensible? Es la fase lútea. Intenta reducir la sal y beber más agua. ¡Ayuda!';

  @override
  String get insightDelayed_1 =>
      '¿Período retrasado? Pequeñas fluctuaciones son normales, el estrés o cambios en la rutina pueden ser la causa. Solo sigue monitoreando.';

  @override
  String get insightDelayed_2 =>
      'Esperando... Es común tener un retraso de uno o dos días. Intenta relajarte, dormir bien y ver qué pasa mañana.';

  @override
  String get insightDelayed_3 =>
      'Tu cuerpo tiene su propio ритмо. Un período tardío puede ocurrir por muchas razones. Si estás preocupada, siempre puedes hablar con un adulto de confianza.';

  @override
  String get settingsTheme => 'Tema de la App';

  @override
  String get themeRose => 'Rosa Suave';

  @override
  String get themeNight => 'Noche Iluminada';

  @override
  String get themeForest => 'Calma del Bosque';

  @override
  String get questionPeriodLengthTitle =>
      '¿Cuál es la duración media de tu período?';

  @override
  String get questionPeriodLengthDesc =>
      'Esto nos ayuda a hacer una primera predicción más precisa. (Normalmente 3-7 días)';

  @override
  String get settingsCycleCalculationTitle =>
      'Cálculo de la duración del ciclo';

  @override
  String get settingsUseManualCalculation => 'Usar cálculo manual';

  @override
  String get settingsUseManualCalculationDesc =>
      'Las predicciones se basarán en el valor siguiente';

  @override
  String get settingsManualCycleLength => 'Duración manual del ciclo';

  @override
  String get settingsManualCycleLengthDialogTitle =>
      'Seleccionar duración del ciclo';

  @override
  String settingsManualCycleLengthDays(int count) {
    return '$count días';
  }

  @override
  String get dialogCancel => 'Cancelar';

  @override
  String get dialogOK => 'Aceptar';

  @override
  String get homeConfirmStartTitle => '¿Iniciar Período?';

  @override
  String get homeEmptyDesc =>
      'Comienza a registrar tu período para ver predicciones. Presiona el botón \'+\' para comenzar.';

  @override
  String get homeConfirmStartDesc =>
      '¿Estás segura de que quieres marcar hoy como el inicio de tu período?';

  @override
  String get homeConfirmEndTitle => '¿Finalizar Período?';

  @override
  String get homeConfirmEndDesc =>
      '¿Estás segura de que quieres marcar hoy como el final de tu período?';

  @override
  String get homeConfirmYes => 'Sí';

  @override
  String get homeConfirmNo => 'No';

  @override
  String get calendarLongPressHint =>
      'Mantén presionado un día para registrar síntomas';

  @override
  String get homeHello => '¡Hola!';

  @override
  String get homeInsight => 'Perspectiva';

  @override
  String get homeToday => 'Hoy';

  @override
  String get homeEmptyTitle => 'Aún no hay datos';

  @override
  String homeDayOfCycle(int day) {
    return 'Día $day';
  }

  @override
  String homePredictionNextIn(Object days) {
    return 'Próximo período en $days días';
  }

  @override
  String homePredictionOvulationIn(Object days) {
    return 'Ovulación en $days días';
  }

  @override
  String get homePredictionFertile => 'Ventana Fértil';

  @override
  String get homePredictionPeriod => 'Período';

  @override
  String get homePredictionDelayed => 'Retrasado';

  @override
  String get phaseMenstruation => 'Período';

  @override
  String get phaseFollicular => 'Fase Folicular';

  @override
  String get phaseOvulation => 'Ovulación';

  @override
  String get phaseLuteal => 'Fase Lútea';

  @override
  String get phaseDelayed => 'Retrasado';

  @override
  String get phaseNone => 'Sin datos';

  @override
  String get settingsPillTrackerTitle => 'Píldoras Anticonceptivas';

  @override
  String get settingsPillTrackerEnable => 'Activar recordatorios de píldora';

  @override
  String get settingsPillTrackerDesc =>
      'Esto desactivará todas las predicciones del ciclo (ovulación, ventana fértil) y configurará recordatorios diarios de la píldora.';

  @override
  String get settingsPillTrackerTime => 'Hora del recordatorio';

  @override
  String get settingsPillTrackerTimeNotSet => 'No establecido';

  @override
  String get pillTrackerTabTitle => 'Píldoras';

  @override
  String get pillScreenTitle => 'Seguidor de Píldoras';

  @override
  String get pillTakenButton => 'He tomado mi píldora';

  @override
  String get pillAlreadyTaken => '¡Tomada hoy!';

  @override
  String get pillInfoButton => 'Aprender sobre las píldoras';

  @override
  String get pillInfoTitle => 'Sobre las Píldoras';

  @override
  String get pillInfoWhatAreThey => '¿Qué son las píldoras anticonceptivas?';

  @override
  String get pillInfoWhatAreTheyBody =>
      'Las píldoras anticonceptivas son un tipo de medicamento que las mujeres pueden tomar diariamente para prevenir el embarazo. Contienen hormonas que detienen la ovulación (la liberación de un óvulo del ovario).';

  @override
  String get pillInfoHowToUse => '¿Cómo usarlas?';

  @override
  String get pillInfoHowToUseBody =>
      'Debes tomar una píldora todos los días, a la misma hora cada día. La constancia es muy importante. La mayoría de los paquetes tienen 21 píldoras activas y 7 píldoras de placebo (azúcar), o 28 píldoras activas. Durante la semana de placebo, es probable que tengas un sangrado por deprivación, que es como un período.';

  @override
  String get pillInfoWhatIfMissed => '¿Qué pasa si olvido una píldora?';

  @override
  String get pillInfoWhatIfMissedBody =>
      'Si olvidas una píldora, tómala tan pronto como lo recuerdes, incluso si significa tomar dos píldoras en un día. Si olvidas dos o más píldoras, tu riesgo de embarazo aumenta. Toma la última píldora que olvidaste, desecha las otras píldoras olvidadas y usa un método anticonceptivo de respaldo (como un condón) durante los próximos 7 días. Lee siempre el prospecto de tu marca específica de píldora o consulta a tu médico.';

  @override
  String get notificationPillTitle => 'Bloom: Recordatorio 💊';

  @override
  String get notificationPillBody => '¡Es hora de tomar tu píldora!';

  @override
  String get pillSetupTitle => 'Configurar Paquete';

  @override
  String get pillSetupDesc =>
      'Para comenzar, proporciona información sobre tu paquete de píldoras.';

  @override
  String get pillSetupStartDate => '¿Cuándo comenzó este paquete?';

  @override
  String get pillSetupActiveDays => 'Píldoras activas (ej. 21)';

  @override
  String get pillSetupPlaceboDays => 'Días de placebo/descanso (ej. 7)';

  @override
  String get pillSetupSaveButton => 'Comenzar Seguimiento';

  @override
  String get pillDay => 'Día';

  @override
  String get pillDayActive => 'Activa';

  @override
  String get pillDayPlacebo => 'Placebo';

  @override
  String get calendarLegendPill => 'Píldora tomada';

  @override
  String get pillResetTitle => '¿Reiniciar Paquete?';

  @override
  String get pillResetDesc =>
      'Esto borrará la configuración actual de tu paquete de píldoras y tendrás que configurarlo de nuevo. Tu historial de píldoras tomadas se conservará.';

  @override
  String get pillResetButton => 'Reiniciar';

  @override
  String get symptomNotesLabel => 'Notas para hoy...';

  @override
  String get calendarLegendNote => 'Nota añadida';

  @override
  String get logBleedingButton => 'Registrar sangrado';

  @override
  String get logBleedingEndButton => 'Finalizar Sangrado';

  @override
  String homeBleedingDay(int day) {
    return 'Día de Sangrado: $day';
  }

  @override
  String get calendarLegendBleeding => 'Sangrado por deprivación';

  @override
  String get insightPillActive =>
      'Estás tomando una píldora activa. ¡Recuerda tomarla a la misma hora todos los días! La constancia es clave.';

  @override
  String get insightPillPlacebo =>
      'Estás en tu semana de placebo (descanso). Es normal tener un sangrado por deprivación (similar a un período) ahora. ¡No olvides empezar tu nuevo paquete a tiempo!';

  @override
  String get notificationPillActionTaken => 'Marcar como tomada';

  @override
  String get calendarEmptyState =>
      'Здесь появится ваша история. Нажмите на день, чтобы отметить месячные или кровотечение.';

  @override
  String get authLogin => 'Iniciar Sesión';

  @override
  String get authRegister => 'Registrarse';

  @override
  String get authEmail => 'Correo';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authSwitchToRegister => '¿No tienes cuenta? Regístrate';

  @override
  String get authSwitchToLogin => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get authSignOut => 'Cerrar Sesión';

  @override
  String get authSignOutConfirm =>
      '¿Estás segura de que quieres cerrar sesión?';

  @override
  String get authWithGoogle => 'Iniciar sesión con Google';

  @override
  String get authAsGuest => 'Continuar como invitado';

  @override
  String get authLinkAccount => 'Vincular cuenta de Google';

  @override
  String get authLinkDesc =>
      'Guarda tus datos y sincronízalos entre dispositivos vinculando tu cuenta de Google.';

  @override
  String get authAccount => 'Cuenta';

  @override
  String get authOr => 'o';

  @override
  String get authLinkSuccess => '¡Cuenta vinculada con éxito!';

  @override
  String get authLinkError => 'Error al vincular la cuenta: ';
}
