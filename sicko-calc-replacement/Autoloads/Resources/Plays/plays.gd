class_name Plays
extends Resource

enum Type {ATTACK_BODY, ATTACK_SPIRIT, ATTACK_MIND, VOLLEY, SUPPORT, DEFENSE, NONE = -1}

@export var type : Type = Type.SUPPORT
