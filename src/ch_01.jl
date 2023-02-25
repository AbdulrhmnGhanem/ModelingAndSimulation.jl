using Unitful

# define some constatnts
a = 9.8u"m/s^2"
T = 3.4u"s"

##
# define a function to calculate the distance from the acceleration and time.
d(a, t) = a * t^2 / 2

d(a, T)
##
# the Empire States Building is 381m tall
h = 381u"m"
##
# define a function to calculate the time the penny would take to hit ground.
t(h, a) = sqrt(2h / a)
t(h, a)
##
##
# define a function to calculate the velocity of the penny when it hits ground.
v(a, t) = a * t
v(a, t(h, a))

##
@assert v(a, t(h, a)) ≈ 86.41527642726142u"m/s"
##
# Convert to miles per hour
v(a, t(h, a)) |> u"mi/s" |> u"mi/hr"
################################################################################

##
# Exercise 1.3
pole_height = 10u"ft"

# first we try foot lhs, meter rhs
new_total_height_rhs = pole_height + h
##
# now we try foot rhs, meter lhs
new_total_height_lhs = h + pole_height

# The behavior her is different thatn Python Pint. In Python Pint, the lhs quantity contols
# the units of the result. In Julia Unitful, the unit is controlled by promotion rules.
# [https://painterqubits.github.io/Unitful.jl/stable/conversion/#Basic-promotion-mechanisms]

################################################################################
# Exercise 1.5
vₜ = 29u"m/s"
tₜ = h / vₜ
##

################################################################################
# Exercise 1.6
t_until_termial_v = vₜ / a
d_until_terminal = d(a, t_until_termial_v)
t_rest = (h - d_until_terminal) / vₜ
t_total = t_until_termial_v + t_rest
##

################################################################################
# Exercise 1.7
# We need to build the model from http://baseball.physics.illinois.edu/ClarkGreerSemonSoftball.pdf.
##

################################################################################
# Exercise 1.8
d_race = 10_000u"m"
t_race = 44u"minute" + 52u"s"
v̄ = d_race / t_race |> u"mi/minute"
pace = 1 / v̄
##
