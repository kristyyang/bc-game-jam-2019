extends KinematicBody2D

signal died
const R_MINUS = 1

onready var utils = preload("res://Utils.gd")
onready var paths = preload("res://Paths.gd")

var motion = Vector2()
var speed = 150
var size = 10
var invisibility = 100

var knockback = 100
var knockback_duration = 0.3
var knockback_direction = Vector2()

func _ready():
	$Energy.connect('energy_changed', self, '_on_Energy_energy_changed')


func move():
	if Input.is_key_pressed(KEY_D):
		motion.x = 1
	elif Input.is_key_pressed(KEY_A):
		motion.x = -1
	else:
		motion.x = 0
	if Input.is_key_pressed(KEY_W):
		motion.y = -1
	elif Input.is_key_pressed(KEY_S):
		motion.y = 1
	else:
		motion.y = 0

	motion = motion.normalized() * speed

	if is_on_wall():
		motion.y = 0
		motion.x = 0


func _physics_process(delta):
	move()
	var collision = move_and_collide(utils.cartesian_to_isometric(motion) * delta)
	if collision:
		if collision.collider.is_in_group('Guards'):
			knockback_direction = utils.cartesian_to_isometric((collision.collider.global_position - self.global_position).normalized())
			print(knockback_direction.x, ',', knockback_direction.y)
			$Tween.interpolate_property(self, 'position', position, position + knockback * -knockback_direction, knockback_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
			$Tween.start()
			$Energy.take_damage(1)
		elif collision.collider.get_parent().get_name() == 'Foods':
			eat(collision.collider)
			
			collision.collider.queue_free() 

func _on_Energy_energy_changed(energy):
	if energy == 0:
		emit_signal('died')

func eat(food):
	self.invisibility += food.INVISIBILITY
	self.speed += food.SPEED
	$Energy.recover(food.LIFE)
	