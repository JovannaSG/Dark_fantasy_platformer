extends Node

# Передаем координаты игрока
signal player_position_update(player_position)
# Передаем урон от врага игроку
signal enemy_attack(enemy_damage)
# Передаем урон от игрока врагу
signal player_attack(plr_dmg)
