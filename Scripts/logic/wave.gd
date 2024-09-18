extends AudioStreamPlayer3D

var playback # Guardará el AudioStreamGeneratorPlayback.
@onready var sample_hz = $".".stream.mix_rate

# Parámetros de la onda
@export var pulse_hz = 440.0 # Frecuencia inicial en Hz
@export var speed = 0.0 # Velocidad inicial de cambio de frecuencia
@export var accel = 0.0 # Aceleración inicial
@export var jerk = 0.0 # Jerk inicial

# Parámetros de la envolvente ADSR
@export var activateADSR: bool = true
@export var attack = 0.1 # Tiempo de ataque (segundos)
@export var decay = 0.2 # Tiempo de decaimiento (segundos)
@export var sustain = 0.7 # Nivel de sustain (0 a 1)
@export var sustain_length = 1.0 # Duración del sustain (segundos)
@export var release = 0.3 # Tiempo de release (segundos)
@export var max_amplitude = 1.0 # Amplitud máxima

var rng = RandomNumberGenerator.new()

func _ready():
	$".".play()
	playback = $".".get_stream_playback()
	fill_buffer()
func  _physics_process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_A):
		var rn = rng.randf_range(60, 100)
		pulse_hz = rn
		fill_buffer()

func fill_buffer():
	var phase = 0.0
	var increment = pulse_hz * TAU / sample_hz
	var frames_available = playback.get_frames_available()

	var time_elapsed = 0.0
	for i in range(frames_available):
		var amplitude = 1.0
		if activateADSR:
			# Calcular la amplitud según la envolvente ADSR
			amplitude = calculate_adsr_amplitude(time_elapsed)
		
		# Generar la onda sinusoidal con la amplitud calculada
		playback.push_frame(Vector2.ONE * sin(phase * TAU) * amplitude)
		phase = fmod(phase + increment, 1)
		print(phase)
		# Modificar la frecuencia en tiempo real usando speed, accel y jerk
		speed += accel # Aumentar la velocidad usando la aceleración
		accel += jerk  # Aumentar la aceleración usando jerk
		pulse_hz += speed # Modificar la frecuencia con la velocidad
		
		# Recalcular el incremento de fase basado en la nueva frecuencia
		increment = pulse_hz / sample_hz
		time_elapsed += 1.0 / sample_hz  # Incrementar el tiempo transcurrido

# Función para calcular la amplitud en función de la envolvente ADSR
func calculate_adsr_amplitude(time_elapsed: float) -> float:
	if time_elapsed < attack:
		# Fase de ataque: subir la amplitud de 0 a max_amplitude
		return (time_elapsed / attack) * max_amplitude
	elif time_elapsed < attack + decay:
		# Fase de decaimiento: bajar la amplitud desde max_amplitude hasta sustain
		var t = time_elapsed - attack
		return max_amplitude - (t / decay) * (max_amplitude - sustain * max_amplitude)
	elif time_elapsed < attack + decay + sustain_length:
		# Fase de sustain: mantener la amplitud en el nivel de sustain
		return sustain * max_amplitude
	elif time_elapsed < attack + decay + sustain_length + release:
		# Fase de release: bajar la amplitud desde suWstain hasta 0
		var t = time_elapsed - (attack + decay + sustain_length)
		return sustain * max_amplitude * (1.0 - t / release)
	else:
		# Después del release: amplitud es 0
		return 0.0
